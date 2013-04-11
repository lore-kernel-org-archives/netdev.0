From: Thomas Graf <tgraf@suug.ch>
Subject: [PATCH] tcp: Reallocate headroom if it would overflow csum_start
Date: Thu, 11 Apr 2013 13:19:48 +0200
Message-ID: <c35c262084e8907098dc2db5ea9690d2119b4916.1365678820.git.tgraf@suug.ch>
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 173-166-109-252-newengland.hfc.comcastbusiness.net ([173.166.109.252]:59099
	"EHLO bombadil.infradead.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750812Ab3DKLTy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 07:19:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If a TCP retransmission gets partially ACKed and collapsed multiple
times it is possible for the headroom to grow beyond 64K which will
overflow the 16bit skb->csum_start which is based on the start of
the headroom. It has been observed rarely in the wild with IPoIB due
to the 64K MTU.

Verify if the acking and collapsing resulted in a headroom exceeding
what csum_start can cover and reallocate the headroom if so.

LLNL has been running the patch for a while and has not seen the
problem occur since.

A big thank you to Jim Foraker <foraker1@llnl.gov> and the team at
LLNL for helping out with the investigation and testing.

Reported-by: Jim Foraker <foraker1@llnl.gov>
Signed-off-by: Thomas Graf <tgraf@suug.ch>
---
v2: reallocate headroom instead of preventing further collapsing

 net/ipv4/tcp_output.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index b44cf81..bf6ceb7 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2388,8 +2388,11 @@ int __tcp_retransmit_skb(struct sock *sk, struct sk_buff *skb)
 	 */
 	TCP_SKB_CB(skb)->when = tcp_time_stamp;
 
-	/* make sure skb->data is aligned on arches that require it */
-	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3))) {
+	/* make sure skb->data is aligned on arches that require it
+	 * and check if ack-trimming & collapsing extended the headroom
+	 * beyond what csum_start can cover. */
+	if (unlikely(NET_IP_ALIGN && ((unsigned long)skb->data & 3) ||
+		     skb_headroom(skb) >= 0xFFFF)) {
 		struct sk_buff *nskb = __pskb_copy(skb, MAX_TCP_HEADER,
 						   GFP_ATOMIC);
 		return nskb ? tcp_transmit_skb(sk, nskb, 0, GFP_ATOMIC) :
-- 
1.7.11.7
