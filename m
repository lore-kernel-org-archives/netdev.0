From: Patrick McHardy <kaber@trash.net>
Subject: [RFC, PATCH 4/5]: netfilter+ipsec - policy lookup
Date: Thu, 18 Mar 2004 17:32:23 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4059CF17.8090907@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net> <20040308115858.75cdddca.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040408090804010508050308"
Cc: herbert@gondor.apana.org.au, netdev@oss.sgi.com,
        netfilter-devel@lists.netfilter.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040308115858.75cdddca.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040408090804010508050308
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

This patch adds policy lookups to ip_route_me_harder and makes NAT
reroute for any change that affects route/policy lookups.


--------------040408090804010508050308
Content-Type: text/x-patch;
 name="04-nat-xfrm_lookup.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="04-nat-xfrm_lookup.diff"

# This is a BitKeeper generated diff -Nru style patch.
#
# ChangeSet
#   2004/03/18 16:43:22+01:00 kaber@trash.net 
#   [NETFILTER]: Add policy lookups to ip_route_me_harder, make NAT reroute for any change in route/policy key
# 
# net/ipv4/netfilter/ip_nat_standalone.c
#   2004/03/18 16:43:16+01:00 kaber@trash.net +72 -8
#   [NETFILTER]: Add policy lookups to ip_route_me_harder, make NAT reroute for any change in route/policy key
# 
# net/ipv4/netfilter/ip_conntrack_standalone.c
#   2004/03/18 16:43:16+01:00 kaber@trash.net +1 -0
#   [NETFILTER]: Add policy lookups to ip_route_me_harder, make NAT reroute for any change in route/policy key
# 
# net/core/netfilter.c
#   2004/03/18 16:43:16+01:00 kaber@trash.net +15 -1
#   [NETFILTER]: Add policy lookups to ip_route_me_harder, make NAT reroute for any change in route/policy key
# 
diff -Nru a/net/core/netfilter.c b/net/core/netfilter.c
--- a/net/core/netfilter.c	Thu Mar 18 16:46:02 2004
+++ b/net/core/netfilter.c	Thu Mar 18 16:46:02 2004
@@ -27,6 +27,7 @@
 #include <net/sock.h>
 #include <net/route.h>
 #include <net/xfrm.h>
+#include <net/ip.h>
 #include <linux/ip.h>
 
 /* In this code, we can be waiting indefinitely for userspace to
@@ -635,7 +636,6 @@
 #ifdef CONFIG_IP_ROUTE_FWMARK
 		fl.nl_u.ip4_u.fwmark = (*pskb)->nfmark;
 #endif
-		fl.proto = iph->protocol;
 		if (ip_route_output_key(&rt, &fl) != 0)
 			return -1;
 
@@ -661,6 +661,20 @@
 	
 	if ((*pskb)->dst->error)
 		return -1;
+
+#ifdef CONFIG_XFRM
+	if (!(IPCB(*pskb)->flags & IPSKB_XFRM_TRANSFORMED)) {
+		struct xfrm_policy_afinfo *afinfo;
+
+		afinfo = xfrm_policy_get_afinfo(AF_INET);
+		if (afinfo != NULL) {
+			afinfo->decode_session(*pskb, &fl);
+			xfrm_policy_put_afinfo(afinfo);
+			if (xfrm_lookup(&(*pskb)->dst, &fl, (*pskb)->sk, 0) != 0)
+				return -1;
+		}
+	}
+#endif
 
 	/* Change in oif may mean change in hh_len. */
 	hh_len = (*pskb)->dst->dev->hard_header_len;
diff -Nru a/net/ipv4/netfilter/ip_conntrack_standalone.c b/net/ipv4/netfilter/ip_conntrack_standalone.c
--- a/net/ipv4/netfilter/ip_conntrack_standalone.c	Thu Mar 18 16:46:02 2004
+++ b/net/ipv4/netfilter/ip_conntrack_standalone.c	Thu Mar 18 16:46:02 2004
@@ -583,6 +583,7 @@
 EXPORT_SYMBOL(ip_conntrack_alter_reply);
 EXPORT_SYMBOL(ip_conntrack_destroyed);
 EXPORT_SYMBOL(ip_conntrack_get);
+EXPORT_SYMBOL(__ip_conntrack_confirm);
 EXPORT_SYMBOL(need_ip_conntrack);
 EXPORT_SYMBOL(ip_conntrack_helper_register);
 EXPORT_SYMBOL(ip_conntrack_helper_unregister);
diff -Nru a/net/ipv4/netfilter/ip_nat_standalone.c b/net/ipv4/netfilter/ip_nat_standalone.c
--- a/net/ipv4/netfilter/ip_nat_standalone.c	Thu Mar 18 16:46:02 2004
+++ b/net/ipv4/netfilter/ip_nat_standalone.c	Thu Mar 18 16:46:02 2004
@@ -166,6 +166,45 @@
 	return do_bindings(ct, ctinfo, info, hooknum, pskb);
 }
 
+struct nat_route_key
+{
+	u_int32_t addr;
+#ifdef CONFIG_XFRM
+	u_int16_t port;
+#endif
+};
+
+static inline void
+nat_route_key_get(struct sk_buff *skb, struct nat_route_key *key, int which)
+{
+	struct iphdr *iph = skb->nh.iph;
+
+	key->addr = which ? iph->daddr : iph->saddr;
+#ifdef CONFIG_XFRM
+	key->port = 0;
+	if (iph->protocol == IPPROTO_TCP || iph->protocol == IPPROTO_UDP) {
+		u_int16_t *ports = (u_int16_t *)(skb->nh.raw + iph->ihl*4);
+		key->port = ports[which];
+	}
+#endif
+}
+
+static inline int
+nat_route_key_compare(struct sk_buff *skb, struct nat_route_key *key, int which)
+{
+	struct iphdr *iph = skb->nh.iph;
+
+	if (key->addr != (which ? iph->daddr : iph->saddr))
+		return 1;
+#ifdef CONFIG_XFRM
+	if (iph->protocol == IPPROTO_TCP || iph->protocol == IPPROTO_UDP) {
+		u_int16_t *ports = (u_int16_t *)(skb->nh.raw + iph->ihl*4);
+		if (key->port != ports[which])
+			return 1;
+	}
+#endif
+}
+
 static unsigned int
 ip_nat_out(unsigned int hooknum,
 	   struct sk_buff **pskb,
@@ -173,6 +212,9 @@
 	   const struct net_device *out,
 	   int (*okfn)(struct sk_buff *))
 {
+	struct nat_route_key key;
+	unsigned int ret;
+
 	/* root is playing with raw sockets. */
 	if ((*pskb)->len < sizeof(struct iphdr)
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
@@ -195,7 +237,29 @@
 			return NF_STOLEN;
 	}
 
-	return ip_nat_fn(hooknum, pskb, in, out, okfn);
+	nat_route_key_get(*pskb, &key, 0);
+	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
+
+	if (ret != NF_DROP && ret != NF_STOLEN
+	    && nat_route_key_compare(*pskb, &key, 0)) {
+		if (ip_route_me_harder(pskb) != 0)
+			ret = NF_DROP;
+#ifdef CONFIG_XFRM
+		/*
+		 * POST_ROUTING hook is called with fixed outfn, we need
+		 * to manually confirm the packet and direct it to the
+		 * transformers if a policy matches.
+		 */
+		else if ((*pskb)->dst->xfrm != NULL) {
+			ret = ip_conntrack_confirm(*pskb);
+			if (ret != NF_DROP) {
+				dst_output(*pskb);
+				ret = NF_STOLEN;
+			}
+		}
+#endif
+	}
+	return ret;
 }
 
 #ifdef CONFIG_IP_NF_NAT_LOCAL
@@ -206,7 +270,7 @@
 		const struct net_device *out,
 		int (*okfn)(struct sk_buff *))
 {
-	u_int32_t saddr, daddr;
+	struct nat_route_key key;
 	unsigned int ret;
 
 	/* root is playing with raw sockets. */
@@ -214,14 +278,14 @@
 	    || (*pskb)->nh.iph->ihl * 4 < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	saddr = (*pskb)->nh.iph->saddr;
-	daddr = (*pskb)->nh.iph->daddr;
-
+	nat_route_key_get(*pskb, &key, 1);
 	ret = ip_nat_fn(hooknum, pskb, in, out, okfn);
+
 	if (ret != NF_DROP && ret != NF_STOLEN
-	    && ((*pskb)->nh.iph->saddr != saddr
-		|| (*pskb)->nh.iph->daddr != daddr))
-		return ip_route_me_harder(pskb) == 0 ? ret : NF_DROP;
+	    && nat_route_key_compare(*pskb, &key, 1)) {
+		if (ip_route_me_harder(pskb) != 0)
+			ret = NF_DROP;
+	}
 	return ret;
 }
 #endif


--------------040408090804010508050308--
