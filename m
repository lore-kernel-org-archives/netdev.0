From: <sarveshwar.bandi@emulex.com>
Subject: [PATCH net-2.6] bonding: Bonding driver does not consider the gso_max_size setting of slaves.
Date: Wed, 21 Nov 2012 16:48:56 +0530
Message-ID: <8814d83f-7213-4a32-91ec-39088a1a60a6@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:3553 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753482Ab2KULSm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Nov 2012 06:18:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Patch sets the lowest non-zero gso_max_size value of the slaves during enslave
and detach.

Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
---
 drivers/net/bonding/bond_main.c |   27 +++++++++++++++++++++++++++
 1 file changed, 27 insertions(+)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index b2530b0..5f19d16 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1198,6 +1198,31 @@ static void bond_attach_slave(struct bonding *bond, struct slave *new_slave)
 	bond->slave_cnt++;
 }
 
+static void bond_set_gso_max_size(struct bonding *bond)
+{
+	struct slave *slave;
+	struct net_device *bond_dev = bond->dev;
+	unsigned int gso_max_size = 0;
+	bool reset_gso_size = true;
+	int i;
+
+	bond_for_each_slave(bond, slave, i) {
+		if (!slave->dev->gso_max_size)
+			continue;
+
+		reset_gso_size = false;
+
+		if (!gso_max_size ||
+		    slave->dev->gso_max_size < gso_max_size)
+			gso_max_size = slave->dev->gso_max_size;
+	}
+
+	if (gso_max_size && gso_max_size < bond_dev->gso_max_size)
+		netif_set_gso_max_size(bond_dev, gso_max_size);
+	else if (reset_gso_size)
+		netif_set_gso_max_size(bond_dev, 0);
+}
+
 /*
  * This function detaches the slave from the list.
  * WARNING: no check is made to verify if the slave effectively
@@ -1403,6 +1428,8 @@ done:
 	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
 	bond_dev->priv_flags = flags | dst_release_flag;
 
+	bond_set_gso_max_size(bond);
+
 	read_unlock(&bond->lock);
 
 	netdev_change_features(bond_dev);
-- 
1.7.9.5
