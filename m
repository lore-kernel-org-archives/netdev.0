From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 2/2] e1000: Implement the new kernel API for multiqueue TX support.
Date: Thu, 08 Feb 2007 16:09:52 -0800
Message-ID: <20070209000952.5155.96947.stgit@gitlost.site>
References: <20070209000942.5155.78998.stgit@gitlost.site>
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Peter Waskiewicz Jr" <peter.p.waskiewicz.jr@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
To: "David Miller" <davem@davemloft.net>,
	"Garzik, Jeff" <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1301 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1945942AbXBHXzu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Feb 2007 18:55:50 -0500
In-Reply-To: <20070209000942.5155.78998.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


From: Peter Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>

Several newer e1000 chipsets support multiple RX and TX queues. Most
commonly, 82571's and ESB2LAN support 2 rx and 2 rx queues.

Signed-off-by: Peter Waskiewicz Jr. <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/Kconfig               |   13 ++
 drivers/net/e1000/e1000.h         |   23 +++
 drivers/net/e1000/e1000_ethtool.c |   43 ++++++
 drivers/net/e1000/e1000_main.c    |  269 +++++++++++++++++++++++++++++++------
 4 files changed, 304 insertions(+), 44 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index ad92b6a..2d758ab 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -1988,6 +1988,19 @@ config E1000_DISABLE_PACKET_SPLIT
 
 	  If in doubt, say N.
 
+config E1000_MQ
+	bool "Enable Tx/Rx Multiqueue Support (EXPERIMENTAL)"
+	depends on E1000 && NET_MULTI_QUEUE_DEVICE && EXPERIMENTAL
+	help
+	  Say Y here if you want to enable multiqueue support for supported
+	  e1000 devices.  This will enable both transmit and receive queues
+	  on devices that support them.
+
+	  In order to fully utilize the Tx queue support, use the SCH_PRIO
+	  queueing discipline.
+
+	  If in doubt, say N.
+
 source "drivers/net/ixp2000/Kconfig"
 
 config MYRI_SBUS
diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index 689f158..cfcdc9d 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -108,6 +108,10 @@ struct e1000_adapter;
 #define E1000_MIN_RXD                       80
 #define E1000_MAX_82544_RXD               4096
 
+#ifdef CONFIG_E1000_MQ
+#define E1000_MAX_TX_QUEUES                  4
+#endif
+
 /* this is the size past which hardware will drop packets when setting LPE=0 */
 #define MAXIMUM_ETHERNET_VLAN_SIZE 1522
 
@@ -168,6 +172,12 @@ struct e1000_buffer {
 	uint16_t next_to_watch;
 };
 
+#ifdef CONFIG_E1000_MQ
+struct e1000_queue_stats {
+	uint64_t packets;
+	uint64_t bytes;
+};
+#endif
 
 struct e1000_ps_page { struct page *ps_page[PS_PAGE_BUFFERS]; };
 struct e1000_ps_page_dma { uint64_t ps_page_dma[PS_PAGE_BUFFERS]; };
@@ -188,9 +198,16 @@ struct e1000_tx_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
+#ifdef CONFIG_E1000_MQ
+	/* for tx ring cleanup - needed for multiqueue */
+	spinlock_t tx_queue_lock;
+#endif
 	spinlock_t tx_lock;
 	uint16_t tdh;
 	uint16_t tdt;
+#ifdef CONFIG_E1000_MQ
+	struct e1000_queue_stats tx_stats;
+#endif
 	boolean_t last_tx_tso;
 };
 
@@ -218,6 +235,9 @@ struct e1000_rx_ring {
 
 	uint16_t rdh;
 	uint16_t rdt;
+#ifdef CONFIG_E1000_MQ
+	struct e1000_queue_stats rx_stats;
+#endif
 };
 
 #define E1000_DESC_UNUSED(R) \
@@ -271,6 +291,9 @@ struct e1000_adapter {
 
 	/* TX */
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
+#ifdef CONFIG_E1000_MQ
+	struct e1000_tx_ring **cpu_tx_ring; /* per-cpu */
+#endif
 	unsigned int restart_queue;
 	unsigned long tx_queue_len;
 	uint32_t txd_cmd;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 44ebc72..c8c1500 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -105,7 +105,14 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "dropped_smbus", E1000_STAT(stats.mgpdc) },
 };
 
+#ifdef CONFIG_E1000_MQ
+#define E1000_QUEUE_STATS_LEN \
+	(((struct e1000_adapter *)netdev->priv)->num_tx_queues + \
+	 ((struct e1000_adapter *)netdev->priv)->num_rx_queues) \
+	* (sizeof(struct e1000_queue_stats) / sizeof(uint64_t))
+#else
 #define E1000_QUEUE_STATS_LEN 0
+#endif
 #define E1000_GLOBAL_STATS_LEN	\
 	sizeof(e1000_gstrings_stats) / sizeof(struct e1000_stats)
 #define E1000_STATS_LEN (E1000_GLOBAL_STATS_LEN + E1000_QUEUE_STATS_LEN)
@@ -1909,6 +1916,11 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+#ifdef CONFIG_E1000_MQ
+	uint64_t *queue_stat;
+	int stat_count = sizeof(struct e1000_queue_stats) / sizeof(uint64_t);
+	int j, k;
+#endif
 	int i;
 
 	e1000_update_stats(adapter);
@@ -1917,12 +1929,29 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
 			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
 	}
+#ifdef CONFIG_E1000_MQ
+	for (j = 0; j < adapter->num_tx_queues; j++) {
+		queue_stat = (uint64_t *)&adapter->tx_ring[j].tx_stats;
+		for (k = 0; k < stat_count; k++)
+			data[i + k] = queue_stat[k];
+		i += k;
+	}
+	for (j = 0; j < adapter->num_rx_queues; j++) {
+		queue_stat = (uint64_t *)&adapter->rx_ring[j].rx_stats;
+		for (k = 0; k < stat_count; k++)
+			data[i + k] = queue_stat[k];
+		i += k;
+	}
+#endif
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
 
 static void
 e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
+#ifdef CONFIG_E1000_MQ
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+#endif
 	uint8_t *p = data;
 	int i;
 
@@ -1937,6 +1966,20 @@ e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+#ifdef CONFIG_E1000_MQ
+		for (i = 0; i < adapter->num_tx_queues; i++) {
+			sprintf(p, "tx_queue_%u_packets", i);
+			p += ETH_GSTRING_LEN;
+			sprintf(p, "tx_queue_%u_bytes", i);
+			p += ETH_GSTRING_LEN;
+		}
+		for (i = 0; i < adapter->num_rx_queues; i++) {
+			sprintf(p, "rx_queue_%u_packets", i);
+			p+= ETH_GSTRING_LEN;
+			sprintf(p, "rx_queue_%u_bytes", i);
+			p += ETH_GSTRING_LEN;
+		}
+#endif
 /*		BUG_ON(p - data != E1000_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 619c892..a53f065 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -28,6 +28,10 @@
 
 #include "e1000.h"
 #include <net/ip6_checksum.h>
+#ifdef CONFIG_E1000_MQ
+#include <linux/cpu.h>
+#include <linux/smp.h>
+#endif
 
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
@@ -137,6 +141,9 @@ static void e1000_exit_module(void);
 static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void __devexit e1000_remove(struct pci_dev *pdev);
 static int e1000_alloc_queues(struct e1000_adapter *adapter);
+#ifdef CONFIG_E1000_MQ
+static void e1000_setup_queue_mapping(struct e1000_adapter *adapter);
+#endif
 static int e1000_sw_init(struct e1000_adapter *adapter);
 static int e1000_open(struct net_device *netdev);
 static int e1000_close(struct net_device *netdev);
@@ -153,7 +160,13 @@ static void e1000_set_multi(struct net_device *netdev);
 static void e1000_update_phy_info(unsigned long data);
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
+static int e1000_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev,
+                                 struct e1000_tx_ring *tx_ring);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+#ifdef CONFIG_E1000_MQ
+static int e1000_subqueue_xmit_frame(struct sk_buff *skb,
+                                     struct net_device *netdev, int queue);
+#endif
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
@@ -547,6 +560,10 @@ e1000_up(struct e1000_adapter *adapter)
 		                      E1000_DESC_UNUSED(ring));
 	}
 
+#ifdef CONFIG_E1000_MQ
+	e1000_setup_queue_mapping(adapter);
+#endif
+
 	adapter->tx_queue_len = netdev->tx_queue_len;
 
 #ifdef CONFIG_E1000_NAPI
@@ -900,7 +917,12 @@ e1000_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	err = -ENOMEM;
+#ifdef CONFIG_E1000_MQ
+	netdev = alloc_etherdev(sizeof(struct e1000_adapter) +
+		(sizeof(struct net_device_subqueue) * E1000_MAX_TX_QUEUES));
+#else
 	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
+#endif
 	if (!netdev)
 		goto err_alloc_etherdev;
 
@@ -934,6 +956,9 @@ e1000_probe(struct pci_dev *pdev,
 	netdev->open = &e1000_open;
 	netdev->stop = &e1000_close;
 	netdev->hard_start_xmit = &e1000_xmit_frame;
+#ifdef CONFIG_E1000_MQ
+	netdev->hard_start_subqueue_xmit = &e1000_subqueue_xmit_frame;
+#endif
 	netdev->get_stats = &e1000_get_stats;
 	netdev->set_multicast_list = &e1000_set_multi;
 	netdev->set_mac_address = &e1000_set_mac;
@@ -1317,8 +1342,44 @@ e1000_sw_init(struct e1000_adapter *adapter)
 		hw->master_slave = E1000_MASTER_SLAVE;
 	}
 
+#ifdef CONFIG_E1000_MQ
+	/* Number of supported queues.
+	 * TODO: It's assumed num_rx_queues >= num_tx_queues, since multi-rx
+	 * queues are much more interesting.  Is it worth coding for the
+	 * possibility (however improbable) of num_tx_queues > num_rx_queues?
+	 */
+	switch (hw->mac_type) {
+	case e1000_82571:
+	case e1000_82572:
+	case e1000_80003es2lan:
+		adapter->num_tx_queues = 2;
+		adapter->num_rx_queues = 2;
+		break;
+
+	default:
+		/* All hardware before 82571 only have 1 queue each for Rx/Tx.
+		 * However, the 82571 family does not have MSI-X, so multi-
+		 * queue isn't enabled.
+		 * It'd be wise not to mess with this default case. :) */
+		adapter->num_tx_queues = 1;
+		adapter->num_rx_queues = 1;
+		netdev->egress_subqueue_count = 0;
+		break;
+	}
+	adapter->num_rx_queues = min(adapter->num_rx_queues, num_online_cpus());
+	adapter->num_tx_queues = min(adapter->num_tx_queues, num_online_cpus());
+
+	if ((adapter->num_tx_queues > 1) || (adapter->num_rx_queues > 1)) {
+		netdev->egress_subqueue = (struct net_device_subqueue *)((void *)adapter + sizeof(struct e1000_adapter));
+		netdev->egress_subqueue_count = adapter->num_tx_queues;
+		DPRINTK(DRV, INFO, "Multiqueue Enabled: RX queues = %u, "
+		        "TX queues = %u\n", adapter->num_rx_queues,
+		        adapter->num_tx_queues);
+	}
+#else
 	adapter->num_tx_queues = 1;
 	adapter->num_rx_queues = 1;
+#endif
 
 	if (e1000_alloc_queues(adapter)) {
 		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
@@ -1334,13 +1395,16 @@ e1000_sw_init(struct e1000_adapter *adapter)
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
 	spin_lock_init(&adapter->tx_queue_lock);
+#ifdef CONFIG_E1000_MQ
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		spin_lock_init(&adapter->tx_ring[i].tx_queue_lock);
+#endif
 #endif
 
 	atomic_set(&adapter->irq_sem, 1);
 	spin_lock_init(&adapter->stats_lock);
 
 	set_bit(__E1000_DOWN, &adapter->flags);
-
 	return 0;
 }
 
@@ -1382,9 +1446,28 @@ e1000_alloc_queues(struct e1000_adapter *adapter)
 	}
 	memset(adapter->polling_netdev, 0, size);
 #endif
+#ifdef CONFIG_E1000_MQ
+	adapter->cpu_tx_ring = alloc_percpu(struct e1000_tx_ring *);
+#endif
 
 	return E1000_SUCCESS;
 }
+#ifdef CONFIG_E1000_MQ
+static void
+e1000_setup_queue_mapping(struct e1000_adapter *adapter)
+{
+	int i, cpu;
+
+	lock_cpu_hotplug();
+	i = 0;
+	for_each_online_cpu(cpu) {
+		*per_cpu_ptr(adapter->cpu_tx_ring, cpu) =
+		             &adapter->tx_ring[i % adapter->num_tx_queues];
+		i++;
+	}
+	unlock_cpu_hotplug();
+}
+#endif
 
 /**
  * e1000_open - Called when a network interface is made active
@@ -1636,23 +1719,20 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t tdlen, tctl, tipg, tarc;
 	uint32_t ipgr1, ipgr2;
+	int i;
 
 	/* Setup the HW Tx Head and Tail descriptor pointers */
-
-	switch (adapter->num_tx_queues) {
-	case 1:
-	default:
-		tdba = adapter->tx_ring[0].dma;
-		tdlen = adapter->tx_ring[0].count *
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		tdba = adapter->tx_ring[i].dma;
+		tdlen = adapter->tx_ring[i].count *
 			sizeof(struct e1000_tx_desc);
-		E1000_WRITE_REG(hw, TDLEN, tdlen);
-		E1000_WRITE_REG(hw, TDBAH, (tdba >> 32));
-		E1000_WRITE_REG(hw, TDBAL, (tdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, TDT, 0);
-		E1000_WRITE_REG(hw, TDH, 0);
-		adapter->tx_ring[0].tdh = ((hw->mac_type >= e1000_82543) ? E1000_TDH : E1000_82542_TDH);
-		adapter->tx_ring[0].tdt = ((hw->mac_type >= e1000_82543) ? E1000_TDT : E1000_82542_TDT);
-		break;
+		E1000_WRITE_REG(hw, TDLEN + (i << 8), tdlen);
+		E1000_WRITE_REG(hw, TDBAH + (i << 8), (tdba >> 32));
+		E1000_WRITE_REG(hw, TDBAL + (i << 8), (tdba & 0x00000000ffffffffULL));
+		E1000_WRITE_REG(hw, TDT + (i << 8), 0);
+		E1000_WRITE_REG(hw, TDH + (i << 8), 0);
+		adapter->tx_ring[i].tdh = ((hw->mac_type >= e1000_82543) ? E1000_TDH + (i << 8) : E1000_82542_TDH);
+		adapter->tx_ring[i].tdt = ((hw->mac_type >= e1000_82543) ? E1000_TDT + (i << 8) : E1000_82542_TDT);
 	}
 
 	/* Set the default values for the Tx Inter Packet Gap timer */
@@ -1999,6 +2079,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	uint64_t rdba;
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t rdlen, rctl, rxcsum, ctrl_ext;
+	int i;
 
 	if (adapter->rx_ps_pages) {
 		/* this is a 32 byte descriptor */
@@ -2042,20 +2123,67 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
-	switch (adapter->num_rx_queues) {
-	case 1:
-	default:
-		rdba = adapter->rx_ring[0].dma;
-		E1000_WRITE_REG(hw, RDLEN, rdlen);
-		E1000_WRITE_REG(hw, RDBAH, (rdba >> 32));
-		E1000_WRITE_REG(hw, RDBAL, (rdba & 0x00000000ffffffffULL));
-		E1000_WRITE_REG(hw, RDT, 0);
-		E1000_WRITE_REG(hw, RDH, 0);
-		adapter->rx_ring[0].rdh = ((hw->mac_type >= e1000_82543) ? E1000_RDH : E1000_82542_RDH);
-		adapter->rx_ring[0].rdt = ((hw->mac_type >= e1000_82543) ? E1000_RDT : E1000_82542_RDT);
-		break;
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		rdba = adapter->rx_ring[i].dma;
+		E1000_WRITE_REG(hw, RDLEN + (i << 8), rdlen);
+		E1000_WRITE_REG(hw, RDBAH + (i << 8), (rdba >> 32));
+		E1000_WRITE_REG(hw, RDBAL + (i << 8), (rdba & 0x00000000ffffffffULL));
+		E1000_WRITE_REG(hw, RDT + (i << 8), 0);
+		E1000_WRITE_REG(hw, RDH + (i << 8), 0);
+		adapter->rx_ring[i].rdh = ((hw->mac_type >= e1000_82543) ? E1000_RDH + (i << 8) : E1000_82542_RDH);
+		adapter->rx_ring[i].rdt = ((hw->mac_type >= e1000_82543) ? E1000_RDT + (i << 8) : E1000_82542_RDT);
 	}
 
+#ifdef CONFIG_E1000_MQ
+	if (adapter->num_rx_queues > 1) {
+		u32 random[10];
+		u32 reta, mrqc;
+		int i;
+
+		get_random_bytes(&random[0], 40);
+
+		switch (adapter->num_rx_queues) {
+		default:
+			reta = 0x00800080;
+			mrqc = E1000_MRQC_ENABLE_RSS_2Q;
+			break;
+		}
+
+		/* Fill out redirection table */
+		for (i = 0; i < 32; i++)
+			E1000_WRITE_REG_ARRAY(hw, RETA, i, reta);
+		/* Fill out hash function seeds */
+		for (i = 0; i < 10; i++)
+			E1000_WRITE_REG_ARRAY(hw, RSSRK, i, random[i]);
+
+		mrqc |= (E1000_MRQC_RSS_FIELD_IPV4 |
+			 E1000_MRQC_RSS_FIELD_IPV4_TCP);
+
+		E1000_WRITE_REG(hw, MRQC, mrqc);
+
+		/* Multiqueue and packet checksumming are mutually exclusive. */
+		rxcsum = E1000_READ_REG(hw, RXCSUM);
+		rxcsum |= E1000_RXCSUM_PCSD;
+		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
+	} else if (hw->mac_type >= e1000_82543) {
+		/* Enable 82543 Receive Checksum Offload for TCP and UDP */
+		rxcsum = E1000_READ_REG(hw, RXCSUM);
+		if (adapter->rx_csum == TRUE) {
+			rxcsum |= E1000_RXCSUM_TUOFL;
+
+			/* Enable 82571 IPv4 payload checksum for UDP fragments
+			 * Must be used in conjunction with packet-split. */
+			if ((hw->mac_type >= e1000_82571) &&
+			    (adapter->rx_ps_pages)) {
+				rxcsum |= E1000_RXCSUM_IPPCSE;
+			}
+		} else {
+			rxcsum &= ~E1000_RXCSUM_TUOFL;
+			/* don't need to clear IPPCSE as it defaults to 0 */
+		}
+		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
+	}
+#else
 	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 	if (hw->mac_type >= e1000_82543) {
 		rxcsum = E1000_READ_REG(hw, RXCSUM);
@@ -2074,6 +2202,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 		}
 		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
 	}
+#endif
 
 	/* enable early receives on 82573, only takes effect if using > 2048
 	 * byte total frame size.  for example only for jumbo frames */
@@ -2555,6 +2684,9 @@ e1000_watchdog(unsigned long data)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
 	int32_t ret_val;
+#ifdef CONFIG_E1000_MQ
+	int i;
+#endif
 
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
@@ -2652,6 +2784,12 @@ e1000_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
+#ifdef CONFIG_E1000_MQ
+			if (netif_is_multiqueue(netdev))
+				for (i = 0; i < adapter->num_tx_queues; i++)
+					netif_wake_subqueue(netdev, i);
+#endif
+
 			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
 			adapter->smartspeed = 0;
 		} else {
@@ -3249,10 +3387,10 @@ static int e1000_maybe_stop_tx(struct net_device *netdev,
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
 static int
-e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+e1000_xmit_frame_ring(struct sk_buff *skb, struct net_device *netdev,
+                      struct e1000_tx_ring *tx_ring)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
-	struct e1000_tx_ring *tx_ring;
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
@@ -3265,12 +3403,6 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	unsigned int f;
 	len -= skb->data_len;
 
-	/* This goes back to the question of how to logically map a tx queue
-	 * to a flow.  Right now, performance is impacted slightly negatively
-	 * if using multiple tx queues.  If the stack breaks away from a
-	 * single qdisc implementation, we can look at this again. */
-	tx_ring = adapter->tx_ring;
-
 	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
 		return NETDEV_TX_OK;
@@ -3425,6 +3557,31 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	return NETDEV_TX_OK;
 }
 
+static int
+e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = adapter->tx_ring;
+
+	/* This goes back to the question of how to logically map a tx queue
+	 * to a flow.  Right now, performance is impacted slightly negatively
+	 * if using multiple tx queues.  If the stack breaks away from a
+	 * single qdisc implementation, we can look at this again. */
+	return (e1000_xmit_frame_ring(skb, netdev, tx_ring));
+}
+
+#ifdef CONFIG_E1000_MQ
+static int
+e1000_subqueue_xmit_frame(struct sk_buff *skb, struct net_device *netdev,
+                          int queue)
+{
+	struct e1000_adapter *adapter = netdev_priv(netdev);
+	struct e1000_tx_ring *tx_ring = &adapter->tx_ring[queue];
+
+	return (e1000_xmit_frame_ring(skb, netdev, tx_ring));
+}
+#endif
+
 /**
  * e1000_tx_timeout - Respond to a Tx Hang
  * @netdev: network interface device structure
@@ -3924,6 +4081,7 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 	struct e1000_adapter *adapter;
 	int work_to_do = min(*budget, poll_dev->quota);
 	int tx_cleaned = 0, work_done = 0;
+	int i;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -3933,18 +4091,27 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 		goto quit_polling;
 
 	/* e1000_clean is called per-cpu.  This lock protects
-	 * tx_ring[0] from being cleaned by multiple cpus
+	 * tx_ring[i] from being cleaned by multiple cpus
 	 * simultaneously.  A failure obtaining the lock means
-	 * tx_ring[0] is currently being cleaned anyway. */
-	if (spin_trylock(&adapter->tx_queue_lock)) {
-		tx_cleaned = e1000_clean_tx_irq(adapter,
-		                                &adapter->tx_ring[0]);
-		spin_unlock(&adapter->tx_queue_lock);
+	 * tx_ring[i] is currently being cleaned anyway. */
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+#ifdef CONFIG_E1000_MQ
+		if (spin_trylock(&adapter->tx_ring[i].tx_queue_lock)) {
+			tx_cleaned = e1000_clean_tx_irq(adapter,
+			                                &adapter->tx_ring[i]);
+			spin_unlock(&adapter->tx_ring[i].tx_queue_lock);
+		}
+#else
+		if (spin_trylock(&adapter->tx_queue_lock)) {
+			tx_cleaned = e1000_clean_tx_irq(adapter,
+			                                &adapter->tx_ring[i]);
+			spin_unlock(&adapter->tx_queue_lock);
+		}
+#endif
+		adapter->clean_rx(adapter, &adapter->rx_ring[i],
+		                  &work_done, work_to_do);
 	}
 
-	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, work_to_do);
-
 	*budget -= work_done;
 	poll_dev->quota -= work_done;
 
@@ -3992,6 +4159,9 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
 
+#ifdef CONFIG_E1000_MQ
+			tx_ring->tx_stats.bytes += buffer_info->length;
+#endif
 			if (cleaned) {
 				struct sk_buff *skb = buffer_info->skb;
 				unsigned int segs, bytecount;
@@ -4008,6 +4178,9 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			if (unlikely(++i == tx_ring->count)) i = 0;
 		}
 
+#ifdef CONFIG_E1000_MQ
+		tx_ring->tx_stats.packets++;
+#endif
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
 #ifdef CONFIG_E1000_NAPI
@@ -4269,6 +4442,10 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		}
 #endif /* CONFIG_E1000_NAPI */
 		netdev->last_rx = jiffies;
+#ifdef CONFIG_E1000_MQ
+		rx_ring->rx_stats.packets++;
+		rx_ring->rx_stats.bytes += length;
+#endif
 
 next_desc:
 		rx_desc->status = 0;
@@ -4375,6 +4552,10 @@ e1000_clean_rx_irq_ps(struct e1000_adapter *adapter,
 
 		/* Good Receive */
 		skb_put(skb, length);
+#ifdef CONFIG_E1000_MQ
+		rx_ring->rx_stats.packets++;
+		rx_ring->rx_stats.bytes += skb->len;
+#endif
 
 		{
 		/* this looks ugly, but it seems compiler issues make it



---
Auke Kok <auke-jan.h.kok@intel.com>
