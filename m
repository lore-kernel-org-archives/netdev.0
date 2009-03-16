From: Holger Eitzenberger <holger@eitzenberger.org>
Subject: [patch 1/6] ctnetlink: add callbacks to the per-proto nlattrs
Date: Mon, 16 Mar 2009 23:07:00 +0100
Message-ID: <20090316221135.741449312@jonathan.eitzenberger.org>
References: <20090316220659.756862181@jonathan.eitzenberger.org>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline; filename=ctnetlink-add-infrastructure-to-the-per-proto-nlatt.diff
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There is added a single callback for the l3 proto helper.  The two
callbacks for the l4 protos are necessary because of the general
structure of a ctnetlink event, which is in short:

 CTA_TUPLE_ORIG
   <l3/l4-proto-attributes>
 CTA_TUPLE_REPLY
   <l3/l4-proto-attributes>
 CTA_ID
 ...
 CTA_PROTOINFO
   <l4-proto-attributes>
 CTA_TUPLE_MASTER
   <l3/l4-proto-attributes>

Therefore the formular is

 size := sizeof(generic-nlas) + 3 * sizeof(tuple_nlas) + sizeof(protoinfo_nlas)

Some of the NLAs are optional, e. g. CTA_TUPLE_MASTER, which is only
set if it's an expected connection.  But the number of optional NLAs is
small enough to prevent netlink_trim() from reallocating if calculated
properly.

Signed-off-by: Holger Eitzenberger <holger@eitzenberger.org>

Index: net-next-2.6/include/net/netfilter/nf_conntrack_l3proto.h
===================================================================
--- net-next-2.6.orig/include/net/netfilter/nf_conntrack_l3proto.h
+++ net-next-2.6/include/net/netfilter/nf_conntrack_l3proto.h
@@ -53,10 +53,17 @@ struct nf_conntrack_l3proto
 	int (*tuple_to_nlattr)(struct sk_buff *skb,
 			       const struct nf_conntrack_tuple *t);
 
+	/*
+	 * Calculate size of tuple nlattr
+	 */
+	int (*nlattr_tuple_size)(void);
+
 	int (*nlattr_to_tuple)(struct nlattr *tb[],
 			       struct nf_conntrack_tuple *t);
 	const struct nla_policy *nla_policy;
 
+	size_t nla_size;
+
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*ctl_table_header;
 	struct ctl_path		*ctl_table_path;
Index: net-next-2.6/include/net/netfilter/nf_conntrack_l4proto.h
===================================================================
--- net-next-2.6.orig/include/net/netfilter/nf_conntrack_l4proto.h
+++ net-next-2.6/include/net/netfilter/nf_conntrack_l4proto.h
@@ -64,16 +64,22 @@ struct nf_conntrack_l4proto
 	/* convert protoinfo to nfnetink attributes */
 	int (*to_nlattr)(struct sk_buff *skb, struct nlattr *nla,
 			 const struct nf_conn *ct);
+	/* Calculate protoinfo nlattr size */
+	int (*nlattr_size)(void);
 
 	/* convert nfnetlink attributes to protoinfo */
 	int (*from_nlattr)(struct nlattr *tb[], struct nf_conn *ct);
 
 	int (*tuple_to_nlattr)(struct sk_buff *skb,
 			       const struct nf_conntrack_tuple *t);
+	/* Calculate tuple nlattr size */
+	int (*nlattr_tuple_size)(void);
 	int (*nlattr_to_tuple)(struct nlattr *tb[],
 			       struct nf_conntrack_tuple *t);
 	const struct nla_policy *nla_policy;
 
+	size_t nla_size;
+
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	**ctl_table_header;
 	struct ctl_table	*ctl_table;
Index: net-next-2.6/net/netfilter/nf_conntrack_proto.c
===================================================================
--- net-next-2.6.orig/net/netfilter/nf_conntrack_proto.c
+++ net-next-2.6/net/netfilter/nf_conntrack_proto.c
@@ -188,6 +188,9 @@ int nf_conntrack_l3proto_register(struct
 	if (proto->l3proto >= AF_MAX)
 		return -EBUSY;
 
+	if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
+		return -EINVAL;
+
 	mutex_lock(&nf_ct_proto_mutex);
 	if (nf_ct_l3protos[proto->l3proto] != &nf_conntrack_l3proto_generic) {
 		ret = -EBUSY;
@@ -198,6 +201,9 @@ int nf_conntrack_l3proto_register(struct
 	if (ret < 0)
 		goto out_unlock;
 
+	if (proto->nlattr_tuple_size)
+		proto->nla_size = 3 * proto->nlattr_tuple_size();
+
 	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto], proto);
 
 out_unlock:
@@ -284,6 +290,10 @@ int nf_conntrack_l4proto_register(struct
 	if (l4proto->l3proto >= PF_MAX)
 		return -EBUSY;
 
+	if ((l4proto->to_nlattr && !l4proto->nlattr_size)
+		|| (l4proto->tuple_to_nlattr && !l4proto->nlattr_tuple_size))
+		return -EINVAL;
+
 	mutex_lock(&nf_ct_proto_mutex);
 	if (!nf_ct_protos[l4proto->l3proto]) {
 		/* l3proto may be loaded latter. */
@@ -311,6 +321,12 @@ int nf_conntrack_l4proto_register(struct
 	if (ret < 0)
 		goto out_unlock;
 
+	l4proto->nla_size = 0;
+	if (l4proto->nlattr_size)
+		l4proto->nla_size += l4proto->nlattr_size();
+	if (l4proto->nlattr_tuple_size)
+		l4proto->nla_size += 3 * l4proto->nlattr_tuple_size();
+
 	rcu_assign_pointer(nf_ct_protos[l4proto->l3proto][l4proto->l4proto],
 			   l4proto);
 

-- 
