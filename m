From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] usbnet.c: check for the right MII variable
Date: Fri, 2 Nov 2007 16:46:15 +0100
Message-ID: <20071102154615.GS30287@stusta.de>
References: <200711012024.57412.toralf.foerster@gmx.de> <20071101222524.GB7227@stusta.de> <200711011652.39601.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1761014AbXKBPsO@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200711011652.39601.david-b@pacbell.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 01, 2007 at 04:52:39PM -0700, David Brownell wrote:
> On Thursday 01 November 2007, Adrian Bunk wrote:
> > All this USB_USBNET_MII trickery is simply not worth it considering=
 how=20
> > few code it saves.
>=20
> Depends on what systems you're talking about.  Forcing unused
> code into the kernel is not free, especially if that's made into
> a design policy and applied repeatedly to many subsystems.

If it was turned into a design policy...

My impression is that in some parts of the kernel every byte gets=20
counted, while in other parts noone would notice a few kilobytes more o=
r=20
less.

> > As a side effect, this also fixes the following compile error repor=
ted=20
> > by Toralf F=C3=B6rster:
>=20
> Why not just fix the thing which changed and broke the build?

Today it's exactly one year since your commit entered the tree.

Dear bug, happy birthday!  ;-)

> Or if reverse dependencies can't be made to work sanely, then
> have those Ethernet-adapter minidrivers depend on NET_ETHERNET
> and then select MII.  (To make the relationships be simple
> enough that current Kconfig can handle them.)

It's not Kconfig's fault that you test for the wrong variable in=20
usbnet.c ...

> I have a fair number of usbnet devices.  Not one of them needs
> MII or NET_ETHERNET.

I don't understand why you think this bug was in any way related to=20
NET_ETHERNET - set NET_ETHERNET=3Dy and the bug is still present.

If you insist on the #ifdef's take the patch below - it even saves a fe=
w=20
additional bytes if you have non-usbnet net drivers requiring MII=20
enabled statically or as modules in your .config but no usbnet drivers=20
requiring MII.

> - Dave

cu
Adrian


<--  snip  -->


This patch fixes the following compile error with CONFIG_MII=3Dm,=20
CONFIG_USB_USBNET=3Dy, CONFIG_USB_USBNET_MII=3Dn:

<--  snip  -->

=2E..
  LD      .tmp_vmlinux1
drivers/built-in.o: In function `usbnet_set_settings':
(.text+0xf1876): undefined reference to `mii_ethtool_sset'
drivers/built-in.o: In function `usbnet_get_settings':
(.text+0xf1836): undefined reference to `mii_ethtool_gset'
drivers/built-in.o: In function `usbnet_get_link':
(.text+0xf18d6): undefined reference to `mii_link_ok'
drivers/built-in.o: In function `usbnet_nway_reset':
(.text+0xf18f6): undefined reference to `mii_nway_restart'
make: *** [.tmp_vmlinux1] Error 1

<--  snip  -->

This bug was introduced by commit 18ee91fa9815fa3bb4e51cdcb8229bd0a0f11=
a70
and reported by Toralf F=C3=B6rster.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

BTW:
The Kconfig part of this patch is not really required, but testing for
  #if defined(CONFIG_USB_USBNET_MII) || defined(CONFIG_USB_USBNET_MII_M=
ODULE)
would look needlessly ugly.

 drivers/net/usb/Kconfig  |    5 ++---
 drivers/net/usb/usbnet.c |    7 +++----
 2 files changed, 5 insertions(+), 7 deletions(-)

a421e4910eb30b140a315e274632e87c7a218df6=20
diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
index 5a96d74..9261371 100644
--- a/drivers/net/usb/Kconfig
+++ b/drivers/net/usb/Kconfig
@@ -94,12 +94,11 @@ config USB_RTL8150
 	  module will be called rtl8150.
=20
 config USB_USBNET_MII
-	tristate
-	default n
+	bool
=20
 config USB_USBNET
 	tristate "Multi-purpose USB Networking Framework"
-	select MII if USB_USBNET_MII !=3D n
+	select MII if USB_USBNET_MII
 	---help---
 	  This driver supports several kinds of network links over USB,
 	  with "minidrivers" built around a common network driver core
diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
index acd5f1c..7393ab0 100644
--- a/drivers/net/usb/usbnet.c
+++ b/drivers/net/usb/usbnet.c
@@ -683,8 +683,7 @@ done_nopm:
  * they'll probably want to use this base set.
  */
=20
-#if defined(CONFIG_MII) || defined(CONFIG_MII_MODULE)
-#define HAVE_MII
+#ifdef CONFIG_USB_USBNET_MII
=20
 int usbnet_get_settings (struct net_device *net, struct ethtool_cmd *c=
md)
 {
@@ -744,7 +743,7 @@ int usbnet_nway_reset(struct net_device *net)
 }
 EXPORT_SYMBOL_GPL(usbnet_nway_reset);
=20
-#endif	/* HAVE_MII */
+#endif	/*  CONFIG_USB_USBNET_MII  */
=20
 void usbnet_get_drvinfo (struct net_device *net, struct ethtool_drvinf=
o *info)
 {
@@ -776,7 +775,7 @@ EXPORT_SYMBOL_GPL(usbnet_set_msglevel);
=20
 /* drivers may override default ethtool_ops in their bind() routine */
 static struct ethtool_ops usbnet_ethtool_ops =3D {
-#ifdef	HAVE_MII
+#ifdef CONFIG_USB_USBNET_MII
 	.get_settings		=3D usbnet_get_settings,
 	.set_settings		=3D usbnet_set_settings,
 	.get_link		=3D usbnet_get_link,
