From: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Subject: Re: [PATCH] net: Remove a noisy printk
Date: Wed, 17 Dec 2008 09:26:22 +0100 (CET)
Message-ID: <alpine.DEB.2.00.0812170922480.8687@blackhole.kfki.hu>
References: <1229033625-30825-1-git-send-email-ajax@redhat.com> <20081211.203243.124017657.davem@davemloft.net> <alpine.LNX.1.10.0812132310080.27276@fbirervta.pbzchgretzou.qr> <alpine.DEB.2.00.0812141745550.2447@blackhole.kfki.hu> <20081214200353.GA2994@redhat.com>
 <alpine.LNX.1.10.0812162058030.21696@fbirervta.pbzchgretzou.qr>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Dave Jones <davej@redhat.com>, David Miller <davem@davemloft.net>,
	ajax@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.1.10.0812162058030.21696@fbirervta.pbzchgretzou.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 16 Dec 2008, Jan Engelhardt wrote:

> Here is a patch that attempts silence both the fraction
> that wants to keep the printk and those to get rid of it.
> It trips up on the bloatmeters, though.

Based on your patch, here is another one: the printk is removed from 
everywhere except the filter tables where it's controlled by the module 
parameter. The checking against short packets was missing from 
ip6table_raw.c, so it's added as well.

diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 1ea677d..9527e2a 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -19,6 +19,10 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("iptables filter table");
 
+/* Default log short RAW packets */
+static unsigned int happy_cracking = 1;
+module_param(happy_cracking, bool, 0400);
+
 #define FILTER_VALID_HOOKS ((1 << NF_INET_LOCAL_IN) | \
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
@@ -94,7 +98,8 @@ ipt_local_out_hook(unsigned int hook,
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
+		if (happy_cracking && net_ratelimit())
+			/* FIXME: log process pid */
 			printk("iptable_filter: ignoring short SOCK_RAW "
 			       "packet.\n");
 		return NF_ACCEPT;
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index da59182..773d6ed 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -132,12 +132,8 @@ ipt_local_hook(unsigned int hook,
 
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			printk("iptable_mangle: ignoring short SOCK_RAW "
-			       "packet.\n");
+	    || ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	}
 
 	/* Save things which could affect route */
 	mark = skb->mark;
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index fddce77..71547fa 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -65,12 +65,8 @@ ipt_local_hook(unsigned int hook,
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			printk("iptable_raw: ignoring short SOCK_RAW "
-			       "packet.\n");
+	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	}
 	return ipt_do_table(skb, hook, in, out,
 			    nf_local_out_net(in, out)->ipv4.iptable_raw);
 }
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 7eb0b61..d20c0a0 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -185,11 +185,8 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 {
 	/* root is playing with raw sockets. */
 	if (skb->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			printk("ipt_hook: happy cracking.\n");
+	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	}
 	return nf_conntrack_in(PF_INET, hooknum, skb);
 }
 
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 55a2c29..a74b0e6 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -17,6 +17,10 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
 MODULE_DESCRIPTION("ip6tables filter table");
 
+/* Default log short RAW packets */
+static unsigned int happy_cracking = 1;
+module_param(happy_cracking, bool, 0400);
+
 #define FILTER_VALID_HOOKS ((1 << NF_INET_LOCAL_IN) | \
 			    (1 << NF_INET_FORWARD) | \
 			    (1 << NF_INET_LOCAL_OUT))
@@ -89,15 +93,14 @@ ip6t_local_out_hook(unsigned int hook,
 		   const struct net_device *out,
 		   int (*okfn)(struct sk_buff *))
 {
-#if 0
 	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			printk("ip6t_hook: happy cracking.\n");
+	if (skb->len < sizeof(struct ipv6hdr)) {
+		if (happy_cracking && net_ratelimit())
+			/* FIXME: log process pid */
+			printk("ip6table_filter: ignoring short SOCK_RAW "
+			       "packet.\n");
 		return NF_ACCEPT;
 	}
-#endif
 
 	return ip6t_do_table(skb, hook, in, out,
 			     nf_local_out_net(in, out)->ipv6.ip6table_filter);
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index f405cea..5c93909 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -89,15 +89,9 @@ ip6t_local_hook(unsigned int hook,
 	u_int8_t hop_limit;
 	u_int32_t flowlabel, mark;
 
-#if 0
 	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr)
-	    || ip_hdrlen(skb) < sizeof(struct iphdr)) {
-		if (net_ratelimit())
-			printk("ip6t_hook: happy cracking.\n");
+	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
-	}
-#endif
 
 	/* save source/dest address, mark, hoplimit, flowlabel, priority,  */
 	memcpy(&saddr, &ipv6_hdr(skb)->saddr, sizeof(saddr));
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 92b9107..4e24ff9 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -54,6 +54,19 @@ ip6t_hook(unsigned int hook,
 	return ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_raw);
 }
 
+static unsigned int
+ip6t_local_hook(unsigned int hook,
+		struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sk_buff *))
+{
+	/* root is playing with raw sockets. */
+	if (skb->len < sizeof(struct ipv6hdr))
+		return NF_ACCEPT;
+	return ip6t_do_table(skb, hook, in, out, init_net.ipv6.ip6table_raw);
+}
+
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	{
 	  .hook = ip6t_hook,
@@ -63,7 +76,7 @@ static struct nf_hook_ops ip6t_ops[] __read_mostly = {
 	  .owner = THIS_MODULE,
 	},
 	{
-	  .hook = ip6t_hook,
+	  .hook = ip6t_local_hook,
 	  .pf = PF_INET6,
 	  .hooknum = NF_INET_LOCAL_OUT,
 	  .priority = NF_IP6_PRI_FIRST,
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 85050c0..462360e 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -245,11 +245,8 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 					 int (*okfn)(struct sk_buff *))
 {
 	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct ipv6hdr)) {
-		if (net_ratelimit())
-			printk("ipv6_conntrack_local: packet too short\n");
+	if (skb->len < sizeof(struct ipv6hdr))
 		return NF_ACCEPT;
-	}
 	return ipv6_conntrack_in(hooknum, skb, in, out, okfn);
 }
 

Bests regards,
Jozsef
-
E-mail  : kadlec@blackhole.kfki.hu, kadlec@mail.kfki.hu
PGP key : http://www.kfki.hu/~kadlec/pgp_public_key.txt
Address : KFKI Research Institute for Particle and Nuclear Physics
          H-1525 Budapest 114, POB. 49, Hungary
