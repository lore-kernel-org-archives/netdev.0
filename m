From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v3 1/2] bonding: fail_over_mac should only affect
 AB mode at enslave and removal processing
Date: Fri, 24 Jan 2014 12:27:33 +0800
Message-ID: <52E1EBB5.2010606@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([119.145.14.64]:17377 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750721AbaAXE2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 23:28:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

According to bonding.txt, the fail_over_ma should only affect active-backup mode,
but I fould that the fail_over_mac could be set to active or follow in every
mode, this will cause new slave could not be set to bond's MAC address at
enslave processing and restore its own MAC address at removal processing.

The correct way to fix the problem is that we should not add restrictions when
setting options, just need to modify the bond enslave and removal processing
to check the mode in addition to fail_over_mac when setting a slave's MAC during
enslavement. The change active slave processing already only calls the fail_over_mac
function when in active-backup mode.

Thanks for Jay's suggestion.

The patch also modify the pr_warning() to pr_warn().

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_main.c | 22 +++++++++++++++-------
 1 file changed, 15 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2ca949f..4409aa8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1270,9 +1270,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 
 	if (slave_ops->ndo_set_mac_address == NULL) {
 		if (!bond_has_slaves(bond)) {
-			pr_warning("%s: Warning: The first slave device specified does not support setting the MAC address. Setting fail_over_mac to active.",
-				   bond_dev->name);
-			bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+			pr_warn("%s: Warning: The first slave device specified does not support setting the MAC address.\n",
+				bond_dev->name);
+			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP) {
+				bond->params.fail_over_mac = BOND_FOM_ACTIVE;
+				pr_warn("%s: Setting fail_over_mac to active for active-backup mode.\n",
+					bond_dev->name);
+			}
 		} else if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
 			pr_err("%s: Error: The slave device specified does not support setting the MAC address, but fail_over_mac is not set to active.\n",
 			       bond_dev->name);
@@ -1315,7 +1319,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	 */
 	memcpy(new_slave->perm_hwaddr, slave_dev->dev_addr, ETH_ALEN);
 
-	if (!bond->params.fail_over_mac) {
+	if (!bond->params.fail_over_mac ||
+	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
 		/*
 		 * Set slave to master's mac address.  The application already
 		 * set the master's mac address to that of the first slave
@@ -1579,7 +1584,8 @@ err_close:
 	dev_close(slave_dev);
 
 err_restore_mac:
-	if (!bond->params.fail_over_mac) {
+	if (!bond->params.fail_over_mac ||
+	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
 		/* XXX TODO - fom follow mode needs to change master's
 		 * MAC if this slave's MAC is in use by the bond, or at
 		 * least print a warning.
@@ -1672,7 +1678,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 
 	bond->current_arp_slave = NULL;
 
-	if (!all && !bond->params.fail_over_mac) {
+	if (!all && (!bond->params.fail_over_mac ||
+		     bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
 		if (ether_addr_equal_64bits(bond_dev->dev_addr, slave->perm_hwaddr) &&
 		    bond_has_slaves(bond))
 			pr_warn("%s: Warning: the permanent HWaddr of %s - %pM - is still in use by %s. Set the HWaddr of %s to a different address to avoid conflicts.\n",
@@ -1769,7 +1776,8 @@ static int __bond_release_one(struct net_device *bond_dev,
 	/* close slave before restoring its mac address */
 	dev_close(slave_dev);
 
-	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
+	if (bond->params.fail_over_mac != BOND_FOM_ACTIVE ||
+	    bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
 		/* restore original ("permanent") mac address */
 		memcpy(addr.sa_data, slave->perm_hwaddr, ETH_ALEN);
 		addr.sa_family = slave_dev->type;
-- 
1.8.0
