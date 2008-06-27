From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 08/18] igb: Introduce multiple TX
	queues with	infrastructure
Date: Fri, 27 Jun 2008 11:00:47 -0700
Message-ID: <20080627180044.22428.21729.stgit@localhost.localdomain>
References: <20080627175921.22428.52767.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: jeff@garzik.org, davem@davemloft.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <20080627175921.22428.52767.stgit@localhost.localdomain>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>

This code adds multiple Tx queue infrastructure much like we
previously did in ixgbe. The MSI-X vector mapping is the bulk of
the change.

IAM can now be safely enabled and we've verified that it does
work correctly. We can also eliminate the tx ring lock.

Signed-off-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/igb/igb.h      |    6 +-
 drivers/net/igb/igb_main.c |  160 ++++++++++++++++++++++++++++++--------------
 2 files changed, 113 insertions(+), 53 deletions(-)

diff --git a/drivers/net/igb/igb.h b/drivers/net/igb/igb.h
index 17eb84e..4534283 100644
--- a/drivers/net/igb/igb.h
+++ b/drivers/net/igb/igb.h
@@ -62,6 +62,7 @@ struct igb_adapter;
 
 /* Transmit and receive queues */
 #define IGB_MAX_RX_QUEUES                  4
+#define IGB_MAX_TX_QUEUES                  4
 
 /* RX descriptor control thresholds.
  * PTHRESH - MAC will consider prefetch if it has fewer than this number of
@@ -157,8 +158,6 @@ struct igb_ring {
 	union {
 		/* TX */
 		struct {
-			spinlock_t tx_clean_lock;
-			spinlock_t tx_lock;
 			bool detect_tx_hung;
 		};
 		/* RX */
@@ -273,6 +272,9 @@ struct igb_adapter {
 	unsigned int msi_enabled;
 
 	u32 eeprom_wol;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	struct igb_ring *multi_tx_table[IGB_MAX_TX_QUEUES];
+#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
 };
 
 enum e1000_state_t {
diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 1f0703d..3699cf0 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -103,7 +103,7 @@ static irqreturn_t igb_msix_rx(int irq, void *);
 static irqreturn_t igb_msix_tx(int irq, void *);
 static int igb_clean_rx_ring_msix(struct napi_struct *, int);
 static bool igb_clean_tx_irq(struct igb_ring *);
-static int igb_clean(struct napi_struct *, int);
+static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_rx_irq_adv(struct igb_ring *, int *, int);
 static void igb_alloc_rx_buffers_adv(struct igb_ring *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
@@ -224,6 +224,11 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		return -ENOMEM;
 	}
 
+	for (i = 0; i < adapter->num_tx_queues; i++) {
+		struct igb_ring *ring = &(adapter->tx_ring[i]);
+		ring->adapter = adapter;
+		ring->queue_index = i;
+	}
 	for (i = 0; i < adapter->num_rx_queues; i++) {
 		struct igb_ring *ring = &(adapter->rx_ring[i]);
 		ring->adapter = adapter;
@@ -231,7 +236,7 @@ static int igb_alloc_queues(struct igb_adapter *adapter)
 		ring->itr_register = E1000_ITR;
 
 		/* set a default napi handler for each rx_ring */
-		netif_napi_add(adapter->netdev, &ring->napi, igb_clean, 64);
+		netif_napi_add(adapter->netdev, &ring->napi, igb_poll, 64);
 	}
 	return 0;
 }
@@ -412,8 +417,14 @@ static void igb_set_interrupt_capability(struct igb_adapter *adapter)
 	/* If we can't do MSI-X, try MSI */
 msi_only:
 	adapter->num_rx_queues = 1;
+	adapter->num_tx_queues = 1;
 	if (!pci_enable_msi(adapter->pdev))
 		adapter->msi_enabled = 1;
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	/* Notify the stack of the (possibly) reduced Tx Queue count. */
+	adapter->netdev->egress_subqueue_count = adapter->num_tx_queues;
+#endif
 	return;
 }
 
@@ -693,6 +704,10 @@ void igb_down(struct igb_adapter *adapter)
 	/* flush and sleep below */
 
 	netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		netif_stop_subqueue(netdev, i);
+#endif
 
 	/* disable transmits in the hardware */
 	tctl = rd32(E1000_TCTL);
@@ -870,7 +885,11 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	pci_save_state(pdev);
 
 	err = -ENOMEM;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netdev = alloc_etherdev_mq(sizeof(struct igb_adapter), IGB_MAX_TX_QUEUES);
+#else
 	netdev = alloc_etherdev(sizeof(struct igb_adapter));
+#endif /* CONFIG_NETDEVICES_MULTIQUEUE */
 	if (!netdev)
 		goto err_alloc_etherdev;
 
@@ -970,6 +989,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	if (pci_using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netdev->features |= NETIF_F_MULTI_QUEUE;
+#endif
+
 	netdev->features |= NETIF_F_LLTX;
 	adapter->en_mng_pt = igb_enable_mng_pass_thru(&adapter->hw);
 
@@ -1070,6 +1093,10 @@ static int __devinit igb_probe(struct pci_dev *pdev,
 	/* tell the stack to leave us alone until igb_open() is called */
 	netif_carrier_off(netdev);
 	netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i = 0; i < adapter->num_tx_queues; i++)
+		netif_stop_subqueue(netdev, i);
+#endif
 
 	strcpy(netdev->name, "eth%d");
 	err = register_netdev(netdev);
@@ -1196,9 +1223,15 @@ static int __devinit igb_sw_init(struct igb_adapter *adapter)
 
 	/* Number of supported queues. */
 	/* Having more queues than CPUs doesn't make sense. */
+	adapter->num_rx_queues = min((u32)IGB_MAX_RX_QUEUES, (u32)num_online_cpus());
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	adapter->num_tx_queues = min(IGB_MAX_TX_QUEUES, num_online_cpus());
+#else
 	adapter->num_tx_queues = 1;
-	adapter->num_rx_queues = min(IGB_MAX_RX_QUEUES, num_online_cpus());
+#endif /* CONFIG_NET_MULTI_QUEUE_DEVICE */
 
+	/* This call may decrease the number of queues depending on
+	 * interrupt mode. */
 	igb_set_interrupt_capability(adapter);
 
 	if (igb_alloc_queues(adapter)) {
@@ -1359,8 +1392,6 @@ int igb_setup_tx_resources(struct igb_adapter *adapter,
 	tx_ring->adapter = adapter;
 	tx_ring->next_to_use = 0;
 	tx_ring->next_to_clean = 0;
-	spin_lock_init(&tx_ring->tx_clean_lock);
-	spin_lock_init(&tx_ring->tx_lock);
 	return 0;
 
 err:
@@ -1380,6 +1411,9 @@ err:
 static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 {
 	int i, err = 0;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int r_idx;
+#endif	
 
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		err = igb_setup_tx_resources(adapter, &adapter->tx_ring[i]);
@@ -1392,6 +1426,12 @@ static int igb_setup_all_tx_resources(struct igb_adapter *adapter)
 		}
 	}
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	for (i = 0; i < IGB_MAX_TX_QUEUES; i++) {
+		r_idx = i % adapter->num_tx_queues;
+		adapter->multi_tx_table[i] = &adapter->tx_ring[r_idx];
+	}	
+#endif		
 	return err;
 }
 
@@ -2069,6 +2109,9 @@ static void igb_watchdog_task(struct work_struct *work)
 	struct e1000_mac_info *mac = &adapter->hw.mac;
 	u32 link;
 	s32 ret_val;
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int i;
+#endif
 
 	if ((netif_carrier_ok(netdev)) &&
 	    (rd32(E1000_STATUS) & E1000_STATUS_LU))
@@ -2125,6 +2168,10 @@ static void igb_watchdog_task(struct work_struct *work)
 
 			netif_carrier_on(netdev);
 			netif_wake_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				netif_wake_subqueue(netdev, i);
+#endif
 
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
@@ -2137,6 +2184,10 @@ static void igb_watchdog_task(struct work_struct *work)
 			dev_info(&adapter->pdev->dev, "NIC Link is Down\n");
 			netif_carrier_off(netdev);
 			netif_stop_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			for (i = 0; i < adapter->num_tx_queues; i++)
+				netif_stop_subqueue(netdev, i);
+#endif
 			if (!test_bit(__IGB_DOWN, &adapter->state))
 				mod_timer(&adapter->phy_info_timer,
 					  round_jiffies(jiffies + 2 * HZ));
@@ -2497,7 +2548,7 @@ static inline bool igb_tx_csum_adv(struct igb_adapter *adapter,
 		context_desc->type_tucmd_mlhl = cpu_to_le32(tu_cmd);
 		context_desc->seqnum_seed = 0;
 		context_desc->mss_l4len_idx =
-					  cpu_to_le32(tx_ring->eims_value >> 4);
+					  cpu_to_le32(tx_ring->queue_index << 4);
 
 		buffer_info->time_stamp = jiffies;
 		buffer_info->dma = 0;
@@ -2600,7 +2651,7 @@ static inline void igb_tx_queue_adv(struct igb_adapter *adapter,
 
 	if (tx_flags & (IGB_TX_FLAGS_CSUM | IGB_TX_FLAGS_TSO |
 			IGB_TX_FLAGS_VLAN))
-		olinfo_status |= tx_ring->eims_value >> 4;
+		olinfo_status |= tx_ring->queue_index << 4;
 
 	olinfo_status |= ((paylen - hdr_len) << E1000_ADVTXD_PAYLEN_SHIFT);
 
@@ -2636,7 +2687,12 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
 
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_stop_subqueue(netdev, tx_ring->queue_index);
+#else
 	netif_stop_queue(netdev);
+#endif
+
 	/* Herbert's original patch had:
 	 *  smp_mb__after_netif_stop_queue();
 	 * but since that doesn't exist yet, just open code it. */
@@ -2648,7 +2704,11 @@ static int __igb_maybe_stop_tx(struct net_device *netdev,
 		return -EBUSY;
 
 	/* A reprieve! */
-	netif_start_queue(netdev);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	netif_wake_subqueue(netdev, tx_ring->queue_index);
+#else
+	netif_wake_queue(netdev);
+#endif	
 	++adapter->restart_queue;
 	return 0;
 }
@@ -2670,7 +2730,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	struct igb_adapter *adapter = netdev_priv(netdev);
 	unsigned int tx_flags = 0;
 	unsigned int len;
-	unsigned long irq_flags;
 	u8 hdr_len = 0;
 	int tso = 0;
 
@@ -2686,10 +2745,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		return NETDEV_TX_OK;
 	}
 
-	if (!spin_trylock_irqsave(&tx_ring->tx_lock, irq_flags))
-		/* Collision - tell upper layer to requeue */
-		return NETDEV_TX_LOCKED;
-
 	/* need: 1 descriptor per page,
 	 *       + 2 desc gap to keep tail from touching head,
 	 *       + 1 desc for skb->data,
@@ -2697,7 +2752,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	 * otherwise try next time */
 	if (igb_maybe_stop_tx(netdev, tx_ring, skb_shinfo(skb)->nr_frags + 4)) {
 		/* this is a hard error */
-		spin_unlock_irqrestore(&tx_ring->tx_lock, irq_flags);
 		return NETDEV_TX_BUSY;
 	}
 
@@ -2706,12 +2760,14 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 		tx_flags |= (vlan_tx_tag_get(skb) << IGB_TX_FLAGS_VLAN_SHIFT);
 	}
 
+	if (skb->protocol == htons(ETH_P_IP))
+		tx_flags |= IGB_TX_FLAGS_IPV4;
+
 	tso = skb_is_gso(skb) ? igb_tso_adv(adapter, tx_ring, skb, tx_flags,
 					      &hdr_len) : 0;
 
 	if (tso < 0) {
 		dev_kfree_skb_any(skb);
-		spin_unlock_irqrestore(&tx_ring->tx_lock, irq_flags);
 		return NETDEV_TX_OK;
 	}
 
@@ -2721,9 +2777,6 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 			if (skb->ip_summed == CHECKSUM_PARTIAL)
 				tx_flags |= IGB_TX_FLAGS_CSUM;
 
-	if (skb->protocol == htons(ETH_P_IP))
-		tx_flags |= IGB_TX_FLAGS_IPV4;
-
 	igb_tx_queue_adv(adapter, tx_ring, tx_flags,
 			 igb_tx_map_adv(adapter, tx_ring, skb),
 			 skb->len, hdr_len);
@@ -2733,14 +2786,22 @@ static int igb_xmit_frame_ring_adv(struct sk_buff *skb,
 	/* Make sure there is space in the ring for the next send. */
 	igb_maybe_stop_tx(netdev, tx_ring, MAX_SKB_FRAGS + 4);
 
-	spin_unlock_irqrestore(&tx_ring->tx_lock, irq_flags);
 	return NETDEV_TX_OK;
 }
 
 static int igb_xmit_frame_adv(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct igb_adapter *adapter = netdev_priv(netdev);
-	struct igb_ring *tx_ring = &adapter->tx_ring[0];
+	struct igb_ring *tx_ring;
+
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+	int r_idx = 0;
+	r_idx = skb->queue_mapping & (IGB_MAX_TX_QUEUES - 1);
+	tx_ring = adapter->multi_tx_table[r_idx];
+#else
+	tx_ring = &adapter->tx_ring[0];
+#endif
+
 
 	/* This goes back to the question of how to logically map a tx queue
 	 * to a flow.  Right now, performance is impacted slightly negatively
@@ -3008,7 +3069,7 @@ static irqreturn_t igb_msix_other(int irq, void *data)
 	/* guard against interrupt when we're going down */
 	if (!test_bit(__IGB_DOWN, &adapter->state))
 		mod_timer(&adapter->watchdog_timer, jiffies + 1);
-
+	
 no_link_interrupt:
 	wr32(E1000_IMS, E1000_IMS_LSC);
 	wr32(E1000_EIMS, adapter->eims_other);
@@ -3027,12 +3088,15 @@ static irqreturn_t igb_msix_tx(int irq, void *data)
 
 	tx_ring->total_bytes = 0;
 	tx_ring->total_packets = 0;
+
+	/* auto mask will automatically reenable the interrupt when we write
+	 * EICS */
 	if (!igb_clean_tx_irq(tx_ring))
 		/* Ring was not completely cleaned, so fire another interrupt */
 		wr32(E1000_EICS, tx_ring->eims_value);
-
-	if (!tx_ring->itr_val)
+	else
 		wr32(E1000_EIMS, tx_ring->eims_value);
+
 	return IRQ_HANDLED;
 }
 
@@ -3136,42 +3200,24 @@ static irqreturn_t igb_intr(int irq, void *data)
 }
 
 /**
- * igb_clean - NAPI Rx polling callback
- * @adapter: board private structure
+ * igb_poll - NAPI Rx polling callback
+ * @napi: napi polling structure
+ * @budget: count of how many packets we should handle
  **/
-static int igb_clean(struct napi_struct *napi, int budget)
+static int igb_poll(struct napi_struct *napi, int budget)
 {
-	struct igb_adapter *adapter = container_of(napi, struct igb_adapter,
-						   napi);
+	struct igb_ring *rx_ring = container_of(napi, struct igb_ring, napi);
+	struct igb_adapter *adapter = rx_ring->adapter;
 	struct net_device *netdev = adapter->netdev;
-	int tx_clean_complete = 1, work_done = 0;
-	int i;
+	int tx_clean_complete, work_done = 0;
 
-	/* Must NOT use netdev_priv macro here. */
-	adapter = netdev->priv;
-
-	/* Keep link state information with original netdev */
-	if (!netif_carrier_ok(netdev))
-		goto quit_polling;
-
-	/* igb_clean is called per-cpu.  This lock protects tx_ring[i] from
-	 * being cleaned by multiple cpus simultaneously.  A failure obtaining
-	 * the lock means tx_ring[i] is currently being cleaned anyway. */
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		if (spin_trylock(&adapter->tx_ring[i].tx_clean_lock)) {
-			tx_clean_complete &= igb_clean_tx_irq(&adapter->tx_ring[i]);
-			spin_unlock(&adapter->tx_ring[i].tx_clean_lock);
-		}
-	}
-
-	for (i = 0; i < adapter->num_rx_queues; i++)
-		igb_clean_rx_irq_adv(&adapter->rx_ring[i], &work_done,
-				     adapter->rx_ring[i].napi.weight);
+	/* this poll routine only supports one tx and one rx queue */
+	tx_clean_complete = igb_clean_tx_irq(&adapter->tx_ring[0]);
+	igb_clean_rx_irq_adv(&adapter->rx_ring[0], &work_done, budget);
 
 	/* If no Tx and not enough Rx work done, exit the polling mode */
 	if ((tx_clean_complete && (work_done < budget)) ||
 	    !netif_running(netdev)) {
-quit_polling:
 		if (adapter->itr_setting & 3)
 			igb_set_itr(adapter, E1000_ITR, false);
 		netif_rx_complete(netdev, napi);
@@ -3300,11 +3346,19 @@ done_cleaning:
 		 * sees the new next_to_clean.
 		 */
 		smp_mb();
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+		if (__netif_subqueue_stopped(netdev, tx_ring->queue_index) &&
+		    !(test_bit(__IGB_DOWN, &adapter->state))) {
+			netif_wake_subqueue(netdev, tx_ring->queue_index);
+			++adapter->restart_queue;
+		}
+#else
 		if (netif_queue_stopped(netdev) &&
 		    !(test_bit(__IGB_DOWN, &adapter->state))) {
 			netif_wake_queue(netdev);
 			++adapter->restart_queue;
 		}
+#endif		
 	}
 
 	if (tx_ring->detect_tx_hung) {
@@ -3341,7 +3395,11 @@ done_cleaning:
 				tx_ring->buffer_info[i].time_stamp,
 				jiffies,
 				tx_desc->upper.fields.status);
+#ifdef CONFIG_NETDEVICES_MULTIQUEUE
+			netif_stop_subqueue(netdev, tx_ring->queue_index);
+#else
 			netif_stop_queue(netdev);
+#endif
 		}
 	}
 	tx_ring->total_bytes += total_bytes;


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
