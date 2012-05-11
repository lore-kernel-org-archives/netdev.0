From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: pch_gbe: oops with vlan (new)
Date: Sat, 12 May 2012 00:10:54 +0200
Message-ID: <1336774254.31653.287.camel@edumazet-glaptop>
References: <40680C535D6FE6498883F1640FACD44DDF9105@ka-exchange-1.kontronamerica.local>
	 <1336770777.31653.283.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Andy Cress <andy.cress@us.kontron.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:54527 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759169Ab2EKWLA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 May 2012 18:11:00 -0400
Received: by wibhn6 with SMTP id hn6so687000wib.1
        for <netdev@vger.kernel.org>; Fri, 11 May 2012 15:10:58 -0700 (PDT)
In-Reply-To: <1336770777.31653.283.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-05-11 at 23:13 +0200, Eric Dumazet wrote:
> On Fri, 2012-05-11 at 13:48 -0700, Andy Cress wrote:
> > Folks,
> > 
> > I am looking for help in debugging a pch_gbe driver oops/abort.
> > 
> > Kernel: version 2.6.32-220.el6.i686 (RHEL6.2)
> > Driver: pch_gbe version 0.91-NAPI  (source tarball we used is at
> > https://sendfile.kontron.com/message/24tdUi6MXklnUtBLnOsumq until May
> > 16)
> > NIC: 0b:00.1 Ethernet controller [0200]: Intel Corporation Platform
> > Controller Hub EG20T Gigabit Ethernet Controller [8086:8802] (rev 02)
> > 
> > Configuration, with VLAN:
> >  eth0 (not started)
> >  eth0.100 = 192.168.100.1
> >  eth0.200 = 192.168.200.1
> >  eth0.6  = 192.168.6.1
> > 
> > When starting the VLAN configuration, then doing a ping test for >= 5
> > minutes, I get a kernel oop/abort message as shown below.  This does not
> > happen without configuring VLAN.
> > Where should I look for possible causes for a transmit queue timeout
> > like this?  
> > 
> > I have contacted the OKI/LAPIS driver authors, but no response so far.
> > I thought that this group might be able to comment from similar
> > experiences.
> > 
> > Andy
> 
> typical sign of a buggy driver
> 
> A quick look in current Linus tree show a non existent synchronization
> between ndo_start_xmit and TX completion.
> 
> tx completion uses a tx_queue_lock spinlock for nothing but false sense
> of correctness.

Please try the following patch : (based on current net-next tree)

Also this driver has a strange RX path : It does a copy of incoming
frames on fixed size skbs, (2048+overhead -> kmalloc-4096 pool) instead
of using skb of the right size...



 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h      |    2 
 drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c |   25 ++++------
 2 files changed, 11 insertions(+), 16 deletions(-)

diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
index 9f3dbc4..b07311e 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe.h
@@ -584,7 +584,6 @@ struct pch_gbe_hw_stats {
 /**
  * struct pch_gbe_adapter - board specific private data structure
  * @stats_lock:	Spinlock structure for status
- * @tx_queue_lock:	Spinlock structure for transmit
  * @ethtool_lock:	Spinlock structure for ethtool
  * @irq_sem:		Semaphore for interrupt
  * @netdev:		Pointer of network device structure
@@ -609,7 +608,6 @@ struct pch_gbe_hw_stats {
 
 struct pch_gbe_adapter {
 	spinlock_t stats_lock;
-	spinlock_t tx_queue_lock;
 	spinlock_t ethtool_lock;
 	atomic_t irq_sem;
 	struct net_device *netdev;
diff --git a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
index 9dc7e50..3787c64 100644
--- a/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
+++ b/drivers/net/ethernet/oki-semi/pch_gbe/pch_gbe_main.c
@@ -645,14 +645,11 @@ static void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
  */
 static int pch_gbe_alloc_queues(struct pch_gbe_adapter *adapter)
 {
-	int size;
-
-	size = (int)sizeof(struct pch_gbe_tx_ring);
-	adapter->tx_ring = kzalloc(size, GFP_KERNEL);
+	adapter->tx_ring = kzalloc(sizeof(*adapter->tx_ring), GFP_KERNEL);
 	if (!adapter->tx_ring)
 		return -ENOMEM;
-	size = (int)sizeof(struct pch_gbe_rx_ring);
-	adapter->rx_ring = kzalloc(size, GFP_KERNEL);
+
+	adapter->rx_ring = kzalloc(sizeof(*adapter->rx_ring), GFP_KERNEL);
 	if (!adapter->rx_ring) {
 		kfree(adapter->tx_ring);
 		return -ENOMEM;
@@ -1169,7 +1166,6 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 	struct sk_buff *tmp_skb;
 	unsigned int frame_ctrl;
 	unsigned int ring_num;
-	unsigned long flags;
 
 	/*-- Set frame control --*/
 	frame_ctrl = 0;
@@ -1216,14 +1212,14 @@ static void pch_gbe_tx_queue(struct pch_gbe_adapter *adapter,
 			}
 		}
 	}
-	spin_lock_irqsave(&tx_ring->tx_lock, flags);
+
 	ring_num = tx_ring->next_to_use;
 	if (unlikely((ring_num + 1) == tx_ring->count))
 		tx_ring->next_to_use = 0;
 	else
 		tx_ring->next_to_use = ring_num + 1;
 
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
+
 	buffer_info = &tx_ring->buffer_info[ring_num];
 	tmp_skb = buffer_info->skb;
 
@@ -1525,7 +1521,7 @@ pch_gbe_alloc_rx_buffers_pool(struct pch_gbe_adapter *adapter,
 						&rx_ring->rx_buff_pool_logic,
 						GFP_KERNEL);
 	if (!rx_ring->rx_buff_pool) {
-		pr_err("Unable to allocate memory for the receive poll buffer\n");
+		pr_err("Unable to allocate memory for the receive pool buffer\n");
 		return -ENOMEM;
 	}
 	memset(rx_ring->rx_buff_pool, 0, size);
@@ -1644,15 +1640,17 @@ pch_gbe_clean_tx(struct pch_gbe_adapter *adapter,
 	pr_debug("called pch_gbe_unmap_and_free_tx_resource() %d count\n",
 		 cleaned_count);
 	/* Recover from running out of Tx resources in xmit_frame */
+	spin_lock(&tx_ring->tx_lock);
 	if (unlikely(cleaned && (netif_queue_stopped(adapter->netdev)))) {
 		netif_wake_queue(adapter->netdev);
 		adapter->stats.tx_restart_count++;
 		pr_debug("Tx wake queue\n");
 	}
-	spin_lock(&adapter->tx_queue_lock);
+
 	tx_ring->next_to_clean = i;
-	spin_unlock(&adapter->tx_queue_lock);
+
 	pr_debug("next_to_clean : %d\n", tx_ring->next_to_clean);
+	spin_unlock(&tx_ring->tx_lock);
 	return cleaned;
 }
 
@@ -2043,7 +2041,6 @@ static int pch_gbe_sw_init(struct pch_gbe_adapter *adapter)
 		return -ENOMEM;
 	}
 	spin_lock_init(&adapter->hw.miim_lock);
-	spin_lock_init(&adapter->tx_queue_lock);
 	spin_lock_init(&adapter->stats_lock);
 	spin_lock_init(&adapter->ethtool_lock);
 	atomic_set(&adapter->irq_sem, 0);
@@ -2148,10 +2145,10 @@ static int pch_gbe_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 			 tx_ring->next_to_use, tx_ring->next_to_clean);
 		return NETDEV_TX_BUSY;
 	}
-	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 
 	/* CRC,ITAG no support */
 	pch_gbe_tx_queue(adapter, tx_ring, skb);
+	spin_unlock_irqrestore(&tx_ring->tx_lock, flags);
 	return NETDEV_TX_OK;
 }
 
