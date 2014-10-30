From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: skb_fclone_busy() needs to detect orphaned skb
Date: Thu, 30 Oct 2014 10:32:34 -0700
Message-ID: <1414690354.9028.9.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:57423 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757327AbaJ3Rcp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 13:32:45 -0400
Received: by mail-pd0-f176.google.com with SMTP id ft15so5542840pdb.7
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 10:32:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Some drivers are unable to perform TX completions in a bound time.
They instead call skb_orphan()

Problem is skb_fclone_busy() has to detect this case, otherwise
we block TCP retransmits and can freeze unlucky tcp sessions on
mostly idle hosts.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: 1f3279ae0c13 ("tcp: avoid retransmits of TCP packets hanging in host queues")
---
 This is a stable candidate.
 This problem is known to hurt users of linux-3.16 kernels used by guests kernels.
 David, I can provide backports if you want.
 Thanks !

 include/linux/skbuff.h |    8 ++++++--
 net/ipv4/tcp_output.c  |    2 +-
 net/xfrm/xfrm_policy.c |    2 +-
 3 files changed, 8 insertions(+), 4 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 5884f95ff0e9..6c8b6f604e76 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -799,15 +799,19 @@ struct sk_buff_fclones {
  *	@skb: buffer
  *
  * Returns true is skb is a fast clone, and its clone is not freed.
+ * Some drivers call skb_orphan() in their ndo_start_xmit(),
+ * so we also check that this didnt happen.
  */
-static inline bool skb_fclone_busy(const struct sk_buff *skb)
+static inline bool skb_fclone_busy(const struct sock *sk,
+				   const struct sk_buff *skb)
 {
 	const struct sk_buff_fclones *fclones;
 
 	fclones = container_of(skb, struct sk_buff_fclones, skb1);
 
 	return skb->fclone == SKB_FCLONE_ORIG &&
-	       fclones->skb2.fclone == SKB_FCLONE_CLONE;
+	       fclones->skb2.fclone == SKB_FCLONE_CLONE &&
+	       fclones->skb2.sk == sk;
 }
 
 static inline struct sk_buff *alloc_skb_fclone(unsigned int size,
diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 3af21296d967..a3d453b94747 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2126,7 +2126,7 @@ bool tcp_schedule_loss_probe(struct sock *sk)
 static bool skb_still_in_host_queue(const struct sock *sk,
 				    const struct sk_buff *skb)
 {
-	if (unlikely(skb_fclone_busy(skb))) {
+	if (unlikely(skb_fclone_busy(sk, skb))) {
 		NET_INC_STATS_BH(sock_net(sk),
 				 LINUX_MIB_TCPSPURIOUS_RTX_HOSTQUEUES);
 		return true;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4c4e457e7888..88bf289abdc9 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1962,7 +1962,7 @@ static int xdst_queue_output(struct sock *sk, struct sk_buff *skb)
 	struct xfrm_policy *pol = xdst->pols[0];
 	struct xfrm_policy_queue *pq = &pol->polq;
 
-	if (unlikely(skb_fclone_busy(skb))) {
+	if (unlikely(skb_fclone_busy(sk, skb))) {
 		kfree_skb(skb);
 		return 0;
 	}
