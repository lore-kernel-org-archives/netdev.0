From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [3.8-rc] regression: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Sat, 5 Jan 2013 17:57:35 +0100
Message-ID: <20130105165735.GB4906@electric-eye.fr.zoreil.com>
References: <CADDKRnBqxSwC7HUP_aN1QELrv2+7jnncXj7EP0Pqv8E8FFTpPw@mail.gmail.com> <20130105093718.GA938@electric-eye.fr.zoreil.com> <CADDKRnBCrDz2X=5qpGE+r92ZFX5cA+jnSGt3wS8TR0RE8hi1HA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?utf-8?B?SsO2cmc=?= Otte <jrg.otte@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CADDKRnBCrDz2X=5qpGE+r92ZFX5cA+jnSGt3wS8TR0RE8hi1HA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

J=C3=B6rg Otte <jrg.otte@gmail.com> :
[...]
> jojo@ahorn:~$ dmesg | grep XID
> [    1.808847] r8169 0000:02:00.0 eth0: RTL8168evl/8111evl at
> 0xffffc90000054000, 5c:9a:d8:69:2b:39, XID 0c900800 IRQ 42

Can you check if things improve with v3.8-rc2 after removing :

1. 9ecb9aabaf634677c77af467f4e3028b09d7bcda=20
   r8169: workaround for missing extended GigaMAC registers
2. d64ec841517a25f6d468bde9f67e5b4cffdc67c7
   r8169: enable internal ASPM and clock request settings
3. e0c075577965d1c01b30038d38bf637b027a1df3
   r8169: enable ALDPS for power saving

(you can directly try v3.7 r8169.c with v3.8-rc2 if it worked for you
so far)=20

If the regression is still there, please apply the patch below to both
v3.8-rc2 unpatched and a known working version then send me their dmesg
after you 'ip link set dev eth0 up'.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index ed96f30..3d2d2446 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -90,10 +90,28 @@ static const int multicast_filter_limit =3D 32;
 #define RTL8169_TX_TIMEOUT	(6*HZ)
 #define RTL8169_PHY_TIMEOUT	(10*HZ)
=20
+static void rw8(void __iomem *ioaddr, u8 b)
+{
+	printk(KERN_DEBUG PFX "w %p %02x\n", ioaddr, b);
+	writeb(b, ioaddr);
+}
+
+static void rw16(void __iomem *ioaddr, u16 w)
+{
+	printk(KERN_DEBUG PFX "w %p %04x\n", ioaddr, w);
+	writew(w, ioaddr);
+}
+
+static void rw32(void __iomem *ioaddr, u32 d)
+{
+	printk(KERN_DEBUG PFX "w %p %08x\n", ioaddr, d);
+	writel(d, ioaddr);
+}
+
 /* write/read MMIO register */
-#define RTL_W8(reg, val8)	writeb ((val8), ioaddr + (reg))
-#define RTL_W16(reg, val16)	writew ((val16), ioaddr + (reg))
-#define RTL_W32(reg, val32)	writel ((val32), ioaddr + (reg))
+#define RTL_W8(reg, val8)	rw8(ioaddr + (reg), (val8))
+#define RTL_W16(reg, val16)	rw16(ioaddr + (reg), (val16))
+#define RTL_W32(reg, val32)	rw32(ioaddr + (reg), (val32))
 #define RTL_R8(reg)		readb (ioaddr + (reg))
 #define RTL_R16(reg)		readw (ioaddr + (reg))
 #define RTL_R32(reg)		readl (ioaddr + (reg))
