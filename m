From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out
Date: Fri, 18 Jun 2004 11:11:24 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040618111124.3a2681b5@dell_ss3.pdx.osdl.net>
References: <40CDD68C.8070509@dgreaves.com>
	<20040615155111.26d6b809@dell_ss3.pdx.osdl.net>
	<40D0280B.2030308@dgreaves.com>
	<Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Greaves <david@dgreaves.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jens Laas <jens.laas@data.slu.se>
In-Reply-To: <Pine.LNX.4.60.0406180953240.1089@jlaas2.data.slu.se>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

To get to the root of these problems, could you:

* Give full lspci -v output for the boards in question.

* Are you using any special queuing or shaping (output of "tc qdisc ls")

* You could try the following, which dumps out the state of the transmit ring
  in case of error. and tries to see if it is one of the other watchdog hooks in
  this driver.

------
diff -Nru a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
--- a/drivers/net/e1000/e1000_main.c	2004-06-18 11:09:36 -07:00
+++ b/drivers/net/e1000/e1000_main.c	2004-06-18 11:09:36 -07:00
@@ -1426,6 +1426,7 @@
 			 * but we've got queued Tx work that's never going
 			 * to get done, so reset controller to flush Tx.
 			 * (Do the reset outside of interrupt context). */
+			printk("%s: link lost but ring is full\n", netdev->name);
 			schedule_work(&adapter->tx_timeout_task);
 		}
 	}
@@ -1450,8 +1451,12 @@
 	i = txdr->next_to_clean;
 	if(txdr->buffer_info[i].dma &&
 	   time_after(jiffies, txdr->buffer_info[i].time_stamp + HZ) &&
-	   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF))
+	   !(E1000_READ_REG(&adapter->hw, STATUS) & E1000_STATUS_TXOFF)) {
+		printk("%s: may be hung last tx was %ld ticks\n",
+		       netdev->name, 
+		       (long)(jiffies - txdr->buffer_info[i].time_stamp));
 		netif_stop_queue(netdev);
+	}
 
 	/* Reset the timer */
 	mod_timer(&adapter->watchdog_timer, jiffies + 2 * HZ);
@@ -1826,6 +1831,7 @@
 {
 	struct e1000_adapter *adapter = netdev->priv;
 
+	printk("%s: transmit timeout from queuing\n", netdev->name);
 	/* Do the reset outside of interrupt context */
 	schedule_work(&adapter->tx_timeout_task);
 }
@@ -1834,6 +1840,21 @@
 e1000_tx_timeout_task(struct net_device *netdev)
 {
 	struct e1000_adapter *adapter = netdev->priv;
+	unsigned long now = jiffies;
+	int i;
+
+	printk("%s: state=0x%lx transmit ring size=%u count=%u to_use=%u to_clean=%u\n",
+	       netdev->name, netdev->state,
+	       adapter->tx_ring.size, adapter->tx_ring.count,
+	       adapter->tx_ring.next_to_use, adapter->tx_ring.next_to_clean);
+	
+	for (i = 0; i < adapter->tx_ring.count; ++i) {
+		struct e1000_buffer *b = &adapter->tx_ring.buffer_info[i];
+		printk(" %d: skb=%p dma=%llu length=%lu time=+%ld watch=%u\n",
+		       i, b->skb, b->dma, b->length, 
+		       (long) (now - b->time_stamp), b->next_to_watch);
+	}
+	
 
 	netif_device_detach(netdev);
 	e1000_down(adapter);
