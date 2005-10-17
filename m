From: Patrick McHardy <kaber@trash.net>
Subject: [NF+IPsec 5/6]: Redo policy lookups after NAT when necessary
Date: Mon, 17 Oct 2005 02:22:38 +0200
Message-ID: <4352EECE.80301@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="05.diff"
Content-Transfer-Encoding: 7bit
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="05.diff"
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

[NETFILTER]: Redo policy lookups after NAT when necessary

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 373ca7e8b42cb5abbaf86e41a755363aa4029850
tree b33c60701979f2a795c8d7feef1262b141d7f3a2
parent 9b2748c756fd805c0fe5b37505735e02f06ebb28
author Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 01:45:45 +0200
committer Patrick McHardy <kaber@trash.net> Mon, 17 Oct 2005 01:45:45 +0200

 include/net/ip.h                       |    1 +
 include/net/xfrm.h                     |    2 +
 net/ipv4/ip_output.c                   |    6 ++++
 net/ipv4/netfilter.c                   |    9 +++++
 net/ipv4/netfilter/ip_nat_standalone.c |   54 +++++++++++++++++++++++---------
 net/ipv4/xfrm4_output.c                |    1 +
 net/xfrm/xfrm_policy.c                 |    8 ++---
 7 files changed, 61 insertions(+), 20 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
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
--- a/include/net/xfrm.h
+++ b/include/net/xfrm.h
@@ -644,7 +644,7 @@ static inline int xfrm6_policy_check(str
 	return xfrm_policy_check(sk, dir, skb, AF_INET6);
 }
 
-
+extern int xfrm_decode_session(struct sk_buff *skb, struct flowi *fl, unsigned short family);
 extern int __xfrm_route_forward(struct sk_buff *skb, unsigned short family);
 
 static inline int xfrm_route_forward(struct sk_buff *skb, unsigned short family)
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -167,6 +167,12 @@ static inline int ip_finish_output3(stru
 	struct net_device *dev = dst->dev;
 	int hh_len = LL_RESERVED_SPACE(dev);
 
+#if defined(CONFIG_NETFILTER) && defined(CONFIG_XFRM)
+	/* Policy lookup after SNAT yielded a new policy */
+	if (dst->xfrm != NULL)
+		return __ip_dst_output(skb);
+#endif
+
 	/* Be paranoid, rather than too clever. */
 	if (unlikely(skb_headroom(skb) < hh_len && dev->hard_header)) {
 		struct sk_buff *skb2;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -13,6 +13,7 @@
 #include <linux/ip.h>
 #include <net/route.h>
 #include <net/xfrm.h>
+#include <net/ip.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
@@ -61,6 +62,14 @@ int ip_route_me_harder(struct sk_buff **
 	if ((*pskb)->dst->error)
 		return -1;
 
+#ifdef CONFIG_XFRM
+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(*pskb, &fl, AF_INET) == 0) {
+		if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0))
+			return -1;
+	}
+#endif
+
 	/* Change in oif may mean change in hh_len. */
 	hh_len = (*pskb)->dst->dev->hard_header_len;
 	if (skb_headroom(*pskb) < hh_len) {
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -162,18 +162,19 @@ ip_nat_in(unsigned int hooknum,
           const struct net_device *out,
           int (*okfn)(struct sk_buff *))
 {
-	u_int32_t saddr, daddr;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
 
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
-
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN
-	    && ((*pskb)->nh.iph->saddr != saddr
-	        || (*pskb)->nh.iph->daddr != daddr)) {
-		dst_release((*pskb)->dst);
-		(*pskb)->dst = NULL;
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+		if (ct->tuplehash[dir].tuple.src.ip !=
+		    ct->tuplehash[!dir].tuple.dst.ip) {
+			dst_release((*pskb)->dst);
+			(*pskb)->dst = NULL;
+		}
 	}
 	return ret;
 }
@@ -185,6 +186,10 @@ ip_nat_out(unsigned int hooknum,
 	   const struct net_device *out,
 	   int (*okfn)(struct sk_buff *))
 {
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
+	unsigned int ret;
+
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
@@ -192,7 +197,20 @@ ip_nat_out(unsigned int hooknum,
 
 	WARN_ON((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET));
 
-	return ip_nat_fn(hooknum, pskb, in, out, okfn);
+	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+		if (ct->tuplehash[dir].tuple.src.ip !=
+		    ct->tuplehash[!dir].tuple.dst.ip
+#ifdef CONFIG_XFRM
+		    || ct->tuplehash[dir].tuple.src.u.all !=
+		       ct->tuplehash[!dir].tuple.dst.u.all
+#endif
+		    )
+			return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+	}
+	return ret;
 }
 
 static unsigned int
@@ -202,7 +220,8 @@ ip_nat_local_fn(unsigned int hooknum,
 		const struct net_device *out,
 		int (*okfn)(struct sk_buff *))
 {
-	u_int32_t saddr, daddr;
+	struct ip_conntrack *ct;
+	enum ip_conntrack_info ctinfo;
 	unsigned int ret;
 
 	/* root is playing with raw sockets. */
@@ -210,14 +229,19 @@ ip_nat_local_fn(unsigned int hooknum,
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
-
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN
-	    && ((*pskb)->nh.iph->saddr != saddr
-		|| (*pskb)->nh.iph->daddr != daddr))
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+		if (ct->tuplehash[dir].tuple.dst.ip !=
+		    ct->tuplehash[!dir].tuple.src.ip
+#ifdef CONFIG_XFRM
+		    || ct->tuplehash[dir].tuple.dst.u.all !=
+		       ct->tuplehash[dir].tuple.src.u.all
+#endif
+		    )
 		return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+	}
 	return ret;
 }
 
diff --git a/net/ipv4/xfrm4_output.c b/net/ipv4/xfrm4_output.c
--- a/net/ipv4/xfrm4_output.c
+++ b/net/ipv4/xfrm4_output.c
@@ -133,6 +133,7 @@ int xfrm4_output(struct sk_buff *skb)
 		err = -EHOSTUNREACH;
 		goto error_nolock;
 	}
+	IPCB(skb)->flags |= IPSKB_XFRM_TRANSFORMED;
 	nf_reset(skb);
 	err = NET_XMIT_BYPASS;
 
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
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
 
@@ -935,7 +935,7 @@ int __xfrm_policy_check(struct sock *sk,
 	struct xfrm_policy *pol;
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	/* First, check used SA against their selectors. */
@@ -1007,7 +1007,7 @@ int __xfrm_route_forward(struct sk_buff 
 {
 	struct flowi fl;
 
-	if (_decode_session(skb, &fl, family) < 0)
+	if (xfrm_decode_session(skb, &fl, family) < 0)
 		return 0;
 
 	return xfrm_lookup(&skb->dst, &fl, NULL, 0) == 0;
