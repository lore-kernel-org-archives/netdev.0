From: Tom Herbert <therbert@google.com>
Subject: [PATCH 7/7] l2tp: Remove UDP checksum verification
Date: Wed, 7 May 2014 16:52:48 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071644360.1293@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:41891 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaEGXws (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:52:48 -0400
Received: by mail-qa0-f74.google.com with SMTP id ih12so271533qab.3
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:52:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Validating the UDP checksum is now done in UDP before handing
packets to the encapsulation layer. Note that this also eliminates
the "feature" where L2TP can ignore a non-zero UDP checksum (doing
this was contrary to RFC 1122).

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/l2tp/l2tp_core.c | 57 +---------------------------------------------------
 1 file changed, 1 insertion(+), 56 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index a4e37d7..aa1a9d4 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -495,52 +495,6 @@ out:
 	spin_unlock_bh(&session->reorder_q.lock);
 }
 
-static inline int l2tp_verify_udp_checksum(struct sock *sk,
-					   struct sk_buff *skb)
-{
-	struct udphdr *uh = udp_hdr(skb);
-	u16 ulen = ntohs(uh->len);
-	__wsum psum;
-
-	if (sk->sk_no_check || skb_csum_unnecessary(skb))
-		return 0;
-
-#if IS_ENABLED(CONFIG_IPV6)
-	if (sk->sk_family == PF_INET6 && !l2tp_tunnel(sk)->v4mapped) {
-		if (!uh->check) {
-			LIMIT_NETDEBUG(KERN_INFO "L2TP: IPv6: checksum is 0\n");
-			return 1;
-		}
-		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
-		    !csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-				     &ipv6_hdr(skb)->daddr, ulen,
-				     IPPROTO_UDP, skb->csum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			return 0;
-		}
-		skb->csum = ~csum_unfold(csum_ipv6_magic(&ipv6_hdr(skb)->saddr,
-							 &ipv6_hdr(skb)->daddr,
-							 skb->len, IPPROTO_UDP,
-							 0));
-	} else
-#endif
-	{
-		struct inet_sock *inet;
-		if (!uh->check)
-			return 0;
-		inet = inet_sk(sk);
-		psum = csum_tcpudp_nofold(inet->inet_saddr, inet->inet_daddr,
-					  ulen, IPPROTO_UDP, 0);
-
-		if ((skb->ip_summed == CHECKSUM_COMPLETE) &&
-		    !csum_fold(csum_add(psum, skb->csum)))
-			return 0;
-		skb->csum = psum;
-	}
-
-	return __skb_checksum_complete(skb);
-}
-
 static int l2tp_seq_check_rx_window(struct l2tp_session *session, u32 nr)
 {
 	u32 nws;
@@ -895,8 +849,7 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 	u16 version;
 	int length;
 
-	if (tunnel->sock && l2tp_verify_udp_checksum(tunnel->sock, skb))
-		goto discard_bad_csum;
+	/* UDP has verifed checksum */
 
 	/* UDP always verifies the packet length. */
 	__skb_pull(skb, sizeof(struct udphdr));
@@ -979,14 +932,6 @@ static int l2tp_udp_recv_core(struct l2tp_tunnel *tunnel, struct sk_buff *skb,
 
 	return 0;
 
-discard_bad_csum:
-	LIMIT_NETDEBUG("%s: UDP: bad checksum\n", tunnel->name);
-	UDP_INC_STATS_USER(tunnel->l2tp_net, UDP_MIB_INERRORS, 0);
-	atomic_long_inc(&tunnel->stats.rx_errors);
-	kfree_skb(skb);
-
-	return 0;
-
 error:
 	/* Put UDP header back */
 	__skb_push(skb, sizeof(struct udphdr));
-- 
1.9.1.423.g4596e3a
