From: Lothar =?UTF-8?B?V2HDn21hbm4=?= <LW@KARO-electronics.de>
Subject: Re: Problem with "swinging" ethernet link on i.MX28 based device
Date: Fri, 27 Nov 2015 12:09:19 +0100
Message-ID: <20151127120919.66f2bfda@ipc1.ka-ro>
References: <565822B2.30007@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NETDEV <netdev@vger.kernel.org>, fabio.estevam@freescale.com,
	marek.vasut@gmail.com
To: Michael Heimpold <michael.heimpold@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.karo-electronics.de ([81.173.242.67]:59037 "EHLO
	mail.karo-electronics.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754566AbbK0L1W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Nov 2015 06:27:22 -0500
In-Reply-To: <565822B2.30007@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

> we at I2SE have developed an i.MX28 based embedded device, called Duc=
kbill.
> Regarding ethernet, it is very similar to the FSL mx28evk, i.e. we us=
e the same
> phy (SMSC LAN8720), we use RMII mode, clock is provided by iMX (not v=
ia
> external crystal), we have a GPIO to reset the phy and an interrupt G=
PIO.
>=20
> At the moment, we are using vanilla kernel 4.2.5 with only a fetch pa=
tches - mainly
> patches to add the device tree stuff needed and some cherry-picked up=
stream
> patches. Nothing special IMO. You can find it here:
> https://github.com/I2SE/linux/tree/v4.2.5-duckbill
>=20
> After booting the device, we observe on a few devices the ethernet "s=
winging"
> or toggling:
> [   15.830759] fec 800f0000.ethernet eth0: Freescale FEC PHY driver [=
SMSC LAN8710/LAN8720] (mii_bus:phy_addr=3D800f0000.etherne:00, irq=3D35=
)
> [   15.843361] IPv6: ADDRCONF(NETDEV_UP): eth0: link is not ready
> [   17.112867] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full =
- flow control rx/tx
> [   17.121746] IPv6: ADDRCONF(NETDEV_CHANGE): eth0: link becomes read=
y
> [   17.894416] fec 800f0000.ethernet eth0: Link is Down
> [   19.506960] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full =
- flow control rx/tx
> [   20.294398] fec 800f0000.ethernet eth0: Link is Down
> [   21.932365] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full =
- flow control rx/tx
> [   22.714410] fec 800f0000.ethernet eth0: Link is Down
> [   24.357890] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full =
- flow control rx/tx
> [   25.144400] fec 800f0000.ethernet eth0: Link is Down
> [   26.783367] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full =
- flow control rx/tx
> [   27.564357] fec 800f0000.ethernet eth0: Link is Down
> [   29.208846] fec 800f0000.ethernet eth0: Link is Up - 100Mbps/Full =
- flow control rx/tx
>=20
> However, in U-Boot I can transfer several hundreds of MB without any =
problem,
> I can attach the cable/reattach etc. as usual - no obvious problems.
> This is the reason, we think that the hardware is ok (and of course, =
we double-checked
> especially the soldering of the affected devices).
>=20
> This is what I tried so far:
> - changed the device tree to not use the interrupt line -> phy is pol=
led periodically
> - reverted latest phy changes for LAN8720, i.e.
>    d88ecb373bd1877acc43e13311a8e0e6daffc3d2 - "net: phy: smsc: disabl=
e energy detect mode"
>    ff94c742dfeea3110f1e1d27399d728f8494d29e - "net: phy: fix semicolo=
n.cocci warnings"
>    776829de90c5972895db398993ddfa9417ff8b01 - "net: phy: workaround f=
or buggy cable detection by LAN8700 after cable plugging"
> - then I tried the following patch
>=20
> -snip-
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -936,7 +936,7 @@ fec_restart(struct net_device *ndev)
>          if (fep->quirks & FEC_QUIRK_HAS_AVB) {
>                  writel(0, fep->hwp + FEC_ECNTRL);
>          } else {
> - writel(1, fep->hwp + FEC_ECNTRL);
> + //writel(1, fep->hwp + FEC_ECNTRL);
>                  udelay(10);
>          }
> -snap-
> The idea behind this patch is: when FEC is resetted, then registers a=
re reset to initial values
> and thus FEC is configured for MII. When using ENET_CLK_OUT this resu=
lts in 25 MHz clock
> to phy instead of 50 MHz as required by RMII. At least for a short ti=
me, there might be
> a "glitch". The concern was, that the phy might become stuck by this.
>=20
> However, nothing of the above improved anything. So, at the moment, I=
'm
> running out of ideas - any help/hint to debug this issue further is r=
eally appreciated.
> Please let me know if I missed some important information.
>=20
I faced the same problem on one of our i.MX6 modules recently but
haven't come around to send a proper patch yet.

The problem is that the enet_out clock is disabled in
fec_enet_clk_enable() which leaves the PHY without a running clock.
Due to this the PHY loses its internal state and requires a reset to be
reactivated.

The following patch should fix this problem:
diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index b2a3220..cfa70b5 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1857,11 +1857,6 @@ static int fec_enet_clk_enable(struct net_device=
 *ndev, bool enable)
 		ret =3D clk_prepare_enable(fep->clk_ahb);
 		if (ret)
 			return ret;
-		if (fep->clk_enet_out) {
-			ret =3D clk_prepare_enable(fep->clk_enet_out);
-			if (ret)
-				goto failed_clk_enet_out;
-		}
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			ret =3D clk_prepare_enable(fep->clk_ptp);
@@ -1873,35 +1868,26 @@ static int fec_enet_clk_enable(struct net_devic=
e *ndev, bool enable)
 			}
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
-		if (fep->clk_ref) {
-			ret =3D clk_prepare_enable(fep->clk_ref);
-			if (ret)
-				goto failed_clk_ref;
-		}
+		ret =3D clk_prepare_enable(fep->clk_ref);
+		if (ret)
+			goto failed_clk_ref;
 	} else {
 		clk_disable_unprepare(fep->clk_ahb);
-		if (fep->clk_enet_out)
-			clk_disable_unprepare(fep->clk_enet_out);
 		if (fep->clk_ptp) {
 			mutex_lock(&fep->ptp_clk_mutex);
 			clk_disable_unprepare(fep->clk_ptp);
 			fep->ptp_clk_on =3D false;
 			mutex_unlock(&fep->ptp_clk_mutex);
 		}
-		if (fep->clk_ref)
-			clk_disable_unprepare(fep->clk_ref);
+		clk_disable_unprepare(fep->clk_ref);
 	}
=20
 	return 0;
=20
 failed_clk_ref:
-	if (fep->clk_ref)
-		clk_disable_unprepare(fep->clk_ref);
+	clk_disable_unprepare(fep->clk_ref);
 failed_clk_ptp:
-	if (fep->clk_enet_out)
-		clk_disable_unprepare(fep->clk_enet_out);
-failed_clk_enet_out:
-		clk_disable_unprepare(fep->clk_ahb);
+	clk_disable_unprepare(fep->clk_ahb);
=20
 	return ret;
 }
@@ -3430,6 +3416,10 @@ fec_probe(struct platform_device *pdev)
 	if (ret)
 		goto failed_clk;
=20
+	ret =3D clk_prepare_enable(fep->clk_enet_out);
+	if (ret)
+		goto failed_clk_enet_out;
+
 	ret =3D clk_prepare_enable(fep->clk_ipg);
 	if (ret)
 		goto failed_clk_ipg;
@@ -3514,6 +3504,8 @@ failed_init:
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 failed_regulator:
+	clk_disable_unprepare(fep->clk_enet_out);
+failed_clk_enet_out:
 	clk_disable_unprepare(fep->clk_ipg);
 failed_clk_ipg:
 	fec_enet_clk_enable(ndev, false);
@@ -3536,6 +3528,8 @@ fec_drv_remove(struct platform_device *pdev)
 	fec_ptp_stop(pdev);
 	unregister_netdev(ndev);
 	fec_enet_mii_remove(fep);
+	fec_enet_clk_enable(ndev, false);
+	clk_disable_unprepare(fep->clk_enet_out);
 	if (fep->reg_phy)
 		regulator_disable(fep->reg_phy);
 	of_node_put(fep->phy_node);



Lothar Wa=C3=9Fmann
