From: Amir Vadai <amir@vadai.me>
Subject: [PATCH net-next V2 2/3] net/act_pedit: Support using offset relative to the conventional network headers
Date: Thu,  5 Jan 2017 11:54:53 +0200
Message-ID: <20170105095454.32644-3-amir@vadai.me>
References: <20170105095454.32644-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, Jiri Pirko <jiri@mellanox.com>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Amir Vadai <amir@vadai.me>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36008 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760457AbdAEJzV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Jan 2017 04:55:21 -0500
Received: by mail-wj0-f196.google.com with SMTP id j10so78640387wjb.3
        for <netdev@vger.kernel.org>; Thu, 05 Jan 2017 01:55:15 -0800 (PST)
In-Reply-To: <20170105095454.32644-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend pedit to enable the user setting offset relative to network
headers. This change would enable to work with more complex header
schemes (vs the simple IPv4 case) where setting a fixed offset relative
to the network header is not enough. It is also forward looking to
enable hardware offloading of pedit.

The header type is embedded in the 8 MSB of the u32 key->shift which
were never used till now. Therefore backward compatibility is being
kept.

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
 include/uapi/linux/tc_act/tc_pedit.h | 17 ++++++++++
 net/sched/act_pedit.c                | 65 +++++++++++++++++++++++++++++-------
 2 files changed, 70 insertions(+), 12 deletions(-)

diff --git a/include/uapi/linux/tc_act/tc_pedit.h b/include/uapi/linux/tc_act/tc_pedit.h
index 6389959a5157..604e6729ad38 100644
--- a/include/uapi/linux/tc_act/tc_pedit.h
+++ b/include/uapi/linux/tc_act/tc_pedit.h
@@ -32,4 +32,21 @@ struct tc_pedit_sel {
 };
 #define tc_pedit tc_pedit_sel
 
+#define PEDIT_TYPE_SHIFT 24
+#define PEDIT_TYPE_MASK 0xff
+
+#define PEDIT_TYPE_GET(_val) \
+	(((_val) >> PEDIT_TYPE_SHIFT) & PEDIT_TYPE_MASK)
+#define PEDIT_SHIFT_GET(_val) ((_val) & 0xff)
+
+enum pedit_header_type {
+	PEDIT_HDR_TYPE_RAW = 0,
+
+	PEDIT_HDR_TYPE_ETH = 1,
+	PEDIT_HDR_TYPE_IP4 = 2,
+	PEDIT_HDR_TYPE_IP6 = 3,
+	PEDIT_HDR_TYPE_TCP = 4,
+	PEDIT_HDR_TYPE_UDP = 5,
+};
+
 #endif
diff --git a/net/sched/act_pedit.c b/net/sched/act_pedit.c
index b27c4daec88f..4b9c7184c752 100644
--- a/net/sched/act_pedit.c
+++ b/net/sched/act_pedit.c
@@ -119,18 +119,45 @@ static bool offset_valid(struct sk_buff *skb, int offset)
 	return true;
 }
 
+static int pedit_skb_hdr_offset(struct sk_buff *skb,
+				enum pedit_header_type htype, int *hoffset)
+{
+	int ret = -1;
+
+	switch (htype) {
+	case PEDIT_HDR_TYPE_ETH:
+		if (skb_mac_header_was_set(skb)) {
+			*hoffset = skb_mac_offset(skb);
+			ret = 0;
+		}
+		break;
+	case PEDIT_HDR_TYPE_RAW:
+	case PEDIT_HDR_TYPE_IP4:
+	case PEDIT_HDR_TYPE_IP6:
+		*hoffset = skb_network_offset(skb);
+		ret = 0;
+		break;
+	case PEDIT_HDR_TYPE_TCP:
+	case PEDIT_HDR_TYPE_UDP:
+		if (skb_transport_header_was_set(skb)) {
+			*hoffset = skb_transport_offset(skb);
+			ret = 0;
+		}
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
@@ -141,20 +168,32 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
 		for (i = p->tcfp_nkeys; i > 0; i--, tkey++) {
 			u32 *ptr, _data;
 			int offset = tkey->off;
+			int hoffset;
+			int rc;
+			enum pedit_header_type htype =
+				PEDIT_TYPE_GET(tkey->shift);
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
-						       &_d);
+				d = skb_header_pointer(skb,
+						       hoffset + tkey->at,
+						       1, &_d);
 				if (!d)
 					goto bad;
-				offset += (*d & tkey->offmask) >> tkey->shift;
+				offset += (*d & tkey->offmask) >> PEDIT_SHIFT_GET(tkey->shift);
 			}
 
 			if (offset % 4) {
@@ -163,19 +202,21 @@ static int tcf_pedit(struct sk_buff *skb, const struct tc_action *a,
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
+			ptr = skb_header_pointer(skb,
+						 hoffset + offset,
+						 4, &_data);
 			if (!ptr)
 				goto bad;
 			/* just do it, baby */
 			*ptr = ((*ptr & tkey->mask) ^ tkey->val);
 			if (ptr == &_data)
-				skb_store_bits(skb, off + offset, ptr, 4);
+				skb_store_bits(skb, hoffset + offset, ptr, 4);
 		}
 
 		goto done;
-- 
2.11.0
