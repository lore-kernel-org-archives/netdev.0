From: David Miller <davem@davemloft.net>
Subject: Re: [REGRESSION] 2.6.24-rc7: e1000: Detected Tx Unit Hang
Date: Fri, 18 Jan 2008 04:11:44 -0800 (PST)
Message-ID: <20080118.041144.81957249.davem@davemloft.net>
References: <200801160956.09053.elendil@planet.nl>
	<20080116.022953.184520911.davem@davemloft.net>
	<18318.14810.877279.41815@robur.slu.se>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: elendil@planet.nl, jesse.brandeburg@intel.com,
	slavon@bigtelecom.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Robert.Olsson@data.slu.se
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758586AbYARML4@vger.kernel.org>
In-Reply-To: <18318.14810.877279.41815@robur.slu.se>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Robert Olsson <Robert.Olsson@data.slu.se>
Date: Wed, 16 Jan 2008 18:07:38 +0100

> 
> eth0 e1000_irq_enable sem = 1    <- High netload
> eth0 e1000_irq_enable sem = 1
> eth0 e1000_irq_enable sem = 1
> eth0 e1000_irq_enable sem = 1
> eth0 e1000_irq_enable sem = 1
> eth0 e1000_irq_enable sem = 1
> eth0 e1000_irq_enable sem = 1    <- ifconfig eth0 down
> eth0 e1000_irq_disable sem = 2
> 
> **e1000_open                     <- ifconfig eth0 up
> eth0 e1000_irq_disable sem = 3      Dead. irq's can't be enabled
> e1000_irq_enable miss
> eth0 e1000_irq_enable sem = 2
> e1000_irq_enable miss
> eth0 e1000_irq_enable sem = 1
> ADDRCONF(NETDEV_UP): eth0: link is not ready

Yes, this semaphore thing is highly problematic.  In the most crucial
areas where network driver consistency matters the most for ease of
understanding and debugging, the Intel drivers choose to be different
:-(

The way the napi_disable() logic breaks out from high packet load in
net_rx_action() is it simply returns even leaving interrupts disabled
when a pending napi_disable() is pending.

This is what trips up the semaphore logic.

Robert, give this patch a try.

In the long term this semaphore should be completely eliminated,
there is no justification for it.

Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index 0c9a6f7..76c0fa6 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -632,6 +632,7 @@ e1000_down(struct e1000_adapter *adapter)
 
 #ifdef CONFIG_E1000_NAPI
 	napi_disable(&adapter->napi);
+	atomic_set(&adapter->irq_sem, 0);
 #endif
 	e1000_irq_disable(adapter);
 
diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 2ab3bfb..9cc5a6b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -2183,6 +2183,7 @@ void e1000e_down(struct e1000_adapter *adapter)
 	msleep(10);
 
 	napi_disable(&adapter->napi);
+	atomic_set(&adapter->irq_sem, 0);
 	e1000_irq_disable(adapter);
 
 	del_timer_sync(&adapter->watchdog_timer);
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index d2fb88d..4f63839 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -296,6 +296,11 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 {
 	struct net_device *netdev = adapter->netdev;
 
+#ifdef CONFIG_IXGB_NAPI
+	napi_disable(&adapter->napi);
+	atomic_set(&adapter->irq_sem, 0);
+#endif
+
 	ixgb_irq_disable(adapter);
 	free_irq(adapter->pdev->irq, netdev);
 
@@ -304,9 +309,7 @@ ixgb_down(struct ixgb_adapter *adapter, boolean_t kill_watchdog)
 
 	if(kill_watchdog)
 		del_timer_sync(&adapter->watchdog_timer);
-#ifdef CONFIG_IXGB_NAPI
-	napi_disable(&adapter->napi);
-#endif
+
 	adapter->link_speed = 0;
 	adapter->link_duplex = 0;
 	netif_carrier_off(netdev);
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index de3f45e..a4265bc 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1409,9 +1409,11 @@ void ixgbe_down(struct ixgbe_adapter *adapter)
 	IXGBE_WRITE_FLUSH(&adapter->hw);
 	msleep(10);
 
+	napi_disable(&adapter->napi);
+	atomic_set(&adapter->irq_sem, 0);
+
 	ixgbe_irq_disable(adapter);
 
-	napi_disable(&adapter->napi);
 	del_timer_sync(&adapter->watchdog_timer);
 
 	netif_carrier_off(netdev);
