From: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
Subject: [PATCH net 8/9] qlcnic: Fix releasing of Tx frag which was never mapped.
Date: Fri, 19 Jul 2013 16:56:33 -0400
Message-ID: <1374267394-27697-9-git-send-email-sucheta.chakraborty@qlogic.com>
References: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe005.messaging.microsoft.com ([65.55.88.15]:36348 "EHLO
	tx2outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752034Ab3GSVYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 17:24:05 -0400
In-Reply-To: <1374267394-27697-1-git-send-email-sucheta.chakraborty@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Driver was freeing Tx frag which was never mapped before which
  result into panic as kernel was unable to handle paging request.

BUG: unable to handle kernel paging request at ffffc9002552a000
IP: [<ffffffffa05ed762>] qlcnic_release_tx_buffers+0x72/0x170 [qlcnic]
PGD 87fc15067 PUD 47febf067 PMD 4758c5067 PTE 0
Oops: 0000 [#1] SMP

crash> bt
PID: 27343  TASK: ffff8802a5de8080  CPU: 27  COMMAND: "ifconfig"
   [ffff8802a34b3850] machine_kexec at ffffffff81035b7b
   [ffff8802a34b38b0] crash_kexec at ffffffff810c0db2
   [ffff8802a34b3980] oops_end at ffffffff815111d0
   [ffff8802a34b39b0] no_context at ffffffff81046bfb
   [ffff8802a34b3a00] __bad_area_nosemaphore at ffffffff81046e85
   [ffff8802a34b3a50] bad_area_nosemaphore at ffffffff81046f53
   [ffff8802a34b3a60] __do_page_fault at ffffffff810476b1
   [ffff8802a34b3b80] do_page_fault at ffffffff8151311e
   [ffff8802a34b3bb0] page_fault at ffffffff815104d5
    [exception RIP: qlcnic_release_tx_buffers+114]
    RIP: ffffffffa05ed762  RSP: ffff8802a34b3c68  RFLAGS: 00010246
    RAX: ffff88087989c000  RBX: ffffc90025529ff8  RCX: 0000000000000001
    RDX: 0000000000000013  RSI: 0000000000000013  RDI: 0000000000000000
    RBP: ffff8802a34b3ca8   R8: 0000000000000000   R9: 0000000000000000
    R10: 000000000000000c  R11: 0000000000000000  R12: 0000000000000012
    R13: ffffc90025529ec0  R14: ffff880761e876e0  R15: 00000000000003ff
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
   [ffff8802a34b3cb0] __qlcnic_down at ffffffffa05e8b15 [qlcnic]
   [ffff8802a34b3d00] qlcnic_close at ffffffffa05e8b78 [qlcnic]
   [ffff8802a34b3d10] dev_close at ffffffff81449d81
   [ffff8802a34b3d30] dev_change_flags at ffffffff814495c1

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Signed-off-by: Sucheta Chakraborty <sucheta.chakraborty@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
index d28336f..a202309 100644
--- a/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
+++ b/drivers/net/ethernet/qlogic/qlcnic/qlcnic_init.c
@@ -142,7 +142,7 @@ void qlcnic_release_tx_buffers(struct qlcnic_adapter *adapter)
 					 buffrag->length, PCI_DMA_TODEVICE);
 			buffrag->dma = 0ULL;
 		}
-		for (j = 0; j < cmd_buf->frag_count; j++) {
+		for (j = 1; j < cmd_buf->frag_count; j++) {
 			buffrag++;
 			if (buffrag->dma) {
 				pci_unmap_page(adapter->pdev, buffrag->dma,
-- 
1.7.1
