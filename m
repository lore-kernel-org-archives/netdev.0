From: adobriyan@gmail.com
Subject: [PATCH 01/38] netns nf: remove nf_*_net() wrappers
Date: Fri, 22 Aug 2008 01:56:57 +0400
Message-ID: <20080821215657.GA31136@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	containers@lists.linux-foundation.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that dev_net() exists, the usefullness of them is even less. Also they're
a big problem in resolving circular header dependencies necessary for
NOTRACK-in-netns patch. See below.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

 include/linux/netfilter.h              |   53 ---------------------------------
 net/ipv4/netfilter/iptable_filter.c    |    6 +--
 net/ipv4/netfilter/iptable_mangle.c    |   10 +++---
 net/ipv4/netfilter/iptable_raw.c       |    4 +-
 net/ipv4/netfilter/iptable_security.c  |    6 +--
 net/ipv6/netfilter/ip6table_filter.c   |    6 +--
 net/ipv6/netfilter/ip6table_security.c |    6 +--
 7 files changed, 19 insertions(+), 72 deletions(-)

--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -5,13 +5,11 @@
 #include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/net.h>
-#include <linux/netdevice.h>
 #include <linux/if.h>
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <linux/wait.h>
 #include <linux/list.h>
-#include <net/net_namespace.h>
 #endif
 #include <linux/types.h>
 #include <linux/compiler.h>
@@ -343,56 +341,5 @@ extern void (*nf_ct_destroy)(struct nf_conntrack *);
 static inline void nf_ct_attach(struct sk_buff *new, struct sk_buff *skb) {}
 #endif
 
-static inline struct net *nf_pre_routing_net(const struct net_device *in,
-					     const struct net_device *out)
-{
-#ifdef CONFIG_NET_NS
-	return in->nd_net;
-#else
-	return &init_net;
-#endif
-}
-
-static inline struct net *nf_local_in_net(const struct net_device *in,
-					  const struct net_device *out)
-{
-#ifdef CONFIG_NET_NS
-	return in->nd_net;
-#else
-	return &init_net;
-#endif
-}
-
-static inline struct net *nf_forward_net(const struct net_device *in,
-					 const struct net_device *out)
-{
-#ifdef CONFIG_NET_NS
-	BUG_ON(in->nd_net != out->nd_net);
-	return in->nd_net;
-#else
-	return &init_net;
-#endif
-}
-
-static inline struct net *nf_local_out_net(const struct net_device *in,
-					   const struct net_device *out)
-{
-#ifdef CONFIG_NET_NS
-	return out->nd_net;
-#else
-	return &init_net;
-#endif
-}
-
-static inline struct net *nf_post_routing_net(const struct net_device *in,
-					      const struct net_device *out)
-{
-#ifdef CONFIG_NET_NS
-	return out->nd_net;
-#else
-	return &init_net;
-#endif
-}
-
 #endif /*__KERNEL__*/
 #endif /*__LINUX_NETFILTER_H*/
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -70,7 +70,7 @@ ipt_local_in_hook(unsigned int hook,
 		  int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_local_in_net(in, out)->ipv4.iptable_filter);
+			    dev_net(in)->ipv4.iptable_filter);
 }
 
 static unsigned int
@@ -81,7 +81,7 @@ ipt_hook(unsigned int hook,
 	 int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_forward_net(in, out)->ipv4.iptable_filter);
+			    dev_net(in)->ipv4.iptable_filter);
 }
 
 static unsigned int
@@ -101,7 +101,7 @@ ipt_local_out_hook(unsigned int hook,
 	}
 
 	return ipt_do_table(skb, hook, in, out,
-			    nf_local_out_net(in, out)->ipv4.iptable_filter);
+			    dev_net(out)->ipv4.iptable_filter);
 }
 
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -81,7 +81,7 @@ ipt_pre_routing_hook(unsigned int hook,
 		     int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_pre_routing_net(in, out)->ipv4.iptable_mangle);
+			    dev_net(in)->ipv4.iptable_mangle);
 }
 
 static unsigned int
@@ -92,7 +92,7 @@ ipt_post_routing_hook(unsigned int hook,
 		      int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_post_routing_net(in, out)->ipv4.iptable_mangle);
+			    dev_net(out)->ipv4.iptable_mangle);
 }
 
 static unsigned int
@@ -103,7 +103,7 @@ ipt_local_in_hook(unsigned int hook,
 		  int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_local_in_net(in, out)->ipv4.iptable_mangle);
+			    dev_net(in)->ipv4.iptable_mangle);
 }
 
 static unsigned int
@@ -114,7 +114,7 @@ ipt_forward_hook(unsigned int hook,
 	 int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_forward_net(in, out)->ipv4.iptable_mangle);
+			    dev_net(in)->ipv4.iptable_mangle);
 }
 
 static unsigned int
@@ -147,7 +147,7 @@ ipt_local_hook(unsigned int hook,
 	tos = iph->tos;
 
 	ret = ipt_do_table(skb, hook, in, out,
-			   nf_local_out_net(in, out)->ipv4.iptable_mangle);
+			   dev_net(out)->ipv4.iptable_mangle);
 	/* Reroute for ANY change. */
 	if (ret != NF_DROP && ret != NF_STOLEN && ret != NF_QUEUE) {
 		iph = ip_hdr(skb);
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -53,7 +53,7 @@ ipt_hook(unsigned int hook,
 	 int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_pre_routing_net(in, out)->ipv4.iptable_raw);
+			    dev_net(in)->ipv4.iptable_raw);
 }
 
 static unsigned int
@@ -72,7 +72,7 @@ ipt_local_hook(unsigned int hook,
 		return NF_ACCEPT;
 	}
 	return ipt_do_table(skb, hook, in, out,
-			    nf_local_out_net(in, out)->ipv4.iptable_raw);
+			    dev_net(out)->ipv4.iptable_raw);
 }
 
 /* 'raw' is the very first table. */
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -73,7 +73,7 @@ ipt_local_in_hook(unsigned int hook,
 		  int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_local_in_net(in, out)->ipv4.iptable_security);
+			    dev_net(in)->ipv4.iptable_security);
 }
 
 static unsigned int
@@ -84,7 +84,7 @@ ipt_forward_hook(unsigned int hook,
 		 int (*okfn)(struct sk_buff *))
 {
 	return ipt_do_table(skb, hook, in, out,
-			    nf_forward_net(in, out)->ipv4.iptable_security);
+			    dev_net(in)->ipv4.iptable_security);
 }
 
 static unsigned int
@@ -103,7 +103,7 @@ ipt_local_out_hook(unsigned int hook,
 		return NF_ACCEPT;
 	}
 	return ipt_do_table(skb, hook, in, out,
-			    nf_local_out_net(in, out)->ipv4.iptable_security);
+			    dev_net(out)->ipv4.iptable_security);
 }
 
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -68,7 +68,7 @@ ip6t_local_in_hook(unsigned int hook,
 		   int (*okfn)(struct sk_buff *))
 {
 	return ip6t_do_table(skb, hook, in, out,
-			     nf_local_in_net(in, out)->ipv6.ip6table_filter);
+			     dev_net(in)->ipv6.ip6table_filter);
 }
 
 static unsigned int
@@ -79,7 +79,7 @@ ip6t_forward_hook(unsigned int hook,
 		  int (*okfn)(struct sk_buff *))
 {
 	return ip6t_do_table(skb, hook, in, out,
-			     nf_forward_net(in, out)->ipv6.ip6table_filter);
+			     dev_net(in)->ipv6.ip6table_filter);
 }
 
 static unsigned int
@@ -100,7 +100,7 @@ ip6t_local_out_hook(unsigned int hook,
 #endif
 
 	return ip6t_do_table(skb, hook, in, out,
-			     nf_local_out_net(in, out)->ipv6.ip6table_filter);
+			     dev_net(out)->ipv6.ip6table_filter);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -72,7 +72,7 @@ ip6t_local_in_hook(unsigned int hook,
 		   int (*okfn)(struct sk_buff *))
 {
 	return ip6t_do_table(skb, hook, in, out,
-			     nf_local_in_net(in, out)->ipv6.ip6table_security);
+			     dev_net(in)->ipv6.ip6table_security);
 }
 
 static unsigned int
@@ -83,7 +83,7 @@ ip6t_forward_hook(unsigned int hook,
 		  int (*okfn)(struct sk_buff *))
 {
 	return ip6t_do_table(skb, hook, in, out,
-			     nf_forward_net(in, out)->ipv6.ip6table_security);
+			     dev_net(in)->ipv6.ip6table_security);
 }
 
 static unsigned int
@@ -95,7 +95,7 @@ ip6t_local_out_hook(unsigned int hook,
 {
 	/* TBD: handle short packets via raw socket */
 	return ip6t_do_table(skb, hook, in, out,
-			     nf_local_out_net(in, out)->ipv6.ip6table_security);
+			     dev_net(out)->ipv6.ip6table_security);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {

