From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [Bugme-new] [Bug 18592] New: Remote/local Denial of Service vulnerability
 in SCTP packet/chunk handling
Date: Wed, 15 Sep 2010 20:34:29 -0400
Message-ID: <4C916615.4060400@hp.com>
References: <bug-18592-10286@https.bugzilla.kernel.org/> <20100915124340.5bf89d07.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dreibh@iem.uni-due.de, bugzilla-daemon@bugzilla.kernel.org,
	netdev@vger.kernel.org, Sridhar Samudrala <sri@us.ibm.com>,
	linux-sctp@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:17655 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753890Ab0IPAeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 20:34:36 -0400
In-Reply-To: <20100915124340.5bf89d07.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/15/2010 03:43 PM, Andrew Morton wrote:
>
> 
> Thanks, but please send patches via email, not via bugzilla. 
> Documentation/SubmittingPatches has some tips.  Suitable recipients for
> this patch are, from the MAINTAINERS file:
> 
> M:      Vlad Yasevich <vladislav.yasevich@hp.com>
> M:      Sridhar Samudrala <sri@us.ibm.com>
> L:      linux-sctp@vger.kernel.org
> 
> but please just send it as a reply-to-all to this email so that everyone
> knows wht's happening.
> 
> I'd suggest that you also add the line
> 
> Cc: <stable@kernel.org>
> 
> to the end of the changelog so that we don't forget to consider the
> patch for backporting.
> 
> 

Hi Andrew

There is a much simpler solution to this problem that I posted to netdev today.

-vlad.


> 
> diff --git a/net/sctp/output.c b/net/sctp/output.c
> index a646681..744e667 100644
> --- a/net/sctp/output.c
> +++ b/net/sctp/output.c
> @@ -72,6 +72,7 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
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
> @@ -799,13 +799,13 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
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
> @@ -900,15 +900,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
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
> @@ -970,6 +969,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
>  			/* Change packets if necessary.  */
>  			if (new_transport != transport) {
>  				transport = new_transport;
> +				packet = &transport->packet;
>  
>  				/* Schedule to have this transport's
>  				 * packet flushed.
> @@ -977,15 +977,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
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
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

