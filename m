From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver updates
Date: Thu, 14 Aug 2008 05:32:54 -0400
Message-ID: <20080814093254.GA14871@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:56288 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752298AbYHNJcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Aug 2008 05:32:55 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'upstream-davem' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git upstream-davem

to receive the following updates:

 drivers/net/Kconfig                      |    2 +-
 drivers/net/acenic.c                     |    1 -
 drivers/net/arm/ixp4xx_eth.c             |    6 +-
 drivers/net/atl1e/atl1e_ethtool.c        |    2 +-
 drivers/net/atl1e/atl1e_main.c           |    4 +-
 drivers/net/au1000_eth.c                 |    2 +-
 drivers/net/ax88796.c                    |    4 +-
 drivers/net/bnx2x_link.c                 |    1 -
 drivers/net/bnx2x_main.c                 |    1 -
 drivers/net/cpmac.c                      |    1 -
 drivers/net/e1000e/defines.h             |    2 +-
 drivers/net/e1000e/e1000.h               |    1 +
 drivers/net/e1000e/ethtool.c             |    2 +-
 drivers/net/e1000e/netdev.c              |  185 ++++++++++++++++++++++++--
 drivers/net/e1000e/param.c               |   25 +++-
 drivers/net/gianfar.c                    |    6 +-
 drivers/net/gianfar_sysfs.c              |    1 -
 drivers/net/ipg.h                        |    2 -
 drivers/net/ixgbe/ixgbe_82598.c          |    1 +
 drivers/net/ixgbe/ixgbe_main.c           |    4 +-
 drivers/net/ixgbe/ixgbe_type.h           |    1 +
 drivers/net/myri10ge/myri10ge.c          |    6 +-
 drivers/net/ne.c                         |    4 +-
 drivers/net/netxen/netxen_nic.h          |    7 +-
 drivers/net/netxen/netxen_nic_hw.c       |   59 ++++++---
 drivers/net/netxen/netxen_nic_init.c     |   28 ++--
 drivers/net/netxen/netxen_nic_main.c     |  210 ++++++++++++++----------------
 drivers/net/netxen/netxen_nic_phan_reg.h |    2 +
 drivers/net/ppp_mppe.c                   |    1 -
 drivers/net/pppol2tp.c                   |    1 -
 drivers/net/r6040.c                      |    1 -
 drivers/net/sh_eth.c                     |    1 -
 drivers/net/sky2.c                       |    8 +-
 drivers/net/tehuti.h                     |    1 -
 drivers/net/tlan.c                       |    8 +-
 drivers/net/typhoon.c                    |    1 -
 drivers/net/usb/Kconfig                  |   21 ++--
 drivers/net/usb/hso.c                    |   53 +++++----
 38 files changed, 425 insertions(+), 241 deletions(-)

Adrian Bunk (1):
      [netdrvr] uninline atl1e_setup_mac_ctrl()

Atsushi Nemoto (1):
      [netdrvr] ne: Use CONFIG_MACH_TX49XX

Ben Dooks (1):
      AX88796: Fix locking in ethtool support

Brice Goglin (1):
      myri10ge: myri10ge_fw_name also overrides the rss firmware

Bruce Allan (7):
      e1000e: Return 1 instead of a non-zero value for link up indication
      e1000e: Set InterruptThrottleRate to default when invalid value used
      e1000e: Use skb_copy_to_linear_data_offset introduced in 2.6.22
      e1000e: Increase Tx timeout factor for 10Mbps
      e1000e: increase minimum frame size allowed
      e1000e: test for unusable MSI support
      e1000e: remove unnecessary snippet missed in prior check_options update

David Brownell (1):
      Kconfig: HSO driver bugfixes and updates

Dhananjay Phadke (6):
      netxen: fix mac addr setup
      netxen: fix rxbuf leak across driver reload
      netxen: force link update across ifdown/ifup
      netxen: fix dma watchdog
      netxen: cleanup interrupt code
      netxen: update driver version

Greg Kroah-Hartman (2):
      USB: HSO: make tty_operations const
      USB: HSO: minor fixes due to code review

Huang Weiyi (1):
      [netdrvr] remove unnecessary #include

Jesse Brandeburg (1):
      ixgbe: add cx4 device ID

Mikael Pettersson (1):
      ixp4xx_eth: fix dma_mapping_error() compile errors

Olivier Blin (2):
      hso: fix oops in read/write callbacks
      hso: fix refcounting on the ttyHSx devices

Rafael J. Wysocki (1):
      sky2: Fix suspend/hibernation/shutdown regression with WOL enabled (rev. 2)

Robert Fitzsimons (1):
      tlan: Fix two regressions introduced by 64bit conversion.

Scott Wood (1):
      gianfar: Call gfar_halt_nodisable() from gfar_halt().

Vegard Nossum (1):
      au1000_eth: use 'unsigned long' for irqflags

roel kluin (1):
      atl1e: WAKE_MCAST 2x. 1st WAKE_UCAST?

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 4b4cb2b..a5c141c 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1172,7 +1172,7 @@ config ETH16I
 
 config NE2000
 	tristate "NE2000/NE1000 support"
-	depends on NET_ISA || (Q40 && m) || M32R || TOSHIBA_RBTX4927 || TOSHIBA_RBTX4938
+	depends on NET_ISA || (Q40 && m) || M32R || MACH_TX49XX
 	select CRC32
 	---help---
 	  If you have a network (Ethernet) card of this type, say Y and read
diff --git a/drivers/net/acenic.c b/drivers/net/acenic.c
index e4483de..66de80b 100644
--- a/drivers/net/acenic.c
+++ b/drivers/net/acenic.c
@@ -52,7 +52,6 @@
 
 #include <linux/module.h>
 #include <linux/moduleparam.h>
-#include <linux/version.h>
 #include <linux/types.h>
 #include <linux/errno.h>
 #include <linux/ioport.h>
diff --git a/drivers/net/arm/ixp4xx_eth.c b/drivers/net/arm/ixp4xx_eth.c
index 9b777d9..7d5db2e 100644
--- a/drivers/net/arm/ixp4xx_eth.c
+++ b/drivers/net/arm/ixp4xx_eth.c
@@ -551,7 +551,7 @@ static int eth_poll(struct napi_struct *napi, int budget)
 		if ((skb = netdev_alloc_skb(dev, RX_BUFF_SIZE))) {
 			phys = dma_map_single(&dev->dev, skb->data,
 					      RX_BUFF_SIZE, DMA_FROM_DEVICE);
-			if (dma_mapping_error(phys)) {
+			if (dma_mapping_error(&dev->dev, phys)) {
 				dev_kfree_skb(skb);
 				skb = NULL;
 			}
@@ -698,7 +698,7 @@ static int eth_xmit(struct sk_buff *skb, struct net_device *dev)
 #endif
 
 	phys = dma_map_single(&dev->dev, mem, bytes, DMA_TO_DEVICE);
-	if (dma_mapping_error(phys)) {
+	if (dma_mapping_error(&dev->dev, phys)) {
 #ifdef __ARMEB__
 		dev_kfree_skb(skb);
 #else
@@ -883,7 +883,7 @@ static int init_queues(struct port *port)
 		desc->buf_len = MAX_MRU;
 		desc->data = dma_map_single(&port->netdev->dev, data,
 					    RX_BUFF_SIZE, DMA_FROM_DEVICE);
-		if (dma_mapping_error(desc->data)) {
+		if (dma_mapping_error(&port->netdev->dev, desc->data)) {
 			free_buffer(buff);
 			return -EIO;
 		}
diff --git a/drivers/net/atl1e/atl1e_ethtool.c b/drivers/net/atl1e/atl1e_ethtool.c
index cdc3b85..619c658 100644
--- a/drivers/net/atl1e/atl1e_ethtool.c
+++ b/drivers/net/atl1e/atl1e_ethtool.c
@@ -355,7 +355,7 @@ static int atl1e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
 	struct atl1e_adapter *adapter = netdev_priv(netdev);
 
 	if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE |
-			    WAKE_MCAST | WAKE_BCAST | WAKE_MCAST))
+			    WAKE_UCAST | WAKE_MCAST | WAKE_BCAST))
 		return -EOPNOTSUPP;
 	/* these settings will always override what we currently have */
 	adapter->wol = 0;
diff --git a/drivers/net/atl1e/atl1e_main.c b/drivers/net/atl1e/atl1e_main.c
index 35264c2..82d7be1 100644
--- a/drivers/net/atl1e/atl1e_main.c
+++ b/drivers/net/atl1e/atl1e_main.c
@@ -47,7 +47,7 @@ MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
 MODULE_LICENSE("GPL");
 MODULE_VERSION(DRV_VERSION);
 
-static inline void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter);
+static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter);
 
 static const u16
 atl1e_rx_page_vld_regs[AT_MAX_RECEIVE_QUEUE][AT_PAGE_NUM_PER_QUEUE] =
@@ -1037,7 +1037,7 @@ static inline void atl1e_configure_dma(struct atl1e_adapter *adapter)
 	return;
 }
 
-static inline void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
+static void atl1e_setup_mac_ctrl(struct atl1e_adapter *adapter)
 {
 	u32 value;
 	struct atl1e_hw *hw = &adapter->hw;
diff --git a/drivers/net/au1000_eth.c b/drivers/net/au1000_eth.c
index cb8be49..5ee1b05 100644
--- a/drivers/net/au1000_eth.c
+++ b/drivers/net/au1000_eth.c
@@ -807,7 +807,7 @@ err_out:
 static int au1000_init(struct net_device *dev)
 {
 	struct au1000_private *aup = (struct au1000_private *) dev->priv;
-	u32 flags;
+	unsigned long flags;
 	int i;
 	u32 control;
 
diff --git a/drivers/net/ax88796.c b/drivers/net/ax88796.c
index 0b4adf4..a886a4b 100644
--- a/drivers/net/ax88796.c
+++ b/drivers/net/ax88796.c
@@ -554,7 +554,7 @@ static int ax_get_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	spin_lock_irqsave(&ax->mii_lock, flags);
 	mii_ethtool_gset(&ax->mii, cmd);
-	spin_lock_irqsave(&ax->mii_lock, flags);
+	spin_unlock_irqrestore(&ax->mii_lock, flags);
 
 	return 0;
 }
@@ -567,7 +567,7 @@ static int ax_set_settings(struct net_device *dev, struct ethtool_cmd *cmd)
 
 	spin_lock_irqsave(&ax->mii_lock, flags);
 	rc = mii_ethtool_sset(&ax->mii, cmd);
-	spin_lock_irqsave(&ax->mii_lock, flags);
+	spin_unlock_irqrestore(&ax->mii_lock, flags);
 
 	return rc;
 }
diff --git a/drivers/net/bnx2x_link.c b/drivers/net/bnx2x_link.c
index 8b92c6a..4ce7fe9 100644
--- a/drivers/net/bnx2x_link.c
+++ b/drivers/net/bnx2x_link.c
@@ -21,7 +21,6 @@
 #include <linux/delay.h>
 #include <linux/ethtool.h>
 #include <linux/mutex.h>
-#include <linux/version.h>
 
 #include "bnx2x_reg.h"
 #include "bnx2x_fw_defs.h"
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 3e7dc17..971576b 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -44,7 +44,6 @@
 #include <net/ip.h>
 #include <net/tcp.h>
 #include <net/checksum.h>
-#include <linux/version.h>
 #include <net/ip6_checksum.h>
 #include <linux/workqueue.h>
 #include <linux/crc32.h>
diff --git a/drivers/net/cpmac.c b/drivers/net/cpmac.c
index a7800e5..ec6b0af 100644
--- a/drivers/net/cpmac.c
+++ b/drivers/net/cpmac.c
@@ -26,7 +26,6 @@
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/delay.h>
-#include <linux/version.h>
 
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index f823b8b..14b0e6c 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -389,7 +389,7 @@
 
 /* Interrupt Cause Set */
 #define E1000_ICS_LSC       E1000_ICR_LSC       /* Link Status Change */
-#define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* rx desc min. threshold */
+#define E1000_ICS_RXSEQ     E1000_ICR_RXSEQ     /* Rx sequence error */
 #define E1000_ICS_RXDMT0    E1000_ICR_RXDMT0    /* Rx desc min. threshold */
 
 /* Transmit Descriptor Control */
diff --git a/drivers/net/e1000e/e1000.h b/drivers/net/e1000e/e1000.h
index cf57050..ac4e506 100644
--- a/drivers/net/e1000e/e1000.h
+++ b/drivers/net/e1000e/e1000.h
@@ -326,6 +326,7 @@ struct e1000_info {
 #define FLAG_RX_CSUM_ENABLED              (1 << 28)
 #define FLAG_TSO_FORCE                    (1 << 29)
 #define FLAG_RX_RESTART_NOW               (1 << 30)
+#define FLAG_MSI_TEST_FAILED              (1 << 31)
 
 #define E1000_RX_DESC_PS(R, i)	    \
 	(&(((union e1000_rx_desc_packet_split *)((R).desc))[i]))
diff --git a/drivers/net/e1000e/ethtool.c b/drivers/net/e1000e/ethtool.c
index cf9679f..e21c9e0 100644
--- a/drivers/net/e1000e/ethtool.c
+++ b/drivers/net/e1000e/ethtool.c
@@ -177,7 +177,7 @@ static u32 e1000_get_link(struct net_device *netdev)
 	u32 status;
 	
 	status = er32(STATUS);
-	return (status & E1000_STATUS_LU);
+	return (status & E1000_STATUS_LU) ? 1 : 0;
 }
 
 static int e1000_set_spd_dplx(struct e1000_adapter *adapter, u16 spddplx)
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 05b0b2f..d266510 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -510,9 +510,12 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 			    netdev_alloc_skb(netdev, length + NET_IP_ALIGN);
 			if (new_skb) {
 				skb_reserve(new_skb, NET_IP_ALIGN);
-				memcpy(new_skb->data - NET_IP_ALIGN,
-				       skb->data - NET_IP_ALIGN,
-				       length + NET_IP_ALIGN);
+				skb_copy_to_linear_data_offset(new_skb,
+							       -NET_IP_ALIGN,
+							       (skb->data -
+								NET_IP_ALIGN),
+							       (length +
+								NET_IP_ALIGN));
 				/* save the skb in buffer_info as good */
 				buffer_info->skb = skb;
 				skb = new_skb;
@@ -1233,26 +1236,36 @@ static irqreturn_t e1000_intr(int irq, void *data)
 	return IRQ_HANDLED;
 }
 
+/**
+ * e1000_request_irq - initialize interrupts
+ *
+ * Attempts to configure interrupts using the best available
+ * capabilities of the hardware and kernel.
+ **/
 static int e1000_request_irq(struct e1000_adapter *adapter)
 {
 	struct net_device *netdev = adapter->netdev;
-	irq_handler_t handler = e1000_intr;
 	int irq_flags = IRQF_SHARED;
 	int err;
 
-	if (!pci_enable_msi(adapter->pdev)) {
-		adapter->flags |= FLAG_MSI_ENABLED;
-		handler = e1000_intr_msi;
-		irq_flags = 0;
+	if (!(adapter->flags & FLAG_MSI_TEST_FAILED)) {
+		err = pci_enable_msi(adapter->pdev);
+		if (!err) {
+			adapter->flags |= FLAG_MSI_ENABLED;
+			irq_flags = 0;
+		}
 	}
 
-	err = request_irq(adapter->pdev->irq, handler, irq_flags, netdev->name,
-			  netdev);
+	err = request_irq(adapter->pdev->irq,
+			  ((adapter->flags & FLAG_MSI_ENABLED) ?
+				&e1000_intr_msi : &e1000_intr),
+			  irq_flags, netdev->name, netdev);
 	if (err) {
-		e_err("Unable to allocate %s interrupt (return: %d)\n",
-		      adapter->flags & FLAG_MSI_ENABLED ? "MSI":"INTx",	err);
-		if (adapter->flags & FLAG_MSI_ENABLED)
+		if (adapter->flags & FLAG_MSI_ENABLED) {
 			pci_disable_msi(adapter->pdev);
+			adapter->flags &= ~FLAG_MSI_ENABLED;
+		}
+		e_err("Unable to allocate interrupt, Error: %d\n", err);
 	}
 
 	return err;
@@ -2592,6 +2605,135 @@ err:
 }
 
 /**
+ * e1000_intr_msi_test - Interrupt Handler
+ * @irq: interrupt number
+ * @data: pointer to a network interface device structure
+ **/
+static irqreturn_t e1000_intr_msi_test(int irq, void *data)
+{
+	struct net_device *netdev = data;
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_hw *hw = &adapter->hw;
+	u32 icr = er32(ICR);
+
+	e_dbg("%s: icr is %08X\n", netdev->name, icr);
+	if (icr & E1000_ICR_RXSEQ) {
+		adapter->flags &= ~FLAG_MSI_TEST_FAILED;
+		wmb();
+	}
+
+	return IRQ_HANDLED;
+}
+
+/**
+ * e1000_test_msi_interrupt - Returns 0 for successful test
+ * @adapter: board private struct
+ *
+ * code flow taken from tg3.c
+ **/
+static int e1000_test_msi_interrupt(struct e1000_adapter *adapter)
+{
+	struct net_device *netdev = adapter->netdev;
+	struct e1000_hw *hw = &adapter->hw;
+	int err;
+
+	/* poll_enable hasn't been called yet, so don't need disable */
+	/* clear any pending events */
+	er32(ICR);
+
+	/* free the real vector and request a test handler */
+	e1000_free_irq(adapter);
+
+	/* Assume that the test fails, if it succeeds then the test
+	 * MSI irq handler will unset this flag */
+	adapter->flags |= FLAG_MSI_TEST_FAILED;
+
+	err = pci_enable_msi(adapter->pdev);
+	if (err)
+		goto msi_test_failed;
+
+	err = request_irq(adapter->pdev->irq, &e1000_intr_msi_test, 0,
+			  netdev->name, netdev);
+	if (err) {
+		pci_disable_msi(adapter->pdev);
+		goto msi_test_failed;
+	}
+
+	wmb();
+
+	e1000_irq_enable(adapter);
+
+	/* fire an unusual interrupt on the test handler */
+	ew32(ICS, E1000_ICS_RXSEQ);
+	e1e_flush();
+	msleep(50);
+
+	e1000_irq_disable(adapter);
+
+	rmb();
+
+	if (adapter->flags & FLAG_MSI_TEST_FAILED) {
+		err = -EIO;
+		e_info("MSI interrupt test failed!\n");
+	}
+
+	free_irq(adapter->pdev->irq, netdev);
+	pci_disable_msi(adapter->pdev);
+
+	if (err == -EIO)
+		goto msi_test_failed;
+
+	/* okay so the test worked, restore settings */
+	e_dbg("%s: MSI interrupt test succeeded!\n", netdev->name);
+msi_test_failed:
+	/* restore the original vector, even if it failed */
+	e1000_request_irq(adapter);
+	return err;
+}
+
+/**
+ * e1000_test_msi - Returns 0 if MSI test succeeds or INTx mode is restored
+ * @adapter: board private struct
+ *
+ * code flow taken from tg3.c, called with e1000 interrupts disabled.
+ **/
+static int e1000_test_msi(struct e1000_adapter *adapter)
+{
+	int err;
+	u16 pci_cmd;
+
+	if (!(adapter->flags & FLAG_MSI_ENABLED))
+		return 0;
+
+	/* disable SERR in case the MSI write causes a master abort */
+	pci_read_config_word(adapter->pdev, PCI_COMMAND, &pci_cmd);
+	pci_write_config_word(adapter->pdev, PCI_COMMAND,
+			      pci_cmd & ~PCI_COMMAND_SERR);
+
+	err = e1000_test_msi_interrupt(adapter);
+
+	/* restore previous setting of command word */
+	pci_write_config_word(adapter->pdev, PCI_COMMAND, pci_cmd);
+
+	/* success ! */
+	if (!err)
+		return 0;
+
+	/* EIO means MSI test failed */
+	if (err != -EIO)
+		return err;
+
+	/* back to INTx mode */
+	e_warn("MSI interrupt test failed, using legacy interrupt.\n");
+
+	e1000_free_irq(adapter);
+
+	err = e1000_request_irq(adapter);
+
+	return err;
+}
+
+/**
  * e1000_open - Called when a network interface is made active
  * @netdev: network interface device structure
  *
@@ -2649,6 +2791,19 @@ static int e1000_open(struct net_device *netdev)
 	if (err)
 		goto err_req_irq;
 
+	/*
+	 * Work around PCIe errata with MSI interrupts causing some chipsets to
+	 * ignore e1000e MSI messages, which means we need to test our MSI
+	 * interrupt now
+	 */
+	{
+		err = e1000_test_msi(adapter);
+		if (err) {
+			e_err("Interrupt allocation failed\n");
+			goto err_req_irq;
+		}
+	}
+
 	/* From here on the code is the same as e1000e_up() */
 	clear_bit(__E1000_DOWN, &adapter->state);
 
@@ -3055,7 +3210,7 @@ static void e1000_watchdog_task(struct work_struct *work)
 			case SPEED_10:
 				txb2b = 0;
 				netdev->tx_queue_len = 10;
-				adapter->tx_timeout_factor = 14;
+				adapter->tx_timeout_factor = 16;
 				break;
 			case SPEED_100:
 				txb2b = 0;
@@ -3721,7 +3876,7 @@ static int e1000_change_mtu(struct net_device *netdev, int new_mtu)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	int max_frame = new_mtu + ETH_HLEN + ETH_FCS_LEN;
 
-	if ((max_frame < ETH_ZLEN + ETH_FCS_LEN) ||
+	if ((new_mtu < ETH_ZLEN + ETH_FCS_LEN + VLAN_HLEN) ||
 	    (max_frame > MAX_JUMBO_FRAME_SIZE)) {
 		e_err("Invalid MTU setting\n");
 		return -EINVAL;
diff --git a/drivers/net/e1000e/param.c b/drivers/net/e1000e/param.c
index 8effc31..ed912e0 100644
--- a/drivers/net/e1000e/param.c
+++ b/drivers/net/e1000e/param.c
@@ -324,14 +324,27 @@ void __devinit e1000e_check_options(struct e1000_adapter *adapter)
 				adapter->itr = 20000;
 				break;
 			default:
-				e1000_validate_option(&adapter->itr, &opt,
-					adapter);
 				/*
-				 * save the setting, because the dynamic bits
-				 * change itr. clear the lower two bits
-				 * because they are used as control
+				 * Save the setting, because the dynamic bits
+				 * change itr.
 				 */
-				adapter->itr_setting = adapter->itr & ~3;
+				if (e1000_validate_option(&adapter->itr, &opt,
+							  adapter) &&
+				    (adapter->itr == 3)) {
+					/*
+					 * In case of invalid user value,
+					 * default to conservative mode.
+					 */
+					adapter->itr_setting = adapter->itr;
+					adapter->itr = 20000;
+				} else {
+					/*
+					 * Clear the lower two bits because
+					 * they are used as control.
+					 */
+					adapter->itr_setting =
+						adapter->itr & ~3;
+				}
 				break;
 			}
 		} else {
diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index ca6cf6e..999d691 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -134,9 +134,7 @@ static int gfar_process_frame(struct net_device *dev, struct sk_buff *skb, int l
 static void gfar_vlan_rx_register(struct net_device *netdev,
 		                struct vlan_group *grp);
 void gfar_halt(struct net_device *dev);
-#ifdef CONFIG_PM
 static void gfar_halt_nodisable(struct net_device *dev);
-#endif
 void gfar_start(struct net_device *dev);
 static void gfar_clear_exact_match(struct net_device *dev);
 static void gfar_set_mac_for_addr(struct net_device *dev, int num, u8 *addr);
@@ -631,7 +629,6 @@ static void init_registers(struct net_device *dev)
 }
 
 
-#ifdef CONFIG_PM
 /* Halt the receive and transmit queues */
 static void gfar_halt_nodisable(struct net_device *dev)
 {
@@ -657,7 +654,6 @@ static void gfar_halt_nodisable(struct net_device *dev)
 			cpu_relax();
 	}
 }
-#endif
 
 /* Halt the receive and transmit queues */
 void gfar_halt(struct net_device *dev)
@@ -666,6 +662,8 @@ void gfar_halt(struct net_device *dev)
 	struct gfar __iomem *regs = priv->regs;
 	u32 tempval;
 
+	gfar_halt_nodisable(dev);
+
 	/* Disable Rx and Tx */
 	tempval = gfar_read(&regs->maccfg1);
 	tempval &= ~(MACCFG1_RX_EN | MACCFG1_TX_EN);
diff --git a/drivers/net/gianfar_sysfs.c b/drivers/net/gianfar_sysfs.c
index 5116f68..782c201 100644
--- a/drivers/net/gianfar_sysfs.c
+++ b/drivers/net/gianfar_sysfs.c
@@ -33,7 +33,6 @@
 
 #include <asm/uaccess.h>
 #include <linux/module.h>
-#include <linux/version.h>
 
 #include "gianfar.h"
 
diff --git a/drivers/net/ipg.h b/drivers/net/ipg.h
index e0e718a..dd9318f 100644
--- a/drivers/net/ipg.h
+++ b/drivers/net/ipg.h
@@ -7,7 +7,6 @@
 #ifndef __LINUX_IPG_H
 #define __LINUX_IPG_H
 
-#include <linux/version.h>
 #include <linux/module.h>
 
 #include <linux/kernel.h>
@@ -21,7 +20,6 @@
 #include <linux/etherdevice.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/version.h>
 #include <asm/bitops.h>
 
 /*
diff --git a/drivers/net/ixgbe/ixgbe_82598.c b/drivers/net/ixgbe/ixgbe_82598.c
index 2f38e84..f96358b 100644
--- a/drivers/net/ixgbe/ixgbe_82598.c
+++ b/drivers/net/ixgbe/ixgbe_82598.c
@@ -190,6 +190,7 @@ static enum ixgbe_media_type ixgbe_get_media_type_82598(struct ixgbe_hw *hw)
 	case IXGBE_DEV_ID_82598AF_DUAL_PORT:
 	case IXGBE_DEV_ID_82598AF_SINGLE_PORT:
 	case IXGBE_DEV_ID_82598EB_CX4:
+	case IXGBE_DEV_ID_82598_CX4_DUAL_PORT:
 		media_type = ixgbe_media_type_fiber;
 		break;
 	case IXGBE_DEV_ID_82598AT_DUAL_PORT:
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index e5f3da8..34bca16 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -48,7 +48,7 @@ char ixgbe_driver_name[] = "ixgbe";
 static const char ixgbe_driver_string[] =
 	"Intel(R) 10 Gigabit PCI Express Network Driver";
 
-#define DRV_VERSION "1.3.18-k2"
+#define DRV_VERSION "1.3.18-k4"
 const char ixgbe_driver_version[] = DRV_VERSION;
 static const char ixgbe_copyright[] =
 	 "Copyright (c) 1999-2007 Intel Corporation.";
@@ -72,6 +72,8 @@ static struct pci_device_id ixgbe_pci_tbl[] = {
 	 board_82598 },
 	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598EB_CX4),
 	 board_82598 },
+	{PCI_VDEVICE(INTEL, IXGBE_DEV_ID_82598_CX4_DUAL_PORT),
+	 board_82598 },
 
 	/* required last entry */
 	{0, }
diff --git a/drivers/net/ixgbe/ixgbe_type.h b/drivers/net/ixgbe/ixgbe_type.h
index 1ad7cb9..c0282a2 100644
--- a/drivers/net/ixgbe/ixgbe_type.h
+++ b/drivers/net/ixgbe/ixgbe_type.h
@@ -39,6 +39,7 @@
 #define IXGBE_DEV_ID_82598AF_SINGLE_PORT 0x10C7
 #define IXGBE_DEV_ID_82598AT_DUAL_PORT   0x10C8
 #define IXGBE_DEV_ID_82598EB_CX4         0x10DD
+#define IXGBE_DEV_ID_82598_CX4_DUAL_PORT 0x10EC
 
 /* General Registers */
 #define IXGBE_CTRL      0x00000
diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index f1de38f..5d76cd0 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -3548,7 +3548,11 @@ static void myri10ge_probe_slices(struct myri10ge_priv *mgp)
 
 	/* try to load the slice aware rss firmware */
 	old_fw = mgp->fw_name;
-	if (old_fw == myri10ge_fw_aligned)
+	if (myri10ge_fw_name != NULL) {
+		dev_info(&mgp->pdev->dev, "overriding rss firmware to %s\n",
+			 myri10ge_fw_name);
+		mgp->fw_name = myri10ge_fw_name;
+	} else if (old_fw == myri10ge_fw_aligned)
 		mgp->fw_name = myri10ge_fw_rss_aligned;
 	else
 		mgp->fw_name = myri10ge_fw_rss_unaligned;
diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 42443d6..fa3ceca 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -118,7 +118,7 @@ bad_clone_list[] __initdata = {
     {"E-LAN100", "E-LAN200", {0x00, 0x00, 0x5d}}, /* Broken ne1000 clones */
     {"PCM-4823", "PCM-4823", {0x00, 0xc0, 0x6c}}, /* Broken Advantech MoBo */
     {"REALTEK", "RTL8019", {0x00, 0x00, 0xe8}}, /* no-name with Realtek chip */
-#if defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
+#ifdef CONFIG_MACH_TX49XX
     {"RBHMA4X00-RTL8019", "RBHMA4X00/RTL8019", {0x00, 0x60, 0x0a}},  /* Toshiba built-in */
 #endif
     {"LCS-8834", "LCS-8836", {0x04, 0x04, 0x37}}, /* ShinyNet (SET) */
@@ -142,7 +142,7 @@ bad_clone_list[] __initdata = {
 #if defined(CONFIG_PLAT_MAPPI)
 #  define DCR_VAL 0x4b
 #elif defined(CONFIG_PLAT_OAKS32R)  || \
-   defined(CONFIG_TOSHIBA_RBTX4927) || defined(CONFIG_TOSHIBA_RBTX4938)
+   defined(CONFIG_MACH_TX49XX)
 #  define DCR_VAL 0x48		/* 8-bit mode */
 #else
 #  define DCR_VAL 0x49
diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxen_nic.h
index 93a7b9b..ab871df 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -66,8 +66,8 @@
 
 #define _NETXEN_NIC_LINUX_MAJOR 4
 #define _NETXEN_NIC_LINUX_MINOR 0
-#define _NETXEN_NIC_LINUX_SUBVERSION 0
-#define NETXEN_NIC_LINUX_VERSIONID  "4.0.0"
+#define _NETXEN_NIC_LINUX_SUBVERSION 11
+#define NETXEN_NIC_LINUX_VERSIONID  "4.0.11"
 
 #define NETXEN_VERSION_CODE(a, b, c)	(((a) << 16) + ((b) << 8) + (c))
 
@@ -1615,7 +1615,8 @@ dma_watchdog_wakeup(struct netxen_adapter *adapter)
 
 
 int netxen_is_flash_supported(struct netxen_adapter *adapter);
-int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 mac[]);
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
+int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac);
 extern void netxen_change_ringparam(struct netxen_adapter *adapter);
 extern int netxen_rom_fast_read(struct netxen_adapter *adapter, int addr,
 				int *valp);
diff --git a/drivers/net/netxen/netxen_nic_hw.c b/drivers/net/netxen/netxen_nic_hw.c
index 9aa20f9..84978f8 100644
--- a/drivers/net/netxen/netxen_nic_hw.c
+++ b/drivers/net/netxen/netxen_nic_hw.c
@@ -733,31 +733,56 @@ static int netxen_get_flash_block(struct netxen_adapter *adapter, int base,
 	return 0;
 }
 
-int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 mac[])
+int netxen_get_flash_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
 {
-	__le32 *pmac = (__le32 *) & mac[0];
+	__le32 *pmac = (__le32 *) mac;
+	u32 offset;
 
-	if (netxen_get_flash_block(adapter,
-				   NETXEN_USER_START +
-				   offsetof(struct netxen_new_user_info,
-					    mac_addr),
-				   FLASH_NUM_PORTS * sizeof(u64), pmac) == -1) {
+	offset = NETXEN_USER_START +
+		offsetof(struct netxen_new_user_info, mac_addr) +
+		adapter->portnum * sizeof(u64);
+
+	if (netxen_get_flash_block(adapter, offset, sizeof(u64), pmac) == -1)
 		return -1;
-	}
+
 	if (*mac == cpu_to_le64(~0ULL)) {
+
+		offset = NETXEN_USER_START_OLD +
+			offsetof(struct netxen_user_old_info, mac_addr) +
+			adapter->portnum * sizeof(u64);
+
 		if (netxen_get_flash_block(adapter,
-					   NETXEN_USER_START_OLD +
-					   offsetof(struct netxen_user_old_info,
-						    mac_addr),
-					   FLASH_NUM_PORTS * sizeof(u64),
-					   pmac) == -1)
+					offset, sizeof(u64), pmac) == -1)
 			return -1;
+
 		if (*mac == cpu_to_le64(~0ULL))
 			return -1;
 	}
 	return 0;
 }
 
+int netxen_p3_get_mac_addr(struct netxen_adapter *adapter, __le64 *mac)
+{
+	uint32_t crbaddr, mac_hi, mac_lo;
+	int pci_func = adapter->ahw.pci_func;
+
+	crbaddr = CRB_MAC_BLOCK_START +
+		(4 * ((pci_func/2) * 3)) + (4 * (pci_func & 1));
+
+	adapter->hw_read_wx(adapter, crbaddr, &mac_lo, 4);
+	adapter->hw_read_wx(adapter, crbaddr+4, &mac_hi, 4);
+
+	mac_hi = cpu_to_le32(mac_hi);
+	mac_lo = cpu_to_le32(mac_lo);
+
+	if (pci_func & 1)
+		*mac = ((mac_lo >> 16) | ((u64)mac_hi << 16));
+	else
+		*mac = ((mac_lo) | ((u64)mac_hi << 32));
+
+	return 0;
+}
+
 #define CRB_WIN_LOCK_TIMEOUT 100000000
 
 static int crb_win_lock(struct netxen_adapter *adapter)
@@ -2183,10 +2208,10 @@ void netxen_nic_flash_print(struct netxen_adapter *adapter)
 	if (adapter->portnum == 0) {
 		get_brd_name_by_type(board_info->board_type, brd_name);
 
-		printk("NetXen %s Board S/N %s  Chip id 0x%x\n",
-				brd_name, serial_num, board_info->chip_id);
-		printk("NetXen Firmware version %d.%d.%d\n", fw_major,
-				fw_minor, fw_build);
+		printk(KERN_INFO "NetXen %s Board S/N %s  Chip rev 0x%x\n",
+				brd_name, serial_num, adapter->ahw.revision_id);
+		printk(KERN_INFO "NetXen Firmware version %d.%d.%d\n",
+				fw_major, fw_minor, fw_build);
 	}
 
 	if (NETXEN_VERSION_CODE(fw_major, fw_minor, fw_build) <
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/netxen_nic_init.c
index 519fc86..5bba675 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1079,10 +1079,12 @@ int netxen_initialize_adapter_offload(struct netxen_adapter *adapter)
 
 void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 {
-	int i;
+	int i = 100;
+
+	if (!adapter->dummy_dma.addr)
+		return;
 
-	if (adapter->dummy_dma.addr) {
-		i = 100;
+	if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
 		do {
 			if (dma_watchdog_shutdown_request(adapter) == 1)
 				break;
@@ -1090,17 +1092,17 @@ void netxen_free_adapter_offload(struct netxen_adapter *adapter)
 			if (dma_watchdog_shutdown_poll_result(adapter) == 1)
 				break;
 		} while (--i);
+	}
 
-		if (i) {
-			pci_free_consistent(adapter->pdev,
-				    NETXEN_HOST_DUMMY_DMA_SIZE,
-				    adapter->dummy_dma.addr,
-				    adapter->dummy_dma.phys_addr);
-			adapter->dummy_dma.addr = NULL;
-		} else {
-			printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
-					adapter->netdev->name);
-		}
+	if (i) {
+		pci_free_consistent(adapter->pdev,
+			    NETXEN_HOST_DUMMY_DMA_SIZE,
+			    adapter->dummy_dma.addr,
+			    adapter->dummy_dma.phys_addr);
+		adapter->dummy_dma.addr = NULL;
+	} else {
+		printk(KERN_ERR "%s: dma_watchdog_shutdown failed\n",
+				adapter->netdev->name);
 	}
 }
 
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/netxen_nic_main.c
index 7615c71..32bb47a 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -149,76 +149,18 @@ static uint32_t msi_tgt_status[8] = {
 
 static struct netxen_legacy_intr_set legacy_intr[] = NX_LEGACY_INTR_CONFIG;
 
-static void netxen_nic_disable_int(struct netxen_adapter *adapter)
+static inline void netxen_nic_disable_int(struct netxen_adapter *adapter)
 {
-	u32 mask = 0x7ff;
-	int retries = 32;
-	int pci_fn = adapter->ahw.pci_func;
-
-	if (adapter->msi_mode != MSI_MODE_MULTIFUNC)
-		adapter->pci_write_normalize(adapter,
-				adapter->crb_intr_mask, 0);
-
-	if (adapter->intr_scheme != -1 &&
-	    adapter->intr_scheme != INTR_SCHEME_PERPORT)
-		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
-
-	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
-		do {
-			adapter->pci_write_immediate(adapter,
-					adapter->legacy_intr.tgt_status_reg,
-					0xffffffff);
-			mask = adapter->pci_read_immediate(adapter,
-					ISR_INT_VECTOR);
-			if (!(mask & 0x80))
-				break;
-			udelay(10);
-		} while (--retries);
-
-		if (!retries) {
-			printk(KERN_NOTICE "%s: Failed to disable interrupt\n",
-					netxen_nic_driver_name);
-		}
-	} else {
-		if (adapter->msi_mode == MSI_MODE_MULTIFUNC) {
-			adapter->pci_write_immediate(adapter,
-					msi_tgt_status[pci_fn], 0xffffffff);
-		}
-	}
+	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0);
 }
 
-static void netxen_nic_enable_int(struct netxen_adapter *adapter)
+static inline void netxen_nic_enable_int(struct netxen_adapter *adapter)
 {
-	u32 mask;
-
-	if (adapter->intr_scheme != -1 &&
-		adapter->intr_scheme != INTR_SCHEME_PERPORT) {
-		switch (adapter->ahw.board_type) {
-		case NETXEN_NIC_GBE:
-			mask  =  0x77b;
-			break;
-		case NETXEN_NIC_XGBE:
-			mask  =  0x77f;
-			break;
-		default:
-			mask  =  0x7ff;
-			break;
-		}
-
-		adapter->pci_write_immediate(adapter, ISR_INT_MASK, mask);
-	}
-
 	adapter->pci_write_normalize(adapter, adapter->crb_intr_mask, 0x1);
 
-	if (!NETXEN_IS_MSI_FAMILY(adapter)) {
-		mask = 0xbff;
-		if (adapter->intr_scheme == INTR_SCHEME_PERPORT)
-			adapter->pci_write_immediate(adapter,
-				adapter->legacy_intr.tgt_mask_reg, mask);
-		else
-			adapter->pci_write_normalize(adapter,
-					CRB_INT_VECTOR, 0);
-	}
+	if (!NETXEN_IS_MSI_FAMILY(adapter))
+		adapter->pci_write_immediate(adapter,
+				adapter->legacy_intr.tgt_mask_reg, 0xfbff);
 }
 
 static int nx_set_dma_mask(struct netxen_adapter *adapter, uint8_t revision_id)
@@ -501,6 +443,44 @@ static void netxen_init_msix_entries(struct netxen_adapter *adapter)
 		adapter->msix_entries[i].entry = i;
 }
 
+static int
+netxen_read_mac_addr(struct netxen_adapter *adapter)
+{
+	int i;
+	unsigned char *p;
+	__le64 mac_addr;
+	DECLARE_MAC_BUF(mac);
+	struct net_device *netdev = adapter->netdev;
+	struct pci_dev *pdev = adapter->pdev;
+
+	if (netxen_is_flash_supported(adapter) != 0)
+		return -EIO;
+
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
+		if (netxen_p3_get_mac_addr(adapter, &mac_addr) != 0)
+			return -EIO;
+	} else {
+		if (netxen_get_flash_mac_addr(adapter, &mac_addr) != 0)
+			return -EIO;
+	}
+
+	p = (unsigned char *)&mac_addr;
+	for (i = 0; i < 6; i++)
+		netdev->dev_addr[i] = *(p + 5 - i);
+
+	memcpy(netdev->perm_addr, netdev->dev_addr, netdev->addr_len);
+
+	/* set station address */
+
+	if (!is_valid_ether_addr(netdev->perm_addr)) {
+		dev_warn(&pdev->dev, "Bad MAC address %s.\n",
+				print_mac(mac, netdev->dev_addr));
+	} else
+		adapter->macaddr_set(adapter, netdev->dev_addr);
+
+	return 0;
+}
+
 /*
  * netxen_nic_probe()
  *
@@ -529,10 +509,8 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 	unsigned long mem_base, mem_len, db_base, db_len, pci_len0 = 0;
 	int i = 0, err;
 	int first_driver, first_boot;
-	__le64 mac_addr[FLASH_NUM_PORTS + 1];
 	u32 val;
 	int pci_func_id = PCI_FUNC(pdev->devfn);
-	DECLARE_MAC_BUF(mac);
 	struct netxen_legacy_intr_set *legacy_intrp;
 	uint8_t revision_id;
 
@@ -545,6 +523,13 @@ netxen_nic_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
 		return -ENODEV;
 	}
 
+	if (pdev->revision >= NX_P3_A0 && pdev->revision < NX_P3_B1) {
+		printk(KERN_WARNING "NetXen chip revisions between 0x%x-0x%x"
+				"will not be enabled.\n",
+				NX_P3_A0, NX_P3_B1);
+		return -ENODEV;
+	}
+
 	if ((err = pci_enable_device(pdev)))
 		return err;
 
@@ -898,34 +883,14 @@ request_msi:
 		goto err_out_disable_msi;
 
 	init_timer(&adapter->watchdog_timer);
-	adapter->ahw.linkup = 0;
 	adapter->watchdog_timer.function = &netxen_watchdog;
 	adapter->watchdog_timer.data = (unsigned long)adapter;
 	INIT_WORK(&adapter->watchdog_task, netxen_watchdog_task);
 	INIT_WORK(&adapter->tx_timeout_task, netxen_tx_timeout_task);
 
-	if (netxen_is_flash_supported(adapter) == 0 &&
-			netxen_get_flash_mac_addr(adapter, mac_addr) == 0) {
-		unsigned char *p;
-
-		p = (unsigned char *)&mac_addr[adapter->portnum];
-		netdev->dev_addr[0] = *(p + 5);
-		netdev->dev_addr[1] = *(p + 4);
-		netdev->dev_addr[2] = *(p + 3);
-		netdev->dev_addr[3] = *(p + 2);
-		netdev->dev_addr[4] = *(p + 1);
-		netdev->dev_addr[5] = *(p + 0);
-
-		memcpy(netdev->perm_addr, netdev->dev_addr,
-			netdev->addr_len);
-		if (!is_valid_ether_addr(netdev->perm_addr)) {
-			printk(KERN_ERR "%s: Bad MAC address %s.\n",
-					netxen_nic_driver_name,
-					print_mac(mac, netdev->dev_addr));
-		} else {
-			adapter->macaddr_set(adapter, netdev->dev_addr);
-		}
-	}
+	err = netxen_read_mac_addr(adapter);
+	if (err)
+		dev_warn(&pdev->dev, "failed to read mac addr\n");
 
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
@@ -1000,6 +965,7 @@ static void __devexit netxen_nic_remove(struct pci_dev *pdev)
 
 	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
 		netxen_free_hw_resources(adapter);
+		netxen_release_rx_buffers(adapter);
 		netxen_free_sw_resources(adapter);
 	}
 
@@ -1069,6 +1035,15 @@ static int netxen_nic_open(struct net_device *netdev)
 			goto err_out_free_sw;
 		}
 
+		if ((adapter->msi_mode != MSI_MODE_MULTIFUNC) ||
+			(adapter->intr_scheme != INTR_SCHEME_PERPORT)) {
+			printk(KERN_ERR "%s: Firmware interrupt scheme is "
+					"incompatible with driver\n",
+					netdev->name);
+			adapter->driver_mismatch = 1;
+			goto err_out_free_hw;
+		}
+
 		if (adapter->fw_major < 4) {
 			adapter->crb_addr_cmd_producer =
 				crb_cmd_producer[adapter->portnum];
@@ -1094,7 +1069,7 @@ static int netxen_nic_open(struct net_device *netdev)
 				  flags, netdev->name, adapter);
 		if (err) {
 			printk(KERN_ERR "request_irq failed with: %d\n", err);
-			goto err_out_free_hw;
+			goto err_out_free_rxbuf;
 		}
 
 		adapter->is_up = NETXEN_ADAPTER_UP_MAGIC;
@@ -1116,6 +1091,7 @@ static int netxen_nic_open(struct net_device *netdev)
 	if (adapter->set_mtu)
 		adapter->set_mtu(adapter, netdev->mtu);
 
+	adapter->ahw.linkup = 0;
 	mod_timer(&adapter->watchdog_timer, jiffies);
 
 	napi_enable(&adapter->napi);
@@ -1127,6 +1103,8 @@ static int netxen_nic_open(struct net_device *netdev)
 
 err_out_free_irq:
 	free_irq(adapter->irq, adapter);
+err_out_free_rxbuf:
+	netxen_release_rx_buffers(adapter);
 err_out_free_hw:
 	netxen_free_hw_resources(adapter);
 err_out_free_sw:
@@ -1152,10 +1130,8 @@ static int netxen_nic_close(struct net_device *netdev)
 
 	netxen_release_tx_buffers(adapter);
 
-	if (adapter->is_up == NETXEN_ADAPTER_UP_MAGIC) {
-		FLUSH_SCHEDULED_WORK();
-		del_timer_sync(&adapter->watchdog_timer);
-	}
+	FLUSH_SCHEDULED_WORK();
+	del_timer_sync(&adapter->watchdog_timer);
 
 	return 0;
 }
@@ -1458,7 +1434,8 @@ void netxen_watchdog_task(struct work_struct *work)
 
 	netxen_nic_handle_phy_intr(adapter);
 
-	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
+	if (netif_running(adapter->netdev))
+		mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
 }
 
 static void netxen_tx_timeout(struct net_device *netdev)
@@ -1518,18 +1495,9 @@ struct net_device_stats *netxen_nic_get_stats(struct net_device *netdev)
 	return stats;
 }
 
-static inline void
-netxen_handle_int(struct netxen_adapter *adapter)
-{
-	netxen_nic_disable_int(adapter);
-	napi_schedule(&adapter->napi);
-}
-
 static irqreturn_t netxen_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
-	u32 our_int = 0;
-
 	u32 status = 0;
 
 	status = adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
@@ -1544,22 +1512,32 @@ static irqreturn_t netxen_intr(int irq, void *data)
 		if (!ISR_LEGACY_INT_TRIGGERED(status))
 			return IRQ_NONE;
 
-	} else if (NX_IS_REVISION_P2(adapter->ahw.revision_id)) {
+	} else {
+		unsigned long our_int = 0;
 
 		our_int = adapter->pci_read_normalize(adapter, CRB_INT_VECTOR);
+
 		/* not our interrupt */
-		if ((our_int & (0x80 << adapter->portnum)) == 0)
+		if (!test_and_clear_bit((7 + adapter->portnum), &our_int))
 			return IRQ_NONE;
 
-		if (adapter->intr_scheme == INTR_SCHEME_PERPORT) {
-			/* claim interrupt */
-			adapter->pci_write_normalize(adapter,
-				CRB_INT_VECTOR,
-				our_int & ~((u32)(0x80 << adapter->portnum)));
-		}
+		/* claim interrupt */
+		adapter->pci_write_normalize(adapter,
+				CRB_INT_VECTOR, (our_int & 0xffffffff));
 	}
 
-	netxen_handle_int(adapter);
+	/* clear interrupt */
+	if (adapter->fw_major < 4)
+		netxen_nic_disable_int(adapter);
+
+	adapter->pci_write_immediate(adapter,
+			adapter->legacy_intr.tgt_status_reg,
+			0xffffffff);
+	/* read twice to ensure write is flushed */
+	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+	adapter->pci_read_immediate(adapter, ISR_INT_VECTOR);
+
+	napi_schedule(&adapter->napi);
 
 	return IRQ_HANDLED;
 }
@@ -1568,7 +1546,11 @@ static irqreturn_t netxen_msi_intr(int irq, void *data)
 {
 	struct netxen_adapter *adapter = data;
 
-	netxen_handle_int(adapter);
+	/* clear interrupt */
+	adapter->pci_write_immediate(adapter,
+			msi_tgt_status[adapter->ahw.pci_func], 0xffffffff);
+
+	napi_schedule(&adapter->napi);
 	return IRQ_HANDLED;
 }
 
diff --git a/drivers/net/netxen/netxen_nic_phan_reg.h b/drivers/net/netxen/netxen_nic_phan_reg.h
index 83e5ee5..b293adc 100644
--- a/drivers/net/netxen/netxen_nic_phan_reg.h
+++ b/drivers/net/netxen/netxen_nic_phan_reg.h
@@ -125,6 +125,8 @@
 #define CRB_SW_INT_MASK_2	   NETXEN_NIC_REG(0x1e4)
 #define CRB_SW_INT_MASK_3	   NETXEN_NIC_REG(0x1e8)
 
+#define CRB_MAC_BLOCK_START        NETXEN_CAM_RAM(0x1c0)
+
 /*
  * capabilities register, can be used to selectively enable/disable features
  * for backward compability
diff --git a/drivers/net/ppp_mppe.c b/drivers/net/ppp_mppe.c
index b35d794..88f03c9 100644
--- a/drivers/net/ppp_mppe.c
+++ b/drivers/net/ppp_mppe.c
@@ -46,7 +46,6 @@
 #include <linux/err.h>
 #include <linux/module.h>
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/types.h>
 #include <linux/slab.h>
diff --git a/drivers/net/pppol2tp.c b/drivers/net/pppol2tp.c
index f929882..ff175e8 100644
--- a/drivers/net/pppol2tp.c
+++ b/drivers/net/pppol2tp.c
@@ -61,7 +61,6 @@
  */
 
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/string.h>
 #include <linux/list.h>
 #include <asm/uaccess.h>
diff --git a/drivers/net/r6040.c b/drivers/net/r6040.c
index 6531ff5..5d86281 100644
--- a/drivers/net/r6040.c
+++ b/drivers/net/r6040.c
@@ -24,7 +24,6 @@
 
 #include <linux/kernel.h>
 #include <linux/module.h>
-#include <linux/version.h>
 #include <linux/moduleparam.h>
 #include <linux/string.h>
 #include <linux/timer.h>
diff --git a/drivers/net/sh_eth.c b/drivers/net/sh_eth.c
index 25e62cf..1c370e6 100644
--- a/drivers/net/sh_eth.c
+++ b/drivers/net/sh_eth.c
@@ -20,7 +20,6 @@
  *  the file called "COPYING".
  */
 
-#include <linux/version.h>
 #include <linux/init.h>
 #include <linux/dma-mapping.h>
 #include <linux/etherdevice.h>
diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7d29edc..e24b25c 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -24,7 +24,6 @@
 
 #include <linux/crc32.h>
 #include <linux/kernel.h>
-#include <linux/version.h>
 #include <linux/module.h>
 #include <linux/netdevice.h>
 #include <linux/dma-mapping.h>
@@ -666,11 +665,16 @@ static void sky2_phy_power_down(struct sky2_hw *hw, unsigned port)
 
 	if (hw->chip_id != CHIP_ID_YUKON_EC) {
 		if (hw->chip_id == CHIP_ID_YUKON_EC_U) {
-			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
+			/* select page 2 to access MAC control register */
+			gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 2);
 
+			ctrl = gm_phy_read(hw, port, PHY_MARV_PHY_CTRL);
 			/* enable Power Down */
 			ctrl |= PHY_M_PC_POW_D_ENA;
 			gm_phy_write(hw, port, PHY_MARV_PHY_CTRL, ctrl);
+
+			/* set page register back to 0 */
+			gm_phy_write(hw, port, PHY_MARV_EXT_ADR, 0);
 		}
 
 		/* set IEEE compatible Power Down Mode (dev. #4.99) */
diff --git a/drivers/net/tehuti.h b/drivers/net/tehuti.h
index c66dfc9..7db48f1 100644
--- a/drivers/net/tehuti.h
+++ b/drivers/net/tehuti.h
@@ -27,7 +27,6 @@
 #include <linux/sched.h>
 #include <linux/tty.h>
 #include <linux/if_vlan.h>
-#include <linux/version.h>
 #include <linux/interrupt.h>
 #include <linux/vmalloc.h>
 #include <asm/byteorder.h>
diff --git a/drivers/net/tlan.c b/drivers/net/tlan.c
index 85246ed..ec871f6 100644
--- a/drivers/net/tlan.c
+++ b/drivers/net/tlan.c
@@ -360,8 +360,8 @@ TLan_GetSKB( const struct tlan_list_tag *tag)
 {
 	unsigned long addr;
 
-	addr = tag->buffer[8].address;
-	addr |= (tag->buffer[9].address << 16) << 16;
+	addr = tag->buffer[9].address;
+	addr |= (tag->buffer[8].address << 16) << 16;
 	return (struct sk_buff *) addr;
 }
 
@@ -1984,7 +1984,6 @@ static void TLan_ResetLists( struct net_device *dev )
 	TLanList	*list;
 	dma_addr_t	list_phys;
 	struct sk_buff	*skb;
-	void		*t = NULL;
 
 	priv->txHead = 0;
 	priv->txTail = 0;
@@ -2022,7 +2021,8 @@ static void TLan_ResetLists( struct net_device *dev )
 			}
 
 			skb_reserve( skb, NET_IP_ALIGN );
-			list->buffer[0].address = pci_map_single(priv->pciDev, t,
+			list->buffer[0].address = pci_map_single(priv->pciDev,
+								 skb->data,
 								 TLAN_MAX_FRAME_SIZE,
 								 PCI_DMA_FROMDEVICE);
 			TLan_StoreSKB(list, skb);
diff --git a/drivers/net/typhoon.c b/drivers/net/typhoon.c
index 8549f11..734ce09 100644
--- a/drivers/net/typhoon.c
+++ b/drivers/net/typhoon.c
@@ -128,7 +128,6 @@ static const int multicast_filter_limit = 32;
 #include <asm/io.h>
 #include <asm/uaccess.h>
 #include <linux/in6.h>
-#include <linux/version.h>
 #include <linux/dma-mapping.h>
 
 #include "typhoon.h"
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 68e198b..0973b6e 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -154,17 +154,6 @@ config USB_NET_AX8817X
 	  This driver creates an interface named "ethX", where X depends on
 	  what other networking devices you have in use.
 
-config USB_HSO
-	tristate "Option USB High Speed Mobile Devices"
-	depends on USB && RFKILL
-	default n
-	help
-	  Choose this option if you have an Option HSDPA/HSUPA card.
-	  These cards support downlink speeds of 7.2Mbps or greater.
-
-	  To compile this driver as a module, choose M here: the
-	  module will be called hso.
-
 config USB_NET_CDCETHER
 	tristate "CDC Ethernet support (smart devices such as cable modems)"
 	depends on USB_USBNET
@@ -337,5 +326,15 @@ config USB_NET_ZAURUS
 	  really need this non-conformant variant of CDC Ethernet (or in
 	  some cases CDC MDLM) protocol, not "g_ether".
 
+config USB_HSO
+	tristate "Option USB High Speed Mobile Devices"
+	depends on USB && RFKILL
+	default n
+	help
+	  Choose this option if you have an Option HSDPA/HSUPA card.
+	  These cards support downlink speeds of 7.2Mbps or greater.
+
+	  To compile this driver as a module, choose M here: the
+	  module will be called hso.
 
 endmenu
diff --git a/drivers/net/usb/hso.c b/drivers/net/usb/hso.c
index 031d07b..1b7cac7 100644
--- a/drivers/net/usb/hso.c
+++ b/drivers/net/usb/hso.c
@@ -102,8 +102,12 @@
 
 #define MAX_RX_URBS			2
 
-#define get_serial_by_tty(x)	\
-	(x ? (struct hso_serial *)x->driver_data : NULL)
+static inline struct hso_serial *get_serial_by_tty(struct tty_struct *tty)
+{
+	if (tty)
+		return tty->driver_data;
+	return NULL;
+}
 
 /*****************************************************************************/
 /* Debugging functions                                                       */
@@ -294,24 +298,25 @@ static int hso_get_activity(struct hso_device *hso_dev);
 
 /* #define DEBUG */
 
-#define dev2net(x) (x->port_data.dev_net)
-#define dev2ser(x) (x->port_data.dev_serial)
+static inline struct hso_net *dev2net(struct hso_device *hso_dev)
+{
+	return hso_dev->port_data.dev_net;
+}
+
+static inline struct hso_serial *dev2ser(struct hso_device *hso_dev)
+{
+	return hso_dev->port_data.dev_serial;
+}
 
 /* Debugging functions */
 #ifdef DEBUG
 static void dbg_dump(int line_count, const char *func_name, unsigned char *buf,
 		     unsigned int len)
 {
-	u8 i = 0;
+	static char name[255];
 
-	printk(KERN_DEBUG "[%d:%s]: len %d", line_count, func_name, len);
-
-	for (i = 0; i < len; i++) {
-		if (!(i % 16))
-			printk("\n    0x%03x:  ", i);
-		printk("%02x ", (unsigned char)buf[i]);
-	}
-	printk("\n");
+	sprintf(name, "hso[%d:%s]", line_count, func_name);
+	print_hex_dump_bytes(name, DUMP_PREFIX_NONE, buf, len);
 }
 
 #define DUMP(buf_, len_)	\
@@ -528,13 +533,12 @@ static struct hso_serial *get_serial_by_shared_int_and_type(
 
 static struct hso_serial *get_serial_by_index(unsigned index)
 {
-	struct hso_serial *serial;
+	struct hso_serial *serial = NULL;
 	unsigned long flags;
 
-	if (!serial_table[index])
-		return NULL;
 	spin_lock_irqsave(&serial_table_lock, flags);
-	serial = dev2ser(serial_table[index]);
+	if (serial_table[index])
+		serial = dev2ser(serial_table[index]);
 	spin_unlock_irqrestore(&serial_table_lock, flags);
 
 	return serial;
@@ -561,6 +565,7 @@ static int get_free_serial_index(void)
 static void set_serial_by_index(unsigned index, struct hso_serial *serial)
 {
 	unsigned long flags;
+
 	spin_lock_irqsave(&serial_table_lock, flags);
 	if (serial)
 		serial_table[index] = serial->parent;
@@ -569,7 +574,7 @@ static void set_serial_by_index(unsigned index, struct hso_serial *serial)
 	spin_unlock_irqrestore(&serial_table_lock, flags);
 }
 
-/* log a meaningfull explanation of an USB status */
+/* log a meaningful explanation of an USB status */
 static void log_usb_status(int status, const char *function)
 {
 	char *explanation;
@@ -1103,8 +1108,8 @@ static void hso_serial_close(struct tty_struct *tty, struct file *filp)
 	/* reset the rts and dtr */
 	/* do the actual close */
 	serial->open_count--;
+	kref_put(&serial->parent->ref, hso_serial_ref_free);
 	if (serial->open_count <= 0) {
-		kref_put(&serial->parent->ref, hso_serial_ref_free);
 		serial->open_count = 0;
 		if (serial->tty) {
 			serial->tty->driver_data = NULL;
@@ -1467,7 +1472,8 @@ static void hso_std_serial_write_bulk_callback(struct urb *urb)
 		return;
 	}
 	hso_put_activity(serial->parent);
-	tty_wakeup(serial->tty);
+	if (serial->tty)
+		tty_wakeup(serial->tty);
 	hso_kick_transmit(serial);
 
 	D1(" ");
@@ -1538,7 +1544,8 @@ static void ctrl_callback(struct urb *urb)
 			clear_bit(HSO_SERIAL_FLAG_RX_SENT, &serial->flags);
 	} else {
 		hso_put_activity(serial->parent);
-		tty_wakeup(serial->tty);
+		if (serial->tty)
+			tty_wakeup(serial->tty);
 		/* response to a write command */
 		hso_kick_transmit(serial);
 	}
@@ -2652,7 +2659,7 @@ static void hso_free_interface(struct usb_interface *interface)
 			hso_stop_net_device(network_table[i]);
 			cancel_work_sync(&network_table[i]->async_put_intf);
 			cancel_work_sync(&network_table[i]->async_get_intf);
-			if(rfk)
+			if (rfk)
 				rfkill_unregister(rfk);
 			hso_free_net_device(network_table[i]);
 		}
@@ -2723,7 +2730,7 @@ static int hso_mux_submit_intr_urb(struct hso_shared_int *shared_int,
 }
 
 /* operations setup of the serial interface */
-static struct tty_operations hso_serial_ops = {
+static const struct tty_operations hso_serial_ops = {
 	.open = hso_serial_open,
 	.close = hso_serial_close,
 	.write = hso_serial_write,
