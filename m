From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 2/3] net/act_pedit: Support using offset relative to the conventional network headers
Date: Tue,  7 Feb 2017 09:56:07 +0200
Message-ID: <20170207075608.8430-3-amir@vadai.me>
References: <20170207075608.8430-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f196.google.com ([209.85.128.196]:35450 "EHLO
        mail-wr0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753145AbdBGH42 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:56:28 -0500
Received: by mail-wr0-f196.google.com with SMTP id o16so4954915wra.2
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:56:27 -0800 (PST)
In-Reply-To: <20170207075608.8430-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend pedit to enable the user setting offset relative to network
headers. This change would enable to work with more complex header
schemes (vs the simple IPv4 case) where setting a fixed offset relative
to the network header is not enough.

After this patch, the action has information about the exact header type
and field inside this header. This information could be used later on
for hardware offloading of pedit.

Backward compatibility was being kept:
1. Old kernel <-> new userspace
2. New kernel <-> old userspace
3. add rule using new userspace <-> dump using old userspace
4. add rule using old userspace <-> dump using new userspace

When using the extended api, new netlink attributes are being used. This
way, operation will fail in (1) and (3) - and no malformed rule be added
or dumped. Of course, new user space that doesn't need the new
functionality can use the old netlink attributes and operation will
succeed.
Since action can support both api's, (2) should work, and it is easy to
write the new user space to have (4) work.

The action is having a strict check that only header types and commands
it can handle are accepted. This way future additions will be much
easier.

Usage example:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
  flower \
    ip_proto tcp \
    dst_port 80 \
  action pedit munge tcp dport set 8080 pipe \
  action mirred egress redirect dev veth0

Will forward tcp port whose original dest port is 80, while modifying
the destination port to 8080.

Signed-off-by: Amir Vadai <amir@vadai.me>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/net/tc_act/tc_pedit.h        |   5 +
 include/uapi/linux/tc_act/tc_pedit.h |  23 ++++
 net/sched/act_pedit.c                | 196 ++++++++++++++++++++++++++++++++---
 3 files changed, 208 insertions(+), 16 deletions(-)

diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index 29e38d6823df..e076f22035a5 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -3,11 +3,16 @@
 
 #include <net/act_api.h>
 
+struct tcf_pedit_key_ex {
+	enum pedit_header_type htype;
+};
+
 struct tcf_pedit {
 	struct tc_action	common;
 	unsigned char		tcfp_nkeys;
 	unsigned char		tcfp_flags;
 	struct tc_pedit_key	*tcfp_keys;
+	struct tcf_pedit_key_ex	*tcfp_keys_ex;
 };
 #define to_pedit(a) ((struct tcf_pedit *)a)
 
diff --git a/include/uapi/linux/tc_act/tc_pedit.h b/include/uapi/linux/tc_act/tc_pedit.h
index 6389959a5157..22f19eeda997 100644
--- a/include/uapi/linux/tc_act/tc_pedit.h
+++ b/include/uapi/linux/tc_act/tc_pedit.h
@@ -11,10 +11,33 @@ enum {
 	TCA_PEDIT_TM,
 	TCA_PEDIT_PARMS,
 	TCA_PEDIT_PAD,
+	TCA_PEDIT_PARMS_EX,
+	TCA_PEDIT_KEYS_EX,
+	TCA_PEDIT_KEY_EX,
 	__TCA_PEDIT_MAX
 };
 #define TCA_PEDIT_MAX (__TCA_PEDIT_MAX - 1)
                                                                                 
+enum {
+	TCA_PEDIT_KEY_EX_HTYPE = 1,
+	__TCA_PEDIT_KEY_EX_MAX
+};
+#define TCA_PEDIT_KEY_EX_MAX (__TCA_PEDIT_KEY_EX_MAX - 1)
+
+ /* TCA_PEDIT_KEY_EX_HDR_TYPE_NETWROK is a special case for legacy users. It
+  * means no specific header type - offset is relative to the network layer
+  */
+enum pedit_header_type {
+	TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK = 0,
+	TCA_PEDIT_KEY_EX_HDR_TYPE_ETH = 1,
+	TCA_PEDIT_KEY_EX_HDR_TYPE_IP4 = 2,
+	TCA_PEDIT_KEY_EX_HDR_TYPE_IP6 = 3,
+	TCA_PEDIT_KEY_EX_HDR_TYPE_TCP = 4,
+	TCA_PEDIT_KEY_EX_HDR_TYPE_UDP = 5,
+	__PEDIT_HDR_TYPE_MAX,
+};
+#define TCA_PEDIT_HDR_TYPE_MAX (__PEDIT_HDR_TYPE_MAX - 1)
+
 struct tc_pedit_key {
 	__u32           mask;  /* AND */
 	__u32           val;   /*XOR */
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index b27c4daec88f..fdd012bd3602 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -22,6 +22,7 @@
 #include <net/pkt_sched.h>
 #include <linux/tc_act/tc_pedit.h>
 #include <net/tc_act/tc_pedit.h>
+#include <uapi/linux/tc_act/tc_pedit.h>
 
 #define PEDIT_TAB_MASK	15
 
@@ -30,18 +31,112 @@ static struct tc_action_ops act_pedit_ops;
 
 static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 	[TCA_PEDIT_PARMS]	= { .len = sizeof(struct tc_pedit) },
+	[TCA_PEDIT_KEYS_EX]   = { .type = NLA_NESTED },
 };
 
+static const struct nla_policy pedit_key_ex_policy[TCA_PEDIT_KEY_EX_MAX + 1] = {
+	[TCA_PEDIT_KEY_EX_HTYPE]  = { .type = NLA_U16 },
+};
+
+static struct tcf_pedit_key_ex *tcf_pedit_keys_ex_parse(struct nlattr *nla,
+							u8 n)
+{
+	struct tcf_pedit_key_ex *keys_ex;
+	struct tcf_pedit_key_ex *k;
+	const struct nlattr *ka;
+	int err = -EINVAL;
+	int rem;
+
+	if (!nla || !n)
+		return NULL;
+
+	keys_ex = kcalloc(n, sizeof(*k), GFP_KERNEL);
+	if (!keys_ex)
+		return ERR_PTR(-ENOMEM);
+
+	k = keys_ex;
+
+	nla_for_each_nested(ka, nla, rem) {
+		struct nlattr *tb[TCA_PEDIT_KEY_EX_MAX + 1];
+
+		if (!n) {
+			err = -EINVAL;
+			goto err_out;
+		}
+		n--;
+
+		if (nla_type(ka) != TCA_PEDIT_KEY_EX) {
+			err = -EINVAL;
+			goto err_out;
+		}
+
+		err = nla_parse_nested(tb, TCA_PEDIT_KEY_EX_MAX, ka,
+				       pedit_key_ex_policy);
+		if (err)
+			goto err_out;
+
+		if (!tb[TCA_PEDIT_KEY_EX_HTYPE]) {
+			err = -EINVAL;
+			goto err_out;
+		}
+
+		k->htype = nla_get_u16(tb[TCA_PEDIT_KEY_EX_HTYPE]);
+
+		if (k->htype > TCA_PEDIT_HDR_TYPE_MAX) {
+			err = -EINVAL;
+			goto err_out;
+		}
+
+		k++;
+	}
+
+	if (n)
+		goto err_out;
+
+	return keys_ex;
+
+err_out:
+	kfree(keys_ex);
+	return ERR_PTR(err);
+}
+
+static int tcf_pedit_key_ex_dump(struct sk_buff *skb,
+				 struct tcf_pedit_key_ex *keys_ex, int n)
+{
+	struct nlattr *keys_start = nla_nest_start(skb, TCA_PEDIT_KEYS_EX);
+
+	for (; n > 0; n--) {
+		struct nlattr *key_start;
+
+		key_start = nla_nest_start(skb, TCA_PEDIT_KEY_EX);
+
+		if (nla_put_u16(skb, TCA_PEDIT_KEY_EX_HTYPE, keys_ex->htype)) {
+			nlmsg_trim(skb, keys_start);
+			return -EINVAL;
+		}
+
+		nla_nest_end(skb, key_start);
+
+		keys_ex++;
+	}
+
+	nla_nest_end(skb, keys_start);
+
+	return 0;
+}
+
 static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 			  struct nlattr *est, struct tc_action **a,
 			  int ovr, int bind)
 {
 	struct tc_action_net *tn = net_generic(net, pedit_net_id);
 	struct nlattr *tb[TCA_PEDIT_MAX + 1];
+	struct nlattr *pattr;
 	struct tc_pedit *parm;
 	int ret = 0, err;
 	struct tcf_pedit *p;
 	struct tc_pedit_key *keys = NULL;
+	struct tcf_pedit_key_ex *keys_ex;
 	int ksize;
 
 	if (nla == NULL)
@@ -51,13 +146,21 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 	if (err < 0)
 		return err;
 
-	if (tb[TCA_PEDIT_PARMS] == NULL)
+	pattr = tb[TCA_PEDIT_PARMS];
+	if (!pattr)
+		pattr = tb[TCA_PEDIT_PARMS_EX];
+	if (!pattr)
 		return -EINVAL;
-	parm = nla_data(tb[TCA_PEDIT_PARMS]);
+
+	parm = nla_data(pattr);
 	ksize = parm->nkeys * sizeof(struct tc_pedit_key);
-	if (nla_len(tb[TCA_PEDIT_PARMS]) < sizeof(*parm) + ksize)
+	if (nla_len(pattr) < sizeof(*parm) + ksize)
 		return -EINVAL;
 
+	keys_ex = tcf_pedit_keys_ex_parse(tb[TCA_PEDIT_KEYS_EX], parm->nkeys);
+	if (IS_ERR(keys_ex))
+		return PTR_ERR(keys_ex);
+
 	if (!tcf_hash_check(tn, parm->index, a, bind)) {
 		if (!parm->nkeys)
 			return -EINVAL;
@@ -69,6 +172,7 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		keys = kmalloc(ksize, GFP_KERNEL);
 		if (keys == NULL) {
 			tcf_hash_cleanup(*a, est);
+			kfree(keys_ex);
 			return -ENOMEM;
 		}
 		ret = ACT_P_CREATED;
@@ -81,8 +185,10 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		p = to_pedit(*a);
 		if (p->tcfp_nkeys && p->tcfp_nkeys != parm->nkeys) {
 			keys = kmalloc(ksize, GFP_KERNEL);
-			if (keys == NULL)
+			if (!keys) {
+				kfree(keys_ex);
 				return -ENOMEM;
+			}
 		}
 	}
 
@@ -95,6 +201,10 @@ static int tcf_pedit_init(struct net *net, struct nlattr *nla,
 		p->tcfp_nkeys = parm->nkeys;
 	}
 	memcpy(p->tcfp_keys, parm->keys, ksize);
+
+	kfree(p->tcfp_keys_ex);
+	p->tcfp_keys_ex = keys_ex;
+
 	spin_unlock_bh(&p->tcf_lock);
 	if (ret == ACT_P_CREATED)
 		tcf_hash_insert(tn, *a);
@@ -106,6 +216,7 @@ static void tcf_pedit_cleanup(struct tc_action *a, int bind)
 	struct tcf_pedit *p = to_pedit(a);
 	struct tc_pedit_key *keys = p->tcfp_keys;
 	kfree(keys);
+	kfree(p->tcfp_keys_ex);
 }
 
 static bool offset_valid(struct sk_buff *skb, int offset)
@@ -119,38 +230,84 @@ static bool offset_valid(struct sk_buff *skb, int offset)
 	return true;
 }
 
+static int pedit_skb_hdr_offset(struct sk_buff *skb,
+				enum pedit_header_type htype, int *hoffset)
+{
+	int ret = -EINVAL;
+
+	switch (htype) {
+	case TCA_PEDIT_KEY_EX_HDR_TYPE_ETH:
+		if (skb_mac_header_was_set(skb)) {
+			*hoffset = skb_mac_offset(skb);
+			ret = 0;
+		}
+		break;
+	case TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK:
+	case TCA_PEDIT_KEY_EX_HDR_TYPE_IP4:
+	case TCA_PEDIT_KEY_EX_HDR_TYPE_IP6:
+		*hoffset = skb_network_offset(skb);
+		ret = 0;
+		break;
+	case TCA_PEDIT_KEY_EX_HDR_TYPE_TCP:
+	case TCA_PEDIT_KEY_EX_HDR_TYPE_UDP:
+		if (skb_transport_header_was_set(skb)) {
+			*hoffset = skb_transport_offset(skb);
+			ret = 0;
+		}
+		break;
+	default:
+		ret = -EINVAL;
+		break;
+	};
+
+	return ret;
+}
+
 static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		     struct tcf_result *res)
 {
 	struct tcf_pedit *p = to_pedit(a);
 	int i;
-	unsigned int off;
 
 	if (skb_unclone(skb, GFP_ATOMIC))
 		return p->tcf_action;
 
-	off = skb_network_offset(skb);
-
 	spin_lock(&p->tcf_lock);
 
 	tcf_lastuse_update(&p->tcf_tm);
 
 	if (p->tcfp_nkeys > 0) {
 		struct tc_pedit_key *tkey = p->tcfp_keys;
+		struct tcf_pedit_key_ex *tkey_ex = p->tcfp_keys_ex;
+		enum pedit_header_type htype = TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK;
 
 		for (i = p->tcfp_nkeys; i > 0; i--, tkey++) {
 			u32 *ptr, _data;
 			int offset = tkey->off;
+			int hoffset;
+			int rc;
+
+			if (tkey_ex) {
+				htype = tkey_ex->htype;
+				tkey_ex++;
+			}
+
+			rc = pedit_skb_hdr_offset(skb, htype, &hoffset);
+			if (rc) {
+				pr_info("tc filter pedit bad header type specified (0x%x)\n",
+					htype);
+				goto bad;
+			}
 
 			if (tkey->offmask) {
 				char *d, _d;
 
-				if (!offset_valid(skb, off + tkey->at)) {
+				if (!offset_valid(skb, hoffset + tkey->at)) {
 					pr_info("tc filter pedit 'at' offset %d out of bounds\n",
-						off + tkey->at);
+						hoffset + tkey->at);
 					goto bad;
 				}
-				d = skb_header_pointer(skb, off + tkey->at, 1,
+				d = skb_header_pointer(skb, hoffset + tkey->at, 1,
 						       &_d);
 				if (!d)
 					goto bad;
@@ -163,19 +320,19 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 				goto bad;
 			}
 
-			if (!offset_valid(skb, off + offset)) {
+			if (!offset_valid(skb, hoffset + offset)) {
 				pr_info("tc filter pedit offset %d out of bounds\n",
-					offset);
+					hoffset + offset);
 				goto bad;
 			}
 
-			ptr = skb_header_pointer(skb, off + offset, 4, &_data);
+			ptr = skb_header_pointer(skb, hoffset + offset, 4, &_data);
 			if (!ptr)
 				goto bad;
 			/* just do it, baby */
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
 			if (ptr == &_data)
-				skb_store_bits(skb, off + offset, ptr, 4);
+				skb_store_bits(skb, hoffset + offset, ptr, 4);
 		}
 
 		goto done;
@@ -215,8 +372,15 @@ static int tcf_pedit_dump(struct sk_buff *skb, struct tc_action *a,
 	opt->refcnt = p->tcf_refcnt - ref;
 	opt->bindcnt = p->tcf_bindcnt - bind;
 
-	if (nla_put(skb, TCA_PEDIT_PARMS, s, opt))
-		goto nla_put_failure;
+	if (p->tcfp_keys_ex) {
+		tcf_pedit_key_ex_dump(skb, p->tcfp_keys_ex, p->tcfp_nkeys);
+
+		if (nla_put(skb, TCA_PEDIT_PARMS_EX, s, opt))
+			goto nla_put_failure;
+	} else {
+		if (nla_put(skb, TCA_PEDIT_PARMS, s, opt))
+			goto nla_put_failure;
+	}
 
 	tcf_tm_dump(&t, &p->tcf_tm);
 	if (nla_put_64bit(skb, TCA_PEDIT_TM, sizeof(t), &t, TCA_PEDIT_PAD))
-- 
2.11.0
