From: Scott Feldman <scott.feldman@intel.com>
Subject: [PATCH 2.6] e100: use NAPI mode all the time
Date: Fri, 4 Jun 2004 17:35:26 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0406041727160.2662@sfeldma-ich5.jf.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@oss.sgi.com, scott.feldman@intel.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I see no reason to keep the non-NAPI option for e100.  This patch removes
the CONFIG_E100_NAPI option and puts the driver in NAPI mode all the time.
Matches the way tg3 works.

Unless someone has a really good reason to keep the non-NAPI mode, this
should go in for 2.6.7.

-scott

----------------

diff -Naurp linux-2.6.7-rc2-bk5/drivers/net/e100.c linux-2.6.7-rc2-bk5.mod/drivers/net/e100.c
--- linux-2.6.7-rc2-bk5/drivers/net/e100.c	2004-06-04 15:58:07.000000000 -0700
+++ linux-2.6.7-rc2-bk5.mod/drivers/net/e100.c	2004-06-04 16:02:04.000000000 -0700
@@ -87,9 +87,8 @@
  *	cb_to_use is the next CB to use for queuing a command; cb_to_clean
  *	is the next CB to check for completion; cb_to_send is the first
  *	CB to start on in case of a previous failure to resume.  CB clean
- *	up happens in interrupt context in response to a CU interrupt, or
- *	in dev->poll in the case where NAPI is enabled.  cbs_avail keeps
- *	track of number of free CB resources available.
+ *	up happens in interrupt context in response to a CU interrupt.
+ *	cbs_avail keeps track of number of free CB resources available.
  *
  * 	Hardware padding of short packets to minimum packet size is
  * 	enabled.  82557 pads with 7Eh, while the later controllers pad
@@ -112,9 +111,8 @@
  *	replacement RFDs cannot be allocated, or the RU goes non-active,
  *	the RU must be restarted.  Frame arrival generates an interrupt,
  *	and Rx indication and re-allocation happen in the same context,
- *	therefore no locking is required.  If NAPI is enabled, this work
- *	happens in dev->poll.  A software-generated interrupt is gen-
- *	erated from the watchdog to recover from a failed allocation
+ *	therefore no locking is required.  A software-generated interrupt
+ *	is generated from the watchdog to recover from a failed allocation
  *	senario where all Rx resources have been indicated and none re-
  *	placed.
  *
@@ -126,8 +124,6 @@
  * 	supported.  Tx Scatter/Gather is not supported.  Jumbo Frames is
  * 	not supported (hardware limitation).
  *
- * 	NAPI support is enabled with CONFIG_E100_NAPI.
- *
  * 	MagicPacket(tm) WoL support is enabled/disabled via ethtool.
  *
  * 	Thanks to JC (jchapman@katalix.com) for helping with
@@ -158,7 +154,7 @@


 #define DRV_NAME		"e100"
-#define DRV_VERSION		"3.0.18"
+#define DRV_VERSION		"3.0.22-NAPI"
 #define DRV_DESCRIPTION		"Intel(R) PRO/100 Network Driver"
 #define DRV_COPYRIGHT		"Copyright(c) 1999-2004 Intel Corporation"
 #define PFX			DRV_NAME ": "
@@ -1463,11 +1459,7 @@ static inline int e100_rx_indicate(struc
 		nic->net_stats.rx_packets++;
 		nic->net_stats.rx_bytes += actual_size;
 		nic->netdev->last_rx = jiffies;
-#ifdef CONFIG_E100_NAPI
 		netif_receive_skb(skb);
-#else
-		netif_rx(skb);
-#endif
 		if(work_done)
 			(*work_done)++;
 	}
@@ -1562,20 +1554,12 @@ static irqreturn_t e100_intr(int irq, vo
 	if(stat_ack & stat_ack_rnr)
 		nic->ru_running = 0;

-#ifdef CONFIG_E100_NAPI
 	e100_disable_irq(nic);
 	netif_rx_schedule(netdev);
-#else
-	if(stat_ack & stat_ack_rx)
-		e100_rx_clean(nic, NULL, 0);
-	if(stat_ack & stat_ack_tx)
-		e100_tx_clean(nic);
-#endif

 	return IRQ_HANDLED;
 }

-#ifdef CONFIG_E100_NAPI
 static int e100_poll(struct net_device *netdev, int *budget)
 {
 	struct nic *nic = netdev_priv(netdev);
@@ -1598,7 +1582,6 @@ static int e100_poll(struct net_device *

 	return 1;
 }
-#endif

 #ifdef CONFIG_NET_POLL_CONTROLLER
 static void e100_netpoll(struct net_device *netdev)
@@ -2137,10 +2120,8 @@ static int __devinit e100_probe(struct p
 	SET_ETHTOOL_OPS(netdev, &e100_ethtool_ops);
 	netdev->tx_timeout = e100_tx_timeout;
 	netdev->watchdog_timeo = E100_WATCHDOG_PERIOD;
-#ifdef CONFIG_E100_NAPI
 	netdev->poll = e100_poll;
 	netdev->weight = E100_NAPI_WEIGHT;
-#endif
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	netdev->poll_controller = e100_netpoll;
 #endif
diff -Naurp linux-2.6.7-rc2-bk5/drivers/net/Kconfig linux-2.6.7-rc2-bk5.mod/drivers/net/Kconfig
--- linux-2.6.7-rc2-bk5/drivers/net/Kconfig	2004-06-04 15:58:26.000000000 -0700
+++ linux-2.6.7-rc2-bk5.mod/drivers/net/Kconfig	2004-06-04 16:02:34.000000000 -0700
@@ -1498,10 +1498,6 @@ config E100
 	  <file:Documentation/networking/net-modules.txt>.  The module
 	  will be called e100.

-config E100_NAPI
-	bool "Use Rx Polling (NAPI)"
-	depends on E100
-
 config LNE390
 	tristate "Mylex EISA LNE390A/B support (EXPERIMENTAL)"
 	depends on NET_PCI && EISA && EXPERIMENTAL
