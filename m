From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 7/7] openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT
Date: Tue, 29 Sep 2015 15:39:40 -0700
Message-ID: <1443566380-22640-8-git-send-email-joestringer@nicira.com>
References: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:33616 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751474AbbI2WkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:40:06 -0400
Received: by pacex6 with SMTP id ex6so18500525pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:40:05 -0700 (PDT)
In-Reply-To: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Previously, the CT_ATTR_FLAGS attribute, when nested under the
OVS_ACTION_ATTR_CT, encoded a 32-bit bitmask of flags that modify the
semantics of the ct action. It's more extensible to just represent each
flag as a nested attribute, and this requires no additional error
checking to reject flags that aren't currently supported.

Suggested-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
 include/uapi/linux/openvswitch.h | 14 ++++----------
 net/openvswitch/conntrack.c      | 20 +++++++++++++-------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index f121af5..e14563e 100644
--- a/include/uapi/linux/openvswitch.h
+++ b/include/uapi/linux/openvswitch.h
@@ -618,7 +618,9 @@ struct ovs_action_hash {
 
 /**
  * enum ovs_ct_attr - Attributes for %OVS_ACTION_ATTR_CT action.
- * @OVS_CT_ATTR_FLAGS: u32 connection tracking flags.
+ * @OVS_CT_ATTR_COMMIT: If present, commits the connection to the conntrack
+ * table. This allows future packets for the same connection to be identified
+ * as 'established' or 'related'.
  * @OVS_CT_ATTR_ZONE: u16 connection tracking zone.
  * @OVS_CT_ATTR_MARK: u32 value followed by u32 mask. For each bit set in the
  * mask, the corresponding bit in the value is copied to the connection
@@ -630,7 +632,7 @@ struct ovs_action_hash {
  */
 enum ovs_ct_attr {
 	OVS_CT_ATTR_UNSPEC,
-	OVS_CT_ATTR_FLAGS,      /* u32 bitmask of OVS_CT_F_*. */
+	OVS_CT_ATTR_COMMIT,     /* No argument, commits connection. */
 	OVS_CT_ATTR_ZONE,       /* u16 zone id. */
 	OVS_CT_ATTR_MARK,       /* mark to associate with this connection. */
 	OVS_CT_ATTR_LABELS,     /* labels to associate with this connection. */
@@ -641,14 +643,6 @@ enum ovs_ct_attr {
 
 #define OVS_CT_ATTR_MAX (__OVS_CT_ATTR_MAX - 1)
 
-/*
- * OVS_CT_ATTR_FLAGS flags - bitmask of %OVS_CT_F_*
- * @OVS_CT_F_COMMIT: Commits the flow to the conntrack table. This allows
- * future packets for the same connection to be identified as 'established'
- * or 'related'.
- */
-#define OVS_CT_F_COMMIT		0x01
-
 /**
  * enum ovs_action_attr - Action types.
  *
diff --git a/net/openvswitch/conntrack.c b/net/openvswitch/conntrack.c
index 167cf43..effa78c 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -42,12 +42,18 @@ struct md_label {
 	struct ovs_key_ct_label mask;
 };
 
+/* Flags for performing connection tracking.
+ *
+ * CT_F_COMMIT: Commits the flow to the conntrack table.
+ */
+#define CT_F_COMMIT	BIT(0)
+
 /* Conntrack action context for execution. */
 struct ovs_conntrack_info {
 	struct nf_conntrack_helper *helper;
 	struct nf_conntrack_zone zone;
 	struct nf_conn *ct;
-	u32 flags;
+	u8 flags;		/* bitmask of CT_F_*. */
 	u16 family;
 	struct md_mark mark;
 	struct md_label label;
@@ -493,7 +499,7 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 			return err;
 	}
 
-	if (info->flags & OVS_CT_F_COMMIT)
+	if (info->flags & CT_F_COMMIT)
 		err = ovs_ct_commit(net, key, info, skb);
 	else
 		err = ovs_ct_lookup(net, key, info, skb);
@@ -539,8 +545,7 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
 }
 
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
-	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
-				    .maxlen = sizeof(u32) },
+	[OVS_CT_ATTR_COMMIT]	= { .minlen = 0, .maxlen = 0 },
 	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
 				    .maxlen = sizeof(u16) },
 	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
@@ -576,8 +581,8 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		}
 
 		switch (type) {
-		case OVS_CT_ATTR_FLAGS:
-			info->flags = nla_get_u32(a);
+		case OVS_CT_ATTR_COMMIT:
+			info->flags |= CT_F_COMMIT;
 			break;
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 		case OVS_CT_ATTR_ZONE:
@@ -701,7 +706,8 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	if (!start)
 		return -EMSGSIZE;
 
-	if (nla_put_u32(skb, OVS_CT_ATTR_FLAGS, ct_info->flags))
+	if (ct_info->flags & CT_F_COMMIT &&
+	    nla_put_flag(skb, OVS_CT_ATTR_COMMIT))
 		return -EMSGSIZE;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
 	    nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone.id))
-- 
2.1.4
