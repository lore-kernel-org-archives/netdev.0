From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [v5.2] ucc_slow: Fix to avoid IS_ERR_VALUE abuses and dead code on 64bit systems.
Date: Fri,  5 Aug 2016 14:10:52 +0530
Message-ID: <1470386452-7263-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: qiang.zhao@freescale.com, scottwood@freescale.com,
	viresh.kumar@linaro.org, akpm@linux-foundation.org,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net, arnd@arndb.de,
	Arvind Yadav <arvind.yadav.cs@gmail.com>
To: zajec5@gmail.com, leoli@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from broadband.actcorp.in ([106.51.140.228]:20352 "EHLO
	arvind-ThinkPad-Edge-E431" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S934745AbcHEKdn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Aug 2016 06:33:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

IS_ERR_VALUE() assumes that parameter is an unsigned long.
It can not be used to check if 'unsigned int' is passed insted.
Which tends to reflect an error.
In 64bit architectures sizeof (int) == 4 && sizeof (long) == 8.
IS_ERR_VALUE(x) is ((x) >= (unsigned long)-4095).
IS_ERR_VALUE() of 'unsigned int' is always false because the 32bit
value is zero extended to 64 bits.

Now Problem In UCC slow protocols -: drivers/soc/fsl/qe/ucc_slow.c

        /* Get PRAM base */
        uccs->us_pram_offset =
           qe_muram_alloc(UCC_SLOW_PRAM_SIZE, ALIGNMENT_OF_UCC_SLOW_PRAM);
        if (IS_ERR_VALUE(uccs->us_pram_offset)) {
           printk(KERN_ERR "%s: cannot allocate MURAM for PRAM", __func__);
           ucc_slow_free(uccs);
           return -ENOMEM;
        }
        id = ucc_slow_get_qe_cr_subblock(us_info->ucc_num);
        qe_issue_cmd(QE_ASSIGN_PAGE_TO_DEVICE, id, us_info->protocol,
                     uccs->us_pram_offset);

        uccs->us_pram = qe_muram_addr(uccs->us_pram_offset);

        /* Allocate BDs. */
        uccs->rx_base_offset =
            qe_muram_alloc(us_info->rx_bd_ring_len * sizeof(struct qe_bd),
                                QE_ALIGNMENT_OF_BD);
        if (IS_ERR_VALUE(uccs->rx_base_offset)) {
            printk(KERN_ERR "%s: cannot allocate %u RX BDs\n", __func__,
                        us_info->rx_bd_ring_len);
            uccs->rx_base_offset = 0;
            ucc_slow_free(uccs);
            return -ENOMEM;
        }

        uccs->tx_base_offset =
             qe_muram_alloc(us_info->tx_bd_ring_len * sizeof(struct qe_bd),
                        QE_ALIGNMENT_OF_BD);
        if (IS_ERR_VALUE(uccs->tx_base_offset)) {
             printk(KERN_ERR "%s: cannot allocate TX BDs", __func__);
             uccs->tx_base_offset = 0;
             ucc_slow_free(uccs);
             return -ENOMEM;
        }

qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.
Return value store in a u32 (us_pram_offset, rx_base_offset
and tx_base_offset).If qe_muram_alloc will return any error,
Then IS_ERR_VALUE will always return 0. it'll not call ucc_fast_free
for any failure. Inside 'if code' will be a dead code on 64bit.
Even  qe_muram_addr will return wrong virtual address. Which
can cause an error.
This patch is to avoid this problem on 64bit machine.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 include/soc/fsl/qe/ucc_slow.h | 10 +++++++---
 1 file changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/soc/fsl/qe/ucc_slow.h b/include/soc/fsl/qe/ucc_slow.h
index 6c0573a..fca30a1 100644
--- a/include/soc/fsl/qe/ucc_slow.h
+++ b/include/soc/fsl/qe/ucc_slow.h
@@ -189,7 +189,7 @@ struct ucc_slow_private {
 	struct ucc_slow_info *us_info;
 	struct ucc_slow __iomem *us_regs; /* Ptr to memory map of UCC regs */
 	struct ucc_slow_pram *us_pram;	/* a pointer to the parameter RAM */
-	u32 us_pram_offset;
+	unsigned long us_pram_offset;
 	int enabled_tx;		/* Whether channel is enabled for Tx (ENT) */
 	int enabled_rx;		/* Whether channel is enabled for Rx (ENR) */
 	int stopped_tx;		/* Whether channel has been stopped for Tx
@@ -198,8 +198,12 @@ struct ucc_slow_private {
 	struct list_head confQ;	/* frames passed to chip waiting for tx */
 	u32 first_tx_bd_mask;	/* mask is used in Tx routine to save status
 				   and length for first BD in a frame */
-	u32 tx_base_offset;	/* first BD in Tx BD table offset (In MURAM) */
-	u32 rx_base_offset;	/* first BD in Rx BD table offset (In MURAM) */
+	unsigned long tx_base_offset;	/* first BD in Tx BD table offset
+					 * (In MURAM)
+					 */
+	unsigned long rx_base_offset;	/* first BD in Rx BD table offset
+					 * (In MURAM)
+					 */
 	struct qe_bd *confBd;	/* next BD for confirm after Tx */
 	struct qe_bd *tx_bd;	/* next BD for new Tx request */
 	struct qe_bd *rx_bd;	/* next BD to collect after Rx */
-- 
1.9.1
