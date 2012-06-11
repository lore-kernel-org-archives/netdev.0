From: pablo@netfilter.org
Subject: [PATCH 05/25] netfilter: nf_conntrack: prepare namespace support for l3 protocol trackers
Date: Mon, 11 Jun 2012 16:43:41 +0200
Message-ID: <1339425841-24171-6-git-send-email-pablo@netfilter.org>
References: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1339425841-24171-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitsu.com>

This patch prepares the namespace support for layer 3 protocol trackers.
Basically, this modifies the following interfaces:

* nf_ct_l3proto_[un]register_sysctl.
* nf_conntrack_l3proto_[un]register.

We add a new nf_ct_l3proto_net is used to get the pernet data of l3proto.

This adds rhe new struct nf_ip_net that is used to store the sysctl header
and l3proto_ipv4,l4proto_tcp(6),l4proto_udp(6),l4proto_icmp(v6) because the
protos such tcp and tcp6 use the same data,so making nf_ip_net as a field
of netns_ct is the easiest way to manager it.

This patch also adds init_net to struct nf_conntrack_l3proto to initial
the layer 3 protocol pernet data.

Acked-by: Eric W. Biederman <ebiederm@xmission.com>
Signed-off-by: Gao feng <gaofeng@cn.fujitsu.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_conntrack_l3proto.h   |    9 ++-
 include/net/netns/conntrack.h                  |    8 +++
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c |    6 +-
 net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c |    6 +-
 net/netfilter/nf_conntrack_proto.c             |   92 ++++++++++++++++++------
 5 files changed, 91 insertions(+), 30 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 9699c02..d6df8c7 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -69,6 +69,9 @@ struct nf_conntrack_l3proto {
 	struct ctl_table	*ctl_table;
 #endif /* CONFIG_SYSCTL */
 
+	/* Init l3proto pernet data */
+	int (*init_net)(struct net *net);
+
 	/* Module (if any) which this is connected to. */
 	struct module *me;
 };
@@ -76,8 +79,10 @@ struct nf_conntrack_l3proto {
 extern struct nf_conntrack_l3proto __rcu *nf_ct_l3protos[AF_MAX];
 
 /* Protocol registration. */
-extern int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto);
-extern void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto);
+extern int nf_conntrack_l3proto_register(struct net *net,
+					 struct nf_conntrack_l3proto *proto);
+extern void nf_conntrack_l3proto_unregister(struct net *net,
+					    struct nf_conntrack_l3proto *proto);
 extern struct nf_conntrack_l3proto *nf_ct_l3proto_find_get(u_int16_t l3proto);
 extern void nf_ct_l3proto_put(struct nf_conntrack_l3proto *p);
 
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 1f53038..b2dbcc5 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -20,6 +20,13 @@ struct nf_proto_net {
 	unsigned int		users;
 };
 
+struct nf_ip_net {
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	struct ctl_table_header *ctl_table_header;
+	struct ctl_table	*ctl_table;
+#endif
+};
+
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
@@ -40,6 +47,7 @@ struct netns_ct {
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
 	int			sysctl_auto_assign_helper;
 	bool			auto_assign_helper_warned;
+	struct nf_ip_net	nf_ct_proto;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index 46ec515..0c0fb90 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -409,7 +409,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 		goto cleanup_udp;
 	}
 
-	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv4);
+	ret = nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3proto_ipv4);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv4: can't register ipv4\n");
 		goto cleanup_icmp;
@@ -432,7 +432,7 @@ static int __init nf_conntrack_l3proto_ipv4_init(void)
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
 #endif
  cleanup_ipv4:
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
+	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv4);
  cleanup_icmp:
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
  cleanup_udp:
@@ -451,7 +451,7 @@ static void __exit nf_conntrack_l3proto_ipv4_fini(void)
 	nf_conntrack_ipv4_compat_fini();
 #endif
 	nf_unregister_hooks(ipv4_conntrack_ops, ARRAY_SIZE(ipv4_conntrack_ops));
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv4);
+	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv4);
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmp);
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp4);
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp4);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 51ad9f1..7334cbf 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -358,7 +358,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 		goto cleanup_udp;
 	}
 
-	ret = nf_conntrack_l3proto_register(&nf_conntrack_l3proto_ipv6);
+	ret = nf_conntrack_l3proto_register(&init_net, &nf_conntrack_l3proto_ipv6);
 	if (ret < 0) {
 		pr_err("nf_conntrack_ipv6: can't register ipv6\n");
 		goto cleanup_icmpv6;
@@ -374,7 +374,7 @@ static int __init nf_conntrack_l3proto_ipv6_init(void)
 	return ret;
 
  cleanup_ipv6:
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
+	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv6);
  cleanup_icmpv6:
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
  cleanup_udp:
@@ -388,7 +388,7 @@ static void __exit nf_conntrack_l3proto_ipv6_fini(void)
 {
 	synchronize_net();
 	nf_unregister_hooks(ipv6_conntrack_ops, ARRAY_SIZE(ipv6_conntrack_ops));
-	nf_conntrack_l3proto_unregister(&nf_conntrack_l3proto_ipv6);
+	nf_conntrack_l3proto_unregister(&init_net, &nf_conntrack_l3proto_ipv6);
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_icmpv6);
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_udp6);
 	nf_conntrack_l4proto_unregister(&init_net, &nf_conntrack_l4proto_tcp6);
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 7ee31ac..a8daf0f 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -168,31 +168,57 @@ static int kill_l4proto(struct nf_conn *i, void *data)
 	       nf_ct_l3num(i) == l4proto->l3proto;
 }
 
-static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3proto *l3proto)
+static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
+					   struct nf_conntrack_l3proto *l3proto)
+{
+	if (l3proto->l3proto == PF_INET)
+		return &net->ct.nf_ct_proto;
+	else
+		return NULL;
+}
+
+static int nf_ct_l3proto_register_sysctl(struct net *net,
+					 struct nf_conntrack_l3proto *l3proto)
 {
 	int err = 0;
+	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
+	/* nf_conntrack_l3proto_ipv6 doesn't support sysctl */
+	if (in == NULL)
+		return 0;
 
-#ifdef CONFIG_SYSCTL
-	if (l3proto->ctl_table != NULL) {
-		err = nf_ct_register_sysctl(&init_net,
-					    &l3proto->ctl_table_header,
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	if (in->ctl_table != NULL) {
+		err = nf_ct_register_sysctl(net,
+					    &in->ctl_table_header,
 					    l3proto->ctl_table_path,
-					    l3proto->ctl_table, NULL);
+					    in->ctl_table,
+					    NULL);
+		if (err < 0) {
+			kfree(in->ctl_table);
+			in->ctl_table = NULL;
+		}
 	}
 #endif
 	return err;
 }
 
-static void nf_ct_l3proto_unregister_sysctl(struct nf_conntrack_l3proto *l3proto)
+static void nf_ct_l3proto_unregister_sysctl(struct net *net,
+					    struct nf_conntrack_l3proto *l3proto)
 {
-#ifdef CONFIG_SYSCTL
-	if (l3proto->ctl_table_header != NULL)
-		nf_ct_unregister_sysctl(&l3proto->ctl_table_header,
-					&l3proto->ctl_table, NULL);
+	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
+
+	if (in == NULL)
+		return;
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	if (in->ctl_table_header != NULL)
+		nf_ct_unregister_sysctl(&in->ctl_table_header,
+					&in->ctl_table,
+					NULL);
 #endif
 }
 
-int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
+static int
+nf_conntrack_l3proto_register_net(struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
 	struct nf_conntrack_l3proto *old;
@@ -211,10 +237,6 @@ int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 		goto out_unlock;
 	}
 
-	ret = nf_ct_l3proto_register_sysctl(proto);
-	if (ret < 0)
-		goto out_unlock;
-
 	if (proto->nlattr_tuple_size)
 		proto->nla_size = 3 * proto->nlattr_tuple_size();
 
@@ -223,13 +245,32 @@ int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 out_unlock:
 	mutex_unlock(&nf_ct_proto_mutex);
 	return ret;
+
 }
-EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
-void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
+int nf_conntrack_l3proto_register(struct net *net,
+				  struct nf_conntrack_l3proto *proto)
 {
-	struct net *net;
+	int ret = 0;
+
+	if (net == &init_net)
+		ret = nf_conntrack_l3proto_register_net(proto);
 
+	if (ret < 0)
+		return ret;
+
+	if (proto->init_net) {
+		ret = proto->init_net(net);
+		if (ret < 0)
+			return ret;
+	}
+	return nf_ct_l3proto_register_sysctl(net, proto);
+}
+EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
+
+static void
+nf_conntrack_l3proto_unregister_net(struct nf_conntrack_l3proto *proto)
+{
 	BUG_ON(proto->l3proto >= AF_MAX);
 
 	mutex_lock(&nf_ct_proto_mutex);
@@ -238,15 +279,22 @@ void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
 					 ) != proto);
 	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
 			   &nf_conntrack_l3proto_generic);
-	nf_ct_l3proto_unregister_sysctl(proto);
 	mutex_unlock(&nf_ct_proto_mutex);
 
 	synchronize_rcu();
+}
+
+void nf_conntrack_l3proto_unregister(struct net *net,
+				     struct nf_conntrack_l3proto *proto)
+{
+	if (net == &init_net)
+		nf_conntrack_l3proto_unregister_net(proto);
+
+	nf_ct_l3proto_unregister_sysctl(net, proto);
 
 	/* Remove all contrack entries for this protocol */
 	rtnl_lock();
-	for_each_net(net)
-		nf_ct_iterate_cleanup(net, kill_l3proto, proto);
+	nf_ct_iterate_cleanup(net, kill_l3proto, proto);
 	rtnl_unlock();
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_unregister);
-- 
1.7.10

