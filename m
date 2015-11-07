From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 4.3.0 r8169: "rtl_counters_cond == 1 (loop: 1000, delay: 10)."
 log spam
Date: Sat, 7 Nov 2015 23:00:34 +0100
Message-ID: <20151107220034.GA8795@electric-eye.fr.zoreil.com>
References: <CAGmahrQeczagrfAc-cbGnDrDW4c3DNwAZCn=ZYkRo=q9wnge5g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, andreas.reis@gmail.com
To: Sverd Johnsen <sverd.johnsen@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:55368 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752400AbbKGWAi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Nov 2015 17:00:38 -0500
Content-Disposition: inline
In-Reply-To: <CAGmahrQeczagrfAc-cbGnDrDW4c3DNwAZCn=ZYkRo=q9wnge5g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sverd Johnsen <sverd.johnsen@googlemail.com> :
> related:
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=107421

Let's start with yours.

> https://bugzilla.kernel.org/show_bug.cgi?id=104351
> 
> 4.3.0 smp x86_64
> 
> [    4.384336] r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
> [    4.384747] r8169 0000:0e:00.0 eth0: RTL8101e at
> 0xffffc90000060000, 00:1b:38:b5:9f:d6, XID 94200000 IRQ 29
> [   13.288711] r8169 0000:0e:00.0 enp14s0: renamed from eth0
> [   13.317747] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   28.238567] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   28.904171] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   28.923315] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   29.029901] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
[snip]
> [   36.148587] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).

Something enjoys harnessing the tally counters. I don't know why.

> [   46.511024] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   48.304603] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   61.528387] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).
> [   76.545869] r8169 0000:0e:00.0 enp14s0: rtl_counters_cond == 1
> (loop: 1000, delay: 10).

Looks like stats retrieval every 15s.

Is the link up at this point ?

Can you temporarily increase the driver verbosity ? It may display
some more messages at WARNING level if you enable "hw" context messages
through ethtool (see "msglvl" option).

Btw the patch below could make a difference.

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index b4f2123..b9817fec 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -2194,8 +2194,12 @@ static int rtl8169_get_sset_count(struct net_device *dev, int sset)
 DECLARE_RTL_COND(rtl_counters_cond)
 {
 	void __iomem *ioaddr = tp->mmio_addr;
+	u32 mask = CounterReset;
 
-	return RTL_R32(CounterAddrLow) & (CounterReset | CounterDump);
+	if (tp->mac_version >= RTL_GIGA_MAC_VER_19)
+		mask |= CounterDump;
+
+	return RTL_R32(CounterAddrLow) & mask;
 }
 
 static bool rtl8169_do_counters(struct net_device *dev, u32 counter_cmd)

-- 
Ueimor
