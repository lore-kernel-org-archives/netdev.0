From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V3 3/3] net/act_pedit: Introduce 'add' operation
Date: Tue,  7 Feb 2017 09:56:08 +0200
Message-ID: <20170207075608.8430-4-amir@vadai.me>
References: <20170207075608.8430-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:33091 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753147AbdBGH4a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2017 02:56:30 -0500
Received: by mail-wm0-f66.google.com with SMTP id v77so26601195wmv.0
        for <netdev@vger.kernel.org>; Mon, 06 Feb 2017 23:56:29 -0800 (PST)
In-Reply-To: <20170207075608.8430-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command could be useful to inc/dec fields.

For example, to forward any TCP packet and decrease its TTL:
$ tc filter add dev enp0s9 protocol ip parent ffff: \
    flower ip_proto tcp \
    action pedit munge ip ttl add 0xff pipe \
    action mirred egress redirect dev veth0

In the example above, adding 0xff to this u8 field is actually
decreasing it by one, since the operation is masked.

Signed-off-by: Amir Vadai <amir@vadai.me>
Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 include/net/tc_act/tc_pedit.h        |  1 +
 include/uapi/linux/tc_act/tc_pedit.h |  8 ++++++++
 net/sched/act_pedit.c                | 30 ++++++++++++++++++++++++++----
 3 files changed, 35 insertions(+), 4 deletions(-)

diff --git a/include/net/tc_act/tc_pedit.h b/include/net/tc_act/tc_pedit.h
index e076f22035a5..dfbd6ee0bc7c 100644
--- a/include/net/tc_act/tc_pedit.h
+++ b/include/net/tc_act/tc_pedit.h
@@ -5,6 +5,7 @@
 
 struct tcf_pedit_key_ex {
 	enum pedit_header_type htype;
+	enum pedit_cmd cmd;
 };
 
 struct tcf_pedit {
diff --git a/include/uapi/linux/tc_act/tc_pedit.h b/include/uapi/linux/tc_act/tc_pedit.h
index 22f19eeda997..143d2b31a316 100644
--- a/include/uapi/linux/tc_act/tc_pedit.h
+++ b/include/uapi/linux/tc_act/tc_pedit.h
@@ -20,6 +20,7 @@ enum {
                                                                                 
 enum {
 	TCA_PEDIT_KEY_EX_HTYPE = 1,
+	TCA_PEDIT_KEY_EX_CMD = 2,
 	__TCA_PEDIT_KEY_EX_MAX
 };
 #define TCA_PEDIT_KEY_EX_MAX (__TCA_PEDIT_KEY_EX_MAX - 1)
@@ -38,6 +39,13 @@ enum pedit_header_type {
 };
 #define TCA_PEDIT_HDR_TYPE_MAX (__PEDIT_HDR_TYPE_MAX - 1)
 
+enum pedit_cmd {
+	TCA_PEDIT_KEY_EX_CMD_SET = 0,
+	TCA_PEDIT_KEY_EX_CMD_ADD = 1,
+	__PEDIT_CMD_MAX,
+};
+#define TCA_PEDIT_CMD_MAX (__PEDIT_CMD_MAX - 1)
+
 struct tc_pedit_key {
 	__u32           mask;  /* AND */
 	__u32           val;   /*XOR */
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index fdd012bd3602..c1310472f620 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -36,6 +36,7 @@ static const struct nla_policy pedit_policy[TCA_PEDIT_MAX + 1] = {
 
 static const struct nla_policy pedit_key_ex_policy[TCA_PEDIT_KEY_EX_MAX + 1] = {
 	[TCA_PEDIT_KEY_EX_HTYPE]  = { .type = NLA_U16 },
+	[TCA_PEDIT_KEY_EX_CMD]	  = { .type = NLA_U16 },
 };
 
 static struct tcf_pedit_key_ex *tcf_pedit_keys_ex_parse(struct nlattr *nla,
@@ -75,14 +76,17 @@ static struct tcf_pedit_key_ex *tcf_pedit_keys_ex_parse(struct nlattr *nla,
 		if (err)
 			goto err_out;
 
-		if (!tb[TCA_PEDIT_KEY_EX_HTYPE]) {
+		if (!tb[TCA_PEDIT_KEY_EX_HTYPE] ||
+		    !tb[TCA_PEDIT_KEY_EX_CMD]) {
 			err = -EINVAL;
 			goto err_out;
 		}
 
 		k->htype = nla_get_u16(tb[TCA_PEDIT_KEY_EX_HTYPE]);
+		k->cmd = nla_get_u16(tb[TCA_PEDIT_KEY_EX_CMD]);
 
-		if (k->htype > TCA_PEDIT_HDR_TYPE_MAX) {
+		if (k->htype > TCA_PEDIT_HDR_TYPE_MAX ||
+		    k->cmd > TCA_PEDIT_CMD_MAX) {
 			err = -EINVAL;
 			goto err_out;
 		}
@@ -110,7 +114,8 @@ static int tcf_pedit_key_ex_dump(struct sk_buff *skb,
 
 		key_start = nla_nest_start(skb, TCA_PEDIT_KEY_EX);
 
-		if (nla_put_u16(skb, TCA_PEDIT_KEY_EX_HTYPE, keys_ex->htype)) {
+		if (nla_put_u16(skb, TCA_PEDIT_KEY_EX_HTYPE, keys_ex->htype) ||
+		    nla_put_u16(skb, TCA_PEDIT_KEY_EX_CMD, keys_ex->cmd)) {
 			nlmsg_trim(skb, keys_start);
 			return -EINVAL;
 		}
@@ -280,15 +285,19 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		struct tc_pedit_key *tkey = p->tcfp_keys;
 		struct tcf_pedit_key_ex *tkey_ex = p->tcfp_keys_ex;
 		enum pedit_header_type htype = TCA_PEDIT_KEY_EX_HDR_TYPE_NETWORK;
+		enum pedit_cmd cmd = TCA_PEDIT_KEY_EX_CMD_SET;
 
 		for (i = p->tcfp_nkeys; i > 0; i--, tkey++) {
 			u32 *ptr, _data;
 			int offset = tkey->off;
 			int hoffset;
+			u32 val;
 			int rc;
 
 			if (tkey_ex) {
 				htype = tkey_ex->htype;
+				cmd = tkey_ex->cmd;
+
 				tkey_ex++;
 			}
 
@@ -330,7 +339,20 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 			if (!ptr)
 				goto bad;
 			/* just do it, baby */
-			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
+			switch (cmd) {
+			case TCA_PEDIT_KEY_EX_CMD_SET:
+				val = tkey->val;
+				break;
+			case TCA_PEDIT_KEY_EX_CMD_ADD:
+				val = (*ptr + tkey->val) & ~tkey->mask;
+				break;
+			default:
+				pr_info("tc filter pedit bad command (%d)\n",
+					cmd);
+				goto bad;
+			}
+
+			*ptr = ((*ptr & tkey->mask) ^ val);
 			if (ptr == &_data)
 				skb_store_bits(skb, hoffset + offset, ptr, 4);
 		}
-- 
2.11.0
