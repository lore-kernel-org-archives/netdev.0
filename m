From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] net: SCTP remote/local Denial of Service vulnerability
 description and fix
Date: Wed, 15 Sep 2010 10:02:16 -0400
Message-ID: <4C90D1E8.7000404@hp.com>
References: <201009151001.59860.dreibh@iem.uni-due.de>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070900030609000603040207"
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	Martin Becke <martin.becke@uni-due.de>
To: Thomas Dreibholz <dreibh@iem.uni-due.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0006.atlanta.hp.com ([15.192.0.43]:42434 "EHLO
	g5t0006.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752994Ab0IOOCW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 10:02:22 -0400
In-Reply-To: <201009151001.59860.dreibh@iem.uni-due.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------070900030609000603040207
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 09/15/2010 04:01 AM, Thomas Dreibholz wrote:
> sctp_outq_flush() in net/sctp/outqueue.c may call sctp_packet_reset() on a 
> packet structure which has already been filled with chunks. sctp_packet_reset() 
> will not take care of the chunks in its list and only reset the packet length. 
> After that, the SCTP code assumes the packet to be re-initialized and adds 
> further chunks to the structure. The length will be wrong. When actually 
> trying to transmit the packet, the packet sk_buff structure may be exceeded 
> within sctp_packet_transmit(), resulting in skb_over_panic() => denial of 
> service.
> 
> Such a DoS can be triggered by a malicious remote SCTP instance, as follows:
> - The remote endpoint has to use two paths (i.e. 2 IP addresses); easy to 
> achieve using an IPv4 address and an IPv6 address -> path A and B.
> - The remote user has to trigger the transmission of a HEARTBEAT_ACK on path 
> A. This is trivial, by sending a HEARTBEAT chunk. sctp_outq_flush() will call 
> sctp_packet_config() for the packet on path A. The HEARTBEAT_ACK will be added 
> to this packet.
> - The remote user has to trigger a DATA chunk retransmission on path B. This 
> is trivial, since it only has to send appropriate SACK chunks. 
> sctp_outq_flush() notices that the retransmission is on a different path and 
> calls sctp_packet_config() for the packet on path B. The DATA chunk to be 
> retransmitted is added to this packet.
> - The local instance has to send another DATA chunk on path A. This depends on 
> the application, but should be easy to trigger from a remote instance. 
> sctp_outq_flush() notices that the path has changed again, and calls 
> sctp_packet_config() for the packet on path A. This resets the size of the 
> HEARTBEAT_ACK chunk, but the chunk remains in the packet. If 
> size(HEARTBEAT_ACK) + size(DATA) > MTU - overhead, the next call to 
> sctp_packet_transmit() causes the kernel panic => DoS.
> In a similar way, the problem can also be triggered by a local user, having 
> only the permission to establish SCTP associations. Of course, the problem can 
> also occur during normal network operation, just by a retransmission at the 
> wrong time.
> 
> The patch below against 2.6.36-rc4 (git repository) fixes sctp_outq_flush() by 
> ensuring that the packet on each path is initialized only once. Furthermore, a 
> BUG_ON() statement ensures that further problems by calling 
> sctp_packet_reset() on packets with chunks are detected directly.
> 

Actually I have a much easier solution.  When calling packet_config, we should not
be resetting the packet contents.

Packet contents need to be reset when a new packet is created or when the packet has
been sent.  We explicitly reset it after sending in sctp_packet_transmit.  We also reset it
in sctp_packet_init().  So, code such as:
	sctp_packet_init()
	sctp_packet_config()

already guarantees that at config time we have a clear packet.

So, simply removing a reset call from sctp_packet_config() solves this issue.

I've attached the patch that corrects this.

-vlad

> Signed-off-by: Thomas Dreibholz <dreibh@iem.uni-due.de>
> ---
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index a646681..744e667 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -72,6 +72,7 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet 
> *packet,
> 
>  static void sctp_packet_reset(struct sctp_packet *packet)
>  {
> +        BUG_ON(!list_empty(&packet->chunk_list));
>  	packet->size = packet->overhead;
>  	packet->has_cookie_echo = 0;
>  	packet->has_sack = 0;
> diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
> index c04b2eb..69296c8 100644
> --- a/net/sctp/outqueue.c
> +++ b/net/sctp/outqueue.c
> @@ -799,13 +799,13 @@ static int sctp_outq_flush(struct sctp_outq *q, int 
> rtx_timeout)
>  		 */
>  		if (new_transport != transport) {
>  			transport = new_transport;
> +			packet = &transport->packet;
>  			if (list_empty(&transport->send_ready)) {
>  				list_add_tail(&transport->send_ready,
>  					      &transport_list);
> +				sctp_packet_config(packet, vtag,
> +					      asoc->peer.ecn_capable);
>  			}
> -			packet = &transport->packet;
> -			sctp_packet_config(packet, vtag,
> -					   asoc->peer.ecn_capable);
>  		}
> 
>  		switch (chunk->chunk_hdr->type) {
> @@ -900,15 +900,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int 
> rtx_timeout)
>  			/* Switch transports & prepare the packet.  */
> 
>  			transport = asoc->peer.retran_path;
> +			packet = &transport->packet;
> 
>  			if (list_empty(&transport->send_ready)) {
>  				list_add_tail(&transport->send_ready,
>  					      &transport_list);
> +				sctp_packet_config(packet, vtag,
> +						   asoc->peer.ecn_capable);
>  			}
> -
> -			packet = &transport->packet;
> -			sctp_packet_config(packet, vtag,
> -					   asoc->peer.ecn_capable);
>  		retran:
>  			error = sctp_outq_flush_rtx(q, packet,
>  						    rtx_timeout, &start_timer);
> @@ -970,6 +969,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int 
> rtx_timeout)
>  			/* Change packets if necessary.  */
>  			if (new_transport != transport) {
>  				transport = new_transport;
> +				packet = &transport->packet;
> 
>  				/* Schedule to have this transport's
>  				 * packet flushed.
> @@ -977,15 +977,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int 
> rtx_timeout)
>  				if (list_empty(&transport->send_ready)) {
>  					list_add_tail(&transport->send_ready,
>  						      &transport_list);
> -				}
> +					sctp_packet_config(packet, vtag,
> +							   asoc->peer.ecn_capable);
> 
> -				packet = &transport->packet;
> -				sctp_packet_config(packet, vtag,
> -						   asoc->peer.ecn_capable);
> -				/* We've switched transports, so apply the
> -				 * Burst limit to the new transport.
> -				 */
> -				sctp_transport_burst_limited(transport);
> +					/* We've switched transports, so apply the
> +					 * Burst limit to the new transport.
> +					 */
> +					sctp_transport_burst_limited(transport);
> +				}
>  			}
> 
>  			SCTP_DEBUG_PRINTK("sctp_outq_flush(%p, %p[%s]), ",
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 


--------------070900030609000603040207
Content-Type: text/x-patch;
 name="0001-sctp-Do-not-reset-the-packet-during-sctp_packet_conf.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-sctp-Do-not-reset-the-packet-during-sctp_packet_conf.pa";
 filename*1="tch"

>From cb27bb964b8f34829c6290cbdeb20a38d579c721 Mon Sep 17 00:00:00 2001
From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 15 Sep 2010 10:00:26 -0400
Subject: [PATCH] sctp: Do not reset the packet during sctp_packet_config().

sctp_packet_config() is called when getting the packet ready
for appending of chunks.  The function should not touch the
current state, since it's possible to ping-pong between two
transports when sending, and that can result packet corruption
followed by skb overlfow crash.

Reported-by: Thomas Dreibholz <dreibh@iem.uni-due.de>
Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/output.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index a646681..bcc4590 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -92,7 +92,6 @@ struct sctp_packet *sctp_packet_config(struct sctp_packet *packet,
 	SCTP_DEBUG_PRINTK("%s: packet:%p vtag:0x%x\n", __func__,
 			  packet, vtag);
 
-	sctp_packet_reset(packet);
 	packet->vtag = vtag;
 
 	if (ecn_capable && sctp_packet_empty(packet)) {
-- 
1.7.0.4


--------------070900030609000603040207--
