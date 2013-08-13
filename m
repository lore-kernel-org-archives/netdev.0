From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH] r8169: fix invalid register dump
Date: Tue, 13 Aug 2013 22:37:45 +0200
Message-ID: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com>
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com, lekensteyn@gmail.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f46.google.com ([74.125.82.46]:52911 "EHLO
	mail-wg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759174Ab3HMUhv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 16:37:51 -0400
Received: by mail-wg0-f46.google.com with SMTP id k13so6935471wgh.25
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 13:37:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter Wu <lekensteyn@gmail.com>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
Hi,

Personally I dislike the repetition of this patch, a hypothetical
`memcpy_fromio_block(bytes, tp->mmio_addr, 4)` would look cleaner, but
perhaps I am doing something wrong because apparantly nobody had a need
for reading multiple blocks from IO?

Anyway, this patch (with patched ethtool) allows `ethtool -d` to be more
useful for the mentioned chip.

Regards,
Peter
---
 drivers/net/ethernet/realtek/r8169.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..28af01c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +1897,17 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	char *bytes = p;
+	int i;
 
 	if (regs->len > R8169_REGS_SIZE)
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	memcpy_fromio(p, tp->mmio_addr, regs->len);
+	for (i = 0; i < regs->len - 4; i += 4)
+		memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
+	if (i < regs->len)
+		memcpy_fromio(bytes + i, tp->mmio_addr + i, regs->len - i);
 	rtl_unlock_work(tp);
 }
 
-- 
1.8.3.4
