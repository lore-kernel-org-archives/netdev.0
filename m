From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v2] r8169: fix invalid register dump
Date: Sat, 17 Aug 2013 11:04:23 +0200
Message-ID: <1376730263-9352-1-git-send-email-lekensteyn@gmail.com>
Cc: nic_swsd <nic_swsd@realtek.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Francois Romieu <romieu@fr.zoreil.com>, lekensteyn@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:41425 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752380Ab3HQJEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 Aug 2013 05:04:30 -0400
Received: by mail-ea0-f179.google.com with SMTP id b10so1410020eae.10
        for <netdev@vger.kernel.org>; Sat, 17 Aug 2013 02:04:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Thanks to Francois for a better implementation.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..2943916 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +1897,16 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	u32 __iomem *data = tp->mmio_addr;
+	u32 *dw = p;
+	int i;
 
 	if (regs->len > R8169_REGS_SIZE)
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	memcpy_fromio(p, tp->mmio_addr, regs->len);
+	for (i = regs->len; i > 0; i -= 4)
+		memcpy_fromio(dw++, data++, min(4, i));
 	rtl_unlock_work(tp);
 }
 
-- 
1.8.3.4
