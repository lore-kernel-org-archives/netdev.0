From: jamal <hadi@cyberus.ca>
Subject: Re: TX performance of Intel 82546
Date: 15 Sep 2004 08:18:27 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1095250706.1057.214.camel@jzny.localdomain>
References: <20040915081439.GA27038@sunbeam.de.gnumonks.org>
	 <414808F3.70104@draigBrady.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-LvwXueET1uGxmrAzo7XZ"
Cc: Harald Welte <laforge@netfilter.org>, Linux NICS <linux.nics@intel.com>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: P@draigBrady.com
In-Reply-To: <414808F3.70104@draigBrady.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-LvwXueET1uGxmrAzo7XZ
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Wed, 2004-09-15 at 05:18, P@draigBrady.com wrote:

> I was able to confirm the above by passing 4x730Kpps
> through a PCI-X system with 4 ethernet controllers,
> but never more than 760Kpps through one particular controller.
> 
> Note also you may be able to tune for transmission
> using setpci (google for setpci & MMRBC), or hacking with TSO?

Our friends in FreeBSD claim they can do 1Mpps _forwarding_ with 
e1000 - forget about transmit only ;->

I have been experimenting after SUCON on and off because i found the BSD
folks batch their transmits. They have a very dumb egress with no QoS.
Results are not conclusive yet. I will post at some point. 

Harald try to move the wmb() just before you write the TDT as i do in
kick_DMA in rearranged e1000 patch attached.
I will move things around if you show worse results.

BTW, anyone wanting to experiment on this patch talk to me privately. I
need to clean it up - maybe this weekend.

cheers,
jamal


--=-LvwXueET1uGxmrAzo7XZ
Content-Disposition: attachment; filename=e1000p
Content-Type: text/plain; name=e1000p; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

--- 269-rc1-bk10/drivers/net/e1000/e1000_main.c	2004/09/12 17:05:58	1.1
+++ 269-rc1-bk10/drivers/net/e1000/e1000_main.c	2004/09/15 12:13:24
@@ -125,6 +125,7 @@
 static void e1000_watchdog(unsigned long data);
 static void e1000_82547_tx_fifo_stall(unsigned long data);
 static int e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev);
+static int e1000_xmit_frames(struct sk_buff_head *list, struct net_device *netdev);
 static struct net_device_stats * e1000_get_stats(struct net_device *netdev);
 static int e1000_change_mtu(struct net_device *netdev, int new_mtu);
 static int e1000_set_mac(struct net_device *netdev, void *p);
@@ -448,6 +449,7 @@
 	netdev->open = &e1000_open;
 	netdev->stop = &e1000_close;
 	netdev->hard_start_xmit = &e1000_xmit_frame;
+	netdev->hard_batch_xmit = &e1000_xmit_frames;
 	netdev->get_stats = &e1000_get_stats;
 	netdev->set_multicast_list = &e1000_set_multi;
 	netdev->set_mac_address = &e1000_set_mac;
@@ -1673,6 +1675,14 @@
 }
 
 static inline void
+e1000_kick_DMA(struct e1000_adapter *adapter, int i)
+{
+	wmb();
+
+	E1000_WRITE_REG(&adapter->hw, TDT, i);
+}
+
+static inline void
 e1000_tx_queue(struct e1000_adapter *adapter, int count, int tx_flags)
 {
 	struct e1000_desc_ring *tx_ring = &adapter->tx_ring;
@@ -1711,14 +1721,16 @@
 
 	tx_desc->lower.data |= cpu_to_le32(adapter->txd_cmd);
 
+#if 0
 	/* Force memory writes to complete before letting h/w
 	 * know there are new descriptors to fetch.  (Only
 	 * applicable for weak-ordered memory model archs,
 	 * such as IA-64). */
 	wmb();
 
-	tx_ring->next_to_use = i;
 	E1000_WRITE_REG(&adapter->hw, TDT, i);
+#endif
+	tx_ring->next_to_use = i;
 }
 
 /**
@@ -1760,15 +1772,15 @@
 }
 
 #define TXD_USE_COUNT(S, X) (((S) >> (X)) + 1 )
-static int
-e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+#define NETDEV_TX_DROPPED 3
+static inline int
+e1000_queue_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev->priv;
 	unsigned int first, max_per_txd = E1000_MAX_DATA_PER_TXD;
 	unsigned int max_txd_pwr = E1000_MAX_TXD_PWR;
 	unsigned int tx_flags = 0;
 	unsigned int len = skb->len;
-	unsigned long flags;
 	unsigned int nr_frags = 0;
 	unsigned int mss = 0;
 	int count = 0;
@@ -1778,7 +1790,7 @@
 
 	if(unlikely(skb->len <= 0)) {
 		dev_kfree_skb_any(skb);
-		return 0;
+		return NETDEV_TX_DROPPED;
 	}
 
 #ifdef NETIF_F_TSO
@@ -1813,27 +1825,19 @@
 	if(adapter->pcix_82544)
 		count += nr_frags;
 
- 	local_irq_save(flags); 
- 	if (!spin_trylock(&adapter->tx_lock)) { 
- 		/* Collision - tell upper layer to requeue */ 
- 		local_irq_restore(flags); 
- 		return -1; 
- 	} 
 
 	/* need: count + 2 desc gap to keep tail from touching
 	 * head, otherwise try next time */
 	if(E1000_DESC_UNUSED(&adapter->tx_ring) < count + 2) {
 		netif_stop_queue(netdev);
-		spin_unlock_irqrestore(&adapter->tx_lock, flags);
-		return 1;
+		return NETDEV_TX_BUSY;
 	}
 
 	if(unlikely(adapter->hw.mac_type == e1000_82547)) {
 		if(unlikely(e1000_82547_fifo_workaround(adapter, skb))) {
 			netif_stop_queue(netdev);
 			mod_timer(&adapter->tx_fifo_stall_timer, jiffies);
-			spin_unlock_irqrestore(&adapter->tx_lock, flags);
-			return 1;
+			return NETDEV_TX_BUSY;
 		}
 	}
 
@@ -1855,8 +1859,69 @@
 
 	netdev->trans_start = jiffies;
 
+	return NETDEV_TX_OK;
+}
+
+static int
+e1000_xmit_frames(struct sk_buff_head *list, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev->priv;
+	int ret = NETDEV_TX_OK;
+	int didq = 0;
+	int inbatch =  skb_queue_len(list);
+	struct sk_buff	*skb = NULL;
+	unsigned long flags;
+
+ 	local_irq_save(flags); 
+ 	if (!spin_trylock(&adapter->tx_lock)) { 
+ 		/* Collision - tell upper layer to requeue */ 
+ 		local_irq_restore(flags); 
+ 		return NETDEV_TX_LOCKED; 
+ 	} 
+
+	while ((skb = __skb_dequeue(list)) != NULL) {
+		ret = e1000_queue_frame(skb, netdev);
+		if (ret == NETDEV_TX_OK) {
+			didq++;
+		} else {
+			if (ret == NETDEV_TX_BUSY)
+				break;
+		}
+	}
+
+	if (didq)
+		e1000_kick_DMA(adapter, adapter->tx_ring.next_to_use);
+	if (skb_queue_len(list) && (inbatch > skb_queue_len(list)))
+		ret = NETDEV_TX_BUSY;
+	else
+		ret = NETDEV_TX_OK;
 	spin_unlock_irqrestore(&adapter->tx_lock, flags);
-	return 0;
+	return ret;
+}
+
+static int
+e1000_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
+{
+	struct e1000_adapter *adapter = netdev->priv;
+	int ret = NETDEV_TX_OK;
+	unsigned long flags;
+
+ 	local_irq_save(flags); 
+ 	if (!spin_trylock(&adapter->tx_lock)) { 
+ 		/* Collision - tell upper layer to requeue */ 
+ 		local_irq_restore(flags); 
+ 		return NETDEV_TX_LOCKED; 
+ 	} 
+
+	ret = e1000_queue_frame(skb, netdev);
+	if (ret == NETDEV_TX_OK) {
+		e1000_kick_DMA(adapter, adapter->tx_ring.next_to_use);
+	}
+
+	spin_unlock_irqrestore(&adapter->tx_lock, flags);
+	if (ret == NETDEV_TX_DROPPED)
+		ret = NETDEV_TX_OK;
+	return ret;
 }
 
 /**

--=-LvwXueET1uGxmrAzo7XZ--
