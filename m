From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 15/16] batman-adv: form groups in the bridge loop avoidance
Date: Sat,  7 Apr 2012 20:49:57 +0200
Message-ID: <1333824598-27771-16-git-send-email-ordex@autistici.org>
References: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:61275 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754683Ab2DGStn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2012 14:49:43 -0400
In-Reply-To: <1333824598-27771-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

backbone gateways may be part of the same LAN, but participate
in different meshes. With this patch, backbone gateways form groups by
applying the groupid of another backbone gateway if it is higher. After
forming the group, they only accept messages from backbone gateways of
the same group.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/bridge_loop_avoidance.c |  121 ++++++++++++++++++++++++++++++--
 net/batman-adv/types.h                 |    1 +
 2 files changed, 116 insertions(+), 6 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 4f6b44a..1cf18ac 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -33,7 +33,6 @@
 #include <net/arp.h>
 #include <linux/if_vlan.h>
 
-static const uint8_t claim_dest[6] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
 static const uint8_t announce_mac[4] = {0x43, 0x05, 0x43, 0x05};
 
 static void bla_periodic_work(struct work_struct *work);
@@ -265,7 +264,8 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 	if (!primary_if)
 		return;
 
-	memcpy(&local_claim_dest, claim_dest, sizeof(local_claim_dest));
+	memcpy(&local_claim_dest, &bat_priv->claim_dest,
+	       sizeof(local_claim_dest));
 	local_claim_dest.type = claimtype;
 
 	soft_iface = primary_if->soft_iface;
@@ -282,6 +282,7 @@ static void bla_send_claim(struct bat_priv *bat_priv, uint8_t *mac,
 			 primary_if->net_dev->dev_addr,
 			 /* HW DST: FF:43:05:XX:00:00
 			  * with XX   = claim type
+			  * and YY:YY = group id
 			  */
 			 (uint8_t *)&local_claim_dest);
 
@@ -734,6 +735,86 @@ static int handle_claim(struct bat_priv *bat_priv,
 
 /**
  * @bat_priv: the bat priv with all the soft interface information
+ * @bat_priv: the bat priv with all the soft interface information
+ * @hw_src: the Hardware source in the ARP Header
+ * @hw_dst: the Hardware destination in the ARP Header
+ * @ethhdr: pointer to the Ethernet header of the claim frame
+ *
+ * checks if it is a claim packet and if its on the same group.
+ * This function also applies the group ID of the sender
+ * if it is in the same mesh.
+ *
+ * returns:
+ *	2  - if it is a claim packet and on the same group
+ *	1  - if is a claim packet from another group
+ *	0  - if it is not a claim packet
+ */
+static int check_claim_group(struct bat_priv *bat_priv,
+			     struct hard_iface *primary_if,
+			     uint8_t *hw_src, uint8_t *hw_dst,
+			     struct ethhdr *ethhdr)
+{
+	uint8_t *backbone_addr;
+	struct orig_node *orig_node;
+	struct bla_claim_dst *bla_dst, *bla_dst_own;
+
+	bla_dst = (struct bla_claim_dst *)hw_dst;
+	bla_dst_own = &bat_priv->claim_dest;
+
+	/* check if it is a claim packet in general */
+	if (memcmp(bla_dst->magic, bla_dst_own->magic,
+		   sizeof(bla_dst->magic)) != 0)
+		return 0;
+
+	/* if announcement packet, use the source,
+	 * otherwise assume it is in the hw_src
+	 */
+	switch (bla_dst->type) {
+	case CLAIM_TYPE_ADD:
+		backbone_addr = hw_src;
+		break;
+	case CLAIM_TYPE_REQUEST:
+	case CLAIM_TYPE_ANNOUNCE:
+	case CLAIM_TYPE_DEL:
+		backbone_addr = ethhdr->h_source;
+		break;
+	default:
+		return 0;
+	}
+
+	/* don't accept claim frames from ourselves */
+	if (compare_eth(backbone_addr, primary_if->net_dev->dev_addr))
+		return 0;
+
+	/* if its already the same group, it is fine. */
+	if (bla_dst->group == bla_dst_own->group)
+		return 2;
+
+	/* lets see if this originator is in our mesh */
+	orig_node = orig_hash_find(bat_priv, backbone_addr);
+
+	/* dont accept claims from gateways which are not in
+	 * the same mesh or group.
+	 */
+	if (!orig_node)
+		return 1;
+
+	/* if our mesh friends mac is bigger, use it for ourselves. */
+	if (ntohs(bla_dst->group) > ntohs(bla_dst_own->group)) {
+		bat_dbg(DBG_BLA, bat_priv,
+			"taking other backbones claim group: %04x\n",
+			ntohs(bla_dst->group));
+		bla_dst_own->group = bla_dst->group;
+	}
+
+	orig_node_free_ref(orig_node);
+
+	return 2;
+}
+
+
+/**
+ * @bat_priv: the bat priv with all the soft interface information
  * @skb: the frame to be checked
  *
  * Check if this is a claim frame, and process it accordingly.
@@ -753,6 +834,7 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 	uint16_t proto;
 	int headlen;
 	short vid = -1;
+	int ret;
 
 	ethhdr = (struct ethhdr *)skb_mac_header(skb);
 
@@ -796,8 +878,14 @@ static int bla_process_claim(struct bat_priv *bat_priv,
 	bla_dst = (struct bla_claim_dst *)hw_dst;
 
 	/* check if it is a claim frame. */
-	if (memcmp(hw_dst, claim_dest, 3) != 0)
-		return 0;
+	ret = check_claim_group(bat_priv, primary_if, hw_src, hw_dst, ethhdr);
+	if (ret == 1)
+		bat_dbg(DBG_BLA, bat_priv,
+			"bla_process_claim(): received a claim frame from another group. From: %pM on vid %d ...(hw_src %pM, hw_dst %pM)\n",
+			ethhdr->h_source, vid, hw_src, hw_dst);
+
+	if (ret < 2)
+		return ret;
 
 	/* become a backbone gw ourselves on this vlan if not happened yet */
 	bla_update_own_backbone_gw(bat_priv, primary_if, vid);
@@ -944,6 +1032,10 @@ void bla_update_orig_address(struct bat_priv *bat_priv,
 	struct hashtable_t *hash;
 	int i;
 
+	/* reset bridge loop avoidance group id */
+	bat_priv->claim_dest.group =
+		htons(crc16(0, primary_if->net_dev->dev_addr, ETH_ALEN));
+
 	if (!oldif) {
 		bla_purge_claims(bat_priv, NULL, 1);
 		bla_purge_backbone_gw(bat_priv, 1);
@@ -1042,9 +1134,24 @@ out:
 int bla_init(struct bat_priv *bat_priv)
 {
 	int i;
+	uint8_t claim_dest[ETH_ALEN] = {0xff, 0x43, 0x05, 0x00, 0x00, 0x00};
+	struct hard_iface *primary_if;
 
 	bat_dbg(DBG_BLA, bat_priv, "bla hash registering\n");
 
+	/* setting claim destination address */
+	memcpy(&bat_priv->claim_dest.magic, claim_dest, 3);
+	bat_priv->claim_dest.type = 0;
+	primary_if = primary_if_get_selected(bat_priv);
+	if (primary_if) {
+		bat_priv->claim_dest.group =
+			htons(crc16(0, primary_if->net_dev->dev_addr,
+				    ETH_ALEN));
+		hardif_free_ref(primary_if);
+	} else {
+		bat_priv->claim_dest.group = 0; /* will be set later */
+	}
+
 	/* initialize the duplicate list */
 	for (i = 0; i < DUPLIST_SIZE; i++)
 		bat_priv->bcast_duplist[i].entrytime =
@@ -1448,8 +1555,10 @@ int bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 		goto out;
 	}
 
-	seq_printf(seq, "Claims announced for the mesh %s (orig %pM)\n",
-		   net_dev->name, primary_if->net_dev->dev_addr);
+	seq_printf(seq,
+		   "Claims announced for the mesh %s (orig %pM, group id %04x)\n",
+		   net_dev->name, primary_if->net_dev->dev_addr,
+		   ntohs(bat_priv->claim_dest.group));
 	seq_printf(seq, "   %-17s    %-5s    %-17s [o] (%-4s)\n",
 		   "Client", "VID", "Originator", "CRC");
 	for (i = 0; i < hash->size; i++) {
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index ad97e87..7f7f610 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -193,6 +193,7 @@ struct bat_priv {
 	struct hashtable_t *vis_hash;
 	struct bcast_duplist_entry bcast_duplist[DUPLIST_SIZE];
 	int bcast_duplist_curr;
+	struct bla_claim_dst claim_dest;
 	spinlock_t forw_bat_list_lock; /* protects forw_bat_list */
 	spinlock_t forw_bcast_list_lock; /* protects  */
 	spinlock_t tt_changes_list_lock; /* protects tt_changes */
-- 
1.7.9.4
