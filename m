From: Dmitry Kravkov <dkravkov@gmail.com>
Subject: [PATCH] bnx2x: fix crash during TSO tunneling
Date: Thu, 24 Jul 2014 18:39:11 +0300
Message-ID: <1406216351-3230-1-git-send-email-Dmitry.Kravkov@qlogic.com>
Cc: ypei@redhat.com, mschmidt@redhat.com,
	Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f177.google.com ([209.85.212.177]:38789 "EHLO
	mail-wi0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759390AbaGXPje (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jul 2014 11:39:34 -0400
Received: by mail-wi0-f177.google.com with SMTP id ho1so4192795wib.10
        for <netdev@vger.kernel.org>; Thu, 24 Jul 2014 08:39:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When TSO packet is transmitted additional BD w/o mapping is used
to describe the packed. The BD needs special handling in tx
completion.

kernel: Call Trace:
kernel: <IRQ>  [<ffffffff815e19ba>] dump_stack+0x19/0x1b
kernel: [<ffffffff8105dee1>] warn_slowpath_common+0x61/0x80
kernel: [<ffffffff8105df5c>] warn_slowpath_fmt+0x5c/0x80
kernel: [<ffffffff814a8c0d>] ? find_iova+0x4d/0x90
kernel: [<ffffffff814ab0e2>] intel_unmap_page.part.36+0x142/0x160
kernel: [<ffffffff814ad0e6>] intel_unmap_page+0x26/0x30
kernel: [<ffffffffa01f55d7>] bnx2x_free_tx_pkt+0x157/0x2b0 [bnx2x]
kernel: [<ffffffffa01f8dac>] bnx2x_tx_int+0xac/0x220 [bnx2x]
kernel: [<ffffffff8101a0d9>] ? read_tsc+0x9/0x20
kernel: [<ffffffffa01f8fdb>] bnx2x_poll+0xbb/0x3c0 [bnx2x]
kernel: [<ffffffff814d041a>] net_rx_action+0x15a/0x250
kernel: [<ffffffff81067047>] __do_softirq+0xf7/0x290
kernel: [<ffffffff815f3a5c>] call_softirq+0x1c/0x30
kernel: [<ffffffff81014d25>] do_softirq+0x55/0x90
kernel: [<ffffffff810673e5>] irq_exit+0x115/0x120
kernel: [<ffffffff815f4358>] do_IRQ+0x58/0xf0
kernel: [<ffffffff815e94ad>] common_interrupt+0x6d/0x6d
kernel: <EOI>  [<ffffffff810bbff7>] ? clockevents_notify+0x127/0x140
kernel: [<ffffffff814834df>] ? cpuidle_enter_state+0x4f/0xc0
kernel: [<ffffffff81483615>] cpuidle_idle_call+0xc5/0x200
kernel: [<ffffffff8101bc7e>] arch_cpu_idle+0xe/0x30
kernel: [<ffffffff810b4725>] cpu_startup_entry+0xf5/0x290
kernel: [<ffffffff815cfee1>] start_secondary+0x265/0x27b
kernel: ---[ end trace 11aa7726f18d7e80 ]---

Reported-by: Yulong Pei <ypei@redhat.com>
Cc: Michal Schmidt <mschmidt@redhat.com>
Signed-off-by: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x.h     | 1 +
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 9 +++++++++
 2 files changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
index 4cab09d..8206a29 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x.h
@@ -346,6 +346,7 @@ struct sw_tx_bd {
 	u8		flags;
 /* Set on the first BD descriptor when there is a split BD */
 #define BNX2X_TSO_SPLIT_BD		(1<<0)
+#define BNX2X_HAS_SECOND_PBD		(1<<1)
 };
 
 struct sw_rx_page {
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 4b875da..c43e723 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -227,6 +227,12 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fp_txdata *txdata,
 	--nbd;
 	bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
 
+	if (tx_buf->flags & BNX2X_HAS_SECOND_PBD) {
+		/* Skip second parse bd... */
+		--nbd;
+		bd_idx = TX_BD(NEXT_TX_IDX(bd_idx));
+	}
+
 	/* TSO headers+data bds share a common mapping. See bnx2x_tx_split() */
 	if (tx_buf->flags & BNX2X_TSO_SPLIT_BD) {
 		tx_data_bd = &txdata->tx_desc_ring[bd_idx].reg_bd;
@@ -3889,6 +3895,9 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
 			/* set encapsulation flag in start BD */
 			SET_FLAG(tx_start_bd->general_data,
 				 ETH_TX_START_BD_TUNNEL_EXIST, 1);
+
+			tx_buf->flags |= BNX2X_HAS_SECOND_PBD;
+
 			nbd++;
 		} else if (xmit_type & XMIT_CSUM) {
 			/* Set PBD in checksum offload case w/o encapsulation */
-- 
1.9.3
