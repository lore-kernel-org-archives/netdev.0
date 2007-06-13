From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN 17/18]: Introduce symbolic constants for flag values
Date: Wed, 13 Jun 2007 18:51:05 +0200 (MEST)
Message-ID: <20070613165102.7780.57723.sendpatchset@localhost.localdomain>
References: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:35947 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759272AbXFMQvG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jun 2007 12:51:06 -0400
In-Reply-To: <20070613165039.7780.15855.sendpatchset@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[VLAN]: Introduce symbolic constants for flag values

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 84bb1e021b6c3567bebccfc5e3dd4ab7d8f5bfae
tree 74f71648d2821cc86765694a7d41d94b39bffce4
parent fc3fa5f1275ec357ae719066eef18c51c186c2b9
author Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:33 +0200
committer Patrick McHardy <kaber@trash.net> Wed, 13 Jun 2007 18:10:33 +0200

 include/linux/if_vlan.h |    4 ++++
 net/8021q/vlan.c        |    2 +-
 net/8021q/vlan_dev.c    |   13 +++++++------
 3 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/if_vlan.h b/include/linux/if_vlan.h
index b46d422..c791287 100644
--- a/include/linux/if_vlan.h
+++ b/include/linux/if_vlan.h
@@ -398,6 +398,10 @@ enum vlan_ioctl_cmds {
 	GET_VLAN_VID_CMD /* Get the VID of this VLAN (specified by name) */
 };
 
+enum vlan_flags {
+	VLAN_FLAG_REORDER_HDR	= 0x1,
+};
+
 enum vlan_name_types {
 	VLAN_NAME_TYPE_PLUS_VID, /* Name will look like:  vlan0005 */
 	VLAN_NAME_TYPE_RAW_PLUS_VID, /* name will look like:  eth1.0005 */
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 5801993..f12f914 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -565,7 +565,7 @@ static int register_vlan_device(struct net_device *real_dev,
 	VLAN_DEV_INFO(new_dev)->vlan_id = VLAN_ID; /* 1 through VLAN_VID_MASK */
 	VLAN_DEV_INFO(new_dev)->real_dev = real_dev;
 	VLAN_DEV_INFO(new_dev)->dent = NULL;
-	VLAN_DEV_INFO(new_dev)->flags = 1;
+	VLAN_DEV_INFO(new_dev)->flags = VLAN_FLAG_REORDER_HDR;
 
 	err = register_vlan_dev(new_dev);
 	if (err < 0)
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4f6ede7..95afe38 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -73,7 +73,7 @@ int vlan_dev_rebuild_header(struct sk_buff *skb)
 
 static inline struct sk_buff *vlan_check_reorder_header(struct sk_buff *skb)
 {
-	if (VLAN_DEV_INFO(skb->dev)->flags & 1) {
+	if (VLAN_DEV_INFO(skb->dev)->flags & VLAN_FLAG_REORDER_HDR) {
 		if (skb_shared(skb) || skb_cloned(skb)) {
 			struct sk_buff *nskb = skb_copy(skb, GFP_ATOMIC);
 			kfree_skb(skb);
@@ -350,7 +350,8 @@ int vlan_dev_hard_header(struct sk_buff *skb, struct net_device *dev,
 	 * header shuffling in the hard_start_xmit.  Users can turn off this
 	 * REORDER behaviour with the vconfig tool.
 	 */
-	build_vlan_header = ((VLAN_DEV_INFO(dev)->flags & 1) == 0);
+	if (!(VLAN_DEV_INFO(dev)->flags & VLAN_FLAG_REORDER_HDR))
+		build_vlan_header = 1;
 
 	if (build_vlan_header) {
 		vhdr = (struct vlan_hdr *) skb_push(skb, VLAN_HLEN);
@@ -584,16 +585,16 @@ int vlan_dev_set_egress_priority(const struct net_device *dev,
 	return 0;
 }
 
-/* Flags are defined in the vlan_dev_info class in include/linux/if_vlan.h file. */
+/* Flags are defined in the vlan_flags enum in include/linux/if_vlan.h file. */
 int vlan_dev_set_vlan_flag(const struct net_device *dev,
 			   u32 flag, short flag_val)
 {
 	/* verify flag is supported */
-	if (flag == 1) {
+	if (flag == VLAN_FLAG_REORDER_HDR) {
 		if (flag_val) {
-			VLAN_DEV_INFO(dev)->flags |= 1;
+			VLAN_DEV_INFO(dev)->flags |= VLAN_FLAG_REORDER_HDR;
 		} else {
-			VLAN_DEV_INFO(dev)->flags &= ~1;
+			VLAN_DEV_INFO(dev)->flags &= ~VLAN_FLAG_REORDER_HDR;
 		}
 		return 0;
 	}
