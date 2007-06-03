From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes
Date: Sun, 3 Jun 2007 12:02:10 -0400
Message-ID: <20070603160210.GA27486@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:57384 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752838AbXFCQCQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 3 Jun 2007 12:02:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Please pull from 'upstream-linus' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-linus

to receive the following updates:

 MAINTAINERS                          |    9 ++++++-
 drivers/net/8139cp.c                 |   17 +++-----------
 drivers/net/acenic.c                 |   21 ++---------------
 drivers/net/acenic.h                 |    1 -
 drivers/net/amd8111e.c               |   11 +--------
 drivers/net/atl1/atl1_main.c         |   33 +---------------------------
 drivers/net/bnx2.c                   |   14 ------------
 drivers/net/chelsio/cxgb2.c          |   10 --------
 drivers/net/cxgb3/cxgb3_main.c       |    6 -----
 drivers/net/e1000/e1000_main.c       |   11 ++++++---
 drivers/net/forcedeth.c              |    8 +------
 drivers/net/gianfar.c                |   16 -------------
 drivers/net/myri10ge/myri10ge.c      |    1 +
 drivers/net/netxen/netxen_nic_main.c |    2 -
 drivers/net/ns83820.c                |   12 ----------
 drivers/net/qla3xxx.c                |    2 +-
 drivers/net/r8169.c                  |   11 ---------
 drivers/net/s2io.c                   |   12 ----------
 drivers/net/sky2.c                   |   31 +++++++++++---------------
 drivers/net/smc91x.h                 |    5 +---
 drivers/net/spider_net.c             |   40 ----------------------------------
 drivers/net/tg3.c                    |   16 -------------
 drivers/net/typhoon.c                |   11 +--------
 net/8021q/vlan.c                     |   10 ++------
 24 files changed, 45 insertions(+), 265 deletions(-)

Auke Kok (1):
      e1000: disable polling before registering netdevice

Brice Goglin (1):
      myri10ge: report link up/down in standard ethtool way

Li Yang (1):
      NET: add MAINTAINERS entry for ucc_geth driver

Mithlesh Thukral (1):
      NetXen: Removal of extra free_irq call

Paul Mundt (1):
      smc91x: sh solution engine fixes.

Stephen Hemminger (6):
      qla3xxx: device doesnt do hardware checksumming.
      VLAN: kill_vid is only useful for VLAN filtering devices
      sky2: Fix VLAN unregistration
      8139cp: fix VLAN unregistration
      atl1: eliminate unneeded kill_vid code
      network drivers: eliminate unneeded kill_vid code

Valerie Henson (1):
      Update tulip maintainer email address

diff --git a/MAINTAINERS b/MAINTAINERS
index 124b950..f3b5a39 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -1487,6 +1487,13 @@ L:	linux-usb-devel@lists.sourceforge.net
 L:	linuxppc-embedded@ozlabs.org
 S:	Maintained
 
+FREESCALE QUICC ENGINE UCC ETHERNET DRIVER
+P:	Li Yang
+M:	leoli@freescale.com
+L:	netdev@vger.kernel.org
+L:	linuxppc-embedded@ozlabs.org
+S:	Maintained
+
 FILE LOCKING (flock() and fcntl()/lockf())
 P:	Matthew Wilcox
 M:	matthew@wil.cx
@@ -3545,7 +3552,7 @@ S:	Maintained
 
 TULIP NETWORK DRIVER
 P:	Valerie Henson
-M:	val_henson@linux.intel.com
+M:	val@nmt.edu
 L:	tulip-users@lists.sourceforge.net
 W:	http://sourceforge.net/projects/tulip/
 S:	Maintained
diff --git a/drivers/net/8139cp.c b/drivers/net/8139cp.c
index e8c9f27..a804965 100644
--- a/drivers/net/8139cp.c
+++ b/drivers/net/8139cp.c
@@ -435,20 +435,12 @@ static void cp_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 
 	spin_lock_irqsave(&cp->lock, flags);
 	cp->vlgrp = grp;
-	cp->cpcmd |= RxVlanOn;
-	cpw16(CpCmd, cp->cpcmd);
-	spin_unlock_irqrestore(&cp->lock, flags);
-}
-
-static void cp_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct cp_private *cp = netdev_priv(dev);
-	unsigned long flags;
+	if (grp)
+		cp->cpcmd |= RxVlanOn;
+	else
+		cp->cpcmd &= ~RxVlanOn;
 
-	spin_lock_irqsave(&cp->lock, flags);
-	cp->cpcmd &= ~RxVlanOn;
 	cpw16(CpCmd, cp->cpcmd);
-	vlan_group_set_device(cp->vlgrp, vid, NULL);
 	spin_unlock_irqrestore(&cp->lock, flags);
 }
 #endif /* CP_VLAN_TAG_USED */
@@ -1944,7 +1936,6 @@ static int cp_init_one (struct pci_dev *pdev, const struct pci_device_id *ent)
 #if CP_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = cp_vlan_rx_register;
-	dev->vlan_rx_kill_vid = cp_vlan_rx_kill_vid;
 #endif
 
 	if (pci_using_dac)
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index 7122b7b..04382f9 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -480,12 +480,10 @@ static int __devinit acenic_probe_one(struct pci_dev *pdev,
 #if ACENIC_DO_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = ace_vlan_rx_register;
-	dev->vlan_rx_kill_vid = ace_vlan_rx_kill_vid;
 #endif
-	if (1) {
-		dev->tx_timeout = &ace_watchdog;
-		dev->watchdog_timeo = 5*HZ;
-	}
+
+	dev->tx_timeout = &ace_watchdog;
+	dev->watchdog_timeo = 5*HZ;
 
 	dev->open = &ace_open;
 	dev->stop = &ace_close;
@@ -2283,19 +2281,6 @@ static void ace_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	ace_unmask_irq(dev);
 	local_irq_restore(flags);
 }
-
-
-static void ace_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct ace_private *ap = netdev_priv(dev);
-	unsigned long flags;
-
-	local_irq_save(flags);
-	ace_mask_irq(dev);
-	vlan_group_set_device(ap->vlgrp, vid, NULL);
-	ace_unmask_irq(dev);
-	local_irq_restore(flags);
-}
 #endif /* ACENIC_DO_VLAN */
 
 
diff --git a/drivers/net/acenic.h b/drivers/net/acenic.h
index 8ca8534..60ed183 100644
--- a/drivers/net/acenic.h
+++ b/drivers/net/acenic.h
@@ -787,7 +787,6 @@ static struct net_device_stats *ace_get_stats(struct net_device *dev);
 static int read_eeprom_byte(struct net_device *dev, unsigned long offset);
 #if ACENIC_DO_VLAN
 static void ace_vlan_rx_register(struct net_device *dev, struct vlan_group *grp);
-static void ace_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid);
 #endif
 
 #endif /* _ACENIC_H_ */
diff --git a/drivers/net/amd8111e.c b/drivers/net/amd8111e.c
index 84b8164..a61b2f8 100644
--- a/drivers/net/amd8111e.c
+++ b/drivers/net/amd8111e.c
@@ -1728,15 +1728,8 @@ static void amd8111e_vlan_rx_register(struct net_device *dev, struct vlan_group
 	lp->vlgrp = grp;
 	spin_unlock_irq(&lp->lock);
 }
-
-static void amd8111e_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct amd8111e_priv *lp = netdev_priv(dev);
-	spin_lock_irq(&lp->lock);
-	vlan_group_set_device(lp->vlgrp, vid, NULL);
-	spin_unlock_irq(&lp->lock);
-}
 #endif
+
 static int amd8111e_enable_magicpkt(struct amd8111e_priv* lp)
 {
 	writel( VAL1|MPPLBA, lp->mmio + CMD3);
@@ -1996,7 +1989,6 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 #if AMD8111E_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX ;
 	dev->vlan_rx_register =amd8111e_vlan_rx_register;
-	dev->vlan_rx_kill_vid = amd8111e_vlan_rx_kill_vid;
 #endif
 
 	lp = netdev_priv(dev);
@@ -2049,7 +2041,6 @@ static int __devinit amd8111e_probe_one(struct pci_dev *pdev,
 #if AMD8111E_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register =amd8111e_vlan_rx_register;
-	dev->vlan_rx_kill_vid = amd8111e_vlan_rx_kill_vid;
 #endif
 	/* Probe the external PHY */
 	amd8111e_probe_ext_phy(dev);
diff --git a/drivers/net/atl1/atl1_main.c b/drivers/net/atl1/atl1_main.c
index 78cf00f..6862c11 100644
--- a/drivers/net/atl1/atl1_main.c
+++ b/drivers/net/atl1/atl1_main.c
@@ -1229,39 +1229,9 @@ static void atl1_vlan_rx_register(struct net_device *netdev,
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
 
-/* FIXME: justify or remove -- CHS */
-static void atl1_vlan_rx_add_vid(struct net_device *netdev, u16 vid)
-{
-	/* We don't do Vlan filtering */
-	return;
-}
-
-/* FIXME: this looks wrong too -- CHS */
-static void atl1_vlan_rx_kill_vid(struct net_device *netdev, u16 vid)
-{
-	struct atl1_adapter *adapter = netdev_priv(netdev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	/* atl1_irq_disable(adapter); */
-	vlan_group_set_device(adapter->vlgrp, vid, NULL);
-	/* atl1_irq_enable(adapter); */
-	spin_unlock_irqrestore(&adapter->lock, flags);
-	/* We don't do Vlan filtering */
-	return;
-}
-
 static void atl1_restore_vlan(struct atl1_adapter *adapter)
 {
 	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-	if (adapter->vlgrp) {
-		u16 vid;
-		for (vid = 0; vid < VLAN_GROUP_ARRAY_LEN; vid++) {
-			if (!vlan_group_get_device(adapter->vlgrp, vid))
-				continue;
-			atl1_vlan_rx_add_vid(adapter->netdev, vid);
-		}
-	}
 }
 
 static u16 tpd_avail(struct atl1_tpd_ring *tpd_ring)
@@ -2203,8 +2173,7 @@ static int __devinit atl1_probe(struct pci_dev *pdev,
 	netdev->poll_controller = atl1_poll_controller;
 #endif
 	netdev->vlan_rx_register = atl1_vlan_rx_register;
-	netdev->vlan_rx_add_vid = atl1_vlan_rx_add_vid;
-	netdev->vlan_rx_kill_vid = atl1_vlan_rx_kill_vid;
+
 	netdev->ethtool_ops = &atl1_ethtool_ops;
 	adapter->bd_number = cards_found;
 	adapter->pci_using_64 = pci_using_64;
diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 88b33c6..da7c3b0 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -4786,19 +4786,6 @@ bnx2_vlan_rx_register(struct net_device *dev, struct vlan_group *vlgrp)
 
 	bnx2_netif_start(bp);
 }
-
-/* Called with rtnl_lock */
-static void
-bnx2_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
-{
-	struct bnx2 *bp = netdev_priv(dev);
-
-	bnx2_netif_stop(bp);
-	vlan_group_set_device(bp->vlgrp, vid, NULL);
-	bnx2_set_rx_mode(dev);
-
-	bnx2_netif_start(bp);
-}
 #endif
 
 /* Called with netif_tx_lock.
@@ -6453,7 +6440,6 @@ bnx2_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->watchdog_timeo = TX_TIMEOUT;
 #ifdef BCM_VLAN
 	dev->vlan_rx_register = bnx2_vlan_rx_register;
-	dev->vlan_rx_kill_vid = bnx2_vlan_rx_kill_vid;
 #endif
 	dev->poll = bnx2_poll;
 	dev->ethtool_ops = &bnx2_ethtool_ops;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 125c9b1..231ce43 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -883,15 +883,6 @@ static void vlan_rx_register(struct net_device *dev,
 	t1_set_vlan_accel(adapter, grp != NULL);
 	spin_unlock_irq(&adapter->async_lock);
 }
-
-static void vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct adapter *adapter = dev->priv;
-
-	spin_lock_irq(&adapter->async_lock);
-	vlan_group_set_device(adapter->vlan_grp, vid, NULL);
-	spin_unlock_irq(&adapter->async_lock);
-}
 #endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -1099,7 +1090,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 			netdev->features |=
 				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 			netdev->vlan_rx_register = vlan_rx_register;
-			netdev->vlan_rx_kill_vid = vlan_rx_kill_vid;
 #endif
 
 			/* T204: disable TSO */
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index 67b4b21..1b20f40 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2067,11 +2067,6 @@ static void vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	t3_synchronize_rx(adapter, pi);
 }
 
-static void vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	/* nothing */
-}
-
 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void cxgb_netpoll(struct net_device *dev)
 {
@@ -2409,7 +2404,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 		netdev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->vlan_rx_register = vlan_rx_register;
-		netdev->vlan_rx_kill_vid = vlan_rx_kill_vid;
 
 		netdev->open = cxgb_open;
 		netdev->stop = cxgb_close;
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 9ec35b7..cf8af92 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -1142,13 +1142,16 @@ e1000_probe(struct pci_dev *pdev,
 	    !e1000_check_mng_mode(&adapter->hw))
 		e1000_get_hw_control(adapter);
 
-	strcpy(netdev->name, "eth%d");
-	if ((err = register_netdev(netdev)))
-		goto err_register;
-
 	/* tell the stack to leave us alone until e1000_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+#ifdef CONFIG_E1000_NAPI
+	netif_poll_disable(netdev);
+#endif
+
+	strcpy(netdev->name, "eth%d");
+	if ((err = register_netdev(netdev)))
+		goto err_register;
 
 	DPRINTK(PROBE, INFO, "Intel(R) PRO/1000 Network Connection\n");
 
diff --git a/drivers/net/forcedeth.c b/drivers/net/forcedeth.c
index 4154fd0..32788ca 100644
--- a/drivers/net/forcedeth.c
+++ b/drivers/net/forcedeth.c
@@ -4605,12 +4605,7 @@ static void nv_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	writel(np->txrxctl_bits, get_hwbase(dev) + NvRegTxRxControl);
 
 	spin_unlock_irq(&np->lock);
-};
-
-static void nv_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	/* nothing to do */
-};
+}
 
 /* The mgmt unit and driver use a semaphore to access the phy during init */
 static int nv_mgmt_acquire_sema(struct net_device *dev)
@@ -4956,7 +4951,6 @@ static int __devinit nv_probe(struct pci_dev *pci_dev, const struct pci_device_i
 		np->vlanctl_bits = NVREG_VLANCONTROL_ENABLE;
 		dev->features |= NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_TX;
 		dev->vlan_rx_register = nv_vlan_rx_register;
-		dev->vlan_rx_kill_vid = nv_vlan_rx_kill_vid;
 	}
 
 	np->msi_flags = 0;
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f5b3cba..6822bf1 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -140,7 +140,6 @@ int gfar_clean_rx_ring(struct net_device *dev, int rx_work_limit);
 static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int length);
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
-static void gfar_vlan_rx_kill_vid(struct net_device *netdev, uint16_t vid);
 void gfar_halt(struct net_device *dev);
 void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
@@ -284,7 +283,6 @@ static int gfar_probe(struct platform_device *pdev)
 
 	if (priv->einfo->device_flags & FSL_GIANFAR_DEV_HAS_VLAN) {
 		dev->vlan_rx_register = gfar_vlan_rx_register;
-		dev->vlan_rx_kill_vid = gfar_vlan_rx_kill_vid;
 
 		dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 
@@ -1133,20 +1131,6 @@ static void gfar_vlan_rx_register(struct net_device *dev,
 	spin_unlock_irqrestore(&priv->rxlock, flags);
 }
 
-
-static void gfar_vlan_rx_kill_vid(struct net_device *dev, uint16_t vid)
-{
-	struct gfar_private *priv = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&priv->rxlock, flags);
-
-	vlan_group_set_device(priv->vlgrp, vid, NULL);
-
-	spin_unlock_irqrestore(&priv->rxlock, flags);
-}
-
-
 static int gfar_change_mtu(struct net_device *dev, int new_mtu)
 {
 	int tempsize, tempval;
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 5d14be7..b53b7ad 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1472,6 +1472,7 @@ static const struct ethtool_ops myri10ge_ethtool_ops = {
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = ethtool_op_set_tso,
+	.get_link = ethtool_op_get_link,
 	.get_strings = myri10ge_get_strings,
 	.get_stats_count = myri10ge_get_stats_count,
 	.get_ethtool_stats = myri10ge_get_ethtool_stats,
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 2c5c6d2..c61181f 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -654,8 +654,6 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 	if (adapter->portnum == 0)
 		netxen_free_adapter_offload(adapter);
 
-	if (adapter->irq)
-		free_irq(adapter->irq, adapter);
 	if(adapter->portnum == 0) {
 		/* leave the hw in the same state as reboot */
 		writel(0, NETXEN_CRB_NORMALIZE(adapter, CRB_CMDPEG_STATE));
diff --git a/drivers/net/ns83820.c b/drivers/net/ns83820.c
index 3439f8c..717d8e9 100644
--- a/drivers/net/ns83820.c
+++ b/drivers/net/ns83820.c
@@ -506,17 +506,6 @@ static void ns83820_vlan_rx_register(struct net_device *ndev, struct vlan_group
 	spin_unlock(&dev->tx_lock);
 	spin_unlock_irq(&dev->misc_lock);
 }
-
-static void ns83820_vlan_rx_kill_vid(struct net_device *ndev, unsigned short vid)
-{
-	struct ns83820 *dev = PRIV(ndev);
-
-	spin_lock_irq(&dev->misc_lock);
-	spin_lock(&dev->tx_lock);
-	vlan_group_set_device(dev->vlgrp, vid, NULL);
-	spin_unlock(&dev->tx_lock);
-	spin_unlock_irq(&dev->misc_lock);
-}
 #endif
 
 /* Packet Receiver
@@ -2083,7 +2072,6 @@ static int __devinit ns83820_init_one(struct pci_dev *pci_dev, const struct pci_
 	/* We also support hardware vlan acceleration */
 	ndev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	ndev->vlan_rx_register = ns83820_vlan_rx_register;
-	ndev->vlan_rx_kill_vid = ns83820_vlan_rx_kill_vid;
 #endif
 
 	if (using_dac) {
diff --git a/drivers/net/qla3xxx.c b/drivers/net/qla3xxx.c
index d8766c0..585be04 100755
--- a/drivers/net/qla3xxx.c
+++ b/drivers/net/qla3xxx.c
@@ -4044,7 +4044,7 @@ static int __devinit ql3xxx_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		ndev->features |= NETIF_F_HIGHDMA;
 	if (qdev->device_id == QL3032_DEVICE_ID)
-		ndev->features |= (NETIF_F_HW_CSUM | NETIF_F_SG);
+		ndev->features |= NETIF_F_IP_CSUM | NETIF_F_SG;
 
 	qdev->mem_map_registers =
 	    ioremap_nocache(pci_resource_start(pdev, 1),
diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 45876a8..5ec7752 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -886,16 +886,6 @@ static void rtl8169_vlan_rx_register(struct net_device *dev,
 	spin_unlock_irqrestore(&tp->lock, flags);
 }
 
-static void rtl8169_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned long flags;
-
-	spin_lock_irqsave(&tp->lock, flags);
-	vlan_group_set_device(tp->vlgrp, vid, NULL);
-	spin_unlock_irqrestore(&tp->lock, flags);
-}
-
 static int rtl8169_rx_vlan_skb(struct rtl8169_private *tp, struct RxDesc *desc,
 			       struct sk_buff *skb)
 {
@@ -1671,7 +1661,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 #ifdef CONFIG_R8169_VLAN
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = rtl8169_vlan_rx_register;
-	dev->vlan_rx_kill_vid = rtl8169_vlan_rx_kill_vid;
 #endif
 
 #ifdef CONFIG_NET_POLL_CONTROLLER
diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
index e3e6d41..c6ba3de 100644
--- a/drivers/net/s2io.c
+++ b/drivers/net/s2io.c
@@ -340,17 +340,6 @@ static void s2io_vlan_rx_register(struct net_device *dev,
 /* A flag indicating whether 'RX_PA_CFG_STRIP_VLAN_TAG' bit is set or not */
 static int vlan_strip_flag;
 
-/* Unregister the vlan */
-static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned long vid)
-{
-	struct s2io_nic *nic = dev->priv;
-	unsigned long flags;
-
-	spin_lock_irqsave(&nic->tx_lock, flags);
-	vlan_group_set_device(nic->vlgrp, vid, NULL);
-	spin_unlock_irqrestore(&nic->tx_lock, flags);
-}
-
 /*
  * Constants to be programmed into the Xena's registers, to configure
  * the XAUI.
@@ -7412,7 +7401,6 @@ s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
 	SET_ETHTOOL_OPS(dev, &netdev_ethtool_ops);
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = s2io_vlan_rx_register;
-	dev->vlan_rx_kill_vid = (void *)s2io_vlan_rx_kill_vid;
 
 	/*
 	 * will use eth_mac_addr() for  dev->set_mac_address
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index adfbe81..fe01b96 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -1049,26 +1049,22 @@ static void sky2_vlan_rx_register(struct net_device *dev, struct vlan_group *grp
 	u16 port = sky2->port;
 
 	netif_tx_lock_bh(dev);
+	netif_poll_disable(sky2->hw->dev[0]);
 
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_ON);
-	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_ON);
 	sky2->vlgrp = grp;
+	if (grp) {
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_ON);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_ON);
+	} else {
+		sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T),
+			     RX_VLAN_STRIP_OFF);
+		sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T),
+			     TX_VLAN_TAG_OFF);
+	}
 
-	netif_tx_unlock_bh(dev);
-}
-
-static void sky2_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct sky2_port *sky2 = netdev_priv(dev);
-	struct sky2_hw *hw = sky2->hw;
-	u16 port = sky2->port;
-
-	netif_tx_lock_bh(dev);
-
-	sky2_write32(hw, SK_REG(port, RX_GMF_CTRL_T), RX_VLAN_STRIP_OFF);
-	sky2_write32(hw, SK_REG(port, TX_GMF_CTRL_T), TX_VLAN_TAG_OFF);
-	vlan_group_set_device(sky2->vlgrp, vid, NULL);
-
+	netif_poll_enable(sky2->hw->dev[0]);
 	netif_tx_unlock_bh(dev);
 }
 #endif
@@ -3484,7 +3480,6 @@ static __devinit struct net_device *sky2_init_netdev(struct sky2_hw *hw,
 #ifdef SKY2_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = sky2_vlan_rx_register;
-	dev->vlan_rx_kill_vid = sky2_vlan_rx_kill_vid;
 #endif
 
 	/* read the mac address */
diff --git a/drivers/net/smc91x.h b/drivers/net/smc91x.h
index 111f23d..506bffc 100644
--- a/drivers/net/smc91x.h
+++ b/drivers/net/smc91x.h
@@ -281,17 +281,14 @@ SMC_outw(u16 val, void __iomem *ioaddr, int reg)
 
 #elif   defined(CONFIG_SUPERH)
 
-#if defined(CONFIG_SH_7780_SOLUTION_ENGINE) || defined(CONFIG_SH_7722_SOLUTION_ENGINE)
+#ifdef CONFIG_SOLUTION_ENGINE
 #define SMC_CAN_USE_8BIT       0
 #define SMC_CAN_USE_16BIT      1
 #define SMC_CAN_USE_32BIT      0
 #define SMC_IO_SHIFT           0
 #define SMC_NOWAIT             1
 
-#define SMC_inb(a, r)          (inw((a) + ((r)&~1)) >> (8*(r%2)))&0xff
 #define SMC_inw(a, r)          inw((a) + (r))
-#define SMC_outb(v, a, r)      outw(((inw((a)+((r)&~1))*(0xff<<8*(r%2)))) | ((v)<<(8*(r&2)))), (a) + ((r)&~1))
-
 #define SMC_outw(v, a, r)      outw(v, (a) + (r))
 #define SMC_insw(a, r, p, l)   insw((a) + (r), p, l)
 #define SMC_outsw(a, r, p, l)  outsw((a) + (r), p, l)
diff --git a/drivers/net/spider_net.c b/drivers/net/spider_net.c
index ef84d7c..b47ad1d 100644
--- a/drivers/net/spider_net.c
+++ b/drivers/net/spider_net.c
@@ -1191,43 +1191,6 @@ spider_net_poll(struct net_device *netdev, int *budget)
 }
 
 /**
- * spider_net_vlan_rx_reg - initializes VLAN structures in the driver and card
- * @netdev: interface device structure
- * @grp: vlan_group structure that is registered (NULL on destroying interface)
- */
-static void
-spider_net_vlan_rx_reg(struct net_device *netdev, struct vlan_group *grp)
-{
-	/* further enhancement... yet to do */
-	return;
-}
-
-/**
- * spider_net_vlan_rx_add - adds VLAN id to the card filter
- * @netdev: interface device structure
- * @vid: VLAN id to add
- */
-static void
-spider_net_vlan_rx_add(struct net_device *netdev, uint16_t vid)
-{
-	/* further enhancement... yet to do */
-	/* add vid to card's VLAN filter table */
-	return;
-}
-
-/**
- * spider_net_vlan_rx_kill - removes VLAN id to the card filter
- * @netdev: interface device structure
- * @vid: VLAN id to remove
- */
-static void
-spider_net_vlan_rx_kill(struct net_device *netdev, uint16_t vid)
-{
-	/* further enhancement... yet to do */
-	/* remove vid from card's VLAN filter table */
-}
-
-/**
  * spider_net_get_stats - get interface statistics
  * @netdev: interface device structure
  *
@@ -2177,9 +2140,6 @@ spider_net_setup_netdev_ops(struct net_device *netdev)
 	netdev->poll = &spider_net_poll;
 	netdev->weight = SPIDER_NET_NAPI_WEIGHT;
 	/* HW VLAN */
-	netdev->vlan_rx_register = &spider_net_vlan_rx_reg;
-	netdev->vlan_rx_add_vid = &spider_net_vlan_rx_add;
-	netdev->vlan_rx_kill_vid = &spider_net_vlan_rx_kill;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	/* poll controller */
 	netdev->poll_controller = &spider_net_poll_controller;
diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 923b9c7..023779a 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9121,21 +9121,6 @@ static void tg3_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	if (netif_running(dev))
 		tg3_netif_start(tp);
 }
-
-static void tg3_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct tg3 *tp = netdev_priv(dev);
-
-	if (netif_running(dev))
-		tg3_netif_stop(tp);
-
-	tg3_full_lock(tp, 0);
-	vlan_group_set_device(tp->vlgrp, vid, NULL);
-	tg3_full_unlock(tp);
-
-	if (netif_running(dev))
-		tg3_netif_start(tp);
-}
 #endif
 
 static int tg3_get_coalesce(struct net_device *dev, struct ethtool_coalesce *ec)
@@ -11778,7 +11763,6 @@ static int __devinit tg3_init_one(struct pci_dev *pdev,
 #if TG3_VLAN_TAG_USED
 	dev->features |= NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 	dev->vlan_rx_register = tg3_vlan_rx_register;
-	dev->vlan_rx_kill_vid = tg3_vlan_rx_kill_vid;
 #endif
 
 	tp = netdev_priv(dev);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index f725735..15b2fb8 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -741,15 +741,6 @@ typhoon_vlan_rx_register(struct net_device *dev, struct vlan_group *grp)
 	spin_unlock_bh(&tp->state_lock);
 }
 
-static void
-typhoon_vlan_rx_kill_vid(struct net_device *dev, unsigned short vid)
-{
-	struct typhoon *tp = netdev_priv(dev);
-	spin_lock_bh(&tp->state_lock);
-	vlan_group_set_device(tp->vlgrp, vid, NULL);
-	spin_unlock_bh(&tp->state_lock);
-}
-
 static inline void
 typhoon_tso_fill(struct sk_buff *skb, struct transmit_ring *txRing,
 			u32 ring_dma)
@@ -2542,7 +2533,7 @@ typhoon_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->get_stats		= typhoon_get_stats;
 	dev->set_mac_address	= typhoon_set_mac_address;
 	dev->vlan_rx_register	= typhoon_vlan_rx_register;
-	dev->vlan_rx_kill_vid	= typhoon_vlan_rx_kill_vid;
+
 	SET_ETHTOOL_OPS(dev, &typhoon_ethtool_ops);
 
 	/* We can handle scatter gather, up to 16 entries, and
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index bd93c45..ceef57c 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -240,10 +240,8 @@ static int unregister_vlan_dev(struct net_device *real_dev,
 			 * interlock with HW accelerating devices or SW vlan
 			 * input packet processing.
 			 */
-			if (real_dev->features &
-			    (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER)) {
+			if (real_dev->features & NETIF_F_HW_VLAN_FILTER)
 				real_dev->vlan_rx_kill_vid(real_dev, vlan_id);
-			}
 
 			vlan_group_set_device(grp, vlan_id, NULL);
 			synchronize_net();
@@ -409,16 +407,14 @@ static struct net_device *register_vlan_device(const char *eth_IF_name,
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_RX) &&
-	    (real_dev->vlan_rx_register == NULL ||
-	     real_dev->vlan_rx_kill_vid == NULL)) {
+	    !real_dev->vlan_rx_register) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
 			__FUNCTION__, real_dev->name);
 		goto out_put_dev;
 	}
 
 	if ((real_dev->features & NETIF_F_HW_VLAN_FILTER) &&
-	    (real_dev->vlan_rx_add_vid == NULL ||
-	     real_dev->vlan_rx_kill_vid == NULL)) {
+	    (!real_dev->vlan_rx_add_vid || !real_dev->vlan_rx_kill_vid)) {
 		printk(VLAN_DBG "%s: Device %s has buggy VLAN hw accel.\n",
 			__FUNCTION__, real_dev->name);
 		goto out_put_dev;
