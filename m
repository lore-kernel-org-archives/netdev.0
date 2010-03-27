From: =?iso-8859-1?Q?Fran=E7ois?= Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 mac reading/writing broken
Date: Sat, 27 Mar 2010 12:40:59 +0100
Message-ID: <20100327114059.GA3432@electric-eye.fr.zoreil.com>
References: <4BADDDB7.4010005@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ivan Vecera <ivecera@redhat.com>, netdev@vger.kernel.org
To: Timo =?iso-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 55.58.140-88.rev.gaoland.net ([88.140.58.55]:47713 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752709Ab0C0Lld (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 07:41:33 -0400
Content-Disposition: inline
In-Reply-To: <4BADDDB7.4010005@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo Ter=E4s <timo.teras@iki.fi> :
[...]
> I did some more testing, and added debugging info to rtl_rar_set(). I=
t would
> appear that even if I write any mac address (with ifconfig) and rerea=
d the
> MAC0..MAC5 register, the first four bytes get zeroed. So it would sou=
nds like
> the hardware is faulty, or that the rtl_rar_set function is buggy.
>=20
> Any suggestions to fix this ?

Try something like the patch below and please send a complete lspci -vv=
v.

I wonder what the bus controler looks like.

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 9d3ebf3..5db357a 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2814,6 +2814,7 @@ static void rtl_rar_set(struct rtl8169_private *t=
p, u8 *addr)
 	void __iomem *ioaddr =3D tp->mmio_addr;
 	u32 high;
 	u32 low;
+	int i;
=20
 	low  =3D addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24)=
;
 	high =3D addr[4] | (addr[5] << 8);
@@ -2822,7 +2823,17 @@ static void rtl_rar_set(struct rtl8169_private *=
tp, u8 *addr)
=20
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W32(MAC0, low);
-	RTL_W32(MAC4, high);
+	for (i =3D 0; i < 16; i++) {
+		u32 read;
+
+		RTL_W32(MAC4, high);
+		read =3D RTL_R32(MAC4);
+		if (read !=3D high) {
+			printk(KERN_ERR PFX
+			       "failure %02d: read =3D 0x%08x, write =3D 0x%08x\n",
+				i, read, high);
+		}
+	}
 	RTL_W8(Cfg9346, Cfg9346_Lock);
=20
 	spin_unlock_irq(&tp->lock);
