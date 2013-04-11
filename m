From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH v2] tcp: Reallocate headroom if it would overflow csum_start
Date: Thu, 11 Apr 2013 22:57:18 +0200
Message-ID: <751a8e6e8f026ec11fbfa97347c0db352225f878.1365713735.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
	bhutchings@solarflare.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:40434 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161040Ab3DKU5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 16:57:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a TCP retransmission gets partially ACKed and collapsed multiple
times it is possible for the headroom to grow beyond 64K which will
overflow the 16bit skb->csum_start which is based on the start of
the headroom. It has been observed rarely in the wild with IPoIB due
to the 64K MTU.

Verify if the acking and collapsing resulted in a headroom exceeding
what csum_start can cover and reallocate the headroom if so.

A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
LLNL for helping out with the investigation and testing.

Reported-by: Jim Foraker <foraker1@llnl.gov>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2: Also do check for !NET_IP_ALIGN

 net/ipv4/tcp_output.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b44cf81..509912a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2388,8 +2388,12 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
-	/* make sure skb->data is aligned on arches that require it */
-	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
+	/* make sure skb->data is aligned on arches that require it
+	 * and check if ack-trimming & collapsing extended the headroom
+	 * beyond what csum_start can cover.
+	 */
+	if (unlikely((NET_IP_ALIGN && ((unsigned long)skb->data & 3)) ||
+		     skb_headroom(skb) >= 0xFFFF)) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
 						   GFP_ATOMIC);
 		return nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
-- 
1.7.11.7
