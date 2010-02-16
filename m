From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 59/62: ctnetlink: add zone support
Date: Tue, 16 Feb 2010 15:56:40 +0100 (MET)
Message-ID: <20100216145637.2796.18777.sendpatchset@x2.localnet>
References: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:52127 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932804Ab0BPO4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 09:56:41 -0500
In-Reply-To: <20100216145517.2796.40634.sendpatchset@x2.localnet>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit ef00f89f1eb7e056aab9dfe068521e6f2320c94a
Author: Patrick McHardy <kaber@trash.net>
Date:   Mon Feb 15 18:14:57 2010 +0100

    netfilter: ctnetlink: add zone support
    
    Parse and dump the conntrack zone in ctnetlink.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index ed4ef8d..9ed534c 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -40,6 +40,7 @@ enum ctattr_type {
 	CTA_NAT_SEQ_ADJ_ORIG,
 	CTA_NAT_SEQ_ADJ_REPLY,
 	CTA_SECMARK,
+	CTA_ZONE,
 	__CTA_MAX
 };
 #define CTA_MAX (__CTA_MAX - 1)
@@ -159,6 +160,7 @@ enum ctattr_expect {
 	CTA_EXPECT_TIMEOUT,
 	CTA_EXPECT_ID,
 	CTA_EXPECT_HELP_NAME,
+	CTA_EXPECT_ZONE,
 	__CTA_EXPECT_MAX
 };
 #define CTA_EXPECT_MAX (__CTA_EXPECT_MAX - 1)
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 51089cf..8b05f36 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -39,6 +39,7 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
 #include <net/netfilter/nf_conntrack_acct.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #ifdef CONFIG_NF_NAT_NEEDED
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_protocol.h>
@@ -379,6 +380,9 @@ ctnetlink_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
+	if (nf_ct_zone(ct))
+		NLA_PUT_BE16(skb, CTA_ZONE, htons(nf_ct_zone(ct)));
+
 	if (ctnetlink_dump_status(skb, ct) < 0 ||
 	    ctnetlink_dump_timeout(skb, ct) < 0 ||
 	    ctnetlink_dump_counters(skb, ct, IP_CT_DIR_ORIGINAL) < 0 ||
@@ -517,6 +521,9 @@ ctnetlink_conntrack_event(unsigned int events, struct nf_ct_event *item)
 		goto nla_put_failure;
 	nla_nest_end(skb, nest_parms);
 
+	if (nf_ct_zone(ct))
+		NLA_PUT_BE16(skb, CTA_ZONE, htons(nf_ct_zone(ct)));
+
 	if (ctnetlink_dump_id(skb, ct) < 0)
 		goto nla_put_failure;
 
@@ -750,6 +757,21 @@ ctnetlink_parse_tuple(const struct nlattr * const cda[],
 	return 0;
 }
 
+static int
+ctnetlink_parse_zone(const struct nlattr *attr, u16 *zone)
+{
+	if (attr)
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+		*zone = ntohs(nla_get_be16(attr));
+#else
+		return -EOPNOTSUPP;
+#endif
+	else
+		*zone = 0;
+
+	return 0;
+}
+
 static const struct nla_policy help_nla_policy[CTA_HELP_MAX+1] = {
 	[CTA_HELP_NAME]		= { .type = NLA_NUL_STRING },
 };
@@ -781,6 +803,7 @@ static const struct nla_policy ct_nla_policy[CTA_MAX+1] = {
 	[CTA_ID]		= { .type = NLA_U32 },
 	[CTA_NAT_DST]		= { .type = NLA_NESTED },
 	[CTA_TUPLE_MASTER]	= { .type = NLA_NESTED },
+	[CTA_ZONE]		= { .type = NLA_U16 },
 };
 
 static int
@@ -794,7 +817,12 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conn *ct;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	int err = 0;
+	u16 zone;
+	int err;
+
+	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
+	if (err < 0)
+		return err;
 
 	if (cda[CTA_TUPLE_ORIG])
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG, u3);
@@ -811,7 +839,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(net, 0, &tuple);
+	h = nf_conntrack_find_get(net, zone, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -856,12 +884,17 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct sk_buff *skb2 = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	int err = 0;
+	u16 zone;
+	int err;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP)
 		return netlink_dump_start(ctnl, skb, nlh, ctnetlink_dump_table,
 					  ctnetlink_done);
 
+	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
+	if (err < 0)
+		return err;
+
 	if (cda[CTA_TUPLE_ORIG])
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_TUPLE_ORIG, u3);
 	else if (cda[CTA_TUPLE_REPLY])
@@ -872,7 +905,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(net, 0, &tuple);
+	h = nf_conntrack_find_get(net, zone, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1211,7 +1244,7 @@ ctnetlink_change_conntrack(struct nf_conn *ct,
 }
 
 static struct nf_conn *
-ctnetlink_create_conntrack(struct net *net,
+ctnetlink_create_conntrack(struct net *net, u16 zone,
 			   const struct nlattr * const cda[],
 			   struct nf_conntrack_tuple *otuple,
 			   struct nf_conntrack_tuple *rtuple,
@@ -1221,7 +1254,7 @@ ctnetlink_create_conntrack(struct net *net,
 	int err = -EINVAL;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(net, 0, otuple, rtuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(net, zone, otuple, rtuple, GFP_ATOMIC);
 	if (IS_ERR(ct))
 		return ERR_PTR(-ENOMEM);
 
@@ -1325,7 +1358,7 @@ ctnetlink_create_conntrack(struct net *net,
 		if (err < 0)
 			goto err2;
 
-		master_h = nf_conntrack_find_get(net, 0, &master);
+		master_h = nf_conntrack_find_get(net, zone, &master);
 		if (master_h == NULL) {
 			err = -ENOENT;
 			goto err2;
@@ -1358,7 +1391,12 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_tuple_hash *h = NULL;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	int err = 0;
+	u16 zone;
+	int err;
+
+	err = ctnetlink_parse_zone(cda[CTA_ZONE], &zone);
+	if (err < 0)
+		return err;
 
 	if (cda[CTA_TUPLE_ORIG]) {
 		err = ctnetlink_parse_tuple(cda, &otuple, CTA_TUPLE_ORIG, u3);
@@ -1374,9 +1412,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	spin_lock_bh(&nf_conntrack_lock);
 	if (cda[CTA_TUPLE_ORIG])
-		h = __nf_conntrack_find(net, 0, &otuple);
+		h = __nf_conntrack_find(net, zone, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = __nf_conntrack_find(net, 0, &rtuple);
+		h = __nf_conntrack_find(net, zone, &rtuple);
 
 	if (h == NULL) {
 		err = -ENOENT;
@@ -1384,7 +1422,7 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 			struct nf_conn *ct;
 			enum ip_conntrack_events events;
 
-			ct = ctnetlink_create_conntrack(net, cda, &otuple,
+			ct = ctnetlink_create_conntrack(net, zone, cda, &otuple,
 							&rtuple, u3);
 			if (IS_ERR(ct)) {
 				err = PTR_ERR(ct);
@@ -1698,7 +1736,8 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct sk_buff *skb2;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	int err = 0;
+	u16 zone;
+	int err;
 
 	if (nlh->nlmsg_flags & NLM_F_DUMP) {
 		return netlink_dump_start(ctnl, skb, nlh,
@@ -1706,6 +1745,10 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 					  ctnetlink_exp_done);
 	}
 
+	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
+	if (err < 0)
+		return err;
+
 	if (cda[CTA_EXPECT_MASTER])
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_MASTER, u3);
 	else
@@ -1714,7 +1757,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	exp = nf_ct_expect_find_get(net, 0, &tuple);
+	exp = nf_ct_expect_find_get(net, zone, &tuple);
 	if (!exp)
 		return -ENOENT;
 
@@ -1761,16 +1804,21 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct hlist_node *n, *next;
 	u_int8_t u3 = nfmsg->nfgen_family;
 	unsigned int i;
+	u16 zone;
 	int err;
 
 	if (cda[CTA_EXPECT_TUPLE]) {
 		/* delete a single expect by tuple */
+		err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
+		if (err < 0)
+			return err;
+
 		err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE, u3);
 		if (err < 0)
 			return err;
 
 		/* bump usage count to 2 */
-		exp = nf_ct_expect_find_get(net, 0, &tuple);
+		exp = nf_ct_expect_find_get(net, zone, &tuple);
 		if (!exp)
 			return -ENOENT;
 
@@ -1832,7 +1880,8 @@ ctnetlink_change_expect(struct nf_conntrack_expect *x,
 }
 
 static int
-ctnetlink_create_expect(struct net *net, const struct nlattr * const cda[],
+ctnetlink_create_expect(struct net *net, u16 zone,
+			const struct nlattr * const cda[],
 			u_int8_t u3,
 			u32 pid, int report)
 {
@@ -1855,7 +1904,7 @@ ctnetlink_create_expect(struct net *net, const struct nlattr * const cda[],
 		return err;
 
 	/* Look for master conntrack of this expectation */
-	h = nf_conntrack_find_get(net, 0, &master_tuple);
+	h = nf_conntrack_find_get(net, zone, &master_tuple);
 	if (!h)
 		return -ENOENT;
 	ct = nf_ct_tuplehash_to_ctrack(h);
@@ -1900,25 +1949,30 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 	struct nf_conntrack_expect *exp;
 	struct nfgenmsg *nfmsg = nlmsg_data(nlh);
 	u_int8_t u3 = nfmsg->nfgen_family;
-	int err = 0;
+	u16 zone;
+	int err;
 
 	if (!cda[CTA_EXPECT_TUPLE]
 	    || !cda[CTA_EXPECT_MASK]
 	    || !cda[CTA_EXPECT_MASTER])
 		return -EINVAL;
 
+	err = ctnetlink_parse_zone(cda[CTA_EXPECT_ZONE], &zone);
+	if (err < 0)
+		return err;
+
 	err = ctnetlink_parse_tuple(cda, &tuple, CTA_EXPECT_TUPLE, u3);
 	if (err < 0)
 		return err;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = __nf_ct_expect_find(net, 0, &tuple);
+	exp = __nf_ct_expect_find(net, zone, &tuple);
 
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_lock);
 		err = -ENOENT;
 		if (nlh->nlmsg_flags & NLM_F_CREATE) {
-			err = ctnetlink_create_expect(net, cda,
+			err = ctnetlink_create_expect(net, zone, cda,
 						      u3,
 						      NETLINK_CB(skb).pid,
 						      nlmsg_report(nlh));
