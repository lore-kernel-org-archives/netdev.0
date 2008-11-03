From: Jeff Garzik <jeff@garzik.org>
Subject: [git patches] net driver fixes for 2.6.28-rc
Date: Mon, 3 Nov 2008 15:51:22 -0500
Message-ID: <20081103205121.GA6005@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from havoc.gtf.org ([69.61.125.42]:42972 "EHLO havoc.gtf.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755572AbYKCUvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Nov 2008 15:51:23 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Please pull from 'davem-fixes' branch of
master.kernel.org:/pub/scm/linux/kernel/git/jgarzik/netdev-2.6.git davem-fixes

to receive the following updates:

 drivers/net/Kconfig                |   18 +++++++++++++++---
 drivers/net/fs_enet/fs_enet-main.c |    6 ++++--
 drivers/net/mv643xx_eth.c          |    9 ++++++---
 3 files changed, 25 insertions(+), 8 deletions(-)

Alexey Dobriyan (1):
      fs_enet: fix polling

Jeff Kirsher (1):
      net: kconfig cleanup

Lennert Buytenhek (1):
      mv643xx_eth: fix SMI bus access timeouts

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f749b40..11f143f 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2010,9 +2010,13 @@ config IGB_LRO
 	  If in doubt, say N.
 
 config IGB_DCA
-	bool "Enable DCA"
+	bool "Direct Cache Access (DCA) Support"
 	default y
 	depends on IGB && DCA && !(IGB=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
 
 source "drivers/net/ixp2000/Kconfig"
 
@@ -2437,9 +2441,13 @@ config IXGBE
 	  will be called ixgbe.
 
 config IXGBE_DCA
-	bool
+	bool "Direct Cache Access (DCA) Support"
 	default y
 	depends on IXGBE && DCA && !(IXGBE=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
 
 config IXGB
 	tristate "Intel(R) PRO/10GbE support"
@@ -2489,9 +2497,13 @@ config MYRI10GE
 	  will be called myri10ge.
 
 config MYRI10GE_DCA
-	bool
+	bool "Direct Cache Access (DCA) Support"
 	default y
 	depends on MYRI10GE && DCA && !(MYRI10GE=y && DCA=m)
+	---help---
+	  Say Y here if you want to use Direct Cache Access (DCA) in the
+	  driver.  DCA is a method for warming the CPU cache before data
+	  is used, with the intent of lessening the impact of cache misses.
 
 config NETXEN_NIC
 	tristate "NetXen Multi port (1/10) Gigabit Ethernet NIC"
diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_enet-main.c
index cb51c1f..a6f49d0 100644
--- a/drivers/net/fs_enet/fs_enet-main.c
+++ b/drivers/net/fs_enet/fs_enet-main.c
@@ -1099,7 +1099,9 @@ static int __devinit fs_enet_probe(struct of_device *ofdev,
 	ndev->stop = fs_enet_close;
 	ndev->get_stats = fs_enet_get_stats;
 	ndev->set_multicast_list = fs_set_multicast_list;
-
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	ndev->poll_controller = fs_enet_netpoll;
+#endif
 	if (fpi->use_napi)
 		netif_napi_add(ndev, &fep->napi, fs_enet_rx_napi,
 		               fpi->napi_weight);
@@ -1209,7 +1211,7 @@ static void __exit fs_cleanup(void)
 static void fs_enet_netpoll(struct net_device *dev)
 {
        disable_irq(dev->irq);
-       fs_enet_interrupt(dev->irq, dev, NULL);
+       fs_enet_interrupt(dev->irq, dev);
        enable_irq(dev->irq);
 }
 #endif
diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
index a9c8c08..b9dcdbd 100644
--- a/drivers/net/mv643xx_eth.c
+++ b/drivers/net/mv643xx_eth.c
@@ -1066,9 +1066,12 @@ static int smi_wait_ready(struct mv643xx_eth_shared_private *msp)
 		return 0;
 	}
 
-	if (!wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
-				msecs_to_jiffies(100)))
-		return -ETIMEDOUT;
+	if (!smi_is_done(msp)) {
+		wait_event_timeout(msp->smi_busy_wait, smi_is_done(msp),
+				   msecs_to_jiffies(100));
+		if (!smi_is_done(msp))
+			return -ETIMEDOUT;
+	}
 
 	return 0;
 }
