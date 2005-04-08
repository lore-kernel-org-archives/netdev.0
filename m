From: Radheka Godse <radheka.godse@intel.com>
Subject: [PATCH 2.6.12-rc2 6/17] bonding: ALB init kmalloc inside spinlock
 bugfix
Date: Fri, 8 Apr 2005 16:34:15 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504081630390.10355@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This patch corrects bug in ALB init where kmalloc called inside a held
lock causes stacdump in debug mode

Signed-off-by: Radheka Godse <radheka.godse@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>

diff -urN -X dontdiff linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c
--- linux-2.6.12-rc2clean/drivers/net/bonding/bond_alb.c	2005-04-07 11:24:41.000000000 -0700
+++ linux-2.6.12-rc2/drivers/net/bonding/bond_alb.c	2005-04-07 13:57:29.000000000 -0700
@@ -198,20 +198,21 @@
  {
  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
  	int size = TLB_HASH_TABLE_SIZE * sizeof(struct tlb_client_info);
+	struct tlb_client_info *new_hashtbl;
  	int i;

  	spin_lock_init(&(bond_info->tx_hashtbl_lock));

-	_lock_tx_hashtbl(bond);
-
-	bond_info->tx_hashtbl = kmalloc(size, GFP_KERNEL);
-	if (!bond_info->tx_hashtbl) {
+	new_hashtbl = kmalloc(size, GFP_KERNEL);
+	if (!new_hashtbl) {
  		printk(KERN_ERR DRV_NAME
  		       ": Error: %s: Failed to allocate TLB hash table\n",
  		       bond->dev->name);
-		_unlock_tx_hashtbl(bond);
  		return -1;
  	}
+	_lock_tx_hashtbl(bond);
+
+	bond_info->tx_hashtbl = new_hashtbl;

  	memset(bond_info->tx_hashtbl, 0, size);

@@ -798,21 +801,22 @@
  {
  	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
  	struct packet_type *pk_type = &(BOND_ALB_INFO(bond).rlb_pkt_type);
+	struct rlb_client_info	*new_hashtbl;
  	int size = RLB_HASH_TABLE_SIZE * sizeof(struct rlb_client_info);
  	int i;

  	spin_lock_init(&(bond_info->rx_hashtbl_lock));

-	_lock_rx_hashtbl(bond);
-
-	bond_info->rx_hashtbl = kmalloc(size, GFP_KERNEL);
-	if (!bond_info->rx_hashtbl) {
+	new_hashtbl = kmalloc(size, GFP_KERNEL);
+	if (!new_hashtbl) {
  		printk(KERN_ERR DRV_NAME
  		       ": Error: %s: Failed to allocate RLB hash table\n",
  		       bond->dev->name);
-		_unlock_rx_hashtbl(bond);
  		return -1;
  	}
+	_lock_rx_hashtbl(bond);
+
+	bond_info->rx_hashtbl = new_hashtbl;

  	bond_info->rx_hashtbl_head = RLB_NULL_INDEX;
