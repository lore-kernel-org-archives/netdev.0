From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - it's dead jim
Date: Sun, 24 Nov 2013 01:50:22 +0100
Message-ID: <20131124005022.GA6299@electric-eye.fr.zoreil.com>
References: <529105F8.9030901@nurealm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek and the Linux r8169 crew <netdev@vger.kernel.org>
To: James Feeney <james@nurealm.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:53192 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755583Ab3KXAuY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Nov 2013 19:50:24 -0500
Content-Disposition: inline
In-Reply-To: <529105F8.9030901@nurealm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Feeney <james@nurealm.net> :
[...]
> Going from 3.12.0-1-ARCH to 3.12.1-1-ARCH, the r8169 module is having the
> "link detect" problem again.

$ grep james@nurealm.net ~/Mail/linux/netdev/201[123]?? | grep -v 201311

Which one exactly ?

> Initially, "ethtool -s <blah> autoneg off" gives "invalid argument".

blah ?

[...]
> After some time, Auto-negotiation will spontaneously go on, and a 100Mb/s full
> duplex connection will come up, on a 1Gb/s interface.  Subsequent unplugging and
> plugging the cable gives a 1Gb/s full duplex connection.
> 
> This problem has been recurring for so many years, I hope the solution is
> something obvious, perhaps a recent change to the kernel?

The r8169 driver is the same in v3.12 and v3.12.1. Either some userspace
application works in your back or your device experienced a runtime
suspend / resume cycle where it previously didn't.

You can try the genuinely untested hack below if you don't like current
runtime suspend / resume behavior.

What do you want exactly ? 10 Mb/s, 100 Mb/s ? Limited / no advertising ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 7280d5d..701ca00 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -812,6 +812,13 @@ struct rtl8169_private {
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
 
 	u32 ocp_base;
+
+	struct {
+		u32 adv;
+		u16 speed;
+		u8 duplex;
+		u8 autoneg;
+	} rtl_settings;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -1755,6 +1762,11 @@ static int rtl8169_set_speed(struct net_device *dev,
 	if (ret < 0)
 		goto out;
 
+	tp->autoneg	= autoneg;
+	tp->speed	= speed;
+	tp->duplex	= duplex;
+	tp->adv		= advertising;
+
 	if (netif_running(dev) && (autoneg == AUTONEG_ENABLE) &&
 	    (advertising & ADVERTISED_1000baseT_Full)) {
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -3778,6 +3790,14 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
 }
 
+static void rtl_resume_phy(struct net_device *dev, struct rtl8169_private *tp)
+{
+	rtl8169_init_phy(dev, tp);
+
+	if (tp->speed)
+		tp->set_speed(dev, tp->autoneg, tp->speed, tp->duplex, tp->adv);
+}
+
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -6661,7 +6681,7 @@ static int rtl8169_resume(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl8169_init_phy(dev, tp);
+	rtl_resume_phy(dev, tp);
 
 	if (netif_running(dev))
 		__rtl8169_resume(dev);
@@ -6702,7 +6722,7 @@ static int rtl8169_runtime_resume(struct device *device)
 	tp->saved_wolopts = 0;
 	rtl_unlock_work(tp);
 
-	rtl8169_init_phy(dev, tp);
+	rtl_resume_phy(dev, tp);
 
 	__rtl8169_resume(dev);
 
