From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH] r8169: fix invalid register dump
Date: Sat, 17 Aug 2013 00:35:58 +0200
Message-ID: <8673892.63sYyivWik@al>
References: <1376426265-30353-1-git-send-email-lekensteyn@gmail.com> <2045708.ru9COLib4d@al> <20130814224736.GA5193@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:43172 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755637Ab3HPWgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Aug 2013 18:36:03 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so1236555ead.7
        for <netdev@vger.kernel.org>; Fri, 16 Aug 2013 15:36:02 -0700 (PDT)
In-Reply-To: <20130814224736.GA5193@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 15 August 2013 00:47:36 Francois Romieu wrote:
> Spartan implementation:
> 
>         u32 __iomem *ioaddr = tp->mmio_addr;
>         u32 *dw = p;
>         int i;
> 
>         ...
> 
>         for (i = regs->len; i > 0; i -= 4)
>                 memcpy_fromio(dw++, ioaddr++, min(i, 4));

I like this one, simple and readable. I was worried about endianness
issues, but that does not apply here as the source and destination
are presumably in byte order.

I have tested this patch with a modified ethtool[1].

 [1]: http://www.spinics.net/lists/netdev/msg246364.html
--
From: Peter Wu <lekensteyn@gmail.com>

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c 
b/drivers/net/ethernet/realtek/r8169.c
index b5eb419..2943916 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,12 +1897,16 @@ static void rtl8169_get_regs(struct net_device *dev, 
struct ethtool_regs *regs,
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
