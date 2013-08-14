From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Wed, 14 Aug 2013 15:12:50 +0200
Message-ID: <3465288.NFVErF5E7l@al>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com> <20130813222038.GC5635@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f48.google.com ([74.125.82.48]:61473 "EHLO
	mail-wg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932282Ab3HNNM4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 09:12:56 -0400
Received: by mail-wg0-f48.google.com with SMTP id f12so7436064wgh.3
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 06:12:55 -0700 (PDT)
In-Reply-To: <20130813222038.GC5635@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 August 2013 00:20:38 Francois Romieu wrote:
> > -     memcpy_fromio(p, tp->mmio_addr, regs->len);
> > +     for (i = 0; i < regs->len - 4; i += 4)
> > +             memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
> 
> regs->len is u32. regs->len - 4 should not underflow on normal situation but
> it's a bit sloppy.

Heh, I forgot about that case. Fixed it in the below patch. By the way,
have you observed similar behavior on other hardware?

Thanks,
Peter
--
From: Peter Wu <lekensteyn@gmail.com>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..d367763 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +1897,19 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	char *bytes = p;
+	int i;
 
 	if (regs->len > R8169_REGS_SIZE)
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	memcpy_fromio(p, tp->mmio_addr, regs->len);
+	if (regs->len >= 4) {
+		for (i = 0; i < regs->len - 4; i += 4)
+			memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
+	}
+	if (i < regs->len)
+		memcpy_fromio(bytes + i, tp->mmio_addr + i, regs->len - i);
 	rtl_unlock_work(tp);
 }
 
-- 
1.8.3.4
