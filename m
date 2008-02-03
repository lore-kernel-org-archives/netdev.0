From: Jay Cliburn <jacliburn@bellsouth.net>
Subject: [PATCH 02/10] atl1: move common functions to atlx files
Date: Sat,  2 Feb 2008 19:50:04 -0600
Message-ID: <1202003412-4028-2-git-send-email-jacliburn@bellsouth.net>
References: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: csnook@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Jay Cliburn <jacliburn@bellsouth.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmailhost04.isp.att.net ([207.115.11.54]:48576 "EHLO
	fmailhost04.isp.att.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933312AbYBCBuZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Feb 2008 20:50:25 -0500
In-Reply-To: <1202003412-4028-1-git-send-email-jacliburn@bellsouth.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The future atl2 driver and the existing atl1 driver can share certain
functions and definitions.  Move these shareable functions and definiti=
ons
out of atl1-specific files and into atlx.c and atlx.h.  Some transitory
hackery will be present until atl2 is merged.

Reduce the number of source files by moving ethtool, hw, and param
functions from separate files into atl1_main.c, then rename it to just
atl1.c.

Move all atl1-specific definitions from atl1_hw.h to atl1.h.

=46inally, clean up to make checkpatch.pl happy.

Signed-off-by: Chris Snook <csnook@redhat.com>
Signed-off-by: Jay Cliburn <jacliburn@bellsouth.net>
---
 drivers/net/atlx/Makefile                |    1 -
 drivers/net/atlx/{atl1_main.c =3D> atl1.c} | 1544 ++++++++++++++++++++=
++++------
 drivers/net/atlx/atl1.h                  |  603 +++++++++++-
 drivers/net/atlx/atl1_ethtool.c          |  505 ----------
 drivers/net/atlx/atl1_hw.c               |  720 --------------
 drivers/net/atlx/atl1_hw.h               |  946 ------------------
 drivers/net/atlx/atl1_param.c            |  203 ----
 drivers/net/atlx/atlx.c                  |  433 +++++++++
 drivers/net/atlx/atlx.h                  |  506 ++++++++++
 9 files changed, 2751 insertions(+), 2710 deletions(-)
 rename drivers/net/atlx/{atl1_main.c =3D> atl1.c} (65%)
 delete mode 100644 drivers/net/atlx/atl1_ethtool.c
 delete mode 100644 drivers/net/atlx/atl1_hw.c
 delete mode 100644 drivers/net/atlx/atl1_hw.h
 delete mode 100644 drivers/net/atlx/atl1_param.c
 create mode 100644 drivers/net/atlx/atlx.c
 create mode 100644 drivers/net/atlx/atlx.h

diff --git a/drivers/net/atlx/Makefile b/drivers/net/atlx/Makefile
index a6b707e..ca45553 100644
--- a/drivers/net/atlx/Makefile
+++ b/drivers/net/atlx/Makefile
@@ -1,2 +1 @@
 obj-$(CONFIG_ATL1)	+=3D atl1.o
-atl1-y			+=3D atl1_main.o atl1_hw.o atl1_ethtool.o atl1_param.o
diff --git a/drivers/net/atlx/atl1_main.c b/drivers/net/atlx/atl1.c
similarity index 65%
rename from drivers/net/atlx/atl1_main.c
rename to drivers/net/atlx/atl1.c
index 9200ee5..a84c97c 100644
--- a/drivers/net/atlx/atl1_main.c
+++ b/drivers/net/atlx/atl1.c
@@ -1,6 +1,6 @@
 /*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
- * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
+ * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
  *
  * Derived from Intel e1000 driver
@@ -50,51 +50,46 @@
  * SMP torture testing
  */
=20
-#include <linux/types.h>
-#include <linux/netdevice.h>
-#include <linux/pci.h>
-#include <linux/spinlock.h>
-#include <linux/slab.h>
-#include <linux/string.h>
-#include <linux/skbuff.h>
+#include <asm/atomic.h>
+#include <asm/byteorder.h>
+
+#include <linux/compiler.h>
+#include <linux/crc32.h>
+#include <linux/delay.h>
+#include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
-#include <linux/if_vlan.h>
-#include <linux/if_ether.h>
-#include <linux/irqreturn.h>
-#include <linux/workqueue.h>
-#include <linux/timer.h>
-#include <linux/jiffies.h>
 #include <linux/hardirq.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/in.h>
 #include <linux/interrupt.h>
+#include <linux/ip.h>
 #include <linux/irqflags.h>
-#include <linux/dma-mapping.h>
+#include <linux/irqreturn.h>
+#include <linux/jiffies.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/moduleparam.h>
 #include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/pci.h>
+#include <linux/pci_ids.h>
 #include <linux/pm.h>
-#include <linux/in.h>
-#include <linux/ip.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
 #include <linux/tcp.h>
-#include <linux/compiler.h>
-#include <linux/delay.h>
-#include <linux/mii.h>
-#include <net/checksum.h>
+#include <linux/timer.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
=20
-#include <asm/atomic.h>
-#include <asm/byteorder.h>
+#include <net/checksum.h>
=20
 #include "atl1.h"
=20
-#define DRIVER_VERSION "2.0.7"
-
-char atl1_driver_name[] =3D "atl1";
-static const char atl1_driver_string[] =3D "Attansic L1 Ethernet Netwo=
rk Driver";
-static const char atl1_copyright[] =3D "Copyright(c) 2005-2006 Attansi=
c Corporation.";
-char atl1_driver_version[] =3D DRIVER_VERSION;
-
-MODULE_AUTHOR
-    ("Attansic Corporation <xiong_huang@attansic.com>, Chris Snook <cs=
nook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
-MODULE_DESCRIPTION("Attansic 1000M Ethernet Network Driver");
-MODULE_LICENSE("GPL");
-MODULE_VERSION(DRIVER_VERSION);
+/* Temporary hack for merging atl1 and atl2 */
+#include "atlx.c"
=20
 /*
  * atl1_pci_tbl - PCI Device ID Table
@@ -104,7 +99,6 @@ static const struct pci_device_id atl1_pci_tbl[] =3D=
 {
 	/* required last entry */
 	{0,}
 };
-
 MODULE_DEVICE_TABLE(pci, atl1_pci_tbl);
=20
 /*
@@ -125,7 +119,7 @@ static int __devinit atl1_sw_init(struct atl1_adapt=
er *adapter)
=20
 	adapter->wol =3D 0;
 	adapter->rx_buffer_len =3D (hw->max_frame_size + 7) & ~7;
-	adapter->ict =3D 50000;	/* 100ms */
+	adapter->ict =3D 50000;		/* 100ms */
 	adapter->link_speed =3D SPEED_0;	/* hardware init */
 	adapter->link_duplex =3D FULL_DUPLEX;
=20
@@ -206,24 +200,6 @@ static int atl1_mii_ioctl(struct net_device *netde=
v, struct ifreq *ifr, int cmd)
 }
=20
 /*
- * atl1_ioctl -
- * @netdev:
- * @ifreq:
- * @cmd:
- */
-static int atl1_ioctl(struct net_device *netdev, struct ifreq *ifr, in=
t cmd)
-{
-	switch (cmd) {
-	case SIOCGMIIPHY:
-	case SIOCGMIIREG:
-	case SIOCSMIIREG:
-		return atl1_mii_ioctl(netdev, ifr, cmd);
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-/*
  * atl1_setup_mem_resources - allocate Tx / RX descriptor resources
  * @adapter: board private structure
  *
@@ -248,7 +224,8 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *=
adapter)
 	rfd_ring->buffer_info =3D
 		(struct atl1_buffer *)(tpd_ring->buffer_info + tpd_ring->count);
=20
-	/* real ring DMA buffer
+	/*
+	 * real ring DMA buffer
 	 * each ring/block may need up to 8 bytes for alignment, hence the
 	 * additional 40 bytes tacked onto the end.
 	 */
@@ -307,7 +284,7 @@ s32 atl1_setup_ring_resources(struct atl1_adapter *=
adapter)
 		((u8 *) adapter->cmb.cmb +
 		(sizeof(struct coals_msg_block) + offset));
=20
-	return ATL1_SUCCESS;
+	return 0;
=20
 err_nomem:
 	kfree(tpd_ring->buffer_info);
@@ -481,31 +458,6 @@ static void atl1_setup_mac_ctrl(struct atl1_adapte=
r *adapter)
 	iowrite32(value, hw->hw_addr + REG_MAC_CTRL);
 }
=20
-/*
- * atl1_set_mac - Change the Ethernet Address of the NIC
- * @netdev: network interface device structure
- * @p: pointer to an address structure
- *
- * Returns 0 on success, negative on failure
- */
-static int atl1_set_mac(struct net_device *netdev, void *p)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct sockaddr *addr =3D p;
-
-	if (netif_running(netdev))
-		return -EBUSY;
-
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-
-	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
-	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
-
-	atl1_set_mac_addr(&adapter->hw);
-	return 0;
-}
-
 static u32 atl1_check_link(struct atl1_adapter *adapter)
 {
 	struct atl1_hw *hw =3D &adapter->hw;
@@ -517,14 +469,16 @@ static u32 atl1_check_link(struct atl1_adapter *a=
dapter)
 	/* MII_BMSR must read twice */
 	atl1_read_phy_reg(hw, MII_BMSR, &phy_data);
 	atl1_read_phy_reg(hw, MII_BMSR, &phy_data);
-	if (!(phy_data & BMSR_LSTATUS)) {	/* link down */
-		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
+	if (!(phy_data & BMSR_LSTATUS)) {
+		/* link down */
+		if (netif_carrier_ok(netdev)) {
+			/* old link state: Up */
 			dev_info(&adapter->pdev->dev, "link is down\n");
 			adapter->link_speed =3D SPEED_0;
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
 		}
-		return ATL1_SUCCESS;
+		return 0;
 	}
=20
 	/* Link Up */
@@ -568,14 +522,15 @@ static u32 atl1_check_link(struct atl1_adapter *a=
dapter)
 				adapter->link_duplex =3D=3D FULL_DUPLEX ?
 				"full duplex" : "half duplex");
 		}
-		if (!netif_carrier_ok(netdev)) {	/* Link down -> Up */
+		if (!netif_carrier_ok(netdev)) {
+			/* Link down -> Up */
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
 		}
-		return ATL1_SUCCESS;
+		return 0;
 	}
=20
-	/* change orignal link status */
+	/* change original link status */
 	if (netif_carrier_ok(netdev)) {
 		adapter->link_speed =3D SPEED_0;
 		netif_carrier_off(netdev);
@@ -596,12 +551,13 @@ static u32 atl1_check_link(struct atl1_adapter *a=
dapter)
 			phy_data =3D
 			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
 			break;
-		default:	/* MEDIA_TYPE_10M_HALF: */
+		default:
+			/* MEDIA_TYPE_10M_HALF: */
 			phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
 			break;
 		}
 		atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-		return ATL1_SUCCESS;
+		return 0;
 	}
=20
 	/* auto-neg, insert timer to re-config phy */
@@ -610,71 +566,7 @@ static u32 atl1_check_link(struct atl1_adapter *ad=
apter)
 		mod_timer(&adapter->phy_config_timer, jiffies + 3 * HZ);
 	}
=20
-	return ATL1_SUCCESS;
-}
-
-static void atl1_check_for_link(struct atl1_adapter *adapter)
-{
-	struct net_device *netdev =3D adapter->netdev;
-	u16 phy_data =3D 0;
-
-	spin_lock(&adapter->lock);
-	adapter->phy_timer_pending =3D false;
-	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
-	atl1_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
-	spin_unlock(&adapter->lock);
-
-	/* notify upper layer link down ASAP */
-	if (!(phy_data & BMSR_LSTATUS)) {	/* Link Down */
-		if (netif_carrier_ok(netdev)) {	/* old link state: Up */
-			dev_info(&adapter->pdev->dev, "%s link is down\n",
-				netdev->name);
-			adapter->link_speed =3D SPEED_0;
-			netif_carrier_off(netdev);
-			netif_stop_queue(netdev);
-		}
-	}
-	schedule_work(&adapter->link_chg_task);
-}
-
-/*
- * atl1_set_multi - Multicast and Promiscuous mode set
- * @netdev: network interface device structure
- *
- * The set_multi entry point is called whenever the multicast address
- * list or the network interface flags are updated.  This routine is
- * responsible for configuring the hardware for proper multicast,
- * promiscuous mode, and all-multi behavior.
- */
-static void atl1_set_multi(struct net_device *netdev)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_hw *hw =3D &adapter->hw;
-	struct dev_mc_list *mc_ptr;
-	u32 rctl;
-	u32 hash_value;
-
-	/* Check for Promiscuous and All Multicast modes */
-	rctl =3D ioread32(hw->hw_addr + REG_MAC_CTRL);
-	if (netdev->flags & IFF_PROMISC)
-		rctl |=3D MAC_CTRL_PROMIS_EN;
-	else if (netdev->flags & IFF_ALLMULTI) {
-		rctl |=3D MAC_CTRL_MC_ALL_EN;
-		rctl &=3D ~MAC_CTRL_PROMIS_EN;
-	} else
-		rctl &=3D ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
-
-	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
-
-	/* clear the old settings from the multicast hash table */
-	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
-
-	/* compute mc addresses' hash value ,and put it into hash table */
-	for (mc_ptr =3D netdev->mc_list; mc_ptr; mc_ptr =3D mc_ptr->next) {
-		hash_value =3D atl1_hash_mc_addr(hw, mc_ptr->dmi_addr);
-		atl1_hash_set(hw, hash_value);
-	}
+	return 0;
 }
=20
 /*
@@ -974,37 +866,6 @@ static void atl1_via_workaround(struct atl1_adapte=
r *adapter)
 	iowrite32(value, adapter->hw.hw_addr + PCI_COMMAND);
 }
=20
-/*
- * atl1_irq_enable - Enable default interrupt generation settings
- * @adapter: board private structure
- */
-static void atl1_irq_enable(struct atl1_adapter *adapter)
-{
-	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
-	ioread32(adapter->hw.hw_addr + REG_IMR);
-}
-
-/*
- * atl1_irq_disable - Mask off interrupt generation on the NIC
- * @adapter: board private structure
- */
-static void atl1_irq_disable(struct atl1_adapter *adapter)
-{
-	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
-	ioread32(adapter->hw.hw_addr + REG_IMR);
-	synchronize_irq(adapter->pdev->irq);
-}
-
-static void atl1_clear_phy_int(struct atl1_adapter *adapter)
-{
-	u16 phy_data;
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	atl1_read_phy_reg(&adapter->hw, 19, &phy_data);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
 static void atl1_inc_smb(struct atl1_adapter *adapter)
 {
 	struct stats_msg_block *smb =3D adapter->smb.smb;
@@ -1076,19 +937,6 @@ static void atl1_inc_smb(struct atl1_adapter *ada=
pter)
 		adapter->soft_stats.tx_carrier_errors;
 }
=20
-/*
- * atl1_get_stats - Get System Network Statistics
- * @netdev: network interface device structure
- *
- * Returns the address of the device statistics structure.
- * The statistics are actually updated from the timer callback.
- */
-static struct net_device_stats *atl1_get_stats(struct net_device *netd=
ev)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	return &adapter->net_stats;
-}
-
 static void atl1_update_mailbox(struct atl1_adapter *adapter)
 {
 	unsigned long flags;
@@ -1210,7 +1058,8 @@ static u16 atl1_alloc_rx_buffers(struct atl1_adap=
ter *adapter)
 		rfd_desc =3D ATL1_RFD_DESC(rfd_ring, rfd_next_to_use);
=20
 		skb =3D dev_alloc_skb(adapter->rx_buffer_len + NET_IP_ALIGN);
-		if (unlikely(!skb)) {	/* Better luck next round */
+		if (unlikely(!skb)) {
+			/* Better luck next round */
 			adapter->net_stats.rx_dropped++;
 			break;
 		}
@@ -1519,7 +1368,8 @@ static void atl1_tx_map(struct atl1_adapter *adap=
ter, struct sk_buff *skb,
 	buffer_info =3D &tpd_ring->buffer_info[tpd_next_to_use];
 	if (unlikely(buffer_info->skb))
 		BUG();
-	buffer_info->skb =3D NULL;	/* put skb in last TPD */
+	/* put skb in last TPD */
+	buffer_info->skb =3D NULL;
=20
 	if (tcp_seg) {
 		/* TSO/GSO */
@@ -1779,7 +1629,7 @@ static irqreturn_t atl1_intr(int irq, void *data)
 		adapter->cmb.cmb->int_stats =3D 0;
=20
 		if (status & ISR_GPHY)	/* clear phy status */
-			atl1_clear_phy_int(adapter);
+			atlx_clear_phy_int(adapter);
=20
 		/* clear ISR status, and Enable CMB DMA/Disable Interrupt */
 		iowrite32(status | ISR_DIS_INT, adapter->hw.hw_addr + REG_ISR);
@@ -1866,23 +1716,12 @@ static void atl1_phy_config(unsigned long data)
 	spin_lock_irqsave(&adapter->lock, flags);
 	adapter->phy_timer_pending =3D false;
 	atl1_write_phy_reg(hw, MII_ADVERTISE, hw->mii_autoneg_adv_reg);
-	atl1_write_phy_reg(hw, MII_AT001_CR, hw->mii_1000t_ctrl_reg);
+	atl1_write_phy_reg(hw, MII_ATLX_CR, hw->mii_1000t_ctrl_reg);
 	atl1_write_phy_reg(hw, MII_BMCR, MII_CR_RESET | MII_CR_AUTO_NEG_EN);
 	spin_unlock_irqrestore(&adapter->lock, flags);
 }
=20
 /*
- * atl1_tx_timeout - Respond to a Tx Hang
- * @netdev: network interface device structure
- */
-static void atl1_tx_timeout(struct net_device *netdev)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	/* Do the reset outside of interrupt context */
-	schedule_work(&adapter->tx_timeout_task);
-}
-
-/*
  * Orphaned vendor comment left intact here:
  * <vendor comment>
  * If TPD Buffer size equal to 0, PCIE DMAR_TO_INT
@@ -1904,58 +1743,11 @@ static void atl1_tx_timeout_task(struct work_st=
ruct *work)
 	netif_device_attach(netdev);
 }
=20
-/*
- * atl1_link_chg_task - deal with link change event Out of interrupt c=
ontext
- */
-static void atl1_link_chg_task(struct work_struct *work)
-{
-	struct atl1_adapter *adapter =3D
-               container_of(work, struct atl1_adapter, link_chg_task);
-	unsigned long flags;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	atl1_check_link(adapter);
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
-static void atl1_vlan_rx_register(struct net_device *netdev,
-	struct vlan_group *grp)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	unsigned long flags;
-	u32 ctrl;
-
-	spin_lock_irqsave(&adapter->lock, flags);
-	/* atl1_irq_disable(adapter); */
-	adapter->vlgrp =3D grp;
-
-	if (grp) {
-		/* enable VLAN tag insert/strip */
-		ctrl =3D ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl |=3D MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
-	} else {
-		/* disable VLAN tag insert/strip */
-		ctrl =3D ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
-		ctrl &=3D ~MAC_CTRL_RMV_VLAN;
-		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
-	}
-
-	/* atl1_irq_enable(adapter); */
-	spin_unlock_irqrestore(&adapter->lock, flags);
-}
-
-static void atl1_restore_vlan(struct atl1_adapter *adapter)
-{
-	atl1_vlan_rx_register(adapter->netdev, adapter->vlgrp);
-}
-
 int atl1_reset(struct atl1_adapter *adapter)
 {
 	int ret;
-
 	ret =3D atl1_reset_hw(&adapter->hw);
-	if (ret !=3D ATL1_SUCCESS)
+	if (ret)
 		return ret;
 	return atl1_init_hw(&adapter->hw);
 }
@@ -1967,11 +1759,12 @@ s32 atl1_up(struct atl1_adapter *adapter)
 	int irq_flags =3D IRQF_SAMPLE_RANDOM;
=20
 	/* hardware has been reset, we need to reload some things */
-	atl1_set_multi(netdev);
+	atlx_set_multi(netdev);
 	atl1_init_ring_ptrs(adapter);
-	atl1_restore_vlan(adapter);
+	atlx_restore_vlan(adapter);
 	err =3D atl1_alloc_rx_buffers(adapter);
-	if (unlikely(!err))		/* no RX BUFFER allocated */
+	if (unlikely(!err))
+		/* no RX BUFFER allocated */
 		return -ENOMEM;
=20
 	if (unlikely(atl1_configure(adapter))) {
@@ -1992,7 +1785,7 @@ s32 atl1_up(struct atl1_adapter *adapter)
 		goto err_up;
=20
 	mod_timer(&adapter->watchdog_timer, jiffies);
-	atl1_irq_enable(adapter);
+	atlx_irq_enable(adapter);
 	atl1_check_link(adapter);
 	return 0;
=20
@@ -2011,7 +1804,7 @@ void atl1_down(struct atl1_adapter *adapter)
 	del_timer_sync(&adapter->phy_config_timer);
 	adapter->phy_timer_pending =3D false;
=20
-	atl1_irq_disable(adapter);
+	atlx_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
 	pci_disable_msi(adapter->pdev);
 	atl1_reset_hw(&adapter->hw);
@@ -2094,7 +1887,7 @@ static int atl1_suspend(struct pci_dev *pdev, pm_=
message_t state)
 	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
 	atl1_read_phy_reg(hw, MII_BMSR, (u16 *) & ctrl);
 	if (ctrl & BMSR_LSTATUS)
-		wufc &=3D ~ATL1_WUFC_LNKC;
+		wufc &=3D ~ATLX_WUFC_LNKC;
=20
 	/* reduce speed to 10/100M */
 	if (wufc) {
@@ -2102,15 +1895,15 @@ static int atl1_suspend(struct pci_dev *pdev, p=
m_message_t state)
 		/* if resume, let driver to re- setup link */
 		hw->phy_configured =3D false;
 		atl1_set_mac_addr(hw);
-		atl1_set_multi(netdev);
+		atlx_set_multi(netdev);
=20
 		ctrl =3D 0;
 		/* turn on magic packet wol */
-		if (wufc & ATL1_WUFC_MAG)
+		if (wufc & ATLX_WUFC_MAG)
 			ctrl =3D WOL_MAGIC_EN | WOL_MAGIC_PME_EN;
=20
 		/* turn on Link change WOL */
-		if (wufc & ATL1_WUFC_LNKC)
+		if (wufc & ATLX_WUFC_LNKC)
 			ctrl |=3D (WOL_LINK_CHG_EN | WOL_LINK_CHG_PME_EN);
 		iowrite32(ctrl, hw->hw_addr + REG_WOL_CTRL);
=20
@@ -2118,13 +1911,13 @@ static int atl1_suspend(struct pci_dev *pdev, p=
m_message_t state)
 		ctrl =3D ioread32(hw->hw_addr + REG_MAC_CTRL);
 		ctrl &=3D ~MAC_CTRL_DBG;
 		ctrl &=3D ~MAC_CTRL_PROMIS_EN;
-		if (wufc & ATL1_WUFC_MC)
+		if (wufc & ATLX_WUFC_MC)
 			ctrl |=3D MAC_CTRL_MC_ALL_EN;
 		else
 			ctrl &=3D ~MAC_CTRL_MC_ALL_EN;
=20
 		/* turn on broadcast mode if wake on-BC is enabled */
-		if (wufc & ATL1_WUFC_BC)
+		if (wufc & ATLX_WUFC_BC)
 			ctrl |=3D MAC_CTRL_BC_EN;
 		else
 			ctrl &=3D ~MAC_CTRL_BC_EN;
@@ -2152,12 +1945,13 @@ static int atl1_resume(struct pci_dev *pdev)
 {
 	struct net_device *netdev =3D pci_get_drvdata(pdev);
 	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	u32 ret_val;
+	u32 err;
=20
-	pci_set_power_state(pdev, 0);
+	pci_set_power_state(pdev, PCI_D0);
 	pci_restore_state(pdev);
=20
-	ret_val =3D pci_enable_device(pdev);
+	/* FIXME: check and handle */
+	err =3D pci_enable_device(pdev);
 	pci_enable_wake(pdev, PCI_D3hot, 0);
 	pci_enable_wake(pdev, PCI_D3cold, 0);
=20
@@ -2224,14 +2018,16 @@ static int __devinit atl1_probe(struct pci_dev =
*pdev,
 		dev_err(&pdev->dev, "no usable DMA configuration\n");
 		goto err_dma;
 	}
-	/* Mark all PCI regions associated with PCI device
+	/*
+	 * Mark all PCI regions associated with PCI device
 	 * pdev as being reserved by owner atl1_driver_name
 	 */
-	err =3D pci_request_regions(pdev, atl1_driver_name);
+	err =3D pci_request_regions(pdev, ATLX_DRIVER_NAME);
 	if (err)
 		goto err_request_regions;
=20
-	/* Enables bus-mastering on the device and calls
+	/*
+	 * Enables bus-mastering on the device and calls
 	 * pcibios_set_master to do the needed arch specific settings
 	 */
 	pci_set_master(pdev);
@@ -2257,7 +2053,7 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
 	/* get device revision number */
 	adapter->hw.dev_rev =3D ioread16(adapter->hw.hw_addr +
 		(REG_MASTER_CTRL + 2));
-	dev_info(&pdev->dev, "version %s\n", DRIVER_VERSION);
+	dev_info(&pdev->dev, "version %s\n", ATLX_DRIVER_VERSION);
=20
 	/* set default ring resource counts */
 	adapter->rfd_ring.count =3D adapter->rrd_ring.count =3D ATL1_DEFAULT_=
RFD;
@@ -2272,17 +2068,17 @@ static int __devinit atl1_probe(struct pci_dev =
*pdev,
 	netdev->open =3D &atl1_open;
 	netdev->stop =3D &atl1_close;
 	netdev->hard_start_xmit =3D &atl1_xmit_frame;
-	netdev->get_stats =3D &atl1_get_stats;
-	netdev->set_multicast_list =3D &atl1_set_multi;
+	netdev->get_stats =3D &atlx_get_stats;
+	netdev->set_multicast_list =3D &atlx_set_multi;
 	netdev->set_mac_address =3D &atl1_set_mac;
 	netdev->change_mtu =3D &atl1_change_mtu;
-	netdev->do_ioctl =3D &atl1_ioctl;
-	netdev->tx_timeout =3D &atl1_tx_timeout;
+	netdev->do_ioctl =3D &atlx_ioctl;
+	netdev->tx_timeout =3D &atlx_tx_timeout;
 	netdev->watchdog_timeo =3D 5 * HZ;
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller =3D atl1_poll_controller;
 #endif
-	netdev->vlan_rx_register =3D atl1_vlan_rx_register;
+	netdev->vlan_rx_register =3D atlx_vlan_rx_register;
=20
 	netdev->ethtool_ops =3D &atl1_ethtool_ops;
 	adapter->bd_number =3D cards_found;
@@ -2312,7 +2108,7 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
 	/* atl1_pcie_patch(adapter); */
=20
 	/* really reset GPHY core */
-	iowrite16(0, adapter->hw.hw_addr + REG_GPHY_ENABLE);
+	iowrite16(0, adapter->hw.hw_addr + REG_PHY_ENABLE);
=20
 	/*
 	 * reset the controller to
@@ -2357,7 +2153,7 @@ static int __devinit atl1_probe(struct pci_dev *p=
dev,
=20
 	INIT_WORK(&adapter->tx_timeout_task, atl1_tx_timeout_task);
=20
-	INIT_WORK(&adapter->link_chg_task, atl1_link_chg_task);
+	INIT_WORK(&adapter->link_chg_task, atlx_link_chg_task);
=20
 	INIT_WORK(&adapter->pcie_dma_to_rst_task, atl1_tx_timeout_task);
=20
@@ -2400,7 +2196,8 @@ static void __devexit atl1_remove(struct pci_dev =
*pdev)
=20
 	adapter =3D netdev_priv(netdev);
=20
-	/* Some atl1 boards lack persistent storage for their MAC, and get it
+	/*
+	 * Some atl1 boards lack persistent storage for their MAC, and get it
 	 * from the BIOS during POST.  If we've been messing with the MAC
 	 * address, we need to save the permanent one.
 	 */
@@ -2410,7 +2207,7 @@ static void __devexit atl1_remove(struct pci_dev =
*pdev)
 		atl1_set_mac_addr(&adapter->hw);
 	}
=20
-	iowrite16(0, adapter->hw.hw_addr + REG_GPHY_ENABLE);
+	iowrite16(0, adapter->hw.hw_addr + REG_PHY_ENABLE);
 	unregister_netdev(netdev);
 	pci_iounmap(pdev, adapter->hw.hw_addr);
 	pci_release_regions(pdev);
@@ -2419,7 +2216,7 @@ static void __devexit atl1_remove(struct pci_dev =
*pdev)
 }
=20
 static struct pci_driver atl1_driver =3D {
-	.name =3D atl1_driver_name,
+	.name =3D ATLX_DRIVER_NAME,
 	.id_table =3D atl1_pci_tbl,
 	.probe =3D atl1_probe,
 	.remove =3D __devexit_p(atl1_remove),
@@ -2451,3 +2248,1170 @@ static int __init atl1_init_module(void)
=20
 module_init(atl1_init_module);
 module_exit(atl1_exit_module);
+
+struct atl1_stats {
+	char stat_string[ETH_GSTRING_LEN];
+	int sizeof_stat;
+	int stat_offset;
+};
+
+#define ATL1_STAT(m) \
+	sizeof(((struct atl1_adapter *)0)->m), offsetof(struct atl1_adapter, =
m)
+
+static struct atl1_stats atl1_gstrings_stats[] =3D {
+	{"rx_packets", ATL1_STAT(soft_stats.rx_packets)},
+	{"tx_packets", ATL1_STAT(soft_stats.tx_packets)},
+	{"rx_bytes", ATL1_STAT(soft_stats.rx_bytes)},
+	{"tx_bytes", ATL1_STAT(soft_stats.tx_bytes)},
+	{"rx_errors", ATL1_STAT(soft_stats.rx_errors)},
+	{"tx_errors", ATL1_STAT(soft_stats.tx_errors)},
+	{"rx_dropped", ATL1_STAT(net_stats.rx_dropped)},
+	{"tx_dropped", ATL1_STAT(net_stats.tx_dropped)},
+	{"multicast", ATL1_STAT(soft_stats.multicast)},
+	{"collisions", ATL1_STAT(soft_stats.collisions)},
+	{"rx_length_errors", ATL1_STAT(soft_stats.rx_length_errors)},
+	{"rx_over_errors", ATL1_STAT(soft_stats.rx_missed_errors)},
+	{"rx_crc_errors", ATL1_STAT(soft_stats.rx_crc_errors)},
+	{"rx_frame_errors", ATL1_STAT(soft_stats.rx_frame_errors)},
+	{"rx_fifo_errors", ATL1_STAT(soft_stats.rx_fifo_errors)},
+	{"rx_missed_errors", ATL1_STAT(soft_stats.rx_missed_errors)},
+	{"tx_aborted_errors", ATL1_STAT(soft_stats.tx_aborted_errors)},
+	{"tx_carrier_errors", ATL1_STAT(soft_stats.tx_carrier_errors)},
+	{"tx_fifo_errors", ATL1_STAT(soft_stats.tx_fifo_errors)},
+	{"tx_window_errors", ATL1_STAT(soft_stats.tx_window_errors)},
+	{"tx_abort_exce_coll", ATL1_STAT(soft_stats.excecol)},
+	{"tx_abort_late_coll", ATL1_STAT(soft_stats.latecol)},
+	{"tx_deferred_ok", ATL1_STAT(soft_stats.deffer)},
+	{"tx_single_coll_ok", ATL1_STAT(soft_stats.scc)},
+	{"tx_multi_coll_ok", ATL1_STAT(soft_stats.mcc)},
+	{"tx_underun", ATL1_STAT(soft_stats.tx_underun)},
+	{"tx_trunc", ATL1_STAT(soft_stats.tx_trunc)},
+	{"tx_pause", ATL1_STAT(soft_stats.tx_pause)},
+	{"rx_pause", ATL1_STAT(soft_stats.rx_pause)},
+	{"rx_rrd_ov", ATL1_STAT(soft_stats.rx_rrd_ov)},
+	{"rx_trunc", ATL1_STAT(soft_stats.rx_trunc)}
+};
+
+static void atl1_get_ethtool_stats(struct net_device *netdev,
+	struct ethtool_stats *stats, u64 *data)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	int i;
+	char *p;
+
+	for (i =3D 0; i < ARRAY_SIZE(atl1_gstrings_stats); i++) {
+		p =3D (char *)adapter+atl1_gstrings_stats[i].stat_offset;
+		data[i] =3D (atl1_gstrings_stats[i].sizeof_stat =3D=3D
+			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
+	}
+
+}
+
+static int atl1_get_sset_count(struct net_device *netdev, int sset)
+{
+	switch (sset) {
+	case ETH_SS_STATS:
+		return ARRAY_SIZE(atl1_gstrings_stats);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+static int atl1_get_settings(struct net_device *netdev,
+	struct ethtool_cmd *ecmd)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_hw *hw =3D &adapter->hw;
+
+	ecmd->supported =3D (SUPPORTED_10baseT_Half |
+			   SUPPORTED_10baseT_Full |
+			   SUPPORTED_100baseT_Half |
+			   SUPPORTED_100baseT_Full |
+			   SUPPORTED_1000baseT_Full |
+			   SUPPORTED_Autoneg | SUPPORTED_TP);
+	ecmd->advertising =3D ADVERTISED_TP;
+	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
+		ecmd->advertising |=3D ADVERTISED_Autoneg;
+		if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR) {
+			ecmd->advertising |=3D ADVERTISED_Autoneg;
+			ecmd->advertising |=3D
+			    (ADVERTISED_10baseT_Half |
+			     ADVERTISED_10baseT_Full |
+			     ADVERTISED_100baseT_Half |
+			     ADVERTISED_100baseT_Full |
+			     ADVERTISED_1000baseT_Full);
+		} else
+			ecmd->advertising |=3D (ADVERTISED_1000baseT_Full);
+	}
+	ecmd->port =3D PORT_TP;
+	ecmd->phy_address =3D 0;
+	ecmd->transceiver =3D XCVR_INTERNAL;
+
+	if (netif_carrier_ok(adapter->netdev)) {
+		u16 link_speed, link_duplex;
+		atl1_get_speed_and_duplex(hw, &link_speed, &link_duplex);
+		ecmd->speed =3D link_speed;
+		if (link_duplex =3D=3D FULL_DUPLEX)
+			ecmd->duplex =3D DUPLEX_FULL;
+		else
+			ecmd->duplex =3D DUPLEX_HALF;
+	} else {
+		ecmd->speed =3D -1;
+		ecmd->duplex =3D -1;
+	}
+	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL)
+		ecmd->autoneg =3D AUTONEG_ENABLE;
+	else
+		ecmd->autoneg =3D AUTONEG_DISABLE;
+
+	return 0;
+}
+
+static int atl1_set_settings(struct net_device *netdev,
+	struct ethtool_cmd *ecmd)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_hw *hw =3D &adapter->hw;
+	u16 phy_data;
+	int ret_val =3D 0;
+	u16 old_media_type =3D hw->media_type;
+
+	if (netif_running(adapter->netdev)) {
+		dev_dbg(&adapter->pdev->dev, "ethtool shutting down adapter\n");
+		atl1_down(adapter);
+	}
+
+	if (ecmd->autoneg =3D=3D AUTONEG_ENABLE)
+		hw->media_type =3D MEDIA_TYPE_AUTO_SENSOR;
+	else {
+		if (ecmd->speed =3D=3D SPEED_1000) {
+			if (ecmd->duplex !=3D DUPLEX_FULL) {
+				dev_warn(&adapter->pdev->dev,
+					"can't force to 1000M half duplex\n");
+				ret_val =3D -EINVAL;
+				goto exit_sset;
+			}
+			hw->media_type =3D MEDIA_TYPE_1000M_FULL;
+		} else if (ecmd->speed =3D=3D SPEED_100) {
+			if (ecmd->duplex =3D=3D DUPLEX_FULL)
+				hw->media_type =3D MEDIA_TYPE_100M_FULL;
+			else
+				hw->media_type =3D MEDIA_TYPE_100M_HALF;
+		} else {
+			if (ecmd->duplex =3D=3D DUPLEX_FULL)
+				hw->media_type =3D MEDIA_TYPE_10M_FULL;
+			else
+				hw->media_type =3D MEDIA_TYPE_10M_HALF;
+		}
+	}
+	switch (hw->media_type) {
+	case MEDIA_TYPE_AUTO_SENSOR:
+		ecmd->advertising =3D
+		    ADVERTISED_10baseT_Half |
+		    ADVERTISED_10baseT_Full |
+		    ADVERTISED_100baseT_Half |
+		    ADVERTISED_100baseT_Full |
+		    ADVERTISED_1000baseT_Full |
+		    ADVERTISED_Autoneg | ADVERTISED_TP;
+		break;
+	case MEDIA_TYPE_1000M_FULL:
+		ecmd->advertising =3D
+		    ADVERTISED_1000baseT_Full |
+		    ADVERTISED_Autoneg | ADVERTISED_TP;
+		break;
+	default:
+		ecmd->advertising =3D 0;
+		break;
+	}
+	if (atl1_phy_setup_autoneg_adv(hw)) {
+		ret_val =3D -EINVAL;
+		dev_warn(&adapter->pdev->dev,
+			"invalid ethtool speed/duplex setting\n");
+		goto exit_sset;
+	}
+	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL)
+		phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN;
+	else {
+		switch (hw->media_type) {
+		case MEDIA_TYPE_100M_FULL:
+			phy_data =3D
+			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
+			    MII_CR_RESET;
+			break;
+		case MEDIA_TYPE_100M_HALF:
+			phy_data =3D MII_CR_SPEED_100 | MII_CR_RESET;
+			break;
+		case MEDIA_TYPE_10M_FULL:
+			phy_data =3D
+			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
+			break;
+		default:
+			/* MEDIA_TYPE_10M_HALF: */
+			phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
+			break;
+		}
+	}
+	atl1_write_phy_reg(hw, MII_BMCR, phy_data);
+exit_sset:
+	if (ret_val)
+		hw->media_type =3D old_media_type;
+
+	if (netif_running(adapter->netdev)) {
+		dev_dbg(&adapter->pdev->dev, "ethtool starting adapter\n");
+		atl1_up(adapter);
+	} else if (!ret_val) {
+		dev_dbg(&adapter->pdev->dev, "ethtool resetting adapter\n");
+		atl1_reset(adapter);
+	}
+	return ret_val;
+}
+
+static void atl1_get_drvinfo(struct net_device *netdev,
+	struct ethtool_drvinfo *drvinfo)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+
+	strncpy(drvinfo->driver, ATLX_DRIVER_NAME, sizeof(drvinfo->driver));
+	strncpy(drvinfo->version, ATLX_DRIVER_VERSION,
+		sizeof(drvinfo->version));
+	strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
+	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
+		sizeof(drvinfo->bus_info));
+	drvinfo->eedump_len =3D ATL1_EEDUMP_LEN;
+}
+
+static void atl1_get_wol(struct net_device *netdev,
+	struct ethtool_wolinfo *wol)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+
+	wol->supported =3D WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
+	wol->wolopts =3D 0;
+	if (adapter->wol & ATLX_WUFC_EX)
+		wol->wolopts |=3D WAKE_UCAST;
+	if (adapter->wol & ATLX_WUFC_MC)
+		wol->wolopts |=3D WAKE_MCAST;
+	if (adapter->wol & ATLX_WUFC_BC)
+		wol->wolopts |=3D WAKE_BCAST;
+	if (adapter->wol & ATLX_WUFC_MAG)
+		wol->wolopts |=3D WAKE_MAGIC;
+	return;
+}
+
+static int atl1_set_wol(struct net_device *netdev,
+	struct ethtool_wolinfo *wol)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+
+	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
+		return -EOPNOTSUPP;
+	adapter->wol =3D 0;
+	if (wol->wolopts & WAKE_UCAST)
+		adapter->wol |=3D ATLX_WUFC_EX;
+	if (wol->wolopts & WAKE_MCAST)
+		adapter->wol |=3D ATLX_WUFC_MC;
+	if (wol->wolopts & WAKE_BCAST)
+		adapter->wol |=3D ATLX_WUFC_BC;
+	if (wol->wolopts & WAKE_MAGIC)
+		adapter->wol |=3D ATLX_WUFC_MAG;
+	return 0;
+}
+
+static void atl1_get_ringparam(struct net_device *netdev,
+	struct ethtool_ringparam *ring)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_tpd_ring *txdr =3D &adapter->tpd_ring;
+	struct atl1_rfd_ring *rxdr =3D &adapter->rfd_ring;
+
+	ring->rx_max_pending =3D ATL1_MAX_RFD;
+	ring->tx_max_pending =3D ATL1_MAX_TPD;
+	ring->rx_mini_max_pending =3D 0;
+	ring->rx_jumbo_max_pending =3D 0;
+	ring->rx_pending =3D rxdr->count;
+	ring->tx_pending =3D txdr->count;
+	ring->rx_mini_pending =3D 0;
+	ring->rx_jumbo_pending =3D 0;
+}
+
+static int atl1_set_ringparam(struct net_device *netdev,
+	struct ethtool_ringparam *ring)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_tpd_ring *tpdr =3D &adapter->tpd_ring;
+	struct atl1_rrd_ring *rrdr =3D &adapter->rrd_ring;
+	struct atl1_rfd_ring *rfdr =3D &adapter->rfd_ring;
+
+	struct atl1_tpd_ring tpd_old, tpd_new;
+	struct atl1_rfd_ring rfd_old, rfd_new;
+	struct atl1_rrd_ring rrd_old, rrd_new;
+	struct atl1_ring_header rhdr_old, rhdr_new;
+	int err;
+
+	tpd_old =3D adapter->tpd_ring;
+	rfd_old =3D adapter->rfd_ring;
+	rrd_old =3D adapter->rrd_ring;
+	rhdr_old =3D adapter->ring_header;
+
+	if (netif_running(adapter->netdev))
+		atl1_down(adapter);
+
+	rfdr->count =3D (u16) max(ring->rx_pending, (u32) ATL1_MIN_RFD);
+	rfdr->count =3D rfdr->count > ATL1_MAX_RFD ? ATL1_MAX_RFD :
+			rfdr->count;
+	rfdr->count =3D (rfdr->count + 3) & ~3;
+	rrdr->count =3D rfdr->count;
+
+	tpdr->count =3D (u16) max(ring->tx_pending, (u32) ATL1_MIN_TPD);
+	tpdr->count =3D tpdr->count > ATL1_MAX_TPD ? ATL1_MAX_TPD :
+			tpdr->count;
+	tpdr->count =3D (tpdr->count + 3) & ~3;
+
+	if (netif_running(adapter->netdev)) {
+		/* try to get new resources before deleting old */
+		err =3D atl1_setup_ring_resources(adapter);
+		if (err)
+			goto err_setup_ring;
+
+		/*
+		 * save the new, restore the old in order to free it,
+		 * then restore the new back again
+		 */
+
+		rfd_new =3D adapter->rfd_ring;
+		rrd_new =3D adapter->rrd_ring;
+		tpd_new =3D adapter->tpd_ring;
+		rhdr_new =3D adapter->ring_header;
+		adapter->rfd_ring =3D rfd_old;
+		adapter->rrd_ring =3D rrd_old;
+		adapter->tpd_ring =3D tpd_old;
+		adapter->ring_header =3D rhdr_old;
+		atl1_free_ring_resources(adapter);
+		adapter->rfd_ring =3D rfd_new;
+		adapter->rrd_ring =3D rrd_new;
+		adapter->tpd_ring =3D tpd_new;
+		adapter->ring_header =3D rhdr_new;
+
+		err =3D atl1_up(adapter);
+		if (err)
+			return err;
+	}
+	return 0;
+
+err_setup_ring:
+	adapter->rfd_ring =3D rfd_old;
+	adapter->rrd_ring =3D rrd_old;
+	adapter->tpd_ring =3D tpd_old;
+	adapter->ring_header =3D rhdr_old;
+	atl1_up(adapter);
+	return err;
+}
+
+static void atl1_get_pauseparam(struct net_device *netdev,
+	struct ethtool_pauseparam *epause)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_hw *hw =3D &adapter->hw;
+
+	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
+		epause->autoneg =3D AUTONEG_ENABLE;
+	} else {
+		epause->autoneg =3D AUTONEG_DISABLE;
+	}
+	epause->rx_pause =3D 1;
+	epause->tx_pause =3D 1;
+}
+
+static int atl1_set_pauseparam(struct net_device *netdev,
+	struct ethtool_pauseparam *epause)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_hw *hw =3D &adapter->hw;
+
+	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
+		epause->autoneg =3D AUTONEG_ENABLE;
+	} else {
+		epause->autoneg =3D AUTONEG_DISABLE;
+	}
+
+	epause->rx_pause =3D 1;
+	epause->tx_pause =3D 1;
+
+	return 0;
+}
+
+/* FIXME: is this right? -- CHS */
+static u32 atl1_get_rx_csum(struct net_device *netdev)
+{
+	return 1;
+}
+
+static void atl1_get_strings(struct net_device *netdev, u32 stringset,
+	u8 *data)
+{
+	u8 *p =3D data;
+	int i;
+
+	switch (stringset) {
+	case ETH_SS_STATS:
+		for (i =3D 0; i < ARRAY_SIZE(atl1_gstrings_stats); i++) {
+			memcpy(p, atl1_gstrings_stats[i].stat_string,
+				ETH_GSTRING_LEN);
+			p +=3D ETH_GSTRING_LEN;
+		}
+		break;
+	}
+}
+
+static int atl1_nway_reset(struct net_device *netdev)
+{
+	struct atl1_adapter *adapter =3D netdev_priv(netdev);
+	struct atl1_hw *hw =3D &adapter->hw;
+
+	if (netif_running(netdev)) {
+		u16 phy_data;
+		atl1_down(adapter);
+
+		if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+			hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
+			phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN;
+		} else {
+			switch (hw->media_type) {
+			case MEDIA_TYPE_100M_FULL:
+				phy_data =3D MII_CR_FULL_DUPLEX |
+					MII_CR_SPEED_100 | MII_CR_RESET;
+				break;
+			case MEDIA_TYPE_100M_HALF:
+				phy_data =3D MII_CR_SPEED_100 | MII_CR_RESET;
+				break;
+			case MEDIA_TYPE_10M_FULL:
+				phy_data =3D MII_CR_FULL_DUPLEX |
+					MII_CR_SPEED_10 | MII_CR_RESET;
+				break;
+			default:
+				/* MEDIA_TYPE_10M_HALF */
+				phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
+			}
+		}
+		atl1_write_phy_reg(hw, MII_BMCR, phy_data);
+		atl1_up(adapter);
+	}
+	return 0;
+}
+
+const struct ethtool_ops atl1_ethtool_ops =3D {
+	.get_settings		=3D atl1_get_settings,
+	.set_settings		=3D atl1_set_settings,
+	.get_drvinfo		=3D atl1_get_drvinfo,
+	.get_wol		=3D atl1_get_wol,
+	.set_wol		=3D atl1_set_wol,
+	.get_ringparam		=3D atl1_get_ringparam,
+	.set_ringparam		=3D atl1_set_ringparam,
+	.get_pauseparam		=3D atl1_get_pauseparam,
+	.set_pauseparam 	=3D atl1_set_pauseparam,
+	.get_rx_csum		=3D atl1_get_rx_csum,
+	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
+	.get_link		=3D ethtool_op_get_link,
+	.set_sg			=3D ethtool_op_set_sg,
+	.get_strings		=3D atl1_get_strings,
+	.nway_reset		=3D atl1_nway_reset,
+	.get_ethtool_stats	=3D atl1_get_ethtool_stats,
+	.get_sset_count		=3D atl1_get_sset_count,
+	.set_tso		=3D ethtool_op_set_tso,
+};
+
+/*
+ * Reset the transmit and receive units; mask and clear all interrupts=
=2E
+ * hw - Struct containing variables accessed by shared code
+ * return : 0  or  idle status (if error)
+ */
+s32 atl1_reset_hw(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev =3D hw->back->pdev;
+	u32 icr;
+	int i;
+
+	/*
+	 * Clear Interrupt mask to stop board from generating
+	 * interrupts & Clear any pending interrupt events
+	 */
+	/*
+	 * iowrite32(0, hw->hw_addr + REG_IMR);
+	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
+	 */
+
+	/*
+	 * Issue Soft Reset to the MAC.  This will reset the chip's
+	 * transmit, receive, DMA.  It will not effect
+	 * the current PCI configuration.  The global reset bit is self-
+	 * clearing, and should clear within a microsecond.
+	 */
+	iowrite32(MASTER_CTRL_SOFT_RST, hw->hw_addr + REG_MASTER_CTRL);
+	ioread32(hw->hw_addr + REG_MASTER_CTRL);
+
+	iowrite16(1, hw->hw_addr + REG_PHY_ENABLE);
+	ioread16(hw->hw_addr + REG_PHY_ENABLE);
+
+	/* delay about 1ms */
+	msleep(1);
+
+	/* Wait at least 10ms for All module to be Idle */
+	for (i =3D 0; i < 10; i++) {
+		icr =3D ioread32(hw->hw_addr + REG_IDLE_STATUS);
+		if (!icr)
+			break;
+		/* delay 1 ms */
+		msleep(1);
+		/* FIXME: still the right way to do this? */
+		cpu_relax();
+	}
+
+	if (icr) {
+		dev_dbg(&pdev->dev, "ICR =3D 0x%x\n", icr);
+		return icr;
+	}
+
+	return 0;
+}
+
+/* function about EEPROM
+ *
+ * check_eeprom_exist
+ * return 0 if eeprom exist
+ */
+static int atl1_check_eeprom_exist(struct atl1_hw *hw)
+{
+	u32 value;
+	value =3D ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
+	if (value & SPI_FLASH_CTRL_EN_VPD) {
+		value &=3D ~SPI_FLASH_CTRL_EN_VPD;
+		iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
+	}
+
+	value =3D ioread16(hw->hw_addr + REG_PCIE_CAP_LIST);
+	return ((value & 0xFF00) =3D=3D 0x6C00) ? 0 : 1;
+}
+
+static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 *p_va=
lue)
+{
+	int i;
+	u32 control;
+
+	if (offset & 3)
+		/* address do not align */
+		return false;
+
+	iowrite32(0, hw->hw_addr + REG_VPD_DATA);
+	control =3D (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SHIF=
T;
+	iowrite32(control, hw->hw_addr + REG_VPD_CAP);
+	ioread32(hw->hw_addr + REG_VPD_CAP);
+
+	for (i =3D 0; i < 10; i++) {
+		msleep(2);
+		control =3D ioread32(hw->hw_addr + REG_VPD_CAP);
+		if (control & VPD_CAP_VPD_FLAG)
+			break;
+	}
+	if (control & VPD_CAP_VPD_FLAG) {
+		*p_value =3D ioread32(hw->hw_addr + REG_VPD_DATA);
+		return true;
+	}
+	/* timeout */
+	return false;
+}
+
+/*
+ * Reads the value from a PHY register
+ * hw - Struct containing variables accessed by shared code
+ * reg_addr - address of the PHY register to read
+ */
+s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
+{
+	u32 val;
+	int i;
+
+	val =3D ((u32) (reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIF=
T |
+		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
+		MDIO_CLK_SEL_SHIFT;
+	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
+	ioread32(hw->hw_addr + REG_MDIO_CTRL);
+
+	for (i =3D 0; i < MDIO_WAIT_TIMES; i++) {
+		udelay(2);
+		val =3D ioread32(hw->hw_addr + REG_MDIO_CTRL);
+		if (!(val & (MDIO_START | MDIO_BUSY)))
+			break;
+	}
+	if (!(val & (MDIO_START | MDIO_BUSY))) {
+		*phy_data =3D (u16) val;
+		return 0;
+	}
+	return ATLX_ERR_PHY;
+}
+
+#define CUSTOM_SPI_CS_SETUP	2
+#define CUSTOM_SPI_CLK_HI	2
+#define CUSTOM_SPI_CLK_LO	2
+#define CUSTOM_SPI_CS_HOLD	2
+#define CUSTOM_SPI_CS_HI	3
+
+static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
+{
+	int i;
+	u32 value;
+
+	iowrite32(0, hw->hw_addr + REG_SPI_DATA);
+	iowrite32(addr, hw->hw_addr + REG_SPI_ADDR);
+
+	value =3D SPI_FLASH_CTRL_WAIT_READY |
+	    (CUSTOM_SPI_CS_SETUP & SPI_FLASH_CTRL_CS_SETUP_MASK) <<
+	    SPI_FLASH_CTRL_CS_SETUP_SHIFT | (CUSTOM_SPI_CLK_HI &
+					     SPI_FLASH_CTRL_CLK_HI_MASK) <<
+	    SPI_FLASH_CTRL_CLK_HI_SHIFT | (CUSTOM_SPI_CLK_LO &
+					   SPI_FLASH_CTRL_CLK_LO_MASK) <<
+	    SPI_FLASH_CTRL_CLK_LO_SHIFT | (CUSTOM_SPI_CS_HOLD &
+					   SPI_FLASH_CTRL_CS_HOLD_MASK) <<
+	    SPI_FLASH_CTRL_CS_HOLD_SHIFT | (CUSTOM_SPI_CS_HI &
+					    SPI_FLASH_CTRL_CS_HI_MASK) <<
+	    SPI_FLASH_CTRL_CS_HI_SHIFT | (1 & SPI_FLASH_CTRL_INS_MASK) <<
+	    SPI_FLASH_CTRL_INS_SHIFT;
+
+	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
+
+	value |=3D SPI_FLASH_CTRL_START;
+	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
+	ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
+
+	for (i =3D 0; i < 10; i++) {
+		msleep(1);
+		value =3D ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
+		if (!(value & SPI_FLASH_CTRL_START))
+			break;
+	}
+
+	if (value & SPI_FLASH_CTRL_START)
+		return false;
+
+	*buf =3D ioread32(hw->hw_addr + REG_SPI_DATA);
+
+	return true;
+}
+
+/*
+ * get_permanent_address
+ * return 0 if get valid mac address,
+ */
+static int atl1_get_permanent_address(struct atl1_hw *hw)
+{
+	u32 addr[2];
+	u32 i, control;
+	u16 reg;
+	u8 eth_addr[ETH_ALEN];
+	bool key_valid;
+
+	if (is_valid_ether_addr(hw->perm_mac_addr))
+		return 0;
+
+	/* init */
+	addr[0] =3D addr[1] =3D 0;
+
+	if (!atl1_check_eeprom_exist(hw)) {
+		reg =3D 0;
+		key_valid =3D false;
+		/* Read out all EEPROM content */
+		i =3D 0;
+		while (1) {
+			if (atl1_read_eeprom(hw, i + 0x100, &control)) {
+				if (key_valid) {
+					if (reg =3D=3D REG_MAC_STA_ADDR)
+						addr[0] =3D control;
+					else if (reg =3D=3D (REG_MAC_STA_ADDR + 4))
+						addr[1] =3D control;
+					key_valid =3D false;
+				} else if ((control & 0xff) =3D=3D 0x5A) {
+					key_valid =3D true;
+					reg =3D (u16) (control >> 16);
+				} else
+					break;
+			} else
+				/* read error */
+				break;
+			i +=3D 4;
+		}
+
+		*(u32 *) &eth_addr[2] =3D swab32(addr[0]);
+		*(u16 *) &eth_addr[0] =3D swab16(*(u16 *) &addr[1]);
+		if (is_valid_ether_addr(eth_addr)) {
+			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+			return 0;
+		}
+		return 1;
+	}
+
+	/* see if SPI FLAGS exist ? */
+	addr[0] =3D addr[1] =3D 0;
+	reg =3D 0;
+	key_valid =3D false;
+	i =3D 0;
+	while (1) {
+		if (atl1_spi_read(hw, i + 0x1f000, &control)) {
+			if (key_valid) {
+				if (reg =3D=3D REG_MAC_STA_ADDR)
+					addr[0] =3D control;
+				else if (reg =3D=3D (REG_MAC_STA_ADDR + 4))
+					addr[1] =3D control;
+				key_valid =3D false;
+			} else if ((control & 0xff) =3D=3D 0x5A) {
+				key_valid =3D true;
+				reg =3D (u16) (control >> 16);
+			} else
+				/* data end */
+				break;
+		} else
+			/* read error */
+			break;
+		i +=3D 4;
+	}
+
+	*(u32 *) &eth_addr[2] =3D swab32(addr[0]);
+	*(u16 *) &eth_addr[0] =3D swab16(*(u16 *) &addr[1]);
+	if (is_valid_ether_addr(eth_addr)) {
+		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+		return 0;
+	}
+
+	/*
+	 * On some motherboards, the MAC address is written by the
+	 * BIOS directly to the MAC register during POST, and is
+	 * not stored in eeprom.  If all else thus far has failed
+	 * to fetch the permanent MAC address, try reading it directly.
+	 */
+	addr[0] =3D ioread32(hw->hw_addr + REG_MAC_STA_ADDR);
+	addr[1] =3D ioread16(hw->hw_addr + (REG_MAC_STA_ADDR + 4));
+	*(u32 *) &eth_addr[2] =3D swab32(addr[0]);
+	*(u16 *) &eth_addr[0] =3D swab16(*(u16 *) &addr[1]);
+	if (is_valid_ether_addr(eth_addr)) {
+		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Reads the adapter's MAC address from the EEPROM
+ * hw - Struct containing variables accessed by shared code
+ */
+s32 atl1_read_mac_addr(struct atl1_hw *hw)
+{
+	u16 i;
+
+	if (atl1_get_permanent_address(hw))
+		random_ether_addr(hw->perm_mac_addr);
+
+	for (i =3D 0; i < ETH_ALEN; i++)
+		hw->mac_addr[i] =3D hw->perm_mac_addr[i];
+	return 0;
+}
+
+/*
+ * Hashes an address to determine its location in the multicast table
+ * hw - Struct containing variables accessed by shared code
+ * mc_addr - the multicast address to hash
+ *
+ * atl1_hash_mc_addr
+ *  purpose
+ *      set hash value for a multicast address
+ *      hash calcu processing :
+ *          1. calcu 32bit CRC for multicast address
+ *          2. reverse crc with MSB to LSB
+ */
+u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
+{
+	u32 crc32, value =3D 0;
+	int i;
+
+	crc32 =3D ether_crc_le(6, mc_addr);
+	for (i =3D 0; i < 32; i++)
+		value |=3D (((crc32 >> i) & 1) << (31 - i));
+
+	return value;
+}
+
+/*
+ * Sets the bit in the multicast table corresponding to the hash value=
=2E
+ * hw - Struct containing variables accessed by shared code
+ * hash_value - Multicast address hash value
+ */
+void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
+{
+	u32 hash_bit, hash_reg;
+	u32 mta;
+
+	/*
+	 * The HASH Table  is a register array of 2 32-bit registers.
+	 * It is treated like an array of 64 bits.  We want to set
+	 * bit BitArray[hash_value]. So we figure out what register
+	 * the bit is in, read it, OR in the new bit, then write
+	 * back the new value.  The register is determined by the
+	 * upper 7 bits of the hash value and the bit within that
+	 * register are determined by the lower 5 bits of the value.
+	 */
+	hash_reg =3D (hash_value >> 31) & 0x1;
+	hash_bit =3D (hash_value >> 26) & 0x1F;
+	mta =3D ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2))=
;
+	mta |=3D (1 << hash_bit);
+	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
+}
+
+/*
+ * Writes a value to a PHY register
+ * hw - Struct containing variables accessed by shared code
+ * reg_addr - address of the PHY register to write
+ * data - data to write to the PHY
+ */
+s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
+{
+	int i;
+	u32 val;
+
+	val =3D ((u32) (phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |
+	    (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
+	    MDIO_SUP_PREAMBLE |
+	    MDIO_START | MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
+	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
+	ioread32(hw->hw_addr + REG_MDIO_CTRL);
+
+	for (i =3D 0; i < MDIO_WAIT_TIMES; i++) {
+		udelay(2);
+		val =3D ioread32(hw->hw_addr + REG_MDIO_CTRL);
+		if (!(val & (MDIO_START | MDIO_BUSY)))
+			break;
+	}
+
+	if (!(val & (MDIO_START | MDIO_BUSY)))
+		return 0;
+
+	return ATLX_ERR_PHY;
+}
+
+/*
+ * Make L001's PHY out of Power Saving State (bug)
+ * hw - Struct containing variables accessed by shared code
+ * when power on, L001's PHY always on Power saving State
+ * (Gigabit Link forbidden)
+ */
+static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
+{
+	s32 ret;
+	ret =3D atl1_write_phy_reg(hw, 29, 0x0029);
+	if (ret)
+		return ret;
+	return atl1_write_phy_reg(hw, 30, 0);
+}
+
+/*
+ *TODO: do something or get rid of this
+ */
+s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
+{
+/*    s32 ret_val;
+ *    u16 phy_data;
+ */
+
+/*
+    ret_val =3D atl1_write_phy_reg(hw, ...);
+    ret_val =3D atl1_write_phy_reg(hw, ...);
+    ....
+*/
+	return 0;
+}
+
+/*
+ * Resets the PHY and make all config validate
+ * hw - Struct containing variables accessed by shared code
+ *
+ * Sets bit 15 and 12 of the MII Control regiser (for F001 bug)
+ */
+static s32 atl1_phy_reset(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev =3D hw->back->pdev;
+	s32 ret_val;
+	u16 phy_data;
+
+	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
+	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL)
+		phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN;
+	else {
+		switch (hw->media_type) {
+		case MEDIA_TYPE_100M_FULL:
+			phy_data =3D
+			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
+			    MII_CR_RESET;
+			break;
+		case MEDIA_TYPE_100M_HALF:
+			phy_data =3D MII_CR_SPEED_100 | MII_CR_RESET;
+			break;
+		case MEDIA_TYPE_10M_FULL:
+			phy_data =3D
+			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
+			break;
+		default:
+			/* MEDIA_TYPE_10M_HALF: */
+			phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
+			break;
+		}
+	}
+
+	ret_val =3D atl1_write_phy_reg(hw, MII_BMCR, phy_data);
+	if (ret_val) {
+		u32 val;
+		int i;
+		/* pcie serdes link may be down! */
+		dev_dbg(&pdev->dev, "pcie phy link down\n");
+
+		for (i =3D 0; i < 25; i++) {
+			msleep(1);
+			val =3D ioread32(hw->hw_addr + REG_MDIO_CTRL);
+			if (!(val & (MDIO_START | MDIO_BUSY)))
+				break;
+		}
+
+		if ((val & (MDIO_START | MDIO_BUSY)) !=3D 0) {
+			dev_warn(&pdev->dev, "pcie link down at least 25ms\n");
+			return ret_val;
+		}
+	}
+	return 0;
+}
+
+/*
+ * Configures PHY autoneg and flow control advertisement settings
+ * hw - Struct containing variables accessed by shared code
+ */
+s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
+{
+	s32 ret_val;
+	s16 mii_autoneg_adv_reg;
+	s16 mii_1000t_ctrl_reg;
+
+	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
+	mii_autoneg_adv_reg =3D MII_AR_DEFAULT_CAP_MASK;
+
+	/* Read the MII 1000Base-T Control Register (Address 9). */
+	mii_1000t_ctrl_reg =3D MII_ATLX_CR_1000T_DEFAULT_CAP_MASK;
+
+	/*
+	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
+	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
+	 * the  1000Base-T Control Register (Address 9).
+	 */
+	mii_autoneg_adv_reg &=3D ~MII_AR_SPEED_MASK;
+	mii_1000t_ctrl_reg &=3D ~MII_ATLX_CR_1000T_SPEED_MASK;
+
+	/*
+	 * Need to parse media_type  and set up
+	 * the appropriate PHY registers.
+	 */
+	switch (hw->media_type) {
+	case MEDIA_TYPE_AUTO_SENSOR:
+		mii_autoneg_adv_reg |=3D (MII_AR_10T_HD_CAPS |
+					MII_AR_10T_FD_CAPS |
+					MII_AR_100TX_HD_CAPS |
+					MII_AR_100TX_FD_CAPS);
+		mii_1000t_ctrl_reg |=3D MII_ATLX_CR_1000T_FD_CAPS;
+		break;
+
+	case MEDIA_TYPE_1000M_FULL:
+		mii_1000t_ctrl_reg |=3D MII_ATLX_CR_1000T_FD_CAPS;
+		break;
+
+	case MEDIA_TYPE_100M_FULL:
+		mii_autoneg_adv_reg |=3D MII_AR_100TX_FD_CAPS;
+		break;
+
+	case MEDIA_TYPE_100M_HALF:
+		mii_autoneg_adv_reg |=3D MII_AR_100TX_HD_CAPS;
+		break;
+
+	case MEDIA_TYPE_10M_FULL:
+		mii_autoneg_adv_reg |=3D MII_AR_10T_FD_CAPS;
+		break;
+
+	default:
+		mii_autoneg_adv_reg |=3D MII_AR_10T_HD_CAPS;
+		break;
+	}
+
+	/* flow control fixed to enable all */
+	mii_autoneg_adv_reg |=3D (MII_AR_ASM_DIR | MII_AR_PAUSE);
+
+	hw->mii_autoneg_adv_reg =3D mii_autoneg_adv_reg;
+	hw->mii_1000t_ctrl_reg =3D mii_1000t_ctrl_reg;
+
+	ret_val =3D atl1_write_phy_reg(hw, MII_ADVERTISE, mii_autoneg_adv_reg=
);
+	if (ret_val)
+		return ret_val;
+
+	ret_val =3D atl1_write_phy_reg(hw, MII_ATLX_CR, mii_1000t_ctrl_reg);
+	if (ret_val)
+		return ret_val;
+
+	return 0;
+}
+
+/*
+ * Configures link settings.
+ * hw - Struct containing variables accessed by shared code
+ * Assumes the hardware has previously been reset and the
+ * transmitter and receiver are not enabled.
+ */
+static s32 atl1_setup_link(struct atl1_hw *hw)
+{
+	struct pci_dev *pdev =3D hw->back->pdev;
+	s32 ret_val;
+
+	/*
+	 * Options:
+	 *  PHY will advertise value(s) parsed from
+	 *  autoneg_advertised and fc
+	 *  no matter what autoneg is , We will not wait link result.
+	 */
+	ret_val =3D atl1_phy_setup_autoneg_adv(hw);
+	if (ret_val) {
+		dev_dbg(&pdev->dev, "error setting up autonegotiation\n");
+		return ret_val;
+	}
+	/* SW.Reset , En-Auto-Neg if needed */
+	ret_val =3D atl1_phy_reset(hw);
+	if (ret_val) {
+		dev_dbg(&pdev->dev, "error resetting phy\n");
+		return ret_val;
+	}
+	hw->phy_configured =3D true;
+	return ret_val;
+}
+
+static void atl1_init_flash_opcode(struct atl1_hw *hw)
+{
+	if (hw->flash_vendor >=3D ARRAY_SIZE(flash_table))
+		/* Atmel */
+		hw->flash_vendor =3D 0;
+
+	/* Init OP table */
+	iowrite8(flash_table[hw->flash_vendor].cmd_program,
+		hw->hw_addr + REG_SPI_FLASH_OP_PROGRAM);
+	iowrite8(flash_table[hw->flash_vendor].cmd_sector_erase,
+		hw->hw_addr + REG_SPI_FLASH_OP_SC_ERASE);
+	iowrite8(flash_table[hw->flash_vendor].cmd_chip_erase,
+		hw->hw_addr + REG_SPI_FLASH_OP_CHIP_ERASE);
+	iowrite8(flash_table[hw->flash_vendor].cmd_rdid,
+		hw->hw_addr + REG_SPI_FLASH_OP_RDID);
+	iowrite8(flash_table[hw->flash_vendor].cmd_wren,
+		hw->hw_addr + REG_SPI_FLASH_OP_WREN);
+	iowrite8(flash_table[hw->flash_vendor].cmd_rdsr,
+		hw->hw_addr + REG_SPI_FLASH_OP_RDSR);
+	iowrite8(flash_table[hw->flash_vendor].cmd_wrsr,
+		hw->hw_addr + REG_SPI_FLASH_OP_WRSR);
+	iowrite8(flash_table[hw->flash_vendor].cmd_read,
+		hw->hw_addr + REG_SPI_FLASH_OP_READ);
+}
+
+/*
+ * Performs basic configuration of the adapter.
+ * hw - Struct containing variables accessed by shared code
+ * Assumes that the controller has previously been reset and is in a
+ * post-reset uninitialized state. Initializes multicast table,
+ * and  Calls routines to setup link
+ * Leaves the transmit and receive units disabled and uninitialized.
+ */
+s32 atl1_init_hw(struct atl1_hw *hw)
+{
+	u32 ret_val =3D 0;
+
+	/* Zero out the Multicast HASH table */
+	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
+	/* clear the old settings from the multicast hash table */
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+
+	atl1_init_flash_opcode(hw);
+
+	if (!hw->phy_configured) {
+		/* enable GPHY LinkChange Interrrupt */
+		ret_val =3D atl1_write_phy_reg(hw, 18, 0xC00);
+		if (ret_val)
+			return ret_val;
+		/* make PHY out of power-saving state */
+		ret_val =3D atl1_phy_leave_power_saving(hw);
+		if (ret_val)
+			return ret_val;
+		/* Call a subroutine to configure the link */
+		ret_val =3D atl1_setup_link(hw);
+	}
+	return ret_val;
+}
+
+/*
+ * Detects the current speed and duplex settings of the hardware.
+ * hw - Struct containing variables accessed by shared code
+ * speed - Speed of the connection
+ * duplex - Duplex setting of the connection
+ */
+s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *dup=
lex)
+{
+	struct pci_dev *pdev =3D hw->back->pdev;
+	s32 ret_val;
+	u16 phy_data;
+
+	/* ; --- Read   PHY Specific Status Register (17) */
+	ret_val =3D atl1_read_phy_reg(hw, MII_ATLX_PSSR, &phy_data);
+	if (ret_val)
+		return ret_val;
+
+	if (!(phy_data & MII_ATLX_PSSR_SPD_DPLX_RESOLVED))
+		return ATLX_ERR_PHY_RES;
+
+	switch (phy_data & MII_ATLX_PSSR_SPEED) {
+	case MII_ATLX_PSSR_1000MBS:
+		*speed =3D SPEED_1000;
+		break;
+	case MII_ATLX_PSSR_100MBS:
+		*speed =3D SPEED_100;
+		break;
+	case MII_ATLX_PSSR_10MBS:
+		*speed =3D SPEED_10;
+		break;
+	default:
+		dev_dbg(&pdev->dev, "error getting speed\n");
+		return ATLX_ERR_PHY_SPEED;
+		break;
+	}
+	if (phy_data & MII_ATLX_PSSR_DPLX)
+		*duplex =3D FULL_DUPLEX;
+	else
+		*duplex =3D HALF_DUPLEX;
+
+	return 0;
+}
+
+void atl1_set_mac_addr(struct atl1_hw *hw)
+{
+	u32 value;
+	/*
+	 * 00-0B-6A-F6-00-DC
+	 * 0:  6AF600DC   1: 000B
+	 * low dword
+	 */
+	value =3D (((u32) hw->mac_addr[2]) << 24) |
+	    (((u32) hw->mac_addr[3]) << 16) |
+	    (((u32) hw->mac_addr[4]) << 8) | (((u32) hw->mac_addr[5]));
+	iowrite32(value, hw->hw_addr + REG_MAC_STA_ADDR);
+	/* high dword */
+	value =3D (((u32) hw->mac_addr[0]) << 8) | (((u32) hw->mac_addr[1]));
+	iowrite32(value, (hw->hw_addr + REG_MAC_STA_ADDR) + (1 << 2));
+}
diff --git a/drivers/net/atlx/atl1.h b/drivers/net/atlx/atl1.h
index ff4765f..538948d 100644
--- a/drivers/net/atlx/atl1.h
+++ b/drivers/net/atlx/atl1.h
@@ -1,6 +1,6 @@
 /*
  * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
- * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
+ * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
  * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
  *
  * Derived from Intel e1000 driver
@@ -21,26 +21,559 @@
  * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
  */
=20
-#ifndef _ATL1_H_
-#define _ATL1_H_
+#ifndef ATL1_H
+#define ATL1_H
=20
-#include <linux/types.h>
+#include <linux/compiler.h>
+#include <linux/ethtool.h>
 #include <linux/if_vlan.h>
+#include <linux/mii.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/spinlock.h>
+#include <linux/timer.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+
+#include "atlx.h"
+
+#define ATLX_DRIVER_NAME "atl1"
=20
-#include "atl1_hw.h"
+MODULE_DESCRIPTION("Atheros L1 Gigabit Ethernet Driver");
+
+#define atlx_adapter		atl1_adapter
+#define atlx_check_for_link	atl1_check_for_link
+#define atlx_check_link		atl1_check_link
+#define atlx_hash_mc_addr	atl1_hash_mc_addr
+#define atlx_hash_set		atl1_hash_set
+#define atlx_hw			atl1_hw
+#define atlx_mii_ioctl		atl1_mii_ioctl
+#define atlx_read_phy_reg	atl1_read_phy_reg
+#define atlx_set_mac		atl1_set_mac
+#define atlx_set_mac_addr	atl1_set_mac_addr
+
+struct atl1_adapter;
+struct atl1_hw;
=20
 /* function prototypes needed by multiple files */
+s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw);
+s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)=
;
+s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *dup=
lex);
+s32 atl1_read_mac_addr(struct atl1_hw *hw);
+s32 atl1_init_hw(struct atl1_hw *hw);
+s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *dup=
lex);
+s32 atl1_set_speed_and_duplex(struct atl1_hw *hw, u16 speed, u16 duple=
x);
+u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
+void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
+s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)=
;
+void atl1_set_mac_addr(struct atl1_hw *hw);
+s32 atl1_phy_enter_power_saving(struct atl1_hw *hw);
+s32 atl1_reset_hw(struct atl1_hw *hw);
+void atl1_check_options(struct atl1_adapter *adapter);
+static int atl1_mii_ioctl(struct net_device *netdev, struct ifreq *ifr=
,
+	int cmd);
+static u32 atl1_check_link(struct atl1_adapter *adapter);
 s32 atl1_up(struct atl1_adapter *adapter);
 void atl1_down(struct atl1_adapter *adapter);
 int atl1_reset(struct atl1_adapter *adapter);
-s32 atl1_setup_ring_resources(struct atl1_adapter *adapter);
-void atl1_free_ring_resources(struct atl1_adapter *adapter);
=20
-extern char atl1_driver_name[];
-extern char atl1_driver_version[];
 extern const struct ethtool_ops atl1_ethtool_ops;
=20
-struct atl1_adapter;
+/* hardware definitions specific to L1 */
+
+/* Block IDLE Status Register */
+#define IDLE_STATUS_RXMAC			0x1
+#define IDLE_STATUS_TXMAC			0x2
+#define IDLE_STATUS_RXQ				0x4
+#define IDLE_STATUS_TXQ				0x8
+#define IDLE_STATUS_DMAR			0x10
+#define IDLE_STATUS_DMAW			0x20
+#define IDLE_STATUS_SMB				0x40
+#define IDLE_STATUS_CMB				0x80
+
+/* MDIO Control Register */
+#define MDIO_WAIT_TIMES				30
+
+/* MAC Control Register */
+#define MAC_CTRL_TX_PAUSE			0x10000
+#define MAC_CTRL_SCNT				0x20000
+#define MAC_CTRL_SRST_TX			0x40000
+#define MAC_CTRL_TX_SIMURST			0x80000
+#define MAC_CTRL_SPEED_SHIFT			20
+#define MAC_CTRL_SPEED_MASK			0x300000
+#define MAC_CTRL_SPEED_1000			0x2
+#define MAC_CTRL_SPEED_10_100			0x1
+#define MAC_CTRL_DBG_TX_BKPRESURE		0x400000
+#define MAC_CTRL_TX_HUGE			0x800000
+#define MAC_CTRL_RX_CHKSUM_EN			0x1000000
+#define MAC_CTRL_DBG				0x8000000
+
+/* Wake-On-Lan control register */
+#define WOL_CLK_SWITCH_EN			0x8000
+#define WOL_PT5_EN				0x200000
+#define WOL_PT6_EN				0x400000
+#define WOL_PT5_MATCH				0x8000000
+#define WOL_PT6_MATCH				0x10000000
+
+/* WOL Length ( 2 DWORD ) */
+#define REG_WOL_PATTERN_LEN			0x14A4
+#define WOL_PT_LEN_MASK				0x7F
+#define WOL_PT0_LEN_SHIFT			0
+#define WOL_PT1_LEN_SHIFT			8
+#define WOL_PT2_LEN_SHIFT			16
+#define WOL_PT3_LEN_SHIFT			24
+#define WOL_PT4_LEN_SHIFT			0
+#define WOL_PT5_LEN_SHIFT			8
+#define WOL_PT6_LEN_SHIFT			16
+
+/* Internal SRAM Partition Registers, low 32 bits */
+#define REG_SRAM_RFD_LEN			0x1504
+#define REG_SRAM_RRD_ADDR			0x1508
+#define REG_SRAM_RRD_LEN			0x150C
+#define REG_SRAM_TPD_ADDR			0x1510
+#define REG_SRAM_TPD_LEN			0x1514
+#define REG_SRAM_TRD_ADDR			0x1518
+#define REG_SRAM_TRD_LEN			0x151C
+#define REG_SRAM_RXF_ADDR			0x1520
+#define REG_SRAM_RXF_LEN			0x1524
+#define REG_SRAM_TXF_ADDR			0x1528
+#define REG_SRAM_TXF_LEN			0x152C
+#define REG_SRAM_TCPH_PATH_ADDR			0x1530
+#define SRAM_TCPH_ADDR_MASK			0xFFF
+#define SRAM_TCPH_ADDR_SHIFT			0
+#define SRAM_PATH_ADDR_MASK			0xFFF
+#define SRAM_PATH_ADDR_SHIFT			16
+
+/* Load Ptr Register */
+#define REG_LOAD_PTR				0x1534
+
+/* Descriptor Control registers, low 32 bits */
+#define REG_DESC_RFD_ADDR_LO			0x1544
+#define REG_DESC_RRD_ADDR_LO			0x1548
+#define REG_DESC_TPD_ADDR_LO			0x154C
+#define REG_DESC_CMB_ADDR_LO			0x1550
+#define REG_DESC_SMB_ADDR_LO			0x1554
+#define REG_DESC_RFD_RRD_RING_SIZE		0x1558
+#define DESC_RFD_RING_SIZE_MASK			0x7FF
+#define DESC_RFD_RING_SIZE_SHIFT		0
+#define DESC_RRD_RING_SIZE_MASK			0x7FF
+#define DESC_RRD_RING_SIZE_SHIFT		16
+#define REG_DESC_TPD_RING_SIZE			0x155C
+#define DESC_TPD_RING_SIZE_MASK			0x3FF
+#define DESC_TPD_RING_SIZE_SHIFT		0
+
+/* TXQ Control Register */
+#define REG_TXQ_CTRL				0x1580
+#define TXQ_CTRL_TPD_BURST_NUM_SHIFT		0
+#define TXQ_CTRL_TPD_BURST_NUM_MASK		0x1F
+#define TXQ_CTRL_EN				0x20
+#define TXQ_CTRL_ENH_MODE			0x40
+#define TXQ_CTRL_TPD_FETCH_TH_SHIFT		8
+#define TXQ_CTRL_TPD_FETCH_TH_MASK		0x3F
+#define TXQ_CTRL_TXF_BURST_NUM_SHIFT		16
+#define TXQ_CTRL_TXF_BURST_NUM_MASK		0xFFFF
+
+/* Jumbo packet Threshold for task offload */
+#define REG_TX_JUMBO_TASK_TH_TPD_IPG		0x1584
+#define TX_JUMBO_TASK_TH_MASK			0x7FF
+#define TX_JUMBO_TASK_TH_SHIFT			0
+#define TX_TPD_MIN_IPG_MASK			0x1F
+#define TX_TPD_MIN_IPG_SHIFT			16
+
+/* RXQ Control Register */
+#define REG_RXQ_CTRL				0x15A0
+#define RXQ_CTRL_RFD_BURST_NUM_SHIFT		0
+#define RXQ_CTRL_RFD_BURST_NUM_MASK		0xFF
+#define RXQ_CTRL_RRD_BURST_THRESH_SHIFT		8
+#define RXQ_CTRL_RRD_BURST_THRESH_MASK		0xFF
+#define RXQ_CTRL_RFD_PREF_MIN_IPG_SHIFT		16
+#define RXQ_CTRL_RFD_PREF_MIN_IPG_MASK		0x1F
+#define RXQ_CTRL_CUT_THRU_EN			0x40000000
+#define RXQ_CTRL_EN				0x80000000
+
+/* Rx jumbo packet threshold and rrd  retirement timer */
+#define REG_RXQ_JMBOSZ_RRDTIM			0x15A4
+#define RXQ_JMBOSZ_TH_MASK			0x7FF
+#define RXQ_JMBOSZ_TH_SHIFT			0
+#define RXQ_JMBO_LKAH_MASK			0xF
+#define RXQ_JMBO_LKAH_SHIFT			11
+#define RXQ_RRD_TIMER_MASK			0xFFFF
+#define RXQ_RRD_TIMER_SHIFT			16
+
+/* RFD flow control register */
+#define REG_RXQ_RXF_PAUSE_THRESH		0x15A8
+#define RXQ_RXF_PAUSE_TH_HI_SHIFT		16
+#define RXQ_RXF_PAUSE_TH_HI_MASK		0xFFF
+#define RXQ_RXF_PAUSE_TH_LO_SHIFT		0
+#define RXQ_RXF_PAUSE_TH_LO_MASK		0xFFF
+
+/* RRD flow control register */
+#define REG_RXQ_RRD_PAUSE_THRESH		0x15AC
+#define RXQ_RRD_PAUSE_TH_HI_SHIFT		0
+#define RXQ_RRD_PAUSE_TH_HI_MASK		0xFFF
+#define RXQ_RRD_PAUSE_TH_LO_SHIFT		16
+#define RXQ_RRD_PAUSE_TH_LO_MASK		0xFFF
+
+/* DMA Engine Control Register */
+#define REG_DMA_CTRL				0x15C0
+#define DMA_CTRL_DMAR_IN_ORDER			0x1
+#define DMA_CTRL_DMAR_ENH_ORDER			0x2
+#define DMA_CTRL_DMAR_OUT_ORDER			0x4
+#define DMA_CTRL_RCB_VALUE			0x8
+#define DMA_CTRL_DMAR_BURST_LEN_SHIFT		4
+#define DMA_CTRL_DMAR_BURST_LEN_MASK		7
+#define DMA_CTRL_DMAW_BURST_LEN_SHIFT		7
+#define DMA_CTRL_DMAW_BURST_LEN_MASK		7
+#define DMA_CTRL_DMAR_EN			0x400
+#define DMA_CTRL_DMAW_EN			0x800
+
+/* CMB/SMB Control Register */
+#define REG_CSMB_CTRL				0x15D0
+#define CSMB_CTRL_CMB_NOW			1
+#define CSMB_CTRL_SMB_NOW			2
+#define CSMB_CTRL_CMB_EN			4
+#define CSMB_CTRL_SMB_EN			8
+
+/* CMB DMA Write Threshold Register */
+#define REG_CMB_WRITE_TH			0x15D4
+#define CMB_RRD_TH_SHIFT			0
+#define CMB_RRD_TH_MASK				0x7FF
+#define CMB_TPD_TH_SHIFT			16
+#define CMB_TPD_TH_MASK				0x7FF
+
+/* RX/TX count-down timer to trigger CMB-write. 2us resolution. */
+#define REG_CMB_WRITE_TIMER			0x15D8
+#define CMB_RX_TM_SHIFT				0
+#define CMB_RX_TM_MASK				0xFFFF
+#define CMB_TX_TM_SHIFT				16
+#define CMB_TX_TM_MASK				0xFFFF
+
+/* Number of packet received since last CMB write */
+#define REG_CMB_RX_PKT_CNT			0x15DC
+
+/* Number of packet transmitted since last CMB write */
+#define REG_CMB_TX_PKT_CNT			0x15E0
+
+/* SMB auto DMA timer register */
+#define REG_SMB_TIMER				0x15E4
+
+/* Mailbox Register */
+#define REG_MAILBOX				0x15F0
+#define MB_RFD_PROD_INDX_SHIFT			0
+#define MB_RFD_PROD_INDX_MASK			0x7FF
+#define MB_RRD_CONS_INDX_SHIFT			11
+#define MB_RRD_CONS_INDX_MASK			0x7FF
+#define MB_TPD_PROD_INDX_SHIFT			22
+#define MB_TPD_PROD_INDX_MASK			0x3FF
+
+/* Interrupt Status Register */
+#define ISR_SMB					0x1
+#define ISR_TIMER				0x2
+#define ISR_MANUAL				0x4
+#define ISR_RXF_OV				0x8
+#define ISR_RFD_UNRUN				0x10
+#define ISR_RRD_OV				0x20
+#define ISR_TXF_UNRUN				0x40
+#define ISR_LINK				0x80
+#define ISR_HOST_RFD_UNRUN			0x100
+#define ISR_HOST_RRD_OV				0x200
+#define ISR_DMAR_TO_RST				0x400
+#define ISR_DMAW_TO_RST				0x800
+#define ISR_GPHY				0x1000
+#define ISR_RX_PKT				0x10000
+#define ISR_TX_PKT				0x20000
+#define ISR_TX_DMA				0x40000
+#define ISR_RX_DMA				0x80000
+#define ISR_CMB_RX				0x100000
+#define ISR_CMB_TX				0x200000
+#define ISR_MAC_RX				0x400000
+#define ISR_MAC_TX				0x800000
+#define ISR_DIS_SMB				0x20000000
+#define ISR_DIS_DMA				0x40000000
+
+/* Normal Interrupt mask  */
+#define IMR_NORMAL_MASK	(\
+	ISR_SMB		|\
+	ISR_GPHY	|\
+	ISR_PHY_LINKDOWN|\
+	ISR_DMAR_TO_RST	|\
+	ISR_DMAW_TO_RST	|\
+	ISR_CMB_TX	|\
+	ISR_CMB_RX)
+
+/* Debug Interrupt Mask  (enable all interrupt) */
+#define IMR_DEBUG_MASK	(\
+	ISR_SMB		|\
+	ISR_TIMER	|\
+	ISR_MANUAL	|\
+	ISR_RXF_OV	|\
+	ISR_RFD_UNRUN	|\
+	ISR_RRD_OV	|\
+	ISR_TXF_UNRUN	|\
+	ISR_LINK	|\
+	ISR_CMB_TX	|\
+	ISR_CMB_RX	|\
+	ISR_RX_PKT	|\
+	ISR_TX_PKT	|\
+	ISR_MAC_RX	|\
+	ISR_MAC_TX)
+
+#define MEDIA_TYPE_1000M_FULL			1
+#define MEDIA_TYPE_100M_FULL			2
+#define MEDIA_TYPE_100M_HALF			3
+#define MEDIA_TYPE_10M_FULL			4
+#define MEDIA_TYPE_10M_HALF			5
+
+#define AUTONEG_ADVERTISE_SPEED_DEFAULT		0x002F	/* All but 1000-Half *=
/
+
+#define MAX_JUMBO_FRAME_SIZE			10240
+
+#define ATL1_EEDUMP_LEN				48
+
+/* Statistics counters collected by the MAC */
+struct stats_msg_block {
+	/* rx */
+	u32 rx_ok;		/* good RX packets */
+	u32 rx_bcast;		/* good RX broadcast packets */
+	u32 rx_mcast;		/* good RX multicast packets */
+	u32 rx_pause;		/* RX pause frames */
+	u32 rx_ctrl;		/* RX control packets other than pause frames */
+	u32 rx_fcs_err;		/* RX packets with bad FCS */
+	u32 rx_len_err;		/* RX packets with length !=3D actual size */
+	u32 rx_byte_cnt;	/* good bytes received. FCS is NOT included */
+	u32 rx_runt;		/* RX packets < 64 bytes with good FCS */
+	u32 rx_frag;		/* RX packets < 64 bytes with bad FCS */
+	u32 rx_sz_64;		/* 64 byte RX packets */
+	u32 rx_sz_65_127;
+	u32 rx_sz_128_255;
+	u32 rx_sz_256_511;
+	u32 rx_sz_512_1023;
+	u32 rx_sz_1024_1518;
+	u32 rx_sz_1519_max;	/* 1519 byte to MTU RX packets */
+	u32 rx_sz_ov;		/* truncated RX packets > MTU */
+	u32 rx_rxf_ov;		/* frames dropped due to RX FIFO overflow */
+	u32 rx_rrd_ov;		/* frames dropped due to RRD overflow */
+	u32 rx_align_err;	/* alignment errors */
+	u32 rx_bcast_byte_cnt;	/* RX broadcast bytes, excluding FCS */
+	u32 rx_mcast_byte_cnt;	/* RX multicast bytes, excluding FCS */
+	u32 rx_err_addr;	/* packets dropped due to address filtering */
+
+	/* tx */
+	u32 tx_ok;		/* good TX packets */
+	u32 tx_bcast;		/* good TX broadcast packets */
+	u32 tx_mcast;		/* good TX multicast packets */
+	u32 tx_pause;		/* TX pause frames */
+	u32 tx_exc_defer;	/* TX packets deferred excessively */
+	u32 tx_ctrl;		/* TX control frames, excluding pause frames */
+	u32 tx_defer;		/* TX packets deferred */
+	u32 tx_byte_cnt;	/* bytes transmitted, FCS is NOT included */
+	u32 tx_sz_64;		/* 64 byte TX packets */
+	u32 tx_sz_65_127;
+	u32 tx_sz_128_255;
+	u32 tx_sz_256_511;
+	u32 tx_sz_512_1023;
+	u32 tx_sz_1024_1518;
+	u32 tx_sz_1519_max;	/* 1519 byte to MTU TX packets */
+	u32 tx_1_col;		/* packets TX after a single collision */
+	u32 tx_2_col;		/* packets TX after multiple collisions */
+	u32 tx_late_col;	/* TX packets with late collisions */
+	u32 tx_abort_col;	/* TX packets aborted w/excessive collisions */
+	u32 tx_underrun;	/* TX packets aborted due to TX FIFO underrun
+				 * or TRD FIFO underrun */
+	u32 tx_rd_eop;		/* reads beyond the EOP into the next frame
+				 * when TRD was not written timely */
+	u32 tx_len_err;		/* TX packets where length !=3D actual size */
+	u32 tx_trunc;		/* TX packets truncated due to size > MTU */
+	u32 tx_bcast_byte;	/* broadcast bytes transmitted, excluding FCS */
+	u32 tx_mcast_byte;	/* multicast bytes transmitted, excluding FCS */
+	u32 smb_updated;	/* 1: SMB Updated. This is used by software to
+				 * indicate the statistics update. Software
+				 * should clear this bit after retrieving the
+				 * statistics information. */
+};
+
+/* Coalescing Message Block */
+struct coals_msg_block {
+	u32 int_stats;		/* interrupt status */
+	u16 rrd_prod_idx;	/* TRD Producer Index. */
+	u16 rfd_cons_idx;	/* RFD Consumer Index. */
+	u16 update;		/* Selene sets this bit every time it DMAs the
+				 * CMB to host memory. Software should clear
+				 * this bit when CMB info is processed. */
+	u16 tpd_cons_idx;	/* TPD Consumer Index. */
+};
+
+/* RRD descriptor */
+struct rx_return_desc {
+	u8 num_buf;	/* Number of RFD buffers used by the received packet */
+	u8 resved;
+	u16 buf_indx;	/* RFD Index of the first buffer */
+	union {
+		u32 valid;
+		struct {
+			u16 rx_chksum;
+			u16 pkt_size;
+		} xsum_sz;
+	} xsz;
+
+	u16 pkt_flg;	/* Packet flags */
+	u16 err_flg;	/* Error flags */
+	u16 resved2;
+	u16 vlan_tag;	/* VLAN TAG */
+};
+
+#define PACKET_FLAG_ETH_TYPE	0x0080
+#define PACKET_FLAG_VLAN_INS	0x0100
+#define PACKET_FLAG_ERR		0x0200
+#define PACKET_FLAG_IPV4	0x0400
+#define PACKET_FLAG_UDP		0x0800
+#define PACKET_FLAG_TCP		0x1000
+#define PACKET_FLAG_BCAST	0x2000
+#define PACKET_FLAG_MCAST	0x4000
+#define PACKET_FLAG_PAUSE	0x8000
+
+#define ERR_FLAG_CRC		0x0001
+#define ERR_FLAG_CODE		0x0002
+#define ERR_FLAG_DRIBBLE	0x0004
+#define ERR_FLAG_RUNT		0x0008
+#define ERR_FLAG_OV		0x0010
+#define ERR_FLAG_TRUNC		0x0020
+#define ERR_FLAG_IP_CHKSUM	0x0040
+#define ERR_FLAG_L4_CHKSUM	0x0080
+#define ERR_FLAG_LEN		0x0100
+#define ERR_FLAG_DES_ADDR	0x0200
+
+/* RFD descriptor */
+struct rx_free_desc {
+	__le64 buffer_addr;	/* Address of the descriptor's data buffer */
+	__le16 buf_len;		/* Size of the receive buffer in host memory */
+	u16 coalese;		/* Update consumer index to host after the
+				 * reception of this frame */
+	/* __attribute__ ((packed)) is required */
+} __attribute__ ((packed));
+
+/* tsopu defines */
+#define TSO_PARAM_BUFLEN_MASK		0x3FFF
+#define TSO_PARAM_BUFLEN_SHIFT		0
+#define TSO_PARAM_DMAINT_MASK		0x0001
+#define TSO_PARAM_DMAINT_SHIFT		14
+#define TSO_PARAM_PKTNT_MASK		0x0001
+#define TSO_PARAM_PKTINT_SHIFT		15
+#define TSO_PARAM_VLANTAG_MASK		0xFFFF
+#define TSO_PARAM_VLAN_SHIFT		16
+
+/* tsopl defines */
+#define TSO_PARAM_EOP_MASK		0x0001
+#define TSO_PARAM_EOP_SHIFT		0
+#define TSO_PARAM_COALESCE_MASK		0x0001
+#define TSO_PARAM_COALESCE_SHIFT	1
+#define TSO_PARAM_INSVLAG_MASK		0x0001
+#define TSO_PARAM_INSVLAG_SHIFT		2
+#define TSO_PARAM_CUSTOMCKSUM_MASK	0x0001
+#define TSO_PARAM_CUSTOMCKSUM_SHIFT	3
+#define TSO_PARAM_SEGMENT_MASK		0x0001
+#define TSO_PARAM_SEGMENT_SHIFT		4
+#define TSO_PARAM_IPCKSUM_MASK		0x0001
+#define TSO_PARAM_IPCKSUM_SHIFT		5
+#define TSO_PARAM_TCPCKSUM_MASK		0x0001
+#define TSO_PARAM_TCPCKSUM_SHIFT	6
+#define TSO_PARAM_UDPCKSUM_MASK		0x0001
+#define TSO_PARAM_UDPCKSUM_SHIFT	7
+#define TSO_PARAM_VLANTAGGED_MASK	0x0001
+#define TSO_PARAM_VLANTAGGED_SHIFT	8
+#define TSO_PARAM_ETHTYPE_MASK		0x0001
+#define TSO_PARAM_ETHTYPE_SHIFT		9
+#define TSO_PARAM_IPHL_MASK		0x000F
+#define TSO_PARAM_IPHL_SHIFT		10
+#define TSO_PARAM_TCPHDRLEN_MASK	0x000F
+#define TSO_PARAM_TCPHDRLEN_SHIFT	14
+#define TSO_PARAM_HDRFLAG_MASK		0x0001
+#define TSO_PARAM_HDRFLAG_SHIFT		18
+#define TSO_PARAM_MSS_MASK		0x1FFF
+#define TSO_PARAM_MSS_SHIFT		19
+
+/* csumpu defines */
+#define CSUM_PARAM_BUFLEN_MASK		0x3FFF
+#define CSUM_PARAM_BUFLEN_SHIFT		0
+#define CSUM_PARAM_DMAINT_MASK		0x0001
+#define CSUM_PARAM_DMAINT_SHIFT		14
+#define CSUM_PARAM_PKTINT_MASK		0x0001
+#define CSUM_PARAM_PKTINT_SHIFT		15
+#define CSUM_PARAM_VALANTAG_MASK	0xFFFF
+#define CSUM_PARAM_VALAN_SHIFT		16
+
+/* csumpl defines*/
+#define CSUM_PARAM_EOP_MASK		0x0001
+#define CSUM_PARAM_EOP_SHIFT		0
+#define CSUM_PARAM_COALESCE_MASK	0x0001
+#define CSUM_PARAM_COALESCE_SHIFT	1
+#define CSUM_PARAM_INSVLAG_MASK		0x0001
+#define CSUM_PARAM_INSVLAG_SHIFT	2
+#define CSUM_PARAM_CUSTOMCKSUM_MASK	0x0001
+#define CSUM_PARAM_CUSTOMCKSUM_SHIFT	3
+#define CSUM_PARAM_SEGMENT_MASK		0x0001
+#define CSUM_PARAM_SEGMENT_SHIFT	4
+#define CSUM_PARAM_IPCKSUM_MASK		0x0001
+#define CSUM_PARAM_IPCKSUM_SHIFT	5
+#define CSUM_PARAM_TCPCKSUM_MASK	0x0001
+#define CSUM_PARAM_TCPCKSUM_SHIFT	6
+#define CSUM_PARAM_UDPCKSUM_MASK	0x0001
+#define CSUM_PARAM_UDPCKSUM_SHIFT	7
+#define CSUM_PARAM_VLANTAGGED_MASK	0x0001
+#define CSUM_PARAM_VLANTAGGED_SHIFT	8
+#define CSUM_PARAM_ETHTYPE_MASK		0x0001
+#define CSUM_PARAM_ETHTYPE_SHIFT	9
+#define CSUM_PARAM_IPHL_MASK		0x000F
+#define CSUM_PARAM_IPHL_SHIFT		10
+#define CSUM_PARAM_PLOADOFFSET_MASK	0x00FF
+#define CSUM_PARAM_PLOADOFFSET_SHIFT	16
+#define CSUM_PARAM_XSUMOFFSET_MASK	0x00FF
+#define CSUM_PARAM_XSUMOFFSET_SHIFT	24
+
+/* TPD descriptor */
+struct tso_param {
+	/* The order of these declarations is important -- don't change it */
+	u32 tsopu;	/* tso_param upper word */
+	u32 tsopl;	/* tso_param lower word */
+};
+
+struct csum_param {
+	/* The order of these declarations is important -- don't change it */
+	u32 csumpu;	/* csum_param upper word */
+	u32 csumpl;	/* csum_param lower word */
+};
+
+union tpd_descr {
+	u64 data;
+	struct csum_param csum;
+	struct tso_param tso;
+};
+
+struct tx_packet_desc {
+	__le64 buffer_addr;
+	union tpd_descr desc;
+};
+
+/* DMA Order Settings */
+enum atl1_dma_order {
+	atl1_dma_ord_in =3D 1,
+	atl1_dma_ord_enh =3D 2,
+	atl1_dma_ord_out =3D 4
+};
+
+enum atl1_dma_rcb {
+	atl1_rcb_64 =3D 0,
+	atl1_rcb_128 =3D 1
+};
+
+enum atl1_dma_req_block {
+	atl1_dma_req_128 =3D 0,
+	atl1_dma_req_256 =3D 1,
+	atl1_dma_req_512 =3D 2,
+	atl1_dma_req_1024 =3D 3,
+	atl1_dma_req_2048 =3D 4,
+	atl1_dma_req_4096 =3D 5
+};
=20
 #define ATL1_MAX_INTR		3
 #define ATL1_MAX_TX_BUF_LEN	0x3000	/* 12288 bytes */
@@ -58,19 +591,6 @@ struct atl1_adapter;
 #define ATL1_RRD_DESC(R, i)	ATL1_GET_DESC(R, i, struct rx_return_desc)
=20
 /*
- * This detached comment is preserved for documentation purposes only.
- * It was originally attached to some code that got deleted, but seems
- * important enough to keep around...
- *
- * <begin detached comment>
- * Some workarounds require millisecond delays and are run during inte=
rrupt
- * context.  Most notably, when establishing link, the phy may need tw=
eaking
- * but cannot process phy register reads/writes faster than millisecon=
d
- * intervals...and we establish link due to a "link status change" int=
errupt.
- * <end detached comment>
- */
-
-/*
  * atl1_ring_header represents a single, contiguous block of DMA space
  * mapped for the three descriptor rings (tpd, rfd, rrd) and the two
  * message blocks (cmb, smb) described below
@@ -156,20 +676,15 @@ struct atl1_sft_stats {
 	u64 tx_aborted_errors;
 	u64 tx_window_errors;
 	u64 tx_carrier_errors;
-	u64 tx_pause;		/* num pause packets transmitted. */
-	u64 excecol;		/* num tx packets w/ excessive collisions. */
-	u64 deffer;		/* num tx packets deferred */
-	u64 scc;		/* num packets subsequently transmitted
-				 * successfully w/ single prior collision. */
-	u64 mcc;		/* num packets subsequently transmitted
-				 * successfully w/ multiple prior collisions. */
-	u64 latecol;		/* num tx packets  w/ late collisions. */
-	u64 tx_underun;		/* num tx packets aborted due to transmit
-				 * FIFO underrun, or TRD FIFO underrun */
-	u64 tx_trunc;		/* num tx packets truncated due to size
-				 * exceeding MTU, regardless whether truncated
-				 * by the chip or not. (The name doesn't really
-				 * reflect the meaning in this case.) */
+	u64 tx_pause;		/* TX pause frames */
+	u64 excecol;		/* TX packets w/ excessive collisions */
+	u64 deffer;		/* TX packets deferred */
+	u64 scc;		/* packets TX after a single collision */
+	u64 mcc;		/* packets TX after multiple collisions */
+	u64 latecol;		/* TX packets w/ late collisions */
+	u64 tx_underun;		/* TX packets aborted due to TX FIFO underrun
+				 * or TRD FIFO underrun */
+	u64 tx_trunc;		/* TX packets truncated due to size > MTU */
 	u64 rx_pause;		/* num Pause packets received. */
 	u64 rx_rrd_ov;
 	u64 rx_trunc;
@@ -184,8 +699,7 @@ struct atl1_hw {
 	enum atl1_dma_req_block dmar_block;
 	enum atl1_dma_req_block dmaw_block;
 	u8 preamble_len;
-	u8 max_retry;		/* Retransmission maximum, after which the
-				 * packet will be discarded */
+	u8 max_retry;
 	u8 jam_ipg;		/* IPG to start JAM for collision based flow
 				 * control in half-duplex mode. In units of
 				 * 8-bit time */
@@ -271,16 +785,15 @@ struct atl1_adapter {
 	u64 hw_csum_err;
 	u64 hw_csum_good;
=20
-	u16 imt;	/* interrupt moderator timer (2us resolution */
-	u16 ict;	/* interrupt clear timer (2us resolution */
-	struct mii_if_info mii;		/* MII interface info */
+	u16 imt;		/* interrupt moderator timer (2us resolution) */
+	u16 ict;		/* interrupt clear timer (2us resolution */
+	struct mii_if_info mii;	/* MII interface info */
=20
-	/* structs defined in atl1_hw.h */
-	u32 bd_number;			/* board number */
+	u32 bd_number;		/* board number */
 	bool pci_using_64;
 	struct atl1_hw hw;
 	struct atl1_smb smb;
 	struct atl1_cmb cmb;
 };
=20
-#endif	/* _ATL1_H_ */
+#endif /* ATL1_H */
diff --git a/drivers/net/atlx/atl1_ethtool.c b/drivers/net/atlx/atl1_et=
htool.c
deleted file mode 100644
index 68a83be..0000000
--- a/drivers/net/atlx/atl1_ethtool.c
+++ /dev/null
@@ -1,505 +0,0 @@
-/*
- * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
- * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- *
- * Derived from Intel e1000 driver
- * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modif=
y it
- * under the terms of the GNU General Public License as published by t=
he Free
- * Software Foundation; either version 2 of the License, or (at your o=
ption)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful, but=
 WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
- * more details.
- *
- * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- */
-
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/ethtool.h>
-#include <linux/netdevice.h>
-#include <linux/mii.h>
-#include <asm/uaccess.h>
-
-#include "atl1.h"
-
-struct atl1_stats {
-	char stat_string[ETH_GSTRING_LEN];
-	int sizeof_stat;
-	int stat_offset;
-};
-
-#define ATL1_STAT(m) sizeof(((struct atl1_adapter *)0)->m), \
-	offsetof(struct atl1_adapter, m)
-
-static struct atl1_stats atl1_gstrings_stats[] =3D {
-	{"rx_packets", ATL1_STAT(soft_stats.rx_packets)},
-	{"tx_packets", ATL1_STAT(soft_stats.tx_packets)},
-	{"rx_bytes", ATL1_STAT(soft_stats.rx_bytes)},
-	{"tx_bytes", ATL1_STAT(soft_stats.tx_bytes)},
-	{"rx_errors", ATL1_STAT(soft_stats.rx_errors)},
-	{"tx_errors", ATL1_STAT(soft_stats.tx_errors)},
-	{"rx_dropped", ATL1_STAT(net_stats.rx_dropped)},
-	{"tx_dropped", ATL1_STAT(net_stats.tx_dropped)},
-	{"multicast", ATL1_STAT(soft_stats.multicast)},
-	{"collisions", ATL1_STAT(soft_stats.collisions)},
-	{"rx_length_errors", ATL1_STAT(soft_stats.rx_length_errors)},
-	{"rx_over_errors", ATL1_STAT(soft_stats.rx_missed_errors)},
-	{"rx_crc_errors", ATL1_STAT(soft_stats.rx_crc_errors)},
-	{"rx_frame_errors", ATL1_STAT(soft_stats.rx_frame_errors)},
-	{"rx_fifo_errors", ATL1_STAT(soft_stats.rx_fifo_errors)},
-	{"rx_missed_errors", ATL1_STAT(soft_stats.rx_missed_errors)},
-	{"tx_aborted_errors", ATL1_STAT(soft_stats.tx_aborted_errors)},
-	{"tx_carrier_errors", ATL1_STAT(soft_stats.tx_carrier_errors)},
-	{"tx_fifo_errors", ATL1_STAT(soft_stats.tx_fifo_errors)},
-	{"tx_window_errors", ATL1_STAT(soft_stats.tx_window_errors)},
-	{"tx_abort_exce_coll", ATL1_STAT(soft_stats.excecol)},
-	{"tx_abort_late_coll", ATL1_STAT(soft_stats.latecol)},
-	{"tx_deferred_ok", ATL1_STAT(soft_stats.deffer)},
-	{"tx_single_coll_ok", ATL1_STAT(soft_stats.scc)},
-	{"tx_multi_coll_ok", ATL1_STAT(soft_stats.mcc)},
-	{"tx_underun", ATL1_STAT(soft_stats.tx_underun)},
-	{"tx_trunc", ATL1_STAT(soft_stats.tx_trunc)},
-	{"tx_pause", ATL1_STAT(soft_stats.tx_pause)},
-	{"rx_pause", ATL1_STAT(soft_stats.rx_pause)},
-	{"rx_rrd_ov", ATL1_STAT(soft_stats.rx_rrd_ov)},
-	{"rx_trunc", ATL1_STAT(soft_stats.rx_trunc)}
-};
-
-static void atl1_get_ethtool_stats(struct net_device *netdev,
-				struct ethtool_stats *stats, u64 *data)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	int i;
-	char *p;
-
-	for (i =3D 0; i < ARRAY_SIZE(atl1_gstrings_stats); i++) {
-		p =3D (char *)adapter+atl1_gstrings_stats[i].stat_offset;
-		data[i] =3D (atl1_gstrings_stats[i].sizeof_stat =3D=3D
-			sizeof(u64)) ? *(u64 *)p : *(u32 *)p;
-	}
-
-}
-
-static int atl1_get_sset_count(struct net_device *netdev, int sset)
-{
-	switch (sset) {
-	case ETH_SS_STATS:
-		return ARRAY_SIZE(atl1_gstrings_stats);
-	default:
-		return -EOPNOTSUPP;
-	}
-}
-
-static int atl1_get_settings(struct net_device *netdev,
-				struct ethtool_cmd *ecmd)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_hw *hw =3D &adapter->hw;
-
-	ecmd->supported =3D (SUPPORTED_10baseT_Half |
-			   SUPPORTED_10baseT_Full |
-			   SUPPORTED_100baseT_Half |
-			   SUPPORTED_100baseT_Full |
-			   SUPPORTED_1000baseT_Full |
-			   SUPPORTED_Autoneg | SUPPORTED_TP);
-	ecmd->advertising =3D ADVERTISED_TP;
-	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
-		ecmd->advertising |=3D ADVERTISED_Autoneg;
-		if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR) {
-			ecmd->advertising |=3D ADVERTISED_Autoneg;
-			ecmd->advertising |=3D
-			    (ADVERTISED_10baseT_Half |
-			     ADVERTISED_10baseT_Full |
-			     ADVERTISED_100baseT_Half |
-			     ADVERTISED_100baseT_Full |
-			     ADVERTISED_1000baseT_Full);
-		}
-		else
-			ecmd->advertising |=3D (ADVERTISED_1000baseT_Full);
-	}
-	ecmd->port =3D PORT_TP;
-	ecmd->phy_address =3D 0;
-	ecmd->transceiver =3D XCVR_INTERNAL;
-
-	if (netif_carrier_ok(adapter->netdev)) {
-		u16 link_speed, link_duplex;
-		atl1_get_speed_and_duplex(hw, &link_speed, &link_duplex);
-		ecmd->speed =3D link_speed;
-		if (link_duplex =3D=3D FULL_DUPLEX)
-			ecmd->duplex =3D DUPLEX_FULL;
-		else
-			ecmd->duplex =3D DUPLEX_HALF;
-	} else {
-		ecmd->speed =3D -1;
-		ecmd->duplex =3D -1;
-	}
-	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL)
-		ecmd->autoneg =3D AUTONEG_ENABLE;
-	else
-		ecmd->autoneg =3D AUTONEG_DISABLE;
-
-	return 0;
-}
-
-static int atl1_set_settings(struct net_device *netdev,
-				struct ethtool_cmd *ecmd)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_hw *hw =3D &adapter->hw;
-	u16 phy_data;
-	int ret_val =3D 0;
-	u16 old_media_type =3D hw->media_type;
-
-	if (netif_running(adapter->netdev)) {
-		dev_dbg(&adapter->pdev->dev, "ethtool shutting down adapter\n");
-		atl1_down(adapter);
-	}
-
-	if (ecmd->autoneg =3D=3D AUTONEG_ENABLE)
-		hw->media_type =3D MEDIA_TYPE_AUTO_SENSOR;
-	else {
-		if (ecmd->speed =3D=3D SPEED_1000) {
-			if (ecmd->duplex !=3D DUPLEX_FULL) {
-				dev_warn(&adapter->pdev->dev,
-					"can't force to 1000M half duplex\n");
-				ret_val =3D -EINVAL;
-				goto exit_sset;
-			}
-			hw->media_type =3D MEDIA_TYPE_1000M_FULL;
-		} else if (ecmd->speed =3D=3D SPEED_100) {
-			if (ecmd->duplex =3D=3D DUPLEX_FULL) {
-				hw->media_type =3D MEDIA_TYPE_100M_FULL;
-			} else
-				hw->media_type =3D MEDIA_TYPE_100M_HALF;
-		} else {
-			if (ecmd->duplex =3D=3D DUPLEX_FULL)
-				hw->media_type =3D MEDIA_TYPE_10M_FULL;
-			else
-				hw->media_type =3D MEDIA_TYPE_10M_HALF;
-		}
-	}
-	switch (hw->media_type) {
-	case MEDIA_TYPE_AUTO_SENSOR:
-		ecmd->advertising =3D
-		    ADVERTISED_10baseT_Half |
-		    ADVERTISED_10baseT_Full |
-		    ADVERTISED_100baseT_Half |
-		    ADVERTISED_100baseT_Full |
-		    ADVERTISED_1000baseT_Full |
-		    ADVERTISED_Autoneg | ADVERTISED_TP;
-		break;
-	case MEDIA_TYPE_1000M_FULL:
-		ecmd->advertising =3D
-		    ADVERTISED_1000baseT_Full |
-		    ADVERTISED_Autoneg | ADVERTISED_TP;
-		break;
-	default:
-		ecmd->advertising =3D 0;
-		break;
-	}
-	if (atl1_phy_setup_autoneg_adv(hw)) {
-		ret_val =3D -EINVAL;
-		dev_warn(&adapter->pdev->dev,
-			"invalid ethtool speed/duplex setting\n");
-		goto exit_sset;
-	}
-	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL)
-		phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-	else {
-		switch (hw->media_type) {
-		case MEDIA_TYPE_100M_FULL:
-			phy_data =3D
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
-			    MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_100M_HALF:
-			phy_data =3D MII_CR_SPEED_100 | MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_10M_FULL:
-			phy_data =3D
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		default:	/* MEDIA_TYPE_10M_HALF: */
-			phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		}
-	}
-	atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-exit_sset:
-	if (ret_val)
-		hw->media_type =3D old_media_type;
-
-	if (netif_running(adapter->netdev)) {
-		dev_dbg(&adapter->pdev->dev, "ethtool starting adapter\n");
-		atl1_up(adapter);
-	} else if (!ret_val) {
-		dev_dbg(&adapter->pdev->dev, "ethtool resetting adapter\n");
-		atl1_reset(adapter);
-	}
-	return ret_val;
-}
-
-static void atl1_get_drvinfo(struct net_device *netdev,
-				struct ethtool_drvinfo *drvinfo)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-
-	strncpy(drvinfo->driver, atl1_driver_name, sizeof(drvinfo->driver));
-	strncpy(drvinfo->version, atl1_driver_version,
-		sizeof(drvinfo->version));
-	strncpy(drvinfo->fw_version, "N/A", sizeof(drvinfo->fw_version));
-	strncpy(drvinfo->bus_info, pci_name(adapter->pdev),
-		sizeof(drvinfo->bus_info));
-	drvinfo->eedump_len =3D ATL1_EEDUMP_LEN;
-}
-
-static void atl1_get_wol(struct net_device *netdev,
-			    struct ethtool_wolinfo *wol)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-
-	wol->supported =3D WAKE_UCAST | WAKE_MCAST | WAKE_BCAST | WAKE_MAGIC;
-	wol->wolopts =3D 0;
-	if (adapter->wol & ATL1_WUFC_EX)
-		wol->wolopts |=3D WAKE_UCAST;
-	if (adapter->wol & ATL1_WUFC_MC)
-		wol->wolopts |=3D WAKE_MCAST;
-	if (adapter->wol & ATL1_WUFC_BC)
-		wol->wolopts |=3D WAKE_BCAST;
-	if (adapter->wol & ATL1_WUFC_MAG)
-		wol->wolopts |=3D WAKE_MAGIC;
-	return;
-}
-
-static int atl1_set_wol(struct net_device *netdev,
-			struct ethtool_wolinfo *wol)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-
-	if (wol->wolopts & (WAKE_PHY | WAKE_ARP | WAKE_MAGICSECURE))
-		return -EOPNOTSUPP;
-	adapter->wol =3D 0;
-	if (wol->wolopts & WAKE_UCAST)
-		adapter->wol |=3D ATL1_WUFC_EX;
-	if (wol->wolopts & WAKE_MCAST)
-		adapter->wol |=3D ATL1_WUFC_MC;
-	if (wol->wolopts & WAKE_BCAST)
-		adapter->wol |=3D ATL1_WUFC_BC;
-	if (wol->wolopts & WAKE_MAGIC)
-		adapter->wol |=3D ATL1_WUFC_MAG;
-	return 0;
-}
-
-static void atl1_get_ringparam(struct net_device *netdev,
-			    struct ethtool_ringparam *ring)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_tpd_ring *txdr =3D &adapter->tpd_ring;
-	struct atl1_rfd_ring *rxdr =3D &adapter->rfd_ring;
-
-	ring->rx_max_pending =3D ATL1_MAX_RFD;
-	ring->tx_max_pending =3D ATL1_MAX_TPD;
-	ring->rx_mini_max_pending =3D 0;
-	ring->rx_jumbo_max_pending =3D 0;
-	ring->rx_pending =3D rxdr->count;
-	ring->tx_pending =3D txdr->count;
-	ring->rx_mini_pending =3D 0;
-	ring->rx_jumbo_pending =3D 0;
-}
-
-static int atl1_set_ringparam(struct net_device *netdev,
-				struct ethtool_ringparam *ring)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_tpd_ring *tpdr =3D &adapter->tpd_ring;
-	struct atl1_rrd_ring *rrdr =3D &adapter->rrd_ring;
-	struct atl1_rfd_ring *rfdr =3D &adapter->rfd_ring;
-
-	struct atl1_tpd_ring tpd_old, tpd_new;
-	struct atl1_rfd_ring rfd_old, rfd_new;
-	struct atl1_rrd_ring rrd_old, rrd_new;
-	struct atl1_ring_header rhdr_old, rhdr_new;
-	int err;
-
-	tpd_old =3D adapter->tpd_ring;
-	rfd_old =3D adapter->rfd_ring;
-	rrd_old =3D adapter->rrd_ring;
-	rhdr_old =3D adapter->ring_header;
-
-	if (netif_running(adapter->netdev))
-		atl1_down(adapter);
-
-	rfdr->count =3D (u16) max(ring->rx_pending, (u32) ATL1_MIN_RFD);
-	rfdr->count =3D rfdr->count > ATL1_MAX_RFD ? ATL1_MAX_RFD :
-			rfdr->count;
-	rfdr->count =3D (rfdr->count + 3) & ~3;
-	rrdr->count =3D rfdr->count;
-
-	tpdr->count =3D (u16) max(ring->tx_pending, (u32) ATL1_MIN_TPD);
-	tpdr->count =3D tpdr->count > ATL1_MAX_TPD ? ATL1_MAX_TPD :
-			tpdr->count;
-	tpdr->count =3D (tpdr->count + 3) & ~3;
-
-	if (netif_running(adapter->netdev)) {
-		/* try to get new resources before deleting old */
-		err =3D atl1_setup_ring_resources(adapter);
-		if (err)
-			goto err_setup_ring;
-
-		/*
-		 * save the new, restore the old in order to free it,
-		 * then restore the new back again
-		 */
-
-		rfd_new =3D adapter->rfd_ring;
-		rrd_new =3D adapter->rrd_ring;
-		tpd_new =3D adapter->tpd_ring;
-		rhdr_new =3D adapter->ring_header;
-		adapter->rfd_ring =3D rfd_old;
-		adapter->rrd_ring =3D rrd_old;
-		adapter->tpd_ring =3D tpd_old;
-		adapter->ring_header =3D rhdr_old;
-		atl1_free_ring_resources(adapter);
-		adapter->rfd_ring =3D rfd_new;
-		adapter->rrd_ring =3D rrd_new;
-		adapter->tpd_ring =3D tpd_new;
-		adapter->ring_header =3D rhdr_new;
-
-		err =3D atl1_up(adapter);
-		if (err)
-			return err;
-	}
-	return 0;
-
-err_setup_ring:
-	adapter->rfd_ring =3D rfd_old;
-	adapter->rrd_ring =3D rrd_old;
-	adapter->tpd_ring =3D tpd_old;
-	adapter->ring_header =3D rhdr_old;
-	atl1_up(adapter);
-	return err;
-}
-
-static void atl1_get_pauseparam(struct net_device *netdev,
-			     struct ethtool_pauseparam *epause)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_hw *hw =3D &adapter->hw;
-
-	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
-		epause->autoneg =3D AUTONEG_ENABLE;
-	} else {
-		epause->autoneg =3D AUTONEG_DISABLE;
-	}
-	epause->rx_pause =3D 1;
-	epause->tx_pause =3D 1;
-}
-
-static int atl1_set_pauseparam(struct net_device *netdev,
-			     struct ethtool_pauseparam *epause)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_hw *hw =3D &adapter->hw;
-
-	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
-		epause->autoneg =3D AUTONEG_ENABLE;
-	} else {
-		epause->autoneg =3D AUTONEG_DISABLE;
-	}
-
-	epause->rx_pause =3D 1;
-	epause->tx_pause =3D 1;
-
-	return 0;
-}
-
-static u32 atl1_get_rx_csum(struct net_device *netdev)
-{
-	return 1;
-}
-
-static void atl1_get_strings(struct net_device *netdev, u32 stringset,
-				u8 *data)
-{
-	u8 *p =3D data;
-	int i;
-
-	switch (stringset) {
-	case ETH_SS_STATS:
-		for (i =3D 0; i < ARRAY_SIZE(atl1_gstrings_stats); i++) {
-			memcpy(p, atl1_gstrings_stats[i].stat_string,
-				ETH_GSTRING_LEN);
-			p +=3D ETH_GSTRING_LEN;
-		}
-		break;
-	}
-}
-
-static int atl1_nway_reset(struct net_device *netdev)
-{
-	struct atl1_adapter *adapter =3D netdev_priv(netdev);
-	struct atl1_hw *hw =3D &adapter->hw;
-
-	if (netif_running(netdev)) {
-		u16 phy_data;
-		atl1_down(adapter);
-
-		if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-			hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL) {
-			phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-		} else {
-			switch (hw->media_type) {
-			case MEDIA_TYPE_100M_FULL:
-				phy_data =3D MII_CR_FULL_DUPLEX |
-					MII_CR_SPEED_100 | MII_CR_RESET;
-				break;
-			case MEDIA_TYPE_100M_HALF:
-				phy_data =3D MII_CR_SPEED_100 | MII_CR_RESET;
-				break;
-			case MEDIA_TYPE_10M_FULL:
-				phy_data =3D MII_CR_FULL_DUPLEX |
-					MII_CR_SPEED_10 | MII_CR_RESET;
-				break;
-			default:  /* MEDIA_TYPE_10M_HALF */
-				phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
-			}
-		}
-		atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-		atl1_up(adapter);
-	}
-	return 0;
-}
-
-const struct ethtool_ops atl1_ethtool_ops =3D {
-	.get_settings		=3D atl1_get_settings,
-	.set_settings		=3D atl1_set_settings,
-	.get_drvinfo		=3D atl1_get_drvinfo,
-	.get_wol		=3D atl1_get_wol,
-	.set_wol		=3D atl1_set_wol,
-	.get_ringparam		=3D atl1_get_ringparam,
-	.set_ringparam		=3D atl1_set_ringparam,
-	.get_pauseparam		=3D atl1_get_pauseparam,
-	.set_pauseparam 	=3D atl1_set_pauseparam,
-	.get_rx_csum		=3D atl1_get_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_hw_csum,
-	.get_link		=3D ethtool_op_get_link,
-	.set_sg			=3D ethtool_op_set_sg,
-	.get_strings		=3D atl1_get_strings,
-	.nway_reset		=3D atl1_nway_reset,
-	.get_ethtool_stats	=3D atl1_get_ethtool_stats,
-	.get_sset_count		=3D atl1_get_sset_count,
-	.set_tso		=3D ethtool_op_set_tso,
-};
diff --git a/drivers/net/atlx/atl1_hw.c b/drivers/net/atlx/atl1_hw.c
deleted file mode 100644
index 9d3bd22..0000000
--- a/drivers/net/atlx/atl1_hw.c
+++ /dev/null
@@ -1,720 +0,0 @@
-/*
- * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
- * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- *
- * Derived from Intel e1000 driver
- * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modif=
y it
- * under the terms of the GNU General Public License as published by t=
he Free
- * Software Foundation; either version 2 of the License, or (at your o=
ption)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful, but=
 WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
- * more details.
- *
- * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- */
-
-#include <linux/types.h>
-#include <linux/pci.h>
-#include <linux/delay.h>
-#include <linux/if_vlan.h>
-#include <linux/etherdevice.h>
-#include <linux/crc32.h>
-#include <asm/byteorder.h>
-
-#include "atl1.h"
-
-/*
- * Reset the transmit and receive units; mask and clear all interrupts=
=2E
- * hw - Struct containing variables accessed by shared code
- * return : ATL1_SUCCESS  or  idle status (if error)
- */
-s32 atl1_reset_hw(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev =3D hw->back->pdev;
-	u32 icr;
-	int i;
-
-	/*
-	 * Clear Interrupt mask to stop board from generating
-	 * interrupts & Clear any pending interrupt events
-	 */
-	/*
-	 * iowrite32(0, hw->hw_addr + REG_IMR);
-	 * iowrite32(0xffffffff, hw->hw_addr + REG_ISR);
-	 */
-
-	/*
-	 * Issue Soft Reset to the MAC.  This will reset the chip's
-	 * transmit, receive, DMA.  It will not effect
-	 * the current PCI configuration.  The global reset bit is self-
-	 * clearing, and should clear within a microsecond.
-	 */
-	iowrite32(MASTER_CTRL_SOFT_RST, hw->hw_addr + REG_MASTER_CTRL);
-	ioread32(hw->hw_addr + REG_MASTER_CTRL);
-
-	iowrite16(1, hw->hw_addr + REG_GPHY_ENABLE);
-	ioread16(hw->hw_addr + REG_GPHY_ENABLE);
-
-	msleep(1);		/* delay about 1ms */
-
-	/* Wait at least 10ms for All module to be Idle */
-	for (i =3D 0; i < 10; i++) {
-		icr =3D ioread32(hw->hw_addr + REG_IDLE_STATUS);
-		if (!icr)
-			break;
-		msleep(1);	/* delay 1 ms */
-		cpu_relax();	/* FIXME: is this still the right way to do this? */
-	}
-
-	if (icr) {
-		dev_dbg(&pdev->dev, "ICR =3D 0x%x\n", icr);
-		return icr;
-	}
-
-	return ATL1_SUCCESS;
-}
-
-/* function about EEPROM
- *
- * check_eeprom_exist
- * return 0 if eeprom exist
- */
-static int atl1_check_eeprom_exist(struct atl1_hw *hw)
-{
-	u32 value;
-	value =3D ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
-	if (value & SPI_FLASH_CTRL_EN_VPD) {
-		value &=3D ~SPI_FLASH_CTRL_EN_VPD;
-		iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
-	}
-
-	value =3D ioread16(hw->hw_addr + REG_PCIE_CAP_LIST);
-	return ((value & 0xFF00) =3D=3D 0x6C00) ? 0 : 1;
-}
-
-static bool atl1_read_eeprom(struct atl1_hw *hw, u32 offset, u32 *p_va=
lue)
-{
-	int i;
-	u32 control;
-
-	if (offset & 3)
-		return false;	/* address do not align */
-
-	iowrite32(0, hw->hw_addr + REG_VPD_DATA);
-	control =3D (offset & VPD_CAP_VPD_ADDR_MASK) << VPD_CAP_VPD_ADDR_SHIF=
T;
-	iowrite32(control, hw->hw_addr + REG_VPD_CAP);
-	ioread32(hw->hw_addr + REG_VPD_CAP);
-
-	for (i =3D 0; i < 10; i++) {
-		msleep(2);
-		control =3D ioread32(hw->hw_addr + REG_VPD_CAP);
-		if (control & VPD_CAP_VPD_FLAG)
-			break;
-	}
-	if (control & VPD_CAP_VPD_FLAG) {
-		*p_value =3D ioread32(hw->hw_addr + REG_VPD_DATA);
-		return true;
-	}
-	return false;		/* timeout */
-}
-
-/*
- * Reads the value from a PHY register
- * hw - Struct containing variables accessed by shared code
- * reg_addr - address of the PHY register to read
- */
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)
-{
-	u32 val;
-	int i;
-
-	val =3D ((u32) (reg_addr & MDIO_REG_ADDR_MASK)) << MDIO_REG_ADDR_SHIF=
T |
-		MDIO_START | MDIO_SUP_PREAMBLE | MDIO_RW | MDIO_CLK_25_4 <<
-		MDIO_CLK_SEL_SHIFT;
-	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
-	ioread32(hw->hw_addr + REG_MDIO_CTRL);
-
-	for (i =3D 0; i < MDIO_WAIT_TIMES; i++) {
-		udelay(2);
-		val =3D ioread32(hw->hw_addr + REG_MDIO_CTRL);
-		if (!(val & (MDIO_START | MDIO_BUSY)))
-			break;
-	}
-	if (!(val & (MDIO_START | MDIO_BUSY))) {
-		*phy_data =3D (u16) val;
-		return ATL1_SUCCESS;
-	}
-	return ATL1_ERR_PHY;
-}
-
-#define CUSTOM_SPI_CS_SETUP	2
-#define CUSTOM_SPI_CLK_HI	2
-#define CUSTOM_SPI_CLK_LO	2
-#define CUSTOM_SPI_CS_HOLD	2
-#define CUSTOM_SPI_CS_HI	3
-
-static bool atl1_spi_read(struct atl1_hw *hw, u32 addr, u32 *buf)
-{
-	int i;
-	u32 value;
-
-	iowrite32(0, hw->hw_addr + REG_SPI_DATA);
-	iowrite32(addr, hw->hw_addr + REG_SPI_ADDR);
-
-	value =3D SPI_FLASH_CTRL_WAIT_READY |
-	    (CUSTOM_SPI_CS_SETUP & SPI_FLASH_CTRL_CS_SETUP_MASK) <<
-	    SPI_FLASH_CTRL_CS_SETUP_SHIFT | (CUSTOM_SPI_CLK_HI &
-					     SPI_FLASH_CTRL_CLK_HI_MASK) <<
-	    SPI_FLASH_CTRL_CLK_HI_SHIFT | (CUSTOM_SPI_CLK_LO &
-					   SPI_FLASH_CTRL_CLK_LO_MASK) <<
-	    SPI_FLASH_CTRL_CLK_LO_SHIFT | (CUSTOM_SPI_CS_HOLD &
-					   SPI_FLASH_CTRL_CS_HOLD_MASK) <<
-	    SPI_FLASH_CTRL_CS_HOLD_SHIFT | (CUSTOM_SPI_CS_HI &
-					    SPI_FLASH_CTRL_CS_HI_MASK) <<
-	    SPI_FLASH_CTRL_CS_HI_SHIFT | (1 & SPI_FLASH_CTRL_INS_MASK) <<
-	    SPI_FLASH_CTRL_INS_SHIFT;
-
-	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
-
-	value |=3D SPI_FLASH_CTRL_START;
-	iowrite32(value, hw->hw_addr + REG_SPI_FLASH_CTRL);
-	ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
-
-	for (i =3D 0; i < 10; i++) {
-		msleep(1);	/* 1ms */
-		value =3D ioread32(hw->hw_addr + REG_SPI_FLASH_CTRL);
-		if (!(value & SPI_FLASH_CTRL_START))
-			break;
-	}
-
-	if (value & SPI_FLASH_CTRL_START)
-		return false;
-
-	*buf =3D ioread32(hw->hw_addr + REG_SPI_DATA);
-
-	return true;
-}
-
-/*
- * get_permanent_address
- * return 0 if get valid mac address,
- */
-static int atl1_get_permanent_address(struct atl1_hw *hw)
-{
-	u32 addr[2];
-	u32 i, control;
-	u16 reg;
-	u8 eth_addr[ETH_ALEN];
-	bool key_valid;
-
-	if (is_valid_ether_addr(hw->perm_mac_addr))
-		return 0;
-
-	/* init */
-	addr[0] =3D addr[1] =3D 0;
-
-	if (!atl1_check_eeprom_exist(hw)) {	/* eeprom exist */
-		reg =3D 0;
-		key_valid =3D false;
-		/* Read out all EEPROM content */
-		i =3D 0;
-		while (1) {
-			if (atl1_read_eeprom(hw, i + 0x100, &control)) {
-				if (key_valid) {
-					if (reg =3D=3D REG_MAC_STA_ADDR)
-						addr[0] =3D control;
-					else if (reg =3D=3D (REG_MAC_STA_ADDR + 4))
-						addr[1] =3D control;
-					key_valid =3D false;
-				} else if ((control & 0xff) =3D=3D 0x5A) {
-					key_valid =3D true;
-					reg =3D (u16) (control >> 16);
-				} else
-					break;	/* assume data end while encount an invalid KEYWORD */
-			} else
-				break;	/* read error */
-			i +=3D 4;
-		}
-
-		*(u32 *) &eth_addr[2] =3D swab32(addr[0]);
-		*(u16 *) &eth_addr[0] =3D swab16(*(u16 *) &addr[1]);
-		if (is_valid_ether_addr(eth_addr)) {
-			memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
-			return 0;
-		}
-		return 1;
-	}
-
-	/* see if SPI FLAGS exist ? */
-	addr[0] =3D addr[1] =3D 0;
-	reg =3D 0;
-	key_valid =3D false;
-	i =3D 0;
-	while (1) {
-		if (atl1_spi_read(hw, i + 0x1f000, &control)) {
-			if (key_valid) {
-				if (reg =3D=3D REG_MAC_STA_ADDR)
-					addr[0] =3D control;
-				else if (reg =3D=3D (REG_MAC_STA_ADDR + 4))
-					addr[1] =3D control;
-				key_valid =3D false;
-			} else if ((control & 0xff) =3D=3D 0x5A) {
-				key_valid =3D true;
-				reg =3D (u16) (control >> 16);
-			} else
-				break;	/* data end */
-		} else
-			break;	/* read error */
-		i +=3D 4;
-	}
-
-	*(u32 *) &eth_addr[2] =3D swab32(addr[0]);
-	*(u16 *) &eth_addr[0] =3D swab16(*(u16 *) &addr[1]);
-	if (is_valid_ether_addr(eth_addr)) {
-		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
-		return 0;
-	}
-
-	/*
-	 * On some motherboards, the MAC address is written by the
-	 * BIOS directly to the MAC register during POST, and is
-	 * not stored in eeprom.  If all else thus far has failed
-	 * to fetch the permanent MAC address, try reading it directly.
-	 */
-	addr[0] =3D ioread32(hw->hw_addr + REG_MAC_STA_ADDR);
-	addr[1] =3D ioread16(hw->hw_addr + (REG_MAC_STA_ADDR + 4));
-	*(u32 *) &eth_addr[2] =3D swab32(addr[0]);
-	*(u16 *) &eth_addr[0] =3D swab16(*(u16 *) &addr[1]);
-	if (is_valid_ether_addr(eth_addr)) {
-		memcpy(hw->perm_mac_addr, eth_addr, ETH_ALEN);
-		return 0;
-	}
-
-	return 1;
-}
-
-/*
- * Reads the adapter's MAC address from the EEPROM
- * hw - Struct containing variables accessed by shared code
- */
-s32 atl1_read_mac_addr(struct atl1_hw *hw)
-{
-	u16 i;
-
-	if (atl1_get_permanent_address(hw))
-		random_ether_addr(hw->perm_mac_addr);
-
-	for (i =3D 0; i < ETH_ALEN; i++)
-		hw->mac_addr[i] =3D hw->perm_mac_addr[i];
-	return ATL1_SUCCESS;
-}
-
-/*
- * Hashes an address to determine its location in the multicast table
- * hw - Struct containing variables accessed by shared code
- * mc_addr - the multicast address to hash
- *
- * atl1_hash_mc_addr
- *  purpose
- *      set hash value for a multicast address
- *      hash calcu processing :
- *          1. calcu 32bit CRC for multicast address
- *          2. reverse crc with MSB to LSB
- */
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr)
-{
-	u32 crc32, value =3D 0;
-	int i;
-
-	crc32 =3D ether_crc_le(6, mc_addr);
-	for (i =3D 0; i < 32; i++)
-		value |=3D (((crc32 >> i) & 1) << (31 - i));
-
-	return value;
-}
-
-/*
- * Sets the bit in the multicast table corresponding to the hash value=
=2E
- * hw - Struct containing variables accessed by shared code
- * hash_value - Multicast address hash value
- */
-void atl1_hash_set(struct atl1_hw *hw, u32 hash_value)
-{
-	u32 hash_bit, hash_reg;
-	u32 mta;
-
-	/*
-	 * The HASH Table  is a register array of 2 32-bit registers.
-	 * It is treated like an array of 64 bits.  We want to set
-	 * bit BitArray[hash_value]. So we figure out what register
-	 * the bit is in, read it, OR in the new bit, then write
-	 * back the new value.  The register is determined by the
-	 * upper 7 bits of the hash value and the bit within that
-	 * register are determined by the lower 5 bits of the value.
-	 */
-	hash_reg =3D (hash_value >> 31) & 0x1;
-	hash_bit =3D (hash_value >> 26) & 0x1F;
-	mta =3D ioread32((hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2))=
;
-	mta |=3D (1 << hash_bit);
-	iowrite32(mta, (hw->hw_addr + REG_RX_HASH_TABLE) + (hash_reg << 2));
-}
-
-/*
- * Writes a value to a PHY register
- * hw - Struct containing variables accessed by shared code
- * reg_addr - address of the PHY register to write
- * data - data to write to the PHY
- */
-s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)
-{
-	int i;
-	u32 val;
-
-	val =3D ((u32) (phy_data & MDIO_DATA_MASK)) << MDIO_DATA_SHIFT |
-	    (reg_addr & MDIO_REG_ADDR_MASK) << MDIO_REG_ADDR_SHIFT |
-	    MDIO_SUP_PREAMBLE |
-	    MDIO_START | MDIO_CLK_25_4 << MDIO_CLK_SEL_SHIFT;
-	iowrite32(val, hw->hw_addr + REG_MDIO_CTRL);
-	ioread32(hw->hw_addr + REG_MDIO_CTRL);
-
-	for (i =3D 0; i < MDIO_WAIT_TIMES; i++) {
-		udelay(2);
-		val =3D ioread32(hw->hw_addr + REG_MDIO_CTRL);
-		if (!(val & (MDIO_START | MDIO_BUSY)))
-			break;
-	}
-
-	if (!(val & (MDIO_START | MDIO_BUSY)))
-		return ATL1_SUCCESS;
-
-	return ATL1_ERR_PHY;
-}
-
-/*
- * Make L001's PHY out of Power Saving State (bug)
- * hw - Struct containing variables accessed by shared code
- * when power on, L001's PHY always on Power saving State
- * (Gigabit Link forbidden)
- */
-static s32 atl1_phy_leave_power_saving(struct atl1_hw *hw)
-{
-	s32 ret;
-	ret =3D atl1_write_phy_reg(hw, 29, 0x0029);
-	if (ret)
-		return ret;
-	return atl1_write_phy_reg(hw, 30, 0);
-}
-
-/*
- *TODO: do something or get rid of this
- */
-s32 atl1_phy_enter_power_saving(struct atl1_hw *hw)
-{
-/*    s32 ret_val;
- *    u16 phy_data;
- */
-
-/*
-    ret_val =3D atl1_write_phy_reg(hw, ...);
-    ret_val =3D atl1_write_phy_reg(hw, ...);
-    ....
-*/
-	return ATL1_SUCCESS;
-}
-
-/*
- * Resets the PHY and make all config validate
- * hw - Struct containing variables accessed by shared code
- *
- * Sets bit 15 and 12 of the MII Control regiser (for F001 bug)
- */
-static s32 atl1_phy_reset(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev =3D hw->back->pdev;
-	s32 ret_val;
-	u16 phy_data;
-
-	if (hw->media_type =3D=3D MEDIA_TYPE_AUTO_SENSOR ||
-	    hw->media_type =3D=3D MEDIA_TYPE_1000M_FULL)
-		phy_data =3D MII_CR_RESET | MII_CR_AUTO_NEG_EN;
-	else {
-		switch (hw->media_type) {
-		case MEDIA_TYPE_100M_FULL:
-			phy_data =3D
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_100 |
-			    MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_100M_HALF:
-			phy_data =3D MII_CR_SPEED_100 | MII_CR_RESET;
-			break;
-		case MEDIA_TYPE_10M_FULL:
-			phy_data =3D
-			    MII_CR_FULL_DUPLEX | MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		default:	/* MEDIA_TYPE_10M_HALF: */
-			phy_data =3D MII_CR_SPEED_10 | MII_CR_RESET;
-			break;
-		}
-	}
-
-	ret_val =3D atl1_write_phy_reg(hw, MII_BMCR, phy_data);
-	if (ret_val) {
-		u32 val;
-		int i;
-		/* pcie serdes link may be down! */
-		dev_dbg(&pdev->dev, "pcie phy link down\n");
-
-		for (i =3D 0; i < 25; i++) {
-			msleep(1);
-			val =3D ioread32(hw->hw_addr + REG_MDIO_CTRL);
-			if (!(val & (MDIO_START | MDIO_BUSY)))
-				break;
-		}
-
-		if ((val & (MDIO_START | MDIO_BUSY)) !=3D 0) {
-			dev_warn(&pdev->dev, "pcie link down at least 25ms\n");
-			return ret_val;
-		}
-	}
-	return ATL1_SUCCESS;
-}
-
-/*
- * Configures PHY autoneg and flow control advertisement settings
- * hw - Struct containing variables accessed by shared code
- */
-s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw)
-{
-	s32 ret_val;
-	s16 mii_autoneg_adv_reg;
-	s16 mii_1000t_ctrl_reg;
-
-	/* Read the MII Auto-Neg Advertisement Register (Address 4). */
-	mii_autoneg_adv_reg =3D MII_AR_DEFAULT_CAP_MASK;
-
-	/* Read the MII 1000Base-T Control Register (Address 9). */
-	mii_1000t_ctrl_reg =3D MII_AT001_CR_1000T_DEFAULT_CAP_MASK;
-
-	/*
-	 * First we clear all the 10/100 mb speed bits in the Auto-Neg
-	 * Advertisement Register (Address 4) and the 1000 mb speed bits in
-	 * the  1000Base-T Control Register (Address 9).
-	 */
-	mii_autoneg_adv_reg &=3D ~MII_AR_SPEED_MASK;
-	mii_1000t_ctrl_reg &=3D ~MII_AT001_CR_1000T_SPEED_MASK;
-
-	/*
-	 * Need to parse media_type  and set up
-	 * the appropriate PHY registers.
-	 */
-	switch (hw->media_type) {
-	case MEDIA_TYPE_AUTO_SENSOR:
-		mii_autoneg_adv_reg |=3D (MII_AR_10T_HD_CAPS |
-					MII_AR_10T_FD_CAPS |
-					MII_AR_100TX_HD_CAPS |
-					MII_AR_100TX_FD_CAPS);
-		mii_1000t_ctrl_reg |=3D MII_AT001_CR_1000T_FD_CAPS;
-		break;
-
-	case MEDIA_TYPE_1000M_FULL:
-		mii_1000t_ctrl_reg |=3D MII_AT001_CR_1000T_FD_CAPS;
-		break;
-
-	case MEDIA_TYPE_100M_FULL:
-		mii_autoneg_adv_reg |=3D MII_AR_100TX_FD_CAPS;
-		break;
-
-	case MEDIA_TYPE_100M_HALF:
-		mii_autoneg_adv_reg |=3D MII_AR_100TX_HD_CAPS;
-		break;
-
-	case MEDIA_TYPE_10M_FULL:
-		mii_autoneg_adv_reg |=3D MII_AR_10T_FD_CAPS;
-		break;
-
-	default:
-		mii_autoneg_adv_reg |=3D MII_AR_10T_HD_CAPS;
-		break;
-	}
-
-	/* flow control fixed to enable all */
-	mii_autoneg_adv_reg |=3D (MII_AR_ASM_DIR | MII_AR_PAUSE);
-
-	hw->mii_autoneg_adv_reg =3D mii_autoneg_adv_reg;
-	hw->mii_1000t_ctrl_reg =3D mii_1000t_ctrl_reg;
-
-	ret_val =3D atl1_write_phy_reg(hw, MII_ADVERTISE, mii_autoneg_adv_reg=
);
-	if (ret_val)
-		return ret_val;
-
-	ret_val =3D atl1_write_phy_reg(hw, MII_AT001_CR, mii_1000t_ctrl_reg);
-	if (ret_val)
-		return ret_val;
-
-	return ATL1_SUCCESS;
-}
-
-/*
- * Configures link settings.
- * hw - Struct containing variables accessed by shared code
- * Assumes the hardware has previously been reset and the
- * transmitter and receiver are not enabled.
- */
-static s32 atl1_setup_link(struct atl1_hw *hw)
-{
-	struct pci_dev *pdev =3D hw->back->pdev;
-	s32 ret_val;
-
-	/*
-	 * Options:
-	 *  PHY will advertise value(s) parsed from
-	 *  autoneg_advertised and fc
-	 *  no matter what autoneg is , We will not wait link result.
-	 */
-	ret_val =3D atl1_phy_setup_autoneg_adv(hw);
-	if (ret_val) {
-		dev_dbg(&pdev->dev, "error setting up autonegotiation\n");
-		return ret_val;
-	}
-	/* SW.Reset , En-Auto-Neg if needed */
-	ret_val =3D atl1_phy_reset(hw);
-	if (ret_val) {
-		dev_dbg(&pdev->dev, "error resetting phy\n");
-		return ret_val;
-	}
-	hw->phy_configured =3D true;
-	return ret_val;
-}
-
-static struct atl1_spi_flash_dev flash_table[] =3D {
-/*	MFR_NAME  WRSR  READ  PRGM  WREN  WRDI  RDSR  RDID  SECTOR_ERASE CH=
IP_ERASE */
-	{"Atmel", 0x00, 0x03, 0x02, 0x06, 0x04, 0x05, 0x15, 0x52,        0x62=
},
-	{"SST",   0x01, 0x03, 0x02, 0x06, 0x04, 0x05, 0x90, 0x20,        0x60=
},
-	{"ST",    0x01, 0x03, 0x02, 0x06, 0x04, 0x05, 0xAB, 0xD8,        0xC7=
},
-};
-
-static void atl1_init_flash_opcode(struct atl1_hw *hw)
-{
-	if (hw->flash_vendor >=3D ARRAY_SIZE(flash_table))
-		hw->flash_vendor =3D 0;	/* ATMEL */
-
-	/* Init OP table */
-	iowrite8(flash_table[hw->flash_vendor].cmd_program,
-		hw->hw_addr + REG_SPI_FLASH_OP_PROGRAM);
-	iowrite8(flash_table[hw->flash_vendor].cmd_sector_erase,
-		hw->hw_addr + REG_SPI_FLASH_OP_SC_ERASE);
-	iowrite8(flash_table[hw->flash_vendor].cmd_chip_erase,
-		hw->hw_addr + REG_SPI_FLASH_OP_CHIP_ERASE);
-	iowrite8(flash_table[hw->flash_vendor].cmd_rdid,
-		hw->hw_addr + REG_SPI_FLASH_OP_RDID);
-	iowrite8(flash_table[hw->flash_vendor].cmd_wren,
-		hw->hw_addr + REG_SPI_FLASH_OP_WREN);
-	iowrite8(flash_table[hw->flash_vendor].cmd_rdsr,
-		hw->hw_addr + REG_SPI_FLASH_OP_RDSR);
-	iowrite8(flash_table[hw->flash_vendor].cmd_wrsr,
-		hw->hw_addr + REG_SPI_FLASH_OP_WRSR);
-	iowrite8(flash_table[hw->flash_vendor].cmd_read,
-		hw->hw_addr + REG_SPI_FLASH_OP_READ);
-}
-
-/*
- * Performs basic configuration of the adapter.
- * hw - Struct containing variables accessed by shared code
- * Assumes that the controller has previously been reset and is in a
- * post-reset uninitialized state. Initializes multicast table,
- * and  Calls routines to setup link
- * Leaves the transmit and receive units disabled and uninitialized.
- */
-s32 atl1_init_hw(struct atl1_hw *hw)
-{
-	u32 ret_val =3D 0;
-
-	/* Zero out the Multicast HASH table */
-	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
-	/* clear the old settings from the multicast hash table */
-	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
-
-	atl1_init_flash_opcode(hw);
-
-	if (!hw->phy_configured) {
-		/* enable GPHY LinkChange Interrrupt */
-		ret_val =3D atl1_write_phy_reg(hw, 18, 0xC00);
-		if (ret_val)
-			return ret_val;
-		/* make PHY out of power-saving state */
-		ret_val =3D atl1_phy_leave_power_saving(hw);
-		if (ret_val)
-			return ret_val;
-		/* Call a subroutine to configure the link */
-		ret_val =3D atl1_setup_link(hw);
-	}
-	return ret_val;
-}
-
-/*
- * Detects the current speed and duplex settings of the hardware.
- * hw - Struct containing variables accessed by shared code
- * speed - Speed of the connection
- * duplex - Duplex setting of the connection
- */
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *dup=
lex)
-{
-	struct pci_dev *pdev =3D hw->back->pdev;
-	s32 ret_val;
-	u16 phy_data;
-
-	/* ; --- Read   PHY Specific Status Register (17) */
-	ret_val =3D atl1_read_phy_reg(hw, MII_AT001_PSSR, &phy_data);
-	if (ret_val)
-		return ret_val;
-
-	if (!(phy_data & MII_AT001_PSSR_SPD_DPLX_RESOLVED))
-		return ATL1_ERR_PHY_RES;
-
-	switch (phy_data & MII_AT001_PSSR_SPEED) {
-	case MII_AT001_PSSR_1000MBS:
-		*speed =3D SPEED_1000;
-		break;
-	case MII_AT001_PSSR_100MBS:
-		*speed =3D SPEED_100;
-		break;
-	case MII_AT001_PSSR_10MBS:
-		*speed =3D SPEED_10;
-		break;
-	default:
-		dev_dbg(&pdev->dev, "error getting speed\n");
-		return ATL1_ERR_PHY_SPEED;
-		break;
-	}
-	if (phy_data & MII_AT001_PSSR_DPLX)
-		*duplex =3D FULL_DUPLEX;
-	else
-		*duplex =3D HALF_DUPLEX;
-
-	return ATL1_SUCCESS;
-}
-
-void atl1_set_mac_addr(struct atl1_hw *hw)
-{
-	u32 value;
-	/*
-	 * 00-0B-6A-F6-00-DC
-	 * 0:  6AF600DC   1: 000B
-	 * low dword
-	 */
-	value =3D (((u32) hw->mac_addr[2]) << 24) |
-	    (((u32) hw->mac_addr[3]) << 16) |
-	    (((u32) hw->mac_addr[4]) << 8) | (((u32) hw->mac_addr[5]));
-	iowrite32(value, hw->hw_addr + REG_MAC_STA_ADDR);
-	/* high dword */
-	value =3D (((u32) hw->mac_addr[0]) << 8) | (((u32) hw->mac_addr[1]));
-	iowrite32(value, (hw->hw_addr + REG_MAC_STA_ADDR) + (1 << 2));
-}
diff --git a/drivers/net/atlx/atl1_hw.h b/drivers/net/atlx/atl1_hw.h
deleted file mode 100644
index 939aa0f..0000000
--- a/drivers/net/atlx/atl1_hw.h
+++ /dev/null
@@ -1,946 +0,0 @@
-/*
- * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
- * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- *
- * Derived from Intel e1000 driver
- * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modif=
y it
- * under the terms of the GNU General Public License as published by t=
he Free
- * Software Foundation; either version 2 of the License, or (at your o=
ption)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful, but=
 WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
- * more details.
- *
- * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- *
- * There are a lot of defines in here that are unused and/or have cryp=
tic
- * names.  Please leave them alone, as they're the closest thing we ha=
ve
- * to a spec from Attansic at present. *ahem* -- CHS
- */
-
-#ifndef _ATL1_HW_H_
-#define _ATL1_HW_H_
-
-#include <linux/types.h>
-#include <linux/mii.h>
-
-struct atl1_adapter;
-struct atl1_hw;
-
-/* function prototypes needed by multiple files */
-s32 atl1_phy_setup_autoneg_adv(struct atl1_hw *hw);
-s32 atl1_write_phy_reg(struct atl1_hw *hw, u32 reg_addr, u16 phy_data)=
;
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *dup=
lex);
-s32 atl1_read_mac_addr(struct atl1_hw *hw);
-s32 atl1_init_hw(struct atl1_hw *hw);
-s32 atl1_get_speed_and_duplex(struct atl1_hw *hw, u16 *speed, u16 *dup=
lex);
-s32 atl1_set_speed_and_duplex(struct atl1_hw *hw, u16 speed, u16 duple=
x);
-u32 atl1_hash_mc_addr(struct atl1_hw *hw, u8 *mc_addr);
-void atl1_hash_set(struct atl1_hw *hw, u32 hash_value);
-s32 atl1_read_phy_reg(struct atl1_hw *hw, u16 reg_addr, u16 *phy_data)=
;
-void atl1_set_mac_addr(struct atl1_hw *hw);
-s32 atl1_phy_enter_power_saving(struct atl1_hw *hw);
-s32 atl1_reset_hw(struct atl1_hw *hw);
-void atl1_check_options(struct atl1_adapter *adapter);
-
-/* register definitions */
-#define REG_PCIE_CAP_LIST			0x58
-
-#define REG_VPD_CAP				0x6C
-#define VPD_CAP_ID_MASK				0xff
-#define VPD_CAP_ID_SHIFT			0
-#define VPD_CAP_NEXT_PTR_MASK			0xFF
-#define VPD_CAP_NEXT_PTR_SHIFT			8
-#define VPD_CAP_VPD_ADDR_MASK			0x7FFF
-#define VPD_CAP_VPD_ADDR_SHIFT			16
-#define VPD_CAP_VPD_FLAG			0x80000000
-
-#define REG_VPD_DATA				0x70
-
-#define REG_SPI_FLASH_CTRL			0x200
-#define SPI_FLASH_CTRL_STS_NON_RDY		0x1
-#define SPI_FLASH_CTRL_STS_WEN			0x2
-#define SPI_FLASH_CTRL_STS_WPEN			0x80
-#define SPI_FLASH_CTRL_DEV_STS_MASK		0xFF
-#define SPI_FLASH_CTRL_DEV_STS_SHIFT		0
-#define SPI_FLASH_CTRL_INS_MASK			0x7
-#define SPI_FLASH_CTRL_INS_SHIFT		8
-#define SPI_FLASH_CTRL_START			0x800
-#define SPI_FLASH_CTRL_EN_VPD			0x2000
-#define SPI_FLASH_CTRL_LDSTART			0x8000
-#define SPI_FLASH_CTRL_CS_HI_MASK		0x3
-#define SPI_FLASH_CTRL_CS_HI_SHIFT		16
-#define SPI_FLASH_CTRL_CS_HOLD_MASK		0x3
-#define SPI_FLASH_CTRL_CS_HOLD_SHIFT		18
-#define SPI_FLASH_CTRL_CLK_LO_MASK		0x3
-#define SPI_FLASH_CTRL_CLK_LO_SHIFT		20
-#define SPI_FLASH_CTRL_CLK_HI_MASK		0x3
-#define SPI_FLASH_CTRL_CLK_HI_SHIFT		22
-#define SPI_FLASH_CTRL_CS_SETUP_MASK		0x3
-#define SPI_FLASH_CTRL_CS_SETUP_SHIFT		24
-#define SPI_FLASH_CTRL_EROM_PGSZ_MASK		0x3
-#define SPI_FLASH_CTRL_EROM_PGSZ_SHIFT		26
-#define SPI_FLASH_CTRL_WAIT_READY		0x10000000
-
-#define REG_SPI_ADDR				0x204
-
-#define REG_SPI_DATA				0x208
-
-#define REG_SPI_FLASH_CONFIG			0x20C
-#define SPI_FLASH_CONFIG_LD_ADDR_MASK		0xFFFFFF
-#define SPI_FLASH_CONFIG_LD_ADDR_SHIFT		0
-#define SPI_FLASH_CONFIG_VPD_ADDR_MASK		0x3
-#define SPI_FLASH_CONFIG_VPD_ADDR_SHIFT		24
-#define SPI_FLASH_CONFIG_LD_EXIST		0x4000000
-
-#define REG_SPI_FLASH_OP_PROGRAM		0x210
-#define REG_SPI_FLASH_OP_SC_ERASE		0x211
-#define REG_SPI_FLASH_OP_CHIP_ERASE		0x212
-#define REG_SPI_FLASH_OP_RDID			0x213
-#define REG_SPI_FLASH_OP_WREN			0x214
-#define REG_SPI_FLASH_OP_RDSR			0x215
-#define REG_SPI_FLASH_OP_WRSR			0x216
-#define REG_SPI_FLASH_OP_READ			0x217
-
-#define REG_TWSI_CTRL				0x218
-#define TWSI_CTRL_LD_OFFSET_MASK		0xFF
-#define TWSI_CTRL_LD_OFFSET_SHIFT		0
-#define TWSI_CTRL_LD_SLV_ADDR_MASK		0x7
-#define TWSI_CTRL_LD_SLV_ADDR_SHIFT		8
-#define TWSI_CTRL_SW_LDSTART			0x800
-#define TWSI_CTRL_HW_LDSTART			0x1000
-#define TWSI_CTRL_SMB_SLV_ADDR_MASK		0x7F
-#define TWSI_CTRL_SMB_SLV_ADDR_SHIFT		15
-#define TWSI_CTRL_LD_EXIST			0x400000
-#define TWSI_CTRL_READ_FREQ_SEL_MASK		0x3
-#define TWSI_CTRL_READ_FREQ_SEL_SHIFT		23
-#define TWSI_CTRL_FREQ_SEL_100K			0
-#define TWSI_CTRL_FREQ_SEL_200K			1
-#define TWSI_CTRL_FREQ_SEL_300K			2
-#define TWSI_CTRL_FREQ_SEL_400K			3
-#define TWSI_CTRL_SMB_SLV_ADDR
-#define TWSI_CTRL_WRITE_FREQ_SEL_MASK		0x3
-#define TWSI_CTRL_WRITE_FREQ_SEL_SHIFT		24
-
-#define REG_PCIE_DEV_MISC_CTRL			0x21C
-#define PCIE_DEV_MISC_CTRL_EXT_PIPE		0x2
-#define PCIE_DEV_MISC_CTRL_RETRY_BUFDIS		0x1
-#define PCIE_DEV_MISC_CTRL_SPIROM_EXIST		0x4
-#define PCIE_DEV_MISC_CTRL_SERDES_ENDIAN	0x8
-#define PCIE_DEV_MISC_CTRL_SERDES_SEL_DIN	0x10
-
-/* Selene Master Control Register */
-#define REG_MASTER_CTRL				0x1400
-#define MASTER_CTRL_SOFT_RST			0x1
-#define MASTER_CTRL_MTIMER_EN			0x2
-#define MASTER_CTRL_ITIMER_EN			0x4
-#define MASTER_CTRL_MANUAL_INT			0x8
-#define MASTER_CTRL_REV_NUM_SHIFT		16
-#define MASTER_CTRL_REV_NUM_MASK		0xff
-#define MASTER_CTRL_DEV_ID_SHIFT		24
-#define MASTER_CTRL_DEV_ID_MASK			0xff
-
-/* Timer Initial Value Register */
-#define REG_MANUAL_TIMER_INIT			0x1404
-
-/* IRQ ModeratorTimer Initial Value Register */
-#define REG_IRQ_MODU_TIMER_INIT			0x1408
-
-#define REG_GPHY_ENABLE				0x140C
-
-/* IRQ Anti-Lost Timer Initial Value Register */
-#define REG_CMBDISDMA_TIMER			0x140E
-
-/* Block IDLE Status Register */
-#define REG_IDLE_STATUS				0x1410
-#define IDLE_STATUS_RXMAC			1
-#define IDLE_STATUS_TXMAC			2
-#define IDLE_STATUS_RXQ				4
-#define IDLE_STATUS_TXQ				8
-#define IDLE_STATUS_DMAR			0x10
-#define IDLE_STATUS_DMAW			0x20
-#define IDLE_STATUS_SMB				0x40
-#define IDLE_STATUS_CMB				0x80
-
-/* MDIO Control Register */
-#define REG_MDIO_CTRL				0x1414
-#define MDIO_DATA_MASK				0xffff
-#define MDIO_DATA_SHIFT				0
-#define MDIO_REG_ADDR_MASK			0x1f
-#define MDIO_REG_ADDR_SHIFT			16
-#define MDIO_RW					0x200000
-#define MDIO_SUP_PREAMBLE			0x400000
-#define MDIO_START				0x800000
-#define MDIO_CLK_SEL_SHIFT			24
-#define MDIO_CLK_25_4				0
-#define MDIO_CLK_25_6				2
-#define MDIO_CLK_25_8				3
-#define MDIO_CLK_25_10				4
-#define MDIO_CLK_25_14				5
-#define MDIO_CLK_25_20				6
-#define MDIO_CLK_25_28				7
-#define MDIO_BUSY				0x8000000
-#define MDIO_WAIT_TIMES				30
-
-/* MII PHY Status Register */
-#define REG_PHY_STATUS				0x1418
-
-/* BIST Control and Status Register0 (for the Packet Memory) */
-#define REG_BIST0_CTRL				0x141c
-#define BIST0_NOW				0x1
-#define BIST0_SRAM_FAIL				0x2
-#define BIST0_FUSE_FLAG				0x4
-#define REG_BIST1_CTRL				0x1420
-#define BIST1_NOW				0x1
-#define BIST1_SRAM_FAIL				0x2
-#define BIST1_FUSE_FLAG				0x4
-
-/* MAC Control Register */
-#define REG_MAC_CTRL				0x1480
-#define MAC_CTRL_TX_EN				1
-#define MAC_CTRL_RX_EN				2
-#define MAC_CTRL_TX_FLOW			4
-#define MAC_CTRL_RX_FLOW			8
-#define MAC_CTRL_LOOPBACK			0x10
-#define MAC_CTRL_DUPLX				0x20
-#define MAC_CTRL_ADD_CRC			0x40
-#define MAC_CTRL_PAD				0x80
-#define MAC_CTRL_LENCHK				0x100
-#define MAC_CTRL_HUGE_EN			0x200
-#define MAC_CTRL_PRMLEN_SHIFT			10
-#define MAC_CTRL_PRMLEN_MASK			0xf
-#define MAC_CTRL_RMV_VLAN			0x4000
-#define MAC_CTRL_PROMIS_EN			0x8000
-#define MAC_CTRL_TX_PAUSE			0x10000
-#define MAC_CTRL_SCNT				0x20000
-#define MAC_CTRL_SRST_TX			0x40000
-#define MAC_CTRL_TX_SIMURST			0x80000
-#define MAC_CTRL_SPEED_SHIFT			20
-#define MAC_CTRL_SPEED_MASK			0x300000
-#define MAC_CTRL_SPEED_1000			2
-#define MAC_CTRL_SPEED_10_100			1
-#define MAC_CTRL_DBG_TX_BKPRESURE		0x400000
-#define MAC_CTRL_TX_HUGE			0x800000
-#define MAC_CTRL_RX_CHKSUM_EN			0x1000000
-#define MAC_CTRL_MC_ALL_EN			0x2000000
-#define MAC_CTRL_BC_EN				0x4000000
-#define MAC_CTRL_DBG				0x8000000
-
-/* MAC IPG/IFG Control Register */
-#define REG_MAC_IPG_IFG				0x1484
-#define MAC_IPG_IFG_IPGT_SHIFT			0
-#define MAC_IPG_IFG_IPGT_MASK			0x7f
-#define MAC_IPG_IFG_MIFG_SHIFT			8
-#define MAC_IPG_IFG_MIFG_MASK			0xff
-#define MAC_IPG_IFG_IPGR1_SHIFT			16
-#define MAC_IPG_IFG_IPGR1_MASK			0x7f
-#define MAC_IPG_IFG_IPGR2_SHIFT			24
-#define MAC_IPG_IFG_IPGR2_MASK			0x7f
-
-/* MAC STATION ADDRESS */
-#define REG_MAC_STA_ADDR			0x1488
-
-/* Hash table for multicast address */
-#define REG_RX_HASH_TABLE			0x1490
-
-/* MAC Half-Duplex Control Register */
-#define REG_MAC_HALF_DUPLX_CTRL			0x1498
-#define MAC_HALF_DUPLX_CTRL_LCOL_SHIFT		0
-#define MAC_HALF_DUPLX_CTRL_LCOL_MASK		0x3ff
-#define MAC_HALF_DUPLX_CTRL_RETRY_SHIFT		12
-#define MAC_HALF_DUPLX_CTRL_RETRY_MASK		0xf
-#define MAC_HALF_DUPLX_CTRL_EXC_DEF_EN		0x10000
-#define MAC_HALF_DUPLX_CTRL_NO_BACK_C		0x20000
-#define MAC_HALF_DUPLX_CTRL_NO_BACK_P		0x40000
-#define MAC_HALF_DUPLX_CTRL_ABEBE		0x80000
-#define MAC_HALF_DUPLX_CTRL_ABEBT_SHIFT		20
-#define MAC_HALF_DUPLX_CTRL_ABEBT_MASK		0xf
-#define MAC_HALF_DUPLX_CTRL_JAMIPG_SHIFT	24
-#define MAC_HALF_DUPLX_CTRL_JAMIPG_MASK		0xf
-
-/* Maximum Frame Length Control Register */
-#define REG_MTU					0x149c
-
-/* Wake-On-Lan control register */
-#define REG_WOL_CTRL				0x14a0
-#define WOL_PATTERN_EN				0x00000001
-#define WOL_PATTERN_PME_EN			0x00000002
-#define WOL_MAGIC_EN				0x00000004
-#define WOL_MAGIC_PME_EN			0x00000008
-#define WOL_LINK_CHG_EN				0x00000010
-#define WOL_LINK_CHG_PME_EN			0x00000020
-#define WOL_PATTERN_ST				0x00000100
-#define WOL_MAGIC_ST				0x00000200
-#define WOL_LINKCHG_ST				0x00000400
-#define WOL_CLK_SWITCH_EN			0x00008000
-#define WOL_PT0_EN				0x00010000
-#define WOL_PT1_EN				0x00020000
-#define WOL_PT2_EN				0x00040000
-#define WOL_PT3_EN				0x00080000
-#define WOL_PT4_EN				0x00100000
-#define WOL_PT5_EN				0x00200000
-#define WOL_PT6_EN				0x00400000
-
-/* WOL Length ( 2 DWORD ) */
-#define REG_WOL_PATTERN_LEN			0x14a4
-#define WOL_PT_LEN_MASK				0x7f
-#define WOL_PT0_LEN_SHIFT			0
-#define WOL_PT1_LEN_SHIFT			8
-#define WOL_PT2_LEN_SHIFT			16
-#define WOL_PT3_LEN_SHIFT			24
-#define WOL_PT4_LEN_SHIFT			0
-#define WOL_PT5_LEN_SHIFT			8
-#define WOL_PT6_LEN_SHIFT			16
-
-/* Internal SRAM Partition Register */
-#define REG_SRAM_RFD_ADDR			0x1500
-#define REG_SRAM_RFD_LEN			(REG_SRAM_RFD_ADDR+ 4)
-#define REG_SRAM_RRD_ADDR			(REG_SRAM_RFD_ADDR+ 8)
-#define REG_SRAM_RRD_LEN			(REG_SRAM_RFD_ADDR+12)
-#define REG_SRAM_TPD_ADDR			(REG_SRAM_RFD_ADDR+16)
-#define REG_SRAM_TPD_LEN			(REG_SRAM_RFD_ADDR+20)
-#define REG_SRAM_TRD_ADDR			(REG_SRAM_RFD_ADDR+24)
-#define REG_SRAM_TRD_LEN			(REG_SRAM_RFD_ADDR+28)
-#define REG_SRAM_RXF_ADDR			(REG_SRAM_RFD_ADDR+32)
-#define REG_SRAM_RXF_LEN			(REG_SRAM_RFD_ADDR+36)
-#define REG_SRAM_TXF_ADDR			(REG_SRAM_RFD_ADDR+40)
-#define REG_SRAM_TXF_LEN			(REG_SRAM_RFD_ADDR+44)
-#define REG_SRAM_TCPH_PATH_ADDR			(REG_SRAM_RFD_ADDR+48)
-#define SRAM_TCPH_ADDR_MASK			0x0fff
-#define SRAM_TCPH_ADDR_SHIFT			0
-#define SRAM_PATH_ADDR_MASK			0x0fff
-#define SRAM_PATH_ADDR_SHIFT			16
-
-/* Load Ptr Register */
-#define REG_LOAD_PTR				(REG_SRAM_RFD_ADDR+52)
-
-/* Descriptor Control register */
-#define REG_DESC_BASE_ADDR_HI			0x1540
-#define REG_DESC_RFD_ADDR_LO			(REG_DESC_BASE_ADDR_HI+4)
-#define REG_DESC_RRD_ADDR_LO			(REG_DESC_BASE_ADDR_HI+8)
-#define REG_DESC_TPD_ADDR_LO			(REG_DESC_BASE_ADDR_HI+12)
-#define REG_DESC_CMB_ADDR_LO			(REG_DESC_BASE_ADDR_HI+16)
-#define REG_DESC_SMB_ADDR_LO			(REG_DESC_BASE_ADDR_HI+20)
-#define REG_DESC_RFD_RRD_RING_SIZE		(REG_DESC_BASE_ADDR_HI+24)
-#define DESC_RFD_RING_SIZE_MASK			0x7ff
-#define DESC_RFD_RING_SIZE_SHIFT		0
-#define DESC_RRD_RING_SIZE_MASK			0x7ff
-#define DESC_RRD_RING_SIZE_SHIFT		16
-#define REG_DESC_TPD_RING_SIZE			(REG_DESC_BASE_ADDR_HI+28)
-#define DESC_TPD_RING_SIZE_MASK			0x3ff
-#define DESC_TPD_RING_SIZE_SHIFT		0
-
-/* TXQ Control Register */
-#define REG_TXQ_CTRL				0x1580
-#define TXQ_CTRL_TPD_BURST_NUM_SHIFT		0
-#define TXQ_CTRL_TPD_BURST_NUM_MASK		0x1f
-#define TXQ_CTRL_EN				0x20
-#define TXQ_CTRL_ENH_MODE			0x40
-#define TXQ_CTRL_TPD_FETCH_TH_SHIFT		8
-#define TXQ_CTRL_TPD_FETCH_TH_MASK		0x3f
-#define TXQ_CTRL_TXF_BURST_NUM_SHIFT		16
-#define TXQ_CTRL_TXF_BURST_NUM_MASK		0xffff
-
-/* Jumbo packet Threshold for task offload */
-#define REG_TX_JUMBO_TASK_TH_TPD_IPG		0x1584
-#define TX_JUMBO_TASK_TH_MASK			0x7ff
-#define TX_JUMBO_TASK_TH_SHIFT			0
-#define TX_TPD_MIN_IPG_MASK			0x1f
-#define TX_TPD_MIN_IPG_SHIFT			16
-
-/* RXQ Control Register */
-#define REG_RXQ_CTRL				0x15a0
-#define RXQ_CTRL_RFD_BURST_NUM_SHIFT		0
-#define RXQ_CTRL_RFD_BURST_NUM_MASK		0xff
-#define RXQ_CTRL_RRD_BURST_THRESH_SHIFT		8
-#define RXQ_CTRL_RRD_BURST_THRESH_MASK		0xff
-#define RXQ_CTRL_RFD_PREF_MIN_IPG_SHIFT		16
-#define RXQ_CTRL_RFD_PREF_MIN_IPG_MASK		0x1f
-#define RXQ_CTRL_CUT_THRU_EN			0x40000000
-#define RXQ_CTRL_EN				0x80000000
-
-/* Rx jumbo packet threshold and rrd  retirement timer */
-#define REG_RXQ_JMBOSZ_RRDTIM			(REG_RXQ_CTRL+ 4)
-#define RXQ_JMBOSZ_TH_MASK			0x7ff
-#define RXQ_JMBOSZ_TH_SHIFT			0
-#define RXQ_JMBO_LKAH_MASK			0xf
-#define RXQ_JMBO_LKAH_SHIFT			11
-#define RXQ_RRD_TIMER_MASK			0xffff
-#define RXQ_RRD_TIMER_SHIFT			16
-
-/* RFD flow control register */
-#define REG_RXQ_RXF_PAUSE_THRESH		(REG_RXQ_CTRL+ 8)
-#define RXQ_RXF_PAUSE_TH_HI_SHIFT		16
-#define RXQ_RXF_PAUSE_TH_HI_MASK		0xfff
-#define RXQ_RXF_PAUSE_TH_LO_SHIFT		0
-#define RXQ_RXF_PAUSE_TH_LO_MASK		0xfff
-
-/* RRD flow control register */
-#define REG_RXQ_RRD_PAUSE_THRESH		(REG_RXQ_CTRL+12)
-#define RXQ_RRD_PAUSE_TH_HI_SHIFT		0
-#define RXQ_RRD_PAUSE_TH_HI_MASK		0xfff
-#define RXQ_RRD_PAUSE_TH_LO_SHIFT		16
-#define RXQ_RRD_PAUSE_TH_LO_MASK		0xfff
-
-/* DMA Engine Control Register */
-#define REG_DMA_CTRL				0x15c0
-#define DMA_CTRL_DMAR_IN_ORDER			0x1
-#define DMA_CTRL_DMAR_ENH_ORDER			0x2
-#define DMA_CTRL_DMAR_OUT_ORDER			0x4
-#define DMA_CTRL_RCB_VALUE			0x8
-#define DMA_CTRL_DMAR_BURST_LEN_SHIFT		4
-#define DMA_CTRL_DMAR_BURST_LEN_MASK		7
-#define DMA_CTRL_DMAW_BURST_LEN_SHIFT		7
-#define DMA_CTRL_DMAW_BURST_LEN_MASK		7
-#define DMA_CTRL_DMAR_EN				0x400
-#define DMA_CTRL_DMAW_EN				0x800
-
-/* CMB/SMB Control Register */
-#define REG_CSMB_CTRL				0x15d0
-#define CSMB_CTRL_CMB_NOW			1
-#define CSMB_CTRL_SMB_NOW			2
-#define CSMB_CTRL_CMB_EN			4
-#define CSMB_CTRL_SMB_EN			8
-
-/* CMB DMA Write Threshold Register */
-#define REG_CMB_WRITE_TH			(REG_CSMB_CTRL+ 4)
-#define CMB_RRD_TH_SHIFT			0
-#define CMB_RRD_TH_MASK				0x7ff
-#define CMB_TPD_TH_SHIFT			16
-#define CMB_TPD_TH_MASK				0x7ff
-
-/* RX/TX count-down timer to trigger CMB-write. 2us resolution. */
-#define REG_CMB_WRITE_TIMER			(REG_CSMB_CTRL+ 8)
-#define CMB_RX_TM_SHIFT				0
-#define CMB_RX_TM_MASK				0xffff
-#define CMB_TX_TM_SHIFT				16
-#define CMB_TX_TM_MASK				0xffff
-
-/* Number of packet received since last CMB write */
-#define REG_CMB_RX_PKT_CNT			(REG_CSMB_CTRL+12)
-
-/* Number of packet transmitted since last CMB write */
-#define REG_CMB_TX_PKT_CNT			(REG_CSMB_CTRL+16)
-
-/* SMB auto DMA timer register */
-#define REG_SMB_TIMER				(REG_CSMB_CTRL+20)
-
-/* Mailbox Register */
-#define REG_MAILBOX				0x15f0
-#define MB_RFD_PROD_INDX_SHIFT			0
-#define MB_RFD_PROD_INDX_MASK			0x7ff
-#define MB_RRD_CONS_INDX_SHIFT			11
-#define MB_RRD_CONS_INDX_MASK			0x7ff
-#define MB_TPD_PROD_INDX_SHIFT			22
-#define MB_TPD_PROD_INDX_MASK			0x3ff
-
-/* Interrupt Status Register */
-#define REG_ISR					0x1600
-#define ISR_SMB					1
-#define ISR_TIMER				2
-#define ISR_MANUAL				4
-#define ISR_RXF_OV				8
-#define ISR_RFD_UNRUN				0x10
-#define ISR_RRD_OV				0x20
-#define ISR_TXF_UNRUN				0x40
-#define ISR_LINK				0x80
-#define ISR_HOST_RFD_UNRUN			0x100
-#define ISR_HOST_RRD_OV				0x200
-#define ISR_DMAR_TO_RST				0x400
-#define ISR_DMAW_TO_RST				0x800
-#define ISR_GPHY				0x1000
-#define ISR_RX_PKT				0x10000
-#define ISR_TX_PKT				0x20000
-#define ISR_TX_DMA				0x40000
-#define ISR_RX_DMA				0x80000
-#define ISR_CMB_RX				0x100000
-#define ISR_CMB_TX				0x200000
-#define ISR_MAC_RX				0x400000
-#define ISR_MAC_TX				0x800000
-#define ISR_UR_DETECTED				0x1000000
-#define ISR_FERR_DETECTED			0x2000000
-#define ISR_NFERR_DETECTED			0x4000000
-#define ISR_CERR_DETECTED			0x8000000
-#define ISR_PHY_LINKDOWN			0x10000000
-#define ISR_DIS_SMB				0x20000000
-#define ISR_DIS_DMA				0x40000000
-#define ISR_DIS_INT				0x80000000
-
-/* Interrupt Mask Register */
-#define REG_IMR					0x1604
-
-/* Normal Interrupt mask  */
-#define IMR_NORMAL_MASK	(\
-	ISR_SMB		|\
-	ISR_GPHY	|\
-	ISR_PHY_LINKDOWN|\
-	ISR_DMAR_TO_RST	|\
-	ISR_DMAW_TO_RST	|\
-	ISR_CMB_TX	|\
-	ISR_CMB_RX	)
-
-/* Debug Interrupt Mask  (enable all interrupt) */
-#define IMR_DEBUG_MASK	(\
-	ISR_SMB		|\
-	ISR_TIMER	|\
-	ISR_MANUAL	|\
-	ISR_RXF_OV	|\
-	ISR_RFD_UNRUN	|\
-	ISR_RRD_OV	|\
-	ISR_TXF_UNRUN	|\
-	ISR_LINK	|\
-	ISR_CMB_TX	|\
-	ISR_CMB_RX	|\
-	ISR_RX_PKT	|\
-	ISR_TX_PKT	|\
-	ISR_MAC_RX	|\
-	ISR_MAC_TX	)
-
-/* Interrupt Status Register */
-#define REG_RFD_RRD_IDX				0x1800
-#define REG_TPD_IDX				0x1804
-
-/*  MII definition */
-/* PHY Common Register */
-#define MII_AT001_CR					0x09
-#define MII_AT001_SR					0x0A
-#define MII_AT001_ESR					0x0F
-#define MII_AT001_PSCR					0x10
-#define MII_AT001_PSSR					0x11
-
-/* PHY Control Register */
-#define MII_CR_SPEED_SELECT_MSB				0x0040	/* bits 6,13: 10=3D1000, 01=3D=
100, 00=3D10 */
-#define MII_CR_COLL_TEST_ENABLE				0x0080	/* Collision test enable */
-#define MII_CR_FULL_DUPLEX				0x0100	/* FDX =3D1, half duplex =3D0 */
-#define MII_CR_RESTART_AUTO_NEG				0x0200	/* Restart auto negotiation =
*/
-#define MII_CR_ISOLATE					0x0400	/* Isolate PHY from MII */
-#define MII_CR_POWER_DOWN				0x0800	/* Power down */
-#define MII_CR_AUTO_NEG_EN				0x1000	/* Auto Neg Enable */
-#define MII_CR_SPEED_SELECT_LSB				0x2000	/* bits 6,13: 10=3D1000, 01=3D=
100, 00=3D10 */
-#define MII_CR_LOOPBACK					0x4000	/* 0 =3D normal, 1 =3D loopback */
-#define MII_CR_RESET					0x8000	/* 0 =3D normal, 1 =3D PHY reset */
-#define MII_CR_SPEED_MASK				0x2040
-#define MII_CR_SPEED_1000				0x0040
-#define MII_CR_SPEED_100				0x2000
-#define MII_CR_SPEED_10					0x0000
-
-/* PHY Status Register */
-#define MII_SR_EXTENDED_CAPS				0x0001	/* Extended register capabiliti=
es */
-#define MII_SR_JABBER_DETECT				0x0002	/* Jabber Detected */
-#define MII_SR_LINK_STATUS				0x0004	/* Link Status 1 =3D link */
-#define MII_SR_AUTONEG_CAPS				0x0008	/* Auto Neg Capable */
-#define MII_SR_REMOTE_FAULT				0x0010	/* Remote Fault Detect */
-#define MII_SR_AUTONEG_COMPLETE				0x0020	/* Auto Neg Complete */
-#define MII_SR_PREAMBLE_SUPPRESS			0x0040	/* Preamble may be suppresse=
d */
-#define MII_SR_EXTENDED_STATUS				0x0100	/* Ext. status info in Reg 0x=
0F */
-#define MII_SR_100T2_HD_CAPS				0x0200	/* 100T2 Half Duplex Capable */
-#define MII_SR_100T2_FD_CAPS				0x0400	/* 100T2 Full Duplex Capable */
-#define MII_SR_10T_HD_CAPS				0x0800	/* 10T   Half Duplex Capable */
-#define MII_SR_10T_FD_CAPS				0x1000	/* 10T   Full Duplex Capable */
-#define MII_SR_100X_HD_CAPS				0x2000	/* 100X  Half Duplex Capable */
-#define MII_SR_100X_FD_CAPS				0x4000	/* 100X  Full Duplex Capable */
-#define MII_SR_100T4_CAPS				0x8000	/* 100T4 Capable */
-
-/* Link partner ability register. */
-#define MII_LPA_SLCT					0x001f	/* Same as advertise selector  */
-#define MII_LPA_10HALF					0x0020	/* Can do 10mbps half-duplex   */
-#define MII_LPA_10FULL					0x0040	/* Can do 10mbps full-duplex   */
-#define MII_LPA_100HALF					0x0080	/* Can do 100mbps half-duplex  */
-#define MII_LPA_100FULL					0x0100	/* Can do 100mbps full-duplex  */
-#define MII_LPA_100BASE4				0x0200	/* 100BASE-T4  */
-#define MII_LPA_PAUSE					0x0400	/* PAUSE */
-#define MII_LPA_ASYPAUSE				0x0800	/* Asymmetrical PAUSE */
-#define MII_LPA_RFAULT					0x2000	/* Link partner faulted        */
-#define MII_LPA_LPACK					0x4000	/* Link partner acked us       */
-#define MII_LPA_NPAGE					0x8000	/* Next page bit               */
-
-/* Autoneg Advertisement Register */
-#define MII_AR_SELECTOR_FIELD				0x0001	/* indicates IEEE 802.3 CSMA/C=
D */
-#define MII_AR_10T_HD_CAPS				0x0020	/* 10T   Half Duplex Capable */
-#define MII_AR_10T_FD_CAPS				0x0040	/* 10T   Full Duplex Capable */
-#define MII_AR_100TX_HD_CAPS				0x0080	/* 100TX Half Duplex Capable */
-#define MII_AR_100TX_FD_CAPS				0x0100	/* 100TX Full Duplex Capable */
-#define MII_AR_100T4_CAPS				0x0200	/* 100T4 Capable */
-#define MII_AR_PAUSE					0x0400	/* Pause operation desired */
-#define MII_AR_ASM_DIR					0x0800	/* Asymmetric Pause Direction bit */
-#define MII_AR_REMOTE_FAULT				0x2000	/* Remote Fault detected */
-#define MII_AR_NEXT_PAGE				0x8000	/* Next Page ability supported */
-#define MII_AR_SPEED_MASK				0x01E0
-#define MII_AR_DEFAULT_CAP_MASK				0x0DE0
-
-/* 1000BASE-T Control Register */
-#define MII_AT001_CR_1000T_HD_CAPS			0x0100	/* Advertise 1000T HD capa=
bility */
-#define MII_AT001_CR_1000T_FD_CAPS			0x0200	/* Advertise 1000T FD capa=
bility  */
-#define MII_AT001_CR_1000T_REPEATER_DTE			0x0400	/* 1=3DRepeater/switc=
h device port, 0=3DDTE device */
-#define MII_AT001_CR_1000T_MS_VALUE			0x0800	/* 1=3DConfigure PHY as M=
aster, 0=3DConfigure PHY as Slave */
-#define MII_AT001_CR_1000T_MS_ENABLE			0x1000	/* 1=3DMaster/Slave manu=
al config value, 0=3DAutomatic Master/Slave config */
-#define MII_AT001_CR_1000T_TEST_MODE_NORMAL		0x0000	/* Normal Operatio=
n */
-#define MII_AT001_CR_1000T_TEST_MODE_1			0x2000	/* Transmit Waveform t=
est */
-#define MII_AT001_CR_1000T_TEST_MODE_2			0x4000	/* Master Transmit Jit=
ter test */
-#define MII_AT001_CR_1000T_TEST_MODE_3			0x6000	/* Slave Transmit Jitt=
er test */
-#define MII_AT001_CR_1000T_TEST_MODE_4			0x8000	/* Transmitter Distort=
ion test */
-#define MII_AT001_CR_1000T_SPEED_MASK			0x0300
-#define MII_AT001_CR_1000T_DEFAULT_CAP_MASK		0x0300
-
-/* 1000BASE-T Status Register */
-#define MII_AT001_SR_1000T_LP_HD_CAPS			0x0400	/* LP is 1000T HD capab=
le */
-#define MII_AT001_SR_1000T_LP_FD_CAPS			0x0800	/* LP is 1000T FD capab=
le */
-#define MII_AT001_SR_1000T_REMOTE_RX_STATUS		0x1000	/* Remote receiver=
 OK */
-#define MII_AT001_SR_1000T_LOCAL_RX_STATUS		0x2000	/* Local receiver O=
K */
-#define MII_AT001_SR_1000T_MS_CONFIG_RES		0x4000	/* 1=3DLocal TX is Ma=
ster, 0=3DSlave */
-#define MII_AT001_SR_1000T_MS_CONFIG_FAULT		0x8000	/* Master/Slave con=
fig fault */
-#define MII_AT001_SR_1000T_REMOTE_RX_STATUS_SHIFT	12
-#define MII_AT001_SR_1000T_LOCAL_RX_STATUS_SHIFT	13
-
-/* Extended Status Register */
-#define MII_AT001_ESR_1000T_HD_CAPS			0x1000	/* 1000T HD capable */
-#define MII_AT001_ESR_1000T_FD_CAPS			0x2000	/* 1000T FD capable */
-#define MII_AT001_ESR_1000X_HD_CAPS			0x4000	/* 1000X HD capable */
-#define MII_AT001_ESR_1000X_FD_CAPS			0x8000	/* 1000X FD capable */
-
-/* AT001 PHY Specific Control Register */
-#define MII_AT001_PSCR_JABBER_DISABLE			0x0001	/* 1=3DJabber Function =
disabled */
-#define MII_AT001_PSCR_POLARITY_REVERSAL		0x0002	/* 1=3DPolarity Rever=
sal enabled */
-#define MII_AT001_PSCR_SQE_TEST				0x0004	/* 1=3DSQE Test enabled */
-#define MII_AT001_PSCR_MAC_POWERDOWN			0x0008
-#define MII_AT001_PSCR_CLK125_DISABLE			0x0010	/* 1=3DCLK125 low, 0=3D=
CLK125 toggling */
-#define MII_AT001_PSCR_MDI_MANUAL_MODE			0x0000	/* MDI Crossover Mode =
bits 6:5, Manual MDI configuration */
-#define MII_AT001_PSCR_MDIX_MANUAL_MODE			0x0020	/* Manual MDIX config=
uration */
-#define MII_AT001_PSCR_AUTO_X_1000T			0x0040	/* 1000BASE-T: Auto cross=
over, 100BASE-TX/10BASE-T: MDI Mode */
-#define MII_AT001_PSCR_AUTO_X_MODE			0x0060	/* Auto crossover enabled =
all speeds. */
-#define MII_AT001_PSCR_10BT_EXT_DIST_ENABLE		0x0080	/* 1=3DEnable Exte=
nded 10BASE-T distance (Lower 10BASE-T RX Threshold), 0=3DNormal 10BASE=
-T RX Threshold */
-#define MII_AT001_PSCR_MII_5BIT_ENABLE			0x0100	/* 1=3D5-Bit interface=
 in 100BASE-TX, 0=3DMII interface in 100BASE-TX */
-#define MII_AT001_PSCR_SCRAMBLER_DISABLE		0x0200	/* 1=3DScrambler disa=
ble */
-#define MII_AT001_PSCR_FORCE_LINK_GOOD			0x0400	/* 1=3DForce link good=
 */
-#define MII_AT001_PSCR_ASSERT_CRS_ON_TX			0x0800	/* 1=3DAssert CRS on =
Transmit */
-#define MII_AT001_PSCR_POLARITY_REVERSAL_SHIFT		1
-#define MII_AT001_PSCR_AUTO_X_MODE_SHIFT		5
-#define MII_AT001_PSCR_10BT_EXT_DIST_ENABLE_SHIFT	7
-
-/* AT001 PHY Specific Status Register */
-#define MII_AT001_PSSR_SPD_DPLX_RESOLVED		0x0800	/* 1=3DSpeed & Duplex=
 resolved */
-#define MII_AT001_PSSR_DPLX				0x2000	/* 1=3DDuplex 0=3DHalf Duplex */
-#define MII_AT001_PSSR_SPEED				0xC000	/* Speed, bits 14:15 */
-#define MII_AT001_PSSR_10MBS				0x0000	/* 00=3D10Mbs */
-#define MII_AT001_PSSR_100MBS				0x4000	/* 01=3D100Mbs */
-#define MII_AT001_PSSR_1000MBS				0x8000	/* 10=3D1000Mbs */
-
-/* PCI Command Register Bit Definitions */
-#define PCI_REG_COMMAND					0x04	/* PCI Command Register */
-#define CMD_IO_SPACE					0x0001
-#define CMD_MEMORY_SPACE				0x0002
-#define CMD_BUS_MASTER					0x0004
-
-/* Wake Up Filter Control */
-#define ATL1_WUFC_LNKC	0x00000001	/* Link Status Change Wakeup Enable =
*/
-#define ATL1_WUFC_MAG	0x00000002	/* Magic Packet Wakeup Enable */
-#define ATL1_WUFC_EX	0x00000004	/* Directed Exact Wakeup Enable */
-#define ATL1_WUFC_MC	0x00000008	/* Multicast Wakeup Enable */
-#define ATL1_WUFC_BC	0x00000010	/* Broadcast Wakeup Enable */
-
-/* Error Codes */
-#define ATL1_SUCCESS			0
-#define ATL1_ERR_EEPROM			1
-#define ATL1_ERR_PHY			2
-#define ATL1_ERR_CONFIG			3
-#define ATL1_ERR_PARAM			4
-#define ATL1_ERR_MAC_TYPE		5
-#define ATL1_ERR_PHY_TYPE		6
-#define ATL1_ERR_PHY_SPEED		7
-#define ATL1_ERR_PHY_RES		8
-
-#define SPEED_0		0xffff
-#define SPEED_10	10
-#define SPEED_100	100
-#define SPEED_1000	1000
-#define HALF_DUPLEX	1
-#define FULL_DUPLEX	2
-
-#define MEDIA_TYPE_AUTO_SENSOR	0
-#define MEDIA_TYPE_1000M_FULL	1
-#define MEDIA_TYPE_100M_FULL	2
-#define MEDIA_TYPE_100M_HALF	3
-#define MEDIA_TYPE_10M_FULL	4
-#define MEDIA_TYPE_10M_HALF	5
-
-#define ADVERTISE_10_HALF		0x0001
-#define ADVERTISE_10_FULL		0x0002
-#define ADVERTISE_100_HALF		0x0004
-#define ADVERTISE_100_FULL		0x0008
-#define ADVERTISE_1000_HALF		0x0010
-#define ADVERTISE_1000_FULL		0x0020
-#define AUTONEG_ADVERTISE_SPEED_DEFAULT	0x002F	/* Everything but 1000-=
Half */
-#define AUTONEG_ADVERTISE_10_100_ALL	0x000F	/* All 10/100 speeds */
-#define AUTONEG_ADVERTISE_10_ALL	0x0003	/* 10Mbps Full & Half speeds *=
/
-
-#define MAX_JUMBO_FRAME_SIZE		0x2800
-
-#define PHY_AUTO_NEG_TIME	45	/* 4.5 Seconds */
-#define PHY_FORCE_TIME		20	/* 2.0 Seconds */
-
-/* For checksumming , the sum of all words in the EEPROM should equal =
0xBABA */
-#define EEPROM_SUM		0xBABA
-
-#define ATL1_EEDUMP_LEN		48
-
-/* Statistics counters collected by the MAC */
-struct stats_msg_block {
-	/* rx */
-	u32 rx_ok;		/* The number of good packet received. */
-	u32 rx_bcast;		/* The number of good broadcast packet received. */
-	u32 rx_mcast;		/* The number of good multicast packet received. */
-	u32 rx_pause;		/* The number of Pause packet received. */
-	u32 rx_ctrl;		/* The number of Control packet received other than Pau=
se frame. */
-	u32 rx_fcs_err;		/* The number of packets with bad FCS. */
-	u32 rx_len_err;		/* The number of packets with mismatch of length fie=
ld and actual size. */
-	u32 rx_byte_cnt;	/* The number of bytes of good packet received. FCS =
is NOT included. */
-	u32 rx_runt;		/* The number of packets received that are less than 64=
 byte long and with good FCS. */
-	u32 rx_frag;		/* The number of packets received that are less than 64=
 byte long and with bad FCS. */
-	u32 rx_sz_64;		/* The number of good and bad packets received that ar=
e 64 byte long. */
-	u32 rx_sz_65_127;	/* The number of good and bad packets received that=
 are between 65 and 127-byte long. */
-	u32 rx_sz_128_255;	/* The number of good and bad packets received tha=
t are between 128 and 255-byte long. */
-	u32 rx_sz_256_511;	/* The number of good and bad packets received tha=
t are between 256 and 511-byte long. */
-	u32 rx_sz_512_1023;	/* The number of good and bad packets received th=
at are between 512 and 1023-byte long. */
-	u32 rx_sz_1024_1518;	/* The number of good and bad packets received t=
hat are between 1024 and 1518-byte long. */
-	u32 rx_sz_1519_max;	/* The number of good and bad packets received th=
at are between 1519-byte and MTU. */
-	u32 rx_sz_ov;		/* The number of good and bad packets received that ar=
e more than MTU size =C5=A1C truncated by Selene. */
-	u32 rx_rxf_ov;		/* The number of frame dropped due to occurrence of R=
X FIFO overflow. */
-	u32 rx_rrd_ov;		/* The number of frame dropped due to occurrence of R=
RD overflow. */
-	u32 rx_align_err;	/* Alignment Error */
-	u32 rx_bcast_byte_cnt;	/* The byte count of broadcast packet received=
, excluding FCS. */
-	u32 rx_mcast_byte_cnt;	/* The byte count of multicast packet received=
, excluding FCS. */
-	u32 rx_err_addr;	/* The number of packets dropped due to address filt=
ering. */
-
-	/* tx */
-	u32 tx_ok;		/* The number of good packet transmitted. */
-	u32 tx_bcast;		/* The number of good broadcast packet transmitted. */
-	u32 tx_mcast;		/* The number of good multicast packet transmitted. */
-	u32 tx_pause;		/* The number of Pause packet transmitted. */
-	u32 tx_exc_defer;	/* The number of packets transmitted with excessive=
 deferral. */
-	u32 tx_ctrl;		/* The number of packets transmitted is a control frame=
, excluding Pause frame. */
-	u32 tx_defer;		/* The number of packets transmitted that is deferred.=
 */
-	u32 tx_byte_cnt;	/* The number of bytes of data transmitted. FCS is N=
OT included. */
-	u32 tx_sz_64;		/* The number of good and bad packets transmitted that=
 are 64 byte long. */
-	u32 tx_sz_65_127;	/* The number of good and bad packets transmitted t=
hat are between 65 and 127-byte long. */
-	u32 tx_sz_128_255;	/* The number of good and bad packets transmitted =
that are between 128 and 255-byte long. */
-	u32 tx_sz_256_511;	/* The number of good and bad packets transmitted =
that are between 256 and 511-byte long. */
-	u32 tx_sz_512_1023;	/* The number of good and bad packets transmitted=
 that are between 512 and 1023-byte long. */
-	u32 tx_sz_1024_1518;	/* The number of good and bad packets transmitte=
d that are between 1024 and 1518-byte long. */
-	u32 tx_sz_1519_max;	/* The number of good and bad packets transmitted=
 that are between 1519-byte and MTU. */
-	u32 tx_1_col;		/* The number of packets subsequently transmitted succ=
essfully with a single prior collision. */
-	u32 tx_2_col;		/* The number of packets subsequently transmitted succ=
essfully with multiple prior collisions. */
-	u32 tx_late_col;	/* The number of packets transmitted with late colli=
sions. */
-	u32 tx_abort_col;	/* The number of transmit packets aborted due to ex=
cessive collisions. */
-	u32 tx_underrun;	/* The number of transmit packets aborted due to tra=
nsmit FIFO underrun, or TRD FIFO underrun */
-	u32 tx_rd_eop;		/* The number of times that read beyond the EOP into =
the next frame area when TRD was not written timely */
-	u32 tx_len_err;		/* The number of transmit packets with length field =
does NOT match the actual frame size. */
-	u32 tx_trunc;		/* The number of transmit packets truncated due to siz=
e exceeding MTU. */
-	u32 tx_bcast_byte;	/* The byte count of broadcast packet transmitted,=
 excluding FCS. */
-	u32 tx_mcast_byte;	/* The byte count of multicast packet transmitted,=
 excluding FCS. */
-	u32 smb_updated;	/* 1: SMB Updated. This is used by software as the i=
ndication of the statistics update.
-				 * Software should clear this bit as soon as retrieving the statis=
tics information. */
-};
-
-/* Coalescing Message Block */
-struct coals_msg_block {
-	u32 int_stats;		/* interrupt status */
-	u16 rrd_prod_idx;	/* TRD Producer Index. */
-	u16 rfd_cons_idx;	/* RFD Consumer Index. */
-	u16 update;		/* Selene sets this bit every time it DMA the CMB to hos=
t memory.
-				 * Software supposes to clear this bit when CMB information is pro=
cessed. */
-	u16 tpd_cons_idx;	/* TPD Consumer Index. */
-};
-
-/* RRD descriptor */
-struct rx_return_desc {
-	u8 num_buf;		/* Number of RFD buffers used by the received packet */
-	u8 resved;
-	u16 buf_indx;		/* RFD Index of the first buffer */
-	union {
-		u32 valid;
-		struct {
-			u16 rx_chksum;
-			u16 pkt_size;
-		} xsum_sz;
-	} xsz;
-
-	u16 pkt_flg;		/* Packet flags */
-	u16 err_flg;		/* Error flags */
-	u16 resved2;
-	u16 vlan_tag;		/* VLAN TAG */
-};
-
-#define PACKET_FLAG_ETH_TYPE	0x0080
-#define PACKET_FLAG_VLAN_INS	0x0100
-#define PACKET_FLAG_ERR		0x0200
-#define PACKET_FLAG_IPV4	0x0400
-#define PACKET_FLAG_UDP		0x0800
-#define PACKET_FLAG_TCP		0x1000
-#define PACKET_FLAG_BCAST	0x2000
-#define PACKET_FLAG_MCAST	0x4000
-#define PACKET_FLAG_PAUSE	0x8000
-
-#define ERR_FLAG_CRC		0x0001
-#define ERR_FLAG_CODE		0x0002
-#define ERR_FLAG_DRIBBLE	0x0004
-#define ERR_FLAG_RUNT		0x0008
-#define ERR_FLAG_OV		0x0010
-#define ERR_FLAG_TRUNC		0x0020
-#define ERR_FLAG_IP_CHKSUM	0x0040
-#define ERR_FLAG_L4_CHKSUM	0x0080
-#define ERR_FLAG_LEN		0x0100
-#define ERR_FLAG_DES_ADDR	0x0200
-
-/* RFD descriptor */
-struct rx_free_desc {
-	__le64 buffer_addr;	/* Address of the descriptor's data buffer */
-	__le16 buf_len;		/* Size of the receive buffer in host memory, in byt=
e */
-	u16 coalese;		/* Update consumer index to host after the reception of=
 this frame */
-	/* __attribute__ ((packed)) is required */
-} __attribute__ ((packed));
-
-/* tsopu defines */
-#define TSO_PARAM_BUFLEN_MASK           0x3FFF
-#define TSO_PARAM_BUFLEN_SHIFT          0
-#define TSO_PARAM_DMAINT_MASK           0x0001
-#define TSO_PARAM_DMAINT_SHIFT          14
-#define TSO_PARAM_PKTNT_MASK            0x0001
-#define TSO_PARAM_PKTINT_SHIFT          15
-#define TSO_PARAM_VLANTAG_MASK          0xFFFF
-#define TSO_PARAM_VLAN_SHIFT            16
-
-/* tsopl defines */
-#define TSO_PARAM_EOP_MASK              0x0001
-#define TSO_PARAM_EOP_SHIFT             0
-#define TSO_PARAM_COALESCE_MASK         0x0001
-#define TSO_PARAM_COALESCE_SHIFT        1
-#define TSO_PARAM_INSVLAG_MASK          0x0001
-#define TSO_PARAM_INSVLAG_SHIFT         2
-#define TSO_PARAM_CUSTOMCKSUM_MASK      0x0001
-#define TSO_PARAM_CUSTOMCKSUM_SHIFT     3
-#define TSO_PARAM_SEGMENT_MASK          0x0001
-#define TSO_PARAM_SEGMENT_SHIFT         4
-#define TSO_PARAM_IPCKSUM_MASK          0x0001
-#define TSO_PARAM_IPCKSUM_SHIFT         5
-#define TSO_PARAM_TCPCKSUM_MASK         0x0001
-#define TSO_PARAM_TCPCKSUM_SHIFT        6
-#define TSO_PARAM_UDPCKSUM_MASK         0x0001
-#define TSO_PARAM_UDPCKSUM_SHIFT        7
-#define TSO_PARAM_VLANTAGGED_MASK       0x0001
-#define TSO_PARAM_VLANTAGGED_SHIFT      8
-#define TSO_PARAM_ETHTYPE_MASK          0x0001
-#define TSO_PARAM_ETHTYPE_SHIFT         9
-#define TSO_PARAM_IPHL_MASK             0x000F
-#define TSO_PARAM_IPHL_SHIFT            10
-#define TSO_PARAM_TCPHDRLEN_MASK        0x000F
-#define TSO_PARAM_TCPHDRLEN_SHIFT       14
-#define TSO_PARAM_HDRFLAG_MASK          0x0001
-#define TSO_PARAM_HDRFLAG_SHIFT         18
-#define TSO_PARAM_MSS_MASK              0x1FFF
-#define TSO_PARAM_MSS_SHIFT             19
-
-/* csumpu defines */
-#define CSUM_PARAM_BUFLEN_MASK          0x3FFF
-#define CSUM_PARAM_BUFLEN_SHIFT         0
-#define CSUM_PARAM_DMAINT_MASK          0x0001
-#define CSUM_PARAM_DMAINT_SHIFT         14
-#define CSUM_PARAM_PKTINT_MASK          0x0001
-#define CSUM_PARAM_PKTINT_SHIFT         15
-#define CSUM_PARAM_VALANTAG_MASK        0xFFFF
-#define CSUM_PARAM_VALAN_SHIFT          16
-
-/* csumpl defines*/
-#define CSUM_PARAM_EOP_MASK             0x0001
-#define CSUM_PARAM_EOP_SHIFT            0
-#define CSUM_PARAM_COALESCE_MASK        0x0001
-#define CSUM_PARAM_COALESCE_SHIFT       1
-#define CSUM_PARAM_INSVLAG_MASK         0x0001
-#define CSUM_PARAM_INSVLAG_SHIFT        2
-#define CSUM_PARAM_CUSTOMCKSUM_MASK     0x0001
-#define CSUM_PARAM_CUSTOMCKSUM_SHIFT    3
-#define CSUM_PARAM_SEGMENT_MASK         0x0001
-#define CSUM_PARAM_SEGMENT_SHIFT        4
-#define CSUM_PARAM_IPCKSUM_MASK         0x0001
-#define CSUM_PARAM_IPCKSUM_SHIFT        5
-#define CSUM_PARAM_TCPCKSUM_MASK        0x0001
-#define CSUM_PARAM_TCPCKSUM_SHIFT       6
-#define CSUM_PARAM_UDPCKSUM_MASK        0x0001
-#define CSUM_PARAM_UDPCKSUM_SHIFT       7
-#define CSUM_PARAM_VLANTAGGED_MASK      0x0001
-#define CSUM_PARAM_VLANTAGGED_SHIFT     8
-#define CSUM_PARAM_ETHTYPE_MASK         0x0001
-#define CSUM_PARAM_ETHTYPE_SHIFT        9
-#define CSUM_PARAM_IPHL_MASK            0x000F
-#define CSUM_PARAM_IPHL_SHIFT           10
-#define CSUM_PARAM_PLOADOFFSET_MASK     0x00FF
-#define CSUM_PARAM_PLOADOFFSET_SHIFT    16
-#define CSUM_PARAM_XSUMOFFSET_MASK      0x00FF
-#define CSUM_PARAM_XSUMOFFSET_SHIFT     24
-
-/* TPD descriptor */
-struct tso_param {
-        /* The order of these declarations is important -- don't chang=
e it */
-        u32 tsopu;      /* tso_param upper word */
-        u32 tsopl;      /* tso_param lower word */
-};
-
-struct csum_param {
-        /* The order of these declarations is important -- don't chang=
e it */
-        u32 csumpu;     /* csum_param upper word */
-        u32 csumpl;     /* csum_param lower word */
-};
-
-union tpd_descr {
-	u64 data;
-	struct csum_param csum;
-	struct tso_param tso;
-};
-
-struct tx_packet_desc {
-	__le64 buffer_addr;
-	union tpd_descr desc;
-};
-
-/* DMA Order Settings */
-enum atl1_dma_order {
-	atl1_dma_ord_in =3D 1,
-	atl1_dma_ord_enh =3D 2,
-	atl1_dma_ord_out =3D 4
-};
-
-enum atl1_dma_rcb {
-	atl1_rcb_64 =3D 0,
-	atl1_rcb_128 =3D 1
-};
-
-enum atl1_dma_req_block {
-	atl1_dma_req_128 =3D 0,
-	atl1_dma_req_256 =3D 1,
-	atl1_dma_req_512 =3D 2,
-	atl1_dma_req_1024 =3D 3,
-	atl1_dma_req_2048 =3D 4,
-	atl1_dma_req_4096 =3D 5
-};
-
-struct atl1_spi_flash_dev {
-	const char *manu_name;	/* manufacturer id */
-	/* op-code */
-	u8 cmd_wrsr;
-	u8 cmd_read;
-	u8 cmd_program;
-	u8 cmd_wren;
-	u8 cmd_wrdi;
-	u8 cmd_rdsr;
-	u8 cmd_rdid;
-	u8 cmd_sector_erase;
-	u8 cmd_chip_erase;
-};
-
-#endif	/* _ATL1_HW_H_ */
diff --git a/drivers/net/atlx/atl1_param.c b/drivers/net/atlx/atl1_para=
m.c
deleted file mode 100644
index 4246bb9..0000000
--- a/drivers/net/atlx/atl1_param.c
+++ /dev/null
@@ -1,203 +0,0 @@
-/*
- * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
- * Copyright(c) 2006 Chris Snook <csnook@redhat.com>
- * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
- *
- * Derived from Intel e1000 driver
- * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
- *
- * This program is free software; you can redistribute it and/or modif=
y it
- * under the terms of the GNU General Public License as published by t=
he Free
- * Software Foundation; either version 2 of the License, or (at your o=
ption)
- * any later version.
- *
- * This program is distributed in the hope that it will be useful, but=
 WITHOUT
- * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
- * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
- * more details.
- *
- * You should have received a copy of the GNU General Public License a=
long with
- * this program; if not, write to the Free Software Foundation, Inc., =
59
- * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
- */
-
-#include <linux/types.h>
-#include <linux/moduleparam.h>
-#include <linux/pci.h>
-#include "atl1.h"
-
-/*
- * This is the only thing that needs to be changed to adjust the
- * maximum number of ports that the driver can manage.
- */
-#define ATL1_MAX_NIC 4
-
-#define OPTION_UNSET    -1
-#define OPTION_DISABLED 0
-#define OPTION_ENABLED  1
-
-#define ATL1_PARAM_INIT { [0 ... ATL1_MAX_NIC] =3D OPTION_UNSET }
-
-/*
- * Interrupt Moderate Timer in units of 2 us
- *
- * Valid Range: 10-65535
- *
- * Default Value: 100 (200us)
- */
-static int __devinitdata int_mod_timer[ATL1_MAX_NIC+1] =3D ATL1_PARAM_=
INIT;
-static int num_int_mod_timer =3D 0;
-module_param_array_named(int_mod_timer, int_mod_timer, int, &num_int_m=
od_timer, 0);
-MODULE_PARM_DESC(int_mod_timer, "Interrupt moderator timer");
-
-/*
- * flash_vendor
- *
- * Valid Range: 0-2
- *
- * 0 - Atmel
- * 1 - SST
- * 2 - ST
- *
- * Default Value: 0
- */
-static int __devinitdata flash_vendor[ATL1_MAX_NIC+1] =3D ATL1_PARAM_I=
NIT;
-static int num_flash_vendor =3D 0;
-module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_v=
endor, 0);
-MODULE_PARM_DESC(flash_vendor, "SPI flash vendor");
-
-#define DEFAULT_INT_MOD_CNT	100	/* 200us */
-#define MAX_INT_MOD_CNT		65000
-#define MIN_INT_MOD_CNT		50
-
-#define FLASH_VENDOR_DEFAULT	0
-#define FLASH_VENDOR_MIN	0
-#define FLASH_VENDOR_MAX	2
-
-struct atl1_option {
-	enum { enable_option, range_option, list_option } type;
-	char *name;
-	char *err;
-	int def;
-	union {
-		struct {	/* range_option info */
-			int min;
-			int max;
-		} r;
-		struct {	/* list_option info */
-			int nr;
-			struct atl1_opt_list {
-				int i;
-				char *str;
-			} *p;
-		} l;
-	} arg;
-};
-
-static int __devinit atl1_validate_option(int *value, struct atl1_opti=
on *opt, struct pci_dev *pdev)
-{
-	if (*value =3D=3D OPTION_UNSET) {
-		*value =3D opt->def;
-		return 0;
-	}
-
-	switch (opt->type) {
-	case enable_option:
-		switch (*value) {
-		case OPTION_ENABLED:
-			dev_info(&pdev->dev, "%s enabled\n", opt->name);
-			return 0;
-		case OPTION_DISABLED:
-			dev_info(&pdev->dev, "%s disabled\n", opt->name);
-			return 0;
-		}
-		break;
-	case range_option:
-		if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.max) {
-			dev_info(&pdev->dev, "%s set to %i\n", opt->name,
-				*value);
-			return 0;
-		}
-		break;
-	case list_option:{
-			int i;
-			struct atl1_opt_list *ent;
-
-			for (i =3D 0; i < opt->arg.l.nr; i++) {
-				ent =3D &opt->arg.l.p[i];
-				if (*value =3D=3D ent->i) {
-					if (ent->str[0] !=3D '\0')
-						dev_info(&pdev->dev, "%s\n",
-							ent->str);
-					return 0;
-				}
-			}
-		}
-		break;
-
-	default:
-		break;
-	}
-
-	dev_info(&pdev->dev, "invalid %s specified (%i) %s\n",
-		opt->name, *value, opt->err);
-	*value =3D opt->def;
-	return -1;
-}
-
-/*
- * atl1_check_options - Range Checking for Command Line Parameters
- * @adapter: board private structure
- *
- * This routine checks all command line parameters for valid user
- * input.  If an invalid value is given, or if no user specified
- * value exists, a default value is used.  The final value is stored
- * in a variable in the adapter structure.
- */
-void __devinit atl1_check_options(struct atl1_adapter *adapter)
-{
-	struct pci_dev *pdev =3D adapter->pdev;
-	int bd =3D adapter->bd_number;
-	if (bd >=3D ATL1_MAX_NIC) {
-		dev_notice(&pdev->dev, "no configuration for board#%i\n", bd);
-		dev_notice(&pdev->dev, "using defaults for all values\n");
-	}
-	{			/* Interrupt Moderate Timer */
-		struct atl1_option opt =3D {
-			.type =3D range_option,
-			.name =3D "Interrupt Moderator Timer",
-			.err =3D "using default of "
-				__MODULE_STRING(DEFAULT_INT_MOD_CNT),
-			.def =3D DEFAULT_INT_MOD_CNT,
-			.arg =3D {.r =3D
-				{.min =3D MIN_INT_MOD_CNT,.max =3D MAX_INT_MOD_CNT}}
-		};
-		int val;
-		if (num_int_mod_timer > bd) {
-			val =3D int_mod_timer[bd];
-			atl1_validate_option(&val, &opt, pdev);
-			adapter->imt =3D (u16) val;
-		} else
-			adapter->imt =3D (u16) (opt.def);
-	}
-
-	{			/* Flash Vendor */
-		struct atl1_option opt =3D {
-			.type =3D range_option,
-			.name =3D "SPI Flash Vendor",
-			.err =3D "using default of "
-				__MODULE_STRING(FLASH_VENDOR_DEFAULT),
-			.def =3D DEFAULT_INT_MOD_CNT,
-			.arg =3D {.r =3D
-				{.min =3D FLASH_VENDOR_MIN,.max =3D
-				 FLASH_VENDOR_MAX}}
-		};
-		int val;
-		if (num_flash_vendor > bd) {
-			val =3D flash_vendor[bd];
-			atl1_validate_option(&val, &opt, pdev);
-			adapter->hw.flash_vendor =3D (u8) val;
-		} else
-			adapter->hw.flash_vendor =3D (u8) (opt.def);
-	}
-}
diff --git a/drivers/net/atlx/atlx.c b/drivers/net/atlx/atlx.c
new file mode 100644
index 0000000..4186326
--- /dev/null
+++ b/drivers/net/atlx/atlx.c
@@ -0,0 +1,433 @@
+/* atlx.c -- common functions for Attansic network drivers
+ *
+ * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
+ * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
+ * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
+ * Copyright(c) 2007 Atheros Corporation. All rights reserved.
+ *
+ * Derived from Intel e1000 driver
+ * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program; if not, write to the Free Software Foundation, Inc., =
59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+/* Including this file like a header is a temporary hack, I promise. -=
- CHS */
+#ifndef ATLX_C
+#define ATLX_C
+
+#include <linux/device.h>
+#include <linux/errno.h>
+#include <linux/etherdevice.h>
+#include <linux/if.h>
+#include <linux/netdevice.h>
+#include <linux/socket.h>
+#include <linux/sockios.h>
+#include <linux/spinlock.h>
+#include <linux/string.h>
+#include <linux/types.h>
+#include <linux/workqueue.h>
+
+#include "atlx.h"
+
+static struct atlx_spi_flash_dev flash_table[] =3D {
+/*	MFR_NAME  WRSR  READ  PRGM  WREN  WRDI  RDSR  RDID  SEC_ERS CHIP_ER=
S */
+	{"Atmel", 0x00, 0x03, 0x02, 0x06, 0x04, 0x05, 0x15, 0x52,   0x62},
+	{"SST",   0x01, 0x03, 0x02, 0x06, 0x04, 0x05, 0x90, 0x20,   0x60},
+	{"ST",    0x01, 0x03, 0x02, 0x06, 0x04, 0x05, 0xAB, 0xD8,   0xC7},
+};
+
+static int atlx_ioctl(struct net_device *netdev, struct ifreq *ifr, in=
t cmd)
+{
+	switch (cmd) {
+	case SIOCGMIIPHY:
+	case SIOCGMIIREG:
+	case SIOCSMIIREG:
+		return atlx_mii_ioctl(netdev, ifr, cmd);
+	default:
+		return -EOPNOTSUPP;
+	}
+}
+
+/*
+ * atlx_set_mac - Change the Ethernet Address of the NIC
+ * @netdev: network interface device structure
+ * @p: pointer to an address structure
+ *
+ * Returns 0 on success, negative on failure
+ */
+static int atlx_set_mac(struct net_device *netdev, void *p)
+{
+	struct atlx_adapter *adapter =3D netdev_priv(netdev);
+	struct sockaddr *addr =3D p;
+
+	if (netif_running(netdev))
+		return -EBUSY;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
+	memcpy(adapter->hw.mac_addr, addr->sa_data, netdev->addr_len);
+
+	atlx_set_mac_addr(&adapter->hw);
+	return 0;
+}
+
+static void atlx_check_for_link(struct atlx_adapter *adapter)
+{
+	struct net_device *netdev =3D adapter->netdev;
+	u16 phy_data =3D 0;
+
+	spin_lock(&adapter->lock);
+	adapter->phy_timer_pending =3D false;
+	atlx_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
+	atlx_read_phy_reg(&adapter->hw, MII_BMSR, &phy_data);
+	spin_unlock(&adapter->lock);
+
+	/* notify upper layer link down ASAP */
+	if (!(phy_data & BMSR_LSTATUS)) {
+		/* Link Down */
+		if (netif_carrier_ok(netdev)) {
+			/* old link state: Up */
+			dev_info(&adapter->pdev->dev, "%s link is down\n",
+				netdev->name);
+			adapter->link_speed =3D SPEED_0;
+			netif_carrier_off(netdev);
+			netif_stop_queue(netdev);
+		}
+	}
+	schedule_work(&adapter->link_chg_task);
+}
+
+/*
+ * atlx_set_multi - Multicast and Promiscuous mode set
+ * @netdev: network interface device structure
+ *
+ * The set_multi entry point is called whenever the multicast address
+ * list or the network interface flags are updated.  This routine is
+ * responsible for configuring the hardware for proper multicast,
+ * promiscuous mode, and all-multi behavior.
+ */
+static void atlx_set_multi(struct net_device *netdev)
+{
+	struct atlx_adapter *adapter =3D netdev_priv(netdev);
+	struct atlx_hw *hw =3D &adapter->hw;
+	struct dev_mc_list *mc_ptr;
+	u32 rctl;
+	u32 hash_value;
+
+	/* Check for Promiscuous and All Multicast modes */
+	rctl =3D ioread32(hw->hw_addr + REG_MAC_CTRL);
+	if (netdev->flags & IFF_PROMISC)
+		rctl |=3D MAC_CTRL_PROMIS_EN;
+	else if (netdev->flags & IFF_ALLMULTI) {
+		rctl |=3D MAC_CTRL_MC_ALL_EN;
+		rctl &=3D ~MAC_CTRL_PROMIS_EN;
+	} else
+		rctl &=3D ~(MAC_CTRL_PROMIS_EN | MAC_CTRL_MC_ALL_EN);
+
+	iowrite32(rctl, hw->hw_addr + REG_MAC_CTRL);
+
+	/* clear the old settings from the multicast hash table */
+	iowrite32(0, hw->hw_addr + REG_RX_HASH_TABLE);
+	iowrite32(0, (hw->hw_addr + REG_RX_HASH_TABLE) + (1 << 2));
+
+	/* compute mc addresses' hash value ,and put it into hash table */
+	for (mc_ptr =3D netdev->mc_list; mc_ptr; mc_ptr =3D mc_ptr->next) {
+		hash_value =3D atlx_hash_mc_addr(hw, mc_ptr->dmi_addr);
+		atlx_hash_set(hw, hash_value);
+	}
+}
+
+/*
+ * atlx_irq_enable - Enable default interrupt generation settings
+ * @adapter: board private structure
+ */
+static void atlx_irq_enable(struct atlx_adapter *adapter)
+{
+	iowrite32(IMR_NORMAL_MASK, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
+}
+
+/*
+ * atlx_irq_disable - Mask off interrupt generation on the NIC
+ * @adapter: board private structure
+ */
+static void atlx_irq_disable(struct atlx_adapter *adapter)
+{
+	iowrite32(0, adapter->hw.hw_addr + REG_IMR);
+	ioread32(adapter->hw.hw_addr + REG_IMR);
+	synchronize_irq(adapter->pdev->irq);
+}
+
+static void atlx_clear_phy_int(struct atlx_adapter *adapter)
+{
+	u16 phy_data;
+	unsigned long flags;
+
+	spin_lock_irqsave(&adapter->lock, flags);
+	atlx_read_phy_reg(&adapter->hw, 19, &phy_data);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
+/*
+ * atlx_get_stats - Get System Network Statistics
+ * @netdev: network interface device structure
+ *
+ * Returns the address of the device statistics structure.
+ * The statistics are actually updated from the timer callback.
+ */
+static struct net_device_stats *atlx_get_stats(struct net_device *netd=
ev)
+{
+	struct atlx_adapter *adapter =3D netdev_priv(netdev);
+	return &adapter->net_stats;
+}
+
+/*
+ * atlx_tx_timeout - Respond to a Tx Hang
+ * @netdev: network interface device structure
+ */
+static void atlx_tx_timeout(struct net_device *netdev)
+{
+	struct atlx_adapter *adapter =3D netdev_priv(netdev);
+	/* Do the reset outside of interrupt context */
+	schedule_work(&adapter->tx_timeout_task);
+}
+
+/*
+ * atlx_link_chg_task - deal with link change event Out of interrupt c=
ontext
+ */
+static void atlx_link_chg_task(struct work_struct *work)
+{
+	struct atlx_adapter *adapter;
+	unsigned long flags;
+
+	adapter =3D container_of(work, struct atlx_adapter, link_chg_task);
+
+	spin_lock_irqsave(&adapter->lock, flags);
+	atlx_check_link(adapter);
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
+static void atlx_vlan_rx_register(struct net_device *netdev,
+	struct vlan_group *grp)
+{
+	struct atlx_adapter *adapter =3D netdev_priv(netdev);
+	unsigned long flags;
+	u32 ctrl;
+
+	spin_lock_irqsave(&adapter->lock, flags);
+	/* atlx_irq_disable(adapter); FIXME: confirm/remove */
+	adapter->vlgrp =3D grp;
+
+	if (grp) {
+		/* enable VLAN tag insert/strip */
+		ctrl =3D ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+		ctrl |=3D MAC_CTRL_RMV_VLAN;
+		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+	} else {
+		/* disable VLAN tag insert/strip */
+		ctrl =3D ioread32(adapter->hw.hw_addr + REG_MAC_CTRL);
+		ctrl &=3D ~MAC_CTRL_RMV_VLAN;
+		iowrite32(ctrl, adapter->hw.hw_addr + REG_MAC_CTRL);
+	}
+
+	/* atlx_irq_enable(adapter); FIXME */
+	spin_unlock_irqrestore(&adapter->lock, flags);
+}
+
+static void atlx_restore_vlan(struct atlx_adapter *adapter)
+{
+	atlx_vlan_rx_register(adapter->netdev, adapter->vlgrp);
+}
+
+/*
+ * This is the only thing that needs to be changed to adjust the
+ * maximum number of ports that the driver can manage.
+ */
+#define ATL1_MAX_NIC 4
+
+#define OPTION_UNSET    -1
+#define OPTION_DISABLED 0
+#define OPTION_ENABLED  1
+
+#define ATL1_PARAM_INIT { [0 ... ATL1_MAX_NIC] =3D OPTION_UNSET }
+
+/*
+ * Interrupt Moderate Timer in units of 2 us
+ *
+ * Valid Range: 10-65535
+ *
+ * Default Value: 100 (200us)
+ */
+static int __devinitdata int_mod_timer[ATL1_MAX_NIC+1] =3D ATL1_PARAM_=
INIT;
+static int num_int_mod_timer;
+module_param_array_named(int_mod_timer, int_mod_timer, int,
+	&num_int_mod_timer, 0);
+MODULE_PARM_DESC(int_mod_timer, "Interrupt moderator timer");
+
+/*
+ * flash_vendor
+ *
+ * Valid Range: 0-2
+ *
+ * 0 - Atmel
+ * 1 - SST
+ * 2 - ST
+ *
+ * Default Value: 0
+ */
+static int __devinitdata flash_vendor[ATL1_MAX_NIC+1] =3D ATL1_PARAM_I=
NIT;
+static int num_flash_vendor;
+module_param_array_named(flash_vendor, flash_vendor, int, &num_flash_v=
endor, 0);
+MODULE_PARM_DESC(flash_vendor, "SPI flash vendor");
+
+#define DEFAULT_INT_MOD_CNT	100	/* 200us */
+#define MAX_INT_MOD_CNT		65000
+#define MIN_INT_MOD_CNT		50
+
+#define FLASH_VENDOR_DEFAULT	0
+#define FLASH_VENDOR_MIN	0
+#define FLASH_VENDOR_MAX	2
+
+struct atl1_option {
+	enum { enable_option, range_option, list_option } type;
+	char *name;
+	char *err;
+	int def;
+	union {
+		struct {	/* range_option info */
+			int min;
+			int max;
+		} r;
+		struct {	/* list_option info */
+			int nr;
+			struct atl1_opt_list {
+				int i;
+				char *str;
+			} *p;
+		} l;
+	} arg;
+};
+
+static int __devinit atl1_validate_option(int *value, struct atl1_opti=
on *opt,
+	struct pci_dev *pdev)
+{
+	if (*value =3D=3D OPTION_UNSET) {
+		*value =3D opt->def;
+		return 0;
+	}
+
+	switch (opt->type) {
+	case enable_option:
+		switch (*value) {
+		case OPTION_ENABLED:
+			dev_info(&pdev->dev, "%s enabled\n", opt->name);
+			return 0;
+		case OPTION_DISABLED:
+			dev_info(&pdev->dev, "%s disabled\n", opt->name);
+			return 0;
+		}
+		break;
+	case range_option:
+		if (*value >=3D opt->arg.r.min && *value <=3D opt->arg.r.max) {
+			dev_info(&pdev->dev, "%s set to %i\n", opt->name,
+				*value);
+			return 0;
+		}
+		break;
+	case list_option:{
+			int i;
+			struct atl1_opt_list *ent;
+
+			for (i =3D 0; i < opt->arg.l.nr; i++) {
+				ent =3D &opt->arg.l.p[i];
+				if (*value =3D=3D ent->i) {
+					if (ent->str[0] !=3D '\0')
+						dev_info(&pdev->dev, "%s\n",
+							ent->str);
+					return 0;
+				}
+			}
+		}
+		break;
+
+	default:
+		break;
+	}
+
+	dev_info(&pdev->dev, "invalid %s specified (%i) %s\n",
+		opt->name, *value, opt->err);
+	*value =3D opt->def;
+	return -1;
+}
+
+/*
+ * atl1_check_options - Range Checking for Command Line Parameters
+ * @adapter: board private structure
+ *
+ * This routine checks all command line parameters for valid user
+ * input.  If an invalid value is given, or if no user specified
+ * value exists, a default value is used.  The final value is stored
+ * in a variable in the adapter structure.
+ */
+void __devinit atl1_check_options(struct atl1_adapter *adapter)
+{
+	struct pci_dev *pdev =3D adapter->pdev;
+	int bd =3D adapter->bd_number;
+	if (bd >=3D ATL1_MAX_NIC) {
+		dev_notice(&pdev->dev, "no configuration for board#%i\n", bd);
+		dev_notice(&pdev->dev, "using defaults for all values\n");
+	}
+	{			/* Interrupt Moderate Timer */
+		struct atl1_option opt =3D {
+			.type =3D range_option,
+			.name =3D "Interrupt Moderator Timer",
+			.err =3D "using default of "
+				__MODULE_STRING(DEFAULT_INT_MOD_CNT),
+			.def =3D DEFAULT_INT_MOD_CNT,
+			.arg =3D {.r =3D {.min =3D MIN_INT_MOD_CNT,
+					.max =3D MAX_INT_MOD_CNT} }
+		};
+		int val;
+		if (num_int_mod_timer > bd) {
+			val =3D int_mod_timer[bd];
+			atl1_validate_option(&val, &opt, pdev);
+			adapter->imt =3D (u16) val;
+		} else
+			adapter->imt =3D (u16) (opt.def);
+	}
+
+	{			/* Flash Vendor */
+		struct atl1_option opt =3D {
+			.type =3D range_option,
+			.name =3D "SPI Flash Vendor",
+			.err =3D "using default of "
+				__MODULE_STRING(FLASH_VENDOR_DEFAULT),
+			.def =3D DEFAULT_INT_MOD_CNT,
+			.arg =3D {.r =3D {.min =3D FLASH_VENDOR_MIN,
+					.max =3D FLASH_VENDOR_MAX} }
+		};
+		int val;
+		if (num_flash_vendor > bd) {
+			val =3D flash_vendor[bd];
+			atl1_validate_option(&val, &opt, pdev);
+			adapter->hw.flash_vendor =3D (u8) val;
+		} else
+			adapter->hw.flash_vendor =3D (u8) (opt.def);
+	}
+}
+
+#endif /* ATLX_C */
diff --git a/drivers/net/atlx/atlx.h b/drivers/net/atlx/atlx.h
new file mode 100644
index 0000000..3be7c09
--- /dev/null
+++ b/drivers/net/atlx/atlx.h
@@ -0,0 +1,506 @@
+/* atlx_hw.h -- common hardware definitions for Attansic network drive=
rs
+ *
+ * Copyright(c) 2005 - 2006 Attansic Corporation. All rights reserved.
+ * Copyright(c) 2006 - 2007 Chris Snook <csnook@redhat.com>
+ * Copyright(c) 2006 Jay Cliburn <jcliburn@gmail.com>
+ * Copyright(c) 2007 Atheros Corporation. All rights reserved.
+ *
+ * Derived from Intel e1000 driver
+ * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but=
 WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY =
or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public Licen=
se for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License a=
long with
+ * this program; if not, write to the Free Software Foundation, Inc., =
59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ */
+
+#ifndef ATLX_H
+#define ATLX_H
+
+#include <linux/module.h>
+#include <linux/types.h>
+
+#define ATLX_DRIVER_VERSION "2.1.1"
+MODULE_AUTHOR("Xiong Huang <xiong.huang@atheros.com>, \
+	Chris Snook <csnook@redhat.com>, Jay Cliburn <jcliburn@gmail.com>");
+MODULE_LICENSE("GPL");
+MODULE_VERSION(ATLX_DRIVER_VERSION);
+
+#define ATLX_ERR_PHY			2
+#define ATLX_ERR_PHY_SPEED		7
+#define ATLX_ERR_PHY_RES		8
+
+#define SPEED_0				0xffff
+#define SPEED_10			10
+#define SPEED_100			100
+#define SPEED_1000			1000
+#define HALF_DUPLEX			1
+#define FULL_DUPLEX			2
+
+#define MEDIA_TYPE_AUTO_SENSOR		0
+
+/* register definitions */
+#define REG_PM_CTRLSTAT			0x44
+
+#define REG_PCIE_CAP_LIST		0x58
+
+#define REG_VPD_CAP			0x6C
+#define VPD_CAP_ID_MASK			0xFF
+#define VPD_CAP_ID_SHIFT		0
+#define VPD_CAP_NEXT_PTR_MASK		0xFF
+#define VPD_CAP_NEXT_PTR_SHIFT		8
+#define VPD_CAP_VPD_ADDR_MASK		0x7FFF
+#define VPD_CAP_VPD_ADDR_SHIFT		16
+#define VPD_CAP_VPD_FLAG		0x80000000
+
+#define REG_VPD_DATA			0x70
+
+#define REG_SPI_FLASH_CTRL		0x200
+#define SPI_FLASH_CTRL_STS_NON_RDY	0x1
+#define SPI_FLASH_CTRL_STS_WEN		0x2
+#define SPI_FLASH_CTRL_STS_WPEN		0x80
+#define SPI_FLASH_CTRL_DEV_STS_MASK	0xFF
+#define SPI_FLASH_CTRL_DEV_STS_SHIFT	0
+#define SPI_FLASH_CTRL_INS_MASK		0x7
+#define SPI_FLASH_CTRL_INS_SHIFT	8
+#define SPI_FLASH_CTRL_START		0x800
+#define SPI_FLASH_CTRL_EN_VPD		0x2000
+#define SPI_FLASH_CTRL_LDSTART		0x8000
+#define SPI_FLASH_CTRL_CS_HI_MASK	0x3
+#define SPI_FLASH_CTRL_CS_HI_SHIFT	16
+#define SPI_FLASH_CTRL_CS_HOLD_MASK	0x3
+#define SPI_FLASH_CTRL_CS_HOLD_SHIFT	18
+#define SPI_FLASH_CTRL_CLK_LO_MASK	0x3
+#define SPI_FLASH_CTRL_CLK_LO_SHIFT	20
+#define SPI_FLASH_CTRL_CLK_HI_MASK	0x3
+#define SPI_FLASH_CTRL_CLK_HI_SHIFT	22
+#define SPI_FLASH_CTRL_CS_SETUP_MASK	0x3
+#define SPI_FLASH_CTRL_CS_SETUP_SHIFT	24
+#define SPI_FLASH_CTRL_EROM_PGSZ_MASK	0x3
+#define SPI_FLASH_CTRL_EROM_PGSZ_SHIFT	26
+#define SPI_FLASH_CTRL_WAIT_READY	0x10000000
+
+#define REG_SPI_ADDR			0x204
+
+#define REG_SPI_DATA			0x208
+
+#define REG_SPI_FLASH_CONFIG		0x20C
+#define SPI_FLASH_CONFIG_LD_ADDR_MASK	0xFFFFFF
+#define SPI_FLASH_CONFIG_LD_ADDR_SHIFT	0
+#define SPI_FLASH_CONFIG_VPD_ADDR_MASK	0x3
+#define SPI_FLASH_CONFIG_VPD_ADDR_SHIFT	24
+#define SPI_FLASH_CONFIG_LD_EXIST	0x4000000
+
+#define REG_SPI_FLASH_OP_PROGRAM	0x210
+#define REG_SPI_FLASH_OP_SC_ERASE	0x211
+#define REG_SPI_FLASH_OP_CHIP_ERASE	0x212
+#define REG_SPI_FLASH_OP_RDID		0x213
+#define REG_SPI_FLASH_OP_WREN		0x214
+#define REG_SPI_FLASH_OP_RDSR		0x215
+#define REG_SPI_FLASH_OP_WRSR		0x216
+#define REG_SPI_FLASH_OP_READ		0x217
+
+#define REG_TWSI_CTRL			0x218
+#define TWSI_CTRL_LD_OFFSET_MASK	0xFF
+#define TWSI_CTRL_LD_OFFSET_SHIFT	0
+#define TWSI_CTRL_LD_SLV_ADDR_MASK	0x7
+#define TWSI_CTRL_LD_SLV_ADDR_SHIFT	8
+#define TWSI_CTRL_SW_LDSTART		0x800
+#define TWSI_CTRL_HW_LDSTART		0x1000
+#define TWSI_CTRL_SMB_SLV_ADDR_MASK	0x7F
+#define TWSI_CTRL_SMB_SLV_ADDR_SHIFT	15
+#define TWSI_CTRL_LD_EXIST		0x400000
+#define TWSI_CTRL_READ_FREQ_SEL_MASK	0x3
+#define TWSI_CTRL_READ_FREQ_SEL_SHIFT	23
+#define TWSI_CTRL_FREQ_SEL_100K		0
+#define TWSI_CTRL_FREQ_SEL_200K		1
+#define TWSI_CTRL_FREQ_SEL_300K		2
+#define TWSI_CTRL_FREQ_SEL_400K		3
+#define TWSI_CTRL_SMB_SLV_ADDR		/* FIXME: define or remove */
+#define TWSI_CTRL_WRITE_FREQ_SEL_MASK	0x3
+#define TWSI_CTRL_WRITE_FREQ_SEL_SHIFT	24
+
+#define REG_PCIE_DEV_MISC_CTRL			0x21C
+#define PCIE_DEV_MISC_CTRL_EXT_PIPE		0x2
+#define PCIE_DEV_MISC_CTRL_RETRY_BUFDIS		0x1
+#define PCIE_DEV_MISC_CTRL_SPIROM_EXIST		0x4
+#define PCIE_DEV_MISC_CTRL_SERDES_ENDIAN	0x8
+#define PCIE_DEV_MISC_CTRL_SERDES_SEL_DIN	0x10
+
+#define REG_PCIE_PHYMISC		0x1000
+#define PCIE_PHYMISC_FORCE_RCV_DET	0x4
+
+#define REG_PCIE_DLL_TX_CTRL1		0x1104
+#define PCIE_DLL_TX_CTRL1_SEL_NOR_CLK	0x400
+#define PCIE_DLL_TX_CTRL1_DEF		0x568
+
+#define REG_LTSSM_TEST_MODE		0x12FC
+#define LTSSM_TEST_MODE_DEF		0x6500
+
+/* Master Control Register */
+#define REG_MASTER_CTRL			0x1400
+#define MASTER_CTRL_SOFT_RST		0x1
+#define MASTER_CTRL_MTIMER_EN		0x2
+#define MASTER_CTRL_ITIMER_EN		0x4
+#define MASTER_CTRL_MANUAL_INT		0x8
+#define MASTER_CTRL_REV_NUM_SHIFT	16
+#define MASTER_CTRL_REV_NUM_MASK	0xFF
+#define MASTER_CTRL_DEV_ID_SHIFT	24
+#define MASTER_CTRL_DEV_ID_MASK		0xFF
+
+/* Timer Initial Value Register */
+#define REG_MANUAL_TIMER_INIT		0x1404
+
+/* IRQ Moderator Timer Initial Value Register */
+#define REG_IRQ_MODU_TIMER_INIT		0x1408
+
+#define REG_PHY_ENABLE			0x140C
+
+/* IRQ Anti-Lost Timer Initial Value Register */
+#define REG_CMBDISDMA_TIMER		0x140E
+
+/* Block IDLE Status Register */
+#define REG_IDLE_STATUS			0x1410
+
+/* MDIO Control Register */
+#define REG_MDIO_CTRL			0x1414
+#define MDIO_DATA_MASK			0xFFFF
+#define MDIO_DATA_SHIFT			0
+#define MDIO_REG_ADDR_MASK		0x1F
+#define MDIO_REG_ADDR_SHIFT		16
+#define MDIO_RW				0x200000
+#define MDIO_SUP_PREAMBLE		0x400000
+#define MDIO_START			0x800000
+#define MDIO_CLK_SEL_SHIFT		24
+#define MDIO_CLK_25_4			0
+#define MDIO_CLK_25_6			2
+#define MDIO_CLK_25_8			3
+#define MDIO_CLK_25_10			4
+#define MDIO_CLK_25_14			5
+#define MDIO_CLK_25_20			6
+#define MDIO_CLK_25_28			7
+#define MDIO_BUSY			0x8000000
+
+/* MII PHY Status Register */
+#define REG_PHY_STATUS			0x1418
+
+/* BIST Control and Status Register0 (for the Packet Memory) */
+#define REG_BIST0_CTRL			0x141C
+#define BIST0_NOW			0x1
+#define BIST0_SRAM_FAIL			0x2
+#define BIST0_FUSE_FLAG			0x4
+#define REG_BIST1_CTRL			0x1420
+#define BIST1_NOW			0x1
+#define BIST1_SRAM_FAIL			0x2
+#define BIST1_FUSE_FLAG			0x4
+
+/* SerDes Lock Detect Control and Status Register */
+#define REG_SERDES_LOCK			0x1424
+#define SERDES_LOCK_DETECT		1
+#define SERDES_LOCK_DETECT_EN		2
+
+/* MAC Control Register */
+#define REG_MAC_CTRL			0x1480
+#define MAC_CTRL_TX_EN			1
+#define MAC_CTRL_RX_EN			2
+#define MAC_CTRL_TX_FLOW		4
+#define MAC_CTRL_RX_FLOW		8
+#define MAC_CTRL_LOOPBACK		0x10
+#define MAC_CTRL_DUPLX			0x20
+#define MAC_CTRL_ADD_CRC		0x40
+#define MAC_CTRL_PAD			0x80
+#define MAC_CTRL_LENCHK			0x100
+#define MAC_CTRL_HUGE_EN		0x200
+#define MAC_CTRL_PRMLEN_SHIFT		10
+#define MAC_CTRL_PRMLEN_MASK		0xF
+#define MAC_CTRL_RMV_VLAN		0x4000
+#define MAC_CTRL_PROMIS_EN		0x8000
+#define MAC_CTRL_MC_ALL_EN		0x2000000
+#define MAC_CTRL_BC_EN			0x4000000
+
+/* MAC IPG/IFG Control Register */
+#define REG_MAC_IPG_IFG			0x1484
+#define MAC_IPG_IFG_IPGT_SHIFT		0
+#define MAC_IPG_IFG_IPGT_MASK		0x7F
+#define MAC_IPG_IFG_MIFG_SHIFT		8
+#define MAC_IPG_IFG_MIFG_MASK		0xFF
+#define MAC_IPG_IFG_IPGR1_SHIFT		16
+#define MAC_IPG_IFG_IPGR1_MASK		0x7F
+#define MAC_IPG_IFG_IPGR2_SHIFT		24
+#define MAC_IPG_IFG_IPGR2_MASK		0x7F
+
+/* MAC STATION ADDRESS */
+#define REG_MAC_STA_ADDR		0x1488
+
+/* Hash table for multicast address */
+#define REG_RX_HASH_TABLE		0x1490
+
+/* MAC Half-Duplex Control Register */
+#define REG_MAC_HALF_DUPLX_CTRL			0x1498
+#define MAC_HALF_DUPLX_CTRL_LCOL_SHIFT		0
+#define MAC_HALF_DUPLX_CTRL_LCOL_MASK		0x3FF
+#define MAC_HALF_DUPLX_CTRL_RETRY_SHIFT		12
+#define MAC_HALF_DUPLX_CTRL_RETRY_MASK		0xF
+#define MAC_HALF_DUPLX_CTRL_EXC_DEF_EN		0x10000
+#define MAC_HALF_DUPLX_CTRL_NO_BACK_C		0x20000
+#define MAC_HALF_DUPLX_CTRL_NO_BACK_P		0x40000
+#define MAC_HALF_DUPLX_CTRL_ABEBE		0x80000
+#define MAC_HALF_DUPLX_CTRL_ABEBT_SHIFT		20
+#define MAC_HALF_DUPLX_CTRL_ABEBT_MASK		0xF
+#define MAC_HALF_DUPLX_CTRL_JAMIPG_SHIFT	24
+#define MAC_HALF_DUPLX_CTRL_JAMIPG_MASK		0xF
+
+/* Maximum Frame Length Control Register */
+#define REG_MTU				0x149C
+
+/* Wake-On-Lan control register */
+#define REG_WOL_CTRL			0x14A0
+#define WOL_PATTERN_EN			0x1
+#define WOL_PATTERN_PME_EN		0x2
+#define WOL_MAGIC_EN			0x4
+#define WOL_MAGIC_PME_EN		0x8
+#define WOL_LINK_CHG_EN			0x10
+#define WOL_LINK_CHG_PME_EN		0x20
+#define WOL_PATTERN_ST			0x100
+#define WOL_MAGIC_ST			0x200
+#define WOL_LINKCHG_ST			0x400
+#define WOL_PT0_EN			0x10000
+#define WOL_PT1_EN			0x20000
+#define WOL_PT2_EN			0x40000
+#define WOL_PT3_EN			0x80000
+#define WOL_PT4_EN			0x100000
+#define WOL_PT0_MATCH			0x1000000
+#define WOL_PT1_MATCH			0x2000000
+#define WOL_PT2_MATCH			0x4000000
+#define WOL_PT3_MATCH			0x8000000
+#define WOL_PT4_MATCH			0x10000000
+
+/* Internal SRAM Partition Register, high 32 bits */
+#define REG_SRAM_RFD_ADDR		0x1500
+
+/* Descriptor Control register, high 32 bits */
+#define REG_DESC_BASE_ADDR_HI		0x1540
+
+/* Interrupt Status Register */
+#define REG_ISR				0x1600
+#define ISR_UR_DETECTED			0x1000000
+#define ISR_FERR_DETECTED		0x2000000
+#define ISR_NFERR_DETECTED		0x4000000
+#define ISR_CERR_DETECTED		0x8000000
+#define ISR_PHY_LINKDOWN		0x10000000
+#define ISR_DIS_INT			0x80000000
+
+/* Interrupt Mask Register */
+#define REG_IMR				0x1604
+
+#define REG_RFD_RRD_IDX			0x1800
+#define REG_TPD_IDX			0x1804
+
+/* MII definitions */
+
+/* PHY Common Register */
+#define MII_ATLX_CR			0x09
+#define MII_ATLX_SR			0x0A
+#define MII_ATLX_ESR			0x0F
+#define MII_ATLX_PSCR			0x10
+#define MII_ATLX_PSSR			0x11
+
+/* PHY Control Register */
+#define MII_CR_SPEED_SELECT_MSB		0x0040	/* bits 6,13: 10=3D1000, 01=3D=
100,
+						 * 00=3D10
+						 */
+#define MII_CR_COLL_TEST_ENABLE		0x0080	/* Collision test enable */
+#define MII_CR_FULL_DUPLEX		0x0100	/* FDX =3D1, half duplex =3D0 */
+#define MII_CR_RESTART_AUTO_NEG		0x0200	/* Restart auto negotiation */
+#define MII_CR_ISOLATE			0x0400	/* Isolate PHY from MII */
+#define MII_CR_POWER_DOWN		0x0800	/* Power down */
+#define MII_CR_AUTO_NEG_EN		0x1000	/* Auto Neg Enable */
+#define MII_CR_SPEED_SELECT_LSB		0x2000	/* bits 6,13: 10=3D1000, 01=3D=
100,
+						 * 00=3D10
+						 */
+#define MII_CR_LOOPBACK			0x4000	/* 0 =3D normal, 1 =3D loopback */
+#define MII_CR_RESET			0x8000	/* 0 =3D normal, 1 =3D PHY reset */
+#define MII_CR_SPEED_MASK		0x2040
+#define MII_CR_SPEED_1000		0x0040
+#define MII_CR_SPEED_100		0x2000
+#define MII_CR_SPEED_10			0x0000
+
+/* PHY Status Register */
+#define MII_SR_EXTENDED_CAPS		0x0001	/* Ext register capabilities */
+#define MII_SR_JABBER_DETECT		0x0002	/* Jabber Detected */
+#define MII_SR_LINK_STATUS		0x0004	/* Link Status 1 =3D link */
+#define MII_SR_AUTONEG_CAPS		0x0008	/* Auto Neg Capable */
+#define MII_SR_REMOTE_FAULT		0x0010	/* Remote Fault Detect */
+#define MII_SR_AUTONEG_COMPLETE		0x0020	/* Auto Neg Complete */
+#define MII_SR_PREAMBLE_SUPPRESS	0x0040	/* Preamble may be suppressed =
*/
+#define MII_SR_EXTENDED_STATUS		0x0100	/* Ext stat info in Reg 0x0F */
+#define MII_SR_100T2_HD_CAPS		0x0200	/* 100T2 Half Duplex Capable */
+#define MII_SR_100T2_FD_CAPS		0x0400	/* 100T2 Full Duplex Capable */
+#define MII_SR_10T_HD_CAPS		0x0800	/* 10T   Half Duplex Capable */
+#define MII_SR_10T_FD_CAPS		0x1000	/* 10T   Full Duplex Capable */
+#define MII_SR_100X_HD_CAPS		0x2000	/* 100X  Half Duplex Capable */
+#define MII_SR_100X_FD_CAPS		0x4000	/* 100X  Full Duplex Capable */
+#define MII_SR_100T4_CAPS		0x8000	/* 100T4 Capable */
+
+/* Link partner ability register */
+#define MII_LPA_SLCT			0x001f	/* Same as advertise selector */
+#define MII_LPA_10HALF			0x0020	/* Can do 10mbps half-duplex */
+#define MII_LPA_10FULL			0x0040	/* Can do 10mbps full-duplex */
+#define MII_LPA_100HALF			0x0080	/* Can do 100mbps half-duplex */
+#define MII_LPA_100FULL			0x0100	/* Can do 100mbps full-duplex */
+#define MII_LPA_100BASE4		0x0200	/* 100BASE-T4 */
+#define MII_LPA_PAUSE			0x0400	/* PAUSE */
+#define MII_LPA_ASYPAUSE		0x0800	/* Asymmetrical PAUSE */
+#define MII_LPA_RFAULT			0x2000	/* Link partner faulted */
+#define MII_LPA_LPACK			0x4000	/* Link partner acked us */
+#define MII_LPA_NPAGE			0x8000	/* Next page bit */
+
+/* Autoneg Advertisement Register */
+#define MII_AR_SELECTOR_FIELD		0x0001	/* IEEE 802.3 CSMA/CD */
+#define MII_AR_10T_HD_CAPS		0x0020	/* 10T   Half Duplex Capable */
+#define MII_AR_10T_FD_CAPS		0x0040	/* 10T   Full Duplex Capable */
+#define MII_AR_100TX_HD_CAPS		0x0080	/* 100TX Half Duplex Capable */
+#define MII_AR_100TX_FD_CAPS		0x0100	/* 100TX Full Duplex Capable */
+#define MII_AR_100T4_CAPS		0x0200	/* 100T4 Capable */
+#define MII_AR_PAUSE			0x0400	/* Pause operation desired */
+#define MII_AR_ASM_DIR			0x0800	/* Asymmetric Pause Dir bit */
+#define MII_AR_REMOTE_FAULT		0x2000	/* Remote Fault detected */
+#define MII_AR_NEXT_PAGE		0x8000	/* Next Page ability support */
+#define MII_AR_SPEED_MASK		0x01E0
+#define MII_AR_DEFAULT_CAP_MASK		0x0DE0
+
+/* 1000BASE-T Control Register */
+#define MII_ATLX_CR_1000T_HD_CAPS	0x0100	/* Adv 1000T HD cap */
+#define MII_ATLX_CR_1000T_FD_CAPS	0x0200	/* Adv 1000T FD cap */
+#define MII_ATLX_CR_1000T_REPEATER_DTE	0x0400	/* 1=3DRepeater/switch d=
evice,
+						 * 0=3DDTE device */
+#define MII_ATLX_CR_1000T_MS_VALUE	0x0800	/* 1=3DConfig PHY as Master,
+						 * 0=3DConfigure PHY as Slave */
+#define MII_ATLX_CR_1000T_MS_ENABLE	0x1000	/* 1=3DMan Master/Slave con=
fig,
+						 * 0=3DAuto Master/Slave config
+						 */
+#define MII_ATLX_CR_1000T_TEST_MODE_NORMAL	0x0000	/* Normal Operation =
*/
+#define MII_ATLX_CR_1000T_TEST_MODE_1	0x2000	/* Transmit Waveform test=
 */
+#define MII_ATLX_CR_1000T_TEST_MODE_2	0x4000	/* Master Xmit Jitter tes=
t */
+#define MII_ATLX_CR_1000T_TEST_MODE_3	0x6000	/* Slave Xmit Jitter test=
 */
+#define MII_ATLX_CR_1000T_TEST_MODE_4	0x8000	/* Xmitter Distortion tes=
t */
+#define MII_ATLX_CR_1000T_SPEED_MASK	0x0300
+#define MII_ATLX_CR_1000T_DEFAULT_CAP_MASK	0x0300
+
+/* 1000BASE-T Status Register */
+#define MII_ATLX_SR_1000T_LP_HD_CAPS	0x0400	/* LP is 1000T HD capable =
*/
+#define MII_ATLX_SR_1000T_LP_FD_CAPS	0x0800	/* LP is 1000T FD capable =
*/
+#define MII_ATLX_SR_1000T_REMOTE_RX_STATUS	0x1000	/* Remote receiver O=
K */
+#define MII_ATLX_SR_1000T_LOCAL_RX_STATUS	0x2000	/* Local receiver OK =
*/
+#define MII_ATLX_SR_1000T_MS_CONFIG_RES		0x4000	/* 1=3DLocal TX is Mas=
ter
+							 * 0=3DSlave
+							 */
+#define MII_ATLX_SR_1000T_MS_CONFIG_FAULT	0x8000	/* Master/Slave confi=
g
+							 * fault */
+#define MII_ATLX_SR_1000T_REMOTE_RX_STATUS_SHIFT	12
+#define MII_ATLX_SR_1000T_LOCAL_RX_STATUS_SHIFT		13
+
+/* Extended Status Register */
+#define MII_ATLX_ESR_1000T_HD_CAPS	0x1000	/* 1000T HD capable */
+#define MII_ATLX_ESR_1000T_FD_CAPS	0x2000	/* 1000T FD capable */
+#define MII_ATLX_ESR_1000X_HD_CAPS	0x4000	/* 1000X HD capable */
+#define MII_ATLX_ESR_1000X_FD_CAPS	0x8000	/* 1000X FD capable */
+
+/* ATLX PHY Specific Control Register */
+#define MII_ATLX_PSCR_JABBER_DISABLE	0x0001	/* 1=3DJabber Func disable=
d */
+#define MII_ATLX_PSCR_POLARITY_REVERSAL	0x0002	/* 1=3DPolarity Reversa=
l enbld */
+#define MII_ATLX_PSCR_SQE_TEST		0x0004	/* 1=3DSQE Test enabled */
+#define MII_ATLX_PSCR_MAC_POWERDOWN	0x0008
+#define MII_ATLX_PSCR_CLK125_DISABLE	0x0010	/* 1=3DCLK125 low
+						 * 0=3DCLK125 toggling
+						 */
+#define MII_ATLX_PSCR_MDI_MANUAL_MODE	0x0000	/* MDI Crossover Mode bit=
s 6:5,
+						 * Manual MDI configuration
+						 */
+#define MII_ATLX_PSCR_MDIX_MANUAL_MODE	0x0020	/* Manual MDIX configura=
tion */
+#define MII_ATLX_PSCR_AUTO_X_1000T	0x0040	/* 1000BASE-T: Auto crossove=
r
+						 * 100BASE-TX/10BASE-T: MDI
+						 * Mode */
+#define MII_ATLX_PSCR_AUTO_X_MODE	0x0060	/* Auto crossover enabled
+						 * all speeds.
+						 */
+#define MII_ATLX_PSCR_10BT_EXT_DIST_ENABLE	0x0080	/* 1=3DEnable Extend=
ed
+							 * 10BASE-T distance
+							 * (Lower 10BASE-T RX
+							 * Threshold)
+							 * 0=3DNormal 10BASE-T RX
+							 * Threshold
+							 */
+#define MII_ATLX_PSCR_MII_5BIT_ENABLE	0x0100	/* 1=3D5-Bit interface in
+						 * 100BASE-TX
+						 * 0=3DMII interface in
+						 * 100BASE-TX
+						 */
+#define MII_ATLX_PSCR_SCRAMBLER_DISABLE	0x0200	/* 1=3DScrambler dsbl *=
/
+#define MII_ATLX_PSCR_FORCE_LINK_GOOD	0x0400	/* 1=3DForce link good */
+#define MII_ATLX_PSCR_ASSERT_CRS_ON_TX	0x0800	/* 1=3DAssert CRS on Tra=
nsmit */
+#define MII_ATLX_PSCR_POLARITY_REVERSAL_SHIFT		1
+#define MII_ATLX_PSCR_AUTO_X_MODE_SHIFT			5
+#define MII_ATLX_PSCR_10BT_EXT_DIST_ENABLE_SHIFT	7
+
+/* ATLX PHY Specific Status Register */
+#define MII_ATLX_PSSR_SPD_DPLX_RESOLVED	0x0800	/* 1=3DSpeed & Duplex r=
esolved */
+#define MII_ATLX_PSSR_DPLX		0x2000	/* 1=3DDuplex 0=3DHalf Duplex */
+#define MII_ATLX_PSSR_SPEED		0xC000	/* Speed, bits 14:15 */
+#define MII_ATLX_PSSR_10MBS		0x0000	/* 00=3D10Mbs */
+#define MII_ATLX_PSSR_100MBS		0x4000	/* 01=3D100Mbs */
+#define MII_ATLX_PSSR_1000MBS		0x8000	/* 10=3D1000Mbs */
+
+/* PCI Command Register Bit Definitions */
+#define PCI_REG_COMMAND			0x04	/* PCI Command Register */
+#define CMD_IO_SPACE			0x0001
+#define CMD_MEMORY_SPACE		0x0002
+#define CMD_BUS_MASTER			0x0004
+
+/* Wake Up Filter Control */
+#define ATLX_WUFC_LNKC	0x00000001	/* Link Status Change Wakeup Enable =
*/
+#define ATLX_WUFC_MAG	0x00000002	/* Magic Packet Wakeup Enable */
+#define ATLX_WUFC_EX	0x00000004	/* Directed Exact Wakeup Enable */
+#define ATLX_WUFC_MC	0x00000008	/* Multicast Wakeup Enable */
+#define ATLX_WUFC_BC	0x00000010	/* Broadcast Wakeup Enable */
+
+#define ADVERTISE_10_HALF		0x0001
+#define ADVERTISE_10_FULL		0x0002
+#define ADVERTISE_100_HALF		0x0004
+#define ADVERTISE_100_FULL		0x0008
+#define ADVERTISE_1000_HALF		0x0010
+#define ADVERTISE_1000_FULL		0x0020
+#define AUTONEG_ADVERTISE_10_100_ALL	0x000F	/* All 10/100 speeds */
+#define AUTONEG_ADVERTISE_10_ALL	0x0003	/* 10Mbps Full & Half speeds *=
/
+
+#define PHY_AUTO_NEG_TIME		45	/* 4.5 Seconds */
+#define PHY_FORCE_TIME			20	/* 2.0 Seconds */
+
+/* For checksumming, the sum of all words in the EEPROM should equal 0=
xBABA */
+#define EEPROM_SUM			0xBABA
+#define NODE_ADDRESS_SIZE		6
+
+struct atlx_spi_flash_dev {
+	const char *manu_name;	/* manufacturer id */
+	/* op-code */
+	u8 cmd_wrsr;
+	u8 cmd_read;
+	u8 cmd_program;
+	u8 cmd_wren;
+	u8 cmd_wrdi;
+	u8 cmd_rdsr;
+	u8 cmd_rdid;
+	u8 cmd_sector_erase;
+	u8 cmd_chip_erase;
+};
+
+#endif /* ATLX_H */
--=20
1.5.3.8

