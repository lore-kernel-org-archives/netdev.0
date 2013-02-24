From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Fw: [Bug 54231] r8169 driver regression caused by the commit aee77e4accbeb2c86b1d294cd84fec4a12dde3bd
Date: Sun, 24 Feb 2013 23:04:13 +0100
Message-ID: <20130224220413.GA22870@electric-eye.fr.zoreil.com>
References: <20130222095546.396e63a8@nehalam.linuxnetplumber.net> <20130222230908.GB4248@electric-eye.fr.zoreil.com> <512A2BB0.9050803@ncircle.nullnet.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev@vger.kernel.org
To: Tomi Orava <tomimo@ncircle.nullnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38181 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759153Ab3BXWgU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Feb 2013 17:36:20 -0500
Content-Disposition: inline
In-Reply-To: <512A2BB0.9050803@ncircle.nullnet.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tomi Orava <tomimo@ncircle.nullnet.fi> :
> On 02/23/2013 01:09 AM, Francois Romieu wrote:
[...]
> I started re-testing after your comment and figured out that the
> real problem seems to lie somehow with jumbo frames. Ie. the DMA burst
> changes do not actually prevent the hangs at all in my case. The
> catch here, that I missed previously, was that for some interesting
> reason the NIC will fail in a couple of minutes with a suitable traffic
> if the jumbo frames (mtu 4000) have been enabled from the start.
> However, if I enable the jumbo frames manually after the system
> has already started up, there are no stability issues related to network.

If you mean that 'ip link set dev ... mtu 4000; ip link set dev ... up'
fails whereas 'ip link set dev ... up; ip link set dev ... mtu 4000'
works, the patch below is a candidate:

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 8900398..af99498 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -4766,7 +4766,7 @@ static void rtl_hw_start_8168bb(struct rtl8169_private *tp)
 	RTL_W16(CPlusCmd, RTL_R16(CPlusCmd) & ~R8168_CPCMD_QUIRK_MASK);
 
 	rtl_tx_performance_tweak(pdev,
-		(0x5 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
+		(0x2 << MAX_READ_REQUEST_SHIFT) | PCI_EXP_DEVCTL_NOSNOOP_EN);
 }
 
 static void rtl_hw_start_8168bef(struct rtl8169_private *tp)
---

[...]
> > Tomi, what does lspci say about your 8168b device ?
> 
> The NIC information is:
> 
> 03:00.0 Ethernet controller: Realtek Semiconductor Co., Ltd. RTL8111/8168B PCI
> Express Gigabit Ethernet controller (rev 01)
> 
> 03:00.0 0200: 10ec:8168 (rev 01)

Ok, so the first hunk of the patch that Stephen forwarded would not make
any difference for your chipset.

-- 
Ueimor
