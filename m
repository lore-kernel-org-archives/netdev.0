From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 1/3] [PATCH 1/3] bonding: update the primary slave
 when changing slave's name
Date: Tue, 14 Jan 2014 16:41:41 +0800
Message-ID: <52D4F845.6070106@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:57681 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751071AbaANImf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jan 2014 03:42:35 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the slave's name changed, and the bond params primary is exist,
the bond should deal with the situation in two ways:

1) If the slave was the primary slave yet, clean the primary slave
   and reselect active slave.
2) If the slave's new name is as same as bond primary, set the slave
   as primary slave and reselect active slave.

Thanks for Veaceslav's suggestion.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 24 ++++++++++++++++++++++--
 1 file changed, 22 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index e06c445..64e25d5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2860,9 +2860,29 @@ static int bond_slave_netdev_event(unsigned long event,
 		 */
 		break;
 	case NETDEV_CHANGENAME:
-		/*
-		 * TODO: handle changing the primary's name
+		/* Handle changing the slave's name:
+		 * 1) If the slave was primary slave,
+		 * clean the primary slave and reselect
+		 * active slave.
+		 * 2) If the slave's new name is same as
+		 * bond primary, set the slave as primary
+		 * slave and reselect active slave.
 		 */
+		if (slave == bond->primary_slave ||
+		    !strcmp(bond->params.primary, slave_dev->name)) {
+			if (bond->primary_slave) {
+				pr_info("%s: Setting primary slave to None.\n",
+					bond->dev->name);
+				bond->primary_slave = NULL;
+			} else {
+				pr_info("%s: Setting %s as primary slave.\n",
+					bond->dev->name, slave_dev->name);
+				bond->primary_slave = slave;
+			}
+			write_lock_bh(&bond->curr_slave_lock);
+			bond_select_active_slave(bond);
+			write_unlock_bh(&bond->curr_slave_lock);
+		}
 		break;
 	case NETDEV_FEAT_CHANGE:
 		bond_compute_features(bond);
-- 
1.8.0
