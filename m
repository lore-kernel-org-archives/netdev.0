From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 35/62: xtables: compact table hook functions (1/2)
Date: Tue, 16 Feb 2010 15:56:07 +0100 (MET)
Message-ID: <20100216145605.2796.48367.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52017 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932564Ab0BPO4I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:08 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 737535c5cf3524e4bfaa91e22edefd52eccabbce
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jun 13 06:46:36 2009 +0200

    netfilter: xtables: compact table hook functions (1/2)
    
    This patch combines all the per-hook functions in a given table into
    a single function. Together with the 2nd patch, further
    simplifications are possible up to the point of output code reduction.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 9733760..e9d823b 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -53,43 +53,37 @@ static const struct xt_table packet_filter = {
 };
 
 /* The work comes in here from netfilter.c */
-static unsigned int arpt_in_hook(unsigned int hook,
-				 struct sk_buff *skb,
-				 const struct net_device *in,
-				 const struct net_device *out,
-				 int (*okfn)(struct sk_buff *))
+static unsigned int
+arptable_filter_hook(unsigned int hook, struct sk_buff *skb,
+		     const struct net_device *in, const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
 {
-	return arpt_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv4.arptable_filter);
-}
+	if (hook == NF_ARP_OUT)
+		return arpt_do_table(skb, hook, in, out,
+				     dev_net(out)->ipv4.arptable_filter);
 
-static unsigned int arpt_out_hook(unsigned int hook,
-				  struct sk_buff *skb,
-				  const struct net_device *in,
-				  const struct net_device *out,
-				  int (*okfn)(struct sk_buff *))
-{
+	/* INPUT/FORWARD: */
 	return arpt_do_table(skb, hook, in, out,
-			     dev_net(out)->ipv4.arptable_filter);
+			     dev_net(in)->ipv4.arptable_filter);
 }
 
 static struct nf_hook_ops arpt_ops[] __read_mostly = {
 	{
-		.hook		= arpt_in_hook,
+		.hook		= arptable_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_ARP,
 		.hooknum	= NF_ARP_IN,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= arpt_out_hook,
+		.hook		= arptable_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_ARP,
 		.hooknum	= NF_ARP_OUT,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= arpt_in_hook,
+		.hook		= arptable_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_ARP,
 		.hooknum	= NF_ARP_FORWARD,
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index dee90eb..5369833 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -60,61 +60,43 @@ static const struct xt_table packet_filter = {
 	.af		= NFPROTO_IPV4,
 };
 
-/* The work comes in here from netfilter.c. */
 static unsigned int
-ipt_local_in_hook(unsigned int hook,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
+iptable_filter_hook(unsigned int hook, struct sk_buff *skb,
+		    const struct net_device *in, const struct net_device *out,
+		    int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_filter);
-}
+	if (hook == NF_INET_LOCAL_OUT) {
+		if (skb->len < sizeof(struct iphdr) ||
+		    ip_hdrlen(skb) < sizeof(struct iphdr))
+			/* root is playing with raw sockets. */
+			return NF_ACCEPT;
+
+		return ipt_do_table(skb, hook, in, out,
+				    dev_net(out)->ipv4.iptable_filter);
+	}
 
-static unsigned int
-ipt_hook(unsigned int hook,
-	 struct sk_buff *skb,
-	 const struct net_device *in,
-	 const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
-{
+	/* LOCAL_IN/FORWARD: */
 	return ipt_do_table(skb, hook, in, out,
 			    dev_net(in)->ipv4.iptable_filter);
 }
 
-static unsigned int
-ipt_local_out_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
-{
-	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(skb) < sizeof(struct iphdr))
-		return NF_ACCEPT;
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(out)->ipv4.iptable_filter);
-}
-
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
-		.hook		= ipt_local_in_hook,
+		.hook		= iptable_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= ipt_hook,
+		.hook		= iptable_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_FILTER,
 	},
 	{
-		.hook		= ipt_local_out_hook,
+		.hook		= iptable_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index e07bf24..4e699cd 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -71,51 +71,6 @@ static const struct xt_table packet_mangler = {
 	.af		= NFPROTO_IPV4,
 };
 
-/* The work comes in here from netfilter.c. */
-static unsigned int
-ipt_pre_routing_hook(unsigned int hook,
-		     struct sk_buff *skb,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     int (*okfn)(struct sk_buff *))
-{
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_mangle);
-}
-
-static unsigned int
-ipt_post_routing_hook(unsigned int hook,
-		      struct sk_buff *skb,
-		      const struct net_device *in,
-		      const struct net_device *out,
-		      int (*okfn)(struct sk_buff *))
-{
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(out)->ipv4.iptable_mangle);
-}
-
-static unsigned int
-ipt_local_in_hook(unsigned int hook,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
-{
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_mangle);
-}
-
-static unsigned int
-ipt_forward_hook(unsigned int hook,
-	 struct sk_buff *skb,
-	 const struct net_device *in,
-	 const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
-{
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_mangle);
-}
-
 static unsigned int
 ipt_local_hook(unsigned int hook,
 		   struct sk_buff *skb,
@@ -158,37 +113,53 @@ ipt_local_hook(unsigned int hook,
 	return ret;
 }
 
+/* The work comes in here from netfilter.c. */
+static unsigned int
+iptable_mangle_hook(unsigned int hook,
+		     struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	if (hook == NF_INET_LOCAL_OUT)
+		return ipt_local_hook(hook, skb, in, out, okfn);
+
+	/* PREROUTING/INPUT/FORWARD: */
+	return ipt_do_table(skb, hook, in, out,
+			    dev_net(in)->ipv4.iptable_mangle);
+}
+
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
-		.hook		= ipt_pre_routing_hook,
+		.hook		= iptable_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
-		.hook		= ipt_local_in_hook,
+		.hook		= iptable_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
-		.hook		= ipt_forward_hook,
+		.hook		= iptable_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
-		.hook		= ipt_local_hook,
+		.hook		= iptable_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP_PRI_MANGLE,
 	},
 	{
-		.hook		= ipt_post_routing_hook,
+		.hook		= iptable_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 40f2b9f..2c55575 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -45,23 +45,15 @@ static const struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ipt_hook(unsigned int hook,
-	 struct sk_buff *skb,
-	 const struct net_device *in,
-	 const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
+iptable_raw_hook(unsigned int hook, struct sk_buff *skb,
+		 const struct net_device *in, const struct net_device *out,
+		 int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_raw);
-}
+	if (hook == NF_INET_PRE_ROUTING)
+		return ipt_do_table(skb, hook, in, out,
+				    dev_net(in)->ipv4.iptable_raw);
 
-static unsigned int
-ipt_local_hook(unsigned int hook,
-	       struct sk_buff *skb,
-	       const struct net_device *in,
-	       const struct net_device *out,
-	       int (*okfn)(struct sk_buff *))
-{
+	/* OUTPUT: */
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
@@ -73,14 +65,14 @@ ipt_local_hook(unsigned int hook,
 /* 'raw' is the very first table. */
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
-		.hook = ipt_hook,
+		.hook = iptable_raw_hook,
 		.pf = NFPROTO_IPV4,
 		.hooknum = NF_INET_PRE_ROUTING,
 		.priority = NF_IP_PRI_RAW,
 		.owner = THIS_MODULE,
 	},
 	{
-		.hook = ipt_local_hook,
+		.hook = iptable_raw_hook,
 		.pf = NFPROTO_IPV4,
 		.hooknum = NF_INET_LOCAL_OUT,
 		.priority = NF_IP_PRI_RAW,
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 7ce2366..1c666ba 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -65,59 +65,43 @@ static const struct xt_table security_table = {
 };
 
 static unsigned int
-ipt_local_in_hook(unsigned int hook,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
+iptable_security_hook(unsigned int hook, struct sk_buff *skb,
+		      const struct net_device *in,
+		      const struct net_device *out,
+		      int (*okfn)(struct sk_buff *))
 {
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_security);
-}
+	if (hook == NF_INET_LOCAL_OUT) {
+		if (skb->len < sizeof(struct iphdr) ||
+		    ip_hdrlen(skb) < sizeof(struct iphdr))
+			/* Somebody is playing with raw sockets. */
+			return NF_ACCEPT;
 
-static unsigned int
-ipt_forward_hook(unsigned int hook,
-		 struct sk_buff *skb,
-		 const struct net_device *in,
-		 const struct net_device *out,
-		 int (*okfn)(struct sk_buff *))
-{
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_security);
-}
+		return ipt_do_table(skb, hook, in, out,
+				    dev_net(out)->ipv4.iptable_security);
+	}
 
-static unsigned int
-ipt_local_out_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
-{
-	/* Somebody is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(skb) < sizeof(struct iphdr))
-		return NF_ACCEPT;
+	/* INPUT/FORWARD: */
 	return ipt_do_table(skb, hook, in, out,
-			    dev_net(out)->ipv4.iptable_security);
+			    dev_net(in)->ipv4.iptable_security);
 }
 
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
 	{
-		.hook		= ipt_local_in_hook,
+		.hook		= iptable_security_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP_PRI_SECURITY,
 	},
 	{
-		.hook		= ipt_forward_hook,
+		.hook		= iptable_security_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP_PRI_SECURITY,
 	},
 	{
-		.hook		= ipt_local_out_hook,
+		.hook		= iptable_security_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 33ddfe5..38074e9 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -60,54 +60,36 @@ static const struct xt_table packet_filter = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6t_in_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+ip6table_filter_hook(unsigned int hook, struct sk_buff *skb,
+		     const struct net_device *in, const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_filter);
-}
-
-static unsigned int
-ip6t_local_out_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
-{
-#if 0
-	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			printk("ip6t_hook: happy cracking.\n");
-		return NF_ACCEPT;
-	}
-#endif
+	if (hook == NF_INET_LOCAL_OUT)
+		return ip6t_do_table(skb, hook, in, out,
+				     dev_net(out)->ipv6.ip6table_filter);
 
+	/* INPUT/FORWARD: */
 	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(out)->ipv6.ip6table_filter);
+			     dev_net(in)->ipv6.ip6table_filter);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-		.hook		= ip6t_in_hook,
+		.hook		= ip6table_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
-		.hook		= ip6t_in_hook,
+		.hook		= ip6table_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_FILTER,
 	},
 	{
-		.hook		= ip6t_local_out_hook,
+		.hook		= ip6table_filter_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index 9bc483f..405ac1f 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -64,33 +64,9 @@ static const struct xt_table packet_mangler = {
 	.af		= NFPROTO_IPV6,
 };
 
-/* The work comes in here from netfilter.c. */
-static unsigned int
-ip6t_in_hook(unsigned int hook,
-	 struct sk_buff *skb,
-	 const struct net_device *in,
-	 const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
-{
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_mangle);
-}
-
-static unsigned int
-ip6t_post_routing_hook(unsigned int hook,
-		struct sk_buff *skb,
-		const struct net_device *in,
-		const struct net_device *out,
-		int (*okfn)(struct sk_buff *))
-{
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(out)->ipv6.ip6table_mangle);
-}
-
 static unsigned int
 ip6t_local_out_hook(unsigned int hook,
 		   struct sk_buff *skb,
-		   const struct net_device *in,
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
@@ -119,7 +95,7 @@ ip6t_local_out_hook(unsigned int hook,
 	/* flowlabel and prio (includes version, which shouldn't change either */
 	flowlabel = *((u_int32_t *)ipv6_hdr(skb));
 
-	ret = ip6t_do_table(skb, hook, in, out,
+	ret = ip6t_do_table(skb, hook, NULL, out,
 			    dev_net(out)->ipv6.ip6table_mangle);
 
 	if (ret != NF_DROP && ret != NF_STOLEN &&
@@ -132,37 +108,51 @@ ip6t_local_out_hook(unsigned int hook,
 	return ret;
 }
 
+/* The work comes in here from netfilter.c. */
+static unsigned int
+ip6table_mangle_hook(unsigned int hook, struct sk_buff *skb,
+		     const struct net_device *in, const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
+{
+	if (hook == NF_INET_LOCAL_OUT)
+		return ip6t_local_out_hook(hook, skb, out, okfn);
+
+	/* INPUT/FORWARD */
+	return ip6t_do_table(skb, hook, in, out,
+			     dev_net(in)->ipv6.ip6table_mangle);
+}
+
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-		.hook		= ip6t_in_hook,
+		.hook		= ip6table_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_PRE_ROUTING,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_in_hook,
+		.hook		= ip6table_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_in_hook,
+		.hook		= ip6table_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_local_out_hook,
+		.hook		= ip6table_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
 		.priority	= NF_IP6_PRI_MANGLE,
 	},
 	{
-		.hook		= ip6t_post_routing_hook,
+		.hook		= ip6table_mangle_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_POST_ROUTING,
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 4c90b55..985e27c 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -44,37 +44,29 @@ static const struct xt_table packet_raw = {
 
 /* The work comes in here from netfilter.c. */
 static unsigned int
-ip6t_pre_routing_hook(unsigned int hook,
-	 struct sk_buff *skb,
-	 const struct net_device *in,
-	 const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
+ip6table_raw_hook(unsigned int hook, struct sk_buff *skb,
+		  const struct net_device *in, const struct net_device *out,
+		  int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_raw);
-}
+	if (hook == NF_INET_PRE_ROUTING)
+		return ip6t_do_table(skb, hook, in, out,
+				     dev_net(in)->ipv6.ip6table_raw);
 
-static unsigned int
-ip6t_local_out_hook(unsigned int hook,
-	 struct sk_buff *skb,
-	 const struct net_device *in,
-	 const struct net_device *out,
-	 int (*okfn)(struct sk_buff *))
-{
+	/* OUTPUT: */
 	return ip6t_do_table(skb, hook, in, out,
 			     dev_net(out)->ipv6.ip6table_raw);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-	  .hook = ip6t_pre_routing_hook,
+	  .hook = ip6table_raw_hook,
 	  .pf = NFPROTO_IPV6,
 	  .hooknum = NF_INET_PRE_ROUTING,
 	  .priority = NF_IP6_PRI_FIRST,
 	  .owner = THIS_MODULE,
 	},
 	{
-	  .hook = ip6t_local_out_hook,
+	  .hook = ip6table_raw_hook,
 	  .pf = NFPROTO_IPV6,
 	  .hooknum = NF_INET_LOCAL_OUT,
 	  .priority = NF_IP6_PRI_FIRST,
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index baa8d4e..8358589 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -64,56 +64,37 @@ static const struct xt_table security_table = {
 };
 
 static unsigned int
-ip6t_local_in_hook(unsigned int hook,
-		   struct sk_buff *skb,
-		   const struct net_device *in,
-		   const struct net_device *out,
-		   int (*okfn)(struct sk_buff *))
+ip6table_security_hook(unsigned int hook, struct sk_buff *skb,
+		       const struct net_device *in,
+		       const struct net_device *out,
+		       int (*okfn)(struct sk_buff *))
 {
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_security);
-}
+	if (hook == NF_INET_LOCAL_OUT)
+		return ip6t_do_table(skb, hook, in, out,
+				     dev_net(out)->ipv6.ip6table_security);
 
-static unsigned int
-ip6t_forward_hook(unsigned int hook,
-		  struct sk_buff *skb,
-		  const struct net_device *in,
-		  const struct net_device *out,
-		  int (*okfn)(struct sk_buff *))
-{
+	/* INPUT/FORWARD: */
 	return ip6t_do_table(skb, hook, in, out,
 			     dev_net(in)->ipv6.ip6table_security);
 }
 
-static unsigned int
-ip6t_local_out_hook(unsigned int hook,
-		    struct sk_buff *skb,
-		    const struct net_device *in,
-		    const struct net_device *out,
-		    int (*okfn)(struct sk_buff *))
-{
-	/* TBD: handle short packets via raw socket */
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(out)->ipv6.ip6table_security);
-}
-
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
-		.hook		= ip6t_local_in_hook,
+		.hook		= ip6table_security_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_IN,
 		.priority	= NF_IP6_PRI_SECURITY,
 	},
 	{
-		.hook		= ip6t_forward_hook,
+		.hook		= ip6table_security_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_FORWARD,
 		.priority	= NF_IP6_PRI_SECURITY,
 	},
 	{
-		.hook		= ip6t_local_out_hook,
+		.hook		= ip6table_security_hook,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV6,
 		.hooknum	= NF_INET_LOCAL_OUT,
