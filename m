From: Iyappan Subramanian <isubramanian@apm.com>
Subject: [PATCH] drivers: net: xgene: fix: Out of order descriptor bytes read
Date: Thu, 22 Jan 2015 12:03:27 -0800
Message-ID: <1421957007-720-1-git-send-email-isubramanian@apm.com>
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	mlangsdo@redhat.com, patches@apm.com,
	Iyappan Subramanian <isubramanian@apm.com>,
	Keyur Chudgar <kchudgar@apm.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og125.obsmtp.com ([64.18.0.245]:58869 "EHLO
	mail-pd0-f180.google.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751930AbbAVUAo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2015 15:00:44 -0500
Received: by mail-pd0-f180.google.com with SMTP id ft15so3546883pdb.11
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2015 12:00:43 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the following kernel crash,

	WARNING: CPU: 2 PID: 0 at net/ipv4/tcp_input.c:3079 tcp_clean_rtx_queue+0x658/0x80c()
	Call trace:
	[<fffffe0000096b7c>] dump_backtrace+0x0/0x184
	[<fffffe0000096d10>] show_stack+0x10/0x1c
	[<fffffe0000685ea0>] dump_stack+0x74/0x98
	[<fffffe00000b44e0>] warn_slowpath_common+0x88/0xb0
	[<fffffe00000b461c>] warn_slowpath_null+0x14/0x20
	[<fffffe00005b5c1c>] tcp_clean_rtx_queue+0x654/0x80c
	[<fffffe00005b6228>] tcp_ack+0x454/0x688
	[<fffffe00005b6ca8>] tcp_rcv_established+0x4a4/0x62c
	[<fffffe00005bf4b4>] tcp_v4_do_rcv+0x16c/0x350
	[<fffffe00005c225c>] tcp_v4_rcv+0x8e8/0x904
	[<fffffe000059d470>] ip_local_deliver_finish+0x100/0x26c
	[<fffffe000059dad8>] ip_local_deliver+0xac/0xc4
	[<fffffe000059d6c4>] ip_rcv_finish+0xe8/0x328
	[<fffffe000059dd3c>] ip_rcv+0x24c/0x38c
	[<fffffe0000563950>] __netif_receive_skb_core+0x29c/0x7c8
	[<fffffe0000563ea4>] __netif_receive_skb+0x28/0x7c
	[<fffffe0000563f54>] netif_receive_skb_internal+0x5c/0xe0
	[<fffffe0000564810>] napi_gro_receive+0xb4/0x110
	[<fffffe0000482a2c>] xgene_enet_process_ring+0x144/0x338
	[<fffffe0000482d18>] xgene_enet_napi+0x1c/0x50
	[<fffffe0000565454>] net_rx_action+0x154/0x228
	[<fffffe00000b804c>] __do_softirq+0x110/0x28c
	[<fffffe00000b8424>] irq_exit+0x8c/0xc0
	[<fffffe0000093898>] handle_IRQ+0x44/0xa8
	[<fffffe000009032c>] gic_handle_irq+0x38/0x7c
	[...]

Software writes poison data into the descriptor bytes[15:8] and upon
receiving the interrupt, if those bytes are overwritten by the hardware with
the valid data, software also reads bytes[7:0] and executes receive/tx
completion logic.

If the CPU executes the above two reads in out of order fashion, then the
bytes[7:0] will have older data and causing the kernel panic.  We have to
force the order of the reads and thus this patch introduces read memory
barrier between these reads.

Signed-off-by: Iyappan Subramanian <isubramanian@apm.com>
Signed-off-by: Keyur Chudgar <kchudgar@apm.com>
Tested-by: Mark Langsdorf <mlangsdo@redhat.com>
---
 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
index 83a5028..3622cdb 100644
--- a/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
+++ b/drivers/net/ethernet/apm/xgene/xgene_enet_main.c
@@ -369,6 +369,8 @@ static int xgene_enet_process_ring(struct xgene_enet_desc_ring *ring,
 		if (unlikely(xgene_enet_is_desc_slot_empty(raw_desc)))
 			break;
 
+		/* read fpqnum field after dataaddr field */
+		smp_rmb();
 		if (is_rx_desc(raw_desc))
 			ret = xgene_enet_rx_frame(ring, raw_desc);
 		else
-- 
1.9.1
