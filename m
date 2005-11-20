From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 07/13]: [NETFILTER]: Fix xfrm lookup in
	ip_route_me_harder/ip6_route_me_harder
Date: Sun, 20 Nov 2005 17:31:37 +0100
Message-ID: <20051120163137.16666.924.sendpatchset@localhost.localdomain>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: davem@davemloft.net
In-Reply-To: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

[NETFILTER]: Fix xfrm lookup in ip_route_me_harder/ip6_route_me_harder

ip_route_me_harder doesn't use the port numbers of the xfrm lookup and
uses ip_route_input for non-local addresses which doesn't do a xfrm
lookup, ip6_route_me_harder doesn't do a xfrm lookup at all.

Use xfrm_decode_session and do the lookup manually, make sure both
only do the lookup if the packet hasn't been transformed already.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit ffa4445cd4284d3d9b688c80f5a3b9f8b26d59e6
tree 3edbdce75cc680c51e38697d45479dbfd4404452
parent 08cf39d5d7d8b942431a6529daa3ab69ecfb34b5
author Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:05:08 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 19 Nov 2005 22:05:08 +0100

 include/linux/ipv6.h    |    2 ++
 include/net/ip.h        |    1 +
 include/net/xfrm.h      |    2 +-
 net/ipv4/netfilter.c    |    9 ++++++++-
 net/ipv4/xfrm4_output.c |    1 +
 net/ipv6/netfilter.c    |    8 +++++++-
 net/ipv6/xfrm6_output.c |    1 +
 net/xfrm/xfrm_policy.c  |    9 +++++----
 8 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index e0b9227..d7b3fac 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -190,6 +190,8 @@ struct inet6_skb_parm {
 	__u16			srcrt;
 	__u16			dst1;
 	__u16			lastopt;
+	__u16			flags;
+#define IP6SKB_XFRM_TRANSFORMED	1
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/include/net/ip.h b/include/net/ip.h
index 9f09882..377036b 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -45,6 +45,7 @@ struct inet_skb_parm
 #define IPSKB_TRANSLATED	2
 #define IPSKB_FORWARDED		4
 #define IPSKB_XFRM_TUNNEL_SIZE	8
+#define IPSKB_XFRM_TRANSFORMED	16
 };
 
 struct ipcm_cookie
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 5beae1c..19d6aa0 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -644,7 +644,7 @@ static inline int xfrm6_policy_check(str
 	return xfrm_policy_check(sk, dir, skb, AF_INET6);
 }
 
-
+extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
 extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 3c39296..db330b6 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -13,6 +13,7 @@
 #include <linux/ip.h>
 #include <net/route.h>
 #include <net/xfrm.h>
+#include <net/ip.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
@@ -34,7 +35,6 @@ int ip_route_me_harder(struct sk_buff **
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
 #endif
-		fl.proto = iph->protocol;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
@@ -61,6 +61,13 @@ int ip_route_me_harder(struct sk_buff **
 	if ((*pskb)->dst->error)
 		return -1;
 
+#ifdef CONFIG_XFRM
+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(*pskb, &fl, AF_INET) == 0)
+		if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0))
+			return -1;
+#endif
+
 	/* Change in oif may mean change in hh_len. */
 	hh_len = (*pskb)->dst->dev->hard_header_len;
 	if (skb_headroom(*pskb) < hh_len) {
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
index c135746..9e49eeb 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -133,6 +133,7 @@ int xfrm4_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index 06b275e..8bc6305 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -22,7 +22,6 @@ int ip6_route_me_harder(struct sk_buff *
 		{ .ip6_u =
 		  { .daddr = iph->daddr,
 		    .saddr = iph->saddr, } },
-		.proto = iph->nexthdr,
 	};
 
 	dst = ip6_route_output(skb->sk, &fl);
@@ -34,6 +33,13 @@ int ip6_route_me_harder(struct sk_buff *
 		return -EINVAL;
 	}
 
+#ifdef CONFIG_XFRM
+	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(skb, &fl, AF_INET6) == 0)
+		if (xfrm_lookup(&skb->dst, &fl, skb->sk, 0))
+			return -1;
+#endif
+
 	/* Drop old route. */
 	dst_release(skb->dst);
 
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index a566d25..929e4eb 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -132,6 +132,7 @@ int xfrm6_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 0db9e57..e441f35 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -906,8 +906,8 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, s
 	return start;
 }
 
-static int
-_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family)
+int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl,
+                        unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
@@ -918,6 +918,7 @@ _decode_session(struct sk_buff *skb, str
 	xfrm_policy_put_afinfo(afinfo);
 	return 0;
 }
+EXPORT_SYMBOL(xfrm_decode_session);
 
 static inline int secpath_has_tunnel(struct sec_path *sp, int k)
 {
@@ -935,7 +936,7 @@ int __xfrm_policy_check(struct sock *sk,
 	struct xfrm_policy *pol;
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	/* First, check used SA against their selectors. */
@@ -1007,7 +1008,7 @@ int __xfrm_route_forward(struct sk_buff 
 {
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
