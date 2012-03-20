From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: WARNING: at net/sched/sch_generic.c:256 dev_watchdog+0x1f2/0x200()
Date: Tue, 20 Mar 2012 10:37:09 +0100
Message-ID: <20120320093709.GA5058@electric-eye.fr.zoreil.com>
References: <20120205134050.7e135bb231b613806a2e0b70@gmail.com> <4F2F0065.9040909@lwfinger.net> <20120205222141.GA26223@electric-eye.fr.zoreil.com> <20120205145913.194746473361e324bda1eb4a@gmail.com> <CAKFRV=NghW3kokuD-VBAzVJf09r-9ePMG+L7qDYfqmuHwWo4mg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Justin Mattock <justinmattock@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAKFRV=NghW3kokuD-VBAzVJf09r-9ePMG+L7qDYfqmuHwWo4mg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Larry removed)

Justin Mattock <justinmattock@gmail.com> :
[...]
> seems I see this with the latest linux-next:

Thanks for testing.

[...]
> [21740.318685] r8169 0000:06:00.0: eth0: link up
> [21752.292679] r8169 0000:06:00.0: eth0: link up
> [21764.268569] r8169 0000:06:00.0: eth0: link up
> [21776.254393] r8169 0000:06:00.0: eth0: link up
> [21788.235797] r8169 0000:06:00.0: eth0: link up
> [21800.196524] r8169 0000:06:00.0: eth0: link up
> [21812.172497] r8169 0000:06:00.0: eth0: link up

This is completely broken. I could understand a few up/down link changes
until things settles but the driver should not claim periodically that
the link is up when there is no cable, at least not with a supported chipset.

Can you apply the debug helper below and report a complete dmesg from
boot with the same test (please remove l-k, netdev is good enough) ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 61e6ab4..880264a 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -61,7 +61,8 @@
 #endif /* RTL8169_DEBUG */
 
 #define R8169_MSG_DEFAULT \
-	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
+	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN | \
+	 NETIF_MSG_LINK)
 
 #define TX_BUFFS_AVAIL(tp) \
 	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
@@ -731,7 +732,7 @@ struct rtl8169_private {
 	void (*phy_reset_enable)(struct rtl8169_private *tp);
 	void (*hw_start)(struct net_device *);
 	unsigned int (*phy_reset_pending)(struct rtl8169_private *tp);
-	unsigned int (*link_ok)(void __iomem *);
+	unsigned int (*link_ok)(struct rtl8169_private *);
 	int (*do_ioctl)(struct rtl8169_private *tp, struct mii_ioctl_data *data, int cmd);
 
 	struct {
@@ -1260,14 +1261,28 @@ static unsigned int rtl8169_xmii_reset_pending(struct rtl8169_private *tp)
 	return rtl_readphy(tp, MII_BMCR) & BMCR_RESET;
 }
 
-static unsigned int rtl8169_tbi_link_ok(void __iomem *ioaddr)
+static unsigned int rtl8169_tbi_link_ok(struct rtl8169_private *tp)
 {
+	void __iomem *ioaddr = tp->mmio_addr;
+
 	return RTL_R32(TBICSR) & TBILinkOk;
 }
 
-static unsigned int rtl8169_xmii_link_ok(void __iomem *ioaddr)
+static unsigned int rtl8169_xmii_link_ok(struct rtl8169_private *tp)
 {
-	return RTL_R8(PHYstatus) & LinkStatus;
+	void __iomem *ioaddr = tp->mmio_addr;
+	struct net_device *dev = tp->dev;
+	u8 status;
+
+	status = RTL_R8(PHYstatus) & LinkStatus;
+	netif_info(tp, link, dev,
+		   "bmcr: %04x bmsr: %04x gbcr: %04x gbsr: %04x\n",
+		   rtl_readphy(tp, MII_BMCR),
+		   rtl_readphy(tp, MII_BMSR),
+		   rtl_readphy(tp, MII_CTRL1000),
+		   rtl_readphy(tp, MII_STAT1000));
+
+	return status;
 }
 
 static void rtl8169_tbi_reset_enable(struct rtl8169_private *tp)
@@ -1335,7 +1350,7 @@ static void __rtl8169_check_link_status(struct net_device *dev,
 					struct rtl8169_private *tp,
 					void __iomem *ioaddr, bool pm)
 {
-	if (tp->link_ok(ioaddr)) {
+	if (tp->link_ok(tp)) {
 		rtl_link_chg_patch(tp);
 		/* This is to cancel a scheduled suspend if there's one. */
 		if (pm)
@@ -3309,7 +3324,6 @@ static void rtl_hw_phy_config(struct net_device *dev)
 static void rtl_phy_work(struct rtl8169_private *tp)
 {
 	struct timer_list *timer = &tp->timer;
-	void __iomem *ioaddr = tp->mmio_addr;
 	unsigned long timeout = RTL8169_PHY_TIMEOUT;
 
 	assert(tp->mac_version > RTL_GIGA_MAC_VER_01);
@@ -3323,7 +3337,7 @@ static void rtl_phy_work(struct rtl8169_private *tp)
 		goto out_mod_timer;
 	}
 
-	if (tp->link_ok(ioaddr))
+	if (tp->link_ok(tp))
 		return;
 
 	netif_warn(tp, link, tp->dev, "PHY reset until link up\n");
-- 
1.7.7.6
