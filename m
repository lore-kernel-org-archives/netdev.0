From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next] bonding: don't call alb_set_slave_mac_addr() while atomic
Date: Sun, 16 Jun 2013 19:20:44 +0200
Message-ID: <1371403244-2891-1-git-send-email-vfalico@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27950 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755369Ab3FPRUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Jun 2013 13:20:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

alb_set_slave_mac_addr() sets the mac address in alb mode via
dev_set_mac_address(), which might sleep. It's called from
alb_handle_addr_collision_on_attach() in atomic context (under
read_lock(bond->lock)), thus triggering a bug.

Fix this by moving the lock inside alb_handle_addr_collision_on_attach().

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_alb.c |   21 ++++++++++-----------
 1 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index a236234..3f14f99 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1175,10 +1175,7 @@ static void alb_change_hw_addr_on_detach(struct bonding *bond, struct slave *sla
  * @slave.
  *
  * assumption: this function is called before @slave is attached to the
- * 	       bond slave list.
- *
- * caller must hold the bond lock for write since the mac addresses are compared
- * and may be swapped.
+ *	       bond slave list.
  */
 static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slave *slave)
 {
@@ -1196,6 +1193,9 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	 * slaves in the bond.
 	 */
 	if (!ether_addr_equal_64bits(slave->perm_hwaddr, bond->dev->dev_addr)) {
+
+		read_lock(&bond->lock);
+
 		bond_for_each_slave(bond, tmp_slave1, i) {
 			if (ether_addr_equal_64bits(tmp_slave1->dev->dev_addr,
 						    slave->dev->dev_addr)) {
@@ -1204,6 +1204,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 			}
 		}
 
+		read_unlock(&bond->lock);
+
 		if (!found)
 			return 0;
 
@@ -1217,6 +1219,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	 */
 	free_mac_slave = NULL;
 
+	read_lock(&bond->lock);
+
 	bond_for_each_slave(bond, tmp_slave1, i) {
 		found = 0;
 		bond_for_each_slave(bond, tmp_slave2, j) {
@@ -1244,6 +1248,8 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 		}
 	}
 
+	read_unlock(&bond->lock);
+
 	if (free_mac_slave) {
 		alb_set_slave_mac_addr(slave, free_mac_slave->perm_hwaddr);
 
@@ -1607,15 +1613,8 @@ int bond_alb_init_slave(struct bonding *bond, struct slave *slave)
 		return res;
 	}
 
-	/* caller must hold the bond lock for write since the mac addresses
-	 * are compared and may be swapped.
-	 */
-	read_lock(&bond->lock);
-
 	res = alb_handle_addr_collision_on_attach(bond, slave);
 
-	read_unlock(&bond->lock);
-
 	if (res) {
 		return res;
 	}
-- 
1.7.1
