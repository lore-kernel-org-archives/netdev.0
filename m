From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 18592] New: Remote/local Denial of Service
 vulnerability in SCTP packet/chunk handling
Date: Wed, 15 Sep 2010 12:43:40 -0700
Message-ID: <20100915124340.5bf89d07.akpm@linux-foundation.org>
References: <bug-18592-10286@https.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Sridhar Samudrala <sri@us.ibm.com>, linux-sctp@vger.kernel.org
To: dreibh@iem.uni-due.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:38378 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752551Ab0IOTom (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Sep 2010 15:44:42 -0400
In-Reply-To: <bug-18592-10286@https.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


(switched to email.  Please respond via emailed reply-to-all, not via the
bugzilla web interface).

On Wed, 15 Sep 2010 12:17:21 GMT
bugzilla-daemon@bugzilla.kernel.org wrote:

> https://bugzilla.kernel.org/show_bug.cgi?id=18592
> 
>            Summary: Remote/local Denial of Service vulnerability in SCTP
>                     packet/chunk handling
>            Product: Networking
>            Version: 2.5
>     Kernel Version: 2.6.36-rc4
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: blocking
>           Priority: P1
>          Component: Other
>         AssignedTo: acme@ghostprotocols.net
>         ReportedBy: dreibh@iem.uni-due.de
>         Regression: No
> 
> 
> Created an attachment (id=30132)
>  --> (https://bugzilla.kernel.org/attachment.cgi?id=30132)
> Patch to fix the problem
> 
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
> 
> PID: 13309  TASK: f6636600  CPU: 1   COMMAND: "scriptingclient"
>  #0 [e4d91968] crash_kexec at c0189fea
>  #1 [e4d919b4] do_invalid_op at c0104a46
>  #2 [e4d91a50] error_code (via invalid_op) at c058d1a1
>     EAX: 0000008b  EBX: f89e168d  ECX: ffffff78  EDX: 00000000  EBP: e4d91ab8
>     DS:  007b      ESI: f601e000  ES:  007b      EDI: e44570e8  GS:  00e0
>     CS:  0060      EIP: c04b9d7c  ERR: ffffffff  EFLAGS: 00010286
>  #3 [e4d91a84] skb_over_panic at c04b9d7c
>  #4 [e4d91a94] sctp_packet_transmit at f89e1688
>  #5 [e4d91ac8] sctp_packet_transmit at f89e1688
>  #6 [e4d91b14] sctp_packet_transmit_chunk at f89e1d23
>  #7 [e4d91b2c] sctp_outq_flush at f89d78f9
>  #8 [e4d91ba8] sctp_outq_uncork at f89d7994
>  #9 [e4d91bb0] sctp_cmd_interpreter at f89cce71
> #10 [e4d91c00] sctp_side_effects at f89cdbff
> #11 [e4d91c30] sctp_do_sm at f89cdd3d
> #12 [e4d91cdc] sctp_assoc_bh_rcv at f89d1279
> #13 [e4d91d0c] sctp_inq_push at f89d6773
> #14 [e4d91d14] sctp_rcv at f89e2e5d
> #15 [e4d91d8c] ip_local_deliver_finish at c04ec6e5
> #16 [e4d91db0] ip_local_deliver at c04ec93a
> #17 [e4d91dcc] ip_rcv_finish at c04ebf98
> #18 [e4d91df4] ip_rcv at c04ec449
> #19 [e4d91e1c] netif_receive_skb at c04c37a4
> #20 [e4d91e58] e1000_receive_skb at f80a45bb
> #21 [e4d91e68] e1000_clean_rx_irq at f80a88b6
> #22 [e4d91edc] e1000_clean at f80a799d
> #23 [e4d91efc] net_rx_action at c04c410a
> #24 [e4d91f28] __do_softirq at c0153132
> #25 [e4d91f70] do_softirq at c0153290
> #26 [e4d91f7c] irq_exit at c01533e0
> #27 [e4d91f84] do_IRQ at c0591240
> #28 [e4d91fb0] common_interrupt at c0103a2b
>     EAX: 9af6e0c6  EBX: b0dad373  ECX: 00000005  EDX: 4d995cbc
>     DS:  007b      ESI: 598130cd  ES:  007b      EDI: 00b5dfc0
>     SS:  007b      ESP: bfca6d80  EBP: bfca6df8  GS:  0033
>     CS:  0073      EIP: 0804b816  ERR: ffffff55  EFLAGS: 00000a86
> 
> In a similar way, the problem can also be triggered by a local user, having 
> only the permission to establish SCTP associations. Of course, the problem can 
> also occur during normal network operation, just by a retransmission at the 
> wrong time.
> 
> 
> The attached patch against 2.6.36-rc4 (git repository) fixes sctp_outq_flush()
> by ensuring that the packet on each path is initialized only once. Furthermore,
> a BUG_ON() statement ensures that further problems by calling 
> sctp_packet_reset() on packets with chunks are detected directly.
> 

Thanks, but please send patches via email, not via bugzilla. 
Documentation/SubmittingPatches has some tips.  Suitable recipients for
this patch are, from the MAINTAINERS file:

M:      Vlad Yasevich <vladislav.yasevich@hp.com>
M:      Sridhar Samudrala <sri@us.ibm.com>
L:      linux-sctp@vger.kernel.org

but please just send it as a reply-to-all to this email so that everyone
knows wht's happening.

I'd suggest that you also add the line

Cc: <stable@kernel.org>

to the end of the changelog so that we don't forget to consider the
patch for backporting.



diff --git a/net/sctp/output.c b/net/sctp/output.c
index a646681..744e667 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -72,6 +72,7 @@ static sctp_xmit_t sctp_packet_will_fit(struct sctp_packet *packet,
 
 static void sctp_packet_reset(struct sctp_packet *packet)
 {
+        BUG_ON(!list_empty(&packet->chunk_list));
 	packet->size = packet->overhead;
 	packet->has_cookie_echo = 0;
 	packet->has_sack = 0;
diff --git a/net/sctp/outqueue.c b/net/sctp/outqueue.c
index c04b2eb..69296c8 100644
--- a/net/sctp/outqueue.c
+++ b/net/sctp/outqueue.c
@@ -799,13 +799,13 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 		 */
 		if (new_transport != transport) {
 			transport = new_transport;
+			packet = &transport->packet;
 			if (list_empty(&transport->send_ready)) {
 				list_add_tail(&transport->send_ready,
 					      &transport_list);
+				sctp_packet_config(packet, vtag,
+					      asoc->peer.ecn_capable);
 			}
-			packet = &transport->packet;
-			sctp_packet_config(packet, vtag,
-					   asoc->peer.ecn_capable);
 		}
 
 		switch (chunk->chunk_hdr->type) {
@@ -900,15 +900,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			/* Switch transports & prepare the packet.  */
 
 			transport = asoc->peer.retran_path;
+			packet = &transport->packet;
 
 			if (list_empty(&transport->send_ready)) {
 				list_add_tail(&transport->send_ready,
 					      &transport_list);
+				sctp_packet_config(packet, vtag,
+						   asoc->peer.ecn_capable);
 			}
-
-			packet = &transport->packet;
-			sctp_packet_config(packet, vtag,
-					   asoc->peer.ecn_capable);
 		retran:
 			error = sctp_outq_flush_rtx(q, packet,
 						    rtx_timeout, &start_timer);
@@ -970,6 +969,7 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 			/* Change packets if necessary.  */
 			if (new_transport != transport) {
 				transport = new_transport;
+				packet = &transport->packet;
 
 				/* Schedule to have this transport's
 				 * packet flushed.
@@ -977,15 +977,14 @@ static int sctp_outq_flush(struct sctp_outq *q, int rtx_timeout)
 				if (list_empty(&transport->send_ready)) {
 					list_add_tail(&transport->send_ready,
 						      &transport_list);
-				}
+					sctp_packet_config(packet, vtag,
+							   asoc->peer.ecn_capable);
 
-				packet = &transport->packet;
-				sctp_packet_config(packet, vtag,
-						   asoc->peer.ecn_capable);
-				/* We've switched transports, so apply the
-				 * Burst limit to the new transport.
-				 */
-				sctp_transport_burst_limited(transport);
+					/* We've switched transports, so apply the
+					 * Burst limit to the new transport.
+					 */
+					sctp_transport_burst_limited(transport);
+				}
 			}
 
 			SCTP_DEBUG_PRINTK("sctp_outq_flush(%p, %p[%s]), ",

