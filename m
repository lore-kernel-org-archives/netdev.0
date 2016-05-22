From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: Crashes in -next due to 'phy: add support for a reset-gpio
 specification'
Date: Sun, 22 May 2016 12:10:51 +0200
Message-ID: <20160522101051.GA23704@pengutronix.de>
References: <573BF177.6090507@roeck-us.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-next@vger.kernel.org" <linux-next@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Guenter Roeck <linux@roeck-us.net>
Return-path: <linux-next-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <573BF177.6090507@roeck-us.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Tue, May 17, 2016 at 09:37:11PM -0700, Guenter Roeck wrote:
> [    9.366256] libphy: ethoc-mdio: probed
> [    9.367389]  (null): could not attach to PHY
> [    9.368555]  (null): failed to probe MDIO bus
> [    9.371540] Unable to handle kernel paging request at virtual addr=
ess 0000001c
> [    9.371540]  pc =3D d0320926, ra =3D 903209d1
> [    9.375358] Oops: sig: 11 [#1]
> [    9.376081] PREEMPT
> [    9.377080] CPU: 0 PID: 1 Comm: swapper Not tainted 4.6.0-next-201=
60517 #1
> [    9.378397] task: d7c2c000 ti: d7c30000 task.ti: d7c30000
> [    9.379394] a00: 903209d1 d7c31bd0 d7fb5810 00000001 00000000 0000=
0000 d7f45c00 d7c31bd0
> [    9.382298] a08: 00000000 00000000 00000000 00000000 00060100 d04b=
0c10 d7f45dfc d7c31bb0
> [    9.385732] pc: d0320926, ps: 00060110, depc: 00000018, excvaddr: =
0000001c
> [    9.387061] lbeg: d0322e35, lend: d0322e57 lcount: 00000000, sar: =
00000011
> [    9.388173]
> Stack: d7c31be0 00060700 d7f45c00 d7c31bd0 9021d509 d7c31c30 d7f45c00=
 00000000
>        d0485dcc d0485dcc d7fb5810 d7c2c000 00000000 d7c31c30 d7f45c00=
 d025befc
>        d0485dcc d7c30000 d7f45c34 d7c31bf0 9021c985 d7c31c50 d7f45c00=
 d7f45c34
> [    9.396652] Call Trace:
> [    9.397469]  [<d021d4d9>] __device_release_driver+0x7d/0x98
> [    9.398869]  [<d021d509>] device_release_driver+0x15/0x20
> [    9.400247]  [<d021c985>] bus_remove_device+0xc1/0xd4
> [    9.401569]  [<d021a935>] device_del+0x109/0x15c
> [    9.402794]  [<d025c3f9>] phy_mdio_device_remove+0xd/0x18
> [    9.404124]  [<d025d264>] mdiobus_unregister+0x40/0x5c
> [    9.405444]  [<d025ff44>] ethoc_probe+0x534/0x5b8
> [    9.406742]  [<d021e2e0>] platform_drv_probe+0x28/0x48
> [    9.408122]  [<d021d1e5>] driver_probe_device+0x101/0x234
> [    9.409499]  [<d021d395>] __driver_attach+0x7d/0x98
> [    9.410809]  [<d021bd80>] bus_for_each_dev+0x30/0x5c
> [    9.412104]  [<d021cdf0>] driver_attach+0x14/0x18
> [    9.413385]  [<d021ca61>] bus_add_driver+0xc9/0x198
> [    9.414686]  [<d021d7d4>] driver_register+0x70/0xa0
> [    9.416001]  [<d021e2b4>] __platform_driver_register+0x24/0x28
> [    9.417463]  [<d04a1d34>] ethoc_driver_init+0x10/0x14
> [    9.418824]  [<d00032c8>] do_one_initcall+0x80/0x1ac
> [    9.420083]  [<d049386d>] kernel_init_freeable+0x131/0x198
> [    9.421504]  [<d03236e8>] kernel_init+0xc/0xb0
> [    9.422693]  [<d000482c>] ret_from_kernel_thread+0x8/0xc

Guenter, can you please test if the following patch fixes your setup:

diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.=
c
index 307f72a0f2e2..efa85fb31574 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -1573,14 +1573,14 @@ static int phy_probe(struct device *dev)
 	int err =3D 0;
 	struct gpio_descs *reset_gpios;
=20
-	phydev->drv =3D phydrv;
-
 	/* take phy out of reset */
 	reset_gpios =3D devm_gpiod_get_array_optional(dev, "reset",
 						    GPIOD_OUT_LOW);
 	if (IS_ERR(reset_gpios))
 		return PTR_ERR(reset_gpios);
=20
+	phydev->drv =3D phydrv;
+
 	/* Disable the interrupt if the PHY doesn't support it
 	 * but the interrupt is still a valid one
 	 */

This doesn't make your ethernet work, but at least the driver should
fail in a clean way.

Together with enabling GPIOLIB this should put ethernet in a working
state again.

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |
