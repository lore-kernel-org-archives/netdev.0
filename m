From: Martin Michlmayr <tbm@cyrius.com>
Subject: Re: [PATCH 12/21] r8169: confusion between hardware and IP header
	alignment
Date: Fri, 23 Nov 2007 08:45:49 +0100
Message-ID: <20071123074549.GE18081@deprecation.cyrius.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202555.GN3240@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	bunk@stusta.de
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sorrow.cyrius.com ([65.19.161.204]:2894 "EHLO sorrow.cyrius.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751260AbXKWHqL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 02:46:11 -0500
Content-Disposition: inline
In-Reply-To: <20070629202555.GN3240@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Francois,

A Debian user reported that NFS transfers are not working correctly on
a Thecus N2100 (which has two 8169 ports).  I confirmed this bug with
2.6.18 and 2.6.22 but couldn't reproduce it with 2.6.23.  A git bisect
has revealed that your patch "confusion between hardware and IP header
alignment" fixes the issue.  Thanks for fixing this bug before we even
got a chance to report it. ;-)

I'd like to backport the fix to the 2.6.18 kernel that is in our
stable release and have a couple of questions:
 - Does your later patch "align the IP header when there is no DMA
   constraint" fix any bugs or is it merely an improvement?
 - Should I change "align" to 8 for RTL_CFG_1, as it's done in
   current kernels?

I'd like to backport only the changes needed to actually fix the bug
in order to make sure I won't break any other devices.  The patch
below works for me but I'd like to hear your opinion about my
questions above.

[ I added Adrian Bunk to the CC line since he might be interested in
applying the patch from [1] and possibly [2] to his 2.6.16 branch. ]

--- a/drivers/net/r8169.c	2007-11-22 12:20:51.000000000 +0000
+++ b/drivers/net/r8169.c	2007-11-22 12:20:51.000000000 +0000
@@ -202,7 +202,7 @@
 	unsigned int region;
 	unsigned int align;
 } rtl_cfg_info[] = {
-	[RTL_CFG_0] = { 1, NET_IP_ALIGN },
+	[RTL_CFG_0] = { 1, 2 },
 	[RTL_CFG_1] = { 2, NET_IP_ALIGN },
 	[RTL_CFG_2] = { 2, 8 }
 };
@@ -2487,9 +2487,9 @@
 	if (pkt_size < rx_copybreak) {
 		struct sk_buff *skb;
 
-		skb = dev_alloc_skb(pkt_size + align);
+		skb = dev_alloc_skb(pkt_size + NET_IP_ALIGN);
 		if (skb) {
-			skb_reserve(skb, (align - 1) & (u32)skb->data);
+			skb_reserve(skb, NET_IP_ALIGN);
 			eth_copy_and_sum(skb, sk_buff[0]->data, pkt_size, 0);
 			*sk_buff = skb;
 			rtl8169_mark_to_asic(desc, rx_buf_sz);

Some background: the Thecus N2100 is an ARM based NAS device with two
8169 ports.  The chips exhibit PCI parity problems so
dev->broken_parity_status is set on this platform.  The Debian bug is
http://bugs.debian.org/452069

Here's the output from lspci:

00:01.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
        Flags: bus master, 66MHz, medium devsel, latency 0, IRQ 27
        I/O ports at fe000000 [size=256]
        Memory at 800a0200 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at 80080000 [disabled] [size=64K]
        Capabilities: [dc] Power Management version 2
        Capabilities: [60] Vital Product Data

00:02.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet (rev 10)
        Subsystem: Realtek Semiconductor Co., Ltd. RTL-8169 Gigabit Ethernet
        Flags: bus master, 66MHz, medium devsel, latency 0, IRQ 30
        I/O ports at fe000400 [size=256]
        Memory at 800a0300 (32-bit, non-prefetchable) [size=256]
        Expansion ROM at 80090000 [disabled] [size=64K]
        Capabilities: [dc] Power Management version 2
        Capabilities: [60] Vital Product Data

[1] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commit;h=864022344caf43dab7fa5219152280d056c6e051
[2] http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=commitdiff;h=e9f63f30863fd778a5329e93c7e2208b9bcb5b79
-- 
Martin Michlmayr
http://www.cyrius.com/
