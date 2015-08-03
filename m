From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCHv6 RFT] net: fec: Ensure clocks are enabled while using
 mdio bus
Date: Mon, 3 Aug 2015 17:02:58 +0200
Message-ID: <20150803150258.GD9999@pengutronix.de>
References: <1437856682-2338-1-git-send-email-andrew@lunn.ch>
 <20150803131340.GA9999@pengutronix.de>
 <20150803135023.GC3467@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: fabio.estevam@freescale.com, netdev <netdev@vger.kernel.org>,
	tyler.baker@linaro.org, kernel@pengutronix.de,
	shawn.guo@linaro.org, Lucas Stach <l.stach@pengutronix.de>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:47037 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754033AbbHCPDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 11:03:03 -0400
Content-Disposition: inline
In-Reply-To: <20150803135023.GC3467@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Mon, Aug 03, 2015 at 03:50:23PM +0200, Andrew Lunn wrote:
> > The problem is that on i.MX27 there are two clocks involved that bo=
th
> > must be on to send a packet, while on i.MX6 it's only a single one
> > (abstracted by having ipg-clock =3D ahb-clock). With the suggested =
patch
> > only a single one is asserted to be on. This is enough for i.MX6 bu=
t
> > it's not for i.MX27 (and from looking at the device trees also i.MX=
25,
> > i.MX28, and i.MX35 are affected).
>=20
> I don't think it is as simple as this. If you are sending a packet,
> fec_enet_open() must of been called. This does a pm_runtime_get_sync(=
)
> to ensure the ipg-clock is ticking, and fec_enet_clk_enable() to
> enable all other clocks.
>=20
> Can you debug this further to find out which clock is off, and where
> it gets turned off?
I added a call to pm_runtime_get_sync to fec_enet_start_xmit and put it
back at its end. This way I was able to boot with NFS-root which
resulted in an oops before. But this is wrong because if I set
=46EC_MDIO_PM_TIMEOUT to 0 I get an oops anyhow.

I added the following patch:

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/et=
hernet/freescale/fec_main.c
index 32e3807c650e..508c4af4fde8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -64,6 +64,30 @@
=20
 #include "fec.h"
=20
+#define fec_pm_runtime_get_sync(_dev)	({				\
+	dev_info((_dev), "%s: get_sync (%d)", __func__, (_dev)->power.usage_c=
ount.counter); \
+	pm_runtime_get_sync((_dev));					\
+})
+#define pm_runtime_get_sync(_dev) fec_pm_runtime_get_sync(_dev)
+
+#define fec_pm_runtime_put_autosuspend(_dev)	({			\
+	dev_info((_dev), "%s: put_autosuspend (%d)", __func__, (_dev)->power.=
usage_count.counter); \
+	pm_runtime_put_autosuspend((_dev));				\
+})
+#define pm_runtime_put_autosuspend(_dev) fec_pm_runtime_put_autosuspen=
d(_dev)
+
+#define fec_clk_prepare_enable(_clk)	({				\
+	pr_info("%s: enable " #_clk "\n", __func__);			\
+	clk_prepare_enable((_clk));					\
+})
+#define clk_prepare_enable(_clk) fec_clk_prepare_enable(_clk)
+
+#define fec_clk_disable_unprepare(_clk)	({				\
+	pr_info("%s: disable " #_clk "\n", __func__);			\
+	clk_disable_unprepare((_clk));					\
+})
+#define clk_disable_unprepare(_clk) fec_clk_disable_unprepare(_clk)
+
 static void set_multicast_list(struct net_device *ndev);
 static void fec_enet_itr_coal_init(struct net_device *ndev);
=20
@@ -784,6 +808,7 @@ fec_enet_start_xmit(struct sk_buff *skb, struct net=
_device *ndev)
 	struct netdev_queue *nq;
 	int ret;
=20
+	pr_info("%s\n", __func__);
 	queue =3D skb_get_queue_mapping(skb);
 	txq =3D fep->tx_queue[queue];
 	nq =3D netdev_get_tx_queue(ndev, queue);
@@ -2864,6 +2889,7 @@ fec_enet_open(struct net_device *ndev)
 	struct fec_enet_private *fep =3D netdev_priv(ndev);
 	int ret;
=20
+	pr_info("%s\n", __func__);
 	ret =3D pm_runtime_get_sync(&fep->pdev->dev);
 	if (IS_ERR_VALUE(ret))
 		return ret;
@@ -2932,6 +2958,8 @@ fec_enet_close(struct net_device *ndev)
=20
 	fec_enet_free_buffers(ndev);
=20
+	pr_info("%s\n", __func__);
+
 	return 0;
 }
=20
@@ -3416,6 +3444,7 @@ fec_probe(struct platform_device *pdev)
 		goto failed_clk;
=20
 	ret =3D clk_prepare_enable(fep->clk_ipg);
+	clk_prepare_enable(fep->clk_ipg);
 	if (ret)
 		goto failed_clk_ipg;
=20
=20
Which produced the following output (piped through nl for better
reference):
=20
     1	fec_enet_open
     2	fec 1002b000.ethernet: fec_enet_open: get_sync (-1)
     3	fec_runtime_resume: enable fep->clk_ipg
     4	fec_enet_clk_enable: enable fep->clk_ahb
     5	fec 1002b000.ethernet: fec_enet_mdio_write: get_sync (0)
     6	fec 1002b000.ethernet: fec_enet_mdio_write: put_autosuspend (1)
     7	mmc0: new SD card at address 0007
     8	mmcblk0: mmc0:0007 SD01G 972 MiB (ro)
     9	 mmcblk0: p1
    10	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    11	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    12	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    13	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    14	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    15	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    16	fec 1002b000.ethernet: fec_enet_mdio_write: get_sync (0)
    17	fec 1002b000.ethernet: fec_enet_mdio_write: put_autosuspend (1)
    18	fec 1002b000.ethernet eth0: Freescale FEC PHY driver [Generic PH=
Y] (mii_bus:phy_addr=3D1002b000.etherne:00, irq=3D-1)
    19	fec_runtime_suspend: disable fep->clk_ipg
    20	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    21	fec_runtime_resume: enable fep->clk_ipg
    22	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    23	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    24	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    25	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    26	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    27	fec_runtime_suspend: disable fep->clk_ipg
    28	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    29	fec_runtime_resume: enable fep->clk_ipg
    30	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    31	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    32	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    33	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    34	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    35	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    36	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    37	fec_runtime_suspend: disable fep->clk_ipg
    38	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    39	fec_runtime_resume: enable fep->clk_ipg
    40	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    41	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    42	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    43	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    44	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    45	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    46	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    47	fec 1002b000.ethernet: fec_enet_mdio_read: get_sync (0)
    48	fec 1002b000.ethernet: fec_enet_mdio_read: put_autosuspend (1)
    49	fec 1002b000.ethernet eth0: Link is Up - 100Mbps/Full - flow con=
trol off
    50	Sending DHCP requests .
    51	fec_enet_start_xmit
    52	,
    53	fec_enet_start_xmit
    54	 OK
    55	IP-Config: Got DHCP answer from 192.168.23.4, my address is 192.=
168.24.64
    56	IP-Config: Complete:
    57	     device=3Deth0, hwaddr=3D4a:5c:f5:cb:22:15, ipaddr=3D192.168=
=2E24.64, mask=3D255.255.0.0, gw=3D192.168.23.254
    58	     host=3D192.168.24.64, domain=3Dlab.pengutronix.de, nis-doma=
in=3D(none)
    59	fec_runtime_suspend: disable fep->clk_ipg
    60	     bootserver=3D192.168.23.4, rootserver=3D192.168.23.4, rootp=
ath=3D
    61	     nameserver0=3D192.168.23.254
    62	fec_enet_start_xmit

You see, fec_runtime_suspend is called even though _open was called. (A=
nd even
though get_sync was called once more than put_autosuspend).
Without the additional clk_prepare_enable in probe line 62 is where the
machine barfs.

I don't understand it starring at the code for a while. But the -1 in
line 2 looks fishy.

> > As I think it would be bold to fix this commit once more for 4.2, I
> > suggest to revert 8fff755e9f8d0f70a595e79f248695ce6aef5cc3.
> > (To be honest I wonder why v5 of this commit was even taken for -rc=
3.)
> >=20
> > The straight forward fix for the MDIO issue that was intended to be
> > addressed by 8fff755e9f8d is to add clk_prepare_enable and matching
> > _unprepare_disable calls to the mdio callbacks, right?
>=20
> You mean v1 of the patch?
>=20
> https://patchwork.ozlabs.org/patch/483668/
>=20
> Or at least something similar. That idea got NACK because it is
> thought to consume too much power.
I didn't follow the discussion. But yes, that's what I'd do. I'm with
=46lorian here.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
