From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 6 Mar 2007 06:48:08 -0500
Message-ID: <20070306114808.GA22724@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:48805 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964980AbXCFLsJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 06:48:09 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 arch/mips/momentum/jaguar_atx/platform.c  |    8 +-
 arch/mips/momentum/ocelot_3/platform.c    |    8 +-
 arch/mips/momentum/ocelot_c/platform.c    |    4 +
 arch/powerpc/platforms/chrp/pegasos_eth.c |    2 +
 arch/ppc/syslib/mv64x60.c                 |   12 ++-
 drivers/net/3c59x.c                       |    8 +-
 drivers/net/bonding/bond_main.c           |   86 +++++--------
 drivers/net/mv643xx_eth.c                 |   53 ++++----
 drivers/net/natsemi.c                     |   24 +++-
 drivers/net/pcnet32.c                     |    4 +-
 drivers/net/sis900.c                      |   10 +-
 drivers/net/tulip/de2104x.c               |    6 +-
 drivers/net/tulip/dmfe.c                  |  204 +++++++++++++++++++---------
 drivers/net/ucc_geth.c                    |   17 ++-
 include/linux/igmp.h                      |    2 +
 include/linux/mv643xx.h                   |    1 +
 net/ipv4/igmp.c                           |   23 ++++
 17 files changed, 302 insertions(+), 170 deletions(-)

Andrew Morton (2):
      revert "drivers/net/tulip/dmfe: support basic carrier detection"
      sis900 warning fixes

Dale Farnsworth (1):
      mv643xx_eth: Place explicit port number in mv643xx_eth_platform_data

Dmitriy Monakhov (1):
      3c59x: Handle pci_enable_device() failure while resuming

Don Fry (1):
      pcnet32: Fix PCnet32 performance bug on non-coherent architecutres

Jay Vosburgh (3):
      bonding: fix double dev_add_pack
      bonding: only receive ARPs for us
      bonding: Improve IGMP join processing

Li Yang (2):
      ucc_geth: Fix BD processing
      ucc_geth: returns NETDEV_TX_BUSY when BD ring is full

Maxim Levitsky (3):
      dmfe: trivial/spelling fixes
      dmfe: fix two bugs
      dmfe: Fix link detection

Prarit Bhargava (1):
      __devinit & __devexit cleanups for de2104x driver

Sergei Shtylyov (1):
      natsemi: netpoll fixes

diff --git a/arch/mips/momentum/jaguar_atx/platform.c b/arch/mips/momentum/jaguar_atx/platform.c
index 771e55f..5618448 100644
--- a/arch/mips/momentum/jaguar_atx/platform.c
+++ b/arch/mips/momentum/jaguar_atx/platform.c
@@ -48,6 +48,8 @@ static struct resource mv64x60_eth0_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -77,6 +79,8 @@ static struct resource mv64x60_eth1_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -105,7 +109,9 @@ static struct resource mv64x60_eth2_resources[] = {
 	},
 };
 
-static struct mv643xx_eth_platform_data eth2_pd;
+static struct mv643xx_eth_platform_data eth2_pd = {
+	.port_number	= 2,
+};
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
diff --git a/arch/mips/momentum/ocelot_3/platform.c b/arch/mips/momentum/ocelot_3/platform.c
index b80733f..44e4c3f 100644
--- a/arch/mips/momentum/ocelot_3/platform.c
+++ b/arch/mips/momentum/ocelot_3/platform.c
@@ -48,6 +48,8 @@ static struct resource mv64x60_eth0_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -77,6 +79,8 @@ static struct resource mv64x60_eth1_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -105,7 +109,9 @@ static struct resource mv64x60_eth2_resources[] = {
 	},
 };
 
-static struct mv643xx_eth_platform_data eth2_pd;
+static struct mv643xx_eth_platform_data eth2_pd = {
+	.port_number	= 2,
+};
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
diff --git a/arch/mips/momentum/ocelot_c/platform.c b/arch/mips/momentum/ocelot_c/platform.c
index f7cd303..7780aa0 100644
--- a/arch/mips/momentum/ocelot_c/platform.c
+++ b/arch/mips/momentum/ocelot_c/platform.c
@@ -47,6 +47,8 @@ static struct resource mv64x60_eth0_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH0,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
@@ -76,6 +78,8 @@ static struct resource mv64x60_eth1_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+
 	.tx_sram_addr	= MV_SRAM_BASE_ETH1,
 	.tx_sram_size	= MV_SRAM_TXRING_SIZE,
 	.tx_queue_size	= MV_SRAM_TXRING_SIZE / 16,
diff --git a/arch/powerpc/platforms/chrp/pegasos_eth.c b/arch/powerpc/platforms/chrp/pegasos_eth.c
index 6ad4b1a..7104567 100644
--- a/arch/powerpc/platforms/chrp/pegasos_eth.c
+++ b/arch/powerpc/platforms/chrp/pegasos_eth.c
@@ -58,6 +58,7 @@ static struct resource mv643xx_eth0_resources[] = {
 
 
 static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH0,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
@@ -87,6 +88,7 @@ static struct resource mv643xx_eth1_resources[] = {
 };
 
 static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
 	.tx_sram_addr = PEGASOS2_SRAM_BASE_ETH1,
 	.tx_sram_size = PEGASOS2_SRAM_TXRING_SIZE,
 	.tx_queue_size = PEGASOS2_SRAM_TXRING_SIZE/16,
diff --git a/arch/ppc/syslib/mv64x60.c b/arch/ppc/syslib/mv64x60.c
index 3b039c3..a6f8b68 100644
--- a/arch/ppc/syslib/mv64x60.c
+++ b/arch/ppc/syslib/mv64x60.c
@@ -339,7 +339,9 @@ static struct resource mv64x60_eth0_resources[] = {
 	},
 };
 
-static struct mv643xx_eth_platform_data eth0_pd;
+static struct mv643xx_eth_platform_data eth0_pd = {
+	.port_number	= 0,
+};
 
 static struct platform_device eth0_device = {
 	.name		= MV643XX_ETH_NAME,
@@ -362,7 +364,9 @@ static struct resource mv64x60_eth1_resources[] = {
 	},
 };
 
-static struct mv643xx_eth_platform_data eth1_pd;
+static struct mv643xx_eth_platform_data eth1_pd = {
+	.port_number	= 1,
+};
 
 static struct platform_device eth1_device = {
 	.name		= MV643XX_ETH_NAME,
@@ -385,7 +389,9 @@ static struct resource mv64x60_eth2_resources[] = {
 	},
 };
 
-static struct mv643xx_eth_platform_data eth2_pd;
+static struct mv643xx_eth_platform_data eth2_pd = {
+	.port_number	= 2,
+};
 
 static struct platform_device eth2_device = {
 	.name		= MV643XX_ETH_NAME,
diff --git a/drivers/net/3c59x.c b/drivers/net/3c59x.c
index 716a472..7299577 100644
--- a/drivers/net/3c59x.c
+++ b/drivers/net/3c59x.c
@@ -822,11 +822,17 @@ static int vortex_resume(struct pci_dev *pdev)
 {
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct vortex_private *vp = netdev_priv(dev);
+	int err;
 
 	if (dev && vp) {
 		pci_set_power_state(pdev, PCI_D0);
 		pci_restore_state(pdev);
-		pci_enable_device(pdev);
+		err = pci_enable_device(pdev);
+		if (err) {
+			printk(KERN_WARNING "%s: Could not enable device \n",
+				dev->name);
+			return err;
+		}
 		pci_set_master(pdev);
 		if (request_irq(dev->irq, vp->full_bus_master_rx ?
 				&boomerang_interrupt : &vortex_interrupt, IRQF_SHARED, dev->name, dev)) {
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index ea73ebf..e4724d8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -60,6 +60,7 @@
 #include <linux/errno.h>
 #include <linux/netdevice.h>
 #include <linux/inetdevice.h>
+#include <linux/igmp.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
 #include <net/sock.h>
@@ -861,6 +862,28 @@ static void bond_mc_delete(struct bonding *bond, void *addr, int alen)
 	}
 }
 
+
+/*
+ * Retrieve the list of registered multicast addresses for the bonding
+ * device and retransmit an IGMP JOIN request to the current active
+ * slave.
+ */
+static void bond_resend_igmp_join_requests(struct bonding *bond)
+{
+	struct in_device *in_dev;
+	struct ip_mc_list *im;
+
+	rcu_read_lock();
+	in_dev = __in_dev_get_rcu(bond->dev);
+	if (in_dev) {
+		for (im = in_dev->mc_list; im; im = im->next) {
+			ip_mc_rejoin_group(im);
+		}
+	}
+
+	rcu_read_unlock();
+}
+
 /*
  * Totally destroys the mc_list in bond
  */
@@ -874,6 +897,7 @@ static void bond_mc_list_destroy(struct bonding *bond)
 		kfree(dmi);
 		dmi = bond->mc_list;
 	}
+        bond->mc_list = NULL;
 }
 
 /*
@@ -967,6 +991,7 @@ static void bond_mc_swap(struct bonding *bond, struct slave *new_active, struct
 		for (dmi = bond->dev->mc_list; dmi; dmi = dmi->next) {
 			dev_mc_add(new_active->dev, dmi->dmi_addr, dmi->dmi_addrlen, 0);
 		}
+		bond_resend_igmp_join_requests(bond);
 	}
 }
 
@@ -3423,15 +3448,21 @@ void bond_register_arp(struct bonding *bond)
 {
 	struct packet_type *pt = &bond->arp_mon_pt;
 
+	if (pt->type)
+		return;
+
 	pt->type = htons(ETH_P_ARP);
-	pt->dev = NULL; /*bond->dev;XXX*/
+	pt->dev = bond->dev;
 	pt->func = bond_arp_rcv;
 	dev_add_pack(pt);
 }
 
 void bond_unregister_arp(struct bonding *bond)
 {
-	dev_remove_pack(&bond->arp_mon_pt);
+	struct packet_type *pt = &bond->arp_mon_pt;
+
+	dev_remove_pack(pt);
+	pt->type = 0;
 }
 
 /*---------------------------- Hashing Policies -----------------------------*/
@@ -4011,42 +4042,6 @@ out:
 	return 0;
 }
 
-static void bond_activebackup_xmit_copy(struct sk_buff *skb,
-                                        struct bonding *bond,
-                                        struct slave *slave)
-{
-	struct sk_buff *skb2 = skb_copy(skb, GFP_ATOMIC);
-	struct ethhdr *eth_data;
-	u8 *hwaddr;
-	int res;
-
-	if (!skb2) {
-		printk(KERN_ERR DRV_NAME ": Error: "
-		       "bond_activebackup_xmit_copy(): skb_copy() failed\n");
-		return;
-	}
-
-	skb2->mac.raw = (unsigned char *)skb2->data;
-	eth_data = eth_hdr(skb2);
-
-	/* Pick an appropriate source MAC address
-	 *	-- use slave's perm MAC addr, unless used by bond
-	 *	-- otherwise, borrow active slave's perm MAC addr
-	 *	   since that will not be used
-	 */
-	hwaddr = slave->perm_hwaddr;
-	if (!memcmp(eth_data->h_source, hwaddr, ETH_ALEN))
-		hwaddr = bond->curr_active_slave->perm_hwaddr;
-
-	/* Set source MAC address appropriately */
-	memcpy(eth_data->h_source, hwaddr, ETH_ALEN);
-
-	res = bond_dev_queue_xmit(bond, skb2, slave->dev);
-	if (res)
-		dev_kfree_skb(skb2);
-
-	return;
-}
 
 /*
  * in active-backup mode, we know that bond->curr_active_slave is always valid if
@@ -4067,21 +4062,6 @@ static int bond_xmit_activebackup(struct sk_buff *skb, struct net_device *bond_d
 	if (!bond->curr_active_slave)
 		goto out;
 
-	/* Xmit IGMP frames on all slaves to ensure rapid fail-over
-	   for multicast traffic on snooping switches */
-	if (skb->protocol == __constant_htons(ETH_P_IP) &&
-	    skb->nh.iph->protocol == IPPROTO_IGMP) {
-		struct slave *slave, *active_slave;
-		int i;
-
-		active_slave = bond->curr_active_slave;
-		bond_for_each_slave_from_to(bond, slave, i, active_slave->next,
-		                            active_slave->prev)
-			if (IS_UP(slave->dev) &&
-			    (slave->link == BOND_LINK_UP))
-				bond_activebackup_xmit_copy(skb, bond, slave);
-	}
-
 	res = bond_dev_queue_xmit(bond, skb, bond->curr_active_slave->dev);
 
 out:
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index be2ddbb..9ba21e0 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1309,7 +1309,7 @@ static void mv643xx_init_ethtool_cmd(struct net_device *dev, int phy_address,
 static int mv643xx_eth_probe(struct platform_device *pdev)
 {
 	struct mv643xx_eth_platform_data *pd;
-	int port_num = pdev->id;
+	int port_num;
 	struct mv643xx_private *mp;
 	struct net_device *dev;
 	u8 *p;
@@ -1319,6 +1319,12 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	int duplex = DUPLEX_HALF;
 	int speed = 0;			/* default to auto-negotiation */
 
+	pd = pdev->dev.platform_data;
+	if (pd == NULL) {
+		printk(KERN_ERR "No mv643xx_eth_platform_data\n");
+		return -ENODEV;
+	}
+
 	dev = alloc_etherdev(sizeof(struct mv643xx_private));
 	if (!dev)
 		return -ENOMEM;
@@ -1331,8 +1337,6 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 	BUG_ON(!res);
 	dev->irq = res->start;
 
-	mp->port_num = port_num;
-
 	dev->open = mv643xx_eth_open;
 	dev->stop = mv643xx_eth_stop;
 	dev->hard_start_xmit = mv643xx_eth_start_xmit;
@@ -1373,39 +1377,40 @@ static int mv643xx_eth_probe(struct platform_device *pdev)
 
 	spin_lock_init(&mp->lock);
 
+	port_num = pd->port_number;
+
 	/* set default config values */
 	eth_port_uc_addr_get(dev, dev->dev_addr);
 	mp->rx_ring_size = MV643XX_ETH_PORT_DEFAULT_RECEIVE_QUEUE_SIZE;
 	mp->tx_ring_size = MV643XX_ETH_PORT_DEFAULT_TRANSMIT_QUEUE_SIZE;
 
-	pd = pdev->dev.platform_data;
-	if (pd) {
-		if (is_valid_ether_addr(pd->mac_addr))
-			memcpy(dev->dev_addr, pd->mac_addr, 6);
+	if (is_valid_ether_addr(pd->mac_addr))
+		memcpy(dev->dev_addr, pd->mac_addr, 6);
 
-		if (pd->phy_addr || pd->force_phy_addr)
-			ethernet_phy_set(port_num, pd->phy_addr);
+	if (pd->phy_addr || pd->force_phy_addr)
+		ethernet_phy_set(port_num, pd->phy_addr);
 
-		if (pd->rx_queue_size)
-			mp->rx_ring_size = pd->rx_queue_size;
+	if (pd->rx_queue_size)
+		mp->rx_ring_size = pd->rx_queue_size;
 
-		if (pd->tx_queue_size)
-			mp->tx_ring_size = pd->tx_queue_size;
+	if (pd->tx_queue_size)
+		mp->tx_ring_size = pd->tx_queue_size;
 
-		if (pd->tx_sram_size) {
-			mp->tx_sram_size = pd->tx_sram_size;
-			mp->tx_sram_addr = pd->tx_sram_addr;
-		}
-
-		if (pd->rx_sram_size) {
-			mp->rx_sram_size = pd->rx_sram_size;
-			mp->rx_sram_addr = pd->rx_sram_addr;
-		}
+	if (pd->tx_sram_size) {
+		mp->tx_sram_size = pd->tx_sram_size;
+		mp->tx_sram_addr = pd->tx_sram_addr;
+	}
 
-		duplex = pd->duplex;
-		speed = pd->speed;
+	if (pd->rx_sram_size) {
+		mp->rx_sram_size = pd->rx_sram_size;
+		mp->rx_sram_addr = pd->rx_sram_addr;
 	}
 
+	duplex = pd->duplex;
+	speed = pd->speed;
+
+	mp->port_num = port_num;
+
 	/* Hook up MII support for ethtool */
 	mp->mii.dev = dev;
 	mp->mii.mdio_read = mv643xx_mdio_read;
diff --git a/drivers/net/natsemi.c b/drivers/net/natsemi.c
index 5c57433..c6172a7 100644
--- a/drivers/net/natsemi.c
+++ b/drivers/net/natsemi.c
@@ -2024,6 +2024,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 	struct netdev_private *np = netdev_priv(dev);
 	void __iomem * ioaddr = ns_ioaddr(dev);
 	unsigned entry;
+	unsigned long flags;
 
 	/* Note: Ordering is important here, set the field with the
 	   "ownership" bit last, and only then increment cur_tx. */
@@ -2037,7 +2038,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 
 	np->tx_ring[entry].addr = cpu_to_le32(np->tx_dma[entry]);
 
-	spin_lock_irq(&np->lock);
+	spin_lock_irqsave(&np->lock, flags);
 
 	if (!np->hands_off) {
 		np->tx_ring[entry].cmd_status = cpu_to_le32(DescOwn | skb->len);
@@ -2056,7 +2057,7 @@ static int start_tx(struct sk_buff *skb, struct net_device *dev)
 		dev_kfree_skb_irq(skb);
 		np->stats.tx_dropped++;
 	}
-	spin_unlock_irq(&np->lock);
+	spin_unlock_irqrestore(&np->lock, flags);
 
 	dev->trans_start = jiffies;
 
@@ -2222,6 +2223,8 @@ static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do)
 		pkt_len = (desc_status & DescSizeMask) - 4;
 		if ((desc_status&(DescMore|DescPktOK|DescRxLong)) != DescPktOK){
 			if (desc_status & DescMore) {
+				unsigned long flags;
+
 				if (netif_msg_rx_err(np))
 					printk(KERN_WARNING
 						"%s: Oversized(?) Ethernet "
@@ -2236,12 +2239,12 @@ static void netdev_rx(struct net_device *dev, int *work_done, int work_to_do)
 				 * reset procedure documented in
 				 * AN-1287. */
 
-				spin_lock_irq(&np->lock);
+				spin_lock_irqsave(&np->lock, flags);
 				reset_rx(dev);
 				reinit_rx(dev);
 				writel(np->ring_dma, ioaddr + RxRingPtr);
 				check_link(dev);
-				spin_unlock_irq(&np->lock);
+				spin_unlock_irqrestore(&np->lock, flags);
 
 				/* We'll enable RX on exit from this
 				 * function. */
@@ -2396,8 +2399,19 @@ static struct net_device_stats *get_stats(struct net_device *dev)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void natsemi_poll_controller(struct net_device *dev)
 {
+	struct netdev_private *np = netdev_priv(dev);
+
 	disable_irq(dev->irq);
-	intr_handler(dev->irq, dev);
+
+	/*
+	 * A real interrupt might have already reached us at this point
+	 * but NAPI might still haven't called us back.  As the interrupt
+	 * status register is cleared by reading, we should prevent an
+	 * interrupt loss in this case...
+	 */
+	if (!np->intr_status)
+		intr_handler(dev->irq, dev);
+
 	enable_irq(dev->irq);
 }
 #endif
diff --git a/drivers/net/pcnet32.c b/drivers/net/pcnet32.c
index 36f9d98..4d94ba7 100644
--- a/drivers/net/pcnet32.c
+++ b/drivers/net/pcnet32.c
@@ -1234,14 +1234,14 @@ static void pcnet32_rx_entry(struct net_device *dev,
 		skb_put(skb, pkt_len);	/* Make room */
 		pci_dma_sync_single_for_cpu(lp->pci_dev,
 					    lp->rx_dma_addr[entry],
-					    PKT_BUF_SZ - 2,
+					    pkt_len,
 					    PCI_DMA_FROMDEVICE);
 		eth_copy_and_sum(skb,
 				 (unsigned char *)(lp->rx_skbuff[entry]->data),
 				 pkt_len, 0);
 		pci_dma_sync_single_for_device(lp->pci_dev,
 					       lp->rx_dma_addr[entry],
-					       PKT_BUF_SZ - 2,
+					       pkt_len,
 					       PCI_DMA_FROMDEVICE);
 	}
 	lp->stats.rx_bytes += skb->len;
diff --git a/drivers/net/sis900.c b/drivers/net/sis900.c
index fb2b530..b3750f2 100644
--- a/drivers/net/sis900.c
+++ b/drivers/net/sis900.c
@@ -968,10 +968,10 @@ static void mdio_write(struct net_device *net_dev, int phy_id, int location,
 
 static u16 sis900_reset_phy(struct net_device *net_dev, int phy_addr)
 {
-	int i = 0;
+	int i;
 	u16 status;
 
-	while (i++ < 2)
+	for (i = 0; i < 2; i++)
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	mdio_write( net_dev, phy_addr, MII_CONTROL, MII_CNTL_RESET );
@@ -1430,7 +1430,7 @@ static void sis900_auto_negotiate(struct net_device *net_dev, int phy_addr)
 	int i = 0;
 	u32 status;
 
-	while (i++ < 2)
+	for (i = 0; i < 2; i++)
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK)){
@@ -1466,9 +1466,9 @@ static void sis900_read_mode(struct net_device *net_dev, int *speed, int *duplex
 	int phy_addr = sis_priv->cur_phy;
 	u32 status;
 	u16 autoadv, autorec;
-	int i = 0;
+	int i;
 
-	while (i++ < 2)
+	for (i = 0; i < 2; i++)
 		status = mdio_read(net_dev, phy_addr, MII_STATUS);
 
 	if (!(status & MII_STAT_LINK))
diff --git a/drivers/net/tulip/de2104x.c b/drivers/net/tulip/de2104x.c
index dacea4f..c82befa 100644
--- a/drivers/net/tulip/de2104x.c
+++ b/drivers/net/tulip/de2104x.c
@@ -1685,7 +1685,7 @@ static const struct ethtool_ops de_ethtool_ops = {
 	.get_regs		= de_get_regs,
 };
 
-static void __init de21040_get_mac_address (struct de_private *de)
+static void __devinit de21040_get_mac_address (struct de_private *de)
 {
 	unsigned i;
 
@@ -1703,7 +1703,7 @@ static void __init de21040_get_mac_address (struct de_private *de)
 	}
 }
 
-static void __init de21040_get_media_info(struct de_private *de)
+static void __devinit de21040_get_media_info(struct de_private *de)
 {
 	unsigned int i;
 
@@ -1765,7 +1765,7 @@ static unsigned __devinit tulip_read_eeprom(void __iomem *regs, int location, in
 	return retval;
 }
 
-static void __init de21041_get_srom_info (struct de_private *de)
+static void __devinit de21041_get_srom_info (struct de_private *de)
 {
 	unsigned i, sa_offset = 0, ofs;
 	u8 ee_data[DE_EEPROM_SIZE + 6] = {};
diff --git a/drivers/net/tulip/dmfe.c b/drivers/net/tulip/dmfe.c
index 7f59a3d..24a29c9 100644
--- a/drivers/net/tulip/dmfe.c
+++ b/drivers/net/tulip/dmfe.c
@@ -143,9 +143,16 @@
 #define DMFE_TX_TIMEOUT ((3*HZ)/2)	/* tx packet time-out time 1.5 s" */
 #define DMFE_TX_KICK 	(HZ/2)	/* tx packet Kick-out time 0.5 s" */
 
-#define DMFE_DBUG(dbug_now, msg, value) if (dmfe_debug || (dbug_now)) printk(KERN_ERR DRV_NAME ": %s %lx\n", (msg), (long) (value))
+#define DMFE_DBUG(dbug_now, msg, value) \
+	do { \
+ 		if (dmfe_debug || (dbug_now)) \
+			printk(KERN_ERR DRV_NAME ": %s %lx\n",\
+ 				(msg), (long) (value)); \
+	} while (0)
 
-#define SHOW_MEDIA_TYPE(mode) printk(KERN_ERR DRV_NAME ": Change Speed to %sMhz %s duplex\n",mode & 1 ?"100":"10", mode & 4 ? "full":"half");
+#define SHOW_MEDIA_TYPE(mode) \
+	printk (KERN_INFO DRV_NAME ": Change Speed to %sMhz %s duplex\n" , \
+		(mode & 1) ? "100":"10", (mode & 4) ? "full":"half");
 
 
 /* CR9 definition: SROM/MII */
@@ -163,10 +170,20 @@
 
 #define SROM_V41_CODE   0x14
 
-#define SROM_CLK_WRITE(data, ioaddr) outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5);outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr);udelay(5);outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr);udelay(5);
+#define SROM_CLK_WRITE(data, ioaddr) \
+	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
+	udelay(5); \
+	outl(data|CR9_SROM_READ|CR9_SRCS|CR9_SRCLK,ioaddr); \
+	udelay(5); \
+	outl(data|CR9_SROM_READ|CR9_SRCS,ioaddr); \
+	udelay(5);
+
+#define __CHK_IO_SIZE(pci_id, dev_rev) \
+ (( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x02000030) ) ? \
+	DM9102A_IO_SIZE: DM9102_IO_SIZE)
 
-#define __CHK_IO_SIZE(pci_id, dev_rev) ( ((pci_id)==PCI_DM9132_ID) || ((dev_rev) >= 0x02000030) ) ? DM9102A_IO_SIZE: DM9102_IO_SIZE
-#define CHK_IO_SIZE(pci_dev, dev_rev) __CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, dev_rev)
+#define CHK_IO_SIZE(pci_dev, dev_rev) \
+	(__CHK_IO_SIZE(((pci_dev)->device << 16) | (pci_dev)->vendor, dev_rev))
 
 /* Sten Check */
 #define DEVICE net_device
@@ -187,7 +204,7 @@ struct rx_desc {
 struct dmfe_board_info {
 	u32 chip_id;			/* Chip vendor/Device ID */
 	u32 chip_revision;		/* Chip revision */
-	struct DEVICE *dev;		/* net device */
+	struct DEVICE *next_dev;	/* next device */
 	struct pci_dev *pdev;		/* PCI device */
 	spinlock_t lock;
 
@@ -231,7 +248,6 @@ struct dmfe_board_info {
 	u8 media_mode;			/* user specify media mode */
 	u8 op_mode;			/* real work media mode */
 	u8 phy_addr;
-	u8 link_failed;			/* Ever link failed */
 	u8 wait_reset;			/* Hardware failed, need to reset */
 	u8 dm910x_chk_mode;		/* Operating mode check */
 	u8 first_in_callback;		/* Flag to record state */
@@ -329,7 +345,7 @@ static void dmfe_program_DM9802(struct dmfe_board_info *);
 static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * );
 static void dmfe_set_phyxcer(struct dmfe_board_info *);
 
-/* DM910X network baord routine ---------------------------- */
+/* DM910X network board routine ---------------------------- */
 
 /*
  *	Search DM910X board ,allocate space and register it
@@ -356,7 +372,8 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	SET_NETDEV_DEV(dev, &pdev->dev);
 
 	if (pci_set_dma_mask(pdev, DMA_32BIT_MASK)) {
-		printk(KERN_WARNING DRV_NAME ": 32-bit PCI DMA not available.\n");
+		printk(KERN_WARNING DRV_NAME
+			": 32-bit PCI DMA not available.\n");
 		err = -ENODEV;
 		goto err_out_free;
 	}
@@ -399,11 +416,12 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	/* Init system & device */
 	db = netdev_priv(dev);
 
-	db->dev = dev;
-
 	/* Allocate Tx/Rx descriptor memory */
-	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) * DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
-	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
+	db->desc_pool_ptr = pci_alloc_consistent(pdev, sizeof(struct tx_desc) *
+			DESC_ALL_CNT + 0x20, &db->desc_pool_dma_ptr);
+
+	db->buf_pool_ptr = pci_alloc_consistent(pdev, TX_BUF_ALLOC *
+			TX_DESC_CNT + 4, &db->buf_pool_dma_ptr);
 
 	db->first_tx_desc = (struct tx_desc *) db->desc_pool_ptr;
 	db->first_tx_desc_dma = db->desc_pool_dma_ptr;
@@ -428,7 +446,7 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 	dev->poll_controller = &poll_dmfe;
 #endif
 	dev->ethtool_ops = &netdev_ethtool_ops;
-	netif_carrier_off(db->dev);
+	netif_carrier_off(dev);
 	spin_lock_init(&db->lock);
 
 	pci_read_config_dword(pdev, 0x50, &pci_pmr);
@@ -440,7 +458,8 @@ static int __devinit dmfe_init_one (struct pci_dev *pdev,
 
 	/* read 64 word srom data */
 	for (i = 0; i < 64; i++)
-		((u16 *) db->srom)[i] = cpu_to_le16(read_srom_word(db->ioaddr, i));
+		((u16 *) db->srom)[i] =
+			cpu_to_le16(read_srom_word(db->ioaddr, i));
 
 	/* Set Node address */
 	for (i = 0; i < 6; i++)
@@ -482,14 +501,17 @@ static void __devexit dmfe_remove_one (struct pci_dev *pdev)
 	DMFE_DBUG(0, "dmfe_remove_one()", 0);
 
  	if (dev) {
+
+		unregister_netdev(dev);
+
 		pci_free_consistent(db->pdev, sizeof(struct tx_desc) *
 					DESC_ALL_CNT + 0x20, db->desc_pool_ptr,
  					db->desc_pool_dma_ptr);
 		pci_free_consistent(db->pdev, TX_BUF_ALLOC * TX_DESC_CNT + 4,
 					db->buf_pool_ptr, db->buf_pool_dma_ptr);
-		unregister_netdev(dev);
 		pci_release_regions(pdev);
 		free_netdev(dev);	/* free board information */
+
 		pci_set_drvdata(pdev, NULL);
 	}
 
@@ -509,7 +531,8 @@ static int dmfe_open(struct DEVICE *dev)
 
 	DMFE_DBUG(0, "dmfe_open", 0);
 
-	ret = request_irq(dev->irq, &dmfe_interrupt, IRQF_SHARED, dev->name, dev);
+	ret = request_irq(dev->irq, &dmfe_interrupt,
+			  IRQF_SHARED, dev->name, dev);
 	if (ret)
 		return ret;
 
@@ -518,7 +541,6 @@ static int dmfe_open(struct DEVICE *dev)
 	db->tx_packet_cnt = 0;
 	db->tx_queue_cnt = 0;
 	db->rx_avail_cnt = 0;
-	db->link_failed = 1;
 	db->wait_reset = 0;
 
 	db->first_in_callback = 0;
@@ -650,7 +672,8 @@ static int dmfe_start_xmit(struct sk_buff *skb, struct DEVICE *dev)
 	/* No Tx resource check, it never happen nromally */
 	if (db->tx_queue_cnt >= TX_FREE_DESC_CNT) {
 		spin_unlock_irqrestore(&db->lock, flags);
-		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n", db->tx_queue_cnt);
+		printk(KERN_ERR DRV_NAME ": No Tx resource %ld\n",
+		       db->tx_queue_cnt);
 		return 1;
 	}
 
@@ -722,7 +745,8 @@ static int dmfe_stop(struct DEVICE *dev)
 
 #if 0
 	/* show statistic counter */
-	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
+	printk(DRV_NAME ": FU:%lx EC:%lx LC:%lx NC:%lx"
+		" LOC:%lx TXJT:%lx RESET:%lx RCR8:%lx FAL:%lx TT:%lx\n",
 		db->tx_fifo_underrun, db->tx_excessive_collision,
 		db->tx_late_collision, db->tx_no_carrier, db->tx_loss_carrier,
 		db->tx_jabber_timeout, db->reset_count, db->reset_cr8,
@@ -905,7 +929,7 @@ static inline u32 cal_CRC(unsigned char * Data, unsigned int Len, u8 flag)
 static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 {
 	struct rx_desc *rxptr;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *newskb;
 	int rxlen;
 	u32 rdes0;
 
@@ -919,7 +943,9 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 		db->rx_avail_cnt--;
 		db->interval_rx_cnt++;
 
-		pci_unmap_single(db->pdev, le32_to_cpu(rxptr->rdes2), RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
+		pci_unmap_single(db->pdev, le32_to_cpu(rxptr->rdes2),
+				 RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE);
+
 		if ( (rdes0 & 0x300) != 0x300) {
 			/* A packet without First/Last flag */
 			/* reuse this SKB */
@@ -956,9 +982,11 @@ static void dmfe_rx_packet(struct DEVICE *dev, struct dmfe_board_info * db)
 				} else {
 					/* Good packet, send to upper layer */
 					/* Shorst packet used new SKB */
-					if ( (rxlen < RX_COPY_SIZE) &&
-						( (skb = dev_alloc_skb(rxlen + 2) )
-						!= NULL) ) {
+					if ((rxlen < RX_COPY_SIZE) &&
+						((newskb = dev_alloc_skb(rxlen + 2))
+						!= NULL)) {
+
+						skb = newskb;
 						/* size less than COPY_SIZE, allocate a rxlen SKB */
 						skb->dev = dev;
 						skb_reserve(skb, 2); /* 16byte align */
@@ -1069,6 +1097,8 @@ static void dmfe_timer(unsigned long data)
 	struct dmfe_board_info *db = netdev_priv(dev);
  	unsigned long flags;
 
+	int link_ok, link_ok_phy;
+
 	DMFE_DBUG(0, "dmfe_timer()", 0);
 	spin_lock_irqsave(&db->lock, flags);
 
@@ -1078,7 +1108,8 @@ static void dmfe_timer(unsigned long data)
 		if (db->chip_type && (db->chip_id==PCI_DM9102_ID)) {
 			db->cr6_data &= ~0x40000;
 			update_cr6(db->cr6_data, db->ioaddr);
-			phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
+			phy_write(db->ioaddr,
+				  db->phy_addr, 0, 0x1000, db->chip_id);
 			db->cr6_data |= 0x40000;
 			update_cr6(db->cr6_data, db->ioaddr);
 			db->timer.expires = DMFE_TIMER_WUT + HZ * 2;
@@ -1139,21 +1170,41 @@ static void dmfe_timer(unsigned long data)
 		(db->chip_revision == 0x02000010)) ) {
 		/* DM9102A Chip */
 		if (tmp_cr12 & 2)
-			tmp_cr12 = 0x0;		/* Link failed */
+			link_ok = 0;
 		else
-			tmp_cr12 = 0x3;	/* Link OK */
+			link_ok = 1;
 	}
+	else
+		/*0x43 is used instead of 0x3 because bit 6 should represent
+			link status of external PHY */
+		link_ok = (tmp_cr12 & 0x43) ? 1 : 0;
+
+
+	/* If chip reports that link is failed it could be because external
+		PHY link status pin is not conected correctly to chip
+		To be sure ask PHY too.
+	*/
+
+	/* need a dummy read because of PHY's register latch*/
+	phy_read (db->ioaddr, db->phy_addr, 1, db->chip_id);
+	link_ok_phy = (phy_read (db->ioaddr,
+		       db->phy_addr, 1, db->chip_id) & 0x4) ? 1 : 0;
 
-	if ( !(tmp_cr12 & 0x3) && !db->link_failed ) {
+	if (link_ok_phy != link_ok) {
+		DMFE_DBUG (0, "PHY and chip report different link status", 0);
+		link_ok = link_ok | link_ok_phy;
+ 	}
+
+	if ( !link_ok && netif_carrier_ok(dev)) {
 		/* Link Failed */
 		DMFE_DBUG(0, "Link Failed", tmp_cr12);
-		db->link_failed = 1;
-		netif_carrier_off(db->dev);
+		netif_carrier_off(dev);
 
 		/* For Force 10/100M Half/Full mode: Enable Auto-Nego mode */
 		/* AUTO or force 1M Homerun/Longrun don't need */
 		if ( !(db->media_mode & 0x38) )
-			phy_write(db->ioaddr, db->phy_addr, 0, 0x1000, db->chip_id);
+			phy_write(db->ioaddr, db->phy_addr,
+				  0, 0x1000, db->chip_id);
 
 		/* AUTO mode, if INT phyxcer link failed, select EXT device */
 		if (db->media_mode & DMFE_AUTO) {
@@ -1162,21 +1213,19 @@ static void dmfe_timer(unsigned long data)
 			db->cr6_data&=~0x00000200;	/* bit9=0, HD mode */
 			update_cr6(db->cr6_data, db->ioaddr);
 		}
-	} else
-		if ((tmp_cr12 & 0x3) && db->link_failed) {
-			DMFE_DBUG(0, "Link link OK", tmp_cr12);
-			db->link_failed = 0;
-
-			/* Auto Sense Speed */
-			if ( (db->media_mode & DMFE_AUTO) &&
-				dmfe_sense_speed(db) )
-				db->link_failed = 1;
-			else
-				netif_carrier_on(db->dev);
-			dmfe_process_mode(db);
-			/* SHOW_MEDIA_TYPE(db->op_mode); */
+	} else if (!netif_carrier_ok(dev)) {
+
+		DMFE_DBUG(0, "Link link OK", tmp_cr12);
+
+		/* Auto Sense Speed */
+		if ( !(db->media_mode & DMFE_AUTO) || !dmfe_sense_speed(db)) {
+			netif_carrier_on(dev);
+			SHOW_MEDIA_TYPE(db->op_mode);
 		}
 
+		dmfe_process_mode(db);
+	}
+
 	/* HPNA remote command check */
 	if (db->HPNA_command & 0xf00) {
 		db->HPNA_timer--;
@@ -1221,7 +1270,7 @@ static void dmfe_dynamic_reset(struct DEVICE *dev)
 	db->tx_packet_cnt = 0;
 	db->tx_queue_cnt = 0;
 	db->rx_avail_cnt = 0;
-	db->link_failed = 1;
+	netif_carrier_off(dev);
 	db->wait_reset = 0;
 
 	/* Re-initilize DM910X board */
@@ -1259,7 +1308,8 @@ static void dmfe_reuse_skb(struct dmfe_board_info *db, struct sk_buff * skb)
 
 	if (!(rxptr->rdes0 & cpu_to_le32(0x80000000))) {
 		rxptr->rx_skb_ptr = skb;
-		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
+		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev,
+			    skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
 		wmb();
 		rxptr->rdes0 = cpu_to_le32(0x80000000);
 		db->rx_avail_cnt++;
@@ -1291,8 +1341,11 @@ static void dmfe_descriptor_init(struct dmfe_board_info *db, unsigned long ioadd
 	outl(db->first_tx_desc_dma, ioaddr + DCR4);     /* TX DESC address */
 
 	/* rx descriptor start pointer */
-	db->first_rx_desc = (void *)db->first_tx_desc + sizeof(struct tx_desc) * TX_DESC_CNT;
-	db->first_rx_desc_dma =  db->first_tx_desc_dma + sizeof(struct tx_desc) * TX_DESC_CNT;
+	db->first_rx_desc = (void *)db->first_tx_desc +
+			sizeof(struct tx_desc) * TX_DESC_CNT;
+
+	db->first_rx_desc_dma =  db->first_tx_desc_dma +
+			sizeof(struct tx_desc) * TX_DESC_CNT;
 	db->rx_insert_ptr = db->first_rx_desc;
 	db->rx_ready_ptr = db->first_rx_desc;
 	outl(db->first_rx_desc_dma, ioaddr + DCR3);	/* RX DESC address */
@@ -1470,7 +1523,8 @@ static void allocate_rx_buffer(struct dmfe_board_info *db)
 		if ( ( skb = dev_alloc_skb(RX_ALLOC_SIZE) ) == NULL )
 			break;
 		rxptr->rx_skb_ptr = skb; /* FIXME (?) */
-		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data, RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
+		rxptr->rdes2 = cpu_to_le32( pci_map_single(db->pdev, skb->data,
+				    RX_ALLOC_SIZE, PCI_DMA_FROMDEVICE) );
 		wmb();
 		rxptr->rdes0 = cpu_to_le32(0x80000000);
 		rxptr = rxptr->next_rx_desc;
@@ -1510,7 +1564,8 @@ static u16 read_srom_word(long ioaddr, int offset)
 	for (i = 16; i > 0; i--) {
 		outl(CR9_SROM_READ | CR9_SRCS | CR9_SRCLK, cr9_ioaddr);
 		udelay(5);
-		srom_data = (srom_data << 1) | ((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
+		srom_data = (srom_data << 1) |
+				((inl(cr9_ioaddr) & CR9_CRDOUT) ? 1 : 0);
 		outl(CR9_SROM_READ | CR9_SRCS, cr9_ioaddr);
 		udelay(5);
 	}
@@ -1537,9 +1592,11 @@ static u8 dmfe_sense_speed(struct dmfe_board_info * db)
 
 	if ( (phy_mode & 0x24) == 0x24 ) {
 		if (db->chip_id == PCI_DM9132_ID)	/* DM9132 */
-			phy_mode = phy_read(db->ioaddr, db->phy_addr, 7, db->chip_id) & 0xf000;
+			phy_mode = phy_read(db->ioaddr,
+				    db->phy_addr, 7, db->chip_id) & 0xf000;
 		else 				/* DM9102/DM9102A */
-			phy_mode = phy_read(db->ioaddr, db->phy_addr, 17, db->chip_id) & 0xf000;
+			phy_mode = phy_read(db->ioaddr,
+				    db->phy_addr, 17, db->chip_id) & 0xf000;
 		/* printk(DRV_NAME ": Phy_mode %x ",phy_mode); */
 		switch (phy_mode) {
 		case 0x1000: db->op_mode = DMFE_10MHF; break;
@@ -1576,8 +1633,11 @@ static void dmfe_set_phyxcer(struct dmfe_board_info *db)
 
 	/* DM9009 Chip: Phyxcer reg18 bit12=0 */
 	if (db->chip_id == PCI_DM9009_ID) {
-		phy_reg = phy_read(db->ioaddr, db->phy_addr, 18, db->chip_id) & ~0x1000;
-		phy_write(db->ioaddr, db->phy_addr, 18, phy_reg, db->chip_id);
+		phy_reg = phy_read(db->ioaddr,
+				   db->phy_addr, 18, db->chip_id) & ~0x1000;
+
+		phy_write(db->ioaddr,
+			  db->phy_addr, 18, phy_reg, db->chip_id);
 	}
 
 	/* Phyxcer capability setting */
@@ -1650,10 +1710,12 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
 			case DMFE_100MHF: phy_reg = 0x2000; break;
 			case DMFE_100MFD: phy_reg = 0x2100; break;
 			}
-			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
+			phy_write(db->ioaddr,
+				  db->phy_addr, 0, phy_reg, db->chip_id);
        			if ( db->chip_type && (db->chip_id == PCI_DM9102_ID) )
 				mdelay(20);
-			phy_write(db->ioaddr, db->phy_addr, 0, phy_reg, db->chip_id);
+			phy_write(db->ioaddr,
+				  db->phy_addr, 0, phy_reg, db->chip_id);
 		}
 	}
 }
@@ -1663,7 +1725,8 @@ static void dmfe_process_mode(struct dmfe_board_info *db)
  *	Write a word to Phy register
  */
 
-static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data, u32 chip_id)
+static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset,
+		      u16 phy_data, u32 chip_id)
 {
 	u16 i;
 	unsigned long ioaddr;
@@ -1689,11 +1752,13 @@ static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data
 
 		/* Send Phy address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* Send register address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* written trasnition */
 		phy_write_1bit(ioaddr, PHY_DATA_1);
@@ -1701,7 +1766,8 @@ static void phy_write(unsigned long iobase, u8 phy_addr, u8 offset, u16 phy_data
 
 		/* Write a word data to PHY controller */
 		for ( i = 0x8000; i > 0; i >>= 1)
-			phy_write_1bit(ioaddr, phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       phy_data & i ? PHY_DATA_1 : PHY_DATA_0);
 	}
 }
 
@@ -1738,11 +1804,13 @@ static u16 phy_read(unsigned long iobase, u8 phy_addr, u8 offset, u32 chip_id)
 
 		/* Send Phy address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       phy_addr & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* Send register address */
 		for (i = 0x10; i > 0; i = i >> 1)
-			phy_write_1bit(ioaddr, offset & i ? PHY_DATA_1 : PHY_DATA_0);
+			phy_write_1bit(ioaddr,
+				       offset & i ? PHY_DATA_1 : PHY_DATA_0);
 
 		/* Skip transition state */
 		phy_read_1bit(ioaddr);
@@ -1963,7 +2031,8 @@ static void dmfe_HPNA_remote_cmd_chk(struct dmfe_board_info * db)
 
 	/* Check remote device status match our setting ot not */
 	if ( phy_reg != (db->HPNA_command & 0x0f00) ) {
-		phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command, db->chip_id);
+		phy_write(db->ioaddr, db->phy_addr, 16, db->HPNA_command,
+			  db->chip_id);
 		db->HPNA_timer=8;
 	} else
 		db->HPNA_timer=600;	/* Match, every 10 minutes, check */
@@ -2003,8 +2072,11 @@ module_param(HPNA_tx_cmd, byte, 0);
 module_param(HPNA_NoiseFloor, byte, 0);
 module_param(SF_mode, byte, 0);
 MODULE_PARM_DESC(debug, "Davicom DM9xxx enable debugging (0-1)");
-MODULE_PARM_DESC(mode, "Davicom DM9xxx: Bit 0: 10/100Mbps, bit 2: duplex, bit 8: HomePNA");
-MODULE_PARM_DESC(SF_mode, "Davicom DM9xxx special function (bit 0: VLAN, bit 1 Flow Control, bit 2: TX pause packet)");
+MODULE_PARM_DESC(mode, "Davicom DM9xxx: "
+		"Bit 0: 10/100Mbps, bit 2: duplex, bit 8: HomePNA");
+
+MODULE_PARM_DESC(SF_mode, "Davicom DM9xxx special function "
+		"(bit 0: VLAN, bit 1 Flow Control, bit 2: TX pause packet)");
 
 /*	Description:
  *	when user used insmod to add module, system invoked init_module()
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 885e73d..dab88b9 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3598,17 +3598,20 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	/* Move to next BD in the ring */
 	if (!(bd_status & T_W))
-		ugeth->txBd[txQ] = bd + sizeof(struct qe_bd);
+		bd += sizeof(struct qe_bd);
 	else
-		ugeth->txBd[txQ] = ugeth->p_tx_bd_ring[txQ];
+		bd = ugeth->p_tx_bd_ring[txQ];
 
 	/* If the next BD still needs to be cleaned up, then the bds
 	   are full.  We need to tell the kernel to stop sending us stuff. */
 	if (bd == ugeth->confBd[txQ]) {
 		if (!netif_queue_stopped(dev))
 			netif_stop_queue(dev);
+		return NETDEV_TX_BUSY;
 	}
 
+	ugeth->txBd[txQ] = bd;
+
 	if (ugeth->p_scheduler) {
 		ugeth->cpucount[txQ]++;
 		/* Indicate to QE that there are more Tx bds ready for
@@ -3620,7 +3623,7 @@ static int ucc_geth_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	spin_unlock_irq(&ugeth->lock);
 
-	return 0;
+	return NETDEV_TX_OK;
 }
 
 static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit)
@@ -3722,7 +3725,7 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 		/* Handle the transmitted buffer and release */
 		/* the BD to be used with the current frame  */
 
-		if ((bd = ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
+		if ((bd == ugeth->txBd[txQ]) && (netif_queue_stopped(dev) == 0))
 			break;
 
 		ugeth->stats.tx_packets++;
@@ -3741,10 +3744,12 @@ static int ucc_geth_tx(struct net_device *dev, u8 txQ)
 
 		/* Advance the confirmation BD pointer */
 		if (!(bd_status & T_W))
-			ugeth->confBd[txQ] += sizeof(struct qe_bd);
+			bd += sizeof(struct qe_bd);
 		else
-			ugeth->confBd[txQ] = ugeth->p_tx_bd_ring[txQ];
+			bd = ugeth->p_tx_bd_ring[txQ];
+		bd_status = in_be32((u32 *)bd);
 	}
+	ugeth->confBd[txQ] = bd;
 	return 0;
 }
 
diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 9dbb525..a113fe6 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -218,5 +218,7 @@ extern void ip_mc_up(struct in_device *);
 extern void ip_mc_down(struct in_device *);
 extern void ip_mc_dec_group(struct in_device *in_dev, __be32 addr);
 extern void ip_mc_inc_group(struct in_device *in_dev, __be32 addr);
+extern void ip_mc_rejoin_group(struct ip_mc_list *im);
+
 #endif
 #endif
diff --git a/include/linux/mv643xx.h b/include/linux/mv643xx.h
index e7d4da1..c6d4ab8 100644
--- a/include/linux/mv643xx.h
+++ b/include/linux/mv643xx.h
@@ -1288,6 +1288,7 @@ struct mv64xxx_i2c_pdata {
 #define MV643XX_ETH_NAME	"mv643xx_eth"
 
 struct mv643xx_eth_platform_data {
+	int		port_number;
 	u16		force_phy_addr;	/* force override if phy_addr == 0 */
 	u16		phy_addr;
 
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 0637213..1c6a084 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1251,6 +1251,28 @@ out:
 }
 
 /*
+ *	Resend IGMP JOIN report; used for bonding.
+ */
+void ip_mc_rejoin_group(struct ip_mc_list *im)
+{
+	struct in_device *in_dev = im->interface;
+
+#ifdef CONFIG_IP_MULTICAST
+	if (im->multiaddr == IGMP_ALL_HOSTS)
+		return;
+
+	if (IGMP_V1_SEEN(in_dev) || IGMP_V2_SEEN(in_dev)) {
+		igmp_mod_timer(im, IGMP_Initial_Report_Delay);
+		return;
+	}
+	/* else, v3 */
+	im->crcount = in_dev->mr_qrv ? in_dev->mr_qrv :
+		IGMP_Unsolicited_Report_Count;
+	igmp_ifc_event(in_dev);
+#endif
+}
+
+/*
  *	A socket has left a multicast group on device dev
  */
 
@@ -2596,3 +2618,4 @@ int __init igmp_mc_proc_init(void)
 EXPORT_SYMBOL(ip_mc_dec_group);
 EXPORT_SYMBOL(ip_mc_inc_group);
 EXPORT_SYMBOL(ip_mc_join_group);
+EXPORT_SYMBOL(ip_mc_rejoin_group);
