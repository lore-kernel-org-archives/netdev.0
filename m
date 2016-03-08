From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/10] netfilter: xtables: prepare for on-demand hook register
Date: Tue,  8 Mar 2016 11:00:46 +0100
Message-ID: <1457431250-3086-7-git-send-email-pablo@netfilter.org>
References: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:40454 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932466AbcCHKBN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Mar 2016 05:01:13 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 8F9E18429
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 7675028D233
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:09 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 89A20CA103
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2016 11:01:06 +0100 (CET)
In-Reply-To: <1457431250-3086-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

This change prepares for upcoming on-demand xtables hook registration.

We change the protoypes of the register/unregister functions.
A followup patch will then add nf_hook_register/unregister calls
to the iptables one.

Once a hook is registered packets will be picked up, so all assignments
of the form

net->ipv4.iptable_$table = new_table

have to be moved to ip(6)t_register_table, else we can see NULL
net->ipv4.iptable_$table later.

This patch doesn't change functionality; without this the actual change
simply gets too big.

Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter_arp/arp_tables.h  |  9 +++++----
 include/linux/netfilter_ipv4/ip_tables.h  |  9 +++++----
 include/linux/netfilter_ipv6/ip6_tables.h |  9 +++++----
 net/ipv4/netfilter/arp_tables.c           | 25 ++++++++++++++-----------
 net/ipv4/netfilter/arptable_filter.c      | 11 ++++++-----
 net/ipv4/netfilter/ip_tables.c            | 21 ++++++++++-----------
 net/ipv4/netfilter/iptable_filter.c       |  9 +++++----
 net/ipv4/netfilter/iptable_mangle.c       |  9 +++++----
 net/ipv4/netfilter/iptable_nat.c          |  8 +++++---
 net/ipv4/netfilter/iptable_raw.c          |  9 +++++----
 net/ipv4/netfilter/iptable_security.c     |  9 +++++----
 net/ipv6/netfilter/ip6_tables.c           | 23 ++++++++++++-----------
 net/ipv6/netfilter/ip6table_filter.c      |  9 +++++----
 net/ipv6/netfilter/ip6table_mangle.c      |  9 +++++----
 net/ipv6/netfilter/ip6table_nat.c         |  8 +++++---
 net/ipv6/netfilter/ip6table_raw.c         |  9 +++++----
 net/ipv6/netfilter/ip6table_security.c    |  9 +++++----
 17 files changed, 107 insertions(+), 88 deletions(-)

diff --git a/include/linux/netfilter_arp/arp_tables.h b/include/linux/netfilter_arp/arp_tables.h
index 6f074db..029b95e 100644
--- a/include/linux/netfilter_arp/arp_tables.h
+++ b/include/linux/netfilter_arp/arp_tables.h
@@ -48,10 +48,11 @@ struct arpt_error {
 }
 
 extern void *arpt_alloc_initial_table(const struct xt_table *);
-extern struct xt_table *arpt_register_table(struct net *net,
-					    const struct xt_table *table,
-					    const struct arpt_replace *repl);
-extern void arpt_unregister_table(struct xt_table *table);
+int arpt_register_table(struct net *net, const struct xt_table *table,
+			const struct arpt_replace *repl,
+			const struct nf_hook_ops *ops, struct xt_table **res);
+void arpt_unregister_table(struct net *net, struct xt_table *table,
+			   const struct nf_hook_ops *ops);
 extern unsigned int arpt_do_table(struct sk_buff *skb,
 				  const struct nf_hook_state *state,
 				  struct xt_table *table);
diff --git a/include/linux/netfilter_ipv4/ip_tables.h b/include/linux/netfilter_ipv4/ip_tables.h
index aa598f9..7bfc589 100644
--- a/include/linux/netfilter_ipv4/ip_tables.h
+++ b/include/linux/netfilter_ipv4/ip_tables.h
@@ -24,10 +24,11 @@
 
 extern void ipt_init(void) __init;
 
-extern struct xt_table *ipt_register_table(struct net *net,
-					   const struct xt_table *table,
-					   const struct ipt_replace *repl);
-extern void ipt_unregister_table(struct net *net, struct xt_table *table);
+int ipt_register_table(struct net *net, const struct xt_table *table,
+		       const struct ipt_replace *repl,
+		       const struct nf_hook_ops *ops, struct xt_table **res);
+void ipt_unregister_table(struct net *net, struct xt_table *table,
+			  const struct nf_hook_ops *ops);
 
 /* Standard entry. */
 struct ipt_standard {
diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 0f76e5c..b21c392 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -25,10 +25,11 @@
 extern void ip6t_init(void) __init;
 
 extern void *ip6t_alloc_initial_table(const struct xt_table *);
-extern struct xt_table *ip6t_register_table(struct net *net,
-					    const struct xt_table *table,
-					    const struct ip6t_replace *repl);
-extern void ip6t_unregister_table(struct net *net, struct xt_table *table);
+int ip6t_register_table(struct net *net, const struct xt_table *table,
+			const struct ip6t_replace *repl,
+			const struct nf_hook_ops *ops, struct xt_table **res);
+void ip6t_unregister_table(struct net *net, struct xt_table *table,
+			   const struct nf_hook_ops *ops);
 extern unsigned int ip6t_do_table(struct sk_buff *skb,
 				  const struct nf_hook_state *state,
 				  struct xt_table *table);
diff --git a/net/ipv4/netfilter/arp_tables.c b/net/ipv4/netfilter/arp_tables.c
index b488cac..00eed08 100644
--- a/net/ipv4/netfilter/arp_tables.c
+++ b/net/ipv4/netfilter/arp_tables.c
@@ -1780,9 +1780,11 @@ static int do_arpt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len
 	return ret;
 }
 
-struct xt_table *arpt_register_table(struct net *net,
-				     const struct xt_table *table,
-				     const struct arpt_replace *repl)
+int arpt_register_table(struct net *net,
+			const struct xt_table *table,
+			const struct arpt_replace *repl,
+			const struct nf_hook_ops *ops,
+			struct xt_table **res)
 {
 	int ret;
 	struct xt_table_info *newinfo;
@@ -1791,10 +1793,8 @@ struct xt_table *arpt_register_table(struct net *net,
 	struct xt_table *new_table;
 
 	newinfo = xt_alloc_table_info(repl->size);
-	if (!newinfo) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!newinfo)
+		return -ENOMEM;
 
 	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
@@ -1809,15 +1809,18 @@ struct xt_table *arpt_register_table(struct net *net,
 		ret = PTR_ERR(new_table);
 		goto out_free;
 	}
-	return new_table;
+
+	WRITE_ONCE(*res, new_table);
+
+	return ret;
 
 out_free:
 	xt_free_table_info(newinfo);
-out:
-	return ERR_PTR(ret);
+	return ret;
 }
 
-void arpt_unregister_table(struct xt_table *table)
+void arpt_unregister_table(struct net *net, struct xt_table *table,
+			   const struct nf_hook_ops *ops)
 {
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
diff --git a/net/ipv4/netfilter/arptable_filter.c b/net/ipv4/netfilter/arptable_filter.c
index 1897ee1..4c02416 100644
--- a/net/ipv4/netfilter/arptable_filter.c
+++ b/net/ipv4/netfilter/arptable_filter.c
@@ -38,19 +38,20 @@ static struct nf_hook_ops *arpfilter_ops __read_mostly;
 static int __net_init arptable_filter_net_init(struct net *net)
 {
 	struct arpt_replace *repl;
-	
+	int err;
+
 	repl = arpt_alloc_initial_table(&packet_filter);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv4.arptable_filter =
-		arpt_register_table(net, &packet_filter, repl);
+	err = arpt_register_table(net, &packet_filter, repl, arpfilter_ops,
+				  &net->ipv4.arptable_filter);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.arptable_filter);
+	return err;
 }
 
 static void __net_exit arptable_filter_net_exit(struct net *net)
 {
-	arpt_unregister_table(net->ipv4.arptable_filter);
+	arpt_unregister_table(net, net->ipv4.arptable_filter, arpfilter_ops);
 }
 
 static struct pernet_operations arptable_filter_net_ops = {
diff --git a/net/ipv4/netfilter/ip_tables.c b/net/ipv4/netfilter/ip_tables.c
index b99affa..1eb4fe5 100644
--- a/net/ipv4/netfilter/ip_tables.c
+++ b/net/ipv4/netfilter/ip_tables.c
@@ -2062,9 +2062,9 @@ do_ipt_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	return ret;
 }
 
-struct xt_table *ipt_register_table(struct net *net,
-				    const struct xt_table *table,
-				    const struct ipt_replace *repl)
+int ipt_register_table(struct net *net, const struct xt_table *table,
+		       const struct ipt_replace *repl,
+		       const struct nf_hook_ops *ops, struct xt_table **res)
 {
 	int ret;
 	struct xt_table_info *newinfo;
@@ -2073,10 +2073,8 @@ struct xt_table *ipt_register_table(struct net *net,
 	struct xt_table *new_table;
 
 	newinfo = xt_alloc_table_info(repl->size);
-	if (!newinfo) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!newinfo)
+		return -ENOMEM;
 
 	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
@@ -2091,15 +2089,16 @@ struct xt_table *ipt_register_table(struct net *net,
 		goto out_free;
 	}
 
-	return new_table;
+	WRITE_ONCE(*res, new_table);
+	return ret;
 
 out_free:
 	xt_free_table_info(newinfo);
-out:
-	return ERR_PTR(ret);
+	return ret;
 }
 
-void ipt_unregister_table(struct net *net, struct xt_table *table)
+void ipt_unregister_table(struct net *net, struct xt_table *table,
+			  const struct nf_hook_ops *ops)
 {
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
diff --git a/net/ipv4/netfilter/iptable_filter.c b/net/ipv4/netfilter/iptable_filter.c
index 397ef2d..3fbe4ac 100644
--- a/net/ipv4/netfilter/iptable_filter.c
+++ b/net/ipv4/netfilter/iptable_filter.c
@@ -54,6 +54,7 @@ module_param(forward, bool, 0000);
 static int __net_init iptable_filter_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
+	int err;
 
 	repl = ipt_alloc_initial_table(&packet_filter);
 	if (repl == NULL)
@@ -62,15 +63,15 @@ static int __net_init iptable_filter_net_init(struct net *net)
 	((struct ipt_standard *)repl->entries)[1].target.verdict =
 		forward ? -NF_ACCEPT - 1 : -NF_DROP - 1;
 
-	net->ipv4.iptable_filter =
-		ipt_register_table(net, &packet_filter, repl);
+	err = ipt_register_table(net, &packet_filter, repl, filter_ops,
+				 &net->ipv4.iptable_filter);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.iptable_filter);
+	return err;
 }
 
 static void __net_exit iptable_filter_net_exit(struct net *net)
 {
-	ipt_unregister_table(net, net->ipv4.iptable_filter);
+	ipt_unregister_table(net, net->ipv4.iptable_filter, filter_ops);
 }
 
 static struct pernet_operations iptable_filter_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_mangle.c b/net/ipv4/netfilter/iptable_mangle.c
index ba5d392..668e7916 100644
--- a/net/ipv4/netfilter/iptable_mangle.c
+++ b/net/ipv4/netfilter/iptable_mangle.c
@@ -96,19 +96,20 @@ static struct nf_hook_ops *mangle_ops __read_mostly;
 static int __net_init iptable_mangle_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
+	int ret;
 
 	repl = ipt_alloc_initial_table(&packet_mangler);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv4.iptable_mangle =
-		ipt_register_table(net, &packet_mangler, repl);
+	ret = ipt_register_table(net, &packet_mangler, repl, mangle_ops,
+				 &net->ipv4.iptable_mangle);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.iptable_mangle);
+	return ret;
 }
 
 static void __net_exit iptable_mangle_net_exit(struct net *net)
 {
-	ipt_unregister_table(net, net->ipv4.iptable_mangle);
+	ipt_unregister_table(net, net->ipv4.iptable_mangle, mangle_ops);
 }
 
 static struct pernet_operations iptable_mangle_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_nat.c b/net/ipv4/netfilter/iptable_nat.c
index ae2cd27..e984f1d 100644
--- a/net/ipv4/netfilter/iptable_nat.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -98,18 +98,20 @@ static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 static int __net_init iptable_nat_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
+	int ret;
 
 	repl = ipt_alloc_initial_table(&nf_nat_ipv4_table);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv4.nat_table = ipt_register_table(net, &nf_nat_ipv4_table, repl);
+	ret = ipt_register_table(net, &nf_nat_ipv4_table, repl,
+				 nf_nat_ipv4_ops, &net->ipv4.nat_table);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.nat_table);
+	return ret;
 }
 
 static void __net_exit iptable_nat_net_exit(struct net *net)
 {
-	ipt_unregister_table(net, net->ipv4.nat_table);
+	ipt_unregister_table(net, net->ipv4.nat_table, nf_nat_ipv4_ops);
 }
 
 static struct pernet_operations iptable_nat_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_raw.c b/net/ipv4/netfilter/iptable_raw.c
index 1ba0281..9d78780 100644
--- a/net/ipv4/netfilter/iptable_raw.c
+++ b/net/ipv4/netfilter/iptable_raw.c
@@ -37,19 +37,20 @@ static struct nf_hook_ops *rawtable_ops __read_mostly;
 static int __net_init iptable_raw_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
+	int ret;
 
 	repl = ipt_alloc_initial_table(&packet_raw);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv4.iptable_raw =
-		ipt_register_table(net, &packet_raw, repl);
+	ret = ipt_register_table(net, &packet_raw, repl, rawtable_ops,
+				 &net->ipv4.iptable_raw);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.iptable_raw);
+	return ret;
 }
 
 static void __net_exit iptable_raw_net_exit(struct net *net)
 {
-	ipt_unregister_table(net, net->ipv4.iptable_raw);
+	ipt_unregister_table(net, net->ipv4.iptable_raw, rawtable_ops);
 }
 
 static struct pernet_operations iptable_raw_net_ops = {
diff --git a/net/ipv4/netfilter/iptable_security.c b/net/ipv4/netfilter/iptable_security.c
index c2e23d5..88bc52f 100644
--- a/net/ipv4/netfilter/iptable_security.c
+++ b/net/ipv4/netfilter/iptable_security.c
@@ -54,19 +54,20 @@ static struct nf_hook_ops *sectbl_ops __read_mostly;
 static int __net_init iptable_security_net_init(struct net *net)
 {
 	struct ipt_replace *repl;
+	int ret;
 
 	repl = ipt_alloc_initial_table(&security_table);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv4.iptable_security =
-		ipt_register_table(net, &security_table, repl);
+	ret = ipt_register_table(net, &security_table, repl, sectbl_ops,
+				 &net->ipv4.iptable_security);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv4.iptable_security);
+	return ret;
 }
 
 static void __net_exit iptable_security_net_exit(struct net *net)
 {
-	ipt_unregister_table(net, net->ipv4.iptable_security);
+	ipt_unregister_table(net, net->ipv4.iptable_security, sectbl_ops);
 }
 
 static struct pernet_operations iptable_security_net_ops = {
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index 99425cf..052d744 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2071,9 +2071,10 @@ do_ip6t_get_ctl(struct sock *sk, int cmd, void __user *user, int *len)
 	return ret;
 }
 
-struct xt_table *ip6t_register_table(struct net *net,
-				     const struct xt_table *table,
-				     const struct ip6t_replace *repl)
+int ip6t_register_table(struct net *net, const struct xt_table *table,
+			const struct ip6t_replace *repl,
+			const struct nf_hook_ops *ops,
+			struct xt_table **res)
 {
 	int ret;
 	struct xt_table_info *newinfo;
@@ -2082,10 +2083,8 @@ struct xt_table *ip6t_register_table(struct net *net,
 	struct xt_table *new_table;
 
 	newinfo = xt_alloc_table_info(repl->size);
-	if (!newinfo) {
-		ret = -ENOMEM;
-		goto out;
-	}
+	if (!newinfo)
+		return -ENOMEM;
 
 	loc_cpu_entry = newinfo->entries;
 	memcpy(loc_cpu_entry, repl->entries, repl->size);
@@ -2099,15 +2098,17 @@ struct xt_table *ip6t_register_table(struct net *net,
 		ret = PTR_ERR(new_table);
 		goto out_free;
 	}
-	return new_table;
+
+	WRITE_ONCE(*res, new_table);
+	return ret;
 
 out_free:
 	xt_free_table_info(newinfo);
-out:
-	return ERR_PTR(ret);
+	return ret;
 }
 
-void ip6t_unregister_table(struct net *net, struct xt_table *table)
+void ip6t_unregister_table(struct net *net, struct xt_table *table,
+			   const struct nf_hook_ops *ops)
 {
 	struct xt_table_info *private;
 	void *loc_cpu_entry;
diff --git a/net/ipv6/netfilter/ip6table_filter.c b/net/ipv6/netfilter/ip6table_filter.c
index 8b277b9..d191d54 100644
--- a/net/ipv6/netfilter/ip6table_filter.c
+++ b/net/ipv6/netfilter/ip6table_filter.c
@@ -47,6 +47,7 @@ module_param(forward, bool, 0000);
 static int __net_init ip6table_filter_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
+	int err;
 
 	repl = ip6t_alloc_initial_table(&packet_filter);
 	if (repl == NULL)
@@ -55,15 +56,15 @@ static int __net_init ip6table_filter_net_init(struct net *net)
 	((struct ip6t_standard *)repl->entries)[1].target.verdict =
 		forward ? -NF_ACCEPT - 1 : -NF_DROP - 1;
 
-	net->ipv6.ip6table_filter =
-		ip6t_register_table(net, &packet_filter, repl);
+	err = ip6t_register_table(net, &packet_filter, repl, filter_ops,
+				  &net->ipv6.ip6table_filter);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_filter);
+	return err;
 }
 
 static void __net_exit ip6table_filter_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net, net->ipv6.ip6table_filter);
+	ip6t_unregister_table(net, net->ipv6.ip6table_filter, filter_ops);
 }
 
 static struct pernet_operations ip6table_filter_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_mangle.c b/net/ipv6/netfilter/ip6table_mangle.c
index abe278b..fe43d08 100644
--- a/net/ipv6/netfilter/ip6table_mangle.c
+++ b/net/ipv6/netfilter/ip6table_mangle.c
@@ -91,19 +91,20 @@ static struct nf_hook_ops *mangle_ops __read_mostly;
 static int __net_init ip6table_mangle_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
+	int ret;
 
 	repl = ip6t_alloc_initial_table(&packet_mangler);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv6.ip6table_mangle =
-		ip6t_register_table(net, &packet_mangler, repl);
+	ret = ip6t_register_table(net, &packet_mangler, repl, mangle_ops,
+				  &net->ipv6.ip6table_mangle);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_mangle);
+	return ret;
 }
 
 static void __net_exit ip6table_mangle_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net, net->ipv6.ip6table_mangle);
+	ip6t_unregister_table(net, net->ipv6.ip6table_mangle, mangle_ops);
 }
 
 static struct pernet_operations ip6table_mangle_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_nat.c b/net/ipv6/netfilter/ip6table_nat.c
index de2a10a..7f9740e 100644
--- a/net/ipv6/netfilter/ip6table_nat.c
+++ b/net/ipv6/netfilter/ip6table_nat.c
@@ -100,18 +100,20 @@ static struct nf_hook_ops nf_nat_ipv6_ops[] __read_mostly = {
 static int __net_init ip6table_nat_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
+	int ret;
 
 	repl = ip6t_alloc_initial_table(&nf_nat_ipv6_table);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv6.ip6table_nat = ip6t_register_table(net, &nf_nat_ipv6_table, repl);
+	ret = ip6t_register_table(net, &nf_nat_ipv6_table, repl,
+				  nf_nat_ipv6_ops, &net->ipv6.ip6table_nat);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_nat);
+	return ret;
 }
 
 static void __net_exit ip6table_nat_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net, net->ipv6.ip6table_nat);
+	ip6t_unregister_table(net, net->ipv6.ip6table_nat, nf_nat_ipv6_ops);
 }
 
 static struct pernet_operations ip6table_nat_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_raw.c b/net/ipv6/netfilter/ip6table_raw.c
index 9021963..5fac433 100644
--- a/net/ipv6/netfilter/ip6table_raw.c
+++ b/net/ipv6/netfilter/ip6table_raw.c
@@ -30,19 +30,20 @@ static struct nf_hook_ops *rawtable_ops __read_mostly;
 static int __net_init ip6table_raw_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
+	int ret;
 
 	repl = ip6t_alloc_initial_table(&packet_raw);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv6.ip6table_raw =
-		ip6t_register_table(net, &packet_raw, repl);
+	ret = ip6t_register_table(net, &packet_raw, repl, rawtable_ops,
+				  &net->ipv6.ip6table_raw);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_raw);
+	return ret;
 }
 
 static void __net_exit ip6table_raw_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net, net->ipv6.ip6table_raw);
+	ip6t_unregister_table(net, net->ipv6.ip6table_raw, rawtable_ops);
 }
 
 static struct pernet_operations ip6table_raw_net_ops = {
diff --git a/net/ipv6/netfilter/ip6table_security.c b/net/ipv6/netfilter/ip6table_security.c
index 0d856fe..cf58745 100644
--- a/net/ipv6/netfilter/ip6table_security.c
+++ b/net/ipv6/netfilter/ip6table_security.c
@@ -47,19 +47,20 @@ static struct nf_hook_ops *sectbl_ops __read_mostly;
 static int __net_init ip6table_security_net_init(struct net *net)
 {
 	struct ip6t_replace *repl;
+	int ret;
 
 	repl = ip6t_alloc_initial_table(&security_table);
 	if (repl == NULL)
 		return -ENOMEM;
-	net->ipv6.ip6table_security =
-		ip6t_register_table(net, &security_table, repl);
+	ret = ip6t_register_table(net, &security_table, repl, sectbl_ops,
+				  &net->ipv6.ip6table_security);
 	kfree(repl);
-	return PTR_ERR_OR_ZERO(net->ipv6.ip6table_security);
+	return ret;
 }
 
 static void __net_exit ip6table_security_net_exit(struct net *net)
 {
-	ip6t_unregister_table(net, net->ipv6.ip6table_security);
+	ip6t_unregister_table(net, net->ipv6.ip6table_security, sectbl_ops);
 }
 
 static struct pernet_operations ip6table_security_net_ops = {
-- 
2.1.4
