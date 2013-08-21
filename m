From: Peter Wu <lekensteyn@gmail.com>
Subject: Re: [PATCH v3] r8169: fix invalid register dump
Date: Wed, 21 Aug 2013 22:40:58 +0200
Message-ID: <18365346.kxAWDne41Q@al>
References: <1376833298-7321-1-git-send-email-lekensteyn@gmail.com> <20130820.150213.1489180923839317674.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: romieu@fr.zoreil.com, bhutchings@solarflare.com,
	netdev@vger.kernel.org, nic_swsd@realtek.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f50.google.com ([74.125.82.50]:59660 "EHLO
	mail-wg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752235Ab3HUUlE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Aug 2013 16:41:04 -0400
Received: by mail-wg0-f50.google.com with SMTP id m15so835984wgh.17
        for <netdev@vger.kernel.org>; Wed, 21 Aug 2013 13:41:03 -0700 (PDT)
In-Reply-To: <20130820.150213.1489180923839317674.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 20 August 2013 15:02:13 David Miller wrote:
> > This partly obsoletes "r8169,sis190: remove unnecessary length
> > check"[1]. I do not have sis190 hardware, but since that is based on
> > this r8169 driver, would it make sense to apply this patch to sis190
> > too?
> 
> You're going to have to respin this since I applied the length
> check removal patch already.

Please find the updated patch below. There may be differences in lines
because net-next has the r8169,sis190 patch and net the WOL fix.

Can I consider Francois reply[1] as Acked-by?

Thanks,
Peter

 [1]: http://lkml.kernel.org/r/20130817211407.GA30676@electric-eye.fr.zoreil.com

--
>From 56b7598a712e63841b6d8efb2245e5bb87990e01 Mon Sep 17 00:00:00 2001
From: Peter Wu <lekensteyn@gmail.com>
Date: Tue, 23 Jul 2013 12:27:27 +0200
Subject: [PATCH] r8169: fix invalid register dump

For some reason, my PCIe RTL8111E onboard NIC on a GA-Z68X-UD3H-B3
motherboard reads as FFs when reading from MMIO with a block size
larger than 7. Therefore change to reading blocks of four bytes.

Ben Hutchings noted that the buffer is large enough to hold all
registers, so now all registers are read.

Signed-off-by: Peter Wu <lekensteyn@gmail.com>
---
 drivers/net/ethernet/realtek/r8169.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 93ee49d..f724d9c 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -1897,9 +1897,12 @@ static void rtl8169_get_regs(struct net_device *dev, struct ethtool_regs *regs,
 			     void *p)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-
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
