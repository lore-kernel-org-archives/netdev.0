From: Patrick McHardy <kaber@trash.net>
Subject: [NETFILTER 05/10]: Fix xfrm lookup in
	ip_route_me_harder/ip6_route_me_harder
Date: Sat,  7 Jan 2006 02:09:38 +0100 (MET)
Message-ID: <20060107010902.8712.67836.sendpatchset@localhost.localdomain>
References: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David S. Miller <davem@davemloft.net>
In-Reply-To: <20060107010855.8712.68786.sendpatchset@localhost.localdomain>
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

Makeing sure the lookup only happens once needs a new field in the
IP6CB, which exceeds the size of skb->cb. The size of skb->cb is
increased to 48b. Apparently the IPv6 mobile extensions need some
more room anyway.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d923d6ec05f49c2b746a7e8c6d0a71f3bcc35b4e
tree 7005afd82b323b88784953b776f9d95671d4b9f3
parent 0c72987fae9d4f21d80910ccca2beea4f77e1dc5
author Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 00:57:41 +0100
committer Patrick McHardy <kaber@trash.net> Sat, 07 Jan 2006 00:57:41 +0100

 include/linux/ipv6.h    |    3 +++
 include/linux/skbuff.h  |    2 +-
 include/net/ip.h        |    3 ++-
 include/net/xfrm.h      |    2 +-
 net/ipv4/ip_gre.c       |    2 +-
 net/ipv4/ipip.c         |    2 +-
 net/ipv4/netfilter.c    |   12 ++++++++++--
 net/ipv4/xfrm4_output.c |    1 +
 net/ipv6/netfilter.c    |    9 ++++++++-
 net/ipv6/xfrm6_output.c |    1 +
 net/xfrm/xfrm_policy.c  |    9 +++++----
 11 files changed, 34 insertions(+), 12 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 5cfc715..9c8f4c9 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -192,6 +192,9 @@ struct inet6_skb_parm {
 	__u16			dst1;
 	__u16			lastopt;
 	__u32			nhoff;
+	__u16			flags;
+
+#define IP6SKB_XFRM_TRANSFORMED	1
 };
 
 #define IP6CB(skb)	((struct inet6_skb_parm*)((skb)->cb))
diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 483cfc4..e5fd66c 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -251,7 +251,7 @@ struct sk_buff {
 	 * want to keep them across layers you have to do a skb_clone()
 	 * first. This is owned by whoever has the skb queued ATM.
 	 */
-	char			cb[40];
+	char			cb[48];
 
 	unsigned int		len,
 				data_len,
diff --git a/include/net/ip.h b/include/net/ip.h
index 52f4d9c..a494d04 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -39,7 +39,8 @@ struct inet_skb_parm
 
 #define IPSKB_FORWARDED		1
 #define IPSKB_XFRM_TUNNEL_SIZE	2
-#define IPSKB_FRAG_COMPLETE	4
+#define IPSKB_XFRM_TRANSFORMED	4
+#define IPSKB_FRAG_COMPLETE	8
 };
 
 struct ipcm_cookie
diff --git a/include/net/xfrm.h b/include/net/xfrm.h
index 297d09d..d6111a2 100644
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -668,7 +668,7 @@ static inline int xfrm6_policy_check(str
 	return xfrm_policy_check(sk, dir, skb, AF_INET6);
 }
 
-
+extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
 extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 65c3a91..de16e94 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -832,7 +832,7 @@ static int ipgre_tunnel_xmit(struct sk_b
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, gre_hlen);
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~IPSKB_XFRM_TUNNEL_SIZE;
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE|IPSKB_XFRM_TRANSFORMED);
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 078b59b..bbd85f5 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -621,7 +621,7 @@ static int ipip_tunnel_xmit(struct sk_bu
 	skb->h.raw = skb->nh.raw;
 	skb->nh.raw = skb_push(skb, sizeof(struct iphdr));
 	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~IPSKB_XFRM_TUNNEL_SIZE;
+	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE|IPSKB_XFRM_TRANSFORMED);
 	dst_release(skb->dst);
 	skb->dst = &rt->u.dst;
 
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index ae0779d..4c637a1 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -7,11 +7,13 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 
+#include <linux/ip.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
 #include <linux/icmp.h>
 #include <net/route.h>
-#include <linux/ip.h>
+#include <net/xfrm.h>
+#include <net/ip.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
@@ -33,7 +35,6 @@ int ip_route_me_harder(struct sk_buff **
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
 #endif
-		fl.proto = iph->protocol;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
@@ -60,6 +61,13 @@ int ip_route_me_harder(struct sk_buff **
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
index 51fabb8..160c488 100644
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -140,6 +140,7 @@ static int xfrm4_output_one(struct sk_bu
 		x = dst->xfrm;
 	} while (x && !x->props.mode);
 
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	err = 0;
 
 out_exit:
diff --git a/net/ipv6/netfilter.c b/net/ipv6/netfilter.c
index f8626eb..b636783 100644
--- a/net/ipv6/netfilter.c
+++ b/net/ipv6/netfilter.c
@@ -10,6 +10,7 @@
 #include <net/dst.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
+#include <net/xfrm.h>
 
 int ip6_route_me_harder(struct sk_buff *skb)
 {
@@ -21,11 +22,17 @@ int ip6_route_me_harder(struct sk_buff *
 		{ .ip6_u =
 		  { .daddr = iph->daddr,
 		    .saddr = iph->saddr, } },
-		.proto = iph->nexthdr,
 	};
 
 	dst = ip6_route_output(skb->sk, &fl);
 
+#ifdef CONFIG_XFRM
+	if (!(IP6CB(skb)->flags & IP6SKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(skb, &fl, AF_INET6) == 0)
+		if (xfrm_lookup(&skb->dst, &fl, skb->sk, 0))
+			return -1;
+#endif
+
 	if (dst->error) {
 		IP6_INC_STATS(IPSTATS_MIB_OUTNOROUTES);
 		LIMIT_NETDEBUG(KERN_DEBUG "ip6_route_me_harder: No more route.\n");
diff --git a/net/ipv6/xfrm6_output.c b/net/ipv6/xfrm6_output.c
index fc0ea38..8024217 100644
--- a/net/ipv6/xfrm6_output.c
+++ b/net/ipv6/xfrm6_output.c
@@ -139,6 +139,7 @@ static int xfrm6_output_one(struct sk_bu
 		x = dst->xfrm;
 	} while (x && !x->props.mode);
 
+	IP6CB(skb)->flags |= IP6SKB_XFRM_TRANSFORMED;
 	err = 0;
 
 out_exit:
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 64a4473..f2edc92 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -951,8 +951,8 @@ xfrm_policy_ok(struct xfrm_tmpl *tmpl, s
 	return start;
 }
 
-static int
-_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family)
+int
+xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family)
 {
 	struct xfrm_policy_afinfo *afinfo = xfrm_policy_get_afinfo(family);
 
@@ -963,6 +963,7 @@ _decode_session(struct sk_buff *skb, str
 	xfrm_policy_put_afinfo(afinfo);
 	return 0;
 }
+EXPORT_SYMBOL(xfrm_decode_session);
 
 static inline int secpath_has_tunnel(struct sec_path *sp, int k)
 {
@@ -982,7 +983,7 @@ int __xfrm_policy_check(struct sock *sk,
 	u8 fl_dir = policy_to_flow_dir(dir);
 	u32 sk_sid;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	sk_sid = security_sk_sid(sk, &fl, fl_dir);
@@ -1055,7 +1056,7 @@ int __xfrm_route_forward(struct sk_buff 
 {
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
