From: Florian Fainelli <florian.fainelli@telecomint.eu>
Subject: [PATCH] Fix kernel unaligned access with r8169 on sparc64
Date: Fri, 6 Jul 2007 15:02:46 +0200
Message-ID: <200707061502.49146.florian.fainelli@telecomint.eu>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart7404455.LEEEbLzf3Q";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:42792 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbXGFNVo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jul 2007 09:21:44 -0400
Received: from [192.168.10.156] (mla78-1-82-240-17-188.fbx.proxad.net [82.240.17.188])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by smtp-ext.int-evry.fr (Postfix) with ESMTP id 3B3D48D1696
	for <netdev@vger.kernel.org>; Fri,  6 Jul 2007 15:02:46 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart7404455.LEEEbLzf3Q
Content-Type: multipart/mixed;
  boundary="Boundary-01=_21jjGrueYQsBjuU"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

--Boundary-01=_21jjGrueYQsBjuU
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

Hi all,

When using the r8169 gigabit ethernet network driver under a Sun Entreprise=
=20
450, you will encounter a lot of kernel unaligned access on ip_rcv and=20
ip_fast_csum. The full report is available here :=20
http://www.mail-archive.com/debian-bugs-dist%40lists.debian.org/msg363433.h=
tm

The following patch against 2.6.22-rc6 will fix this problem.

Signed-off-by: Florian Fainelli <florian.fainelli@telecomint.eu>
=2D-=20

--Boundary-01=_21jjGrueYQsBjuU
Content-Type: text/plain;
  charset="utf-8";
  name="r8169-sparc64-fix-unaligned.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: attachment;
	filename="r8169-sparc64-fix-unaligned.patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 5ec7752..5095dbe 100644
=2D-- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -69,6 +69,7 @@ VERSION 2.2LK	<2005/01/25>
 #include <asm/system.h>
 #include <asm/io.h>
 #include <asm/irq.h>
+#include <asm/unaligned.h>
=20
 #ifdef CONFIG_R8169_NAPI
 #define NAPI_SUFFIX	"-NAPI"
@@ -224,7 +225,9 @@ static struct pci_device_id rtl8169_pci_tbl[] =3D {
=20
 MODULE_DEVICE_TABLE(pci, rtl8169_pci_tbl);
=20
+#if !defined(__sparc__)
 static int rx_copybreak =3D 200;
+#endif
 static int use_dac;
 static struct {
 	u32 msg_enable;
@@ -465,8 +468,10 @@ MODULE_AUTHOR("Realtek and the Linux r8169 crew <netde=
v@vger.kernel.org>");
 MODULE_DESCRIPTION("RealTek RTL-8169 Gigabit Ethernet driver");
 module_param_array(media, int, &num_media, 0);
 MODULE_PARM_DESC(media, "force phy operation. Deprecated by ethtool (8).");
+#if !defined(__sparc__)
 module_param(rx_copybreak, int, 0);
 MODULE_PARM_DESC(rx_copybreak, "Copy breakpoint for copy-only-tiny-frames"=
);
+#endif
 module_param(use_dac, int, 0);
 MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
 module_param_named(debug, debug.msg_enable, int, 0);
@@ -2486,10 +2491,25 @@ static inline int rtl8169_try_rx_copy(struct sk_buf=
f **sk_buff, int pkt_size,
 {
 	int ret =3D -1;
=20
=2D	if (pkt_size < rx_copybreak) {
+#if defined(__sparc__)
+	if (pkt_size) {
 		struct sk_buff *skb;
+		int i;
+
+		skb =3D dev_alloc_skb(pkt_size + 4);
+
+		/* align the data to the ip header - should be faster than copying the e=
ntire packet to the stack */
+		for (i =3D pkt_size - (pkt_size % 4); i >=3D 0; i -=3D 4) {
+			put_unaligned(*((u32 *) (skb->data + i)), (u32 *) (skb->data + i + 2));
+		}
+		skb->data +=3D 2;
+		skb->tail +=3D 2;
+#else
+	if (pkt_size < rx_copybreak) {
+                struct sk_buff *skb;
=20
 		skb =3D dev_alloc_skb(pkt_size + align);
+#endif
 		if (skb) {
 			skb_reserve(skb, (align - 1) & (unsigned long)skb->data);
 			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);

--Boundary-01=_21jjGrueYQsBjuU--

--nextPart7404455.LEEEbLzf3Q
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.4 (GNU/Linux)

iD8DBQBGjj15mx9n1G/316sRAvxxAJ9zGXf1LaEvaOv39S3AomW6lKZyswCeOoTZ
owzLS3xINrvjD4+a8bBS4JE=
=IdQY
-----END PGP SIGNATURE-----

--nextPart7404455.LEEEbLzf3Q--
