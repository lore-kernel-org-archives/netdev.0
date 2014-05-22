From: Veaceslav Falico <vfalico@gmail.com>
Subject: [PATCH net-next 2/2] bonding: remove alb_set_mac_address()
Date: Thu, 22 May 2014 15:12:04 +0200
Message-ID: <1400764324-23221-3-git-send-email-vfalico@gmail.com>
References: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Cc: Veaceslav Falico <vfalico@gmail.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60544 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbaEVNQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 09:16:37 -0400
In-Reply-To: <1400764324-23221-1-git-send-email-vfalico@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's called only from bond_alb_set_mac_address(), which is called
only for ALB mode, and it does nothing in case the mode is ALB. So,
basically, it's a no-op. All the needed functionality (modifying the active
slave's mac address, per example) is handled by the
bond_alb_set_mac_address() itself.

So remove it, as it's not needed.

CC: Jay Vosburgh <j.vosburgh@gmail.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@gmail.com>
---
 drivers/net/bonding/bond_alb.c | 61 ------------------------------------------
 1 file changed, 61 deletions(-)

diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index 965518b..1d772b5 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -1256,62 +1256,6 @@ static int alb_handle_addr_collision_on_attach(struct bonding *bond, struct slav
 	return 0;
 }
 
-/**
- * alb_set_mac_address
- * @bond:
- * @addr:
- *
- * In TLB mode all slaves are configured to the bond's hw address, but set
- * their dev_addr field to different addresses (based on their permanent hw
- * addresses).
- *
- * For each slave, this function sets the interface to the new address and then
- * changes its dev_addr field to its previous value.
- *
- * Unwinding assumes bond's mac address has not yet changed.
- */
-static int alb_set_mac_address(struct bonding *bond, void *addr)
-{
-	struct slave *slave, *rollback_slave;
-	struct list_head *iter;
-	struct sockaddr sa;
-	char tmp_addr[ETH_ALEN];
-	int res;
-
-	if (BOND_MODE(bond) == BOND_MODE_ALB)
-		return 0;
-
-	bond_for_each_slave(bond, slave, iter) {
-		/* save net_device's current hw address */
-		ether_addr_copy(tmp_addr, slave->dev->dev_addr);
-
-		res = dev_set_mac_address(slave->dev, addr);
-
-		/* restore net_device's hw address */
-		ether_addr_copy(slave->dev->dev_addr, tmp_addr);
-
-		if (res)
-			goto unwind;
-	}
-
-	return 0;
-
-unwind:
-	memcpy(sa.sa_data, bond->dev->dev_addr, bond->dev->addr_len);
-	sa.sa_family = bond->dev->type;
-
-	/* unwind from head to the slave that failed */
-	bond_for_each_slave(bond, rollback_slave, iter) {
-		if (rollback_slave == slave)
-			break;
-		ether_addr_copy(tmp_addr, rollback_slave->dev->dev_addr);
-		dev_set_mac_address(rollback_slave->dev, &sa);
-		ether_addr_copy(rollback_slave->dev->dev_addr, tmp_addr);
-	}
-
-	return res;
-}
-
 /************************ exported alb funcions ************************/
 
 int bond_alb_initialize(struct bonding *bond)
@@ -1777,15 +1721,10 @@ int bond_alb_set_mac_address(struct net_device *bond_dev, void *addr)
 	struct bonding *bond = netdev_priv(bond_dev);
 	struct sockaddr *sa = addr;
 	struct slave *swap_slave;
-	int res;
 
 	if (!is_valid_ether_addr(sa->sa_data))
 		return -EADDRNOTAVAIL;
 
-	res = alb_set_mac_address(bond, addr);
-	if (res)
-		return res;
-
 	memcpy(bond_dev->dev_addr, sa->sa_data, bond_dev->addr_len);
 
 	/* If there is no curr_active_slave there is nothing else to do.
-- 
1.8.4
