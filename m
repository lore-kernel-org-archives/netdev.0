From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Fri, 15 Feb 2008 11:03:14 -0500
Message-ID: <20080215160314.GA13609@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:47933 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756743AbYBOQDP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Feb 2008 11:03:15 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Process note:  'upstream-davem' continues the git history that began
the previous push.  This sometimes happens when I continue to commit
locally, working in parallel while waiting for changes to hit Linus
upstream.

As current net-2.6.git appears to have the same commit ids that I
submitted in the previous push, this should be no problem at all,
just wanted you to know.

Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/e1000/e1000_ethtool.c |    2 +-
 drivers/net/e1000/e1000_main.c    |    8 ++++
 drivers/net/e1000e/netdev.c       |   34 ++---------------
 drivers/net/gianfar.c             |    4 +-
 drivers/net/gianfar_mii.c         |    4 +-
 drivers/net/hamradio/mkiss.c      |    5 +--
 drivers/net/igb/igb_ethtool.c     |    2 +-
 drivers/net/igb/igb_main.c        |   28 --------------
 drivers/net/ixgb/ixgb_ethtool.c   |    2 +-
 drivers/net/ixgbe/ixgbe_main.c    |   41 +++++++++++++++++----
 drivers/net/pcmcia/smc91c92_cs.c  |   12 +++++-
 drivers/net/tsi108_eth.c          |   72 +++++++++++++++++++++++++-----------
 12 files changed, 114 insertions(+), 100 deletions(-)

Al Viro (1):
      gianfar iomem misannotations

Alex Bounine (5):
      Tsi108_eth: add missing linking to driver data
      Tsi108_eth: fix detection of 1000Mb mode
      Tsi108_eth: remove not needed code
      Tsi108_eth: fix link recovery after disconnect
      Tsi108_eth: Add ethtool support

Auke Kok (7):
      e1000: warn if this driver is used for e1000e devices
      e1000e: Fix logic reversal keeping link active
      ixgbe: warn when device is in a x4 or lower width slot
      ixgbe: Disallow device reset during ethtool test
      ixgbe: remove accidentally added #ifdef
      e1000e: Fix CRC stripping in hardware context bug
      ixgbe: Correctly obtain protocol information on transmit

Chuck Ebbert (1):
      Fix station address detection in smc

David Graham (2):
      igb: PCIe devices do not need to unset MANC_ARP_ENA
      e1000e: PCIe devices do not need to unset MANC_ARP_ENA

Jarek Poplawski (1):
      mkiss: ax_bump() locking fix

Julia Lawall (1):
      replace code with FIELD_SIZEOF

diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index d876787..85e66f4 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -50,7 +50,7 @@ struct e1000_stats {
 	int stat_offset;
 };
 
-#define E1000_STAT(m) sizeof(((struct e1000_adapter *)0)->m), \
+#define E1000_STAT(m) FIELD_SIZEOF(struct e1000_adapter, m), \
 		      offsetof(struct e1000_adapter, m)
 static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "rx_packets", E1000_STAT(stats.gprc) },
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d4ee8ec..0991648 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1195,6 +1195,14 @@ e1000_probe(struct pci_dev *pdev,
 
 	printk("%s\n", print_mac(mac, netdev->dev_addr));
 
+	if (adapter->hw.bus_type == e1000_bus_type_pci_express) {
+		DPRINTK(PROBE, WARNING, "This device (id %04x:%04x) will no "
+			"longer be supported by this driver in the future.\n",
+			pdev->vendor, pdev->device);
+		DPRINTK(PROBE, WARNING, "please use the \"e1000e\" "
+			"driver instead.\n");
+	}
+
 	/* reset the hardware with the new settings */
 	e1000_reset(adapter);
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index f58f017..3031d6d 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -1055,23 +1055,6 @@ static void e1000_release_hw_control(struct e1000_adapter *adapter)
 	}
 }
 
-static void e1000_release_manageability(struct e1000_adapter *adapter)
-{
-	if (adapter->flags & FLAG_MNG_PT_ENABLED) {
-		struct e1000_hw *hw = &adapter->hw;
-
-		u32 manc = er32(MANC);
-
-		/* re-enable hardware interception of ARP */
-		manc |= E1000_MANC_ARP_EN;
-		manc &= ~E1000_MANC_EN_MNG2HOST;
-
-		/* don't explicitly have to mess with MANC2H since
-		 * MANC has an enable disable that gates MANC2H */
-		ew32(MANC, manc);
-	}
-}
-
 /**
  * @e1000_alloc_ring - allocate memory for a ring structure
  **/
@@ -1561,9 +1544,6 @@ static void e1000_init_manageability(struct e1000_adapter *adapter)
 
 	manc = er32(MANC);
 
-	/* disable hardware interception of ARP */
-	manc &= ~(E1000_MANC_ARP_EN);
-
 	/* enable receiving management packets to the host. this will probably
 	 * generate destination unreachable messages from the host OS, but
 	 * the packets will be handled on SMBUS */
@@ -1690,6 +1670,9 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 	else
 		rctl |= E1000_RCTL_LPE;
 
+	/* Enable hardware CRC frame stripping */
+	rctl |= E1000_RCTL_SECRC;
+
 	/* Setup buffer sizes */
 	rctl &= ~E1000_RCTL_SZ_4096;
 	rctl |= E1000_RCTL_BSEX;
@@ -1755,9 +1738,6 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
 
 		/* Enable Packet split descriptors */
 		rctl |= E1000_RCTL_DTYP_PS;
-		
-		/* Enable hardware CRC frame stripping */
-		rctl |= E1000_RCTL_SECRC;
 
 		psrctl |= adapter->rx_ps_bsize0 >>
 			E1000_PSRCTL_BSIZE0_SHIFT;
@@ -2008,7 +1988,7 @@ static void e1000_power_down_phy(struct e1000_adapter *adapter)
 	u16 mii_reg;
 
 	/* WoL is enabled */
-	if (!adapter->wol)
+	if (adapter->wol)
 		return;
 
 	/* non-copper PHY? */
@@ -2140,8 +2120,6 @@ void e1000e_reset(struct e1000_adapter *adapter)
 		phy_data &= ~IGP02E1000_PM_SPD;
 		e1e_wphy(hw, IGP02E1000_PHY_POWER_MGMT, phy_data);
 	}
-
-	e1000_release_manageability(adapter);
 }
 
 int e1000e_up(struct e1000_adapter *adapter)
@@ -3487,8 +3465,6 @@ static int e1000_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	e1000_release_manageability(adapter);
-
 	/* make sure adapter isn't asleep if manageability is enabled */
 	if (adapter->flags & FLAG_MNG_PT_ENABLED) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);
@@ -4054,8 +4030,6 @@ static void __devexit e1000_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-	e1000_release_manageability(adapter);
-
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	e1000_release_hw_control(adapter);
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index 0431e9e..4244fc2 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -130,8 +130,8 @@ static void free_skb_resources(struct gfar_private *priv);
 static void gfar_set_multi(struct net_device *dev);
 static void gfar_set_hash_for_addr(struct net_device *dev, u8 *addr);
 static void gfar_configure_serdes(struct net_device *dev);
-extern int gfar_local_mdio_write(struct gfar_mii *regs, int mii_id, int regnum, u16 value);
-extern int gfar_local_mdio_read(struct gfar_mii *regs, int mii_id, int regnum);
+extern int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id, int regnum, u16 value);
+extern int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum);
 #ifdef CONFIG_GFAR_NAPI
 static int gfar_poll(struct napi_struct *napi, int budget);
 #endif
diff --git a/drivers/net/gianfar_mii.c b/drivers/net/gianfar_mii.c
index 6a647d9..2432762 100644
--- a/drivers/net/gianfar_mii.c
+++ b/drivers/net/gianfar_mii.c
@@ -51,7 +51,7 @@
  * the local mdio pins, which may not be the same as system mdio bus, used for
  * controlling the external PHYs, for example.
  */
-int gfar_local_mdio_write(struct gfar_mii *regs, int mii_id,
+int gfar_local_mdio_write(struct gfar_mii __iomem *regs, int mii_id,
 			  int regnum, u16 value)
 {
 	/* Set the PHY address and the register address we want to write */
@@ -77,7 +77,7 @@ int gfar_local_mdio_write(struct gfar_mii *regs, int mii_id,
  * and are always tied to the local mdio pins, which may not be the
  * same as system mdio bus, used for controlling the external PHYs, for eg.
  */
-int gfar_local_mdio_read(struct gfar_mii *regs, int mii_id, int regnum)
+int gfar_local_mdio_read(struct gfar_mii __iomem *regs, int mii_id, int regnum)
 
 {
 	u16 value;
diff --git a/drivers/net/hamradio/mkiss.c b/drivers/net/hamradio/mkiss.c
index cfcd15a..30c9b3b 100644
--- a/drivers/net/hamradio/mkiss.c
+++ b/drivers/net/hamradio/mkiss.c
@@ -289,7 +289,6 @@ static void ax_bump(struct mkiss *ax)
 			*ax->rbuff &= ~0x20;
 		}
  	}
-	spin_unlock_bh(&ax->buflock);
 
 	count = ax->rcount;
 
@@ -297,17 +296,17 @@ static void ax_bump(struct mkiss *ax)
 		printk(KERN_ERR "mkiss: %s: memory squeeze, dropping packet.\n",
 		       ax->dev->name);
 		ax->stats.rx_dropped++;
+		spin_unlock_bh(&ax->buflock);
 		return;
 	}
 
-	spin_lock_bh(&ax->buflock);
 	memcpy(skb_put(skb,count), ax->rbuff, count);
-	spin_unlock_bh(&ax->buflock);
 	skb->protocol = ax25_type_trans(skb, ax->dev);
 	netif_rx(skb);
 	ax->dev->last_rx = jiffies;
 	ax->stats.rx_packets++;
 	ax->stats.rx_bytes += count;
+	spin_unlock_bh(&ax->buflock);
 }
 
 static void kiss_unesc(struct mkiss *ax, unsigned char s)
diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index f69721e..0447f9b 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -43,7 +43,7 @@ struct igb_stats {
 	int stat_offset;
 };
 
-#define IGB_STAT(m) sizeof(((struct igb_adapter *)0)->m), \
+#define IGB_STAT(m) FIELD_SIZEOF(struct igb_adapter, m), \
 		      offsetof(struct igb_adapter, m)
 static const struct igb_stats igb_gstrings_stats[] = {
 	{ "rx_packets", IGB_STAT(stats.gprc) },
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index d4eb8e2..bff280e 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -606,9 +606,6 @@ static void igb_init_manageability(struct igb_adapter *adapter)
 		u32 manc2h = rd32(E1000_MANC2H);
 		u32 manc = rd32(E1000_MANC);
 
-		/* disable hardware interception of ARP */
-		manc &= ~(E1000_MANC_ARP_EN);
-
 		/* enable receiving management packets to the host */
 		/* this will probably generate destination unreachable messages
 		 * from the host OS, but the packets will be handled on SMBUS */
@@ -623,25 +620,6 @@ static void igb_init_manageability(struct igb_adapter *adapter)
 	}
 }
 
-static void igb_release_manageability(struct igb_adapter *adapter)
-{
-	struct e1000_hw *hw = &adapter->hw;
-
-	if (adapter->en_mng_pt) {
-		u32 manc = rd32(E1000_MANC);
-
-		/* re-enable hardware interception of ARP */
-		manc |= E1000_MANC_ARP_EN;
-		manc &= ~E1000_MANC_EN_MNG2HOST;
-
-		/* don't explicitly have to mess with MANC2H since
-		 * MANC has an enable disable that gates MANC2H */
-
-		/* XXX stop the hardware watchdog ? */
-		wr32(E1000_MANC, manc);
-	}
-}
-
 /**
  * igb_configure - configure the hardware for RX and TX
  * @adapter: private board structure
@@ -844,7 +822,6 @@ void igb_reset(struct igb_adapter *adapter)
 
 	igb_reset_adaptive(&adapter->hw);
 	adapter->hw.phy.ops.get_phy_info(&adapter->hw);
-	igb_release_manageability(adapter);
 }
 
 /**
@@ -1178,9 +1155,6 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 
 	flush_scheduled_work();
 
-
-	igb_release_manageability(adapter);
-
 	/* Release control of h/w to f/w.  If f/w is AMT enabled, this
 	 * would have already happened in close and is redundant. */
 	igb_release_hw_control(adapter);
@@ -3955,8 +3929,6 @@ static int igb_suspend(struct pci_dev *pdev, pm_message_t state)
 		pci_enable_wake(pdev, PCI_D3cold, 0);
 	}
 
-	igb_release_manageability(adapter);
-
 	/* make sure adapter isn't asleep if manageability is enabled */
 	if (adapter->en_mng_pt) {
 		pci_enable_wake(pdev, PCI_D3hot, 1);
diff --git a/drivers/net/ixgb/ixgb_ethtool.c b/drivers/net/ixgb/ixgb_ethtool.c
index a267dd8..53a9fd0 100644
--- a/drivers/net/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ixgb/ixgb_ethtool.c
@@ -49,7 +49,7 @@ struct ixgb_stats {
 	int stat_offset;
 };
 
-#define IXGB_STAT(m) sizeof(((struct ixgb_adapter *)0)->m), \
+#define IXGB_STAT(m) FIELD_SIZEOF(struct ixgb_adapter, m), \
 		      offsetof(struct ixgb_adapter, m)
 static struct ixgb_stats ixgb_gstrings_stats[] = {
 	{"rx_packets", IXGB_STAT(net_stats.rx_packets)},
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ead49e5..23d0a4a 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -220,7 +220,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 			tx_ring->stats.bytes += tx_buffer_info->length;
 			if (cleaned) {
 				struct sk_buff *skb = tx_buffer_info->skb;
-#ifdef NETIF_F_TSO
 				unsigned int segs, bytecount;
 				segs = skb_shinfo(skb)->gso_segs ?: 1;
 				/* multiply data chunks by size of headers */
@@ -228,10 +227,6 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_adapter *adapter,
 					    skb->len;
 				total_tx_packets += segs;
 				total_tx_bytes += bytecount;
-#else
-				total_tx_packets++;
-				total_tx_bytes += skb->len;
-#endif
 			}
 			ixgbe_unmap_and_free_tx_resource(adapter,
 							 tx_buffer_info);
@@ -1942,6 +1937,10 @@ static int ixgbe_open(struct net_device *netdev)
 	int err;
 	u32 num_rx_queues = adapter->num_rx_queues;
 
+	/* disallow open during test */
+	if (test_bit(__IXGBE_TESTING, &adapter->state))
+		return -EBUSY;
+
 try_intr_reinit:
 	/* allocate transmit descriptors */
 	err = ixgbe_setup_all_tx_resources(adapter);
@@ -2278,11 +2277,29 @@ static bool ixgbe_tx_csum(struct ixgbe_adapter *adapter,
 				    IXGBE_ADVTXD_DTYP_CTXT);
 
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
-			if (skb->protocol == htons(ETH_P_IP))
+			switch (skb->protocol) {
+			case __constant_htons(ETH_P_IP):
 				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_IPV4;
+				if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+					type_tucmd_mlhl |=
+						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+				break;
+
+			case __constant_htons(ETH_P_IPV6):
+				/* XXX what about other V6 headers?? */
+				if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+					type_tucmd_mlhl |=
+						IXGBE_ADVTXD_TUCMD_L4T_TCP;
+				break;
 
-			if (skb->sk->sk_protocol == IPPROTO_TCP)
-				type_tucmd_mlhl |= IXGBE_ADVTXD_TUCMD_L4T_TCP;
+			default:
+				if (unlikely(net_ratelimit())) {
+					DPRINTK(PROBE, WARNING,
+					 "partial checksum but proto=%x!\n",
+					 skb->protocol);
+				}
+				break;
+			}
 		}
 
 		context_desc->type_tucmd_mlhl = cpu_to_le32(type_tucmd_mlhl);
@@ -2778,6 +2795,14 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 		 hw->mac.type, hw->phy.type,
 		 (part_num >> 8), (part_num & 0xff));
 
+	if (link_width <= IXGBE_PCI_LINK_WIDTH_4) {
+		dev_warn(&pdev->dev, "PCI-Express bandwidth available for "
+			 "this card is not sufficient for optimal "
+			 "performance.\n");
+		dev_warn(&pdev->dev, "For optimal performance a x8 "
+			 "PCI-Express slot is required.\n");
+	}
+
 	/* reset the hardware with the new settings */
 	ixgbe_start_hw(hw);
 
diff --git a/drivers/net/pcmcia/smc91c92_cs.c b/drivers/net/pcmcia/smc91c92_cs.c
index f18eca9..250eb19 100644
--- a/drivers/net/pcmcia/smc91c92_cs.c
+++ b/drivers/net/pcmcia/smc91c92_cs.c
@@ -559,8 +559,16 @@ static int mhz_setup(struct pcmcia_device *link)
 
     /* Read the station address from the CIS.  It is stored as the last
        (fourth) string in the Version 1 Version/ID tuple. */
-    if (link->prod_id[3]) {
-	station_addr = link->prod_id[3];
+    tuple->DesiredTuple = CISTPL_VERS_1;
+    if (first_tuple(link, tuple, parse) != CS_SUCCESS) {
+	rc = -1;
+	goto free_cfg_mem;
+    }
+    /* Ugh -- the EM1144 card has two VERS_1 tuples!?! */
+    if (next_tuple(link, tuple, parse) != CS_SUCCESS)
+	first_tuple(link, tuple, parse);
+    if (parse->version_1.ns > 3) {
+	station_addr = parse->version_1.str + parse->version_1.ofs[3];
 	if (cvt_ascii_address(dev, station_addr) == 0) {
 		rc = 0;
 		goto free_cfg_mem;
diff --git a/drivers/net/tsi108_eth.c b/drivers/net/tsi108_eth.c
index 35d15e8..6f33f84 100644
--- a/drivers/net/tsi108_eth.c
+++ b/drivers/net/tsi108_eth.c
@@ -36,6 +36,7 @@
 #include <linux/net.h>
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/skbuff.h>
 #include <linux/slab.h>
 #include <linux/spinlock.h>
@@ -297,18 +298,11 @@ static void tsi108_check_phy(struct net_device *dev)
 	u32 speed;
 	unsigned long flags;
 
-	/* Do a dummy read, as for some reason the first read
-	 * after a link becomes up returns link down, even if
-	 * it's been a while since the link came up.
-	 */
-
 	spin_lock_irqsave(&phy_lock, flags);
 
 	if (!data->phy_ok)
 		goto out;
 
-	tsi108_read_mii(data, MII_BMSR);
-
 	duplex = mii_check_media(&data->mii_if, netif_msg_link(data), data->init_media);
 	data->init_media = 0;
 
@@ -345,22 +339,21 @@ static void tsi108_check_phy(struct net_device *dev)
 
 			TSI_WRITE(TSI108_MAC_CFG2, mac_cfg2_reg);
 			TSI_WRITE(TSI108_EC_PORTCTRL, portctrl_reg);
+		}
 
-			if (data->link_up == 0) {
-				/* The manual says it can take 3-4 usecs for the speed change
-				 * to take effect.
-				 */
-				udelay(5);
+		if (data->link_up == 0) {
+			/* The manual says it can take 3-4 usecs for the speed change
+			 * to take effect.
+			 */
+			udelay(5);
 
-				spin_lock(&data->txlock);
-				if (is_valid_ether_addr(dev->dev_addr) && data->txfree)
-					netif_wake_queue(dev);
+			spin_lock(&data->txlock);
+			if (is_valid_ether_addr(dev->dev_addr) && data->txfree)
+				netif_wake_queue(dev);
 
-				data->link_up = 1;
-				spin_unlock(&data->txlock);
-			}
+			data->link_up = 1;
+			spin_unlock(&data->txlock);
 		}
-
 	} else {
 		if (data->link_up == 1) {
 			netif_stop_queue(dev);
@@ -1274,12 +1267,11 @@ static void tsi108_init_phy(struct net_device *dev)
 	 * PHY_STAT register before the link up status bit is set.
 	 */
 
-	data->link_up = 1;
+	data->link_up = 0;
 
 	while (!((phyval = tsi108_read_mii(data, MII_BMSR)) &
 		 BMSR_LSTATUS)) {
 		if (i++ > (MII_READ_DELAY / 10)) {
-			data->link_up = 0;
 			break;
 		}
 		spin_unlock_irqrestore(&phy_lock, flags);
@@ -1287,6 +1279,7 @@ static void tsi108_init_phy(struct net_device *dev)
 		spin_lock_irqsave(&phy_lock, flags);
 	}
 
+	data->mii_if.supports_gmii = mii_check_gmii_support(&data->mii_if);
 	printk(KERN_DEBUG "PHY_STAT reg contains %08x\n", phyval);
 	data->phy_ok = 1;
 	data->init_media = 1;
@@ -1527,12 +1520,46 @@ static void tsi108_init_mac(struct net_device *dev)
 	TSI_WRITE(TSI108_EC_INTMASK, ~0);
 }
 
+static int tsi108_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tsi108_prv_data *data = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+	
+	spin_lock_irqsave(&data->txlock, flags);
+	rc = mii_ethtool_gset(&data->mii_if, cmd);
+	spin_unlock_irqrestore(&data->txlock, flags);
+
+	return rc;
+}
+
+static int tsi108_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
+{
+	struct tsi108_prv_data *data = netdev_priv(dev);
+	unsigned long flags;
+	int rc;
+
+	spin_lock_irqsave(&data->txlock, flags);
+	rc = mii_ethtool_sset(&data->mii_if, cmd);
+	spin_unlock_irqrestore(&data->txlock, flags);
+	
+	return rc;
+}
+
 static int tsi108_do_ioctl(struct net_device *dev, struct ifreq *rq, int cmd)
 {
 	struct tsi108_prv_data *data = netdev_priv(dev);
+	if (!netif_running(dev))
+		return -EINVAL;
 	return generic_mii_ioctl(&data->mii_if, if_mii(rq), cmd, NULL);
 }
 
+static const struct ethtool_ops tsi108_ethtool_ops = {
+	.get_link 	= ethtool_op_get_link,
+	.get_settings	= tsi108_get_settings,
+	.set_settings	= tsi108_set_settings,
+};
+
 static int
 tsi108_init_one(struct platform_device *pdev)
 {
@@ -1584,7 +1611,6 @@ tsi108_init_one(struct platform_device *pdev)
 	data->mii_if.phy_id = einfo->phy;
 	data->mii_if.phy_id_mask = 0x1f;
 	data->mii_if.reg_num_mask = 0x1f;
-	data->mii_if.supports_gmii = mii_check_gmii_support(&data->mii_if);
 
 	data->phy = einfo->phy;
 	data->phy_type = einfo->phy_type;
@@ -1598,6 +1624,7 @@ tsi108_init_one(struct platform_device *pdev)
 	dev->get_stats = tsi108_get_stats;
 	netif_napi_add(dev, &data->napi, tsi108_poll, 64);
 	dev->do_ioctl = tsi108_do_ioctl;
+	dev->ethtool_ops = &tsi108_ethtool_ops;
 
 	/* Apparently, the Linux networking code won't use scatter-gather
 	 * if the hardware doesn't do checksums.  However, it's faster
@@ -1629,6 +1656,7 @@ tsi108_init_one(struct platform_device *pdev)
 		goto register_fail;
 	}
 
+	platform_set_drvdata(pdev, dev);
 	printk(KERN_INFO "%s: Tsi108 Gigabit Ethernet, MAC: %s\n",
 	       dev->name, print_mac(mac, dev->dev_addr));
 #ifdef DEBUG
