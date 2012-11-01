From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next 3/3] ptp: Enable clock drivers along with
 associated net/PHY drivers
Date: Thu, 1 Nov 2012 01:33:52 +0000
Message-ID: <1351733632.2706.65.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>,
	Rodolfo Giometti <giometti@enneenne.com>,
	Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64046 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752792Ab2KABd4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Oct 2012 21:33:56 -0400
In-Reply-To: <1351733397.2706.62.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Where a PTP clock driver is associated with a net or PHY driver, it
should be enabled automatically whenever that driver is enabled.
Therefore:

- Make PTP clock drivers select rather than depending on PTP_1588_CLOCK
- Remove separate boolean options for PTP clock drivers that are built
  as part of net driver modules.  (This also fixes cases where the PTP
  subsystem is wrongly forced to be built-in.)
- Set 'default y' for PTP clock drivers that depend on specific net
  drivers but are built separately

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 drivers/net/ethernet/intel/Kconfig                 |   26 +-----------------
 drivers/net/ethernet/intel/igb/Makefile            |    4 +--
 drivers/net/ethernet/intel/igb/igb.h               |    6 ----
 drivers/net/ethernet/intel/igb/igb_ethtool.c       |    2 -
 drivers/net/ethernet/intel/igb/igb_main.c          |   28 --------------------
 drivers/net/ethernet/intel/ixgbe/Makefile          |    3 +-
 drivers/net/ethernet/intel/ixgbe/ixgbe.h           |    6 ----
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c   |    2 -
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c      |   28 --------------------
 drivers/net/ethernet/oki-semi/pch_gbe/Kconfig      |   14 ----------
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h    |    2 -
 .../net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c   |   14 ----------
 drivers/net/ethernet/sfc/Kconfig                   |    7 -----
 drivers/net/ethernet/sfc/Makefile                  |    3 +-
 drivers/net/ethernet/sfc/net_driver.h              |    2 -
 drivers/net/ethernet/sfc/nic.h                     |   26 ------------------
 drivers/ptp/Kconfig                                |   13 +++++---
 17 files changed, 13 insertions(+), 173 deletions(-)

diff --git a/drivers/net/ethernet/intel/Kconfig b/drivers/net/ethernet/intel/Kconfig
index d5b359d..73d28d5 100644
--- a/drivers/net/ethernet/intel/Kconfig
+++ b/drivers/net/ethernet/intel/Kconfig
@@ -93,6 +93,7 @@ config E1000E
 config IGB
 	tristate "Intel(R) 82575/82576 PCI-Express Gigabit Ethernet support"
 	depends on PCI
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports Intel(R) 82575/82576 gigabit ethernet family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -120,18 +121,6 @@ config IGB_DCA
 	  driver.  DCA is a method for warming the CPU cache before data
 	  is used, with the intent of lessening the impact of cache misses.
 
-config IGB_PTP
-	bool "PTP Hardware Clock (PHC)"
-	default n
-	depends on IGB
-	select PTP_1588_CLOCK
-	---help---
-	  Say Y here if you want to use PTP Hardware Clock (PHC) in the
-	  driver.  Only the basic clock operations have been implemented.
-
-	  Every timestamp and clock read operations must consult the
-	  overflow counter to form a correct time value.
-
 config IGBVF
 	tristate "Intel(R) 82576 Virtual Function Ethernet support"
 	depends on PCI
@@ -179,6 +168,7 @@ config IXGBE
 	tristate "Intel(R) 10GbE PCI Express adapters support"
 	depends on PCI && INET
 	select MDIO
+	select PTP_1588_CLOCK
 	---help---
 	  This driver supports Intel(R) 10GbE PCI Express family of
 	  adapters.  For more information on how to identify your adapter, go
@@ -221,18 +211,6 @@ config IXGBE_DCB
 
 	  If unsure, say N.
 
-config IXGBE_PTP
-	bool "PTP Clock Support"
-	default n
-	depends on IXGBE
-	select PTP_1588_CLOCK
-	---help---
-	  Say Y here if you want support for 1588 Timestamping with a
-	  PHC device, using the PTP 1588 Clock support. This is
-	  required to enable timestamping support for the device.
-
-	  If unsure, say N.
-
 config IXGBEVF
 	tristate "Intel(R) 82599 Virtual Function Ethernet support"
 	depends on PCI_MSI
diff --git a/drivers/net/ethernet/intel/igb/Makefile b/drivers/net/ethernet/intel/igb/Makefile
index 97c197f..624476c 100644
--- a/drivers/net/ethernet/intel/igb/Makefile
+++ b/drivers/net/ethernet/intel/igb/Makefile
@@ -34,6 +34,4 @@ obj-$(CONFIG_IGB) += igb.o
 
 igb-objs := igb_main.o igb_ethtool.o e1000_82575.o \
 	    e1000_mac.o e1000_nvm.o e1000_phy.o e1000_mbx.o \
-	    e1000_i210.o
-
-igb-$(CONFIG_IGB_PTP) += igb_ptp.o
+	    e1000_i210.o igb_ptp.o
diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
index be1971b..796db53 100644
--- a/drivers/net/ethernet/intel/igb/igb.h
+++ b/drivers/net/ethernet/intel/igb/igb.h
@@ -34,11 +34,9 @@
 #include "e1000_mac.h"
 #include "e1000_82575.h"
 
-#ifdef CONFIG_IGB_PTP
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
-#endif /* CONFIG_IGB_PTP */
 #include <linux/bitops.h>
 #include <linux/if_vlan.h>
 
@@ -376,7 +374,6 @@ struct igb_adapter {
 	u32 wvbr;
 	u32 *shadow_vfta;
 
-#ifdef CONFIG_IGB_PTP
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	struct delayed_work ptp_overflow_work;
@@ -385,7 +382,6 @@ struct igb_adapter {
 	spinlock_t tmreg_lock;
 	struct cyclecounter cc;
 	struct timecounter tc;
-#endif /* CONFIG_IGB_PTP */
 
 	char fw_version[32];
 };
@@ -439,7 +435,6 @@ extern bool igb_has_link(struct igb_adapter *adapter);
 extern void igb_set_ethtool_ops(struct net_device *);
 extern void igb_power_up_link(struct igb_adapter *);
 extern void igb_set_fw_version(struct igb_adapter *);
-#ifdef CONFIG_IGB_PTP
 extern void igb_ptp_init(struct igb_adapter *adapter);
 extern void igb_ptp_stop(struct igb_adapter *adapter);
 extern void igb_ptp_reset(struct igb_adapter *adapter);
@@ -461,7 +456,6 @@ static inline void igb_ptp_rx_hwtstamp(struct igb_q_vector *q_vector,
 
 extern int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
 				  struct ifreq *ifr, int cmd);
-#endif /* CONFIG_IGB_PTP */
 
 static inline s32 igb_reset_phy(struct e1000_hw *hw)
 {
diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
index 375c0da..d8b1bee 100644
--- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
+++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
@@ -2310,7 +2310,6 @@ static int igb_get_ts_info(struct net_device *dev,
 	struct igb_adapter *adapter = netdev_priv(dev);
 
 	switch (adapter->hw.mac.type) {
-#ifdef CONFIG_IGB_PTP
 	case e1000_82576:
 	case e1000_82580:
 	case e1000_i350:
@@ -2346,7 +2345,6 @@ static int igb_get_ts_info(struct net_device *dev,
 				(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 
 		return 0;
-#endif /* CONFIG_IGB_PTP */
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index df1e790..082ce73 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -1708,10 +1708,8 @@ void igb_reset(struct igb_adapter *adapter)
 	/* Enable h/w to recognize an 802.1Q VLAN Ethernet packet */
 	wr32(E1000_VET, ETHERNET_IEEE_VLAN_TYPE);
 
-#ifdef CONFIG_IGB_PTP
 	/* Re-enable PTP, where applicable. */
 	igb_ptp_reset(adapter);
-#endif /* CONFIG_IGB_PTP */
 
 	igb_get_phy_info(hw);
 }
@@ -2119,10 +2117,8 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 
 #endif
 
-#ifdef CONFIG_IGB_PTP
 	/* do hw tstamp init after resetting */
 	igb_ptp_init(adapter);
-#endif /* CONFIG_IGB_PTP */
 
 	dev_info(&pdev->dev, "Intel(R) Gigabit Ethernet Network Connection\n");
 	/* print bus type/speed/width info */
@@ -2197,9 +2193,7 @@ static void __devexit igb_remove(struct pci_dev *pdev)
 	struct e1000_hw *hw = &adapter->hw;
 
 	pm_runtime_get_noresume(&pdev->dev);
-#ifdef CONFIG_IGB_PTP
 	igb_ptp_stop(adapter);
-#endif /* CONFIG_IGB_PTP */
 
 	/*
 	 * The watchdog timer may be rescheduled, so explicitly
@@ -3095,10 +3089,8 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
 	srrctl = IGB_RX_HDR_LEN << E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;
 	srrctl |= IGB_RX_BUFSZ >> E1000_SRRCTL_BSIZEPKT_SHIFT;
 	srrctl |= E1000_SRRCTL_DESCTYPE_ADV_ONEBUF;
-#ifdef CONFIG_IGB_PTP
 	if (hw->mac.type >= e1000_82580)
 		srrctl |= E1000_SRRCTL_TIMESTAMP;
-#endif /* CONFIG_IGB_PTP */
 	/* Only set Drop Enable if we are supporting multiple queues */
 	if (adapter->vfs_allocated_count || adapter->num_rx_queues > 1)
 		srrctl |= E1000_SRRCTL_DROP_EN;
@@ -4134,11 +4126,9 @@ static __le32 igb_tx_cmd_type(u32 tx_flags)
 	if (tx_flags & IGB_TX_FLAGS_VLAN)
 		cmd_type |= cpu_to_le32(E1000_ADVTXD_DCMD_VLE);
 
-#ifdef CONFIG_IGB_PTP
 	/* set timestamp bit if present */
 	if (unlikely(tx_flags & IGB_TX_FLAGS_TSTAMP))
 		cmd_type |= cpu_to_le32(E1000_ADVTXD_MAC_TSTAMP);
-#endif /* CONFIG_IGB_PTP */
 
 	/* set segmentation bits for TSO */
 	if (tx_flags & IGB_TX_FLAGS_TSO)
@@ -4347,9 +4337,7 @@ static inline int igb_maybe_stop_tx(struct igb_ring *tx_ring, const u16 size)
 netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 				struct igb_ring *tx_ring)
 {
-#ifdef CONFIG_IGB_PTP
 	struct igb_adapter *adapter = netdev_priv(tx_ring->netdev);
-#endif /* CONFIG_IGB_PTP */
 	struct igb_tx_buffer *first;
 	int tso;
 	u32 tx_flags = 0;
@@ -4372,7 +4360,6 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 	first->bytecount = skb->len;
 	first->gso_segs = 1;
 
-#ifdef CONFIG_IGB_PTP
 	if (unlikely((skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP) &&
 		     !(adapter->ptp_tx_skb))) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
@@ -4382,7 +4369,6 @@ netdev_tx_t igb_xmit_frame_ring(struct sk_buff *skb,
 		if (adapter->hw.mac.type == e1000_82576)
 			schedule_work(&adapter->ptp_tx_work);
 	}
-#endif /* CONFIG_IGB_PTP */
 
 	if (vlan_tx_tag_present(skb)) {
 		tx_flags |= IGB_TX_FLAGS_VLAN;
@@ -4776,7 +4762,6 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-#ifdef CONFIG_IGB_PTP
 	if (icr & E1000_ICR_TS) {
 		u32 tsicr = rd32(E1000_TSICR);
 
@@ -4787,7 +4772,6 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 			schedule_work(&adapter->ptp_tx_work);
 		}
 	}
-#endif /* CONFIG_IGB_PTP */
 
 	wr32(E1000_EIMS, adapter->eims_other);
 
@@ -5539,7 +5523,6 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-#ifdef CONFIG_IGB_PTP
 	if (icr & E1000_ICR_TS) {
 		u32 tsicr = rd32(E1000_TSICR);
 
@@ -5550,7 +5533,6 @@ static irqreturn_t igb_intr_msi(int irq, void *data)
 			schedule_work(&adapter->ptp_tx_work);
 		}
 	}
-#endif /* CONFIG_IGB_PTP */
 
 	napi_schedule(&q_vector->napi);
 
@@ -5593,7 +5575,6 @@ static irqreturn_t igb_intr(int irq, void *data)
 			mod_timer(&adapter->watchdog_timer, jiffies + 1);
 	}
 
-#ifdef CONFIG_IGB_PTP
 	if (icr & E1000_ICR_TS) {
 		u32 tsicr = rd32(E1000_TSICR);
 
@@ -5604,7 +5585,6 @@ static irqreturn_t igb_intr(int irq, void *data)
 			schedule_work(&adapter->ptp_tx_work);
 		}
 	}
-#endif /* CONFIG_IGB_PTP */
 
 	napi_schedule(&q_vector->napi);
 
@@ -5889,14 +5869,12 @@ static bool igb_add_rx_frag(struct igb_ring *rx_ring,
 	if ((size <= IGB_RX_HDR_LEN) && !skb_is_nonlinear(skb)) {
 		unsigned char *va = page_address(page) + rx_buffer->page_offset;
 
-#ifdef CONFIG_IGB_PTP
 		if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
 			igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
 			va += IGB_TS_HDR_LEN;
 			size -= IGB_TS_HDR_LEN;
 		}
 
-#endif
 		memcpy(__skb_put(skb, size), va, ALIGN(size, sizeof(long)));
 
 		/* we can reuse buffer as-is, just make sure it is local */
@@ -6221,7 +6199,6 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
 	 */
 	va = skb_frag_address(frag);
 
-#ifdef CONFIG_IGB_PTP
 	if (igb_test_staterr(rx_desc, E1000_RXDADV_STAT_TSIP)) {
 		/* retrieve timestamp from buffer */
 		igb_ptp_rx_pktstamp(rx_ring->q_vector, va, skb);
@@ -6236,7 +6213,6 @@ static void igb_pull_tail(struct igb_ring *rx_ring,
 		va += IGB_TS_HDR_LEN;
 	}
 
-#endif
 	/*
 	 * we need the header to contain the greater of either ETH_HLEN or
 	 * 60 bytes if the skb->len is less than 60 for skb_pad.
@@ -6317,9 +6293,7 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 
 	igb_rx_checksum(rx_ring, rx_desc, skb);
 
-#ifdef CONFIG_IGB_PTP
 	igb_ptp_rx_hwtstamp(rx_ring->q_vector, rx_desc, skb);
-#endif /* CONFIG_IGB_PTP */
 
 	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
 	    igb_test_staterr(rx_desc, E1000_RXD_STAT_VP)) {
@@ -6553,10 +6527,8 @@ static int igb_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 	case SIOCGMIIREG:
 	case SIOCSMIIREG:
 		return igb_mii_ioctl(netdev, ifr, cmd);
-#ifdef CONFIG_IGB_PTP
 	case SIOCSHWTSTAMP:
 		return igb_ptp_hwtstamp_ioctl(netdev, ifr, cmd);
-#endif /* CONFIG_IGB_PTP */
 	default:
 		return -EOPNOTSUPP;
 	}
diff --git a/drivers/net/ethernet/intel/ixgbe/Makefile b/drivers/net/ethernet/intel/ixgbe/Makefile
index 89f40e5..f3a632b 100644
--- a/drivers/net/ethernet/intel/ixgbe/Makefile
+++ b/drivers/net/ethernet/intel/ixgbe/Makefile
@@ -34,11 +34,10 @@ obj-$(CONFIG_IXGBE) += ixgbe.o
 
 ixgbe-objs := ixgbe_main.o ixgbe_common.o ixgbe_ethtool.o ixgbe_debugfs.o\
               ixgbe_82599.o ixgbe_82598.o ixgbe_phy.o ixgbe_sriov.o \
-              ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o
+              ixgbe_mbx.o ixgbe_x540.o ixgbe_lib.o ixgbe_ptp.o
 
 ixgbe-$(CONFIG_IXGBE_DCB) +=  ixgbe_dcb.o ixgbe_dcb_82598.o \
                               ixgbe_dcb_82599.o ixgbe_dcb_nl.o
 
-ixgbe-$(CONFIG_IXGBE_PTP) += ixgbe_ptp.o
 ixgbe-$(CONFIG_IXGBE_HWMON) += ixgbe_sysfs.o
 ixgbe-$(CONFIG_FCOE:m=y) += ixgbe_fcoe.o
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe.h b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
index a17116b..7ff4c4f 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe.h
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe.h
@@ -36,11 +36,9 @@
 #include <linux/aer.h>
 #include <linux/if_vlan.h>
 
-#ifdef CONFIG_IXGBE_PTP
 #include <linux/clocksource.h>
 #include <linux/net_tstamp.h>
 #include <linux/ptp_clock_kernel.h>
-#endif /* CONFIG_IXGBE_PTP */
 
 #include "ixgbe_type.h"
 #include "ixgbe_common.h"
@@ -572,7 +570,6 @@ struct ixgbe_adapter {
 	u32 interrupt_event;
 	u32 led_reg;
 
-#ifdef CONFIG_IXGBE_PTP
 	struct ptp_clock *ptp_clock;
 	struct ptp_clock_info ptp_caps;
 	unsigned long last_overflow_check;
@@ -581,7 +578,6 @@ struct ixgbe_adapter {
 	struct timecounter tc;
 	int rx_hwtstamp_filter;
 	u32 base_incval;
-#endif /* CONFIG_IXGBE_PTP */
 
 	/* SR-IOV */
 	DECLARE_BITMAP(active_vfs, IXGBE_MAX_VF_FUNCTIONS);
@@ -742,7 +738,6 @@ static inline struct netdev_queue *txring_txq(const struct ixgbe_ring *ring)
 	return netdev_get_tx_queue(ring->netdev, ring->queue_index);
 }
 
-#ifdef CONFIG_IXGBE_PTP
 extern void ixgbe_ptp_init(struct ixgbe_adapter *adapter);
 extern void ixgbe_ptp_stop(struct ixgbe_adapter *adapter);
 extern void ixgbe_ptp_overflow_check(struct ixgbe_adapter *adapter);
@@ -756,6 +751,5 @@ extern int ixgbe_ptp_hwtstamp_ioctl(struct ixgbe_adapter *adapter,
 extern void ixgbe_ptp_start_cyclecounter(struct ixgbe_adapter *adapter);
 extern void ixgbe_ptp_reset(struct ixgbe_adapter *adapter);
 extern void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr);
-#endif /* CONFIG_IXGBE_PTP */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
index 872c337..bbf07bd 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c
@@ -2667,7 +2667,6 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 	struct ixgbe_adapter *adapter = netdev_priv(dev);
 
 	switch (adapter->hw.mac.type) {
-#ifdef CONFIG_IXGBE_PTP
 	case ixgbe_mac_X540:
 	case ixgbe_mac_82599EB:
 		info->so_timestamping =
@@ -2690,7 +2689,6 @@ static int ixgbe_get_ts_info(struct net_device *dev,
 			(1 << HWTSTAMP_FILTER_PTP_V1_L4_DELAY_REQ) |
 			(1 << HWTSTAMP_FILTER_PTP_V2_EVENT);
 		break;
-#endif /* CONFIG_IXGBE_PTP */
 	default:
 		return ethtool_op_get_ts_info(dev, info);
 		break;
diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
index 26bfaae..e5f993e 100644
--- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
+++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
@@ -841,10 +841,8 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
 		total_bytes += tx_buffer->bytecount;
 		total_packets += tx_buffer->gso_segs;
 
-#ifdef CONFIG_IXGBE_PTP
 		if (unlikely(tx_buffer->tx_flags & IXGBE_TX_FLAGS_TSTAMP))
 			ixgbe_ptp_tx_hwtstamp(q_vector, tx_buffer->skb);
-#endif
 
 		/* free the skb */
 		dev_kfree_skb_any(tx_buffer->skb);
@@ -1432,9 +1430,7 @@ static void ixgbe_process_skb_fields(struct ixgbe_ring *rx_ring,
 
 	ixgbe_rx_checksum(rx_ring, rx_desc, skb);
 
-#ifdef CONFIG_IXGBE_PTP
 	ixgbe_ptp_rx_hwtstamp(rx_ring->q_vector, rx_desc, skb);
-#endif
 
 	if ((dev->features & NETIF_F_HW_VLAN_RX) &&
 	    ixgbe_test_staterr(rx_desc, IXGBE_RXD_STAT_VP)) {
@@ -2386,10 +2382,8 @@ static inline void ixgbe_irq_enable(struct ixgbe_adapter *adapter, bool queues,
 		break;
 	}
 
-#ifdef CONFIG_IXGBE_PTP
 	if (adapter->hw.mac.type == ixgbe_mac_X540)
 		mask |= IXGBE_EIMS_TIMESYNC;
-#endif
 
 	if ((adapter->flags & IXGBE_FLAG_FDIR_HASH_CAPABLE) &&
 	    !(adapter->flags2 & IXGBE_FLAG2_FDIR_REQUIRES_REINIT))
@@ -2455,10 +2449,8 @@ static irqreturn_t ixgbe_msix_other(int irq, void *data)
 
 	ixgbe_check_fan_failure(adapter, eicr);
 
-#ifdef CONFIG_IXGBE_PTP
 	if (unlikely(eicr & IXGBE_EICR_TIMESYNC))
 		ixgbe_ptp_check_pps_event(adapter, eicr);
-#endif
 
 	/* re-enable the original interrupt state, no lsc, no queues */
 	if (!test_bit(__IXGBE_DOWN, &adapter->state))
@@ -2650,10 +2642,8 @@ static irqreturn_t ixgbe_intr(int irq, void *data)
 	}
 
 	ixgbe_check_fan_failure(adapter, eicr);
-#ifdef CONFIG_IXGBE_PTP
 	if (unlikely(eicr & IXGBE_EICR_TIMESYNC))
 		ixgbe_ptp_check_pps_event(adapter, eicr);
-#endif
 
 	/* would disable interrupts here but EIAM disabled it */
 	napi_schedule(&q_vector->napi);
@@ -4251,10 +4241,8 @@ void ixgbe_reset(struct ixgbe_adapter *adapter)
 	if (hw->mac.san_mac_rar_index)
 		hw->mac.ops.set_vmdq_san_mac(hw, VMDQ_P(0));
 
-#ifdef CONFIG_IXGBE_PTP
 	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
 		ixgbe_ptp_reset(adapter);
-#endif
 }
 
 /**
@@ -4961,9 +4949,7 @@ static int ixgbe_open(struct net_device *netdev)
 	if (err)
 		goto err_set_queues;
 
-#ifdef CONFIG_IXGBE_PTP
 	ixgbe_ptp_init(adapter);
-#endif /* CONFIG_IXGBE_PTP*/
 
 	ixgbe_up_complete(adapter);
 
@@ -4996,9 +4982,7 @@ static int ixgbe_close(struct net_device *netdev)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
-#ifdef CONFIG_IXGBE_PTP
 	ixgbe_ptp_stop(adapter);
-#endif
 
 	ixgbe_down(adapter);
 	ixgbe_free_irq(adapter);
@@ -5561,10 +5545,8 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
 		break;
 	}
 
-#ifdef CONFIG_IXGBE_PTP
 	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
 		ixgbe_ptp_start_cyclecounter(adapter);
-#endif
 
 	e_info(drv, "NIC Link is Up %s, Flow Control: %s\n",
 	       (link_speed == IXGBE_LINK_SPEED_10GB_FULL ?
@@ -5609,10 +5591,8 @@ static void ixgbe_watchdog_link_is_down(struct ixgbe_adapter *adapter)
 	if (ixgbe_is_sfp(hw) && hw->mac.type == ixgbe_mac_82598EB)
 		adapter->flags2 |= IXGBE_FLAG2_SEARCH_FOR_SFP;
 
-#ifdef CONFIG_IXGBE_PTP
 	if (adapter->flags2 & IXGBE_FLAG2_PTP_ENABLED)
 		ixgbe_ptp_start_cyclecounter(adapter);
-#endif
 
 	e_info(drv, "NIC Link is Down\n");
 	netif_carrier_off(netdev);
@@ -5917,9 +5897,7 @@ static void ixgbe_service_task(struct work_struct *work)
 	ixgbe_watchdog_subtask(adapter);
 	ixgbe_fdir_reinit_subtask(adapter);
 	ixgbe_check_hang_subtask(adapter);
-#ifdef CONFIG_IXGBE_PTP
 	ixgbe_ptp_overflow_check(adapter);
-#endif
 
 	ixgbe_service_event_complete(adapter);
 }
@@ -6072,10 +6050,8 @@ static __le32 ixgbe_tx_cmd_type(u32 tx_flags)
 	if (tx_flags & IXGBE_TX_FLAGS_HW_VLAN)
 		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_DCMD_VLE);
 
-#ifdef CONFIG_IXGBE_PTP
 	if (tx_flags & IXGBE_TX_FLAGS_TSTAMP)
 		cmd_type |= cpu_to_le32(IXGBE_ADVTXD_MAC_TSTAMP);
-#endif
 
 	/* set segmentation enable bits for TSO/FSO */
 #ifdef IXGBE_FCOE
@@ -6477,12 +6453,10 @@ netdev_tx_t ixgbe_xmit_frame_ring(struct sk_buff *skb,
 
 	skb_tx_timestamp(skb);
 
-#ifdef CONFIG_IXGBE_PTP
 	if (unlikely(skb_shinfo(skb)->tx_flags & SKBTX_HW_TSTAMP)) {
 		skb_shinfo(skb)->tx_flags |= SKBTX_IN_PROGRESS;
 		tx_flags |= IXGBE_TX_FLAGS_TSTAMP;
 	}
-#endif
 
 #ifdef CONFIG_PCI_IOV
 	/*
@@ -6632,10 +6606,8 @@ static int ixgbe_ioctl(struct net_device *netdev, struct ifreq *req, int cmd)
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
 
 	switch (cmd) {
-#ifdef CONFIG_IXGBE_PTP
 	case SIOCSHWTSTAMP:
 		return ixgbe_ptp_hwtstamp_ioctl(adapter, req, cmd);
-#endif
 	default:
 		return mdio_mii_ioctl(&adapter->hw.phy.mdio, if_mii(req), cmd);
 	}
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
index d0e36f2..00bc4fc 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/Kconfig
@@ -20,17 +20,3 @@ config PCH_GBE
 	  purpose use.
 	  ML7223/ML7831 is companion chip for Intel Atom E6xx series.
 	  ML7223/ML7831 is completely compatible for Intel EG20T PCH.
-
-if PCH_GBE
-
-config PCH_PTP
-	bool "PCH PTP clock support"
-	default n
-	select PTP_1588_CLOCK
-	select PTP_1588_CLOCK_PCH
-	---help---
-	  Say Y here if you want to use Precision Time Protocol (PTP) in the
-	  driver. PTP is a method to precisely synchronize distributed clocks
-	  over Ethernet networks.
-
-endif # PCH_GBE
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index b07311e..7fb7e17 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -649,7 +649,6 @@ extern void pch_gbe_free_tx_resources(struct pch_gbe_adapter *adapter,
 extern void pch_gbe_free_rx_resources(struct pch_gbe_adapter *adapter,
 				       struct pch_gbe_rx_ring *rx_ring);
 extern void pch_gbe_update_stats(struct pch_gbe_adapter *adapter);
-#ifdef CONFIG_PCH_PTP
 extern u32 pch_ch_control_read(struct pci_dev *pdev);
 extern void pch_ch_control_write(struct pci_dev *pdev, u32 val);
 extern u32 pch_ch_event_read(struct pci_dev *pdev);
@@ -659,7 +658,6 @@ extern u32 pch_src_uuid_hi_read(struct pci_dev *pdev);
 extern u64 pch_rx_snap_read(struct pci_dev *pdev);
 extern u64 pch_tx_snap_read(struct pci_dev *pdev);
 extern int pch_set_station_address(u8 *addr, struct pci_dev *pdev);
-#endif
 
 /* pch_gbe_param.c */
 extern void pch_gbe_check_options(struct pch_gbe_adapter *adapter);
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index b2a94d0..499249a 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -21,10 +21,8 @@
 #include "pch_gbe.h"
 #include "pch_gbe_api.h"
 #include <linux/module.h>
-#ifdef CONFIG_PCH_PTP
 #include <linux/net_tstamp.h>
 #include <linux/ptp_classify.h>
-#endif
 
 #define DRV_VERSION     "1.01"
 const char pch_driver_version[] = DRV_VERSION;
@@ -98,7 +96,6 @@ const char pch_driver_version[] = DRV_VERSION;
 
 #define PCH_GBE_INT_DISABLE_ALL		0
 
-#ifdef CONFIG_PCH_PTP
 /* Macros for ieee1588 */
 /* 0x40 Time Synchronization Channel Control Register Bits */
 #define MASTER_MODE   (1<<0)
@@ -113,7 +110,6 @@ const char pch_driver_version[] = DRV_VERSION;
 
 #define PTP_L4_MULTICAST_SA "01:00:5e:00:01:81"
 #define PTP_L2_MULTICAST_SA "01:1b:19:00:00:00"
-#endif
 
 static unsigned int copybreak __read_mostly = PCH_GBE_COPYBREAK_DEFAULT;
 
@@ -122,7 +118,6 @@ static void pch_gbe_mdio_write(struct net_device *netdev, int addr, int reg,
 			       int data);
 static void pch_gbe_set_multi(struct net_device *netdev);
 
-#ifdef CONFIG_PCH_PTP
 static struct sock_filter ptp_filter[] = {
 	PTP_FILTER
 };
@@ -291,7 +286,6 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 
 	return copy_to_user(ifr->ifr_data, &cfg, sizeof(cfg)) ? -EFAULT : 0;
 }
-#endif
 
 inline void pch_gbe_mac_load_mac_addr(struct pch_gbe_hw *hw)
 {
@@ -1261,9 +1255,7 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 		  (int)sizeof(struct pch_gbe_tx_desc) * ring_num,
 		  &hw->reg->TX_DSC_SW_P);
 
-#ifdef CONFIG_PCH_PTP
 	pch_tx_timestamp(adapter, skb);
-#endif
 
 	dev_kfree_skb_any(skb);
 }
@@ -1771,9 +1763,7 @@ pch_gbe_clean_rx(struct pch_gbe_adapter *adapter,
 			/* Write meta date of skb */
 			skb_put(skb, length);
 
-#ifdef CONFIG_PCH_PTP
 			pch_rx_timestamp(adapter, skb);
-#endif
 
 			skb->protocol = eth_type_trans(skb, netdev);
 			if (tcp_ip_status & PCH_GBE_RXD_ACC_STAT_TCPIPOK)
@@ -2369,10 +2359,8 @@ static int pch_gbe_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 
 	pr_debug("cmd : 0x%04x\n", cmd);
 
-#ifdef CONFIG_PCH_PTP
 	if (cmd == SIOCSHWTSTAMP)
 		return hwtstamp_ioctl(netdev, ifr, cmd);
-#endif
 
 	return generic_mii_ioctl(&adapter->mii, if_mii(ifr), cmd, NULL);
 }
@@ -2665,14 +2653,12 @@ static int pch_gbe_probe(struct pci_dev *pdev,
 		goto err_free_netdev;
 	}
 
-#ifdef CONFIG_PCH_PTP
 	adapter->ptp_pdev = pci_get_bus_and_slot(adapter->pdev->bus->number,
 					       PCI_DEVFN(12, 4));
 	if (ptp_filter_init(ptp_filter, ARRAY_SIZE(ptp_filter))) {
 		pr_err("Bad ptp filter\n");
 		return -EINVAL;
 	}
-#endif
 
 	netdev->netdev_ops = &pch_gbe_netdev_ops;
 	netdev->watchdog_timeo = PCH_GBE_WATCHDOG_PERIOD;
diff --git a/drivers/net/ethernet/sfc/Kconfig b/drivers/net/ethernet/sfc/Kconfig
index 25906c1..fb3cbc2 100644
--- a/drivers/net/ethernet/sfc/Kconfig
+++ b/drivers/net/ethernet/sfc/Kconfig
@@ -34,10 +34,3 @@ config SFC_SRIOV
 	  This enables support for the SFC9000 I/O Virtualization
 	  features, allowing accelerated network performance in
 	  virtualized environments.
-config SFC_PTP
-	bool "Solarflare SFC9000-family PTP support"
-	depends on SFC && PTP_1588_CLOCK && !(SFC=y && PTP_1588_CLOCK=m)
-	default y
-	---help---
-	  This enables support for the Precision Time Protocol (PTP)
-	  on SFC9000-family NICs
diff --git a/drivers/net/ethernet/sfc/Makefile b/drivers/net/ethernet/sfc/Makefile
index e11f2ec..945bf06 100644
--- a/drivers/net/ethernet/sfc/Makefile
+++ b/drivers/net/ethernet/sfc/Makefile
@@ -2,9 +2,8 @@ sfc-y			+= efx.o nic.o falcon.o siena.o tx.o rx.o filter.o \
 			   falcon_xmac.o mcdi_mac.o \
 			   selftest.o ethtool.o qt202x_phy.o mdio_10g.o \
 			   tenxpress.o txc43128_phy.o falcon_boards.o \
-			   mcdi.o mcdi_phy.o mcdi_mon.o
+			   mcdi.o mcdi_phy.o mcdi_mon.o ptp.o
 sfc-$(CONFIG_SFC_MTD)	+= mtd.o
 sfc-$(CONFIG_SFC_SRIOV)	+= siena_sriov.o
-sfc-$(CONFIG_SFC_PTP)	+= ptp.o
 
 obj-$(CONFIG_SFC)	+= sfc.o
diff --git a/drivers/net/ethernet/sfc/net_driver.h b/drivers/net/ethernet/sfc/net_driver.h
index 576a310..2487f58 100644
--- a/drivers/net/ethernet/sfc/net_driver.h
+++ b/drivers/net/ethernet/sfc/net_driver.h
@@ -868,9 +868,7 @@ struct efx_nic {
 	struct work_struct peer_work;
 #endif
 
-#ifdef CONFIG_SFC_PTP
 	struct efx_ptp_data *ptp_data;
-#endif
 
 	/* The following fields may be written more often */
 
diff --git a/drivers/net/ethernet/sfc/nic.h b/drivers/net/ethernet/sfc/nic.h
index 438cef1..7a9647a 100644
--- a/drivers/net/ethernet/sfc/nic.h
+++ b/drivers/net/ethernet/sfc/nic.h
@@ -252,7 +252,6 @@ extern int efx_sriov_set_vf_spoofchk(struct net_device *net_dev, int vf,
 				     bool spoofchk);
 
 struct ethtool_ts_info;
-#ifdef CONFIG_SFC_PTP
 extern void efx_ptp_probe(struct efx_nic *efx);
 extern int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd);
 extern int efx_ptp_get_ts_info(struct net_device *net_dev,
@@ -260,31 +259,6 @@ extern int efx_ptp_get_ts_info(struct net_device *net_dev,
 extern bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 extern int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb);
 extern void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev);
-#else
-static inline void efx_ptp_probe(struct efx_nic *efx) {}
-static inline int efx_ptp_ioctl(struct efx_nic *efx, struct ifreq *ifr, int cmd)
-{
-	return -EOPNOTSUPP;
-}
-static inline int efx_ptp_get_ts_info(struct net_device *net_dev,
-				      struct ethtool_ts_info *ts_info)
-{
-	ts_info->so_timestamping = (SOF_TIMESTAMPING_SOFTWARE |
-				    SOF_TIMESTAMPING_RX_SOFTWARE);
-	ts_info->phc_index = -1;
-
-	return 0;
-}
-static inline bool efx_ptp_is_ptp_tx(struct efx_nic *efx, struct sk_buff *skb)
-{
-	return false;
-}
-static inline int efx_ptp_tx(struct efx_nic *efx, struct sk_buff *skb)
-{
-	return NETDEV_TX_OK;
-}
-static inline void efx_ptp_event(struct efx_nic *efx, efx_qword_t *ev) {}
-#endif
 
 extern const struct efx_nic_type falcon_a1_nic_type;
 extern const struct efx_nic_type falcon_b0_nic_type;
diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 131ef03..70c5836 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -25,8 +25,9 @@ config PTP_1588_CLOCK
 
 config PTP_1588_CLOCK_GIANFAR
 	tristate "Freescale eTSEC as PTP clock"
-	depends on PTP_1588_CLOCK
 	depends on GIANFAR
+	select PTP_1588_CLOCK
+	default y
 	help
 	  This driver adds support for using the eTSEC as a PTP
 	  clock. This clock is only useful if your PTP programs are
@@ -38,8 +39,9 @@ config PTP_1588_CLOCK_GIANFAR
 
 config PTP_1588_CLOCK_IXP46X
 	tristate "Intel IXP46x as PTP clock"
-	depends on PTP_1588_CLOCK
 	depends on IXP4XX_ETH
+	select PTP_1588_CLOCK
+	default y
 	help
 	  This driver adds support for using the IXP46X as a PTP
 	  clock. This clock is only useful if your PTP programs are
@@ -50,13 +52,13 @@ config PTP_1588_CLOCK_IXP46X
 	  will be called ptp_ixp46x.
 
 comment "Enable PHYLIB and NETWORK_PHY_TIMESTAMPING to see the additional clocks."
-	depends on PTP_1588_CLOCK && (PHYLIB=n || NETWORK_PHY_TIMESTAMPING=n)
+	depends on PHYLIB=n || NETWORK_PHY_TIMESTAMPING=n
 
 config DP83640_PHY
 	tristate "Driver for the National Semiconductor DP83640 PHYTER"
-	depends on PTP_1588_CLOCK
 	depends on NETWORK_PHY_TIMESTAMPING
 	depends on PHYLIB
+	select PTP_1588_CLOCK
 	---help---
 	  Supports the DP83640 PHYTER with IEEE 1588 features.
 
@@ -70,8 +72,9 @@ config DP83640_PHY
 
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
-	depends on PTP_1588_CLOCK
 	depends on PCH_GBE
+	select PTP_1588_CLOCK
+	default y
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
 	  clock. The hardware supports time stamping of PTP packets
-- 
1.7.7.6


-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
