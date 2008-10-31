From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for 2.6.28-rc
Date: Fri, 31 Oct 2008 01:09:10 -0400
Message-ID: <20081031050910.GA9138@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:55551 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751302AbYJaFJM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Oct 2008 01:09:12 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 arch/powerpc/sysdev/fsl_soc.c   |   26 +++++++++++++++++++
 drivers/net/amd8111e.c          |    9 +++---
 drivers/net/arm/at91_ether.c    |    6 +++-
 drivers/net/atlx/atl1.c         |    7 +++--
 drivers/net/atlx/atl1.h         |    2 +-
 drivers/net/bonding/bond_alb.c  |   13 ++++++---
 drivers/net/bonding/bond_main.c |   52 +++++++++++++++++++++++++-------------
 drivers/net/gianfar.c           |   16 ++++++++++++
 drivers/net/gianfar_mii.c       |   21 +++++++++++++++
 drivers/net/gianfar_mii.h       |    3 ++
 drivers/net/myri10ge/myri10ge.c |    4 ++-
 drivers/net/smc91x.c            |    2 -
 include/linux/fsl_devices.h     |    3 +-
 13 files changed, 127 insertions(+), 37 deletions(-)

Andy Gospodarek (1):
      bonding: fix panic when taking bond interface down before removing module

Brice Goglin (1):
      myri10ge: fix stop/go mmio ordering

Chunbo Luo (1):
      amd8111e: fix dma_free_coherent context

David Brownell (1):
      at91_ether: request/free GPIO for PHY interrupt

Jay Cliburn (1):
      atl1: fix vlan tag regression

Jay Vosburgh (2):
      bonding: fix miimon failure counter
      bonding: Clean up resource leaks

Mike Frysinger (1):
      SMC91x: delete unused local variable "lp"

Trent Piepho (2):
      gianfar: Fix race in TBI/SerDes configuration
      gianfar: Don't reset TBI<->SerDes link if it's already up

diff --git a/arch/powerpc/sysdev/fsl_soc.c b/arch/powerpc/sysdev/fsl_soc.c
index 01b884b..26ecb96 100644
--- a/arch/powerpc/sysdev/fsl_soc.c
+++ b/arch/powerpc/sysdev/fsl_soc.c
@@ -223,6 +223,8 @@ static int gfar_mdio_of_init_one(struct device_node *np)
 	if (ret)
 		return ret;
 
+	/* The gianfar device will try to use the same ID created below to find
+	 * this bus, to coordinate register access (since they share).  */
 	mdio_dev = platform_device_register_simple("fsl-gianfar_mdio",
 			res.start&0xfffff, &res, 1);
 	if (IS_ERR(mdio_dev))
@@ -394,6 +396,30 @@ static int __init gfar_of_init(void)
 			of_node_put(mdio);
 		}
 
+		/* Get MDIO bus controlled by this eTSEC, if any.  Normally only
+		 * eTSEC 1 will control an MDIO bus, not necessarily the same
+		 * bus that its PHY is on ('mdio' above), so we can't just use
+		 * that.  What we do is look for a gianfar mdio device that has
+		 * overlapping registers with this device.  That's really the
+		 * whole point, to find the device sharing our registers to
+		 * coordinate access with it.
+		 */
+		for_each_compatible_node(mdio, NULL, "fsl,gianfar-mdio") {
+			if (of_address_to_resource(mdio, 0, &res))
+				continue;
+
+			if (res.start >= r[0].start && res.end <= r[0].end) {
+				/* Get the ID the mdio bus platform device was
+				 * registered with.  gfar_data.bus_id is
+				 * different because it's for finding a PHY,
+				 * while this is for finding a MII bus.
+				 */
+				gfar_data.mdio_bus = res.start&0xfffff;
+				of_node_put(mdio);
+				break;
+			}
+		}
+
 		ret =
 		    platform_device_add_data(gfar_dev, &gfar_data,
 					     sizeof(struct
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index ba1be0b..07a6697 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -644,10 +644,6 @@ This function frees the  transmiter and receiver descriptor rings.
 */
 static void amd8111e_free_ring(struct amd8111e_priv* lp)
 {
-
-	/* Free transmit and receive skbs */
-	amd8111e_free_skbs(lp->amd8111e_net_dev);
-
 	/* Free transmit and receive descriptor rings */
 	if(lp->rx_ring){
 		pci_free_consistent(lp->pci_dev,
@@ -1233,7 +1229,9 @@ static int amd8111e_close(struct net_device * dev)
 
 	amd8111e_disable_interrupt(lp);
 	amd8111e_stop_chip(lp);
-	amd8111e_free_ring(lp);
+
+	/* Free transmit and receive skbs */
+	amd8111e_free_skbs(lp->amd8111e_net_dev);
 
 	netif_carrier_off(lp->amd8111e_net_dev);
 
@@ -1243,6 +1241,7 @@ static int amd8111e_close(struct net_device * dev)
 
 	spin_unlock_irq(&lp->lock);
 	free_irq(dev->irq, dev);
+	amd8111e_free_ring(lp);
 
 	/* Update the statistics before closing */
 	amd8111e_get_stats(dev);
diff --git a/drivers/net/arm/at91_ether.c b/drivers/net/arm/at91_ether.c
index 0fa5346..6f431a8 100644
--- a/drivers/net/arm/at91_ether.c
+++ b/drivers/net/arm/at91_ether.c
@@ -1080,7 +1080,8 @@ static int __init at91ether_setup(unsigned long phy_type, unsigned short phy_add
 		init_timer(&lp->check_timer);
 		lp->check_timer.data = (unsigned long)dev;
 		lp->check_timer.function = at91ether_check_link;
-	}
+	} else if (lp->board_data.phy_irq_pin >= 32)
+		gpio_request(lp->board_data.phy_irq_pin, "ethernet_phy");
 
 	/* Display ethernet banner */
 	printk(KERN_INFO "%s: AT91 ethernet at 0x%08x int=%d %s%s (%s)\n",
@@ -1167,6 +1168,9 @@ static int __devexit at91ether_remove(struct platform_device *pdev)
 	struct net_device *dev = platform_get_drvdata(pdev);
 	struct at91_private *lp = netdev_priv(dev);
 
+	if (lp->board_data.phy_irq_pin >= 32)
+		gpio_free(lp->board_data.phy_irq_pin);
+
 	unregister_netdev(dev);
 	free_irq(dev->irq, dev);
 	dma_free_coherent(NULL, sizeof(struct recv_desc_bufs), lp->dlist, (dma_addr_t)lp->dlist_phys);
diff --git a/drivers/net/atlx/atl1.c b/drivers/net/atlx/atl1.c
index 3cf59a7..246d92b 100644
--- a/drivers/net/atlx/atl1.c
+++ b/drivers/net/atlx/atl1.c
@@ -2310,7 +2310,8 @@ static void atl1_tx_queue(struct atl1_adapter *adapter, u16 count,
 		if (tpd != ptpd)
 			memcpy(tpd, ptpd, sizeof(struct tx_packet_desc));
 		tpd->buffer_addr = cpu_to_le64(buffer_info->dma);
-		tpd->word2 = (cpu_to_le16(buffer_info->length) &
+		tpd->word2 &= ~(TPD_BUFLEN_MASK << TPD_BUFLEN_SHIFT);
+		tpd->word2 |= (cpu_to_le16(buffer_info->length) &
 			TPD_BUFLEN_MASK) << TPD_BUFLEN_SHIFT;
 
 		/*
@@ -2409,8 +2410,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		vlan_tag = (vlan_tag << 4) | (vlan_tag >> 13) |
 			((vlan_tag >> 9) & 0x8);
 		ptpd->word3 |= 1 << TPD_INS_VL_TAG_SHIFT;
-		ptpd->word3 |= (vlan_tag & TPD_VL_TAGGED_MASK) <<
-			TPD_VL_TAGGED_SHIFT;
+		ptpd->word2 |= (vlan_tag & TPD_VLANTAG_MASK) <<
+			TPD_VLANTAG_SHIFT;
 	}
 
 	tso = atl1_tso(adapter, skb, ptpd);
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index a5015b1..ffa73fc 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -504,7 +504,7 @@ struct rx_free_desc {
 #define TPD_PKTNT_MASK		0x0001
 #define TPD_PKTINT_SHIFT	15
 #define TPD_VLANTAG_MASK	0xFFFF
-#define TPD_VLAN_SHIFT		16
+#define TPD_VLANTAG_SHIFT	16
 
 /* tpd word 3 bits 0:13 */
 #define TPD_EOP_MASK		0x0001
diff --git a/drivers/net/bonding/bond_alb.c b/drivers/net/bonding/bond_alb.c
index ade5f3f..87437c7 100644
--- a/drivers/net/bonding/bond_alb.c
+++ b/drivers/net/bonding/bond_alb.c
@@ -169,11 +169,14 @@ static void tlb_clear_slave(struct bonding *bond, struct slave *slave, int save_
 	/* clear slave from tx_hashtbl */
 	tx_hash_table = BOND_ALB_INFO(bond).tx_hashtbl;
 
-	index = SLAVE_TLB_INFO(slave).head;
-	while (index != TLB_NULL_INDEX) {
-		u32 next_index = tx_hash_table[index].next;
-		tlb_init_table_entry(&tx_hash_table[index], save_load);
-		index = next_index;
+	/* skip this if we've already freed the tx hash table */
+	if (tx_hash_table) {
+		index = SLAVE_TLB_INFO(slave).head;
+		while (index != TLB_NULL_INDEX) {
+			u32 next_index = tx_hash_table[index].next;
+			tlb_init_table_entry(&tx_hash_table[index], save_load);
+			index = next_index;
+		}
 	}
 
 	tlb_init_slave(slave);
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 832739f..a3efba5 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1979,6 +1979,20 @@ void bond_destroy(struct bonding *bond)
 	unregister_netdevice(bond->dev);
 }
 
+static void bond_destructor(struct net_device *bond_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+
+	if (bond->wq)
+		destroy_workqueue(bond->wq);
+
+	netif_addr_lock_bh(bond_dev);
+	bond_mc_list_destroy(bond);
+	netif_addr_unlock_bh(bond_dev);
+
+	free_netdev(bond_dev);
+}
+
 /*
 * First release a slave and than destroy the bond if no more slaves iare left.
 * Must be under rtnl_lock when this function is called.
@@ -2376,6 +2390,9 @@ static void bond_miimon_commit(struct bonding *bond)
 			continue;
 
 		case BOND_LINK_DOWN:
+			if (slave->link_failure_count < UINT_MAX)
+				slave->link_failure_count++;
+
 			slave->link = BOND_LINK_DOWN;
 
 			if (bond->params.mode == BOND_MODE_ACTIVEBACKUP ||
@@ -4550,7 +4567,7 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 
 	bond_set_mode_ops(bond, bond->params.mode);
 
-	bond_dev->destructor = free_netdev;
+	bond_dev->destructor = bond_destructor;
 
 	/* Initialize the device options */
 	bond_dev->tx_queue_len = 0;
@@ -4589,20 +4606,6 @@ static int bond_init(struct net_device *bond_dev, struct bond_params *params)
 	return 0;
 }
 
-/* De-initialize device specific data.
- * Caller must hold rtnl_lock.
- */
-static void bond_deinit(struct net_device *bond_dev)
-{
-	struct bonding *bond = bond_dev->priv;
-
-	list_del(&bond->bond_list);
-
-#ifdef CONFIG_PROC_FS
-	bond_remove_proc_entry(bond);
-#endif
-}
-
 static void bond_work_cancel_all(struct bonding *bond)
 {
 	write_lock_bh(&bond->lock);
@@ -4624,6 +4627,22 @@ static void bond_work_cancel_all(struct bonding *bond)
 		cancel_delayed_work(&bond->ad_work);
 }
 
+/* De-initialize device specific data.
+ * Caller must hold rtnl_lock.
+ */
+static void bond_deinit(struct net_device *bond_dev)
+{
+	struct bonding *bond = bond_dev->priv;
+
+	list_del(&bond->bond_list);
+
+	bond_work_cancel_all(bond);
+
+#ifdef CONFIG_PROC_FS
+	bond_remove_proc_entry(bond);
+#endif
+}
+
 /* Unregister and free all bond devices.
  * Caller must hold rtnl_lock.
  */
@@ -4635,9 +4654,6 @@ static void bond_free_all(void)
 		struct net_device *bond_dev = bond->dev;
 
 		bond_work_cancel_all(bond);
-		netif_addr_lock_bh(bond_dev);
-		bond_mc_list_destroy(bond);
-		netif_addr_unlock_bh(bond_dev);
 		/* Release the bonded slaves */
 		bond_release_all(bond_dev);
 		bond_destroy(bond);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 64b2011..83a5cb6 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -586,6 +586,18 @@ static void gfar_configure_serdes(struct net_device *dev)
 	struct gfar_mii __iomem *regs =
 			(void __iomem *)&priv->regs->gfar_mii_regs;
 	int tbipa = gfar_read(&priv->regs->tbipa);
+	struct mii_bus *bus = gfar_get_miibus(priv);
+
+	if (bus)
+		mutex_lock(&bus->mdio_lock);
+
+	/* If the link is already up, we must already be ok, and don't need to
+	 * configure and reset the TBI<->SerDes link.  Maybe U-Boot configured
+	 * everything for us?  Resetting it takes the link down and requires
+	 * several seconds for it to come back.
+	 */
+	if (gfar_local_mdio_read(regs, tbipa, MII_BMSR) & BMSR_LSTATUS)
+		goto done;
 
 	/* Single clk mode, mii mode off(for serdes communication) */
 	gfar_local_mdio_write(regs, tbipa, MII_TBICON, TBICON_CLK_SELECT);
@@ -596,6 +608,10 @@ static void gfar_configure_serdes(struct net_device *dev)
 
 	gfar_local_mdio_write(regs, tbipa, MII_BMCR, BMCR_ANENABLE |
 			BMCR_ANRESTART | BMCR_FULLDPLX | BMCR_SPEED1000);
+
+	done:
+	if (bus)
+		mutex_unlock(&bus->mdio_lock);
 }
 
 static void init_registers(struct net_device *dev)
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index bf73eea..0e2595d 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -269,6 +269,27 @@ static struct device_driver gianfar_mdio_driver = {
 	.remove = gfar_mdio_remove,
 };
 
+static int match_mdio_bus(struct device *dev, void *data)
+{
+	const struct gfar_private *priv = data;
+	const struct platform_device *pdev = to_platform_device(dev);
+
+	return !strcmp(pdev->name, gianfar_mdio_driver.name) &&
+		pdev->id == priv->einfo->mdio_bus;
+}
+
+/* Given a gfar_priv structure, find the mii_bus controlled by this device (not
+ * necessarily the same as the bus the gfar's PHY is on), if one exists.
+ * Normally only the first gianfar controls a mii_bus.  */
+struct mii_bus *gfar_get_miibus(const struct gfar_private *priv)
+{
+	/*const*/ struct device *d;
+
+	d = bus_find_device(gianfar_mdio_driver.bus, NULL, (void *)priv,
+			    match_mdio_bus);
+	return d ? dev_get_drvdata(d) : NULL;
+}
+
 int __init gfar_mdio_init(void)
 {
 	return driver_register(&gianfar_mdio_driver);
diff --git a/drivers/net/gianfar_mii.h b/drivers/net/gianfar_mii.h
index 2af28b1..02dc970 100644
--- a/drivers/net/gianfar_mii.h
+++ b/drivers/net/gianfar_mii.h
@@ -18,6 +18,8 @@
 #ifndef __GIANFAR_MII_H
 #define __GIANFAR_MII_H
 
+struct gfar_private; /* forward ref */
+
 #define MIIMIND_BUSY            0x00000001
 #define MIIMIND_NOTVALID        0x00000004
 
@@ -44,6 +46,7 @@ int gfar_mdio_write(struct mii_bus *bus, int mii_id, int regnum, u16 value);
 int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
 			  int regnum, u16 value);
 int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
+struct mii_bus *gfar_get_miibus(const struct gfar_private *priv);
 int __init gfar_mdio_init(void);
 void gfar_mdio_exit(void);
 #endif /* GIANFAR_PHY_H */
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index b1556b2..a5f428b 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -75,7 +75,7 @@
 #include "myri10ge_mcp.h"
 #include "myri10ge_mcp_gen_header.h"
 
-#define MYRI10GE_VERSION_STR "1.4.3-1.371"
+#define MYRI10GE_VERSION_STR "1.4.3-1.375"
 
 MODULE_DESCRIPTION("Myricom 10G driver (10GbE)");
 MODULE_AUTHOR("Maintainer: help@myri.com");
@@ -1393,6 +1393,7 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 		if (tx->req == tx->done) {
 			tx->queue_active = 0;
 			put_be32(htonl(1), tx->send_stop);
+			mmiowb();
 		}
 		__netif_tx_unlock(dev_queue);
 	}
@@ -2864,6 +2865,7 @@ again:
 	if ((mgp->dev->real_num_tx_queues > 1) && tx->queue_active == 0) {
 		tx->queue_active = 1;
 		put_be32(htonl(1), tx->send_go);
+		mmiowb();
 	}
 	tx->pkt_start++;
 	if ((avail - count) < MXGEFW_MAX_SEND_DESC) {
diff --git a/drivers/net/smc91x.c b/drivers/net/smc91x.c
index c70870e..6f9895d 100644
--- a/drivers/net/smc91x.c
+++ b/drivers/net/smc91x.c
@@ -2060,7 +2060,6 @@ static int smc_request_attrib(struct platform_device *pdev,
 			      struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
-	struct smc_local *lp = netdev_priv(ndev);
 
 	if (!res)
 		return 0;
@@ -2075,7 +2074,6 @@ static void smc_release_attrib(struct platform_device *pdev,
 			       struct net_device *ndev)
 {
 	struct resource * res = platform_get_resource_byname(pdev, IORESOURCE_MEM, "smc91x-attrib");
-	struct smc_local *lp = netdev_priv(ndev);
 
 	if (res)
 		release_mem_region(res->start, ATTRIB_SIZE);
diff --git a/include/linux/fsl_devices.h b/include/linux/fsl_devices.h
index 4e625e0..708bab5 100644
--- a/include/linux/fsl_devices.h
+++ b/include/linux/fsl_devices.h
@@ -49,7 +49,8 @@ struct gianfar_platform_data {
 	u32	device_flags;
 	/* board specific information */
 	u32	board_flags;
-	char	bus_id[MII_BUS_ID_SIZE];
+	int	mdio_bus;			/* Bus controlled by us */
+	char	bus_id[MII_BUS_ID_SIZE];	/* Bus PHY is on */
 	u32	phy_id;
 	u8	mac_addr[6];
 	phy_interface_t interface;
