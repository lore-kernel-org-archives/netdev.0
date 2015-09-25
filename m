From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 13/17] ipv6: constify ip6_xmit() sock argument
Date: Fri, 25 Sep 2015 07:39:20 -0700
Message-ID: <1443191964-923-14-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:34932 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:28 -0400
Received: by pacfv12 with SMTP id fv12so109584562pac.2
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:28 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to document that socket lock might not be held at this point.

skb_set_owner_w() and ipv6_local_error() are using proper atomic ops
or spinlocks, so we promote the socket to non const when calling them.

netfilter hooks should never assume socket lock is held,
we also promote the socket to non const.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/ipv6.h    |  2 +-
 net/ipv6/datagram.c   |  2 +-
 net/ipv6/ip6_output.c | 26 +++++++++++++++++++-------
 3 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 9877b68ad207..3dde042bcd3f 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -812,7 +812,7 @@ int ip6_rcv_finish(struct net *net, struct sock *sk, struct sk_buff *skb);
 /*
  *	upper-layer output functions
  */
-int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
+int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	     struct ipv6_txoptions *opt, int tclass);
 
 int ip6_find_1stfragopt(struct sk_buff *skb, u8 **nexthdr);
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 9aadd57808a5..d70b0238f468 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -263,7 +263,7 @@ void ipv6_icmp_error(struct sock *sk, struct sk_buff *skb, int err,
 
 void ipv6_local_error(struct sock *sk, int err, struct flowi6 *fl6, u32 info)
 {
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
 	struct sock_exterr_skb *serr;
 	struct ipv6hdr *iph;
 	struct sk_buff *skb;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 6b0d86f3fbfc..60c565309d0a 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -150,14 +150,16 @@ int ip6_output(struct sock *sk, struct sk_buff *skb)
 }
 
 /*
- *	xmit an sk_buff (used by TCP, SCTP and DCCP)
+ * xmit an sk_buff (used by TCP, SCTP and DCCP)
+ * Note : socket lock is not held for SYNACK packets, but might be modified
+ * by calls to skb_set_owner_w() and ipv6_local_error(),
+ * which are using proper atomic operations or spinlocks.
  */
-
-int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
+int ip6_xmit(const struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	     struct ipv6_txoptions *opt, int tclass)
 {
 	struct net *net = sock_net(sk);
-	struct ipv6_pinfo *np = inet6_sk(sk);
+	const struct ipv6_pinfo *np = inet6_sk(sk);
 	struct in6_addr *first_hop = &fl6->daddr;
 	struct dst_entry *dst = skb_dst(skb);
 	struct ipv6hdr *hdr;
@@ -186,7 +188,10 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 			}
 			consume_skb(skb);
 			skb = skb2;
-			skb_set_owner_w(skb, sk);
+			/* skb_set_owner_w() changes sk->sk_wmem_alloc atomically,
+			 * it is safe to call in our context (socket lock not held)
+			 */
+			skb_set_owner_w(skb, (struct sock *)sk);
 		}
 		if (opt->opt_flen)
 			ipv6_push_frag_opts(skb, opt, &proto);
@@ -224,13 +229,20 @@ int ip6_xmit(struct sock *sk, struct sk_buff *skb, struct flowi6 *fl6,
 	if ((skb->len <= mtu) || skb->ignore_df || skb_is_gso(skb)) {
 		IP6_UPD_PO_STATS(net, ip6_dst_idev(skb_dst(skb)),
 			      IPSTATS_MIB_OUT, skb->len);
+		/* hooks should never assume socket lock is held.
+		 * we promote our socket to non const
+		 */
 		return NF_HOOK(NFPROTO_IPV6, NF_INET_LOCAL_OUT,
-			       net, sk, skb, NULL, dst->dev,
+			       net, (struct sock *)sk, skb, NULL, dst->dev,
 			       dst_output_okfn);
 	}
 
 	skb->dev = dst->dev;
-	ipv6_local_error(sk, EMSGSIZE, fl6, mtu);
+	/* ipv6_local_error() does not require socket lock,
+	 * we promote our socket to non const
+	 */
+	ipv6_local_error((struct sock *)sk, EMSGSIZE, fl6, mtu);
+
 	IP6_INC_STATS(net, ip6_dst_idev(skb_dst(skb)), IPSTATS_MIB_FRAGFAILS);
 	kfree_skb(skb);
 	return -EMSGSIZE;
-- 
2.6.0.rc2.230.g3dd15c0
