From: Peter Wu <lekensteyn@gmail.com>
Subject: [PATCH v3] r8169: fix invalid register dump
Date: Sun, 18 Aug 2013 15:41:38 +0200
Message-ID: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com>
Cc: lekensteyn@gmail.com, netdev@vger.kernel.org,
	nic_swsd <nic_swsd@realtek.com>
To: Francois Romieu <romieu@fr.zoreil.com>,
	Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f169.google.com ([209.85.215.169]:50078 "EHLO
	mail-ea0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755370Ab3HRNln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Aug 2013 09:41:43 -0400
Received: by mail-ea0-f169.google.com with SMTP id k11so379299eaj.14
        for <netdev@vger.kernel.org>; Sun, 18 Aug 2013 06:41:42 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Ben Hutchings noted that the buffer is large enough to hold all
registers, so now all registers are read. Since regs->len is not used
anymore, drop the superfluous range check as well. (ethtool would
already ensure that regs->len <= R8169_REGS_SIZE).

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
Hi,

This partly obsoletes "r8169,sis190: remove unnecessary length
check"[1]. I do not have sis190 hardware, but since that is based on
this r8169 driver, would it make sense to apply this patch to sis190
too?

Regards,
Peter

 [1]: http://www.spinics.net/lists/netdev/msg246824.html
---
 drivers/net/ethernet/realtek/r8169.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..c0c9e14 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +1897,13 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-
-	if (regs->len > R8169_REGS_SIZE)
-		regs->len = R8169_REGS_SIZE;
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
