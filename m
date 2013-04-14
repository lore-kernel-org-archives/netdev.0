From: Joe Perches <joe@perches.com>
Subject: [PATCH 3/3] ucc_geth: Convert ugeth_<level> to pr_<level>
Date: Sat, 13 Apr 2013 22:03:19 -0700
Message-ID: <2efb0df7c12d82e9e769b2630b2a692443061aac.1365915548.git.joe@perches.com>
References: <cover.1365915548.git.joe@perches.com>
Cc: Fabio Estevam <festevam@gmail.com>, linuxppc-dev@lists.ozlabs.org,
	Li Yang <leoli@freescale.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1365915548.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Remove unnecessary macros that duplicate generic
kernel functions.

When a struct net_device is available:

Convert printks to netdev_<level>
Convert netif_msg_<foo> and ugeth_<level> to netif_<level>

Add pr_fmt.  Standardize on newlines at end of format.
Remove some duplicated newlines from output.
Coalesce formats.

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/ethernet/freescale/ucc_geth.c         | 881 ++++++++++------------
 drivers/net/ethernet/freescale/ucc_geth_ethtool.c |  24 +-
 2 files changed, 403 insertions(+), 502 deletions(-)

diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
index 0a70bb5..e04c598 100644
--- a/drivers/net/ethernet/freescale/ucc_geth.c
+++ b/drivers/net/ethernet/freescale/ucc_geth.c
@@ -12,6 +12,9 @@
  * Free Software Foundation;  either version 2 of the  License, or (at your
  * option) any later version.
  */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
 #include <linux/kernel.h>
 #include <linux/init.h>
 #include <linux/errno.h>
@@ -50,12 +53,6 @@
 
 #define ugeth_dbg(format, arg...)            \
         ugeth_printk(KERN_DEBUG , format , ## arg)
-#define ugeth_err(format, arg...)            \
-        ugeth_printk(KERN_ERR , format , ## arg)
-#define ugeth_info(format, arg...)           \
-        ugeth_printk(KERN_INFO , format , ## arg)
-#define ugeth_warn(format, arg...)           \
-        ugeth_printk(KERN_WARNING , format , ## arg)
 
 #ifdef UGETH_VERBOSE_DEBUG
 #define ugeth_vdbg ugeth_dbg
@@ -281,7 +278,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 	for (i = 0; i < num_entries; i++) {
 		if ((snum = qe_get_snum()) < 0) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err("fill_init_enet_entries: Can not get SNUM.");
+				pr_err("Can not get SNUM\n");
 			return snum;
 		}
 		if ((i == 0) && skip_page_for_first_entry)
@@ -292,7 +289,7 @@ static int fill_init_enet_entries(struct ucc_geth_private *ugeth,
 			    qe_muram_alloc(thread_size, thread_alignment);
 			if (IS_ERR_VALUE(init_enet_offset)) {
 				if (netif_msg_ifup(ugeth))
-					ugeth_err("fill_init_enet_entries: Can not allocate DPRAM memory.");
+					pr_err("Can not allocate DPRAM memory\n");
 				qe_put_snum((u8) snum);
 				return -ENOMEM;
 			}
@@ -365,10 +362,9 @@ static int dump_init_enet_entries(struct ucc_geth_private *ugeth,
 				init_enet_offset =
 				    (in_be32(p_start) &
 				     ENET_INIT_PARAM_PTR_MASK);
-				ugeth_info("Init enet entry %d:", i);
-				ugeth_info("Base address: 0x%08x",
-					   (u32)
-					   qe_muram_addr(init_enet_offset));
+				pr_info("Init enet entry %d:\n", i);
+				pr_info("Base address: 0x%08x\n",
+					(u32)qe_muram_addr(init_enet_offset));
 				mem_disp(qe_muram_addr(init_enet_offset),
 					 thread_size);
 			}
@@ -396,8 +392,8 @@ static int hw_clear_addr_in_paddr(struct ucc_geth_private *ugeth, u8 paddr_num)
 {
 	struct ucc_geth_82xx_address_filtering_pram __iomem *p_82xx_addr_filt;
 
-	if (!(paddr_num < NUM_OF_PADDRS)) {
-		ugeth_warn("%s: Illagel paddr_num.", __func__);
+	if (paddr_num >= NUM_OF_PADDRS) {
+		pr_warn("%s: Invalid paddr_num: %u\n", __func__, paddr_num);
 		return -EINVAL;
 	}
 
@@ -573,7 +569,7 @@ static void dump_bds(struct ucc_geth_private *ugeth)
 			length =
 			    (ugeth->ug_info->bdRingLenTx[i] *
 			     sizeof(struct qe_bd));
-			ugeth_info("TX BDs[%d]", i);
+			pr_info("TX BDs[%d]\n", i);
 			mem_disp(ugeth->p_tx_bd_ring[i], length);
 		}
 	}
@@ -582,7 +578,7 @@ static void dump_bds(struct ucc_geth_private *ugeth)
 			length =
 			    (ugeth->ug_info->bdRingLenRx[i] *
 			     sizeof(struct qe_bd));
-			ugeth_info("RX BDs[%d]", i);
+			pr_info("RX BDs[%d]\n", i);
 			mem_disp(ugeth->p_rx_bd_ring[i], length);
 		}
 	}
@@ -592,93 +588,93 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 {
 	int i;
 
-	ugeth_info("UCC%d Geth registers:", ugeth->ug_info->uf_info.ucc_num + 1);
-	ugeth_info("Base address: 0x%08x", (u32) ugeth->ug_regs);
-
-	ugeth_info("maccfg1    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->maccfg1,
-		   in_be32(&ugeth->ug_regs->maccfg1));
-	ugeth_info("maccfg2    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->maccfg2,
-		   in_be32(&ugeth->ug_regs->maccfg2));
-	ugeth_info("ipgifg     : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->ipgifg,
-		   in_be32(&ugeth->ug_regs->ipgifg));
-	ugeth_info("hafdup     : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->hafdup,
-		   in_be32(&ugeth->ug_regs->hafdup));
-	ugeth_info("ifctl      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->ifctl,
-		   in_be32(&ugeth->ug_regs->ifctl));
-	ugeth_info("ifstat     : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->ifstat,
-		   in_be32(&ugeth->ug_regs->ifstat));
-	ugeth_info("macstnaddr1: addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->macstnaddr1,
-		   in_be32(&ugeth->ug_regs->macstnaddr1));
-	ugeth_info("macstnaddr2: addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->macstnaddr2,
-		   in_be32(&ugeth->ug_regs->macstnaddr2));
-	ugeth_info("uempr      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->uempr,
-		   in_be32(&ugeth->ug_regs->uempr));
-	ugeth_info("utbipar    : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->utbipar,
-		   in_be32(&ugeth->ug_regs->utbipar));
-	ugeth_info("uescr      : addr - 0x%08x, val - 0x%04x",
-		   (u32) & ugeth->ug_regs->uescr,
-		   in_be16(&ugeth->ug_regs->uescr));
-	ugeth_info("tx64       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->tx64,
-		   in_be32(&ugeth->ug_regs->tx64));
-	ugeth_info("tx127      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->tx127,
-		   in_be32(&ugeth->ug_regs->tx127));
-	ugeth_info("tx255      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->tx255,
-		   in_be32(&ugeth->ug_regs->tx255));
-	ugeth_info("rx64       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rx64,
-		   in_be32(&ugeth->ug_regs->rx64));
-	ugeth_info("rx127      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rx127,
-		   in_be32(&ugeth->ug_regs->rx127));
-	ugeth_info("rx255      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rx255,
-		   in_be32(&ugeth->ug_regs->rx255));
-	ugeth_info("txok       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->txok,
-		   in_be32(&ugeth->ug_regs->txok));
-	ugeth_info("txcf       : addr - 0x%08x, val - 0x%04x",
-		   (u32) & ugeth->ug_regs->txcf,
-		   in_be16(&ugeth->ug_regs->txcf));
-	ugeth_info("tmca       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->tmca,
-		   in_be32(&ugeth->ug_regs->tmca));
-	ugeth_info("tbca       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->tbca,
-		   in_be32(&ugeth->ug_regs->tbca));
-	ugeth_info("rxfok      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rxfok,
-		   in_be32(&ugeth->ug_regs->rxfok));
-	ugeth_info("rxbok      : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rxbok,
-		   in_be32(&ugeth->ug_regs->rxbok));
-	ugeth_info("rbyt       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rbyt,
-		   in_be32(&ugeth->ug_regs->rbyt));
-	ugeth_info("rmca       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rmca,
-		   in_be32(&ugeth->ug_regs->rmca));
-	ugeth_info("rbca       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->rbca,
-		   in_be32(&ugeth->ug_regs->rbca));
-	ugeth_info("scar       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->scar,
-		   in_be32(&ugeth->ug_regs->scar));
-	ugeth_info("scam       : addr - 0x%08x, val - 0x%08x",
-		   (u32) & ugeth->ug_regs->scam,
-		   in_be32(&ugeth->ug_regs->scam));
+	pr_info("UCC%d Geth registers:\n", ugeth->ug_info->uf_info.ucc_num + 1);
+	pr_info("Base address: 0x%08x\n", (u32)ugeth->ug_regs);
+
+	pr_info("maccfg1    : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->maccfg1,
+		in_be32(&ugeth->ug_regs->maccfg1));
+	pr_info("maccfg2    : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->maccfg2,
+		in_be32(&ugeth->ug_regs->maccfg2));
+	pr_info("ipgifg     : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->ipgifg,
+		in_be32(&ugeth->ug_regs->ipgifg));
+	pr_info("hafdup     : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->hafdup,
+		in_be32(&ugeth->ug_regs->hafdup));
+	pr_info("ifctl      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->ifctl,
+		in_be32(&ugeth->ug_regs->ifctl));
+	pr_info("ifstat     : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->ifstat,
+		in_be32(&ugeth->ug_regs->ifstat));
+	pr_info("macstnaddr1: addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->macstnaddr1,
+		in_be32(&ugeth->ug_regs->macstnaddr1));
+	pr_info("macstnaddr2: addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->macstnaddr2,
+		in_be32(&ugeth->ug_regs->macstnaddr2));
+	pr_info("uempr      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->uempr,
+		in_be32(&ugeth->ug_regs->uempr));
+	pr_info("utbipar    : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->utbipar,
+		in_be32(&ugeth->ug_regs->utbipar));
+	pr_info("uescr      : addr - 0x%08x, val - 0x%04x\n",
+		(u32)&ugeth->ug_regs->uescr,
+		in_be16(&ugeth->ug_regs->uescr));
+	pr_info("tx64       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->tx64,
+		in_be32(&ugeth->ug_regs->tx64));
+	pr_info("tx127      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->tx127,
+		in_be32(&ugeth->ug_regs->tx127));
+	pr_info("tx255      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->tx255,
+		in_be32(&ugeth->ug_regs->tx255));
+	pr_info("rx64       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rx64,
+		in_be32(&ugeth->ug_regs->rx64));
+	pr_info("rx127      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rx127,
+		in_be32(&ugeth->ug_regs->rx127));
+	pr_info("rx255      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rx255,
+		in_be32(&ugeth->ug_regs->rx255));
+	pr_info("txok       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->txok,
+		in_be32(&ugeth->ug_regs->txok));
+	pr_info("txcf       : addr - 0x%08x, val - 0x%04x\n",
+		(u32)&ugeth->ug_regs->txcf,
+		in_be16(&ugeth->ug_regs->txcf));
+	pr_info("tmca       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->tmca,
+		in_be32(&ugeth->ug_regs->tmca));
+	pr_info("tbca       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->tbca,
+		in_be32(&ugeth->ug_regs->tbca));
+	pr_info("rxfok      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rxfok,
+		in_be32(&ugeth->ug_regs->rxfok));
+	pr_info("rxbok      : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rxbok,
+		in_be32(&ugeth->ug_regs->rxbok));
+	pr_info("rbyt       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rbyt,
+		in_be32(&ugeth->ug_regs->rbyt));
+	pr_info("rmca       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rmca,
+		in_be32(&ugeth->ug_regs->rmca));
+	pr_info("rbca       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->rbca,
+		in_be32(&ugeth->ug_regs->rbca));
+	pr_info("scar       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->scar,
+		in_be32(&ugeth->ug_regs->scar));
+	pr_info("scam       : addr - 0x%08x, val - 0x%08x\n",
+		(u32)&ugeth->ug_regs->scam,
+		in_be32(&ugeth->ug_regs->scam));
 
 	if (ugeth->p_thread_data_tx) {
 		int numThreadsTxNumerical;
@@ -703,13 +699,13 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 			break;
 		}
 
-		ugeth_info("Thread data TXs:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_thread_data_tx);
+		pr_info("Thread data TXs:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32)ugeth->p_thread_data_tx);
 		for (i = 0; i < numThreadsTxNumerical; i++) {
-			ugeth_info("Thread data TX[%d]:", i);
-			ugeth_info("Base address: 0x%08x",
-				   (u32) & ugeth->p_thread_data_tx[i]);
+			pr_info("Thread data TX[%d]:\n", i);
+			pr_info("Base address: 0x%08x\n",
+				(u32)&ugeth->p_thread_data_tx[i]);
 			mem_disp((u8 *) & ugeth->p_thread_data_tx[i],
 				 sizeof(struct ucc_geth_thread_data_tx));
 		}
@@ -737,270 +733,260 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 			break;
 		}
 
-		ugeth_info("Thread data RX:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_thread_data_rx);
+		pr_info("Thread data RX:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32)ugeth->p_thread_data_rx);
 		for (i = 0; i < numThreadsRxNumerical; i++) {
-			ugeth_info("Thread data RX[%d]:", i);
-			ugeth_info("Base address: 0x%08x",
-				   (u32) & ugeth->p_thread_data_rx[i]);
+			pr_info("Thread data RX[%d]:\n", i);
+			pr_info("Base address: 0x%08x\n",
+				(u32)&ugeth->p_thread_data_rx[i]);
 			mem_disp((u8 *) & ugeth->p_thread_data_rx[i],
 				 sizeof(struct ucc_geth_thread_data_rx));
 		}
 	}
 	if (ugeth->p_exf_glbl_param) {
-		ugeth_info("EXF global param:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_exf_glbl_param);
+		pr_info("EXF global param:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32)ugeth->p_exf_glbl_param);
 		mem_disp((u8 *) ugeth->p_exf_glbl_param,
 			 sizeof(*ugeth->p_exf_glbl_param));
 	}
 	if (ugeth->p_tx_glbl_pram) {
-		ugeth_info("TX global param:");
-		ugeth_info("Base address: 0x%08x", (u32) ugeth->p_tx_glbl_pram);
-		ugeth_info("temoder      : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_tx_glbl_pram->temoder,
-			   in_be16(&ugeth->p_tx_glbl_pram->temoder));
-		ugeth_info("sqptr        : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->sqptr,
-			   in_be32(&ugeth->p_tx_glbl_pram->sqptr));
-		ugeth_info("schedulerbasepointer: addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->schedulerbasepointer,
-			   in_be32(&ugeth->p_tx_glbl_pram->
-				   schedulerbasepointer));
-		ugeth_info("txrmonbaseptr: addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->txrmonbaseptr,
-			   in_be32(&ugeth->p_tx_glbl_pram->txrmonbaseptr));
-		ugeth_info("tstate       : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->tstate,
-			   in_be32(&ugeth->p_tx_glbl_pram->tstate));
-		ugeth_info("iphoffset[0] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[0],
-			   ugeth->p_tx_glbl_pram->iphoffset[0]);
-		ugeth_info("iphoffset[1] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[1],
-			   ugeth->p_tx_glbl_pram->iphoffset[1]);
-		ugeth_info("iphoffset[2] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[2],
-			   ugeth->p_tx_glbl_pram->iphoffset[2]);
-		ugeth_info("iphoffset[3] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[3],
-			   ugeth->p_tx_glbl_pram->iphoffset[3]);
-		ugeth_info("iphoffset[4] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[4],
-			   ugeth->p_tx_glbl_pram->iphoffset[4]);
-		ugeth_info("iphoffset[5] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[5],
-			   ugeth->p_tx_glbl_pram->iphoffset[5]);
-		ugeth_info("iphoffset[6] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[6],
-			   ugeth->p_tx_glbl_pram->iphoffset[6]);
-		ugeth_info("iphoffset[7] : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_tx_glbl_pram->iphoffset[7],
-			   ugeth->p_tx_glbl_pram->iphoffset[7]);
-		ugeth_info("vtagtable[0] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[0],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[0]));
-		ugeth_info("vtagtable[1] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[1],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[1]));
-		ugeth_info("vtagtable[2] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[2],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[2]));
-		ugeth_info("vtagtable[3] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[3],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[3]));
-		ugeth_info("vtagtable[4] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[4],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[4]));
-		ugeth_info("vtagtable[5] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[5],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[5]));
-		ugeth_info("vtagtable[6] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[6],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[6]));
-		ugeth_info("vtagtable[7] : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->vtagtable[7],
-			   in_be32(&ugeth->p_tx_glbl_pram->vtagtable[7]));
-		ugeth_info("tqptr        : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_tx_glbl_pram->tqptr,
-			   in_be32(&ugeth->p_tx_glbl_pram->tqptr));
+		pr_info("TX global param:\n");
+		pr_info("Base address: 0x%08x\n", (u32)ugeth->p_tx_glbl_pram);
+		pr_info("temoder      : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_tx_glbl_pram->temoder,
+			in_be16(&ugeth->p_tx_glbl_pram->temoder));
+	       pr_info("sqptr        : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->sqptr,
+			in_be32(&ugeth->p_tx_glbl_pram->sqptr));
+		pr_info("schedulerbasepointer: addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->schedulerbasepointer,
+			in_be32(&ugeth->p_tx_glbl_pram->schedulerbasepointer));
+		pr_info("txrmonbaseptr: addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->txrmonbaseptr,
+			in_be32(&ugeth->p_tx_glbl_pram->txrmonbaseptr));
+		pr_info("tstate       : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->tstate,
+			in_be32(&ugeth->p_tx_glbl_pram->tstate));
+		pr_info("iphoffset[0] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[0],
+			ugeth->p_tx_glbl_pram->iphoffset[0]);
+		pr_info("iphoffset[1] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[1],
+			ugeth->p_tx_glbl_pram->iphoffset[1]);
+		pr_info("iphoffset[2] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[2],
+			ugeth->p_tx_glbl_pram->iphoffset[2]);
+		pr_info("iphoffset[3] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[3],
+			ugeth->p_tx_glbl_pram->iphoffset[3]);
+		pr_info("iphoffset[4] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[4],
+			ugeth->p_tx_glbl_pram->iphoffset[4]);
+		pr_info("iphoffset[5] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[5],
+			ugeth->p_tx_glbl_pram->iphoffset[5]);
+		pr_info("iphoffset[6] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[6],
+			ugeth->p_tx_glbl_pram->iphoffset[6]);
+		pr_info("iphoffset[7] : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_tx_glbl_pram->iphoffset[7],
+			ugeth->p_tx_glbl_pram->iphoffset[7]);
+		pr_info("vtagtable[0] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[0],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[0]));
+		pr_info("vtagtable[1] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[1],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[1]));
+		pr_info("vtagtable[2] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[2],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[2]));
+		pr_info("vtagtable[3] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[3],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[3]));
+		pr_info("vtagtable[4] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[4],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[4]));
+		pr_info("vtagtable[5] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[5],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[5]));
+		pr_info("vtagtable[6] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[6],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[6]));
+		pr_info("vtagtable[7] : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->vtagtable[7],
+			in_be32(&ugeth->p_tx_glbl_pram->vtagtable[7]));
+		pr_info("tqptr        : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_tx_glbl_pram->tqptr,
+			in_be32(&ugeth->p_tx_glbl_pram->tqptr));
 	}
 	if (ugeth->p_rx_glbl_pram) {
-		ugeth_info("RX global param:");
-		ugeth_info("Base address: 0x%08x", (u32) ugeth->p_rx_glbl_pram);
-		ugeth_info("remoder         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->remoder,
-			   in_be32(&ugeth->p_rx_glbl_pram->remoder));
-		ugeth_info("rqptr           : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->rqptr,
-			   in_be32(&ugeth->p_rx_glbl_pram->rqptr));
-		ugeth_info("typeorlen       : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->typeorlen,
-			   in_be16(&ugeth->p_rx_glbl_pram->typeorlen));
-		ugeth_info("rxgstpack       : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_rx_glbl_pram->rxgstpack,
-			   ugeth->p_rx_glbl_pram->rxgstpack);
-		ugeth_info("rxrmonbaseptr   : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->rxrmonbaseptr,
-			   in_be32(&ugeth->p_rx_glbl_pram->rxrmonbaseptr));
-		ugeth_info("intcoalescingptr: addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->intcoalescingptr,
-			   in_be32(&ugeth->p_rx_glbl_pram->intcoalescingptr));
-		ugeth_info("rstate          : addr - 0x%08x, val - 0x%02x",
-			   (u32) & ugeth->p_rx_glbl_pram->rstate,
-			   ugeth->p_rx_glbl_pram->rstate);
-		ugeth_info("mrblr           : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->mrblr,
-			   in_be16(&ugeth->p_rx_glbl_pram->mrblr));
-		ugeth_info("rbdqptr         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->rbdqptr,
-			   in_be32(&ugeth->p_rx_glbl_pram->rbdqptr));
-		ugeth_info("mflr            : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->mflr,
-			   in_be16(&ugeth->p_rx_glbl_pram->mflr));
-		ugeth_info("minflr          : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->minflr,
-			   in_be16(&ugeth->p_rx_glbl_pram->minflr));
-		ugeth_info("maxd1           : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->maxd1,
-			   in_be16(&ugeth->p_rx_glbl_pram->maxd1));
-		ugeth_info("maxd2           : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->maxd2,
-			   in_be16(&ugeth->p_rx_glbl_pram->maxd2));
-		ugeth_info("ecamptr         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->ecamptr,
-			   in_be32(&ugeth->p_rx_glbl_pram->ecamptr));
-		ugeth_info("l2qt            : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l2qt,
-			   in_be32(&ugeth->p_rx_glbl_pram->l2qt));
-		ugeth_info("l3qt[0]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[0],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[0]));
-		ugeth_info("l3qt[1]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[1],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[1]));
-		ugeth_info("l3qt[2]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[2],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[2]));
-		ugeth_info("l3qt[3]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[3],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[3]));
-		ugeth_info("l3qt[4]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[4],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[4]));
-		ugeth_info("l3qt[5]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[5],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[5]));
-		ugeth_info("l3qt[6]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[6],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[6]));
-		ugeth_info("l3qt[7]         : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->l3qt[7],
-			   in_be32(&ugeth->p_rx_glbl_pram->l3qt[7]));
-		ugeth_info("vlantype        : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->vlantype,
-			   in_be16(&ugeth->p_rx_glbl_pram->vlantype));
-		ugeth_info("vlantci         : addr - 0x%08x, val - 0x%04x",
-			   (u32) & ugeth->p_rx_glbl_pram->vlantci,
-			   in_be16(&ugeth->p_rx_glbl_pram->vlantci));
+		pr_info("RX global param:\n");
+		pr_info("Base address: 0x%08x\n", (u32)ugeth->p_rx_glbl_pram);
+		pr_info("remoder         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->remoder,
+			in_be32(&ugeth->p_rx_glbl_pram->remoder));
+		pr_info("rqptr           : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->rqptr,
+			in_be32(&ugeth->p_rx_glbl_pram->rqptr));
+		pr_info("typeorlen       : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->typeorlen,
+			in_be16(&ugeth->p_rx_glbl_pram->typeorlen));
+		pr_info("rxgstpack       : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_rx_glbl_pram->rxgstpack,
+			ugeth->p_rx_glbl_pram->rxgstpack);
+		pr_info("rxrmonbaseptr   : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->rxrmonbaseptr,
+			in_be32(&ugeth->p_rx_glbl_pram->rxrmonbaseptr));
+		pr_info("intcoalescingptr: addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->intcoalescingptr,
+			in_be32(&ugeth->p_rx_glbl_pram->intcoalescingptr));
+		pr_info("rstate          : addr - 0x%08x, val - 0x%02x\n",
+			(u32)&ugeth->p_rx_glbl_pram->rstate,
+			ugeth->p_rx_glbl_pram->rstate);
+		pr_info("mrblr           : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->mrblr,
+			in_be16(&ugeth->p_rx_glbl_pram->mrblr));
+		pr_info("rbdqptr         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->rbdqptr,
+			in_be32(&ugeth->p_rx_glbl_pram->rbdqptr));
+		pr_info("mflr            : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->mflr,
+			in_be16(&ugeth->p_rx_glbl_pram->mflr));
+		pr_info("minflr          : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->minflr,
+			in_be16(&ugeth->p_rx_glbl_pram->minflr));
+		pr_info("maxd1           : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->maxd1,
+			in_be16(&ugeth->p_rx_glbl_pram->maxd1));
+		pr_info("maxd2           : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->maxd2,
+			in_be16(&ugeth->p_rx_glbl_pram->maxd2));
+		pr_info("ecamptr         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->ecamptr,
+			in_be32(&ugeth->p_rx_glbl_pram->ecamptr));
+		pr_info("l2qt            : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l2qt,
+			in_be32(&ugeth->p_rx_glbl_pram->l2qt));
+		pr_info("l3qt[0]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[0],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[0]));
+		pr_info("l3qt[1]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[1],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[1]));
+		pr_info("l3qt[2]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[2],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[2]));
+		pr_info("l3qt[3]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[3],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[3]));
+		pr_info("l3qt[4]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[4],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[4]));
+		pr_info("l3qt[5]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[5],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[5]));
+		pr_info("l3qt[6]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[6],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[6]));
+		pr_info("l3qt[7]         : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->l3qt[7],
+			in_be32(&ugeth->p_rx_glbl_pram->l3qt[7]));
+		pr_info("vlantype        : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->vlantype,
+			in_be16(&ugeth->p_rx_glbl_pram->vlantype));
+		pr_info("vlantci         : addr - 0x%08x, val - 0x%04x\n",
+			(u32)&ugeth->p_rx_glbl_pram->vlantci,
+			in_be16(&ugeth->p_rx_glbl_pram->vlantci));
 		for (i = 0; i < 64; i++)
-			ugeth_info
-		    ("addressfiltering[%d]: addr - 0x%08x, val - 0x%02x",
-			     i,
-			     (u32) & ugeth->p_rx_glbl_pram->addressfiltering[i],
-			     ugeth->p_rx_glbl_pram->addressfiltering[i]);
-		ugeth_info("exfGlobalParam  : addr - 0x%08x, val - 0x%08x",
-			   (u32) & ugeth->p_rx_glbl_pram->exfGlobalParam,
-			   in_be32(&ugeth->p_rx_glbl_pram->exfGlobalParam));
+			pr_info("addressfiltering[%d]: addr - 0x%08x, val - 0x%02x\n",
+				i,
+				(u32)&ugeth->p_rx_glbl_pram->addressfiltering[i],
+				ugeth->p_rx_glbl_pram->addressfiltering[i]);
+		pr_info("exfGlobalParam  : addr - 0x%08x, val - 0x%08x\n",
+			(u32)&ugeth->p_rx_glbl_pram->exfGlobalParam,
+			in_be32(&ugeth->p_rx_glbl_pram->exfGlobalParam));
 	}
 	if (ugeth->p_send_q_mem_reg) {
-		ugeth_info("Send Q memory registers:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_send_q_mem_reg);
+		pr_info("Send Q memory registers:\n");
+		pr_info("Base address: 0x%08x\n", (u32)ugeth->p_send_q_mem_reg);
 		for (i = 0; i < ugeth->ug_info->numQueuesTx; i++) {
-			ugeth_info("SQQD[%d]:", i);
-			ugeth_info("Base address: 0x%08x",
-				   (u32) & ugeth->p_send_q_mem_reg->sqqd[i]);
+			pr_info("SQQD[%d]:\n", i);
+			pr_info("Base address: 0x%08x\n",
+				(u32)&ugeth->p_send_q_mem_reg->sqqd[i]);
 			mem_disp((u8 *) & ugeth->p_send_q_mem_reg->sqqd[i],
 				 sizeof(struct ucc_geth_send_queue_qd));
 		}
 	}
 	if (ugeth->p_scheduler) {
-		ugeth_info("Scheduler:");
-		ugeth_info("Base address: 0x%08x", (u32) ugeth->p_scheduler);
+		pr_info("Scheduler:\n");
+		pr_info("Base address: 0x%08x\n", (u32)ugeth->p_scheduler);
 		mem_disp((u8 *) ugeth->p_scheduler,
 			 sizeof(*ugeth->p_scheduler));
 	}
 	if (ugeth->p_tx_fw_statistics_pram) {
-		ugeth_info("TX FW statistics pram:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_tx_fw_statistics_pram);
+		pr_info("TX FW statistics pram:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32)ugeth->p_tx_fw_statistics_pram);
 		mem_disp((u8 *) ugeth->p_tx_fw_statistics_pram,
 			 sizeof(*ugeth->p_tx_fw_statistics_pram));
 	}
 	if (ugeth->p_rx_fw_statistics_pram) {
-		ugeth_info("RX FW statistics pram:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_rx_fw_statistics_pram);
+		pr_info("RX FW statistics pram:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32)ugeth->p_rx_fw_statistics_pram);
 		mem_disp((u8 *) ugeth->p_rx_fw_statistics_pram,
 			 sizeof(*ugeth->p_rx_fw_statistics_pram));
 	}
 	if (ugeth->p_rx_irq_coalescing_tbl) {
-		ugeth_info("RX IRQ coalescing tables:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_rx_irq_coalescing_tbl);
+		pr_info("RX IRQ coalescing tables:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32)ugeth->p_rx_irq_coalescing_tbl);
 		for (i = 0; i < ugeth->ug_info->numQueuesRx; i++) {
-			ugeth_info("RX IRQ coalescing table entry[%d]:", i);
-			ugeth_info("Base address: 0x%08x",
-				   (u32) & ugeth->p_rx_irq_coalescing_tbl->
-				   coalescingentry[i]);
-			ugeth_info
-		("interruptcoalescingmaxvalue: addr - 0x%08x, val - 0x%08x",
-			     (u32) & ugeth->p_rx_irq_coalescing_tbl->
-			     coalescingentry[i].interruptcoalescingmaxvalue,
-			     in_be32(&ugeth->p_rx_irq_coalescing_tbl->
-				     coalescingentry[i].
-				     interruptcoalescingmaxvalue));
-			ugeth_info
-		("interruptcoalescingcounter : addr - 0x%08x, val - 0x%08x",
-			     (u32) & ugeth->p_rx_irq_coalescing_tbl->
-			     coalescingentry[i].interruptcoalescingcounter,
-			     in_be32(&ugeth->p_rx_irq_coalescing_tbl->
-				     coalescingentry[i].
-				     interruptcoalescingcounter));
+			pr_info("RX IRQ coalescing table entry[%d]:\n", i);
+			pr_info("Base address: 0x%08x\n",
+				(u32)&ugeth->p_rx_irq_coalescing_tbl->
+				coalescingentry[i]);
+			pr_info("interruptcoalescingmaxvalue: addr - 0x%08x, val - 0x%08x\n",
+				(u32)&ugeth->p_rx_irq_coalescing_tbl->
+				coalescingentry[i].interruptcoalescingmaxvalue,
+				in_be32(&ugeth->p_rx_irq_coalescing_tbl->
+					coalescingentry[i].
+					interruptcoalescingmaxvalue));
+			pr_info("interruptcoalescingcounter : addr - 0x%08x, val - 0x%08x\n",
+				(u32)&ugeth->p_rx_irq_coalescing_tbl->
+				coalescingentry[i].interruptcoalescingcounter,
+				in_be32(&ugeth->p_rx_irq_coalescing_tbl->
+					coalescingentry[i].
+					interruptcoalescingcounter));
 		}
 	}
 	if (ugeth->p_rx_bd_qs_tbl) {
-		ugeth_info("RX BD QS tables:");
-		ugeth_info("Base address: 0x%08x", (u32) ugeth->p_rx_bd_qs_tbl);
+		pr_info("RX BD QS tables:\n");
+		pr_info("Base address: 0x%08x\n", (u32)ugeth->p_rx_bd_qs_tbl);
 		for (i = 0; i < ugeth->ug_info->numQueuesRx; i++) {
-			ugeth_info("RX BD QS table[%d]:", i);
-			ugeth_info("Base address: 0x%08x",
-				   (u32) & ugeth->p_rx_bd_qs_tbl[i]);
-			ugeth_info
-			    ("bdbaseptr        : addr - 0x%08x, val - 0x%08x",
-			     (u32) & ugeth->p_rx_bd_qs_tbl[i].bdbaseptr,
-			     in_be32(&ugeth->p_rx_bd_qs_tbl[i].bdbaseptr));
-			ugeth_info
-			    ("bdptr            : addr - 0x%08x, val - 0x%08x",
-			     (u32) & ugeth->p_rx_bd_qs_tbl[i].bdptr,
-			     in_be32(&ugeth->p_rx_bd_qs_tbl[i].bdptr));
-			ugeth_info
-			    ("externalbdbaseptr: addr - 0x%08x, val - 0x%08x",
-			     (u32) & ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
-			     in_be32(&ugeth->p_rx_bd_qs_tbl[i].
-				     externalbdbaseptr));
-			ugeth_info
-			    ("externalbdptr    : addr - 0x%08x, val - 0x%08x",
-			     (u32) & ugeth->p_rx_bd_qs_tbl[i].externalbdptr,
-			     in_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdptr));
-			ugeth_info("ucode RX Prefetched BDs:");
-			ugeth_info("Base address: 0x%08x",
-				   (u32)
-				   qe_muram_addr(in_be32
-						 (&ugeth->p_rx_bd_qs_tbl[i].
-						  bdbaseptr)));
+			pr_info("RX BD QS table[%d]:\n", i);
+			pr_info("Base address: 0x%08x\n",
+				(u32)&ugeth->p_rx_bd_qs_tbl[i]);
+			pr_info("bdbaseptr        : addr - 0x%08x, val - 0x%08x\n",
+				(u32)&ugeth->p_rx_bd_qs_tbl[i].bdbaseptr,
+				in_be32(&ugeth->p_rx_bd_qs_tbl[i].bdbaseptr));
+			pr_info("bdptr            : addr - 0x%08x, val - 0x%08x\n",
+				(u32)&ugeth->p_rx_bd_qs_tbl[i].bdptr,
+				in_be32(&ugeth->p_rx_bd_qs_tbl[i].bdptr));
+			pr_info("externalbdbaseptr: addr - 0x%08x, val - 0x%08x\n",
+				(u32)&ugeth->p_rx_bd_qs_tbl[i].externalbdbaseptr,
+				in_be32(&ugeth->p_rx_bd_qs_tbl[i].
+					externalbdbaseptr));
+			pr_info("externalbdptr    : addr - 0x%08x, val - 0x%08x\n",
+				(u32)&ugeth->p_rx_bd_qs_tbl[i].externalbdptr,
+				in_be32(&ugeth->p_rx_bd_qs_tbl[i].externalbdptr));
+			pr_info("ucode RX Prefetched BDs:\n");
+			pr_info("Base address: 0x%08x\n",
+				(u32)qe_muram_addr(in_be32
+						   (&ugeth->p_rx_bd_qs_tbl[i].
+						    bdbaseptr)));
 			mem_disp((u8 *)
 				 qe_muram_addr(in_be32
 					       (&ugeth->p_rx_bd_qs_tbl[i].
@@ -1010,9 +996,9 @@ static void dump_regs(struct ucc_geth_private *ugeth)
 	}
 	if (ugeth->p_init_enet_param_shadow) {
 		int size;
-		ugeth_info("Init enet param shadow:");
-		ugeth_info("Base address: 0x%08x",
-			   (u32) ugeth->p_init_enet_param_shadow);
+		pr_info("Init enet param shadow:\n");
+		pr_info("Base address: 0x%08x\n",
+			(u32) ugeth->p_init_enet_param_shadow);
 		mem_disp((u8 *) ugeth->p_init_enet_param_shadow,
 			 sizeof(*ugeth->p_init_enet_param_shadow));
 
@@ -1392,12 +1378,11 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 		struct phy_device *tbiphy;
 
 		if (!ug_info->tbi_node)
-			ugeth_warn("TBI mode requires that the device "
-				"tree specify a tbi-handle\n");
+			pr_warn("TBI mode requires that the device tree specify a tbi-handle\n");
 
 		tbiphy = of_phy_find_device(ug_info->tbi_node);
 		if (!tbiphy)
-			ugeth_warn("Could not get TBI device\n");
+			pr_warn("Could not get TBI device\n");
 
 		value = phy_read(tbiphy, ENET_TBI_MII_CR);
 		value &= ~0x1000;	/* Turn off autonegotiation */
@@ -1409,8 +1394,7 @@ static int adjust_enet_interface(struct ucc_geth_private *ugeth)
 	ret_val = init_preamble_length(ug_info->prel, &ug_regs->maccfg2);
 	if (ret_val != 0) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Preamble length must be between 3 and 7 inclusive.",
-			     __func__);
+			pr_err("Preamble length must be between 3 and 7 inclusive\n");
 		return ret_val;
 	}
 
@@ -1520,7 +1504,7 @@ static int ugeth_enable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __func__);
+			pr_err("ucc_num out of range\n");
 		return -EINVAL;
 	}
 
@@ -1549,7 +1533,7 @@ static int ugeth_disable(struct ucc_geth_private *ugeth, enum comm_dir mode)
 	/* check if the UCC number is in range. */
 	if (ugeth->ug_info->uf_info.ucc_num >= UCC_MAX_NUM) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: ucc_num out of range.", __func__);
+			pr_err("ucc_num out of range\n");
 		return -EINVAL;
 	}
 
@@ -1648,7 +1632,7 @@ static void adjust_link(struct net_device *dev)
 				break;
 			default:
 				if (netif_msg_link(ugeth))
-					ugeth_warn(
+					pr_warn(
 						"%s: Ack!  Speed (%d) is not 10/100/1000!",
 						dev->name, phydev->speed);
 				break;
@@ -2103,8 +2087,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	if (!((uf_info->bd_mem_part == MEM_PART_SYSTEM) ||
 	      (uf_info->bd_mem_part == MEM_PART_MURAM))) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Bad memory partition value.",
-					__func__);
+			pr_err("Bad memory partition value\n");
 		return -EINVAL;
 	}
 
@@ -2114,9 +2097,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 		    (ug_info->bdRingLenRx[i] %
 		     UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT)) {
 			if (netif_msg_probe(ugeth))
-				ugeth_err
-				    ("%s: Rx BD ring length must be multiple of 4, no smaller than 8.",
-					__func__);
+				pr_err("Rx BD ring length must be multiple of 4, no smaller than 8\n");
 			return -EINVAL;
 		}
 	}
@@ -2125,9 +2106,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	for (i = 0; i < ug_info->numQueuesTx; i++) {
 		if (ug_info->bdRingLenTx[i] < UCC_GETH_TX_BD_RING_SIZE_MIN) {
 			if (netif_msg_probe(ugeth))
-				ugeth_err
-				    ("%s: Tx BD ring length must be no smaller than 2.",
-				     __func__);
+				pr_err("Tx BD ring length must be no smaller than 2\n");
 			return -EINVAL;
 		}
 	}
@@ -2136,23 +2115,21 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	if ((uf_info->max_rx_buf_length == 0) ||
 	    (uf_info->max_rx_buf_length % UCC_GETH_MRBLR_ALIGNMENT)) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err
-			    ("%s: max_rx_buf_length must be non-zero multiple of 128.",
-			     __func__);
+			pr_err("max_rx_buf_length must be non-zero multiple of 128\n");
 		return -EINVAL;
 	}
 
 	/* num Tx queues */
 	if (ug_info->numQueuesTx > NUM_TX_QUEUES) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: number of tx queues too large.", __func__);
+			pr_err("number of tx queues too large\n");
 		return -EINVAL;
 	}
 
 	/* num Rx queues */
 	if (ug_info->numQueuesRx > NUM_RX_QUEUES) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: number of rx queues too large.", __func__);
+			pr_err("number of rx queues too large\n");
 		return -EINVAL;
 	}
 
@@ -2160,10 +2137,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	for (i = 0; i < UCC_GETH_VLAN_PRIORITY_MAX; i++) {
 		if (ug_info->l2qt[i] >= ug_info->numQueuesRx) {
 			if (netif_msg_probe(ugeth))
-				ugeth_err
-				    ("%s: VLAN priority table entry must not be"
-					" larger than number of Rx queues.",
-				     __func__);
+				pr_err("VLAN priority table entry must not be larger than number of Rx queues\n");
 			return -EINVAL;
 		}
 	}
@@ -2172,18 +2146,14 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	for (i = 0; i < UCC_GETH_IP_PRIORITY_MAX; i++) {
 		if (ug_info->l3qt[i] >= ug_info->numQueuesRx) {
 			if (netif_msg_probe(ugeth))
-				ugeth_err
-				    ("%s: IP priority table entry must not be"
-					" larger than number of Rx queues.",
-				     __func__);
+				pr_err("IP priority table entry must not be larger than number of Rx queues\n");
 			return -EINVAL;
 		}
 	}
 
 	if (ug_info->cam && !ug_info->ecamptr) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: If cam mode is chosen, must supply cam ptr.",
-				  __func__);
+			pr_err("If cam mode is chosen, must supply cam ptr\n");
 		return -EINVAL;
 	}
 
@@ -2191,9 +2161,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	     UCC_GETH_NUM_OF_STATION_ADDRESSES_1) &&
 	    ug_info->rxExtendedFiltering) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Number of station addresses greater than 1 "
-				  "not allowed in extended parsing mode.",
-				  __func__);
+			pr_err("Number of station addresses greater than 1 not allowed in extended parsing mode\n");
 		return -EINVAL;
 	}
 
@@ -2207,7 +2175,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	/* Initialize the general fast UCC block. */
 	if (ucc_fast_init(uf_info, &ugeth->uccf)) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Failed to init uccf.", __func__);
+			pr_err("Failed to init uccf\n");
 		return -ENOMEM;
 	}
 
@@ -2222,7 +2190,7 @@ static int ucc_struct_init(struct ucc_geth_private *ugeth)
 	ugeth->ug_regs = ioremap(uf_info->regs, sizeof(*ugeth->ug_regs));
 	if (!ugeth->ug_regs) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Failed to ioremap regs.", __func__);
+			pr_err("Failed to ioremap regs\n");
 		return -ENOMEM;
 	}
 
@@ -2273,9 +2241,7 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
 		}
 		if (!ugeth->p_tx_bd_ring[j]) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err
-				    ("%s: Can not allocate memory for Tx bd rings.",
-				     __func__);
+				pr_err("Can not allocate memory for Tx bd rings\n");
 			return -ENOMEM;
 		}
 		/* Zero unused end of bd ring, according to spec */
@@ -2293,8 +2259,7 @@ static int ucc_geth_alloc_tx(struct ucc_geth_private *ugeth)
 
 		if (ugeth->tx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Could not allocate tx_skbuff",
-					  __func__);
+				pr_err("Could not allocate tx_skbuff\n");
 			return -ENOMEM;
 		}
 
@@ -2353,9 +2318,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
 		}
 		if (!ugeth->p_rx_bd_ring[j]) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err
-				    ("%s: Can not allocate memory for Rx bd rings.",
-				     __func__);
+				pr_err("Can not allocate memory for Rx bd rings\n");
 			return -ENOMEM;
 		}
 	}
@@ -2369,8 +2332,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
 
 		if (ugeth->rx_skbuff[j] == NULL) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Could not allocate rx_skbuff",
-					  __func__);
+				pr_err("Could not allocate rx_skbuff\n");
 			return -ENOMEM;
 		}
 
@@ -2438,8 +2400,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		break;
 	default:
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Bad number of Rx threads value.",
-				       	__func__);
+			pr_err("Bad number of Rx threads value\n");
 		return -EINVAL;
 		break;
 	}
@@ -2462,8 +2423,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		break;
 	default:
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Bad number of Tx threads value.",
-				       	__func__);
+			pr_err("Bad number of Tx threads value\n");
 		return -EINVAL;
 		break;
 	}
@@ -2512,8 +2472,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					      &ug_regs->ipgifg);
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: IPGIFG initialization parameter too large.",
-				  __func__);
+			pr_err("IPGIFG initialization parameter too large\n");
 		return ret_val;
 	}
 
@@ -2529,8 +2488,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 					  &ug_regs->hafdup);
 	if (ret_val != 0) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Half Duplex initialization parameter too large.",
-			  __func__);
+			pr_err("Half Duplex initialization parameter too large\n");
 		return ret_val;
 	}
 
@@ -2567,9 +2525,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   UCC_GETH_TX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->tx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_tx_glbl_pram.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_tx_glbl_pram\n");
 		return -ENOMEM;
 	}
 	ugeth->p_tx_glbl_pram =
@@ -2589,9 +2545,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_tx_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_thread_data_tx.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_thread_data_tx\n");
 		return -ENOMEM;
 	}
 
@@ -2618,9 +2572,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   UCC_GETH_SEND_QUEUE_QUEUE_DESCRIPTOR_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->send_q_mem_reg_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_send_q_mem_reg.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_send_q_mem_reg\n");
 		return -ENOMEM;
 	}
 
@@ -2661,9 +2613,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   UCC_GETH_SCHEDULER_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->scheduler_offset)) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err
-				 ("%s: Can not allocate DPRAM memory for p_scheduler.",
-				     __func__);
+				pr_err("Can not allocate DPRAM memory for p_scheduler\n");
 			return -ENOMEM;
 		}
 
@@ -2710,10 +2660,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   UCC_GETH_TX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->tx_fw_statistics_pram_offset)) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err
-				    ("%s: Can not allocate DPRAM memory for"
-					" p_tx_fw_statistics_pram.",
-				       	__func__);
+				pr_err("Can not allocate DPRAM memory for p_tx_fw_statistics_pram\n");
 			return -ENOMEM;
 		}
 		ugeth->p_tx_fw_statistics_pram =
@@ -2750,9 +2697,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   UCC_GETH_RX_GLOBAL_PRAM_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_glbl_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_rx_glbl_pram.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_rx_glbl_pram\n");
 		return -ENOMEM;
 	}
 	ugeth->p_rx_glbl_pram =
@@ -2771,9 +2716,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   UCC_GETH_THREAD_DATA_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->thread_dat_rx_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_thread_data_rx.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_thread_data_rx\n");
 		return -ENOMEM;
 	}
 
@@ -2794,9 +2737,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				   UCC_GETH_RX_STATISTICS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->rx_fw_statistics_pram_offset)) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err
-					("%s: Can not allocate DPRAM memory for"
-					" p_rx_fw_statistics_pram.", __func__);
+				pr_err("Can not allocate DPRAM memory for p_rx_fw_statistics_pram\n");
 			return -ENOMEM;
 		}
 		ugeth->p_rx_fw_statistics_pram =
@@ -2816,9 +2757,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   + 4, UCC_GETH_RX_INTERRUPT_COALESCING_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_irq_coalescing_tbl_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for"
-				" p_rx_irq_coalescing_tbl.", __func__);
+			pr_err("Can not allocate DPRAM memory for p_rx_irq_coalescing_tbl\n");
 		return -ENOMEM;
 	}
 
@@ -2884,9 +2823,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 			   UCC_GETH_RX_BD_QUEUES_ALIGNMENT);
 	if (IS_ERR_VALUE(ugeth->rx_bd_qs_tbl_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_rx_bd_qs_tbl.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_rx_bd_qs_tbl\n");
 		return -ENOMEM;
 	}
 
@@ -2961,8 +2898,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (ug_info->rxExtendedFiltering) {
 		if (!ug_info->extendedFilteringChainPointer) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Null Extended Filtering Chain Pointer.",
-					  __func__);
+				pr_err("Null Extended Filtering Chain Pointer\n");
 			return -EINVAL;
 		}
 
@@ -2973,9 +2909,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		UCC_GETH_RX_EXTENDED_FILTERING_GLOBAL_PARAMETERS_ALIGNMENT);
 		if (IS_ERR_VALUE(ugeth->exf_glbl_param_offset)) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err
-					("%s: Can not allocate DPRAM memory for"
-					" p_exf_glbl_param.", __func__);
+				pr_err("Can not allocate DPRAM memory for p_exf_glbl_param\n");
 			return -ENOMEM;
 		}
 
@@ -3020,9 +2954,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	if (!(ugeth->p_init_enet_param_shadow =
 	      kmalloc(sizeof(struct ucc_geth_init_pram), GFP_KERNEL))) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate memory for"
-				" p_UccInitEnetParamShadows.", __func__);
+			pr_err("Can not allocate memory for p_UccInitEnetParamShadows\n");
 		return -ENOMEM;
 	}
 	/* Zero out *p_init_enet_param_shadow */
@@ -3055,8 +2987,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	    (ug_info->largestexternallookupkeysize !=
 	     QE_FLTR_LARGEST_EXTERNAL_TABLE_LOOKUP_KEY_SIZE_16_BYTES)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Invalid largest External Lookup Key Size.",
-				  __func__);
+			pr_err("Invalid largest External Lookup Key Size\n");
 		return -EINVAL;
 	}
 	ugeth->p_init_enet_param_shadow->largestexternallookupkeysize =
@@ -3081,8 +3012,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 		, size, UCC_GETH_THREAD_RX_PRAM_ALIGNMENT,
 		ug_info->riscRx, 1)) != 0) {
 		if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-					__func__);
+			pr_err("Can not fill p_init_enet_param_shadow\n");
 		return ret_val;
 	}
 
@@ -3096,8 +3026,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 				    UCC_GETH_THREAD_TX_PRAM_ALIGNMENT,
 				    ug_info->riscTx, 0)) != 0) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Can not fill p_init_enet_param_shadow.",
-				  __func__);
+			pr_err("Can not fill p_init_enet_param_shadow\n");
 		return ret_val;
 	}
 
@@ -3105,8 +3034,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	for (i = 0; i < ug_info->numQueuesRx; i++) {
 		if ((ret_val = rx_bd_buffer_set(ugeth, (u8) i)) != 0) {
 			if (netif_msg_ifup(ugeth))
-				ugeth_err("%s: Can not fill Rx bds with buffers.",
-					  __func__);
+				pr_err("Can not fill Rx bds with buffers\n");
 			return ret_val;
 		}
 	}
@@ -3115,9 +3043,7 @@ static int ucc_geth_startup(struct ucc_geth_private *ugeth)
 	init_enet_pram_offset = qe_muram_alloc(sizeof(struct ucc_geth_init_pram), 4);
 	if (IS_ERR_VALUE(init_enet_pram_offset)) {
 		if (netif_msg_ifup(ugeth))
-			ugeth_err
-			    ("%s: Can not allocate DPRAM memory for p_init_enet_pram.",
-			     __func__);
+			pr_err("Can not allocate DPRAM memory for p_init_enet_pram\n");
 		return -ENOMEM;
 	}
 	p_init_enet_pram =
@@ -3266,8 +3192,8 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		    (!(bd_status & (R_F | R_L))) ||
 		    (bd_status & R_ERRORS_FATAL)) {
 			if (netif_msg_rx_err(ugeth))
-				ugeth_err("%s, %d: ERROR!!! skb - 0x%08x",
-					   __func__, __LINE__, (u32) skb);
+				pr_err("%d: ERROR!!! skb - 0x%08x\n",
+				       __LINE__, (u32)skb);
 			dev_kfree_skb(skb);
 
 			ugeth->rx_skbuff[rxQ][ugeth->skb_currx[rxQ]] = NULL;
@@ -3290,7 +3216,7 @@ static int ucc_geth_rx(struct ucc_geth_private *ugeth, u8 rxQ, int rx_work_limit
 		skb = get_new_skb(ugeth, bd);
 		if (!skb) {
 			if (netif_msg_rx_err(ugeth))
-				ugeth_warn("%s: No Rx Data Buffer", __func__);
+				pr_warn("No Rx Data Buffer\n");
 			dev->stats.rx_dropped++;
 			break;
 		}
@@ -3481,25 +3407,19 @@ static int ucc_geth_init_mac(struct ucc_geth_private *ugeth)
 
 	err = ucc_struct_init(ugeth);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot configure internal struct, "
-				  "aborting.", dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot configure internal struct, aborting\n");
 		goto err;
 	}
 
 	err = ucc_geth_startup(ugeth);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot configure net device, aborting.",
-				  dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot configure net device, aborting\n");
 		goto err;
 	}
 
 	err = adjust_enet_interface(ugeth);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot configure net device, aborting.",
-				  dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot configure net device, aborting\n");
 		goto err;
 	}
 
@@ -3516,8 +3436,7 @@ static int ucc_geth_init_mac(struct ucc_geth_private *ugeth)
 
 	err = ugeth_enable(ugeth, COMM_DIR_RX_AND_TX);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot enable net device, aborting.", dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot enable net device, aborting\n");
 		goto err;
 	}
 
@@ -3538,35 +3457,27 @@ static int ucc_geth_open(struct net_device *dev)
 
 	/* Test station address */
 	if (dev->dev_addr[0] & ENET_GROUP_ADDR) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Multicast address used for station "
-				  "address - is this what you wanted?",
-				  __func__);
+		netif_err(ugeth, ifup, dev,
+			  "Multicast address used for station address - is this what you wanted?\n");
 		return -EINVAL;
 	}
 
 	err = init_phy(dev);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot initialize PHY, aborting.",
-				  dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot initialize PHY, aborting\n");
 		return err;
 	}
 
 	err = ucc_geth_init_mac(ugeth);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot initialize MAC, aborting.",
-				  dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot initialize MAC, aborting\n");
 		goto err;
 	}
 
 	err = request_irq(ugeth->ug_info->uf_info.irq, ucc_geth_irq_handler,
 			  0, "UCC Geth", dev);
 	if (err) {
-		if (netif_msg_ifup(ugeth))
-			ugeth_err("%s: Cannot get IRQ for net device, aborting.",
-				  dev->name);
+		netif_err(ugeth, ifup, dev, "Cannot get IRQ for net device, aborting\n");
 		goto err;
 	}
 
@@ -3704,8 +3615,7 @@ static int ucc_geth_resume(struct platform_device *ofdev)
 
 		err = ucc_geth_init_mac(ugeth);
 		if (err) {
-			ugeth_err("%s: Cannot initialize MAC, aborting.",
-				  ndev->name);
+			netdev_err(ndev, "Cannot initialize MAC, aborting\n");
 			return err;
 		}
 	}
@@ -3825,8 +3735,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	ug_info = &ugeth_info[ucc_num];
 	if (ug_info == NULL) {
 		if (netif_msg_probe(&debug))
-			ugeth_err("%s: [%d] Missing additional data!",
-				       	__func__, ucc_num);
+			pr_err("[%d] Missing additional data!\n", ucc_num);
 		return -ENODEV;
 	}
 
@@ -3837,8 +3746,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 		ug_info->uf_info.rx_clock = qe_clock_source(sprop);
 		if ((ug_info->uf_info.rx_clock < QE_CLK_NONE) ||
 		    (ug_info->uf_info.rx_clock > QE_CLK24)) {
-			printk(KERN_ERR
-				"ucc_geth: invalid rx-clock-name property\n");
+			pr_err("invalid rx-clock-name property\n");
 			return -EINVAL;
 		}
 	} else {
@@ -3846,13 +3754,11 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 		if (!prop) {
 			/* If both rx-clock-name and rx-clock are missing,
 			   we want to tell people to use rx-clock-name. */
-			printk(KERN_ERR
-				"ucc_geth: missing rx-clock-name property\n");
+			pr_err("missing rx-clock-name property\n");
 			return -EINVAL;
 		}
 		if ((*prop < QE_CLK_NONE) || (*prop > QE_CLK24)) {
-			printk(KERN_ERR
-				"ucc_geth: invalid rx-clock propperty\n");
+			pr_err("invalid rx-clock propperty\n");
 			return -EINVAL;
 		}
 		ug_info->uf_info.rx_clock = *prop;
@@ -3863,20 +3769,17 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 		ug_info->uf_info.tx_clock = qe_clock_source(sprop);
 		if ((ug_info->uf_info.tx_clock < QE_CLK_NONE) ||
 		    (ug_info->uf_info.tx_clock > QE_CLK24)) {
-			printk(KERN_ERR
-				"ucc_geth: invalid tx-clock-name property\n");
+			pr_err("invalid tx-clock-name property\n");
 			return -EINVAL;
 		}
 	} else {
 		prop = of_get_property(np, "tx-clock", NULL);
 		if (!prop) {
-			printk(KERN_ERR
-				"ucc_geth: missing tx-clock-name property\n");
+			pr_err("missing tx-clock-name property\n");
 			return -EINVAL;
 		}
 		if ((*prop < QE_CLK_NONE) || (*prop > QE_CLK24)) {
-			printk(KERN_ERR
-				"ucc_geth: invalid tx-clock property\n");
+			pr_err("invalid tx-clock property\n");
 			return -EINVAL;
 		}
 		ug_info->uf_info.tx_clock = *prop;
@@ -3949,7 +3852,7 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	}
 
 	if (netif_msg_probe(&debug))
-		printk(KERN_INFO "ucc_geth: UCC%1d at 0x%8x (irq = %d)\n",
+		pr_info("UCC%1d at 0x%8x (irq = %d)\n",
 			ug_info->uf_info.ucc_num + 1, ug_info->uf_info.regs,
 			ug_info->uf_info.irq);
 
@@ -3988,8 +3891,8 @@ static int ucc_geth_probe(struct platform_device* ofdev)
 	err = register_netdev(dev);
 	if (err) {
 		if (netif_msg_probe(ugeth))
-			ugeth_err("%s: Cannot register net device, aborting.",
-				  dev->name);
+			pr_err("%s: Cannot register net device, aborting\n",
+			       dev->name);
 		free_netdev(dev);
 		return err;
 	}
@@ -4047,7 +3950,7 @@ static int __init ucc_geth_init(void)
 	int i, ret;
 
 	if (netif_msg_drv(&debug))
-		printk(KERN_INFO "ucc_geth: " DRV_DESC "\n");
+		pr_info(DRV_DESC "\n");
 	for (i = 0; i < 8; i++)
 		memcpy(&(ugeth_info[i]), &ugeth_primary_info,
 		       sizeof(ugeth_primary_info));
diff --git a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
index 1ebf712..e79aaf9 100644
--- a/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
+++ b/drivers/net/ethernet/freescale/ucc_geth_ethtool.c
@@ -38,7 +38,7 @@
 
 #include "ucc_geth.h"
 
-static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
+static const char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-64-frames",
 	"tx-65-127-frames",
 	"tx-128-255-frames",
@@ -59,7 +59,7 @@ static char hw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"rx-dropped-frames",
 };
 
-static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
+static const char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-single-collision",
 	"tx-multiple-collision",
 	"tx-late-collsion",
@@ -74,7 +74,7 @@ static char tx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"tx-jumbo-frames",
 };
 
-static char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
+static const char rx_fw_stat_gstrings[][ETH_GSTRING_LEN] = {
 	"rx-crc-errors",
 	"rx-alignment-errors",
 	"rx-in-range-length-errors",
@@ -160,8 +160,7 @@ uec_set_pauseparam(struct net_device *netdev,
 	if (ugeth->phydev->autoneg) {
 		if (netif_running(netdev)) {
 			/* FIXME: automatically restart */
-			printk(KERN_INFO
-				"Please re-open the interface.\n");
+			netdev_info(netdev, "Please re-open the interface\n");
 		}
 	} else {
 		struct ucc_geth_info *ug_info = ugeth->ug_info;
@@ -240,18 +239,18 @@ uec_set_ringparam(struct net_device *netdev,
 	int queue = 0, ret = 0;
 
 	if (ring->rx_pending < UCC_GETH_RX_BD_RING_SIZE_MIN) {
-		printk("%s: RxBD ring size must be no smaller than %d.\n",
-			       	netdev->name, UCC_GETH_RX_BD_RING_SIZE_MIN);
+		netdev_info(netdev, "RxBD ring size must be no smaller than %d\n",
+			    UCC_GETH_RX_BD_RING_SIZE_MIN);
 		return -EINVAL;
 	}
 	if (ring->rx_pending % UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT) {
-		printk("%s: RxBD ring size must be multiple of %d.\n",
-			netdev->name, UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT);
+		netdev_info(netdev, "RxBD ring size must be multiple of %d\n",
+			    UCC_GETH_RX_BD_RING_SIZE_ALIGNMENT);
 		return -EINVAL;
 	}
 	if (ring->tx_pending < UCC_GETH_TX_BD_RING_SIZE_MIN) {
-		printk("%s: TxBD ring size must be no smaller than %d.\n",
-				netdev->name, UCC_GETH_TX_BD_RING_SIZE_MIN);
+		netdev_info(netdev, "TxBD ring size must be no smaller than %d\n",
+			    UCC_GETH_TX_BD_RING_SIZE_MIN);
 		return -EINVAL;
 	}
 
@@ -260,8 +259,7 @@ uec_set_ringparam(struct net_device *netdev,
 
 	if (netif_running(netdev)) {
 		/* FIXME: restart automatically */
-		printk(KERN_INFO
-			"Please re-open the interface.\n");
+		netdev_info(netdev, "Please re-open the interface\n");
 	}
 
 	return ret;
-- 
1.8.1.2.459.gbcd45b4.dirty
