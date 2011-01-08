From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [GIT] Networking
Date: Sat, 8 Jan 2011 13:17:26 +0100
Message-ID: <20110108121726.GA2216@electric-eye.fr.zoreil.com>
References: <20110106.122003.233698077.davem@davemloft.net> <AANLkTi=7=_FyVsjA3vKEpg8RwfC=m-8QGfqa6ctxQday@mail.gmail.com> <20110107190656.GQ3702@decadent.org.uk> <AANLkTikwrHoOY4wvUp1qn-OT=EjZesSNR29US1ERc0o2@mail.gmail.com> <20110107215505.GA1892@electric-eye.fr.zoreil.com> <AANLkTinANp+Jp8TPKzii6iZLUFpMyrXhmxYr42nZrXQU@mail.gmail.com> <20110108000901.GA2133@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Hutchings <benh@debian.org>,
	David Miller <davem@davemloft.net>,
	Hayes Wang <hayeswang@realtek.com>,
	David Woodhouse <dwmw2@infradead.org>,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110108000901.GA2133@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

r8169: delay phy init until device opens.

It workarounds the 60s firmware load failure timeout for the
non-modular case.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 27a7c20..dd758cd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3069,15 +3069,6 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		rtl8168_driver_start(tp);
 	}
 
-	rtl8169_init_phy(dev, tp);
-
-	/*
-	 * Pretend we are using VLANs; This bypasses a nasty bug where
-	 * Interrupts stop flowing on high load on 8110SCd controllers.
-	 */
-	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
-		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | RxVlan);
-
 	device_set_wakeup_enable(&pdev->dev, tp->features & RTL_FEATURE_WOL);
 
 	if (pci_dev_run_wake(pdev))
@@ -3127,6 +3118,7 @@ static void __devexit rtl8169_remove_one(struct pci_dev *pdev)
 static int rtl8169_open(struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	void __iomem *ioaddr = tp->mmio_addr;
 	struct pci_dev *pdev = tp->pci_dev;
 	int retval = -ENOMEM;
 
@@ -3162,6 +3154,15 @@ static int rtl8169_open(struct net_device *dev)
 
 	napi_enable(&tp->napi);
 
+	rtl8169_init_phy(dev, tp);
+
+	/*
+	 * Pretend we are using VLANs; This bypasses a nasty bug where
+	 * Interrupts stop flowing on high load on 8110SCd controllers.
+	 */
+	if (tp->mac_version == RTL_GIGA_MAC_VER_05)
+		RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) | RxVlan);
+
 	rtl_pll_power_up(tp);
 
 	rtl_hw_start(dev);
@@ -3171,7 +3172,7 @@ static int rtl8169_open(struct net_device *dev)
 	tp->saved_wolopts = 0;
 	pm_runtime_put_noidle(&pdev->dev);
 
-	rtl8169_check_link_status(dev, tp, tp->mmio_addr);
+	rtl8169_check_link_status(dev, tp, ioaddr);
 out:
 	return retval;
 
