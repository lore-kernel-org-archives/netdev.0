From: jc <jchapman@katalix.com>
Subject: NAPI poll: why not consider transmit cleanup work before exiting poll mode?
Date: Sun, 24 Aug 2003 07:57:04 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1061708224.3f4861c063706@webmail.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Why don't NAPI drivers consider transmit completion work before doing
netif_rx_complete() and re-enabling interrupts?

NAPI drivers do netif_rx_complete() in their poll routines if no rx
work is done but ignore whether they do any tx work. When the driver
transmits bursty data (i.e. no rx events, only tx completion events)
the driver's dev->poll always re-enables interrupts each time it is
called, resulting in suboptimal performance.

The latest e100 development driver (e100-3.0.0dev13) has been modified
so that its dev->poll does netif_rx_complete() only if no receive _or_
transmit work is done. Thus, under bursty receive or transmit load,
interrupts stay off even if the traffic is in only one direction.

Here's a patch fragment showing the key code changes. Notice that the
condition for doing netif_rx_complete() now includes a test of whether
any transmit work was done.

Is this breaking NAPI rules? If not, should other NAPI drivers do the same?

-jc

----

@@ -1200,7 +1201,7 @@
 	return 0;
 }
 
-static inline void e100_tx_clean(struct nic *nic)
+static inline int e100_tx_clean(struct nic *nic)
 {
 	struct cb *cb;
 	int tx_cleaned = 0;
@@ -1234,6 +1235,8 @@
 	/* Recover from running out of Tx resources in xmit_frame */
 	if(unlikely(tx_cleaned && netif_queue_stopped(nic->netdev)))
 		netif_wake_queue(nic->netdev);
+
+	return tx_cleaned;
 }
 
@@ -1514,19 +1515,21 @@
 	struct nic *nic = netdev->priv;
 	unsigned int work_to_do = min(netdev->quota, *budget);
 	unsigned int work_done = 0;
+	int tx_cleaned;
 
 	e100_rx_clean(nic, &work_done, work_to_do);
-	e100_tx_clean(nic);
+	tx_cleaned = e100_tx_clean(nic);
 
-	*budget -= work_done;
-	netdev->quota -= work_done;
-
-	if(work_done == 0) {
+	/* If no Rx and Tx cleanup work was done, exit polling mode. */
+	if(!tx_cleaned && (work_done == 0)) {
 		netif_rx_complete(netdev);
 		e100_enable_irq(nic);
 		return 0;
 	}
 
+	*budget -= work_done;
+	netdev->quota -= work_done;
+
 	return 1;
 }
 #endif





-------------------------------------------------
This mail sent through IMP: http://horde.org/imp/
