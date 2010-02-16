From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 36/62: xtables: compact table hook functions (2/2)
Date: Tue, 16 Feb 2010 15:56:08 +0100 (MET)
Message-ID: <20100216145606.2796.4223.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 2b21e051472fdb4680076278b2ccf63ebc1cc3bc
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Sat Jun 13 06:57:10 2009 +0200

    netfilter: xtables: compact table hook functions (2/2)
    
    The calls to ip6t_do_table only show minimal differences, so it seems
    like a good cleanup to merge them to a single one too.
    Space saving obtained by both patches: 6807725->6807373
    ("Total" column from `size -A`.)
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>

diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index e9d823b..deeda9b 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -58,13 +58,9 @@ arptable_filter_hook(unsigned int hook, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
 		     int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_ARP_OUT)
-		return arpt_do_table(skb, hook, in, out,
-				     dev_net(out)->ipv4.arptable_filter);
+	const struct net *net = dev_net((in != NULL) ? in : out);
 
-	/* INPUT/FORWARD: */
-	return arpt_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv4.arptable_filter);
+	return arpt_do_table(skb, hook, in, out, net->ipv4.arptable_filter);
 }
 
 static struct nf_hook_ops arpt_ops[] __read_mostly = {
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 5369833..1bfeaae 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -65,19 +65,16 @@ iptable_filter_hook(unsigned int hook, struct sk_buff *skb,
 		    const struct net_device *in, const struct net_device *out,
 		    int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_INET_LOCAL_OUT) {
-		if (skb->len < sizeof(struct iphdr) ||
-		    ip_hdrlen(skb) < sizeof(struct iphdr))
-			/* root is playing with raw sockets. */
-			return NF_ACCEPT;
-
-		return ipt_do_table(skb, hook, in, out,
-				    dev_net(out)->ipv4.iptable_filter);
-	}
+	const struct net *net;
+
+	if (hook == NF_INET_LOCAL_OUT &&
+	    (skb->len < sizeof(struct iphdr) ||
+	     ip_hdrlen(skb) < sizeof(struct iphdr)))
+		/* root is playing with raw sockets. */
+		return NF_ACCEPT;
 
-	/* LOCAL_IN/FORWARD: */
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_filter);
+	net = dev_net((in != NULL) ? in : out);
+	return ipt_do_table(skb, hook, in, out, net->ipv4.iptable_filter);
 }
 
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 2c55575..d16e437 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -49,17 +49,16 @@ iptable_raw_hook(unsigned int hook, struct sk_buff *skb,
 		 const struct net_device *in, const struct net_device *out,
 		 int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_INET_PRE_ROUTING)
-		return ipt_do_table(skb, hook, in, out,
-				    dev_net(in)->ipv4.iptable_raw);
-
-	/* OUTPUT: */
-	/* root is playing with raw sockets. */
-	if (skb->len < sizeof(struct iphdr) ||
-	    ip_hdrlen(skb) < sizeof(struct iphdr))
+	const struct net *net;
+
+	if (hook == NF_INET_LOCAL_OUT &&
+	    (skb->len < sizeof(struct iphdr) ||
+	     ip_hdrlen(skb) < sizeof(struct iphdr)))
+		/* root is playing with raw sockets. */
 		return NF_ACCEPT;
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(out)->ipv4.iptable_raw);
+
+	net = dev_net((in != NULL) ? in : out);
+	return ipt_do_table(skb, hook, in, out, net->ipv4.iptable_raw);
 }
 
 /* 'raw' is the very first table. */
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index 1c666ba..324505a 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -70,19 +70,16 @@ iptable_security_hook(unsigned int hook, struct sk_buff *skb,
 		      const struct net_device *out,
 		      int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_INET_LOCAL_OUT) {
-		if (skb->len < sizeof(struct iphdr) ||
-		    ip_hdrlen(skb) < sizeof(struct iphdr))
-			/* Somebody is playing with raw sockets. */
-			return NF_ACCEPT;
-
-		return ipt_do_table(skb, hook, in, out,
-				    dev_net(out)->ipv4.iptable_security);
-	}
-
-	/* INPUT/FORWARD: */
-	return ipt_do_table(skb, hook, in, out,
-			    dev_net(in)->ipv4.iptable_security);
+	const struct net *net;
+
+	if (hook == NF_INET_LOCAL_OUT &&
+	    (skb->len < sizeof(struct iphdr) ||
+	     ip_hdrlen(skb) < sizeof(struct iphdr)))
+		/* Somebody is playing with raw sockets. */
+		return NF_ACCEPT;
+
+	net = dev_net((in != NULL) ? in : out);
+	return ipt_do_table(skb, hook, in, out, net->ipv4.iptable_security);
 }
 
 static struct nf_hook_ops ipt_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 38074e9..866f34a 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -64,13 +64,9 @@ ip6table_filter_hook(unsigned int hook, struct sk_buff *skb,
 		     const struct net_device *in, const struct net_device *out,
 		     int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_INET_LOCAL_OUT)
-		return ip6t_do_table(skb, hook, in, out,
-				     dev_net(out)->ipv6.ip6table_filter);
+	const struct net *net = dev_net((in != NULL) ? in : out);
 
-	/* INPUT/FORWARD: */
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_filter);
+	return ip6t_do_table(skb, hook, in, out, net->ipv6.ip6table_filter);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 985e27c..5451a36 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -48,13 +48,9 @@ ip6table_raw_hook(unsigned int hook, struct sk_buff *skb,
 		  const struct net_device *in, const struct net_device *out,
 		  int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_INET_PRE_ROUTING)
-		return ip6t_do_table(skb, hook, in, out,
-				     dev_net(in)->ipv6.ip6table_raw);
+	const struct net *net = dev_net((in != NULL) ? in : out);
 
-	/* OUTPUT: */
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(out)->ipv6.ip6table_raw);
+	return ip6t_do_table(skb, hook, in, out, net->ipv6.ip6table_raw);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 8358589..841ea77 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -69,13 +69,9 @@ ip6table_security_hook(unsigned int hook, struct sk_buff *skb,
 		       const struct net_device *out,
 		       int (*okfn)(struct sk_buff *))
 {
-	if (hook == NF_INET_LOCAL_OUT)
-		return ip6t_do_table(skb, hook, in, out,
-				     dev_net(out)->ipv6.ip6table_security);
+	const struct net *net = dev_net((in != NULL) ? in : out);
 
-	/* INPUT/FORWARD: */
-	return ip6t_do_table(skb, hook, in, out,
-			     dev_net(in)->ipv6.ip6table_security);
+	return ip6t_do_table(skb, hook, in, out, net->ipv6.ip6table_security);
 }
 
 static struct nf_hook_ops ip6t_ops[] __read_mostly = {
