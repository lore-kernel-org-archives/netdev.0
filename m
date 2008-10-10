From: Francois Romieu <romieu@fr.zoreil.com>
Subject: [PATCH 04/14] r8169: shuffle some registers handling around (8168
	operation only)
Date: Fri, 10 Oct 2008 23:41:05 +0200
Message-ID: <20081010214105.GD27195@electric-eye.fr.zoreil.com>
References: <20081006071229.GA23039@electric-eye.fr.zoreil.com> <20081007222202.GA9393@electric-eye.fr.zoreil.com> <20081009190015.GB19721@electric-eye.fr.zoreil.com> <20081009.122026.239988133.davem@davemloft.net> <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jamagallon@ono.com, greg@kroah.com, netdev@vger.kernel.org,
	bonbons@linux-vserver.org, ivecera@redhat.com,
	Ben Hutchings <bhutchings@solarflare.com>,
	ishikawa <chiaki.ishikawa@ubin.jp>, Mark Lord <lkml@rtr.ca>,
	edward_hsu@realtek.com.tw
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:37866 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759878AbYJJVln (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Oct 2008 17:41:43 -0400
Content-Disposition: inline
In-Reply-To: <20081010213638.GA25005@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I can not argue strongly for (or against) a specific ordering
on a purely technical ground but the patch avoids to swallow
Realtek's changes in one big, hard-to-read gulp.

Let aside the way the RxConfig register is written (see
rtl_set_rx_tx_config_registers / RxConfig / rtl_set_rx_mode),
this change brings the registers write ordering closer with
Realtek's driver one (version 8.006.00) for the 8168 chipsets.

More 8168 specific code which touches the Configx registers will
be added in the section covered by Cfg9346_UnLock / Cfg9346_Lock.

This code should not be the cause of regression for 810x and
8110 users.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
Cc: Edward Hsu <edward_hsu@realtek.com.tw>
---
 drivers/net/r8169.c |   13 +++++++------
 1 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 8086bac..273afb5 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2396,14 +2396,10 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_max_size(ioaddr);
 
-	rtl_set_rx_tx_config_registers(tp);
-
 	tp->cp_cmd |= RTL_R16(CPlusCmd) | PktCntrDisable | INTT_1;
 
 	RTL_W16(CPlusCmd, tp->cp_cmd);
 
-	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
-
 	RTL_W16(IntrMitigate, 0x5151);
 
 	/* Work around for RxFIFO overflow. */
@@ -2414,14 +2410,19 @@ static void rtl_hw_start_8168(struct net_device *dev)
 
 	rtl_set_rx_tx_desc_registers(tp, ioaddr);
 
-	RTL_W8(Cfg9346, Cfg9346_Lock);
+	rtl_set_rx_mode(dev);
+
+	RTL_W32(TxConfig, (TX_DMA_BURST << TxDMAShift) |
+		(InterFrameGap << TxInterFrameGapShift));
 
 	RTL_R8(IntrMask);
 
-	rtl_set_rx_mode(dev);
+	rtl_tx_performance_tweak(pdev, 0x5 << MAX_READ_REQUEST_SHIFT);
 
 	RTL_W8(ChipCmd, CmdTxEnb | CmdRxEnb);
 
+	RTL_W8(Cfg9346, Cfg9346_Lock);
+
 	RTL_W16(MultiIntr, RTL_R16(MultiIntr) & 0xF000);
 
 	RTL_W16(IntrMask, tp->intr_event);
-- 
1.5.3.3

