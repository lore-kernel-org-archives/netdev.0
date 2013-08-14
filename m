From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Wed, 14 Aug 2013 23:31:25 +0200
Message-ID: <2045708.ru9COLib4d@al>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com> <3465288.NFVErF5E7l@al> <20130814195829.GA1613@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:54005 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933097Ab3HNVb3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 17:31:29 -0400
Received: by mail-wi0-f179.google.com with SMTP id hr7so2497813wib.12
        for <netdev@vger.kernel.org>; Wed, 14 Aug 2013 14:31:28 -0700 (PDT)
In-Reply-To: <20130814195829.GA1613@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 14 August 2013 21:58:29 Francois Romieu wrote:
> > -     memcpy_fromio(p, tp->mmio_addr, regs->len);
> > +     if (regs->len >= 4) {
> > +             for (i = 0; i < regs->len - 4; i += 4)
> > +                     memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
> > +     }
> > +     if (i < regs->len)
> 
> Comparison with random stack stuff when regs->len < 4. :o/

Right, let's rm $OLD_PATCH and consider this one.

Checklist:
1. super large regs->len: won't be greater than R8169_REGS_SIZE (256)
2. regs->len == 0: 0 < 0 is false, nothing is copied
3. regs->len is 1, 2 or 3: i = 0, at most 3 bytes will be copied
4. regs->len is 4, i < 4 - 4, skip loop, 0 < regs->len, copy 4
5. regs->len is 5, i < 5 - 4, copy; 4 < regs->len, copy 1

With this I can now say with confidence that I haven't overlooked something
related to integer overflow. You have a very sharp eye, thanks for
catching my mistakes.

Regards,
Peter
---
From: Peter Wu <lekensteyn@gmail.com>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 9 ++++++++-
 1 file changed, 8 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..19524c0 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +1897,19 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
+	char *bytes = p;
+	int i = 0;
 
 	if (regs->len > R8169_REGS_SIZE)
 		regs->len = R8169_REGS_SIZE;
 
 	rtl_lock_work(tp);
-	memcpy_fromio(p, tp->mmio_addr, regs->len);
+	if (regs->len >= 4) {
+		for (; i < regs->len - 4; i += 4)
+			memcpy_fromio(bytes + i, tp->mmio_addr + i, 4);
+	}
+	if (i < regs->len)
+		memcpy_fromio(bytes + i, tp->mmio_addr + i, regs->len - i);
 	rtl_unlock_work(tp);
 }
 
-- 
1.8.3.4
