From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 2.6.9-rc3-mm2 4/5] r8169: rtl8169_close() races
Date: Mon, 4 Oct 2004 21:52:16 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041004195216.GC20379@electric-eye.fr.zoreil.com>
References: <20041004194826.GA18404@electric-eye.fr.zoreil.com> <20041004194949.GA20379@electric-eye.fr.zoreil.com> <20041004195051.GB20379@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com, akpm@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: jgarzik@pobox.com
Content-Disposition: inline
In-Reply-To: <20041004195051.GB20379@electric-eye.fr.zoreil.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

- close the race with rtl8169_interrupt() which appears when rtl8169_close()
  uses synchronize_irq()/free_irq();
- netif_poll_disable() allows rtl8169_close() to wait for any pending
  rtl8169_poll() to complete so it can safely clear the rings.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff -puN drivers/net/r8169.c~r8169-215 drivers/net/r8169.c
--- linux-2.6.9-rc3/drivers/net/r8169.c~r8169-215	2004-10-04 21:26:01.000000000 +0200
+++ linux-2.6.9-rc3-fr/drivers/net/r8169.c	2004-10-04 21:26:01.000000000 +0200
@@ -2142,6 +2142,9 @@ rtl8169_interrupt(int irq, void *dev_ins
 	int status = 0;
 	int handled = 0;
 
+	if (unlikely(!netif_running(dev)))
+		goto out;
+
 	do {
 		status = RTL_R16(IntrStatus);
 
@@ -2196,6 +2199,7 @@ rtl8169_interrupt(int irq, void *dev_ins
 		/* Clear all interrupt sources. */
 		RTL_W16(IntrStatus, 0xffff);
 	}
+out:
 	return IRQ_RETVAL(handled);
 }
 
@@ -2259,6 +2263,8 @@ rtl8169_close(struct net_device *dev)
 	synchronize_irq(dev->irq);
 	free_irq(dev->irq, dev);
 
+	netif_poll_disable(dev);
+
 	rtl8169_tx_clear(tp);
 
 	rtl8169_rx_clear(tp);

_
