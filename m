From: Moni Shoua <monis@Voltaire.COM>
Subject: [PATCH]  net/bonding: Don't destroy bonding master wehn unensalving
 with a sysfs command
Date: Thu, 19 Jun 2008 18:01:37 +0300
Message-ID: <485A74D1.10900@Voltaire.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Olga Stern <olgas@voltaire.com>,
	Or Gerlitz <ogerlitz@voltaire.com>,
	netdev <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:45579 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750753AbYFSPBp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Jun 2008 11:01:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


It is wrong to destroy a bonding  master from a context that uses the sysfs of
 that bond. When last IPoIB slave is unenslaved from by writing to a sysfs
 file (for bond0 this would be /sys/class/net/bond0/bonding/slaves) the driver
 tries to destroy the bond. This is wrong and can lead to a lockup or a crash.
 This fix lets the bonding master stay and relies on the user to destroy the
 bonding master if necessary (i.e. before module ib_ipoib is unloaded)

This patch affects only bonds of IPoIB slaves. Ethernet slaves stay unaffected.
Signed-off-by: Moni Shoua <monis@voltaire.com>
---
 drivers/net/bonding/bond_sysfs.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 08f3d39..f66f590 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -351,9 +351,6 @@ static ssize_t bonding_store_slaves(struct device *d,
 		if (dev) {
 			printk(KERN_INFO DRV_NAME ": %s: Removing slave %s\n",
 				bond->dev->name, dev->name);
-			if (bond->setup_by_slave)
-				res = bond_release_and_destroy(bond->dev, dev);
-			else
 				res = bond_release(bond->dev, dev);
 			if (res) {
 				ret = res;
-- 
1.5.5

