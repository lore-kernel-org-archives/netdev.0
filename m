From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Tue, 7 Aug 2007 20:38:48 -0400
Message-ID: <20070808003848.GA30527@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:51592 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757055AbXHHAiv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Aug 2007 20:38:51 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 drivers/net/atl1/atl1_main.c                |    4 +--
 drivers/net/ehea/ehea.h                     |    2 +-
 drivers/net/ehea/ehea_main.c                |   44 ++++++++++----------------
 drivers/net/ibmveth.c                       |   27 +++++++++-------
 drivers/net/ibmveth.h                       |    3 --
 drivers/net/phy/phy.c                       |    4 +-
 drivers/net/r8169.c                         |   24 ++++++++++-----
 drivers/net/sis190.c                        |    3 ++
 drivers/net/smc91x.h                        |    4 +--
 drivers/net/ucc_geth_ethtool.c              |    1 -
 drivers/net/ucc_geth_mii.c                  |    3 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |    2 +-
 drivers/net/wireless/rtl8187_dev.c          |    2 +-
 drivers/net/wireless/zd1211rw/zd_mac.c      |    2 +-
 fs/compat_ioctl.c                           |    3 --
 net/ieee80211/softmac/ieee80211softmac_wx.c |   11 +++++--
 16 files changed, 69 insertions(+), 70 deletions(-)

Brian King (1):
      ibmveth: Fix rx pool deactivate oops

Domen Puncer (2):
      ucc_geth: fix section mismatch
      phy layer: fix phy_mii_ioctl for autonegotiation

Francois Romieu (1):
      r8169: avoid needless NAPI poll scheduling

Ingo Molnar (1):
      atl1: use spin_trylock_irqsave()

Jan Altenberg (1):
      ucc_geth: remove get_perm_addr from ucc_geth_ethtool.c

John W. Linville (1):
      Revert "[PATCH] bcm43xx: Fix deviation from specifications in set_baseband_attenuation"

Mariusz Kozlowski (1):
      drivers/net/ibmveth.c: memset fix

Masakazu Mokuno (1):
      remove duplicated ioctl entries in compat_ioctl.c

Michael Buesch (1):
      softmac: Fix deadlock of wx_set_essid with assoc work

Michael Wu (1):
      rtl8187: ensure priv->hwaddr is always valid

Neil Muller (1):
      sis190 check for ISA bridge on SiS966

Paul Mundt (1):
      net: smc91x: Build fixes for general sh boards.

Roger So (1):
      r8169: PHY power-on fix

Thomas Klein (3):
      ehea: Fix workqueue handling
      ehea: Simplify resource usage check
      ehea: Eliminated some compiler warnings

Ulrich Kunitz (1):
      zd1211rw: fix filter for PSPOLL frames

diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 56f6389..3c1984e 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1704,10 +1704,8 @@ static int atl1_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 		}
 	}
 
-	local_irq_save(flags);
-	if (!spin_trylock(&adapter->lock)) {
+	if (!spin_trylock_irqsave(&adapter->lock, flags)) {
 		/* Can't get lock - tell upper layer to requeue */
-		local_irq_restore(flags);
 		dev_printk(KERN_DEBUG, &adapter->pdev->dev, "tx locked\n");
 		return NETDEV_TX_LOCKED;
 	}
diff --git a/drivers/net/ehea/ehea.h b/drivers/net/ehea/ehea.h
index 8ee2c2c..d67f97b 100644
--- a/drivers/net/ehea/ehea.h
+++ b/drivers/net/ehea/ehea.h
@@ -39,7 +39,7 @@
 #include <asm/io.h>
 
 #define DRV_NAME	"ehea"
-#define DRV_VERSION	"EHEA_0072"
+#define DRV_VERSION	"EHEA_0073"
 
 /* eHEA capability flags */
 #define DLPAR_PORT_ADD_REM 1
diff --git a/drivers/net/ehea/ehea_main.c b/drivers/net/ehea/ehea_main.c
index 58702f5..9756211 100644
--- a/drivers/net/ehea/ehea_main.c
+++ b/drivers/net/ehea/ehea_main.c
@@ -1326,7 +1326,6 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
 	int skb_data_size = skb->len - skb->data_len;
 	int headersize;
-	u64 tmp_addr;
 
 	/* Packet is TCP with TSO enabled */
 	swqe->tx_control |= EHEA_SWQE_TSO;
@@ -1347,9 +1346,8 @@ static void write_swqe2_TSO(struct sk_buff *skb,
 			/* set sg1entry data */
 			sg1entry->l_key = lkey;
 			sg1entry->len = skb_data_size - headersize;
-
-			tmp_addr = (u64)(skb->data + headersize);
-			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
+			sg1entry->vaddr =
+				ehea_map_vaddr(skb->data + headersize);
 			swqe->descriptors++;
 		}
 	} else
@@ -1362,7 +1360,6 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 	int skb_data_size = skb->len - skb->data_len;
 	u8 *imm_data = &swqe->u.immdata_desc.immediate_data[0];
 	struct ehea_vsgentry *sg1entry = &swqe->u.immdata_desc.sg_entry;
-	u64 tmp_addr;
 
 	/* Packet is any nonTSO type
 	 *
@@ -1379,8 +1376,8 @@ static void write_swqe2_nonTSO(struct sk_buff *skb,
 			/* copy sg1entry data */
 			sg1entry->l_key = lkey;
 			sg1entry->len = skb_data_size - SWQE2_MAX_IMM;
-			tmp_addr = (u64)(skb->data + SWQE2_MAX_IMM);
-			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
+			sg1entry->vaddr =
+				ehea_map_vaddr(skb->data + SWQE2_MAX_IMM);
 			swqe->descriptors++;
 		}
 	} else {
@@ -1395,7 +1392,6 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 	struct ehea_vsgentry *sg_list, *sg1entry, *sgentry;
 	skb_frag_t *frag;
 	int nfrags, sg1entry_contains_frag_data, i;
-	u64 tmp_addr;
 
 	nfrags = skb_shinfo(skb)->nr_frags;
 	sg1entry = &swqe->u.immdata_desc.sg_entry;
@@ -1417,9 +1413,9 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 			/* copy sg1entry data */
 			sg1entry->l_key = lkey;
 			sg1entry->len = frag->size;
-			tmp_addr =  (u64)(page_address(frag->page)
-					  + frag->page_offset);
-			sg1entry->vaddr = ehea_map_vaddr(tmp_addr);
+			sg1entry->vaddr =
+				ehea_map_vaddr(page_address(frag->page)
+					       + frag->page_offset);
 			swqe->descriptors++;
 			sg1entry_contains_frag_data = 1;
 		}
@@ -1431,10 +1427,9 @@ static inline void write_swqe2_data(struct sk_buff *skb, struct net_device *dev,
 
 			sgentry->l_key = lkey;
 			sgentry->len = frag->size;
-
-			tmp_addr = (u64)(page_address(frag->page)
-					 + frag->page_offset);
-			sgentry->vaddr = ehea_map_vaddr(tmp_addr);
+			sgentry->vaddr =
+				ehea_map_vaddr(page_address(frag->page)
+					       + frag->page_offset);
 			swqe->descriptors++;
 		}
 	}
@@ -2165,24 +2160,18 @@ static int ehea_clean_all_portres(struct ehea_port *port)
 	return ret;
 }
 
-static void ehea_remove_adapter_mr (struct ehea_adapter *adapter)
+static void ehea_remove_adapter_mr(struct ehea_adapter *adapter)
 {
-	int i;
-
-	for (i=0; i < EHEA_MAX_PORTS; i++)
-		if (adapter->port[i])
-			return;
+	if (adapter->active_ports)
+		return;
 
 	ehea_rem_mr(&adapter->mr);
 }
 
-static int ehea_add_adapter_mr (struct ehea_adapter *adapter)
+static int ehea_add_adapter_mr(struct ehea_adapter *adapter)
 {
-	int i;
-
-	for (i=0; i < EHEA_MAX_PORTS; i++)
-		if (adapter->port[i])
-			return 0;
+	if (adapter->active_ports)
+		return 0;
 
 	return ehea_reg_kernel_mr(adapter, &adapter->mr);
 }
@@ -3099,6 +3088,7 @@ out:
 
 static void __exit ehea_module_exit(void)
 {
+	destroy_workqueue(ehea_driver_wq);
 	driver_remove_file(&ehea_driver.driver, &driver_attr_capabilities);
 	ibmebus_unregister_driver(&ehea_driver);
 	ehea_destroy_busmap();
diff --git a/drivers/net/ibmveth.c b/drivers/net/ibmveth.c
index d96eb72..acba90f 100644
--- a/drivers/net/ibmveth.c
+++ b/drivers/net/ibmveth.c
@@ -963,7 +963,7 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 {
 	int rc, i;
 	struct net_device *netdev;
-	struct ibmveth_adapter *adapter = NULL;
+	struct ibmveth_adapter *adapter;
 
 	unsigned char *mac_addr_p;
 	unsigned int *mcastFilterSize_p;
@@ -997,7 +997,6 @@ static int __devinit ibmveth_probe(struct vio_dev *dev, const struct vio_device_
 	SET_MODULE_OWNER(netdev);
 
 	adapter = netdev->priv;
-	memset(adapter, 0, sizeof(adapter));
 	dev->dev.driver_data = netdev;
 
 	adapter->vdev = dev;
@@ -1280,24 +1279,28 @@ const char * buf, size_t count)
 			int i;
 			/* Make sure there is a buffer pool with buffers that
 			   can hold a packet of the size of the MTU */
-			for(i = 0; i<IbmVethNumBufferPools; i++) {
+			for (i = 0; i < IbmVethNumBufferPools; i++) {
 				if (pool == &adapter->rx_buff_pool[i])
 					continue;
 				if (!adapter->rx_buff_pool[i].active)
 					continue;
-				if (mtu < adapter->rx_buff_pool[i].buff_size) {
-					pool->active = 0;
-					h_free_logical_lan_buffer(adapter->
-								  vdev->
-								  unit_address,
-								  pool->
-								  buff_size);
-				}
+				if (mtu <= adapter->rx_buff_pool[i].buff_size)
+					break;
 			}
-			if (pool->active) {
+
+			if (i == IbmVethNumBufferPools) {
 				ibmveth_error_printk("no active pool >= MTU\n");
 				return -EPERM;
 			}
+
+			pool->active = 0;
+			if (netif_running(netdev)) {
+				adapter->pool_config = 1;
+				ibmveth_close(netdev);
+				adapter->pool_config = 0;
+				if ((rc = ibmveth_open(netdev)))
+					return rc;
+			}
 		}
 	} else if (attr == &veth_num_attr) {
 		if (value <= 0 || value > IBMVETH_MAX_POOL_COUNT)
diff --git a/drivers/net/ibmveth.h b/drivers/net/ibmveth.h
index bb69cca..72cc15a 100644
--- a/drivers/net/ibmveth.h
+++ b/drivers/net/ibmveth.h
@@ -73,9 +73,6 @@ static inline long h_send_logical_lan(unsigned long unit_address,
 #define h_change_logical_lan_mac(ua, mac) \
   plpar_hcall_norets(H_CHANGE_LOGICAL_LAN_MAC, ua, mac)
 
-#define h_free_logical_lan_buffer(ua, bufsize) \
-  plpar_hcall_norets(H_FREE_LOGICAL_LAN_BUFFER, ua, bufsize)
-
 #define IbmVethNumBufferPools 5
 #define IBMVETH_BUFF_OH 22 /* Overhead: 14 ethernet header + 8 opaque handle */
 #define IBMVETH_MAX_MTU 68
diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
index f71dab3..e323efd 100644
--- a/drivers/net/phy/phy.c
+++ b/drivers/net/phy/phy.c
@@ -261,7 +261,7 @@ void phy_sanitize_settings(struct phy_device *phydev)
 
 	/* Sanitize settings based on PHY capabilities */
 	if ((features & SUPPORTED_Autoneg) == 0)
-		phydev->autoneg = 0;
+		phydev->autoneg = AUTONEG_DISABLE;
 
 	idx = phy_find_valid(phy_find_setting(phydev->speed, phydev->duplex),
 			features);
@@ -374,7 +374,7 @@ int phy_mii_ioctl(struct phy_device *phydev,
 		if (mii_data->phy_id == phydev->addr) {
 			switch(mii_data->reg_num) {
 			case MII_BMCR:
-				if (val & (BMCR_RESET|BMCR_ANENABLE))
+				if ((val & (BMCR_RESET|BMCR_ANENABLE)) == 0)
 					phydev->autoneg = AUTONEG_DISABLE;
 				else
 					phydev->autoneg = AUTONEG_ENABLE;
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index c9333b9..b85ab4a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -725,6 +725,12 @@ static int rtl8169_set_speed_xmii(struct net_device *dev,
 
 	auto_nego |= ADVERTISE_PAUSE_CAP | ADVERTISE_PAUSE_ASYM;
 
+	if (tp->mac_version == RTL_GIGA_MAC_VER_12) {
+		/* Vendor specific (0x1f) and reserved (0x0e) MII registers. */
+		mdio_write(ioaddr, 0x1f, 0x0000);
+		mdio_write(ioaddr, 0x0e, 0x0000);
+	}
+
 	tp->phy_auto_nego_reg = auto_nego;
 	tp->phy_1000_ctrl_reg = giga_ctrl;
 
@@ -2760,14 +2766,16 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			rtl8169_check_link_status(dev, tp, ioaddr);
 
 #ifdef CONFIG_R8169_NAPI
-		RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
-		tp->intr_mask = ~tp->napi_event;
-
-		if (likely(netif_rx_schedule_prep(dev)))
-			__netif_rx_schedule(dev);
-		else if (netif_msg_intr(tp)) {
-			printk(KERN_INFO "%s: interrupt %04x taken in poll\n",
-			       dev->name, status);
+		if (status & tp->napi_event) {
+			RTL_W16(IntrMask, tp->intr_event & ~tp->napi_event);
+			tp->intr_mask = ~tp->napi_event;
+
+			if (likely(netif_rx_schedule_prep(dev)))
+				__netif_rx_schedule(dev);
+			else if (netif_msg_intr(tp)) {
+				printk(KERN_INFO "%s: interrupt %04x in poll\n",
+				       dev->name, status);
+			}
 		}
 		break;
 #else
diff --git a/drivers/net/sis190.c b/drivers/net/sis190.c
index ec2ad9f..d470b19 100644
--- a/drivers/net/sis190.c
+++ b/drivers/net/sis190.c
@@ -1593,6 +1593,9 @@ static int __devinit sis190_get_mac_addr_from_apc(struct pci_dev *pdev,
 		  pci_name(pdev));
 
 	isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0965, NULL);
+	if (!isa_bridge)
+		isa_bridge = pci_get_device(PCI_VENDOR_ID_SI, 0x0966, NULL);
+
 	if (!isa_bridge) {
 		net_probe(tp, KERN_INFO "%s: Can not find ISA bridge.\n",
 			  pci_name(pdev));
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index f842944..6ff3a16 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -299,7 +299,7 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 
 #define SMC_CAN_USE_8BIT       1
 #define SMC_CAN_USE_16BIT      1
-#define SMC_CAN_USE_32BIT      1
+#define SMC_CAN_USE_32BIT      0
 
 #define SMC_inb(a, r)          inb((a) + (r))
 #define SMC_inw(a, r)          inw((a) + (r))
@@ -310,8 +310,6 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 
 #endif  /* BOARDS */
 
-#define set_irq_type(irq, type) do {} while (0)
-
 #elif   defined(CONFIG_M32R)
 
 #define SMC_CAN_USE_8BIT	0
diff --git a/drivers/net/ucc_geth_ethtool.c b/drivers/net/ucc_geth_ethtool.c
index a8994c7..64bef7c 100644
--- a/drivers/net/ucc_geth_ethtool.c
+++ b/drivers/net/ucc_geth_ethtool.c
@@ -379,7 +379,6 @@ static const struct ethtool_ops uec_ethtool_ops = {
 	.get_stats_count        = uec_get_stats_count,
 	.get_strings            = uec_get_strings,
 	.get_ethtool_stats      = uec_get_ethtool_stats,
-	.get_perm_addr          = ethtool_op_get_perm_addr,
 };
 
 void uec_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ucc_geth_mii.c b/drivers/net/ucc_geth_mii.c
index 5f8c2d3..6c257b8 100644
--- a/drivers/net/ucc_geth_mii.c
+++ b/drivers/net/ucc_geth_mii.c
@@ -272,7 +272,8 @@ int __init uec_mdio_init(void)
 	return of_register_platform_driver(&uec_mdio_driver);
 }
 
-void __exit uec_mdio_exit(void)
+/* called from __init ucc_geth_init, therefore can not be __exit */
+void uec_mdio_exit(void)
 {
 	of_unregister_platform_driver(&uec_mdio_driver);
 }
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index d779199..b37f1e3 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -1638,7 +1638,7 @@ void bcm43xx_phy_set_baseband_attenuation(struct bcm43xx_private *bcm,
 		return;
 	}
 
-	if (phy->analog == 1) {
+	if (phy->analog > 1) {
 		value = bcm43xx_phy_read(bcm, 0x0060) & ~0x003C;
 		value |= (baseband_attenuation << 2) & 0x003C;
 	} else {
diff --git a/drivers/net/wireless/rtl8187_dev.c b/drivers/net/wireless/rtl8187_dev.c
index cea8589..e61c6d5 100644
--- a/drivers/net/wireless/rtl8187_dev.c
+++ b/drivers/net/wireless/rtl8187_dev.c
@@ -466,7 +466,7 @@ static int rtl8187_add_interface(struct ieee80211_hw *dev,
 		return -EOPNOTSUPP;
 	}
 
-	priv->hwaddr = conf->mac_addr;
+	priv->hwaddr = conf->mac_addr ? conf->mac_addr : dev->wiphy->perm_addr;
 
 	return 0;
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index f6c487a..26869d1 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -822,7 +822,7 @@ static void cs_set_control(struct zd_mac *mac, struct zd_ctrlset *cs,
 		cs->control |= ZD_CS_MULTICAST;
 
 	/* PS-POLL */
-	if (stype == IEEE80211_STYPE_PSPOLL)
+	if (ftype == IEEE80211_FTYPE_CTL && stype == IEEE80211_STYPE_PSPOLL)
 		cs->control |= ZD_CS_PS_POLL_FRAME;
 
 	/* Unicast data frames over the threshold should have RTS */
diff --git a/fs/compat_ioctl.c b/fs/compat_ioctl.c
index 2bc1428..a6c9078 100644
--- a/fs/compat_ioctl.c
+++ b/fs/compat_ioctl.c
@@ -3161,12 +3161,9 @@ COMPATIBLE_IOCTL(SIOCSIWSENS)
 COMPATIBLE_IOCTL(SIOCGIWSENS)
 COMPATIBLE_IOCTL(SIOCSIWRANGE)
 COMPATIBLE_IOCTL(SIOCSIWPRIV)
-COMPATIBLE_IOCTL(SIOCGIWPRIV)
 COMPATIBLE_IOCTL(SIOCSIWSTATS)
-COMPATIBLE_IOCTL(SIOCGIWSTATS)
 COMPATIBLE_IOCTL(SIOCSIWAP)
 COMPATIBLE_IOCTL(SIOCGIWAP)
-COMPATIBLE_IOCTL(SIOCSIWSCAN)
 COMPATIBLE_IOCTL(SIOCSIWRATE)
 COMPATIBLE_IOCTL(SIOCGIWRATE)
 COMPATIBLE_IOCTL(SIOCSIWRTS)
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index f13937b..d054e92 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -74,8 +74,8 @@ ieee80211softmac_wx_set_essid(struct net_device *net_dev,
 	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
 
+check_assoc_again:
 	mutex_lock(&sm->associnfo.mutex);
-
 	/* Check if we're already associating to this or another network
 	 * If it's another network, cancel and start over with our new network
 	 * If it's our network, ignore the change, we're already doing it!
@@ -98,13 +98,18 @@ ieee80211softmac_wx_set_essid(struct net_device *net_dev,
 				cancel_delayed_work(&authptr->work);
 			sm->associnfo.bssvalid = 0;
 			sm->associnfo.bssfixed = 0;
-			flush_scheduled_work();
 			sm->associnfo.associating = 0;
 			sm->associnfo.associated = 0;
+			/* We must unlock to avoid deadlocks with the assoc workqueue
+			 * on the associnfo.mutex */
+			mutex_unlock(&sm->associnfo.mutex);
+			flush_scheduled_work();
+			/* Avoid race! Check assoc status again. Maybe someone started an
+			 * association while we flushed. */
+			goto check_assoc_again;
 		}
 	}
 
-
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
