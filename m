From: Gao feng <gaofeng@cn.fujitsu.com>
Subject: [PATCH 03/17] netfilter: add namespace support for l3proto
Date: Fri, 27 Apr 2012 17:37:50 +0800
Message-ID: <1335519484-6089-4-git-send-email-gaofeng@cn.fujitsu.com>
References: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	serge.hallyn@canonical.com, ebiederm@xmission.com,
	dlezcano@fr.ibm.com, Gao feng <gaofeng@cn.fujitus.com>
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1335519484-6089-1-git-send-email-gaofeng@cn.fujitsu.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao feng <gaofeng@cn.fujitus.com>

-Add the struct net as param of nf_conntrack_l3proto_(un)register.
 register or unregister the l3proto only when the net is init_net.

-The new struct nf_ip_net is used to store the sysctl header and data
 of l3proto_ipv4,l4proto_tcp(6),l4proto_udp(6),l4proto_icmp(v6).
 because the protos such tcp and tcp6 use the same data,so making
 nf_ip_net as a field of netns_ct is the easiest way to manager it.

-nf_ct_l3proto_register_sysctl call init_net to initial the pernet data
 of l3proto.

-nf_ct_l3proto_net is used to get the pernet data of l3proto.

-export nf_conntrack_l3proto_(un)register

Signed-off-by: Gao feng <gaofeng@cn.fujitus.com>
---
 include/net/netfilter/nf_conntrack_l3proto.h |    6 +-
 include/net/netns/conntrack.h                |    8 ++
 net/netfilter/nf_conntrack_proto.c           |  130 ++++++++++++++++----------
 3 files changed, 93 insertions(+), 51 deletions(-)

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 9766005..d6df8c7 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
@@ -79,8 +79,10 @@ struct nf_conntrack_l3proto {
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
index 59afb87..c329aad 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -20,6 +20,13 @@ struct nf_proto_net {
 	unsigned int		users;
 };
 
+struct nf_ip_net {
+#if defined(CONFIG_SYSCTL) && defined(CONFIG_NF_CONNTRACK_PROC_COMPAT)
+	struct ctl_table_header *ctl_table_header;
+	struct ctl_table        *ctl_table;
+#endif
+};
+
 struct netns_ct {
 	atomic_t		count;
 	unsigned int		expect_count;
@@ -38,6 +45,7 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+	struct nf_ip_net	proto;
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 85d71e0..065bff8 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -170,84 +170,116 @@ static int kill_l4proto(struct nf_conn *i, void *data)
 	       nf_ct_l3num(i) == l4proto->l3proto;
 }
 
-static int nf_ct_l3proto_register_sysctl(struct nf_conntrack_l3proto *l3proto)
+static struct nf_ip_net *nf_ct_l3proto_net(struct net *net,
+					   struct nf_conntrack_l3proto *l3proto)
+{
+	if (l3proto->l3proto == PF_INET)
+		return &net->ct.proto;
+	else
+		return NULL;
+}
+
+static int nf_ct_l3proto_register_sysctl(struct net *net,
+					 struct nf_conntrack_l3proto *l3proto)
 {
 	int err = 0;
+	struct nf_ip_net *in = nf_ct_l3proto_net(net, l3proto);
 
-#ifdef CONFIG_SYSCTL
-	if (l3proto->ctl_table != NULL) {
-		err = nf_ct_register_sysctl(&l3proto->ctl_table_header,
+	if (in == NULL)
+		return 0;
+
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
-					l3proto->ctl_table, NULL);
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
+int nf_conntrack_l3proto_register(struct net *net,
+				  struct nf_conntrack_l3proto *proto)
 {
 	int ret = 0;
-	struct nf_conntrack_l3proto *old;
 
-	if (proto->l3proto >= AF_MAX)
-		return -EBUSY;
-
-	if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
-		return -EINVAL;
-
-	mutex_lock(&nf_ct_proto_mutex);
-	old = rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
-					lockdep_is_held(&nf_ct_proto_mutex));
-	if (old != &nf_conntrack_l3proto_generic) {
-		ret = -EBUSY;
-		goto out_unlock;
-	}
+	if (net == &init_net) {
+		struct nf_conntrack_l3proto *old;
 
-	ret = nf_ct_l3proto_register_sysctl(proto);
-	if (ret < 0)
-		goto out_unlock;
+		if (proto->l3proto >= AF_MAX)
+			return -EBUSY;
+
+		if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
+			return -EINVAL;
 
-	if (proto->nlattr_tuple_size)
-		proto->nla_size = 3 * proto->nlattr_tuple_size();
+		mutex_lock(&nf_ct_proto_mutex);
+		old = rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
+						lockdep_is_held(&nf_ct_proto_mutex));
+		if (old != &nf_conntrack_l3proto_generic) {
+			ret = -EBUSY;
+			goto out_unlock;
+		}
 
-	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto], proto);
+		if (proto->nlattr_tuple_size)
+			proto->nla_size = 3 * proto->nlattr_tuple_size();
 
+		rcu_assign_pointer(nf_ct_l3protos[proto->l3proto], proto);
 out_unlock:
-	mutex_unlock(&nf_ct_proto_mutex);
-	return ret;
+		mutex_unlock(&nf_ct_proto_mutex);
+		if (ret < 0)
+			return ret;
+	}
+	if (proto->init_net) {
+		ret = proto->init_net(net);
+		if (ret < 0)
+			return ret;
+	}
+	return nf_ct_l3proto_register_sysctl(net, proto);
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_l3proto_register);
 
-void nf_conntrack_l3proto_unregister(struct nf_conntrack_l3proto *proto)
+void nf_conntrack_l3proto_unregister(struct net *net,
+				     struct nf_conntrack_l3proto *proto)
 {
-	struct net *net;
-
-	BUG_ON(proto->l3proto >= AF_MAX);
-
-	mutex_lock(&nf_ct_proto_mutex);
-	BUG_ON(rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
-					 lockdep_is_held(&nf_ct_proto_mutex)
-					 ) != proto);
-	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
-			   &nf_conntrack_l3proto_generic);
-	nf_ct_l3proto_unregister_sysctl(proto);
-	mutex_unlock(&nf_ct_proto_mutex);
+	if (net == &init_net) {
+		BUG_ON(proto->l3proto >= AF_MAX);
+
+		mutex_lock(&nf_ct_proto_mutex);
+		BUG_ON(rcu_dereference_protected(nf_ct_l3protos[proto->l3proto],
+						 lockdep_is_held(&nf_ct_proto_mutex)
+						 ) != proto);
+		rcu_assign_pointer(nf_ct_l3protos[proto->l3proto],
+				   &nf_conntrack_l3proto_generic);
+		mutex_unlock(&nf_ct_proto_mutex);
 
-	synchronize_rcu();
+		synchronize_rcu();
+	}
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
1.7.7.6

