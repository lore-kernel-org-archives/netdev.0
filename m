From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 - it's dead jim
Date: Sat, 30 Nov 2013 21:39:31 +0100
Message-ID: <20131130203931.GA18929@electric-eye.fr.zoreil.com>
References: <529105F8.9030901@nurealm.net>
 <20131124005022.GA6299@electric-eye.fr.zoreil.com>
 <5296C072.4070000@nurealm.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: James Feeney <james@nurealm.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42018 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751499Ab3K3Ujh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Nov 2013 15:39:37 -0500
Content-Disposition: inline
In-Reply-To: <5296C072.4070000@nurealm.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Feeney <james@nurealm.net> :
[...]
> > Which one exactly ?
> 
> Sorry - just based upon a Google search, this problem with the card not
> recognizing that a cable has been plugged into the interface, seems to
> have come up off and on for a while, many years.

Kind of. The r8169 driver has been evolving for more than 10 years with
quite some features / chipsets / contributors / bugs.

[...]
> That would seem to make sense.  After some more problems with the interface, I
> later noticed that having the card come-up at 1000Mb/s and Full duplex was not
> enough to indicate that the card was working.  When the interface was just
> handling ping packets it seemed to work fine.  But then, whenever there was a
> file transfer - downloading some email or a large file, for instance - the
> interface seems to "choke".  Watching a repeated "ethtool enp22s0", the link
> speed and duplex would change constantly, dropping down to 10Mb/s and Half
> duplex, then up to 100Mb/s and Full duplex, than back down.  If the file

You should increase the verbosity level through 'ethtool msglvl'. No need
to be clever, start with a gross 65535.

I'll then welcome the dmesg (ethtool -S may want to tell something too).

> transfers were halted, so that nothing more than ping was going through the
> interface, the speed and duplex would come back up, to 1000Mb/s and Full
> duplex.

Stating the obvious: your switch supports 1000Mb/s, right ?

>  Practically, the interface was unusable, and I swapped-out the card for an
> Intel Pro 100, which works fine.   So the problem would then seem to have
> nothing to do with the PC Card hardware on the Thinkpad.

Ok.

> > What do you want exactly ? 10 Mb/s, 100 Mb/s ? Limited / no advertising ?
> 
> Well, according to "ethtool", the card advertises up to 1000Mb/s, Full duplex,
> and Auto-negotiation.  It just seems that it should not constantly try to
> re-configure itself.  I have not studied the code to find-out what would
> trigger a re-negotiation, or trigger a suspend/resume.

Runtime suspend will kick in automatically if there is no activity and
it has been enabled. You can check the later through the
/sys/devices/.../power/control file (on = disabled, auto = enabled, see
Documentation/power/runtime_pm.txt).

[...]
> Maybe there is a simple way to modify the driver to "lock" the configuration?
> Or ... ?
> 
> If you have another patch, I can plug the card back in and try it out.

The patch below should restore whatever link settings you asked for if
runtime suspend / resume kicks in.

I would suggest you avoid disabling autoneg. You can reduce the set of
advertised speed though.

Subject: [PATCH] r8169: restore user link settings after resume.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 27 +++++++++++++++++++++++++--
 1 file changed, 25 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b7a01c8..ad67481 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -812,6 +812,13 @@ struct rtl8169_private {
 #define RTL_FIRMWARE_UNKNOWN	ERR_PTR(-EAGAIN)
 
 	u32 ocp_base;
+
+	struct rtl_link_setting {
+		u32 adv;
+		u16 speed;
+		u8 duplex;
+		u8 autoneg;
+	} link_sets;
 };
 
 MODULE_AUTHOR("Realtek and the Linux r8169 crew <netdev@vger.kernel.org>");
@@ -1749,12 +1756,18 @@ static int rtl8169_set_speed(struct net_device *dev,
 			     u8 autoneg, u16 speed, u8 duplex, u32 advertising)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	struct rtl_link_setting *ls = &tp->link_sets;
 	int ret;
 
 	ret = tp->set_speed(dev, autoneg, speed, duplex, advertising);
 	if (ret < 0)
 		goto out;
 
+	ls->autoneg	= autoneg;
+	ls->speed	= speed;
+	ls->duplex	= duplex;
+	ls->adv		= advertising;
+
 	if (netif_running(dev) && (autoneg == AUTONEG_ENABLE) &&
 	    (advertising & ADVERTISED_1000baseT_Full)) {
 		mod_timer(&tp->timer, jiffies + RTL8169_PHY_TIMEOUT);
@@ -3778,6 +3791,16 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		netif_info(tp, link, dev, "TBI auto-negotiating\n");
 }
 
+static void rtl_resume_phy(struct net_device *dev, struct rtl8169_private *tp)
+{
+	struct rtl_link_setting *ls = &tp->link_sets;
+
+	rtl8169_init_phy(dev, tp);
+
+	if (ls->speed)
+		tp->set_speed(dev, ls->autoneg, ls->speed, ls->duplex, ls->adv);
+}
+
 static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
@@ -6661,7 +6684,7 @@ static int rtl8169_resume(struct device *device)
 	struct net_device *dev = pci_get_drvdata(pdev);
 	struct rtl8169_private *tp = netdev_priv(dev);
 
-	rtl8169_init_phy(dev, tp);
+	rtl_resume_phy(dev, tp);
 
 	if (netif_running(dev))
 		__rtl8169_resume(dev);
@@ -6702,7 +6725,7 @@ static int rtl8169_runtime_resume(struct device *device)
 	tp->saved_wolopts = 0;
 	rtl_unlock_work(tp);
 
-	rtl8169_init_phy(dev, tp);
+	rtl_resume_phy(dev, tp);
 
 	__rtl8169_resume(dev);
 
-- 
1.8.3.1
