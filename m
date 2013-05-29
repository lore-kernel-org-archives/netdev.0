From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 18/21] batman-adv: change VID semantic in the BLA code
Date: Wed, 29 May 2013 10:12:29 +0200
Message-ID: <1369815152-2750-1-git-send-email-ordex@autistici.org>
References: <1369815051-708-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from diserzione.investici.org ([82.221.99.153]:50549 "EHLO
	diserzione.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965050Ab3E2IOa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 May 2013 04:14:30 -0400
In-Reply-To: <1369815051-708-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

In order to make batman-adv fully vlan aware later, the
semantic used for variables storing the VLAN ID values has
to be changed in order to be adapted to the new one which
will be used batman-adv wide.

In particular, the VID has to be an "_unsigned_ short int"
and its 4 MSB will be used as a flag bitfield, while the
remaining 12 bits are used to store the real VID value

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
Acked-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
---
 net/batman-adv/bridge_loop_avoidance.c | 51 ++++++++++++++++++----------------
 net/batman-adv/bridge_loop_avoidance.h | 12 ++++----
 net/batman-adv/main.h                  | 11 ++++++++
 net/batman-adv/soft-interface.c        |  4 +--
 net/batman-adv/types.h                 |  4 +--
 5 files changed, 49 insertions(+), 33 deletions(-)

diff --git a/net/batman-adv/bridge_loop_avoidance.c b/net/batman-adv/bridge_loop_avoidance.c
index 082189e..7354063 100644
--- a/net/batman-adv/bridge_loop_avoidance.c
+++ b/net/batman-adv/bridge_loop_avoidance.c
@@ -180,7 +180,7 @@ static struct batadv_bla_claim
  */
 static struct batadv_bla_backbone_gw *
 batadv_backbone_hash_find(struct batadv_priv *bat_priv,
-			  uint8_t *addr, short vid)
+			  uint8_t *addr, unsigned short vid)
 {
 	struct batadv_hashtable *hash = bat_priv->bla.backbone_hash;
 	struct hlist_head *head;
@@ -257,7 +257,7 @@ batadv_bla_del_backbone_claims(struct batadv_bla_backbone_gw *backbone_gw)
  * @claimtype: the type of the claim (CLAIM, UNCLAIM, ANNOUNCE, ...)
  */
 static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
-				  short vid, int claimtype)
+				  unsigned short vid, int claimtype)
 {
 	struct sk_buff *skb;
 	struct ethhdr *ethhdr;
@@ -335,13 +335,14 @@ static void batadv_bla_send_claim(struct batadv_priv *bat_priv, uint8_t *mac,
 		memcpy(hw_src, mac, ETH_ALEN);
 		memcpy(ethhdr->h_dest, mac, ETH_ALEN);
 		batadv_dbg(BATADV_DBG_BLA, bat_priv,
-			   "bla_send_claim(): REQUEST of %pM to %pMon vid %d\n",
+			   "bla_send_claim(): REQUEST of %pM to %pM on vid %d\n",
 			   ethhdr->h_source, ethhdr->h_dest, vid);
 		break;
 	}
 
-	if (vid != -1)
-		skb = vlan_insert_tag(skb, htons(ETH_P_8021Q), vid);
+	if (vid & BATADV_VLAN_HAS_TAG)
+		skb = vlan_insert_tag(skb, htons(ETH_P_8021Q),
+				      vid & VLAN_VID_MASK);
 
 	skb_reset_mac_header(skb);
 	skb->protocol = eth_type_trans(skb, soft_iface);
@@ -367,7 +368,7 @@ out:
  */
 static struct batadv_bla_backbone_gw *
 batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
-			   short vid, bool own_backbone)
+			   unsigned short vid, bool own_backbone)
 {
 	struct batadv_bla_backbone_gw *entry;
 	struct batadv_orig_node *orig_node;
@@ -434,7 +435,7 @@ batadv_bla_get_backbone_gw(struct batadv_priv *bat_priv, uint8_t *orig,
 static void
 batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
 				  struct batadv_hard_iface *primary_if,
-				  short vid)
+				  unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 
@@ -456,7 +457,7 @@ batadv_bla_update_own_backbone_gw(struct batadv_priv *bat_priv,
  */
 static void batadv_bla_answer_request(struct batadv_priv *bat_priv,
 				      struct batadv_hard_iface *primary_if,
-				      short vid)
+				      unsigned short vid)
 {
 	struct hlist_head *head;
 	struct batadv_hashtable *hash;
@@ -547,7 +548,7 @@ static void batadv_bla_send_announce(struct batadv_priv *bat_priv,
  * @backbone_gw: the backbone gateway which claims it
  */
 static void batadv_bla_add_claim(struct batadv_priv *bat_priv,
-				 const uint8_t *mac, const short vid,
+				 const uint8_t *mac, const unsigned short vid,
 				 struct batadv_bla_backbone_gw *backbone_gw)
 {
 	struct batadv_bla_claim *claim;
@@ -611,7 +612,7 @@ claim_free_ref:
  * given mac address and vid.
  */
 static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
-				 const uint8_t *mac, const short vid)
+				 const uint8_t *mac, const unsigned short vid)
 {
 	struct batadv_bla_claim search_claim, *claim;
 
@@ -637,7 +638,7 @@ static void batadv_bla_del_claim(struct batadv_priv *bat_priv,
 /* check for ANNOUNCE frame, return 1 if handled */
 static int batadv_handle_announce(struct batadv_priv *bat_priv,
 				  uint8_t *an_addr, uint8_t *backbone_addr,
-				  short vid)
+				  unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 	uint16_t crc;
@@ -685,7 +686,7 @@ static int batadv_handle_announce(struct batadv_priv *bat_priv,
 static int batadv_handle_request(struct batadv_priv *bat_priv,
 				 struct batadv_hard_iface *primary_if,
 				 uint8_t *backbone_addr,
-				 struct ethhdr *ethhdr, short vid)
+				 struct ethhdr *ethhdr, unsigned short vid)
 {
 	/* check for REQUEST frame */
 	if (!batadv_compare_eth(backbone_addr, ethhdr->h_dest))
@@ -709,7 +710,7 @@ static int batadv_handle_request(struct batadv_priv *bat_priv,
 static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 				 struct batadv_hard_iface *primary_if,
 				 uint8_t *backbone_addr,
-				 uint8_t *claim_addr, short vid)
+				 uint8_t *claim_addr, unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 
@@ -738,7 +739,7 @@ static int batadv_handle_unclaim(struct batadv_priv *bat_priv,
 static int batadv_handle_claim(struct batadv_priv *bat_priv,
 			       struct batadv_hard_iface *primary_if,
 			       uint8_t *backbone_addr, uint8_t *claim_addr,
-			       short vid)
+			       unsigned short vid)
 {
 	struct batadv_bla_backbone_gw *backbone_gw;
 
@@ -861,7 +862,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	struct batadv_bla_claim_dst *bla_dst;
 	uint16_t proto;
 	int headlen;
-	short vid = -1;
+	unsigned short vid = BATADV_NO_FLAGS;
 	int ret;
 
 	ethhdr = eth_hdr(skb);
@@ -869,6 +870,7 @@ static int batadv_bla_process_claim(struct batadv_priv *bat_priv,
 	if (ntohs(ethhdr->h_proto) == ETH_P_8021Q) {
 		vhdr = (struct vlan_ethhdr *)ethhdr;
 		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+		vid |= BATADV_VLAN_HAS_TAG;
 		proto = ntohs(vhdr->h_vlan_encapsulated_proto);
 		headlen = sizeof(*vhdr);
 	} else {
@@ -1358,7 +1360,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
 	struct batadv_bla_backbone_gw *backbone_gw;
-	short vid = -1;
+	unsigned short vid = BATADV_NO_FLAGS;
 
 	if (!atomic_read(&orig_node->bat_priv->bridge_loop_avoidance))
 		return 0;
@@ -1375,6 +1377,7 @@ int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 
 		vhdr = (struct vlan_ethhdr *)(skb->data + hdr_size);
 		vid = ntohs(vhdr->h_vlan_TCI) & VLAN_VID_MASK;
+		vid |= BATADV_VLAN_HAS_TAG;
 	}
 
 	/* see if this originator is a backbone gw for this VLAN */
@@ -1424,8 +1427,8 @@ void batadv_bla_free(struct batadv_priv *bat_priv)
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
  */
-int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid,
-		  bool is_bcast)
+int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		  unsigned short vid, bool is_bcast)
 {
 	struct ethhdr *ethhdr;
 	struct batadv_bla_claim search_claim, *claim = NULL;
@@ -1519,7 +1522,8 @@ out:
  * returns 1, otherwise it returns 0 and the caller shall further
  * process the skb.
  */
-int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid)
+int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		  unsigned short vid)
 {
 	struct ethhdr *ethhdr;
 	struct batadv_bla_claim search_claim, *claim = NULL;
@@ -1623,7 +1627,7 @@ int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset)
 		hlist_for_each_entry_rcu(claim, head, hash_entry) {
 			is_own = batadv_compare_eth(claim->backbone_gw->orig,
 						    primary_addr);
-			seq_printf(seq,	" * %pM on % 5d by %pM [%c] (%#.4x)\n",
+			seq_printf(seq, " * %pM on %5d by %pM [%c] (%#.4x)\n",
 				   claim->addr, claim->vid,
 				   claim->backbone_gw->orig,
 				   (is_own ? 'x' : ' '),
@@ -1676,10 +1680,9 @@ int batadv_bla_backbone_table_seq_print_text(struct seq_file *seq, void *offset)
 			if (is_own)
 				continue;
 
-			seq_printf(seq,
-				   " * %pM on % 5d % 4i.%03is (%#.4x)\n",
-				   backbone_gw->orig, backbone_gw->vid,
-				   secs, msecs, backbone_gw->crc);
+			seq_printf(seq, " * %pM on %5d %4i.%03is (%#.4x)\n",
+				   backbone_gw->orig, backbone_gw->vid, secs,
+				   msecs, backbone_gw->crc);
 		}
 		rcu_read_unlock();
 	}
diff --git a/net/batman-adv/bridge_loop_avoidance.h b/net/batman-adv/bridge_loop_avoidance.h
index dea2fbc..4b102e7 100644
--- a/net/batman-adv/bridge_loop_avoidance.h
+++ b/net/batman-adv/bridge_loop_avoidance.h
@@ -21,9 +21,10 @@
 #define _NET_BATMAN_ADV_BLA_H_
 
 #ifdef CONFIG_BATMAN_ADV_BLA
-int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid,
-		  bool is_bcast);
-int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb, short vid);
+int batadv_bla_rx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		  unsigned short vid, bool is_bcast);
+int batadv_bla_tx(struct batadv_priv *bat_priv, struct sk_buff *skb,
+		  unsigned short vid);
 int batadv_bla_is_backbone_gw(struct sk_buff *skb,
 			      struct batadv_orig_node *orig_node, int hdr_size);
 int batadv_bla_claim_table_seq_print_text(struct seq_file *seq, void *offset);
@@ -42,13 +43,14 @@ void batadv_bla_free(struct batadv_priv *bat_priv);
 #else /* ifdef CONFIG_BATMAN_ADV_BLA */
 
 static inline int batadv_bla_rx(struct batadv_priv *bat_priv,
-				struct sk_buff *skb, short vid, bool is_bcast)
+				struct sk_buff *skb, unsigned short vid,
+				bool is_bcast)
 {
 	return 0;
 }
 
 static inline int batadv_bla_tx(struct batadv_priv *bat_priv,
-				struct sk_buff *skb, short vid)
+				struct sk_buff *skb, unsigned short vid)
 {
 	return 0;
 }
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index ea1a3ba..6f25ef2 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -162,6 +162,17 @@ enum batadv_uev_type {
 #include <linux/seq_file.h>
 #include "types.h"
 
+/**
+ * batadv_vlan_flags - flags for the four MSB of any vlan ID field
+ * @BATADV_VLAN_HAS_TAG: whether the field contains a valid vlan tag or not
+ */
+enum batadv_vlan_flags {
+	BATADV_VLAN_HAS_TAG	= BIT(15),
+};
+
+#define BATADV_PRINT_VID(vid) (vid & BATADV_VLAN_HAS_TAG ? \
+			       (int)(vid & VLAN_VID_MASK) : -1)
+
 extern char batadv_routing_algo[];
 extern struct list_head batadv_hardif_list;
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index b26a6cd..700d0b4 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -154,7 +154,7 @@ static int batadv_interface_tx(struct sk_buff *skb,
 						    0x00, 0x00};
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
-	short vid __maybe_unused = -1;
+	unsigned short vid __maybe_unused = BATADV_NO_FLAGS;
 	bool do_bcast = false;
 	uint32_t seqno;
 	unsigned long brd_delay = 1;
@@ -303,7 +303,7 @@ void batadv_interface_rx(struct net_device *soft_iface,
 	struct ethhdr *ethhdr;
 	struct vlan_ethhdr *vhdr;
 	struct batadv_header *batadv_header = (struct batadv_header *)skb->data;
-	short vid __maybe_unused = -1;
+	unsigned short vid __maybe_unused = BATADV_NO_FLAGS;
 	__be16 ethertype = __constant_htons(ETH_P_BATMAN);
 	bool is_bcast;
 
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index 5f542bd..b2c94e1 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -642,7 +642,7 @@ struct batadv_socket_packet {
 #ifdef CONFIG_BATMAN_ADV_BLA
 struct batadv_bla_backbone_gw {
 	uint8_t orig[ETH_ALEN];
-	short vid;
+	unsigned short vid;
 	struct hlist_node hash_entry;
 	struct batadv_priv *bat_priv;
 	unsigned long lasttime;
@@ -665,7 +665,7 @@ struct batadv_bla_backbone_gw {
  */
 struct batadv_bla_claim {
 	uint8_t addr[ETH_ALEN];
-	short vid;
+	unsigned short vid;
 	struct batadv_bla_backbone_gw *backbone_gw;
 	unsigned long lasttime;
 	struct hlist_node hash_entry;
-- 
1.8.1.5
