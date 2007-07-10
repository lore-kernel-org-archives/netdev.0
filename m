From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH] Fix kernel unaligned access with r8169 on sparc64
Date: Wed, 11 Jul 2007 00:02:44 +0200
Message-ID: <20070710220244.GC3436@electric-eye.fr.zoreil.com>
References: <200707061502.49146.florian.fainelli@telecomint.eu> <4692E347.3060200@snapgear.com> <20070710205910.GA3436@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J2SCkAp4GZ/dPZZf"
Cc: Philip Craig <philipc@snapgear.com>, netdev@vger.kernel.org,
	Jonathan Larsen <agentc0re@gmail.com>
To: Florian Fainelli <florian.fainelli@telecomint.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:54926 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762992AbXGJWE7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Jul 2007 18:04:59 -0400
Content-Disposition: inline
In-Reply-To: <20070710205910.GA3436@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Francois Romieu <romieu@fr.zoreil.com> :
[...]
> - try http://www.fr.zoreil.com/people/francois/backport/r8169/20070604-00
>   It is a backport against 2.6.18 which should bring you quite close to
>   2.6.23-git wrt r8169. 

Regarding the backport option, it was initially more a compiled-ok-untested-
use-at-your-own-risk thing than anything else. I have given it a try with
2.6.18 and it does not blow up immediately. I suggest adding the attached
patch at the end of the serie to fix a locking bug though.

-- 
Ueimor

--J2SCkAp4GZ/dPZZf
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="r8169-set-mac-addr-locking.patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index eaf5373..982a901 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -135,8 +135,8 @@ static const struct {
 	u32 RxConfigMask;	/* Clears the bits supported by this chip */
 } rtl_chip_info[] = {
 	_R("RTL8169",		RTL_GIGA_MAC_VER_01, 0xff7e1880), // 8169
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_02, 0xff7e1880), // 8169S
-	_R("RTL8169s/8110s",	RTL_GIGA_MAC_VER_03, 0xff7e1880), // 8110S
+	_R("RTL8169s",		RTL_GIGA_MAC_VER_02, 0xff7e1880), // 8169S
+	_R("RTL8110s",		RTL_GIGA_MAC_VER_03, 0xff7e1880), // 8110S
 	_R("RTL8169sb/8110sb",	RTL_GIGA_MAC_VER_04, 0xff7e1880), // 8169SB
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_05, 0xff7e1880), // 8110SCd
 	_R("RTL8169sc/8110sc",	RTL_GIGA_MAC_VER_06, 0xff7e1880), // 8110SCe
@@ -1391,22 +1380,26 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 }
 
-static void rtl8169_rar_set(struct rtl8169_private *tp, u8 *addr)
+static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
-	u32 low;
 	u32 high;
+	u32 low;
 
 	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
 	high = addr[4] | (addr[5] << 8);
 
+	spin_lock_irq(&tp->lock);
+
 	RTL_W8(Cfg9346, Cfg9346_Unlock);
 	RTL_W32(MAC0, low);
 	RTL_W32(MAC4, high);
 	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	spin_unlock_irq(&tp->lock);
 }
 
-static int rtl8169_set_mac_address(struct net_device *dev, void *p)
+static int rtl_set_mac_address(struct net_device *dev, void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
 	struct sockaddr *addr = p;
@@ -1416,7 +1409,7 @@ static int rtl8169_set_mac_address(struct net_device *dev, void *p)
 
 	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
 
-	rtl8169_rar_set(tp, dev->dev_addr);
+	rtl_rar_set(tp, dev->dev_addr);
 
 	return 0;
 }
@@ -1650,7 +1645,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 	dev->change_mtu = rtl8169_change_mtu;
-	dev->set_mac_address = rtl8169_set_mac_address;
+	dev->set_mac_address = rtl_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;

--J2SCkAp4GZ/dPZZf--
