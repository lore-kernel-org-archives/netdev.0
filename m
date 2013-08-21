From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH net-next v4] r8169: fix invalid register dump
Date: Wed, 21 Aug 2013 23:17:11 +0200
Message-ID: <1377119831-29691-1-git-send-email-lekensteyn@gmail.com>
References: <20130821205325.GA24054@electric-eye.fr.zoreil.com>
Cc: nic_swsd@realtek.com, bhutchings@solarflare.com,
	Francois Romieu <romieu@fr.zoreil.com>, lekensteyn@gmail.com
To: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f182.google.com ([74.125.82.182]:39431 "EHLO
	mail-we0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab3HUVRS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 17:17:18 -0400
Received: by mail-we0-f182.google.com with SMTP id q59so932484wes.27
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 14:17:16 -0700 (PDT)
In-Reply-To: <20130821205325.GA24054@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Ben Hutchings noted that the buffer is large enough to hold all
registers, so now all registers are read.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
---
 drivers/net/ethernet/realtek/r8169.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 93ee49d..c0c9e14 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,9 +1897,13 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	u32 __iomem *data = tp->mmio_addr;
+	u32 *dw = p;
+	int i;
 
 	rtl_lock_work(tp);
-	memcpy_fromio(p, tp->mmio_addr, regs->len);
+	for (i = 0; i < R8169_REGS_SIZE; i += 4)
+		memcpy_fromio(dw++, data++, 4);
 	rtl_unlock_work(tp);
 }
 
-- 
1.8.3.4
