From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 9/9] bonding: remove unwanted lock for bond_store_primary_xxx()
Date: Wed, 6 Nov 2013 14:53:12 +0800
Message-ID: <5279E758.3090203@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:14658 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab3KFGzN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Nov 2013 01:55:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_select_active_slave() in bond_store_primary_xxx() is
already protected by RTNL, the bond lock and curr_slave_lock is
no effect here, so remove the unwanted lock.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 8 --------
 1 file changed, 8 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..8f6b713 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1068,8 +1068,6 @@ static ssize_t bonding_store_primary(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 	block_netpoll_tx();
-	read_lock(&bond->lock);
-	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
 		pr_info("%s: Unable to set primary slave; %s is in mode %d\n",
@@ -1107,8 +1105,6 @@ static ssize_t bonding_store_primary(struct device *d,
 		"but it has not been enslaved to %s yet.\n",
 		bond->dev->name, ifname, bond->dev->name);
 out:
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 	rtnl_unlock();
 
@@ -1156,11 +1152,7 @@ static ssize_t bonding_store_primary_reselect(struct device *d,
 		new_value);
 
 	block_netpoll_tx();
-	read_lock(&bond->lock);
-	write_lock_bh(&bond->curr_slave_lock);
 	bond_select_active_slave(bond);
-	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 out:
 	rtnl_unlock();
-- 
1.8.2.1
