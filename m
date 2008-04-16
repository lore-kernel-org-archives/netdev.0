From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: [PATCH v2][POWERPC] qe_lib and ucc_geth: switch to the cpm_muram
	implementation
Date: Wed, 16 Apr 2008 22:22:14 +0400
Message-ID: <20080416182214.GA20056@polina.dev.rtsoft.ru>
References: <20080320173945.GA8446@localhost.localdomain> <20080414181810.GA1038@polina.dev.rtsoft.ru>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	Scott Wood <scottwood@freescale.com>,
	Timur Tabi <timur@freescale.com>
To: Kumar Gala <galak@kernel.crashing.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft2.corbina.net ([85.21.88.2]:60946 "HELO
	mail.dev.rtsoft.ru" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org
	with SMTP id S1750847AbYDPSWR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2008 14:22:17 -0400
Content-Disposition: inline
In-Reply-To: <20080414181810.GA1038@polina.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is very trivial patch. We're transitioning to the cpm_muram_*
calls. That's it.

Less trivial changes:
- BD_SC_* defines were defined in the cpm.h and qe.h, so to avoid redef=
ines
  we remove BD_SC from the qe.h and use cpm.h along with cpm_muram_*
  prototypes;
- qe_muram_dump was unused and thus removed;
- added some code to the cpm_common.c to support legacy QE bindings
  (data-only node name).

Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
---

Oops, this small hunk wormed into the other patch in my series:

>--- a/arch/powerpc/sysdev/cpm_common.c
>+++ b/arch/powerpc/sysdev/cpm_common.c
>@@ -195,7 +195,7 @@ EXPORT_SYMBOL(cpm_muram_addr);
>
> unsigned long cpm_muram_offset(void __iomem *addr)
> {
>-       return addr - muram_vbase;
>+       return addr - (void __iomem *)muram_vbase;
> }
> EXPORT_SYMBOL(cpm_muram_offset);

Without it compile will break:

arch/powerpc/sysdev/cpm_common.c: In function =91cpm_muram_offset=92:
arch/powerpc/sysdev/cpm_common.c:198: error: invalid operands to binary=
 -

=46ixed patch down below.

 arch/powerpc/sysdev/Makefile          |    1 +
 arch/powerpc/sysdev/cpm_common.c      |   16 +++++-
 arch/powerpc/sysdev/qe_lib/qe.c       |   96 +------------------------=
--------
 arch/powerpc/sysdev/qe_lib/ucc_fast.c |    8 ++--
 arch/powerpc/sysdev/qe_lib/ucc_slow.c |   18 +++---
 drivers/net/ucc_geth.c                |   96 ++++++++++++++++---------=
-------
 include/asm-powerpc/cpm.h             |    1 +
 include/asm-powerpc/qe.h              |   29 +----------
 8 files changed, 79 insertions(+), 186 deletions(-)

diff --git a/arch/powerpc/sysdev/Makefile b/arch/powerpc/sysdev/Makefil=
e
index 6d386d0..42b44a1 100644
--- a/arch/powerpc/sysdev/Makefile
+++ b/arch/powerpc/sysdev/Makefile
@@ -40,6 +40,7 @@ endif
 ifeq ($(ARCH),powerpc)
 obj-$(CONFIG_CPM)		+=3D cpm_common.o
 obj-$(CONFIG_CPM2)		+=3D cpm2.o cpm2_pic.o
+obj-$(CONFIG_QUICC_ENGINE)	+=3D cpm_common.o
 obj-$(CONFIG_PPC_DCR)		+=3D dcr.o
 obj-$(CONFIG_8xx)		+=3D mpc8xx_pic.o cpm1.o
 obj-$(CONFIG_UCODE_PATCH)	+=3D micropatch.o
diff --git a/arch/powerpc/sysdev/cpm_common.c b/arch/powerpc/sysdev/cpm=
_common.c
index cb7df2d..9b75d16 100644
--- a/arch/powerpc/sysdev/cpm_common.c
+++ b/arch/powerpc/sysdev/cpm_common.c
@@ -85,9 +85,13 @@ int __init cpm_muram_init(void)
=20
 	np =3D of_find_compatible_node(NULL, NULL, "fsl,cpm-muram-data");
 	if (!np) {
-		printk(KERN_ERR "Cannot find CPM muram data node");
-		ret =3D -ENODEV;
-		goto out;
+		/* try legacy bindings */
+		np =3D of_find_node_by_name(NULL, "data-only");
+		if (!np) {
+			printk(KERN_ERR "Cannot find CPM muram data node");
+			ret =3D -ENODEV;
+			goto out;
+		}
 	}
=20
 	muram_pbase =3D of_translate_address(np, zero);
@@ -189,6 +193,12 @@ void __iomem *cpm_muram_addr(unsigned long offset)
 }
 EXPORT_SYMBOL(cpm_muram_addr);
=20
+unsigned long cpm_muram_offset(void __iomem *addr)
+{
+	return addr - (void __iomem *)muram_vbase;
+}
+EXPORT_SYMBOL(cpm_muram_offset);
+
 /**
  * cpm_muram_dma - turn a muram virtual address into a DMA address
  * @offset: virtual address from cpm_muram_addr() to convert
diff --git a/arch/powerpc/sysdev/qe_lib/qe.c b/arch/powerpc/sysdev/qe_l=
ib/qe.c
index cff550e..4b48094 100644
--- a/arch/powerpc/sysdev/qe_lib/qe.c
+++ b/arch/powerpc/sysdev/qe_lib/qe.c
@@ -35,7 +35,6 @@
 #include <asm/rheap.h>
=20
 static void qe_snums_init(void);
-static void qe_muram_init(void);
 static int qe_sdma_init(void);
=20
 static DEFINE_SPINLOCK(qe_lock);
@@ -99,7 +98,7 @@ void qe_reset(void)
 		     QE_CR_PROTOCOL_UNSPECIFIED, 0);
=20
 	/* Reclaim the MURAM memory for our use. */
-	qe_muram_init();
+	cpm_muram_init();
=20
 	if (qe_sdma_init())
 		panic("sdma init failed!");
@@ -314,7 +313,7 @@ static int qe_sdma_init(void)
=20
 	/* allocate 2 internal temporary buffers (512 bytes size each) for
 	 * the SDMA */
- 	sdma_buf_offset =3D qe_muram_alloc(512 * 2, 4096);
+	sdma_buf_offset =3D cpm_muram_alloc(512 * 2, 4096);
 	if (IS_ERR_VALUE(sdma_buf_offset))
 		return -ENOMEM;
=20
@@ -325,97 +324,6 @@ static int qe_sdma_init(void)
 	return 0;
 }
=20
-/*
- * muram_alloc / muram_free bits.
- */
-static DEFINE_SPINLOCK(qe_muram_lock);
-
-/* 16 blocks should be enough to satisfy all requests
- * until the memory subsystem goes up... */
-static rh_block_t qe_boot_muram_rh_block[16];
-static rh_info_t qe_muram_info;
-
-static void qe_muram_init(void)
-{
-	struct device_node *np;
-	const u32 *address;
-	u64 size;
-	unsigned int flags;
-
-	/* initialize the info header */
-	rh_init(&qe_muram_info, 1,
-		sizeof(qe_boot_muram_rh_block) /
-		sizeof(qe_boot_muram_rh_block[0]), qe_boot_muram_rh_block);
-
-	/* Attach the usable muram area */
-	/* XXX: This is a subset of the available muram. It
-	 * varies with the processor and the microcode patches activated.
-	 */
-	np =3D of_find_compatible_node(NULL, NULL, "fsl,qe-muram-data");
-	if (!np) {
-		np =3D of_find_node_by_name(NULL, "data-only");
-		if (!np) {
-			WARN_ON(1);
-			return;
-		}
-	}
-
-	address =3D of_get_address(np, 0, &size, &flags);
-	WARN_ON(!address);
-
-	of_node_put(np);
-	if (address)
-		rh_attach_region(&qe_muram_info, *address, (int)size);
-}
-
-/* This function returns an index into the MURAM area.
- */
-unsigned long qe_muram_alloc(int size, int align)
-{
-	unsigned long start;
-	unsigned long flags;
-
-	spin_lock_irqsave(&qe_muram_lock, flags);
-	start =3D rh_alloc_align(&qe_muram_info, size, align, "QE");
-	spin_unlock_irqrestore(&qe_muram_lock, flags);
-
-	return start;
-}
-EXPORT_SYMBOL(qe_muram_alloc);
-
-int qe_muram_free(unsigned long offset)
-{
-	int ret;
-	unsigned long flags;
-
-	spin_lock_irqsave(&qe_muram_lock, flags);
-	ret =3D rh_free(&qe_muram_info, offset);
-	spin_unlock_irqrestore(&qe_muram_lock, flags);
-
-	return ret;
-}
-EXPORT_SYMBOL(qe_muram_free);
-
-/* not sure if this is ever needed */
-unsigned long qe_muram_alloc_fixed(unsigned long offset, int size)
-{
-	unsigned long start;
-	unsigned long flags;
-
-	spin_lock_irqsave(&qe_muram_lock, flags);
-	start =3D rh_alloc_fixed(&qe_muram_info, offset, size, "commproc");
-	spin_unlock_irqrestore(&qe_muram_lock, flags);
-
-	return start;
-}
-EXPORT_SYMBOL(qe_muram_alloc_fixed);
-
-void qe_muram_dump(void)
-{
-	rh_dump(&qe_muram_info);
-}
-EXPORT_SYMBOL(qe_muram_dump);
-
 /* The maximum number of RISCs we support */
 #define MAX_QE_RISC     2
=20
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_fast.c b/arch/powerpc/sysde=
v/qe_lib/ucc_fast.c
index bcf88e6..559678d 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_fast.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc_fast.c
@@ -267,7 +267,7 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, s=
truct ucc_fast_private ** ucc
=20
 	/* Allocate memory for Tx Virtual Fifo */
 	uccf->ucc_fast_tx_virtual_fifo_base_offset =3D
-	    qe_muram_alloc(uf_info->utfs, UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
+	    cpm_muram_alloc(uf_info->utfs, UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT)=
;
 	if (IS_ERR_VALUE(uccf->ucc_fast_tx_virtual_fifo_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for TX FIFO\n",
 			__func__);
@@ -278,7 +278,7 @@ int ucc_fast_init(struct ucc_fast_info * uf_info, s=
truct ucc_fast_private ** ucc
=20
 	/* Allocate memory for Rx Virtual Fifo */
 	uccf->ucc_fast_rx_virtual_fifo_base_offset =3D
-		qe_muram_alloc(uf_info->urfs +
+		cpm_muram_alloc(uf_info->urfs +
 			   UCC_FAST_RECEIVE_VIRTUAL_FIFO_SIZE_FUDGE_FACTOR,
 			   UCC_FAST_VIRT_FIFO_REGS_ALIGNMENT);
 	if (IS_ERR_VALUE(uccf->ucc_fast_rx_virtual_fifo_base_offset)) {
@@ -350,10 +350,10 @@ void ucc_fast_free(struct ucc_fast_private * uccf=
)
 		return;
=20
 	if (uccf->ucc_fast_tx_virtual_fifo_base_offset)
-		qe_muram_free(uccf->ucc_fast_tx_virtual_fifo_base_offset);
+		cpm_muram_free(uccf->ucc_fast_tx_virtual_fifo_base_offset);
=20
 	if (uccf->ucc_fast_rx_virtual_fifo_base_offset)
-		qe_muram_free(uccf->ucc_fast_rx_virtual_fifo_base_offset);
+		cpm_muram_free(uccf->ucc_fast_rx_virtual_fifo_base_offset);
=20
 	kfree(uccf);
 }
diff --git a/arch/powerpc/sysdev/qe_lib/ucc_slow.c b/arch/powerpc/sysde=
v/qe_lib/ucc_slow.c
index a578bc7..49e6949 100644
--- a/arch/powerpc/sysdev/qe_lib/ucc_slow.c
+++ b/arch/powerpc/sysdev/qe_lib/ucc_slow.c
@@ -187,7 +187,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, s=
truct ucc_slow_private ** ucc
=20
 	/* Get PRAM base */
 	uccs->us_pram_offset =3D
-		qe_muram_alloc(UCC_SLOW_PRAM_SIZE, ALIGNMENT_OF_UCC_SLOW_PRAM);
+		cpm_muram_alloc(UCC_SLOW_PRAM_SIZE, ALIGNMENT_OF_UCC_SLOW_PRAM);
 	if (IS_ERR_VALUE(uccs->us_pram_offset)) {
 		printk(KERN_ERR "%s: cannot allocate MURAM for PRAM", __func__);
 		ucc_slow_free(uccs);
@@ -197,7 +197,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, s=
truct ucc_slow_private ** ucc
 	qe_issue_cmd(QE_ASSIGN_PAGE_TO_DEVICE, id, us_info->protocol,
 		     uccs->us_pram_offset);
=20
-	uccs->us_pram =3D qe_muram_addr(uccs->us_pram_offset);
+	uccs->us_pram =3D cpm_muram_addr(uccs->us_pram_offset);
=20
 	/* Set UCC to slow type */
 	ret =3D ucc_set_type(us_info->ucc_num, UCC_SPEED_TYPE_SLOW);
@@ -213,7 +213,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, s=
truct ucc_slow_private ** ucc
=20
 	/* Allocate BDs. */
 	uccs->rx_base_offset =3D
-		qe_muram_alloc(us_info->rx_bd_ring_len * sizeof(struct qe_bd),
+		cpm_muram_alloc(us_info->rx_bd_ring_len * sizeof(struct qe_bd),
 				QE_ALIGNMENT_OF_BD);
 	if (IS_ERR_VALUE(uccs->rx_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate %u RX BDs\n", __func__,
@@ -224,7 +224,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, s=
truct ucc_slow_private ** ucc
 	}
=20
 	uccs->tx_base_offset =3D
-		qe_muram_alloc(us_info->tx_bd_ring_len * sizeof(struct qe_bd),
+		cpm_muram_alloc(us_info->tx_bd_ring_len * sizeof(struct qe_bd),
 			QE_ALIGNMENT_OF_BD);
 	if (IS_ERR_VALUE(uccs->tx_base_offset)) {
 		printk(KERN_ERR "%s: cannot allocate TX BDs", __func__);
@@ -234,7 +234,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, s=
truct ucc_slow_private ** ucc
 	}
=20
 	/* Init Tx bds */
-	bd =3D uccs->confBd =3D uccs->tx_bd =3D qe_muram_addr(uccs->tx_base_o=
ffset);
+	bd =3D uccs->confBd =3D uccs->tx_bd =3D cpm_muram_addr(uccs->tx_base_=
offset);
 	for (i =3D 0; i < us_info->tx_bd_ring_len - 1; i++) {
 		/* clear bd buffer */
 		out_be32(&bd->buf, 0);
@@ -247,7 +247,7 @@ int ucc_slow_init(struct ucc_slow_info * us_info, s=
truct ucc_slow_private ** ucc
 	out_be32((u32 *) bd, cpu_to_be32(T_W));
=20
 	/* Init Rx bds */
-	bd =3D uccs->rx_bd =3D qe_muram_addr(uccs->rx_base_offset);
+	bd =3D uccs->rx_bd =3D cpm_muram_addr(uccs->rx_base_offset);
 	for (i =3D 0; i < us_info->rx_bd_ring_len - 1; i++) {
 		/* set bd status and length */
 		out_be32((u32*)bd, 0);
@@ -362,13 +362,13 @@ void ucc_slow_free(struct ucc_slow_private * uccs=
)
 		return;
=20
 	if (uccs->rx_base_offset)
-		qe_muram_free(uccs->rx_base_offset);
+		cpm_muram_free(uccs->rx_base_offset);
=20
 	if (uccs->tx_base_offset)
-		qe_muram_free(uccs->tx_base_offset);
+		cpm_muram_free(uccs->tx_base_offset);
=20
 	if (uccs->us_pram) {
-		qe_muram_free(uccs->us_pram_offset);
+		cpm_muram_free(uccs->us_pram_offset);
 		uccs->us_pram =3D NULL;
 	}
=20
diff --git a/drivers/net/ucc_geth.c b/drivers/net/ucc_geth.c
index ed84182..ba30a25 100644
--- a/drivers/net/ucc_geth.c
+++ b/drivers/net/ucc_geth.c
@@ -299,7 +299,7 @@ static int fill_init_enet_entries(struct ucc_geth_p=
rivate *ugeth,
 			init_enet_offset =3D 0;
 		else {
 			init_enet_offset =3D
-			    qe_muram_alloc(thread_size, thread_alignment);
+			    cpm_muram_alloc(thread_size, thread_alignment);
 			if (IS_ERR_VALUE(init_enet_offset)) {
 				if (netif_msg_ifup(ugeth))
 					ugeth_err("fill_init_enet_entries: Can not allocate DPRAM memory.=
");
@@ -338,7 +338,7 @@ static int return_init_enet_entries(struct ucc_geth=
_private *ugeth,
 				init_enet_offset =3D
 				    (in_be32(p_start) &
 				     ENET_INIT_PARAM_PTR_MASK);
-				qe_muram_free(init_enet_offset);
+				cpm_muram_free(init_enet_offset);
 			}
 			*(p_start++) =3D 0;	/* Just for cosmetics */
 		}
@@ -375,8 +375,8 @@ static int dump_init_enet_entries(struct ucc_geth_p=
rivate *ugeth,
 				ugeth_info("Init enet entry %d:", i);
 				ugeth_info("Base address: 0x%08x",
 					   (u32)
-					   qe_muram_addr(init_enet_offset));
-				mem_disp(qe_muram_addr(init_enet_offset),
+					   cpm_muram_addr(init_enet_offset));
+				mem_disp(cpm_muram_addr(init_enet_offset),
 					 thread_size);
 			}
 			p_start++;
@@ -1085,11 +1085,11 @@ static void dump_regs(struct ucc_geth_private *=
ugeth)
 			ugeth_info("ucode RX Prefetched BDs:");
 			ugeth_info("Base address: 0x%08x",
 				   (u32)
-				   qe_muram_addr(in_be32
+				   cpm_muram_addr(in_be32
 						 (&ugeth->p_rx_bd_qs_tbl[i].
 						  bdbaseptr)));
 			mem_disp((u8 *)
-				 qe_muram_addr(in_be32
+				 cpm_muram_addr(in_be32
 					       (&ugeth->p_rx_bd_qs_tbl[i].
 						bdbaseptr)),
 				 sizeof(struct ucc_geth_rx_prefetched_bds));
@@ -2090,47 +2090,47 @@ static void ucc_geth_memclean(struct ucc_geth_p=
rivate *ugeth)
 	}
=20
 	if (ugeth->p_thread_data_tx) {
-		qe_muram_free(ugeth->thread_dat_tx_offset);
+		cpm_muram_free(ugeth->thread_dat_tx_offset);
 		ugeth->p_thread_data_tx =3D NULL;
 	}
 	if (ugeth->p_thread_data_rx) {
-		qe_muram_free(ugeth->thread_dat_rx_offset);
+		cpm_muram_free(ugeth->thread_dat_rx_offset);
 		ugeth->p_thread_data_rx =3D NULL;
 	}
 	if (ugeth->p_exf_glbl_param) {
-		qe_muram_free(ugeth->exf_glbl_param_offset);
+		cpm_muram_free(ugeth->exf_glbl_param_offset);
 		ugeth->p_exf_glbl_param =3D NULL;
 	}
 	if (ugeth->p_rx_glbl_pram) {
-		qe_muram_free(ugeth->rx_glbl_pram_offset);
+		cpm_muram_free(ugeth->rx_glbl_pram_offset);
 		ugeth->p_rx_glbl_pram =3D NULL;
 	}
 	if (ugeth->p_tx_glbl_pram) {
-		qe_muram_free(ugeth->tx_glbl_pram_offset);
+		cpm_muram_free(ugeth->tx_glbl_pram_offset);
 		ugeth->p_tx_glbl_pram =3D NULL;
 	}
 	if (ugeth->p_send_q_mem_reg) {
-		qe_muram_free(ugeth->send_q_mem_reg_offset);
+		cpm_muram_free(ugeth->send_q_mem_reg_offset);
 		ugeth->p_send_q_mem_reg =3D NULL;
 	}
 	if (ugeth->p_scheduler) {
-		qe_muram_free(ugeth->scheduler_offset);
+		cpm_muram_free(ugeth->scheduler_offset);
 		ugeth->p_scheduler =3D NULL;
 	}
 	if (ugeth->p_tx_fw_statistics_pram) {
-		qe_muram_free(ugeth->tx_fw_statistics_pram_offset);
+		cpm_muram_free(ugeth->tx_fw_statistics_pram_offset);
 		ugeth->p_tx_fw_statistics_pram =3D NULL;
 	}
 	if (ugeth->p_rx_fw_statistics_pram) {
-		qe_muram_free(ugeth->rx_fw_statistics_pram_offset);
+		cpm_muram_free(ugeth->rx_fw_statistics_pram_offset);
 		ugeth->p_rx_fw_statistics_pram =3D NULL;
 	}
 	if (ugeth->p_rx_irq_coalescing_tbl) {
-		qe_muram_free(ugeth->rx_irq_coalescing_tbl_offset);
+		cpm_muram_free(ugeth->rx_irq_coalescing_tbl_offset);
 		ugeth->p_rx_irq_coalescing_tbl =3D NULL;
 	}
 	if (ugeth->p_rx_bd_qs_tbl) {
-		qe_muram_free(ugeth->rx_bd_qs_tbl_offset);
+		cpm_muram_free(ugeth->rx_bd_qs_tbl_offset);
 		ugeth->p_rx_bd_qs_tbl =3D NULL;
 	}
 	if (ugeth->p_init_enet_param_shadow) {
@@ -2171,7 +2171,7 @@ static void ucc_geth_memclean(struct ucc_geth_pri=
vate *ugeth)
 				kfree((void *)ugeth->tx_bd_ring_offset[i]);
 			else if (ugeth->ug_info->uf_info.bd_mem_part =3D=3D
 				 MEM_PART_MURAM)
-				qe_muram_free(ugeth->tx_bd_ring_offset[i]);
+				cpm_muram_free(ugeth->tx_bd_ring_offset[i]);
 			ugeth->p_tx_bd_ring[i] =3D NULL;
 		}
 	}
@@ -2201,7 +2201,7 @@ static void ucc_geth_memclean(struct ucc_geth_pri=
vate *ugeth)
 				kfree((void *)ugeth->rx_bd_ring_offset[i]);
 			else if (ugeth->ug_info->uf_info.bd_mem_part =3D=3D
 				 MEM_PART_MURAM)
-				qe_muram_free(ugeth->rx_bd_ring_offset[i]);
+				cpm_muram_free(ugeth->rx_bd_ring_offset[i]);
 			ugeth->p_rx_bd_ring[i] =3D NULL;
 		}
 	}
@@ -2610,11 +2610,11 @@ static int ucc_geth_startup(struct ucc_geth_pri=
vate *ugeth)
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part =3D=3D MEM_PART_MURAM) {
 			ugeth->tx_bd_ring_offset[j] =3D
-			    qe_muram_alloc(length,
+			    cpm_muram_alloc(length,
 					   UCC_GETH_TX_BD_RING_ALIGNMENT);
 			if (!IS_ERR_VALUE(ugeth->tx_bd_ring_offset[j]))
 				ugeth->p_tx_bd_ring[j] =3D
-				    (u8 *) qe_muram_addr(ugeth->
+				    (u8 *) cpm_muram_addr(ugeth->
 							 tx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_tx_bd_ring[j]) {
@@ -2646,11 +2646,11 @@ static int ucc_geth_startup(struct ucc_geth_pri=
vate *ugeth)
 					align) & ~(align - 1));
 		} else if (uf_info->bd_mem_part =3D=3D MEM_PART_MURAM) {
 			ugeth->rx_bd_ring_offset[j] =3D
-			    qe_muram_alloc(length,
+			    cpm_muram_alloc(length,
 					   UCC_GETH_RX_BD_RING_ALIGNMENT);
 			if (!IS_ERR_VALUE(ugeth->rx_bd_ring_offset[j]))
 				ugeth->p_rx_bd_ring[j] =3D
-				    (u8 *) qe_muram_addr(ugeth->
+				    (u8 *) cpm_muram_addr(ugeth->
 							 rx_bd_ring_offset[j]);
 		}
 		if (!ugeth->p_rx_bd_ring[j]) {
@@ -2733,7 +2733,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	/* Tx global PRAM */
 	/* Allocate global tx parameter RAM page */
 	ugeth->tx_glbl_pram_offset =3D
-	    qe_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
+	    cpm_muram_alloc(sizeof(struct ucc_geth_tx_global_pram),
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
@@ -2744,7 +2744,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		return -ENOMEM;
 	}
 	ugeth->p_tx_glbl_pram =3D
-	    (struct ucc_geth_tx_global_pram *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_tx_global_pram *) cpm_muram_addr(ugeth->
 							tx_glbl_pram_offset);
 	/* Zero out p_tx_glbl_pram */
 	memset(ugeth->p_tx_glbl_pram, 0, sizeof(struct ucc_geth_tx_global_pra=
m));
@@ -2754,7 +2754,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	/* TQPTR */
 	/* Size varies with number of Tx threads */
 	ugeth->thread_dat_tx_offset =3D
-	    qe_muram_alloc(numThreadsTxNumerical *
+	    cpm_muram_alloc(numThreadsTxNumerical *
 			   sizeof(struct ucc_geth_thread_data_tx) +
 			   32 * (numThreadsTxNumerical =3D=3D 1),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
@@ -2768,7 +2768,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	}
=20
 	ugeth->p_thread_data_tx =3D
-	    (struct ucc_geth_thread_data_tx *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_thread_data_tx *) cpm_muram_addr(ugeth->
 							thread_dat_tx_offset);
 	out_be32(&ugeth->p_tx_glbl_pram->tqptr, ugeth->thread_dat_tx_offset);
=20
@@ -2784,7 +2784,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	/* SQPTR */
 	/* Size varies with number of Tx queues */
 	ugeth->send_q_mem_reg_offset =3D
-	    qe_muram_alloc(ug_info->numQueuesTx *
+	    cpm_muram_alloc(ug_info->numQueuesTx *
 			   sizeof(struct ucc_geth_send_queue_qd),
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
@@ -2797,7 +2797,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	}
=20
 	ugeth->p_send_q_mem_reg =3D
-	    (struct ucc_geth_send_queue_mem_region *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_send_queue_mem_region *) cpm_muram_addr(ugeth->
 			send_q_mem_reg_offset);
 	out_be32(&ugeth->p_tx_glbl_pram->sqptr, ugeth->send_q_mem_reg_offset)=
;
=20
@@ -2829,7 +2829,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	if (ug_info->numQueuesTx > 1) {
 	/* scheduler exists only if more than 1 tx queue */
 		ugeth->scheduler_offset =3D
-		    qe_muram_alloc(sizeof(struct ucc_geth_scheduler),
+		    cpm_muram_alloc(sizeof(struct ucc_geth_scheduler),
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
 			if (netif_msg_ifup(ugeth))
@@ -2841,7 +2841,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		}
=20
 		ugeth->p_scheduler =3D
-		    (struct ucc_geth_scheduler *) qe_muram_addr(ugeth->
+		    (struct ucc_geth_scheduler *) cpm_muram_addr(ugeth->
 							   scheduler_offset);
 		out_be32(&ugeth->p_tx_glbl_pram->schedulerbasepointer,
 			 ugeth->scheduler_offset);
@@ -2877,7 +2877,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	if (ug_info->
 	    statisticsMode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_TX) =
{
 		ugeth->tx_fw_statistics_pram_offset =3D
-		    qe_muram_alloc(sizeof
+		    cpm_muram_alloc(sizeof
 				   (struct ucc_geth_tx_firmware_statistics_pram),
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
@@ -2891,7 +2891,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		}
 		ugeth->p_tx_fw_statistics_pram =3D
 		    (struct ucc_geth_tx_firmware_statistics_pram *)
-		    qe_muram_addr(ugeth->tx_fw_statistics_pram_offset);
+		    cpm_muram_addr(ugeth->tx_fw_statistics_pram_offset);
 		/* Zero out p_tx_fw_statistics_pram */
 		memset(ugeth->p_tx_fw_statistics_pram,
 		       0, sizeof(struct ucc_geth_tx_firmware_statistics_pram));
@@ -2919,7 +2919,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	/* Rx global PRAM */
 	/* Allocate global rx parameter RAM page */
 	ugeth->rx_glbl_pram_offset =3D
-	    qe_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
+	    cpm_muram_alloc(sizeof(struct ucc_geth_rx_global_pram),
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
@@ -2930,7 +2930,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		return -ENOMEM;
 	}
 	ugeth->p_rx_glbl_pram =3D
-	    (struct ucc_geth_rx_global_pram *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_rx_global_pram *) cpm_muram_addr(ugeth->
 							rx_glbl_pram_offset);
 	/* Zero out p_rx_glbl_pram */
 	memset(ugeth->p_rx_glbl_pram, 0, sizeof(struct ucc_geth_rx_global_pra=
m));
@@ -2940,7 +2940,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	/* RQPTR */
 	/* Size varies with number of Rx threads */
 	ugeth->thread_dat_rx_offset =3D
-	    qe_muram_alloc(numThreadsRxNumerical *
+	    cpm_muram_alloc(numThreadsRxNumerical *
 			   sizeof(struct ucc_geth_thread_data_rx),
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
@@ -2953,7 +2953,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	}
=20
 	ugeth->p_thread_data_rx =3D
-	    (struct ucc_geth_thread_data_rx *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_thread_data_rx *) cpm_muram_addr(ugeth->
 							thread_dat_rx_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->rqptr, ugeth->thread_dat_rx_offset);
=20
@@ -2964,7 +2964,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	if (ug_info->
 	    statisticsMode & UCC_GETH_STATISTICS_GATHERING_MODE_FIRMWARE_RX) =
{
 		ugeth->rx_fw_statistics_pram_offset =3D
-		    qe_muram_alloc(sizeof
+		    cpm_muram_alloc(sizeof
 				   (struct ucc_geth_rx_firmware_statistics_pram),
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
@@ -2977,7 +2977,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		}
 		ugeth->p_rx_fw_statistics_pram =3D
 		    (struct ucc_geth_rx_firmware_statistics_pram *)
-		    qe_muram_addr(ugeth->rx_fw_statistics_pram_offset);
+		    cpm_muram_addr(ugeth->rx_fw_statistics_pram_offset);
 		/* Zero out p_rx_fw_statistics_pram */
 		memset(ugeth->p_rx_fw_statistics_pram, 0,
 		       sizeof(struct ucc_geth_rx_firmware_statistics_pram));
@@ -2987,7 +2987,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
=20
 	/* Size varies with number of Rx queues */
 	ugeth->rx_irq_coalescing_tbl_offset =3D
-	    qe_muram_alloc(ug_info->numQueuesRx *
+	    cpm_muram_alloc(ug_info->numQueuesRx *
 			   sizeof(struct ucc_geth_rx_interrupt_coalescing_entry)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
@@ -3001,7 +3001,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
=20
 	ugeth->p_rx_irq_coalescing_tbl =3D
 	    (struct ucc_geth_rx_interrupt_coalescing_table *)
-	    qe_muram_addr(ugeth->rx_irq_coalescing_tbl_offset);
+	    cpm_muram_addr(ugeth->rx_irq_coalescing_tbl_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->intcoalescingptr,
 		 ugeth->rx_irq_coalescing_tbl_offset);
=20
@@ -3055,7 +3055,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	/* RBDQPTR */
 	/* Size varies with number of Rx queues */
 	ugeth->rx_bd_qs_tbl_offset =3D
-	    qe_muram_alloc(ug_info->numQueuesRx *
+	    cpm_muram_alloc(ug_info->numQueuesRx *
 			   (sizeof(struct ucc_geth_rx_bd_queues_entry) +
 			    sizeof(struct ucc_geth_rx_prefetched_bds)),
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
@@ -3069,7 +3069,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	}
=20
 	ugeth->p_rx_bd_qs_tbl =3D
-	    (struct ucc_geth_rx_bd_queues_entry *) qe_muram_addr(ugeth->
+	    (struct ucc_geth_rx_bd_queues_entry *) cpm_muram_addr(ugeth->
 				    rx_bd_qs_tbl_offset);
 	out_be32(&ugeth->p_rx_glbl_pram->rbdqptr, ugeth->rx_bd_qs_tbl_offset)=
;
 	/* Zero out p_rx_bd_qs_tbl */
@@ -3148,7 +3148,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		/* Allocate memory for extended filtering Mode Global
 		Parameters */
 		ugeth->exf_glbl_param_offset =3D
-		    qe_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
+		    cpm_muram_alloc(sizeof(struct ucc_geth_exf_global_pram),
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
 			if (netif_msg_ifup(ugeth))
@@ -3160,7 +3160,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		}
=20
 		ugeth->p_exf_glbl_param =3D
-		    (struct ucc_geth_exf_global_pram *) qe_muram_addr(ugeth->
+		    (struct ucc_geth_exf_global_pram *) cpm_muram_addr(ugeth->
 				 exf_glbl_param_offset);
 		out_be32(&ugeth->p_rx_glbl_pram->exfGlobalParam,
 			 ugeth->exf_glbl_param_offset);
@@ -3297,7 +3297,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 	}
=20
 	/* Allocate InitEnet command parameter structure */
-	init_enet_pram_offset =3D qe_muram_alloc(sizeof(struct ucc_geth_init_=
pram), 4);
+	init_enet_pram_offset =3D cpm_muram_alloc(sizeof(struct ucc_geth_init=
_pram), 4);
 	if (IS_ERR_VALUE(init_enet_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
 			ugeth_err
@@ -3307,7 +3307,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		return -ENOMEM;
 	}
 	p_init_enet_pram =3D
-	    (struct ucc_geth_init_pram *) qe_muram_addr(init_enet_pram_offset=
);
+	    (struct ucc_geth_init_pram *) cpm_muram_addr(init_enet_pram_offse=
t);
=20
 	/* Copy shadow InitEnet command parameter structure into PRAM */
 	p_init_enet_pram->resinit1 =3D ugeth->p_init_enet_param_shadow->resin=
it1;
@@ -3336,7 +3336,7 @@ static int ucc_geth_startup(struct ucc_geth_priva=
te *ugeth)
 		     init_enet_pram_offset);
=20
 	/* Free InitEnet command parameter */
-	qe_muram_free(init_enet_pram_offset);
+	cpm_muram_free(init_enet_pram_offset);
=20
 	return 0;
 }
diff --git a/include/asm-powerpc/cpm.h b/include/asm-powerpc/cpm.h
index ede38ff..63a5533 100644
--- a/include/asm-powerpc/cpm.h
+++ b/include/asm-powerpc/cpm.h
@@ -96,6 +96,7 @@ unsigned long cpm_muram_alloc(unsigned long size, uns=
igned long align);
 int cpm_muram_free(unsigned long offset);
 unsigned long cpm_muram_alloc_fixed(unsigned long offset, unsigned lon=
g size);
 void __iomem *cpm_muram_addr(unsigned long offset);
+unsigned long cpm_muram_offset(void __iomem *addr);
 dma_addr_t cpm_muram_dma(void __iomem *addr);
 int cpm_command(u32 command, u8 opcode);
=20
diff --git a/include/asm-powerpc/qe.h b/include/asm-powerpc/qe.h
index c3be6e2..54864dd 100644
--- a/include/asm-powerpc/qe.h
+++ b/include/asm-powerpc/qe.h
@@ -16,6 +16,7 @@
 #define _ASM_POWERPC_QE_H
 #ifdef __KERNEL__
=20
+#include <asm/cpm.h>
 #include <asm/immap_qe.h>
=20
 #define QE_NUM_OF_SNUM	28
@@ -89,20 +90,6 @@ unsigned int qe_get_brg_clk(void);
 int qe_setbrg(enum qe_clock brg, unsigned int rate, unsigned int multi=
plier);
 int qe_get_snum(void);
 void qe_put_snum(u8 snum);
-unsigned long qe_muram_alloc(int size, int align);
-int qe_muram_free(unsigned long offset);
-unsigned long qe_muram_alloc_fixed(unsigned long offset, int size);
-void qe_muram_dump(void);
-
-static inline void __iomem *qe_muram_addr(unsigned long offset)
-{
-	return (void __iomem *)&qe_immr->muram[offset];
-}
-
-static inline unsigned long qe_muram_offset(void __iomem *addr)
-{
-	return addr - (void __iomem *)qe_immr->muram;
-}
=20
 /* Structure that defines QE firmware binary files.
  *
@@ -166,20 +153,6 @@ struct qe_bd {
 #define BD_STATUS_MASK	0xffff0000
 #define BD_LENGTH_MASK	0x0000ffff
=20
-#define BD_SC_EMPTY	0x8000	/* Receive is empty */
-#define BD_SC_READY	0x8000	/* Transmit is ready */
-#define BD_SC_WRAP	0x2000	/* Last buffer descriptor */
-#define BD_SC_INTRPT	0x1000	/* Interrupt on change */
-#define BD_SC_LAST	0x0800	/* Last buffer in frame */
-#define BD_SC_CM	0x0200	/* Continous mode */
-#define BD_SC_ID	0x0100	/* Rec'd too many idles */
-#define BD_SC_P		0x0100	/* xmt preamble */
-#define BD_SC_BR	0x0020	/* Break received */
-#define BD_SC_FR	0x0010	/* Framing error */
-#define BD_SC_PR	0x0008	/* Parity error */
-#define BD_SC_OV	0x0002	/* Overrun */
-#define BD_SC_CD	0x0001	/* ?? */
-
 /* Alignment */
 #define QE_INTR_TABLE_ALIGN	16	/* ??? */
 #define QE_ALIGNMENT_OF_BD	8
--=20
1.5.5

