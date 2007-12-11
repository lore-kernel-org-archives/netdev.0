From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 1/2] [IPSEC]: Added xfrm_decode_session_reverse and xfrmX_policy_check_reverse
Date: Wed, 12 Dec 2007 00:55:01 +0800
Message-ID: <E1J28Np-0004IK-00@gondolin.me.apana.org.au>
References: <20071211165317.GA16420@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:2044 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752144AbXLKQzG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 11:55:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[IPSEC]: Added xfrm_decode_session_reverse and xfrmX_policy_check_reverse

RFC 4301 requires us to relookup ICMP traffic that does not match any
policies using the reverse of its payload.  This patch adds the functions
xfrm_decode_session_reverse and xfrmX_policy_check_reverse so we can get
the reverse flow to perform such a lookup.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/xfrm.h    |    1 
 include/net/xfrm.h      |   63 ++++++++++++++++++++++++++++++++++++++++++++----
 net/ipv4/xfrm4_policy.c |   10 +++----
 net/ipv6/xfrm6_policy.c |   10 +++----
 net/xfrm/xfrm_policy.c  |   17 ++++++++----
 5 files changed, 80 insertions(+), 21 deletions(-)

diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
index df2e62a..f3819ee 100644
--- a/include/linux/xfrm.h
+++ b/include/linux/xfrm.h
@@ -121,6 +121,7 @@ enum
 	XFRM_POLICY_IN	= 0,
 	XFRM_POLICY_OUT	= 1,
 	XFRM_POLICY_FWD	= 2,
+	XFRM_POLICY_MASK = 3,
 	XFRM_POLICY_MAX	= 3
 };
 
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 92ee8e5..5fae184 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -240,7 +240,8 @@ struct xfrm_policy_afinfo {
 	int			(*get_saddr)(xfrm_address_t *saddr, xfrm_address_t *daddr);
 	struct dst_entry	*(*find_bundle)(struct flowi *fl, struct xfrm_policy *policy);
 	void			(*decode_session)(struct sk_buff *skb,
-						  struct flowi *fl);
+						  struct flowi *fl,
+						  int reverse);
 	int			(*get_tos)(struct flowi *fl);
 	int			(*fill_dst)(struct xfrm_dst *xdst,
 					    struct net_device *dev);
@@ -846,14 +847,23 @@ xfrm_state_addr_cmp(struct xfrm_tmpl *tmpl, struct xfrm_state *x, unsigned short
 
 extern int __xfrm_policy_check(struct sock *, int dir, struct sk_buff *skb, unsigned short family);
 
-static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
+static inline int __xfrm_policy_check2(struct sock *sk, int dir,
+				       struct sk_buff *skb,
+				       unsigned int family, int reverse)
 {
+	int ndir = dir | (reverse ? XFRM_POLICY_MASK + 1 : 0);
+
 	if (sk && sk->sk_policy[XFRM_POLICY_IN])
-		return __xfrm_policy_check(sk, dir, skb, family);
+		return __xfrm_policy_check(sk, ndir, skb, family);
 
 	return	(!xfrm_policy_count[dir] && !skb->sp) ||
 		(skb->dst->flags & DST_NOPOLICY) ||
-		__xfrm_policy_check(sk, dir, skb, family);
+		__xfrm_policy_check(sk, ndir, skb, family);
+}
+
+static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb, unsigned short family)
+{
+	return __xfrm_policy_check2(sk, dir, skb, family, 0);
 }
 
 static inline int xfrm4_policy_check(struct sock *sk, int dir, struct sk_buff *skb)
@@ -866,7 +876,34 @@ static inline int xfrm6_policy_check(struct sock *sk, int dir, struct sk_buff *s
 	return xfrm_policy_check(sk, dir, skb, AF_INET6);
 }
 
-extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
+static inline int xfrm4_policy_check_reverse(struct sock *sk, int dir,
+					     struct sk_buff *skb)
+{
+	return __xfrm_policy_check2(sk, dir, skb, AF_INET, 1);
+}
+
+static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
+					     struct sk_buff *skb)
+{
+	return __xfrm_policy_check2(sk, dir, skb, AF_INET6, 1);
+}
+
+extern int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
+				 unsigned int family, int reverse);
+
+static inline int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
+				      unsigned int family)
+{
+	return __xfrm_decode_session(skb, fl, family, 0);
+}
+
+static inline int xfrm_decode_session_reverse(struct sk_buff *skb,
+					      struct flowi *fl,
+					      unsigned int family)
+{
+	return __xfrm_decode_session(skb, fl, family, 1);
+}
+
 extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
@@ -927,6 +964,22 @@ static inline int xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *sk
 {
 	return 1;
 }
+static inline int xfrm_decode_session_reverse(struct sk_buff *skb,
+					      struct flowi *fl,
+					      unsigned int family)
+{
+	return -ENOSYS;
+}
+static inline int xfrm4_policy_check_reverse(struct sock *sk, int dir,
+					     struct sk_buff *skb)
+{
+	return 1;
+}
+static inline int xfrm6_policy_check_reverse(struct sock *sk, int dir,
+					     struct sk_buff *skb)
+{
+	return 1;
+}
 #endif
 
 static __inline__
diff --git a/net/ipv4/xfrm4_policy.c b/net/ipv4/xfrm4_policy.c
index 10b72d1..5ccae3a 100644
--- a/net/ipv4/xfrm4_policy.c
+++ b/net/ipv4/xfrm4_policy.c
@@ -115,7 +115,7 @@ static int xfrm4_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 }
 
 static void
-_decode_session4(struct sk_buff *skb, struct flowi *fl)
+_decode_session4(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
 	struct iphdr *iph = ip_hdr(skb);
 	u8 *xprth = skb_network_header(skb) + iph->ihl * 4;
@@ -131,8 +131,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl)
 			if (pskb_may_pull(skb, xprth + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)xprth;
 
-				fl->fl_ip_sport = ports[0];
-				fl->fl_ip_dport = ports[1];
+				fl->fl_ip_sport = ports[!!reverse];
+				fl->fl_ip_dport = ports[!reverse];
 			}
 			break;
 
@@ -174,8 +174,8 @@ _decode_session4(struct sk_buff *skb, struct flowi *fl)
 		}
 	}
 	fl->proto = iph->protocol;
-	fl->fl4_dst = iph->daddr;
-	fl->fl4_src = iph->saddr;
+	fl->fl4_dst = reverse ? iph->saddr : iph->daddr;
+	fl->fl4_src = reverse ? iph->daddr : iph->saddr;
 	fl->fl4_tos = iph->tos;
 }
 
diff --git a/net/ipv6/xfrm6_policy.c b/net/ipv6/xfrm6_policy.c
index 9c14e02..6714831 100644
--- a/net/ipv6/xfrm6_policy.c
+++ b/net/ipv6/xfrm6_policy.c
@@ -124,7 +124,7 @@ static int xfrm6_fill_dst(struct xfrm_dst *xdst, struct net_device *dev)
 }
 
 static inline void
-_decode_session6(struct sk_buff *skb, struct flowi *fl)
+_decode_session6(struct sk_buff *skb, struct flowi *fl, int reverse)
 {
 	u16 offset = skb_network_header_len(skb);
 	struct ipv6hdr *hdr = ipv6_hdr(skb);
@@ -133,8 +133,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl)
 	u8 nexthdr = nh[IP6CB(skb)->nhoff];
 
 	memset(fl, 0, sizeof(struct flowi));
-	ipv6_addr_copy(&fl->fl6_dst, &hdr->daddr);
-	ipv6_addr_copy(&fl->fl6_src, &hdr->saddr);
+	ipv6_addr_copy(&fl->fl6_dst, reverse ? &hdr->saddr : &hdr->daddr);
+	ipv6_addr_copy(&fl->fl6_src, reverse ? &hdr->daddr : &hdr->saddr);
 
 	while (pskb_may_pull(skb, nh + offset + 1 - skb->data)) {
 		nh = skb_network_header(skb);
@@ -157,8 +157,8 @@ _decode_session6(struct sk_buff *skb, struct flowi *fl)
 			if (pskb_may_pull(skb, nh + offset + 4 - skb->data)) {
 				__be16 *ports = (__be16 *)exthdr;
 
-				fl->fl_ip_sport = ports[0];
-				fl->fl_ip_dport = ports[1];
+				fl->fl_ip_sport = ports[!!reverse];
+				fl->fl_ip_dport = ports[!reverse];
 			}
 			fl->proto = nexthdr;
 			return;
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 265c679..55fd8b7 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -1732,8 +1732,8 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, struct sec_path *sp, int start,
 	return start;
 }
 
-int
-xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family)
+int __xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
+			  unsigned int family, int reverse)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 	int err;
@@ -1741,12 +1741,12 @@ xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family
 	if (unlikely(afinfo == NULL))
 		return -EAFNOSUPPORT;
 
-	afinfo->decode_session(skb, fl);
+	afinfo->decode_session(skb, fl, reverse);
 	err = security_xfrm_decode_session(skb, &fl->secid);
 	xfrm_policy_put_afinfo(afinfo);
 	return err;
 }
-EXPORT_SYMBOL(xfrm_decode_session);
+EXPORT_SYMBOL(__xfrm_decode_session);
 
 static inline int secpath_has_nontransport(struct sec_path *sp, int k, int *idxp)
 {
@@ -1768,11 +1768,16 @@ int __xfrm_policy_check(struct sock *sk, int dir, struct sk_buff *skb,
 	int npols = 0;
 	int xfrm_nr;
 	int pi;
+	int reverse;
 	struct flowi fl;
-	u8 fl_dir = policy_to_flow_dir(dir);
+	u8 fl_dir;
 	int xerr_idx = -1;
 
-	if (xfrm_decode_session(skb, &fl, family) < 0)
+	reverse = dir & ~XFRM_POLICY_MASK;
+	dir &= XFRM_POLICY_MASK;
+	fl_dir = policy_to_flow_dir(dir);
+
+	if (__xfrm_decode_session(skb, &fl, family, reverse) < 0)
 		return 0;
 	nf_nat_decode_session(skb, &fl, family);
 
