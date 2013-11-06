From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 8/9] bonding: remove unwanted lock for bond enslave
 and release
Date: Wed, 6 Nov 2013 14:53:08 +0800
Message-ID: <5279E754.1050808@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:5539 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751084Ab3KFGyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:54:02 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_change_active_slave() and bond_select_active_slave()
was no longer need bond lock and curr_slave_lock, the enslave
and release will always in RTNL, so remove the unwanted lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 19 +------------------
 1 file changed, 1 insertion(+), 18 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index dc17a85..d2d70dc 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1565,13 +1565,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_compute_features(bond);
 	bond_set_carrier(bond);
 
-	if (USES_PRIMARY(bond->params.mode)) {
-		read_lock(&bond->lock);
-		write_lock_bh(&bond->curr_slave_lock);
+	if (USES_PRIMARY(bond->params.mode))
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
-	}
 
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
 		bond_dev->name, slave_dev->name,
@@ -1590,19 +1585,11 @@ err_detach:
 		bond_hw_addr_flush(bond_dev, slave_dev);
 
 	vlan_vids_del_by_dev(slave_dev, bond_dev);
-	write_lock_bh(&bond->lock);
 	if (bond->primary_slave == new_slave)
 		bond->primary_slave = NULL;
 	if (bond->curr_active_slave == new_slave) {
 		bond_change_active_slave(bond, NULL);
-		write_unlock_bh(&bond->lock);
-		read_lock(&bond->lock);
-		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
-		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
-	} else {
-		write_unlock_bh(&bond->lock);
 	}
 	slave_disable_netpoll(new_slave);
 
@@ -1743,13 +1730,9 @@ static int __bond_release_one(struct net_device *bond_dev,
 		 * will interfere.
 		 */
 		write_unlock_bh(&bond->lock);
-		read_lock(&bond->lock);
-		write_lock_bh(&bond->curr_slave_lock);
 
 		bond_select_active_slave(bond);
 
-		write_unlock_bh(&bond->curr_slave_lock);
-		read_unlock(&bond->lock);
 		write_lock_bh(&bond->lock);
 	}
 
-- 
1.8.2.1
