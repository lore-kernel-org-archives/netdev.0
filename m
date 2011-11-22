From: "Lee, Chun-Yi" <joeyli.kernel@gmail.com>
Subject: [PATCH] r8169: Restore MAC address after resume on buggy BIOS
Date: Tue, 22 Nov 2011 18:35:37 +0800
Message-ID: <1321958137-23281-1-git-send-email-jlee@suse.com>
Cc: netdev@vger.kernel.org, "Lee, Chun-Yi" <jlee@suse.com>,
	Hayes Wang <hayeswang@realtek.com>,
	Francois Romieu <romieu@fr.zoreil.com>
To: nic_swsd@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:32859 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752739Ab1KVKhj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Nov 2011 05:37:39 -0500
Received: by ggnr5 with SMTP id r5so40949ggn.19
        for <netdev@vger.kernel.org>; Tue, 22 Nov 2011 02:37:39 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we test r8169 driver with RTL8111E-VL, found have buggy BIOS
write garbage MAC address (e.g. FF:FF:FF:FF:FF:FF) to extended GigaMAC
registers when S3 resume. And, we also found Realtek Windows driver
can cover this buggy BIOS's problem.

So, this patch add a MAC address check in resume callback function and
restore MAC address if buggy BIOS changed it.

Signed-off-by: Lee, Chun-Yi <jlee@suse.com>
Cc: Hayes Wang <hayeswang@realtek.com>
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>
Cc: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c |   33 +++++++++++++++++++++++++++++++++
 1 files changed, 33 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 6f06aa1..91d4a09 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3335,6 +3335,35 @@ static void rtl_rar_set(struct rtl8169_private *tp, u8 *addr)
 	spin_unlock_irq(&tp->lock);
 }
 
+static bool rtl_rar_check(struct rtl8169_private *tp, u8 *addr)
+{
+	void __iomem *ioaddr = tp->mmio_addr;
+	u32 high;
+	u32 low;
+
+	low  = addr[0] | (addr[1] << 8) | (addr[2] << 16) | (addr[3] << 24);
+	high = addr[4] | (addr[5] << 8);
+
+	if (RTL_R32(MAC4) != high)
+		return false;
+	if (RTL_R32(MAC0) != low)
+		return false;
+
+	if (tp->mac_version == RTL_GIGA_MAC_VER_34) {
+		if (rtl_eri_read(ioaddr, 0xe0, ERIAR_EXGMAC) != low)
+			return false;
+		if (rtl_eri_read(ioaddr, 0xe4, ERIAR_EXGMAC) != high)
+			return false;
+		if (rtl_eri_read(ioaddr, 0xf0, ERIAR_EXGMAC) != (low << 16))
+			return false;
+		if (rtl_eri_read(ioaddr, 0xf4, ERIAR_EXGMAC) != (high << 16 |
+								 low >> 16))
+			return false;
+	}
+
+	return true;
+}
+
 static int rtl_set_mac_address(struct net_device *dev, void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
@@ -6098,6 +6127,10 @@ static int rtl8169_resume(struct device *device)
 
 	rtl8169_init_phy(dev, tp);
 
+	/* Restore MAC address if buggy BIOS changed it */
+	if (!rtl_rar_check(tp, dev->dev_addr))
+		rtl_rar_set(tp, dev->dev_addr);
+
 	if (netif_running(dev))
 		__rtl8169_resume(dev);
 
-- 
1.6.0.2
