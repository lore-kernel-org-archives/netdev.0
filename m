From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [BUG] 2.6.29-rc7 broke r8169 MAC on Thecus n2100 ARM board
Date: Fri, 13 Mar 2009 21:15:11 +0100
Message-ID: <20090313201511.GA27827@electric-eye.fr.zoreil.com>
References: <200903092029.n29KT1DS004531@harpo.it.uu.se>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="ibTvN161/egqYuK8"
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ivecera@redhat.com, tdurack@gmail.com
To: Mikael Pettersson <mikpe@it.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:59812 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751354AbZCMUMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 16:12:14 -0400
Content-Disposition: inline
In-Reply-To: <200903092029.n29KT1DS004531@harpo.it.uu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Mikael Pettersson <mikpe@it.uu.se> :
> With the 2.6.29-rc7 kernel I'm unable to 'ifup' eth0 on my ARM-based
> Thecus n2100 NAS box, which has an RTL8169 NIC (10ec:8169 (rev 10)).
> A diff of the kernel logs from 2.6.29-rc6 and -rc7 shows that -rc7
> first mangles and then zaps the MAC addresses:

Can you apply the attached patch and see if it fixes any of these
problems ?

Tim, could you give it a try too ? It applies with "patch -p1" from
the kernel tree directory.

-- 
Ueimor

--ibTvN161/egqYuK8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-init-mac-20.patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index b347340..5d2ae6b 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -1833,7 +1833,13 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	RTL_W32(MAC4, high);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
 
+	/* PCI commit */
+	RTL_R8(ChipCmd);
+
 	spin_unlock_irq(&tp->lock);
+
+	/* Hack. */
+	msleep_interruptible(1);
 }
 
 static int rtl_set_mac_address(struct net_device *dev, void *p)
@@ -1970,9 +1976,14 @@ static const struct net_device_ops rtl8169_netdev_ops = {
 };
 
 /* Delay between EEPROM clock transitions. Force out buffered PCI writes. */
-#define RTL_EEPROM_DELAY()	RTL_R8(Cfg9346)
 #define RTL_EEPROM_READ_CMD	6
 
+static void rtl_eeprom_delay(void __iomem *ioaddr)
+{
+	RTL_R8(Cfg9346);
+	ndelay(450);
+}
+
 /* read 16bit word stored in EEPROM. EEPROM is addressed by words. */
 static u16 rtl_eeprom_read(void __iomem *ioaddr, int addr)
 {
@@ -1992,7 +2003,7 @@ static u16 rtl_eeprom_read(void __iomem *ioaddr, int addr)
 
 	/* enter programming mode */
 	RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS);
-	RTL_EEPROM_DELAY();
+	rtl_eeprom_delay(ioaddr);
 
 	/* write command and requested address */
 	while (cmd_len--) {
@@ -2002,29 +2013,29 @@ static u16 rtl_eeprom_read(void __iomem *ioaddr, int addr)
 
 		/* write a bit */
 		RTL_W8(Cfg9346, x);
-		RTL_EEPROM_DELAY();
+		rtl_eeprom_delay(ioaddr);
 
 		/* raise clock */
 		RTL_W8(Cfg9346, x | Cfg9346_EESK);
-		RTL_EEPROM_DELAY();
+		rtl_eeprom_delay(ioaddr);
 	}
 
 	/* lower clock */
 	RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS);
-	RTL_EEPROM_DELAY();
+	rtl_eeprom_delay(ioaddr);
 
 	/* read back 16bit value */
 	for (i = 16; i > 0; i--) {
 		/* raise clock */
 		RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS | Cfg9346_EESK);
-		RTL_EEPROM_DELAY();
+		rtl_eeprom_delay(ioaddr);
 
 		result <<= 1;
 		result |= (RTL_R8(Cfg9346) & Cfg9346_EEDO) ? 1 : 0;
 
 		/* lower clock */
 		RTL_W8(Cfg9346, Cfg9346_Program | Cfg9346_EECS);
-		RTL_EEPROM_DELAY();
+		rtl_eeprom_delay(ioaddr);
 	}
 
 	RTL_W8(Cfg9346, Cfg9346_Program);

--ibTvN161/egqYuK8--
