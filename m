From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 12/12] r8169: mac address change support
Date: Thu, 26 Apr 2007 23:49:42 +0200
Message-ID: <20070426214942.GM7344@electric-eye.fr.zoreil.com>
References: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:58579 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755167AbXDZVwK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 17:52:10 -0400
Content-Disposition: inline
In-Reply-To: <20070426205714.GA12701@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Merged from Realtek's r8169-6.001 driver.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com>
---
 drivers/net/r8169.c |   32 ++++++++++++++++++++++++++++++++
 1 files changed, 32 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 2667862..5b42176 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -182,6 +182,7 @@ static struct {
 
 enum rtl_registers {
 	MAC0		= 0,	/* Ethernet hardware address. */
+	MAC4		= 4,
 	MAR0		= 8,	/* Multicast filter. */
 	CounterAddrLow		= 0x10,
 	CounterAddrHigh		= 0x14,
@@ -1391,6 +1392,36 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 }
 
+static void rtl8169_rar_set(struct rtl8169_private *tp, u8 *addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 low;
+	u32 high;
+
+	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
+	high = addr[4] | (addr[5] << 8);
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W32(MAC0, low);
+	RTL_W32(MAC4, high);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+}
+
+static int rtl8169_set_mac_address(struct net_device *dev, void *p)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	rtl8169_rar_set(tp, dev->dev_addr);
+
+	return 0;
+}
+
 static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1712,6 +1743,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 	dev->change_mtu = rtl8169_change_mtu;
+	dev->set_mac_address = rtl8169_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
-- 
1.4.4.2
