From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 20/21] r8169: mac address change support
Date: Fri, 29 Jun 2007 22:29:14 +0200
Message-ID: <20070629202914.GV3240@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:32788 "EHLO
	fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751758AbXF2UcW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Jun 2007 16:32:22 -0400
Content-Disposition: inline
In-Reply-To: <20070629201212.GA3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Merged from Realtek's r8169-6.001 driver.

I have added some locking to protect against the arp monitoring
timer in the bonding driver. Accessing the configuration registers
is otherwise performed under RTNL locking.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   36 ++++++++++++++++++++++++++++++++++++
 1 files changed, 36 insertions(+), 0 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index dc8f369..7aa9cf4 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -182,6 +182,7 @@ static struct {
 
 enum rtl_registers {
 	MAC0		= 0,	/* Ethernet hardware address. */
+	MAC4		= 4,
 	MAR0		= 8,	/* Multicast filter. */
 	CounterAddrLow		= 0x10,
 	CounterAddrHigh		= 0x14,
@@ -1379,6 +1380,40 @@ static void rtl8169_init_phy(struct net_device *dev, struct rtl8169_private *tp)
 		printk(KERN_INFO PFX "%s: TBI auto-negotiating\n", dev->name);
 }
 
+static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 high;
+	u32 low;
+
+	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
+	high = addr[4] | (addr[5] << 8);
+
+	spin_lock_irq(&tp->lock);
+
+	RTL_W8(Cfg9346, Cfg9346_Unlock);
+	RTL_W32(MAC0, low);
+	RTL_W32(MAC4, high);
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
+	spin_unlock_irq(&tp->lock);
+}
+
+static int rtl_set_mac_address(struct net_device *dev, void *p)
+{
+	struct rtl8169_private *tp = netdev_priv(dev);
+	struct sockaddr *addr = p;
+
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+
+	memcpy(dev->dev_addr, addr->sa_data, dev->addr_len);
+
+	rtl_rar_set(tp, dev->dev_addr);
+
+	return 0;
+}
+
 static int rtl8169_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -1610,6 +1645,7 @@ rtl8169_init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	dev->irq = pdev->irq;
 	dev->base_addr = (unsigned long) ioaddr;
 	dev->change_mtu = rtl8169_change_mtu;
+	dev->set_mac_address = rtl_set_mac_address;
 
 #ifdef CONFIG_R8169_NAPI
 	dev->poll = rtl8169_poll;
-- 
1.4.4.2

