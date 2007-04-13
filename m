From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Subject: [PATCH 3/3] NET: [e1000] Example implementation of multiqueue network device API
Date: Thu, 12 Apr 2007 17:19:57 -0700
Message-ID: <20070413001957.18763.63749.stgit@gitlost.site>
References: <20070413001630.18763.41107.stgit@gitlost.site>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, cramerj@intel.com, auke-jan.h.kok@intel.com,
	christopher.leech@intel.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:1818 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753904AbXDMADv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Apr 2007 20:03:51 -0400
In-Reply-To: <20070413001630.18763.41107.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This patch is *not* intended to be integrated into any tree please.  This is
fulfilling a request to demonstrate the proposed multiqueue network device
API in a driver.  The necessary updates to the e1000 driver will come in a
more official release.  This is an as-is patch to this version of e1000, and
should not be used outside of testing purposes only.

Signed-off-by: Peter P. Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
---

 drivers/net/e1000/e1000.h         |    8 ++
 drivers/net/e1000/e1000_ethtool.c |   47 ++++++++++-
 drivers/net/e1000/e1000_main.c    |  164 ++++++++++++++++++++++++++++++++-----
 3 files changed, 194 insertions(+), 25 deletions(-)

diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
index dd4b728..15e484e 100644
--- a/drivers/net/e1000/e1000.h
+++ b/drivers/net/e1000/e1000.h
@@ -168,6 +168,10 @@ struct e1000_buffer {
 	uint16_t next_to_watch;
 };
 
+struct e1000_queue_stats {
+	u64 packets;
+	u64 bytes;
+};
 
 struct e1000_ps_page { struct page *ps_page[PS_PAGE_BUFFERS]; };
 struct e1000_ps_page_dma { uint64_t ps_page_dma[PS_PAGE_BUFFERS]; };
@@ -188,9 +192,11 @@ struct e1000_tx_ring {
 	/* array of buffer information structs */
 	struct e1000_buffer *buffer_info;
 
+	spinlock_t tx_queue_lock;
 	spinlock_t tx_lock;
 	uint16_t tdh;
 	uint16_t tdt;
+	struct e1000_queue_stats tx_stats;
 	boolean_t last_tx_tso;
 };
 
@@ -218,6 +224,7 @@ struct e1000_rx_ring {
 
 	uint16_t rdh;
 	uint16_t rdt;
+	struct e1000_queue_stats rx_stats;
 };
 
 #define E1000_DESC_UNUSED(R) \
@@ -271,6 +278,7 @@ struct e1000_adapter {
 
 	/* TX */
 	struct e1000_tx_ring *tx_ring;      /* One per active queue */
+	struct e1000_tx_ring **cpu_tx_ring;
 	unsigned int restart_queue;
 	unsigned long tx_queue_len;
 	uint32_t txd_cmd;
diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
index 6777887..fd466a1 100644
--- a/drivers/net/e1000/e1000_ethtool.c
+++ b/drivers/net/e1000/e1000_ethtool.c
@@ -105,7 +105,12 @@ static const struct e1000_stats e1000_gstrings_stats[] = {
 	{ "dropped_smbus", E1000_STAT(stats.mgpdc) },
 };
 
-#define E1000_QUEUE_STATS_LEN 0
+#define E1000_QUEUE_STATS_LEN \
+        ((((((struct e1000_adapter *)netdev->priv)->num_rx_queues > 1) ? \
+          ((struct e1000_adapter *)netdev->priv)->num_rx_queues : 0 ) + \
+         (((((struct e1000_adapter *)netdev->priv)->num_tx_queues > 1) ? \
+          ((struct e1000_adapter *)netdev->priv)->num_tx_queues : 0 ))) * \
+        (sizeof(struct e1000_queue_stats) / sizeof(u64)))
 #define E1000_GLOBAL_STATS_LEN	\
 	sizeof(e1000_gstrings_stats) / sizeof(struct e1000_stats)
 #define E1000_STATS_LEN (E1000_GLOBAL_STATS_LEN + E1000_QUEUE_STATS_LEN)
@@ -693,8 +698,10 @@ e1000_set_ringparam(struct net_device *netdev,
 		E1000_MAX_TXD : E1000_MAX_82544_TXD));
 	E1000_ROUNDUP(txdr->count, REQ_TX_DESCRIPTOR_MULTIPLE);
 
-	for (i = 0; i < adapter->num_tx_queues; i++)
+	for (i = 0; i < adapter->num_tx_queues; i++) {
 		txdr[i].count = txdr->count;
+		spin_lock_init(&adapter->tx_ring[i].tx_queue_lock);
+	}
 	for (i = 0; i < adapter->num_rx_queues; i++)
 		rxdr[i].count = rxdr->count;
 
@@ -1909,6 +1916,9 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 		struct ethtool_stats *stats, uint64_t *data)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+        u64 *queue_stat;
+        int stat_count = sizeof(struct e1000_queue_stats) / sizeof(u64);
+        int j, k;
 	int i;
 
 	e1000_update_stats(adapter);
@@ -1917,12 +1927,29 @@ e1000_get_ethtool_stats(struct net_device *netdev,
 		data[i] = (e1000_gstrings_stats[i].sizeof_stat ==
 			sizeof(uint64_t)) ? *(uint64_t *)p : *(uint32_t *)p;
 	}
+        if (adapter->num_tx_queues > 1) {
+                for (j = 0; j < adapter->num_tx_queues; j++) {
+                        queue_stat = (u64 *)&adapter->tx_ring[j].tx_stats;
+                        for (k = 0; k < stat_count; k++)
+                                data[i + k] = queue_stat[k];
+                        i += k;
+                }
+        }
+        if (adapter->num_rx_queues > 1) {
+                for (j = 0; j < adapter->num_rx_queues; j++) {
+                        queue_stat = (u64 *)&adapter->rx_ring[j].rx_stats;
+                        for (k = 0; k < stat_count; k++)
+                                data[i + k] = queue_stat[k];
+                        i += k;
+                }
+        }
 /*	BUG_ON(i != E1000_STATS_LEN); */
 }
 
 static void
 e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 {
+	struct e1000_adapter *adapter = netdev_priv(netdev);
 	uint8_t *p = data;
 	int i;
 
@@ -1937,6 +1964,22 @@ e1000_get_strings(struct net_device *netdev, uint32_t stringset, uint8_t *data)
 			       ETH_GSTRING_LEN);
 			p += ETH_GSTRING_LEN;
 		}
+                if (adapter->num_tx_queues > 1) {
+                        for (i = 0; i < adapter->num_tx_queues; i++) {
+                                sprintf(p, "tx_queue_%u_packets", i);
+                                p += ETH_GSTRING_LEN;
+                                sprintf(p, "tx_queue_%u_bytes", i);
+                                p += ETH_GSTRING_LEN;
+                        }
+                }
+                if (adapter->num_rx_queues > 1) {
+                        for (i = 0; i < adapter->num_rx_queues; i++) {
+                                sprintf(p, "rx_queue_%u_packets", i);
+                                p += ETH_GSTRING_LEN;
+                                sprintf(p, "rx_queue_%u_bytes", i);
+                                p += ETH_GSTRING_LEN;
+                        }
+                }
 /*		BUG_ON(p - data != E1000_STATS_LEN * ETH_GSTRING_LEN); */
 		break;
 	}
diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 913db0c..4753674 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -29,6 +29,9 @@
 #include "e1000.h"
 #include <net/ip6_checksum.h>
 
+#include <linux/cpu.h>
+#include <linux/smp.h>
+
 char e1000_driver_name[] = "e1000";
 static char e1000_driver_string[] = "Intel(R) PRO/1000 Network Driver";
 #ifndef CONFIG_E1000_NAPI
@@ -137,6 +140,7 @@ static void e1000_exit_module(void);
 static int e1000_probe(struct pci_dev *pdev, const struct pci_device_id *ent);
 static void __devexit e1000_remove(struct pci_dev *pdev);
 static int e1000_alloc_queues(struct e1000_adapter *adapter);
+static void e1000_setup_queue_mapping(struct e1000_adapter *adapter);
 static int e1000_sw_init(struct e1000_adapter *adapter);
 static int e1000_open(struct net_device *netdev);
 static int e1000_close(struct net_device *netdev);
@@ -547,6 +551,8 @@ e1000_up(struct e1000_adapter *adapter)
 		                      E1000_DESC_UNUSED(ring));
 	}
 
+	e1000_setup_queue_mapping(adapter);
+
 	adapter->tx_queue_len = netdev->tx_queue_len;
 
 #ifdef CONFIG_E1000_NAPI
@@ -900,7 +906,7 @@ e1000_probe(struct pci_dev *pdev,
 	pci_set_master(pdev);
 
 	err = -ENOMEM;
-	netdev = alloc_etherdev(sizeof(struct e1000_adapter));
+	netdev = alloc_etherdev_mq(sizeof(struct e1000_adapter), 2);
 	if (!netdev)
 		goto err_alloc_etherdev;
 
@@ -1001,6 +1007,8 @@ e1000_probe(struct pci_dev *pdev,
 
 	netdev->features |= NETIF_F_LLTX;
 
+	netdev->features |= NETIF_F_MULTI_QUEUE;
+
 	adapter->en_mng_pt = e1000_enable_mng_pass_thru(&adapter->hw);
 
 	/* initialize eeprom parameters */
@@ -1317,8 +1325,8 @@ e1000_sw_init(struct e1000_adapter *adapter)
 		hw->master_slave = E1000_MASTER_SLAVE;
 	}
 
-	adapter->num_tx_queues = 1;
-	adapter->num_rx_queues = 1;
+	adapter->num_tx_queues = 2;
+	adapter->num_rx_queues = 2;
 
 	if (e1000_alloc_queues(adapter)) {
 		DPRINTK(PROBE, ERR, "Unable to allocate memory for queues\n");
@@ -1334,6 +1342,8 @@ e1000_sw_init(struct e1000_adapter *adapter)
 		set_bit(__LINK_STATE_START, &adapter->polling_netdev[i].state);
 	}
 	spin_lock_init(&adapter->tx_queue_lock);
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		spin_lock_init(&adapter->tx_ring[i].tx_queue_lock);
 #endif
 
 	atomic_set(&adapter->irq_sem, 1);
@@ -1382,10 +1392,26 @@ e1000_alloc_queues(struct e1000_adapter *adapter)
 	}
 	memset(adapter->polling_netdev, 0, size);
 #endif
+	adapter->cpu_tx_ring = alloc_percpu(struct e1000_tx_ring *);
 
 	return E1000_SUCCESS;
 }
 
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
+
 /**
  * e1000_open - Called when a network interface is made active
  * @netdev: network interface device structure
@@ -1640,7 +1666,17 @@ e1000_configure_tx(struct e1000_adapter *adapter)
 	/* Setup the HW Tx Head and Tail descriptor pointers */
 
 	switch (adapter->num_tx_queues) {
-	case 1:
+	case 2:
+		tdba = adapter->tx_ring[1].dma;
+		tdlen = adapter->tx_ring[1].count *
+			sizeof(struct e1000_tx_desc);
+		E1000_WRITE_REG(hw, TDLEN1, tdlen);
+		E1000_WRITE_REG(hw, TDBAH1, (tdba >> 32));
+		E1000_WRITE_REG(hw, TDBAL1, (tdba & 0x00000000ffffffffULL));
+		E1000_WRITE_REG(hw, TDT1, 0);
+		E1000_WRITE_REG(hw, TDH1, 0);
+		adapter->tx_ring[1].tdh = ((hw->mac_type >= e1000_82543) ? E1000_TDH1 : E1000_82542_TDH1);
+		adapter->tx_ring[1].tdt = ((hw->mac_type >= e1000_82543) ? E1000_TDT1 : E1000_82542_TDT1);
 	default:
 		tdba = adapter->tx_ring[0].dma;
 		tdlen = adapter->tx_ring[0].count *
@@ -2043,8 +2079,7 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 	/* Setup the HW Rx Head and Tail Descriptor Pointers and
 	 * the Base and Length of the Rx Descriptor Ring */
 	switch (adapter->num_rx_queues) {
-	case 1:
-	default:
+	case 2:
 		rdba = adapter->rx_ring[0].dma;
 		E1000_WRITE_REG(hw, RDLEN, rdlen);
 		E1000_WRITE_REG(hw, RDBAH, (rdba >> 32));
@@ -2053,11 +2088,45 @@ e1000_configure_rx(struct e1000_adapter *adapter)
 		E1000_WRITE_REG(hw, RDH, 0);
 		adapter->rx_ring[0].rdh = ((hw->mac_type >= e1000_82543) ? E1000_RDH : E1000_82542_RDH);
 		adapter->rx_ring[0].rdt = ((hw->mac_type >= e1000_82543) ? E1000_RDT : E1000_82542_RDT);
+		/* fall through */
+	default:
+		rdba = adapter->rx_ring[1].dma;
+		E1000_WRITE_REG(hw, RDLEN1, rdlen);
+		E1000_WRITE_REG(hw, RDBAH1, (rdba >> 32));
+		E1000_WRITE_REG(hw, RDBAL1, (rdba & 0x00000000ffffffffULL));
+		E1000_WRITE_REG(hw, RDT1, 0);
+		E1000_WRITE_REG(hw, RDH1, 0);
+		adapter->rx_ring[1].rdh = ((hw->mac_type >= e1000_82543) ? E1000_RDH1 : E1000_82542_RDH1);
+		adapter->rx_ring[1].rdt = ((hw->mac_type >= e1000_82543) ? E1000_RDT1 : E1000_82542_RDT1);
 		break;
 	}
 
-	/* Enable 82543 Receive Checksum Offload for TCP and UDP */
-	if (hw->mac_type >= e1000_82543) {
+	if (adapter->num_rx_queues > 1) {
+		u32 random[10];
+		u32 reta, mrqc;
+		int i;
+
+		get_random_bytes(&random[0], 40);
+
+		reta = 0x00800080;
+		mrqc = E1000_MRQC_ENABLE_RSS_2Q;
+		/* Fill out redirection table */
+		for (i = 0; i < 32; i++)
+			E1000_WRITE_REG_ARRAY(hw, RETA, i, reta);
+		/* Fill out hash function seeds */
+		for (i = 0; i < 10; i++)
+			E1000_WRITE_REG_ARRAY(hw, RSSRK, i, random[i]);
+
+		mrqc |= (E1000_MRQC_RSS_FIELD_IPV4 |
+			 E1000_MRQC_RSS_FIELD_IPV4_TCP);
+		E1000_WRITE_REG(hw, MRQC, mrqc);
+
+		/* Multiqueue and packet checksumming are mutually exclusive. */
+		rxcsum = E1000_READ_REG(hw, RXCSUM);
+		rxcsum |= E1000_RXCSUM_PCSD;
+		E1000_WRITE_REG(hw, RXCSUM, rxcsum);
+	} else if (hw->mac_type >= e1000_82543) {
+		/* Enable 82543 Receive Checksum Offload for TCP and UDP */
 		rxcsum = E1000_READ_REG(hw, RXCSUM);
 		if (adapter->rx_csum == TRUE) {
 			rxcsum |= E1000_RXCSUM_TUOFL;
@@ -2555,6 +2624,7 @@ e1000_watchdog(unsigned long data)
 	struct e1000_tx_ring *txdr = adapter->tx_ring;
 	uint32_t link, tctl;
 	int32_t ret_val;
+	int i;
 
 	ret_val = e1000_check_for_link(&adapter->hw);
 	if ((ret_val == E1000_ERR_PHY) &&
@@ -2652,6 +2722,8 @@ e1000_watchdog(unsigned long data)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				netif_wake_subqueue(netdev, i);
 			mod_timer(&adapter->phy_info_timer, jiffies + 2 * HZ);
 			adapter->smartspeed = 0;
 		} else {
@@ -3266,7 +3338,7 @@ e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	 * to a flow.  Right now, performance is impacted slightly negatively
 	 * if using multiple tx queues.  If the stack breaks away from a
 	 * single qdisc implementation, we can look at this again. */
-	tx_ring = adapter->tx_ring;
+	tx_ring = &adapter->tx_ring[skb->queue_mapping];
 
 	if (unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
@@ -3751,7 +3823,8 @@ e1000_intr_msi(int irq, void *data)
 	struct e1000_adapter *adapter = netdev_priv(netdev);
 	struct e1000_hw *hw = &adapter->hw;
 #ifndef CONFIG_E1000_NAPI
-	int i;
+	int i, j;
+	int rx_cleaned, tx_cleaned;
 #endif
 	uint32_t icr = E1000_READ_REG(hw, ICR);
 
@@ -3791,10 +3864,20 @@ e1000_intr_msi(int irq, void *data)
 	adapter->total_tx_packets = 0;
 	adapter->total_rx_packets = 0;
 
-	for (i = 0; i < E1000_MAX_INTR; i++)
-		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+	for (i = 0; i < E1000_MAX_INTR; i++) {
+		rx_cleaned = 0;
+		for (j = 0; j < adapter->num_rx_queues; j++)
+			rx_cleaned |= adapter->clean_rx(adapter,
+			                                &adapter->rx_ring[j]);
+
+		tx_cleaned = 0;
+		for (j = 0 ; j < adapter->num_tx_queues ; j++)
+			tx_cleaned |= e1000_clean_tx_irq(adapter,
+			                                 &adapter->tx_ring[j]);
+
+		if (!rx_cleaned & tx_cleaned)
 			break;
+	}
 
 	if (likely(adapter->itr_setting & 3))
 		e1000_set_itr(adapter);
@@ -3818,7 +3901,7 @@ e1000_intr(int irq, void *data)
 	struct e1000_hw *hw = &adapter->hw;
 	uint32_t rctl, icr = E1000_READ_REG(hw, ICR);
 #ifndef CONFIG_E1000_NAPI
-	int i;
+	int i, j;
 #endif
 	if (unlikely(!icr))
 		return IRQ_NONE;  /* Not our interrupt */
@@ -3894,10 +3977,20 @@ e1000_intr(int irq, void *data)
 	adapter->total_tx_packets = 0;
 	adapter->total_rx_packets = 0;
 
-	for (i = 0; i < E1000_MAX_INTR; i++)
-		if (unlikely(!adapter->clean_rx(adapter, adapter->rx_ring) &
-		   e1000_clean_tx_irq(adapter, adapter->tx_ring)))
+	for (i = 0; i < E1000_MAX_INTR; i++) {
+		rx_cleaned = 0;
+		for (j = 0; j < adapter->num_rx_queues; j++)
+			rx_cleaned |= adapter->clean_rx(adapter,
+			                                &adapter->rx_ring[j]);
+
+		tx_cleaned = 0;
+		for (j = 0 ; j < adapter->num_tx_queues ; j++)
+			tx_cleaned |= e1000_clean_tx_irq(adapter,
+			                                 &adapter->tx_ring[j]);
+
+		if (!rx_cleaned & tx_cleaned)
 			break;
+	}
 
 	if (likely(adapter->itr_setting & 3))
 		e1000_set_itr(adapter);
@@ -3920,7 +4013,8 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 {
 	struct e1000_adapter *adapter;
 	int work_to_do = min(*budget, poll_dev->quota);
-	int tx_cleaned = 0, work_done = 0;
+	int tx_cleaned = 1, work_done = 0;
+	int i;
 
 	/* Must NOT use netdev_priv macro here. */
 	adapter = poll_dev->priv;
@@ -3933,14 +4027,29 @@ e1000_clean(struct net_device *poll_dev, int *budget)
 	 * tx_ring[0] from being cleaned by multiple cpus
 	 * simultaneously.  A failure obtaining the lock means
 	 * tx_ring[0] is currently being cleaned anyway. */
-	if (spin_trylock(&adapter->tx_queue_lock)) {
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		if (spin_trylock(&adapter->tx_ring[i].tx_queue_lock)) {
+			tx_cleaned &= e1000_clean_tx_irq(adapter,
+			                                &adapter->tx_ring[i]);
+			spin_unlock(&adapter->tx_ring[i].tx_queue_lock);
+		}
+	}
+	if (adapter->num_tx_queues == 1 &&
+	    spin_trylock(&adapter->tx_queue_lock)) {
 		tx_cleaned = e1000_clean_tx_irq(adapter,
 		                                &adapter->tx_ring[0]);
 		spin_unlock(&adapter->tx_queue_lock);
 	}
 
-	adapter->clean_rx(adapter, &adapter->rx_ring[0],
-	                  &work_done, work_to_do);
+	for (i = 0; i < adapter->num_rx_queues; i++) {
+		/* XXX if the number of queues was limited to a power of two
+		 * this would not need a div */
+		adapter->clean_rx(adapter, &adapter->rx_ring[i],
+		                  &work_done,
+		                  work_to_do / adapter->num_rx_queues);
+		*budget -= work_done;
+		poll_dev->quota -= work_done;
+	}
 
 	*budget -= work_done;
 	poll_dev->quota -= work_done;
@@ -3989,6 +4098,8 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			buffer_info = &tx_ring->buffer_info[i];
 			cleaned = (i == eop);
 
+			tx_ring->tx_stats.bytes += buffer_info->length;
+
 			if (cleaned) {
 				struct sk_buff *skb = buffer_info->skb;
 				unsigned int segs, bytecount;
@@ -4005,6 +4116,8 @@ e1000_clean_tx_irq(struct e1000_adapter *adapter,
 			if (unlikely(++i == tx_ring->count)) i = 0;
 		}
 
+		tx_ring->tx_stats.packets++;
+
 		eop = tx_ring->buffer_info[i].next_to_watch;
 		eop_desc = E1000_TX_DESC(*tx_ring, eop);
 #ifdef CONFIG_E1000_NAPI
@@ -4266,6 +4379,8 @@ e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		}
 #endif /* CONFIG_E1000_NAPI */
 		netdev->last_rx = jiffies;
+		rx_ring->rx_stats.packets++;
+		rx_ring->rx_stats.bytes += length;
 
 next_desc:
 		rx_desc->status = 0;
@@ -5222,12 +5337,15 @@ static void
 e1000_netpoll(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev_priv(netdev);
+	int i;
 
 	disable_irq(adapter->pdev->irq);
 	e1000_intr(adapter->pdev->irq, netdev);
-	e1000_clean_tx_irq(adapter, adapter->tx_ring);
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		e1000_clean_tx_irq(adapter, &adapter->tx_ring[i]);
 #ifndef CONFIG_E1000_NAPI
-	adapter->clean_rx(adapter, adapter->rx_ring);
+	for (i = 0; i < adatper->num_rx_queues; i++)
+		adapter->clean_rx(adapter, &adapter->rx_ring[i]);
 #endif
 	enable_irq(adapter->pdev->irq);
 }

