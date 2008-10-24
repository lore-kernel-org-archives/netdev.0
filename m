From: Marc Dietrich <Marc.Dietrich@ap.physik.uni-giessen.de>
Subject: Re: PROBLEM: too much RX drop packets on kernel 2.6.26 and 2.6.27.x
Date: Fri, 24 Oct 2008 11:12:00 +0200
Message-ID: <200810241112.01255.marc.dietrich@ap.physik.uni-giessen.de>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_hFZAJmbhAqeA5Ap"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Terleev Roman <lost@nx.uz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merkurneu.hrz.uni-giessen.de ([134.176.2.3]:51965 "EHLO
	merkurneu.hrz.uni-giessen.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbYJXJ1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Oct 2008 05:27:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_hFZAJmbhAqeA5Ap
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline


Hi Terleev,

On Friday 24 October 2008 10:00:07 Terleev Roman wrote:
> hello, linux-kernel.
>
> [1.] One line summary of the problem:
> too much RX drop packets
>
> [2.] Full description of the problem/report:
> "Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI Express Gigabit
> Ethernet controller" - network is up and working, but too much more drop
> packets:
>
> working int:
> #ifconfig eth0
> eth0      Link encap:Ethernet  HWaddr 00:1F:D0:5C:1A:5A
>           UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
>           RX packets:7323 errors:0 dropped:7564458177891 overruns:0 frame:0
>           TX packets:8388 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:1000
>           RX bytes:688493 (672.3 KiB)  TX bytes:5088993 (4.8 MiB)
>           Interrupt:251 Base address:0x4000

does the attached patch (from git-net) fix it?

To NetDev: Is this already in a stable-branch?

Marc



--Boundary-00=_hFZAJmbhAqeA5Ap
Content-Type: text/x-patch;
  charset="utf-8";
  name="0001-r8169-fix-RxMissed-register-access.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="0001-r8169-fix-RxMissed-register-access.patch"

=46rom 422f23adb15141fffbba4c2579b26c59fabc3537 Mon Sep 17 00:00:00 2001
=46rom: Francois Romieu <romieu@fr.zoreil.com>
Date: Thu, 21 Aug 2008 23:20:40 +0200
Subject: [PATCH] r8169: fix RxMissed register access

=2D the register location is defined for the 8169 chipset only
=2D only the lower 3 bytes of the register are valid

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
=2D--
 drivers/net/r8169.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 0f6f974..4190ee7 100644
=2D-- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2099,8 +2099,6 @@ static void rtl_hw_start_8168(struct net_device *dev)
=20
 	RTL_R8(IntrMask);
=20
=2D	RTL_W32(RxMissed, 0);
=2D
 	rtl_set_rx_mode(dev);
=20
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2143,8 +2141,6 @@ static void rtl_hw_start_8101(struct net_device *dev)
=20
 	RTL_R8(IntrMask);
=20
=2D	RTL_W32(RxMissed, 0);
=2D
 	rtl_set_rx_mode(dev);
=20
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
@@ -2922,6 +2918,17 @@ static int rtl8169_poll(struct napi_struct *napi, in=
t budget)
 	return work_done;
 }
=20
+static void rtl8169_rx_missed(struct net_device *dev, void __iomem *ioaddr)
+{
+	struct rtl8169_private *tp =3D netdev_priv(dev);
+
+	if (tp->mac_version > RTL_GIGA_MAC_VER_06)
+		return;
+
+	dev->stats.rx_missed_errors +=3D (RTL_R32(RxMissed) & 0xffffff);
+	RTL_W32(RxMissed, 0);
+}
+
 static void rtl8169_down(struct net_device *dev)
 {
 	struct rtl8169_private *tp =3D netdev_priv(dev);
@@ -2939,9 +2946,7 @@ core_down:
=20
 	rtl8169_asic_down(ioaddr);
=20
=2D	/* Update the error counts. */
=2D	dev->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
=2D	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
=20
 	spin_unlock_irq(&tp->lock);
=20
@@ -3063,8 +3068,7 @@ static struct net_device_stats *rtl8169_get_stats(str=
uct net_device *dev)
=20
 	if (netif_running(dev)) {
 		spin_lock_irqsave(&tp->lock, flags);
=2D		dev->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
=2D		RTL_W32(RxMissed, 0);
+		rtl8169_rx_missed(dev, ioaddr);
 		spin_unlock_irqrestore(&tp->lock, flags);
 	}
=20
@@ -3089,8 +3093,7 @@ static int rtl8169_suspend(struct pci_dev *pdev, pm_m=
essage_t state)
=20
 	rtl8169_asic_down(ioaddr);
=20
=2D	dev->stats.rx_missed_errors +=3D RTL_R32(RxMissed);
=2D	RTL_W32(RxMissed, 0);
+	rtl8169_rx_missed(dev, ioaddr);
=20
 	spin_unlock_irq(&tp->lock);
=20

--Boundary-00=_hFZAJmbhAqeA5Ap--
