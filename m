From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 10/10] bonding: remove unwanted lock for bond_store_primaryxxx()
Date: Mon, 11 Nov 2013 20:37:03 +0800
Message-ID: <5280CF6F.8030601@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:21969 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753800Ab3KKMhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 07:37:39 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_select_active_slave() will not release and acquire
bond lock, so it is no need to read the bond lock for them,
and the bond_store_primaryxxx() is in RTNL, remove the
unwanted lock.

Suggested-by: Jay Vosburgh <fubar@us.ibm.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 4 ----
 1 file changed, 4 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..25ef533 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1068,7 +1068,6 @@ static ssize_t bonding_store_primary(struct device *d,
 	if (!rtnl_trylock())
 		return restart_syscall();
 	block_netpoll_tx();
-	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 
 	if (!USES_PRIMARY(bond->params.mode)) {
@@ -1108,7 +1107,6 @@ static ssize_t bonding_store_primary(struct device *d,
 		bond->dev->name, ifname, bond->dev->name);
 out:
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 	rtnl_unlock();
 
@@ -1156,11 +1154,9 @@ static ssize_t bonding_store_primary_reselect(struct device *d,
 		new_value);
 
 	block_netpoll_tx();
-	read_lock(&bond->lock);
 	write_lock_bh(&bond->curr_slave_lock);
 	bond_select_active_slave(bond);
 	write_unlock_bh(&bond->curr_slave_lock);
-	read_unlock(&bond->lock);
 	unblock_netpoll_tx();
 out:
 	rtnl_unlock();
-- 
1.8.2.1
