From: Sergey Matyukevich <geomatsi@gmail.com>
Subject: [PATCH 2/2] [PATCH] ucc_geth: fix for RX skb buffers recycling
Date: Mon,  7 Jun 2010 22:38:14 +0400
Message-ID: <1275935894-30483-2-git-send-email-geomatsi@gmail.com>
References: <1275935894-30483-1-git-send-email-geomatsi@gmail.com>
Cc: Li Yang <leoli@freescale.com>,
	Anton Vorontsov <avorontsov@ru.mvista.com>,
	Sergey Matyukevich <geomatsi@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:50739 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752622Ab0FGSmp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 14:42:45 -0400
Received: by ewy23 with SMTP id 23so45174ewy.1
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 11:42:43 -0700 (PDT)
In-Reply-To: <1275935894-30483-1-git-send-email-geomatsi@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a proper recycling of skb buffers belonging to RX error
path. The suggested fix actually follows the recycling scheme implemented for
TX skb buffers in the same driver (see 'ucc_geth_tx' function): skb buffers
are checked by 'skb_recycle_check' function and deleted if can't be recycled.

This problem in recycling of skb buffers was discovered by accident in a setup
when ethernet interface on one link end was full-duplex while another was
half-duplex. In this case numerous corrupted frames were received by
full-duplex interface due to late collisions. RX skb buffers with error
frames were not properly recycled, that is why overflow occured from time to
time on the next use of those buffers. Here is example of crush dump:

[    2.587886] Freeing unused kernel memory: 148k init
[    3.563785] PHY: mdio@80103720:00 - Link is Up - 100/Full
[    5.440474] skb_over_panic: text:c01bf710 len:1514 put:1514 head:cf9d4000 data:cf9d4040 tail:0xcf9d466a end:0xcf9d4660 dev:eth0
[    5.452042] ------------[ cut here ]------------
[    5.456654] kernel BUG at net/core/skbuff.c:127!
[    5.461270] Oops: Exception in kernel mode, sig: 5 [#1]
[    5.469099] Modules linked in:
[    5.472155] NIP: c01cd4f4 LR: c01cd4f4 CTR: c01919a4
[    5.477117] REGS: c0325cf0 TRAP: 0700   Not tainted  (2.6.33)
[    5.482854] MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 22048022  XER: 20000000
[    5.489514] TASK = c030b3e8[0] 'swapper' THREAD: c0324000
[    5.494730] GPR00: c01cd4f4 c0325da0 c030b3e8 00000089 00002e7d ffffffff c018ef88 00002e7d
[    5.503126] GPR08: 00000030 c0323290 00002e7d c032b5a8 82048022 1001a100 c02c0340 c026dd84
[    5.511519] GPR16: 00000000 c033c4a8 00000000 00000000 00000001 00000000 cf88357c 0000003f
[    5.519915] GPR24: cf8832e0 cf883000 cf8832e0 cf883550 1c0005ee 000005ea cf96eaf0 cf9d4080
[    5.528518] NIP [c01cd4f4] skb_over_panic+0x48/0x5c
[    5.533395] LR [c01cd4f4] skb_over_panic+0x48/0x5c
[    5.538177] Call Trace:
[    5.540628] [c0325da0] [c01cd4f4] skb_over_panic+0x48/0x5c (unreliable)
[    5.547251] [c0325db0] [c01cec10] skb_put+0x5c/0x60
[    5.552145] [c0325dc0] [c01bf710] ucc_geth_poll+0x404/0x478
[    5.557735] [c0325e20] [c01daef4] net_rx_action+0x9c/0x1a4

Signed-off-by: Sergey Matyukevich <geomatsi@gmail.com>
---
 drivers/net/ucc_geth.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index 538148a..033b7d6 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -3214,8 +3214,13 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
 					   __func__, __LINE__, (u32) skb);
 			if (skb) {
-				skb->data = skb->head + NET_SKB_PAD;
-				__skb_queue_head(&ugeth->rx_recycle, skb);
+				if (skb_queue_len(&ugeth->rx_recycle) < RX_BD_RING_LEN &&
+						skb_recycle_check(skb,
+							ugeth->ug_info->uf_info.max_rx_buf_length +
+							UCC_GETH_RX_DATA_BUF_ALIGNMENT))
+					__skb_queue_head(&ugeth->rx_recycle, skb);
+				else
+					dev_kfree_skb(skb);
 			}
 
 			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
-- 
1.6.2.5

