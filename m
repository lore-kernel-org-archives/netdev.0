From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 04/12: ctnetlink: add callbacks to the per-proto nlattrs
Date: Thu, 26 Mar 2009 20:02:36 +0100 (MET)
Message-ID: <20090326190230.23365.28348.sendpatchset@x2.localnet>
References: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39215 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758598AbZCZTCi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Mar 2009 15:02:38 -0400
In-Reply-To: <20090326190225.23365.96356.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit d0dba7255b541f1651a88e75ebdb20dd45509c2f
Author: Holger Eitzenberger <holger@eitzenberger.org>
Date:   Wed Mar 25 18:24:48 2009 +0100

    netfilter: ctnetlink: add callbacks to the per-proto nlattrs
    
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
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/net/netfilter/nf_conntrack_l3proto.h b/include/net/netfilter/nf_conntrack_l3proto.h
index 0378676..9f99d36 100644
--- a/include/net/netfilter/nf_conntrack_l3proto.h
+++ b/include/net/netfilter/nf_conntrack_l3proto.h
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
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index b01070b..a120990 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
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
diff --git a/net/netfilter/nf_conntrack_proto.c b/net/netfilter/nf_conntrack_proto.c
index 9a62b4e..1a4568b 100644
--- a/net/netfilter/nf_conntrack_proto.c
+++ b/net/netfilter/nf_conntrack_proto.c
@@ -167,6 +167,9 @@ int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 	if (proto->l3proto >= AF_MAX)
 		return -EBUSY;
 
+	if (proto->tuple_to_nlattr && !proto->nlattr_tuple_size)
+		return -EINVAL;
+
 	mutex_lock(&nf_ct_proto_mutex);
 	if (nf_ct_l3protos[proto->l3proto] != &nf_conntrack_l3proto_generic) {
 		ret = -EBUSY;
@@ -177,6 +180,9 @@ int nf_conntrack_l3proto_register(struct nf_conntrack_l3proto *proto)
 	if (ret < 0)
 		goto out_unlock;
 
+	if (proto->nlattr_tuple_size)
+		proto->nla_size = 3 * proto->nlattr_tuple_size();
+
 	rcu_assign_pointer(nf_ct_l3protos[proto->l3proto], proto);
 
 out_unlock:
@@ -263,6 +269,10 @@ int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
 	if (l4proto->l3proto >= PF_MAX)
 		return -EBUSY;
 
+	if ((l4proto->to_nlattr && !l4proto->nlattr_size)
+		|| (l4proto->tuple_to_nlattr && !l4proto->nlattr_tuple_size))
+		return -EINVAL;
+
 	mutex_lock(&nf_ct_proto_mutex);
 	if (!nf_ct_protos[l4proto->l3proto]) {
 		/* l3proto may be loaded latter. */
@@ -290,6 +300,12 @@ int nf_conntrack_l4proto_register(struct nf_conntrack_l4proto *l4proto)
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
 
