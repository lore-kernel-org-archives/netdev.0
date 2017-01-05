From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 3/3] net/act_pedit: Introduce 'add' operation
Date: Thu,  5 Jan 2017 11:54:54 +0200
Message-ID: <20170105095454.32644-4-amir@vadai.me>
References: <20170105095454.32644-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:33217 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760523AbdAEJzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 04:55:21 -0500
Received: by mail-wm0-f65.google.com with SMTP id u144so95568945wmu.0
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 01:55:17 -0800 (PST)
In-Reply-To: <20170105095454.32644-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This command could be useful to inc/dec fields.
Command type is embedded inside the existing shift field in an unused
bits, therefore UAPI backward compatibility is being kept.

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
 include/uapi/linux/tc_act/tc_pedit.h | 10 ++++++++++
 net/sched/act_pedit.c                | 16 +++++++++++++++-
 2 files changed, 25 insertions(+), 1 deletion(-)

diff --git a/include/uapi/linux/tc_act/tc_pedit.h b/include/uapi/linux/tc_act/tc_pedit.h
index 604e6729ad38..80028cd0bb1b 100644
--- a/include/uapi/linux/tc_act/tc_pedit.h
+++ b/include/uapi/linux/tc_act/tc_pedit.h
@@ -35,8 +35,13 @@ struct tc_pedit_sel {
 #define PEDIT_TYPE_SHIFT 24
 #define PEDIT_TYPE_MASK 0xff
 
+#define PEDIT_CMD_SHIFT 16
+#define PEDIT_CMD_MASK 0xff
+
 #define PEDIT_TYPE_GET(_val) \
 	(((_val) >> PEDIT_TYPE_SHIFT) & PEDIT_TYPE_MASK)
+#define PEDIT_CMD_GET(_val) \
+	(((_val) >> PEDIT_CMD_SHIFT) & PEDIT_CMD_MASK)
 #define PEDIT_SHIFT_GET(_val) ((_val) & 0xff)
 
 enum pedit_header_type {
@@ -49,4 +54,9 @@ enum pedit_header_type {
 	PEDIT_HDR_TYPE_UDP = 5,
 };
 
+enum pedit_cmd {
+	PEDIT_CMD_SET = 0,
+	PEDIT_CMD_ADD = 1,
+};
+
 #endif
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index 4b9c7184c752..aa137d51bf7f 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -169,6 +169,7 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 			u32 *ptr, _data;
 			int offset = tkey->off;
 			int hoffset;
+			u32 val;
 			int rc;
 			enum pedit_header_type htype =
 				PEDIT_TYPE_GET(tkey->shift);
@@ -214,7 +215,20 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 			if (!ptr)
 				goto bad;
 			/* just do it, baby */
-			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
+			switch (PEDIT_CMD_GET(tkey->shift)) {
+			case PEDIT_CMD_SET:
+				val = tkey->val;
+				break;
+			case PEDIT_CMD_ADD:
+				val = (*ptr + tkey->val) & ~tkey->mask;
+				break;
+			default:
+				pr_info("tc filter pedit bad command (%d)\n",
+					PEDIT_CMD_GET(tkey->shift));
+				goto bad;
+			}
+
+			*ptr = ((*ptr & tkey->mask) ^ val);
 			if (ptr == &_data)
 				skb_store_bits(skb, hoffset + offset, ptr, 4);
 		}
-- 
2.11.0
