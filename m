From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net] bonding: Fix deadlock in bonding driver when using netpoll
Date: Wed, 12 Feb 2014 12:06:40 +0800
Message-ID: <52FAF350.80005@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:62272 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807AbaBLEHl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Feb 2014 23:07:41 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding driver take write locks and spin locks that are shared
by the tx path in enslave processing and notification processing,
If the netconsole is in use, the bonding can call printk which puts
us in the netpoll tx path, if the netconsole is attached to the bonding
driver, result in deadlock.

So add protection for these place, by checking the netpoll_block_tx
state, we can defer the sending of the netconsole frames until a later
time using the retransmit feature of netpoll_send_skb that is triggered
on the return code NETDEV_TX_BUSY.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 71ba18e..8676649 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1543,9 +1543,11 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	bond_set_carrier(bond);
 
 	if (USES_PRIMARY(bond->params.mode)) {
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 	}
 
 	pr_info("%s: enslaving %s as a%s interface with a%s link.\n",
@@ -1571,10 +1573,12 @@ err_detach:
 	if (bond->primary_slave == new_slave)
 		bond->primary_slave = NULL;
 	if (bond->curr_active_slave == new_slave) {
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_change_active_slave(bond, NULL);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 	}
 	slave_disable_netpoll(new_slave);
 
@@ -2864,9 +2868,12 @@ static int bond_slave_netdev_event(unsigned long event,
 		pr_info("%s: Primary slave changed to %s, reselecting active slave.\n",
 			bond->dev->name, bond->primary_slave ? slave_dev->name :
 							       "none");
+
+		block_netpoll_tx();
 		write_lock_bh(&bond->curr_slave_lock);
 		bond_select_active_slave(bond);
 		write_unlock_bh(&bond->curr_slave_lock);
+		unblock_netpoll_tx();
 		break;
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
-- 
1.8.0
