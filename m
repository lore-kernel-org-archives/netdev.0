From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Mon, 5 Nov 2007 19:03:27 -0500
Message-ID: <20071106000327.GA13079@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56612 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754631AbXKFAD2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Nov 2007 19:03:28 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/82596.c          |    3 ++-
 drivers/net/phy/marvell.c    |   23 ++++++++++++++++++-----
 drivers/net/phy/phy_device.c |    2 +-
 drivers/net/sunhme.c         |    4 ++--
 4 files changed, 23 insertions(+), 9 deletions(-)

David Miller (1):
      SUNHME: Fix missing NETIF_F_VLAN_CHALLENGED on PCI happy meals

Evgeniy Dushistov (1):
      82596: free nonexistent resource fix

Olof Johansson (2):
      phylib: Add ID for Marvell 88E1240
      phylib: Silence driver registration

diff --git a/drivers/net/82596.c b/drivers/net/82596.c
index bb30d5b..2797da7 100644
--- a/drivers/net/82596.c
+++ b/drivers/net/82596.c
@@ -1192,6 +1192,8 @@ struct net_device * __init i82596_probe(int unit)
 			goto out;
 		}
 
+		dev->base_addr = ioaddr;
+
 		for (i = 0; i < 8; i++) {
 			eth_addr[i] = inb(ioaddr + 8 + i);
 			checksum += eth_addr[i];
@@ -1209,7 +1211,6 @@ struct net_device * __init i82596_probe(int unit)
 			goto out1;
 		}
 
-		dev->base_addr = ioaddr;
 		dev->irq = 10;
 	}
 #endif
diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
index d2ede5f..035fd41 100644
--- a/drivers/net/phy/marvell.c
+++ b/drivers/net/phy/marvell.c
@@ -265,7 +265,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
+		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = 0x01410c90,
@@ -278,7 +278,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
+		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = 0x01410cc0,
@@ -291,7 +291,7 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
+		.driver = { .owner = THIS_MODULE },
 	},
 	{
 		.phy_id = 0x01410cd0,
@@ -304,8 +304,21 @@ static struct phy_driver marvell_drivers[] = {
 		.read_status = &genphy_read_status,
 		.ack_interrupt = &marvell_ack_interrupt,
 		.config_intr = &marvell_config_intr,
-		.driver = {.owner = THIS_MODULE,},
-	}
+		.driver = { .owner = THIS_MODULE },
+	},
+	{
+		.phy_id = 0x01410e30,
+		.phy_id_mask = 0xfffffff0,
+		.name = "Marvell 88E1240",
+		.features = PHY_GBIT_FEATURES,
+		.flags = PHY_HAS_INTERRUPT,
+		.config_init = &m88e1111_config_init,
+		.config_aneg = &marvell_config_aneg,
+		.read_status = &genphy_read_status,
+		.ack_interrupt = &marvell_ack_interrupt,
+		.config_intr = &marvell_config_intr,
+		.driver = { .owner = THIS_MODULE },
+	},
 };
 
 static int __init marvell_init(void)
diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index c046121..f6e4848 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -706,7 +706,7 @@ int phy_driver_register(struct phy_driver *new_driver)
 		return retval;
 	}
 
-	pr_info("%s: Registered new driver\n", new_driver->name);
+	pr_debug("%s: Registered new driver\n", new_driver->name);
 
 	return 0;
 }
diff --git a/drivers/net/sunhme.c b/drivers/net/sunhme.c
index 120c8af..c20a3bd 100644
--- a/drivers/net/sunhme.c
+++ b/drivers/net/sunhme.c
@@ -3143,8 +3143,8 @@ static int __devinit happy_meal_pci_probe(struct pci_dev *pdev,
 	dev->irq = pdev->irq;
 	dev->dma = 0;
 
-	/* Happy Meal can do it all... */
-	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM;
+	/* Happy Meal can do it all... except VLAN. */
+	dev->features |= NETIF_F_SG | NETIF_F_HW_CSUM | NETIF_F_VLAN_CHALLENGED;
 
 #if defined(CONFIG_SBUS) && defined(CONFIG_PCI)
 	/* Hook up PCI register/dma accessors. */
