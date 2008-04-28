From: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>
Subject: [PATCH] 3c505: use netstats in net_device structure
Date: Tue, 29 Apr 2008 02:27:37 +0300
Message-ID: <48165D69.30706@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010805070805010204020306"
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:44823 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765695AbYD1X2B (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Apr 2008 19:28:01 -0400
Received: from list by ciao.gmane.org with local (Exim 4.43)
	id 1JqclH-0005C8-12
	for netdev@vger.kernel.org; Mon, 28 Apr 2008 23:27:55 +0000
Received: from 78-62-85-225.static.zebra.lt ([78.62.85.225])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 23:27:55 +0000
Received: from paulius.zaleckas by 78-62-85-225.static.zebra.lt with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Mon, 28 Apr 2008 23:27:55 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------010805070805010204020306
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Use net_device_stats from net_device structure instead of local.
No need to memset it to 0, because it is allocated by kzalloc.

Signed-off-by: Paulius Zaleckas <paulius.zaleckas@teltonika.lt>

--------------010805070805010204020306
Content-Type: text/x-patch;
 name="3c505_netstats.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="3c505_netstats.patch"

diff --git a/drivers/net/3c505.c b/drivers/net/3c505.c
index 9c65734..fdfb2b2 100644
--- a/drivers/net/3c505.c
+++ b/drivers/net/3c505.c
@@ -670,7 +670,7 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 				  	memcpy(adapter->current_dma.target, adapter->dma_buffer, adapter->current_dma.length);
 					}
 					skb->protocol = eth_type_trans(skb,dev);
-					adapter->stats.rx_bytes += skb->len;
+					dev->stats.rx_bytes += skb->len;
 					netif_rx(skb);
 					dev->last_rx = jiffies;
 				}
@@ -773,12 +773,12 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 					 * received board statistics
 					 */
 				case CMD_NETWORK_STATISTICS_RESPONSE:
-					adapter->stats.rx_packets += adapter->irx_pcb.data.netstat.tot_recv;
-					adapter->stats.tx_packets += adapter->irx_pcb.data.netstat.tot_xmit;
-					adapter->stats.rx_crc_errors += adapter->irx_pcb.data.netstat.err_CRC;
-					adapter->stats.rx_frame_errors += adapter->irx_pcb.data.netstat.err_align;
-					adapter->stats.rx_fifo_errors += adapter->irx_pcb.data.netstat.err_ovrrun;
-					adapter->stats.rx_over_errors += adapter->irx_pcb.data.netstat.err_res;
+					dev->stats.rx_packets += adapter->irx_pcb.data.netstat.tot_recv;
+					dev->stats.tx_packets += adapter->irx_pcb.data.netstat.tot_xmit;
+					dev->stats.rx_crc_errors += adapter->irx_pcb.data.netstat.err_CRC;
+					dev->stats.rx_frame_errors += adapter->irx_pcb.data.netstat.err_align;
+					dev->stats.rx_fifo_errors += adapter->irx_pcb.data.netstat.err_ovrrun;
+					dev->stats.rx_over_errors += adapter->irx_pcb.data.netstat.err_res;
 					adapter->got[CMD_NETWORK_STATISTICS] = 1;
 					if (elp_debug >= 3)
 						printk(KERN_DEBUG "%s: interrupt - statistics response received\n", dev->name);
@@ -794,11 +794,11 @@ static irqreturn_t elp_interrupt(int irq, void *dev_id)
 						break;
 					switch (adapter->irx_pcb.data.xmit_resp.c_stat) {
 					case 0xffff:
-						adapter->stats.tx_aborted_errors++;
+						dev->stats.tx_aborted_errors++;
 						printk(KERN_INFO "%s: transmit timed out, network cable problem?\n", dev->name);
 						break;
 					case 0xfffe:
-						adapter->stats.tx_fifo_errors++;
+						dev->stats.tx_fifo_errors++;
 						printk(KERN_INFO "%s: transmit timed out, FIFO underrun\n", dev->name);
 						break;
 					}
@@ -986,7 +986,7 @@ static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 		return false;
 	}
 
-	adapter->stats.tx_bytes += nlen;
+	dev->stats.tx_bytes += nlen;
 
 	/*
 	 * send the adapter a transmit packet command. Ignore segment and offset
@@ -1041,7 +1041,6 @@ static bool send_packet(struct net_device *dev, struct sk_buff *skb)
 
 static void elp_timeout(struct net_device *dev)
 {
-	elp_device *adapter = dev->priv;
 	int stat;
 
 	stat = inb_status(dev->base_addr);
@@ -1049,7 +1048,7 @@ static void elp_timeout(struct net_device *dev)
 	if (elp_debug >= 1)
 		printk(KERN_DEBUG "%s: status %#02x\n", dev->name, stat);
 	dev->trans_start = jiffies;
-	adapter->stats.tx_dropped++;
+	dev->stats.tx_dropped++;
 	netif_wake_queue(dev);
 }
 
@@ -1113,7 +1112,7 @@ static struct net_device_stats *elp_get_stats(struct net_device *dev)
 	/* If the device is closed, just return the latest stats we have,
 	   - we cannot ask from the adapter without interrupts */
 	if (!netif_running(dev))
-		return &adapter->stats;
+		return &dev->stats;
 
 	/* send a get statistics command to the board */
 	adapter->tx_pcb.command = CMD_NETWORK_STATISTICS;
@@ -1126,12 +1125,12 @@ static struct net_device_stats *elp_get_stats(struct net_device *dev)
 		while (adapter->got[CMD_NETWORK_STATISTICS] == 0 && time_before(jiffies, timeout));
 		if (time_after_eq(jiffies, timeout)) {
 			TIMEOUT_MSG(__LINE__);
-			return &adapter->stats;
+			return &dev->stats;
 		}
 	}
 
 	/* statistics are now up to date */
-	return &adapter->stats;
+	return &dev->stats;
 }
 
 
@@ -1571,7 +1570,6 @@ static int __init elplus_setup(struct net_device *dev)
 	dev->set_multicast_list = elp_set_mc_list;	/* local */
 	dev->ethtool_ops = &netdev_ethtool_ops;		/* local */
 
-	memset(&(adapter->stats), 0, sizeof(struct net_device_stats));
 	dev->mem_start = dev->mem_end = 0;
 
 	err = register_netdev(dev);
diff --git a/drivers/net/3c505.h b/drivers/net/3c505.h
index 1910cb1..04df2a9 100644
--- a/drivers/net/3c505.h
+++ b/drivers/net/3c505.h
@@ -264,7 +264,6 @@ typedef struct {
 	pcb_struct rx_pcb;	/* PCB for foreground receiving */
 	pcb_struct itx_pcb;	/* PCB for background sending */
 	pcb_struct irx_pcb;	/* PCB for background receiving */
-	struct net_device_stats stats;
 
 	void *dma_buffer;
 

--------------010805070805010204020306--

