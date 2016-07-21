From: Saeed Mahameed <saeedm@mellanox.com>
Subject: [PATCH net V2] net/bonding: Enforce active-backup policy for IPoIB bonds
Date: Thu, 21 Jul 2016 11:52:55 +0300
Message-ID: <1469091175-17143-1-git-send-email-saeedm@mellanox.com>
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <gospo@cumulusnetworks.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Jiri Pirko <jiri@mellanox.com>,
	Doug Ledford <dledford@redhat.com>,
	Mark Bloch <markb@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-il-dmz.mellanox.com ([193.47.165.129]:46370 "EHLO
	mellanox.co.il" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751556AbcGUIxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jul 2016 04:53:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mark Bloch <markb@mellanox.com>

When using an IPoIB bond currently only active-backup mode is a valid
use case and this commit strengthens it.

Since commit 2ab82852a270 ("net/bonding: Enable bonding to enslave
netdevices not supporting set_mac_address()") was introduced till
4.7-rc1, IPoIB didn't support the set_mac_address ndo, and hence the
fail over mac policy always applied to IPoIB bonds.

With the introduction of commit 492a7e67ff83 ("IB/IPoIB: Allow setting
the device address"), that doesn't hold and practically IPoIB bonds are
broken as of that. To fix it, lets go to fail over mac if the device
doesn't support the ndo OR this is IPoIB device.

As a by-product, this commit also prevents a stack corruption which
occurred when trying to copy 20 bytes (IPoIB) device address
to a sockaddr struct that has only 16 bytes of storage.

Signed-off-by: Mark Bloch <markb@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
---

Changes from v0:
 - Set res to -EOPNOTSUPP before jumping to err_undo_flags.

 drivers/net/bonding/bond_main.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a2afa3b..4d79819 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1422,7 +1422,16 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		return -EINVAL;
 	}
 
-	if (slave_ops->ndo_set_mac_address == NULL) {
+	if (slave_dev->type == ARPHRD_INFINIBAND &&
+	    BOND_MODE(bond) != BOND_MODE_ACTIVEBACKUP) {
+		netdev_warn(bond_dev, "Type (%d) supports only active-backup mode\n",
+			    slave_dev->type);
+		res = -EOPNOTSUPP;
+		goto err_undo_flags;
+	}
+
+	if (!slave_ops->ndo_set_mac_address ||
+	    slave_dev->type == ARPHRD_INFINIBAND) {
 		netdev_warn(bond_dev, "The slave device specified does not support setting the MAC address\n");
 		if (BOND_MODE(bond) == BOND_MODE_ACTIVEBACKUP &&
 		    bond->params.fail_over_mac != BOND_FOM_ACTIVE) {
-- 
2.8.0
