From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [patch 2.6.11-rc3 5/5] r8169: synchronization and balancing when the device is closed
Date: Sat, 12 Feb 2005 00:45:22 +0100
Message-ID: <20050211234522.GD13644@electric-eye.fr.zoreil.com>
References: <20050211233918.GB8792@electric-eye.fr.zoreil.com> <20050211234106.GA13644@electric-eye.fr.zoreil.com> <20050211234236.GB13644@electric-eye.fr.zoreil.com> <20050211234403.GC13644@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@osdl.org, jdmason@us.ibm.com, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <20050211234403.GC13644@electric-eye.fr.zoreil.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

rtl8169_close synchronization and balancing

- use synchronize_kernel() to sync with the xmit thread (kindly suggested
  by davem);
- balance the netif_poll_disable issued in rtl8169_down.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-390 drivers/net/r8169.c
--- a/drivers/net/r8169.c~r8169-390	2005-02-12 00:06:40.381648524 +0100
+++ b/drivers/net/r8169.c	2005-02-12 00:06:48.015420988 +0100
@@ -2382,8 +2382,7 @@ static void rtl8169_down(struct net_devi
 	netif_poll_disable(dev);
 
 	/* Give a racing hard_start_xmit a few cycles to complete. */
-	set_current_state(TASK_UNINTERRUPTIBLE);
-	schedule_timeout(1);
+	synchronize_kernel();
 
 	rtl8169_tx_clear(tp);
 
@@ -2399,6 +2398,8 @@ static int rtl8169_close(struct net_devi
 
 	free_irq(dev->irq, dev);
 
+	netif_poll_enable(dev);
+
 	pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDescArray,
 			    tp->RxPhyAddr);
 	pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDescArray,

_
