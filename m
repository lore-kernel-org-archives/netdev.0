From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/2] bonding: use rlb_client_info->vlan_id instead of ->tag
Date: Thu, 29 Aug 2013 23:38:57 +0200
Message-ID: <1377812337-19551-3-git-send-email-vfalico@redhat.com>
References: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50939 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755515Ab3H2Vir (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 17:38:47 -0400
In-Reply-To: <1377812337-19551-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Store VID in ->vlan_id (if any), and remove the useless ->tag.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c | 8 ++++----
 drivers/net/bonding/bond_alb.h | 1 -
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 27b03fa..91f179d 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -512,7 +512,7 @@ static void rlb_update_client(struct rlb_client_info *client_info)
 
 		skb->dev = client_info->slave->dev;
 
-		if (client_info->tag) {
+		if (client_info->vlan_id) {
 			skb = vlan_put_tag(skb, htons(ETH_P_8021Q), client_info->vlan_id);
 			if (!skb) {
 				pr_err("%s: Error: failed to insert VLAN tag\n",
@@ -695,7 +695,7 @@ static struct slave *rlb_choose_channel(struct sk_buff *skb, struct bonding *bon
 		}
 
 		if (!vlan_get_tag(skb, &client_info->vlan_id))
-			client_info->tag = 1;
+			client_info->vlan_id = 0;
 
 		if (!client_info->assigned) {
 			u32 prev_tbl_head = bond_info->rx_hashtbl_used_head;
@@ -801,7 +801,7 @@ static void rlb_init_table_entry_dst(struct rlb_client_info *entry)
 	entry->used_prev = RLB_NULL_INDEX;
 	entry->assigned = 0;
 	entry->slave = NULL;
-	entry->tag = 0;
+	entry->vlan_id = 0;
 }
 static void rlb_init_table_entry_src(struct rlb_client_info *entry)
 {
@@ -958,7 +958,7 @@ static void rlb_clear_vlan(struct bonding *bond, unsigned short vlan_id)
 		struct rlb_client_info *curr = &(bond_info->rx_hashtbl[curr_index]);
 		u32 next_index = bond_info->rx_hashtbl[curr_index].used_next;
 
-		if (curr->tag && (curr->vlan_id == vlan_id))
+		if (curr->vlan_id == vlan_id)
 			rlb_delete_table_entry(bond, curr_index);
 
 		curr_index = next_index;
diff --git a/drivers/net/bonding/bond_alb.h b/drivers/net/bonding/bond_alb.h
index e02c9c5..28d8e4c 100644
--- a/drivers/net/bonding/bond_alb.h
+++ b/drivers/net/bonding/bond_alb.h
@@ -125,7 +125,6 @@ struct rlb_client_info {
 	u8  assigned;		/* checking whether this entry is assigned */
 	u8  ntt;		/* flag - need to transmit client info */
 	struct slave *slave;	/* the slave assigned to this client */
-	u8 tag;			/* flag - need to tag skb */
 	unsigned short vlan_id;	/* VLAN tag associated with IP address */
 };
 
-- 
1.8.4
