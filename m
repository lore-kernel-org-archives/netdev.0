From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 driver crashes in 2.6.32.43
Date: Thu, 28 Jul 2011 12:58:31 +0200
Message-ID: <20110728105831.GA11385@electric-eye.fr.zoreil.com>
References: <20110724195831.GA8718@colin.search.kasperd.net> <20110724201626.GB24418@zoreil.com> <20110725103643.GA11135@colin.search.kasperd.net> <20110728070455.GA11251@electric-eye.fr.zoreil.com> <20110728084821.GA24125@colin.search.kasperd.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ivecera@redhat.com, hayeswang@realtek.com, gregkh@suse.de,
	netdev@vger.kernel.org
To: Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:40956 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754481Ab1G1LO1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 07:14:27 -0400
Content-Disposition: inline
In-Reply-To: <20110728084821.GA24125@colin.search.kasperd.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Kasper Dupont <kasperd@cpvhh.24.jul.2011.kasperd.net> :
[...]
> I tried to apply both 1519e57fe81c14bb8fa4855579f19264d1ef63b4
> and f60ac8e7ab7cbb413a0131d5665b053f9f386526. It still crashes,
> the first two times I booted that exact build it printed out a
> stackdump just before crashing. I have pictures of the two
> stack dumps in case that is any help, but unfortunately they
> were too deep to fit on 25 lines.

It will probably not help but I can hardly tell without seeing them. :o)
It will be ok if you publish them somewhere.

Does something prevent you to enable a different video mode ?

[...]
> I tried applying this one as well (in addition to the previous
> two). It no longer crashes, but now the network stops working
> after the first few packets have been transmitted.

Thanks for testing.

> What exactly was 649f25c389e9498923b459bbffff41a2fd1d7a64
> trying to fix in the first place?
>
> Before that patch the network on this machine was running fast and stable.

It's frustrating.

Either the hardware did not experience Rx FIFO overflow internally or it
was able to recover from it without driver intervention. Ivan's hardware
seems to behave differently so blindly revert 
649f25c389e9498923b459bbffff41a2fd1d7a64 is not an option.

Can you add the crap below on top of the pre "no longer crashes, no network"
one (it will work on top of plain -git driver as well) ?

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7d9c650..f9f2044 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -395,6 +395,7 @@ enum rtl_register_content {
 	/* InterruptStatusBits */
 	SYSErr		= 0x8000,
 	PCSTimeout	= 0x4000,
+	RxFIFOEmpty	= 0x0200,	/* 816x something only ? */
 	SWInt		= 0x0100,
 	TxDescUnavail	= 0x0080,
 	RxFIFOOver	= 0x0040,
@@ -5381,9 +5382,10 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 
 		if (unlikely(status & RxFIFOOver)) {
 			switch (tp->mac_version) {
+				int i;
+
 			/* Work around for rx fifo overflow */
 			case RTL_GIGA_MAC_VER_11:
-			case RTL_GIGA_MAC_VER_22:
 			case RTL_GIGA_MAC_VER_26:
 				netif_stop_queue(dev);
 				rtl8169_tx_timeout(dev);
@@ -5399,6 +5401,21 @@ static irqreturn_t rtl8169_interrupt(int irq, void *dev_instance)
 			case RTL_GIGA_MAC_VER_28:
 			case RTL_GIGA_MAC_VER_31:
 			/* Experimental science. Pktgen proof. */
+			case RTL_GIGA_MAC_VER_22:
+				netif_info(tp, drv, dev, "S: %08x\n", status);
+				for (i = 0; i < 4000000; i++) {
+					if (RTL_R16(IntrStatus) & RxFIFOEmpty) {
+						RTL_W16(IntrStatus, RxFIFOOver);
+						if (net_ratelimit()) {
+							netif_info(tp, drv, dev,
+								   "FEmp\n");
+						}
+						break;
+					}
+					udelay(10);
+				}
+				if ((i >= 4000000) && net_ratelimit())
+					netif_info(tp, drv, dev, "no FEmp\n");
 			case RTL_GIGA_MAC_VER_12:
 			case RTL_GIGA_MAC_VER_25:
 				if (status == RxFIFOOver)
