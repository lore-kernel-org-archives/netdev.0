From: Marc Zyngier <marc.zyngier@arm.com>
Subject: [PATCH] NET: smsc95xx: don't use stack for async writes to the device
Date: Fri, 18 Mar 2011 13:53:58 +0000
Message-ID: <1300456438-13286-1-git-send-email-marc.zyngier@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: Steve Glendinning <steve.glendinning@smsc.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from service87.mimecast.com ([94.185.240.25]:38631 "HELO
	service87.mimecast.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756525Ab1CRNxu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 09:53:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The set_multicast operation performs asynchronous writes to the
device, with some addresses pointing to the stack. Bad things may
happen, and this is trapped CONFIG_DMA_API_DEBUG:

[    5.237762] WARNING: at /build/buildd/linux-linaro-omap-2.6.38/lib/dma-d=
ebug.c:867 check_for_stack+0xd4/0x100()
[    5.237792] ehci-omap ehci-omap.0: DMA-API: device driver maps memory fr=
omstack [addr=3Dd9c77dec]
[    5.237792] Modules linked in: smsc95xx(+) usbnet twl6030_usb twl4030_pw=
rbutton leds_gpio omap_wdt omap2_mcspi
[    5.237854] [<c006d618>] (unwind_backtrace+0x0/0xf8) from [<c00a6a14>] (=
warn_slowpath_common+0x54/0x64)
[    5.237884] [<c00a6a14>] (warn_slowpath_common+0x54/0x64) from [<c00a6ab=
8>] (warn_slowpath_fmt+0x30/0x40)
[    5.237915] [<c00a6ab8>] (warn_slowpath_fmt+0x30/0x40) from [<c034e9d8>]=
 (check_for_stack+0xd4/0x100)
[    5.237915] [<c034e9d8>] (check_for_stack+0xd4/0x100) from [<c034fea8>] =
(debug_dma_map_page+0xb4/0xdc)
[    5.237976] [<c034fea8>] (debug_dma_map_page+0xb4/0xdc) from [<c04242f0>=
] (map_urb_for_dma+0x26c/0x304)
[    5.237976] [<c04242f0>] (map_urb_for_dma+0x26c/0x304) from [<c0424594>]=
 (usb_hcd_submit_urb+0x78/0x19c)
[    5.238037] [<c0424594>] (usb_hcd_submit_urb+0x78/0x19c) from [<bf049c5c=
>] (smsc95xx_write_reg_async+0xb4/0x130 [smsc95xx])
[    5.238067] [<bf049c5c>] (smsc95xx_write_reg_async+0xb4/0x130 [smsc95xx]=
) from [<bf049dd4>] (smsc95xx_set_multicast+0xfc/0x148 [smsc95xx])
[    5.238098] [<bf049dd4>] (smsc95xx_set_multicast+0xfc/0x148 [smsc95xx]) =
from [<bf04a118>] (smsc95xx_reset+0x2f8/0x68c [smsc95xx])
[    5.238128] [<bf04a118>] (smsc95xx_reset+0x2f8/0x68c [smsc95xx]) from [<=
bf04a8cc>] (smsc95xx_bind+0xcc/0x188 [smsc95xx])
[    5.238159] [<bf04a8cc>] (smsc95xx_bind+0xcc/0x188 [smsc95xx]) from [<bf=
03ef1c>] (usbnet_probe+0x204/0x4c4 [usbnet])
[    5.238220] [<bf03ef1c>] (usbnet_probe+0x204/0x4c4 [usbnet]) from [<c042=
9078>] (usb_probe_interface+0xe4/0x1c4)
[    5.238250] [<c0429078>] (usb_probe_interface+0xe4/0x1c4) from [<c03a877=
0>] (really_probe+0x64/0x160)
[    5.238250] [<c03a8770>] (really_probe+0x64/0x160) from [<c03a8a30>] (dr=
iver_probe_device+0x48/0x60)
[    5.238281] [<c03a8a30>] (driver_probe_device+0x48/0x60) from [<c03a8ad4=
>] (__driver_attach+0x8c/0x90)
[    5.238311] [<c03a8ad4>] (__driver_attach+0x8c/0x90) from [<c03a7b24>] (=
bus_for_each_dev+0x50/0x7c)
[    5.238311] [<c03a7b24>] (bus_for_each_dev+0x50/0x7c) from [<c03a82ec>] =
(bus_add_driver+0x190/0x250)
[    5.238311] [<c03a82ec>] (bus_add_driver+0x190/0x250) from [<c03a8cf8>] =
(driver_register+0x78/0x13c)
[    5.238433] [<c03a8cf8>] (driver_register+0x78/0x13c) from [<c0428040>] =
(usb_register_driver+0x78/0x13c)
[    5.238464] [<c0428040>] (usb_register_driver+0x78/0x13c) from [<c005b68=
0>] (do_one_initcall+0x34/0x188)
[    5.238494] [<c005b680>] (do_one_initcall+0x34/0x188) from [<c00e11f0>] =
(sys_init_module+0xb0/0x1c0)
[    5.238525] [<c00e11f0>] (sys_init_module+0xb0/0x1c0) from [<c0065c40>] =
(ret_fast_syscall+0x0/0x30)

Move the two offenders to the private structure which is kmalloc-ed,
and thus safe.

Signed-off-by: Marc Zyngier <marc.zyngier@arm.com>
Cc: Steve Glendinning <steve.glendinning@smsc.com>
---
 drivers/net/usb/smsc95xx.c |   17 ++++++++++-------
 1 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
index bc86f4b..727874d 100644
--- a/drivers/net/usb/smsc95xx.c
+++ b/drivers/net/usb/smsc95xx.c
@@ -49,6 +49,8 @@
=20
 struct smsc95xx_priv {
 =09u32 mac_cr;
+=09u32 hash_hi;
+=09u32 hash_lo;
 =09spinlock_t mac_cr_lock;
 =09bool use_tx_csum;
 =09bool use_rx_csum;
@@ -370,10 +372,11 @@ static void smsc95xx_set_multicast(struct net_device =
*netdev)
 {
 =09struct usbnet *dev =3D netdev_priv(netdev);
 =09struct smsc95xx_priv *pdata =3D (struct smsc95xx_priv *)(dev->data[0]);
-=09u32 hash_hi =3D 0;
-=09u32 hash_lo =3D 0;
 =09unsigned long flags;
=20
+=09pdata->hash_hi =3D 0;
+=09pdata->hash_lo =3D 0;
+
 =09spin_lock_irqsave(&pdata->mac_cr_lock, flags);
=20
 =09if (dev->net->flags & IFF_PROMISC) {
@@ -394,13 +397,13 @@ static void smsc95xx_set_multicast(struct net_device =
*netdev)
 =09=09=09u32 bitnum =3D smsc95xx_hash(ha->addr);
 =09=09=09u32 mask =3D 0x01 << (bitnum & 0x1F);
 =09=09=09if (bitnum & 0x20)
-=09=09=09=09hash_hi |=3D mask;
+=09=09=09=09pdata->hash_hi |=3D mask;
 =09=09=09else
-=09=09=09=09hash_lo |=3D mask;
+=09=09=09=09pdata->hash_lo |=3D mask;
 =09=09}
=20
 =09=09netif_dbg(dev, drv, dev->net, "HASHH=3D0x%08X, HASHL=3D0x%08X\n",
-=09=09=09=09   hash_hi, hash_lo);
+=09=09=09=09   pdata->hash_hi, pdata->hash_lo);
 =09} else {
 =09=09netif_dbg(dev, drv, dev->net, "receive own packets only\n");
 =09=09pdata->mac_cr &=3D
@@ -410,8 +413,8 @@ static void smsc95xx_set_multicast(struct net_device *n=
etdev)
 =09spin_unlock_irqrestore(&pdata->mac_cr_lock, flags);
=20
 =09/* Initiate async writes, as we can't wait for completion here */
-=09smsc95xx_write_reg_async(dev, HASHH, &hash_hi);
-=09smsc95xx_write_reg_async(dev, HASHL, &hash_lo);
+=09smsc95xx_write_reg_async(dev, HASHH, &pdata->hash_hi);
+=09smsc95xx_write_reg_async(dev, HASHL, &pdata->hash_lo);
 =09smsc95xx_write_reg_async(dev, MAC_CR, &pdata->mac_cr);
 }
=20
--=20
1.7.0.4


