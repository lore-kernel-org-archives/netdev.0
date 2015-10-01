From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 7/7] openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT
Date: Thu,  1 Oct 2015 13:53:30 -0700
Message-ID: <1443732810-38746-8-git-send-email-joestringer@nicira.com>
References: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Previously, the CT_ATTR_FLAGS attribute, when nested under the
OVS_ACTION_ATTR_CT, encoded a 32-bit bitmask of flags that modify the
semantics of the ct action. It's more extensible to just represent each
flag as a nested attribute, and this requires no additional error
checking to reject flags that aren't currently supported.

Suggested-by: Ben Pfaff <blp@nicira.com>
Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
v2: Use bitmask for internal representation of COMMIT.
---
 include/uapi/linux/openvswitch.h | 14 ++++----------
 net/openvswitch/conntrack.c      | 13 ++++++-------
 2 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/include/uapi/linux/openvswitch.h b/include/uapi/linux/openvswitch.h
index c861a4cf..036f73b 100644
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
index 466d557..80bf702 100644
--- a/net/openvswitch/conntrack.c
+++ b/net/openvswitch/conntrack.c
@@ -47,7 +47,7 @@ struct ovs_conntrack_info {
 	struct nf_conntrack_helper *helper;
 	struct nf_conntrack_zone zone;
 	struct nf_conn *ct;
-	u32 flags;
+	u8 commit : 1;
 	u16 family;
 	struct md_mark mark;
 	struct md_labels labels;
@@ -493,7 +493,7 @@ int ovs_ct_execute(struct net *net, struct sk_buff *skb,
 			return err;
 	}
 
-	if (info->flags & OVS_CT_F_COMMIT)
+	if (info->commit)
 		err = ovs_ct_commit(net, key, info, skb);
 	else
 		err = ovs_ct_lookup(net, key, info, skb);
@@ -539,8 +539,7 @@ static int ovs_ct_add_helper(struct ovs_conntrack_info *info, const char *name,
 }
 
 static const struct ovs_ct_len_tbl ovs_ct_attr_lens[OVS_CT_ATTR_MAX + 1] = {
-	[OVS_CT_ATTR_FLAGS]	= { .minlen = sizeof(u32),
-				    .maxlen = sizeof(u32) },
+	[OVS_CT_ATTR_COMMIT]	= { .minlen = 0, .maxlen = 0 },
 	[OVS_CT_ATTR_ZONE]	= { .minlen = sizeof(u16),
 				    .maxlen = sizeof(u16) },
 	[OVS_CT_ATTR_MARK]	= { .minlen = sizeof(struct md_mark),
@@ -576,8 +575,8 @@ static int parse_ct(const struct nlattr *attr, struct ovs_conntrack_info *info,
 		}
 
 		switch (type) {
-		case OVS_CT_ATTR_FLAGS:
-			info->flags = nla_get_u32(a);
+		case OVS_CT_ATTR_COMMIT:
+			info->commit = true;
 			break;
 #ifdef CONFIG_NF_CONNTRACK_ZONES
 		case OVS_CT_ATTR_ZONE:
@@ -701,7 +700,7 @@ int ovs_ct_action_to_attr(const struct ovs_conntrack_info *ct_info,
 	if (!start)
 		return -EMSGSIZE;
 
-	if (nla_put_u32(skb, OVS_CT_ATTR_FLAGS, ct_info->flags))
+	if (ct_info->commit && nla_put_flag(skb, OVS_CT_ATTR_COMMIT))
 		return -EMSGSIZE;
 	if (IS_ENABLED(CONFIG_NF_CONNTRACK_ZONES) &&
 	    nla_put_u16(skb, OVS_CT_ATTR_ZONE, ct_info->zone.id))
-- 
2.1.4
