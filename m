From: Patrick McHardy <kaber@trash.net>
Subject: [PATCH 09/10]: [NETFILTER]: Redo policy lookups after NAT when
	neccessary
Date: Fri, 11 Nov 2005 04:19:36 +0100
Message-ID: <43740DC8.5010706@trash.net>
Mime-Version: 1.0
Content-Type: text/x-patch;
 name="09.diff"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Content-Disposition: inline;
 filename="09.diff"
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

[NETFILTER]: Redo policy lookups after NAT when neccessary

When NAT changes the key used for the xfrm lookup on the output
path the lookup needs to be redone.

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit d449eeda76508f14f27d76a84350e4069c968497
tree fa245e3599e04432ee1ef1e046eeef9c800553e3
parent 351bc1c8a9c5c5e4aa48c153f0050f0a8b979201
author Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 03:21:13 +0100
committer Patrick McHardy <kaber@trash.net> Fri, 11 Nov 2005 03:21:13 +0100

 include/net/dst.h                      |    1 +
 include/net/ip.h                       |    1 +
 net/ipv4/ip_output.c                   |    6 ++++++
 net/ipv4/netfilter.c                   |    6 ++++--
 net/ipv4/netfilter/ip_nat_standalone.c |   27 +++++++++++++++++++++++++--
 net/ipv4/xfrm4_output.c                |    1 +
 6 files changed, 38 insertions(+), 4 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index 7eadd0c..4630e17 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -237,6 +237,7 @@ static inline int dst_output(struct sk_b
 }
 
 #if defined(CONFIG_XFRM) && defined(CONFIG_NETFILTER)
+extern int __ip_dst_output(struct sk_buff *skb);
 extern int ip_dst_output(struct sk_buff *skb);
 extern int ip6_dst_output(struct sk_buff *skb);
 #else
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
diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index eb6906d..579877f 100644
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
index 0f6616f..8fda96a 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -13,6 +13,7 @@
 #include <linux/ip.h>
 #include <net/route.h>
 #include <net/xfrm.h>
+#include <net/ip.h>
 
 /* route_me_harder function, used by iptable_nat, iptable_mangle + ip_queue */
 int ip_route_me_harder(struct sk_buff **pskb)
@@ -61,7 +62,8 @@ int ip_route_me_harder(struct sk_buff **
 		return -1;
 
 #ifdef CONFIG_XFRM
-	if (xfrm_decode_session(*pskb, &fl, AF_INET) == 0)
+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED) &&
+	    xfrm_decode_session(*pskb, &fl, AF_INET) == 0)
 		if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0))
 			return -1;
 #endif
@@ -85,7 +87,7 @@ int ip_route_me_harder(struct sk_buff **
 EXPORT_SYMBOL(ip_route_me_harder);
 
 #ifdef CONFIG_XFRM
-static inline int __ip_dst_output(struct sk_buff *skb)
+inline int __ip_dst_output(struct sk_buff *skb)
 {
 	int err;
 
diff --git a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
index ff24bac..e383b16 100644
--- a/net/ipv4/netfilter/ip_nat_standalone.c
+++ b/net/ipv4/netfilter/ip_nat_standalone.c
@@ -187,6 +187,10 @@ ip_nat_out(unsigned int hooknum,
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
@@ -194,7 +198,21 @@ ip_nat_out(unsigned int hooknum,
 
 	WARN_ON((*pskb)->nh.iph->frag_off & htons(IP_MF|IP_OFFSET));
 
-	return ip_nat_fn(hooknum, pskb, in, out, okfn);
+	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
+	if (ret != NF_DROP && ret != NF_STOLEN
+	    && (ct = ip_conntrack_get(*pskb, &ctinfo)) != NULL) {
+		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+
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
@@ -219,7 +237,12 @@ ip_nat_local_fn(unsigned int hooknum,
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if (ct->tuplehash[dir].tuple.dst.ip !=
-		    ct->tuplehash[!dir].tuple.src.ip)
+		    ct->tuplehash[!dir].tuple.src.ip
+#ifdef CONFIG_XFRM
+		    || ct->tuplehash[dir].tuple.dst.u.all !=
+		       ct->tuplehash[dir].tuple.src.u.all
+#endif
+		    )
 			return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
 	}
 	return ret;
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
 
