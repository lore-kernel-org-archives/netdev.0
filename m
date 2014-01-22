From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/3] bonding: Set the correct value to fail_over_mac
 at enslavement
Date: Wed, 22 Jan 2014 17:22:00 +0800
Message-ID: <52DF8DB8.9000006@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:17285 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbaAVJWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 04:22:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the new slave don't support setting the MAC address, there are
two ways to handle this situation:

1). If the new slave is the first slave, set bond to the new slave's
    MAC address, if the mode is active-backup, set fail_over_mac to
    active, otherwise set fail_over_mac to none.
2). If the new slave is not the first slave and the fail_over_mac is
    active, it means that the slave could work normally in active-backup
    mode, otherwise if the fail_over_mac is none, the slave could not
    work normally for no active-backup mode, so bond could not ensalve
    the new dev.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3220b48..598f100 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1334,9 +1334,17 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
 		if (!bond_has_slaves(bond)) {
-			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
+			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address.\n",
 				   bond_dev->name);
-			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
+				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+				pr_warning("%s: Setting fail_over_mac to active for active-backup mode.\n",
+					   bond_dev->name);
+			} else {
+				bond->params.fail_over_mac = BOND_FOM_NONE;
+				pr_warning("%s: Setting fail_over_mac to none for no active-backup modes",
+					   bond_dev->name);
+			}
 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active.\n",
 			       bond_dev->name);
-- 
1.8.0
