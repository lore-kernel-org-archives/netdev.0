From: Jiri Pirko <jpirko@redhat.com>
Subject: [PATCH net-next-2.6] bonding: move dev_addr cpy to bond_enslave
Date: Wed, 19 May 2010 13:14:29 +0200
Message-ID: <20100519111428.GA2788@psychotron.lab.eng.brq.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50499 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755835Ab0ESLOk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 07:14:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the code that copies slave's mac address in case that's the first slave into
bond_enslave. Ifenslave app does this also but that's not a problem. This is
something that should be done in bond_enslave, and it shound not matter from
where is it called.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/bonding/bond_main.c  |    7 +++++++
 drivers/net/bonding/bond_sysfs.c |    8 --------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 2c3f9db..4e7473e 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1522,6 +1522,13 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 		}
 	}
 
+	/* If this is the first slave, then we need to set the master's hardware
+	 * address to be the same as the slave's. */
+	if (bond->slave_cnt == 0)
+		memcpy(bond->dev->dev_addr, slave_dev->dev_addr,
+		       slave_dev->addr_len);
+
+
 	new_slave = kzalloc(sizeof(struct slave), GFP_KERNEL);
 	if (!new_slave) {
 		res = -ENOMEM;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index a4cbaf7..496ac1e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -250,14 +250,6 @@ static ssize_t bonding_store_slaves(struct device *d,
 	switch (command[0]) {
 	case '+':
 		pr_info("%s: Adding slave %s.\n", bond->dev->name, dev->name);
-
-		/* If this is the first slave, then we need to set
-		   the master's hardware address to be the same as the
-		   slave's. */
-		if (is_zero_ether_addr(bond->dev->dev_addr))
-			memcpy(bond->dev->dev_addr, dev->dev_addr,
-			       dev->addr_len);
-
 		res = bond_enslave(bond->dev, dev);
 		break;
 
-- 
1.6.6.1

