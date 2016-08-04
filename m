From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [v5.1] ucc_fast: Fix to avoid IS_ERR_VALUE abuses and dead code on
 64bit systems.
Date: Thu,  4 Aug 2016 22:22:43 +0530
Message-ID: <1470329563-5464-1-git-send-email-arvind.yadav.cs@gmail.com>
Cc: qiang.zhao@freescale.com, arnd@arndb.de, viresh.kumar@linaro.org,
 linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
 scottwood@freescale.com, Arvind Yadav <arvind.yadav.cs@gmail.com>,
 akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org, linux@roeck-us.net
To: zajec5@gmail.com,
	leoli@freescale.com
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev/>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
 <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Sender: "Linuxppc-dev"
 <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
List-Id: netdev.vger.kernel.org

IS_ERR_VALUE() assumes that parameter is an unsigned long.
It can not be used to check if 'unsigned int' is passed insted.
Which tends to reflect an error.
In 64bit architectures sizeof (int) == 4 && sizeof (long) == 8.
IS_ERR_VALUE(x) is ((x) >= (unsigned long)-4095).
IS_ERR_VALUE() of 'unsigned int' is always false because the 32bit
value is zero extended to 64 bits.

Now Problem In UCC fast protocols -: drivers/soc/fsl/qe/ucc_fast.c

        /* Allocate memory for Tx Virtual Fifo */
        uccf->ucc_fast_tx_virtual_fifo_base_offset =
          qe_muram_alloc(uf_info->utfs, UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
        if (IS_ERR_VALUE(uccf->ucc_fast_tx_virtual_fifo_base_offset)) {
                printk(KERN_ERR "%s: cannot allocate MURAM for TX FIFO\n",
                        __func__);
                uccf->ucc_fast_tx_virtual_fifo_base_offset = 0;
                ucc_fast_free(uccf);
                return -ENOMEM;
        }

        /* Allocate memory for Rx Virtual Fifo */
        uccf->ucc_fast_rx_virtual_fifo_base_offset =
           qe_muram_alloc(uf_info->urfs +
                           UCC_FAST_RECEIVE_VIRTUAL_FIFO_SIZE_FUDGE_FACTOR,
                           UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
        if (IS_ERR_VALUE(uccf->ucc_fast_rx_virtual_fifo_base_offset)) {
                printk(KERN_ERR "%s: cannot allocate MURAM for RX FIFO\n",
                        __func__);
                uccf->ucc_fast_rx_virtual_fifo_base_offset = 0;
                ucc_fast_free(uccf);
                return -ENOMEM;
        }

qe_muram_alloc (a.k.a. cpm_muram_alloc) returns unsigned long.
Return value store in a u32 (ucc_fast_tx_virtual_fifo_base_offset
and ucc_fast_rx_virtual_fifo_base_offset).If qe_muram_alloc will
return any error, Then IS_ERR_VALUE will always return 0. it'll not
call ucc_fast_free for any failure. Inside 'if code' will be a dead
code on 64bit.
This patch is to avoid this problem on 64bit machine.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 include/soc/fsl/qe/ucc_fast.h | 10 ++++++----
 1 file changed, 6 insertions(+), 4 deletions(-)

diff --git a/include/soc/fsl/qe/ucc_fast.h b/include/soc/fsl/qe/ucc_fast.h
index df8ea79..ada9070 100644
--- a/include/soc/fsl/qe/ucc_fast.h
+++ b/include/soc/fsl/qe/ucc_fast.h
@@ -165,10 +165,12 @@ struct ucc_fast_private {
 	int stopped_tx;		/* Whether channel has been stopped for Tx
 				   (STOP_TX, etc.) */
 	int stopped_rx;		/* Whether channel has been stopped for Rx */
-	u32 ucc_fast_tx_virtual_fifo_base_offset;/* pointer to base of Tx
-						    virtual fifo */
-	u32 ucc_fast_rx_virtual_fifo_base_offset;/* pointer to base of Rx
-						    virtual fifo */
+	unsigned long ucc_fast_tx_virtual_fifo_base_offset;/* pointer to base of
+							    * Tx virtual fifo
+							    */
+	unsigned long ucc_fast_rx_virtual_fifo_base_offset;/* pointer to base of
+							    * Rx virtual fifo
+							    */
 #ifdef STATISTICS
 	u32 tx_frames;		/* Transmitted frames counter. */
 	u32 rx_frames;		/* Received frames counter (only frames
-- 
1.9.1
