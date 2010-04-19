From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next-2.6 1/11] bnx2x: Parity errors handling for
 57710 and 57711
Date: Mon, 19 Apr 2010 14:13:12 +0300
Message-ID: <1271675592.6900.266.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2049 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754509Ab0DSLNV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Apr 2010 07:13:21 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the parity errors handling code for 57710 and 577=
11 chips.

HW is configured to stop all DMA transactions to the host and sending p=
ackets to the network
once parity error is detected, which is meant to prevent silent data co=
rruption.
At the same time HW generates the attention interrupt to every function=
 of the device where parity
has been detected so that driver can start the recovery flow.

The recovery is actually resetting the chip and restarting the driver o=
n all active functions
of the chip where the parity error has been reported.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x.h      |   23 +-
 drivers/net/bnx2x_main.c | 1045 ++++++++++++++++++++++++++++++++++++++=
+++++---
 drivers/net/bnx2x_reg.h  |   27 ++-
 3 files changed, 1039 insertions(+), 56 deletions(-)

diff --git a/drivers/net/bnx2x.h b/drivers/net/bnx2x.h
index ae9c89e..37e9b16 100644
--- a/drivers/net/bnx2x.h
+++ b/drivers/net/bnx2x.h
@@ -155,9 +155,15 @@ do {								 \
 #define SHMEM2_RD(bp, field)		REG_RD(bp, SHMEM2_ADDR(bp, field))
 #define SHMEM2_WR(bp, field, val)	REG_WR(bp, SHMEM2_ADDR(bp, field), v=
al)
=20
+#define MF_CFG_RD(bp, field)		SHMEM_RD(bp, mf_cfg.field)
+#define MF_CFG_WR(bp, field, val)	SHMEM_WR(bp, mf_cfg.field, val)
+
 #define EMAC_RD(bp, reg)		REG_RD(bp, emac_base + reg)
 #define EMAC_WR(bp, reg, val)		REG_WR(bp, emac_base + reg, val)
=20
+#define AEU_IN_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR \
+	AEU_INPUTS_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR
+
=20
 /* fast path */
=20
@@ -818,6 +824,12 @@ struct attn_route {
 	u32	sig[4];
 };
=20
+typedef enum {
+	BNX2X_RECOVERY_DONE,
+	BNX2X_RECOVERY_INIT,
+	BNX2X_RECOVERY_WAIT,
+} bnx2x_recovery_state_t;
+
 struct bnx2x {
 	/* Fields used in the tx and intr/napi performance paths
 	 * are grouped together in the beginning of the structure
@@ -835,6 +847,9 @@ struct bnx2x {
 	struct pci_dev		*pdev;
=20
 	atomic_t		intr_sem;
+
+	bnx2x_recovery_state_t	recovery_state;
+	int			is_leader;
 #ifdef BCM_CNIC
 	struct msix_entry	msix_table[MAX_CONTEXT+2];
 #else
@@ -924,8 +939,7 @@ struct bnx2x {
 	int			mrrs;
=20
 	struct delayed_work	sp_task;
-	struct work_struct	reset_task;
-
+	struct delayed_work	reset_task;
 	struct timer_list	timer;
 	int			current_interval;
=20
@@ -1125,6 +1139,7 @@ static inline u32 reg_poll(struct bnx2x *bp, u32 =
reg, u32 expected, int ms,
 #define LOAD_DIAG			2
 #define UNLOAD_NORMAL			0
 #define UNLOAD_CLOSE			1
+#define UNLOAD_RECOVERY                 2
=20
=20
 /* DMAE command defines */
@@ -1294,6 +1309,10 @@ static inline u32 reg_poll(struct bnx2x *bp, u32=
 reg, u32 expected, int ms,
 				 AEU_INPUTS_ATTN_BITS_IGU_PARITY_ERROR | \
 				 AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR)
=20
+#define HW_PRTY_ASSERT_SET_3 (AEU_INPUTS_ATTN_BITS_MCP_LATCHED_ROM_PAR=
ITY | \
+		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_RX_PARITY | \
+		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY | \
+		AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY)
=20
 #define MULTI_FLAGS(bp) \
 		(TSTORM_ETH_FUNCTION_COMMON_CONFIG_RSS_IPV4_CAPABILITY | \
diff --git a/drivers/net/bnx2x_main.c b/drivers/net/bnx2x_main.c
index 63a17d6..bbaf4ac 100644
--- a/drivers/net/bnx2x_main.c
+++ b/drivers/net/bnx2x_main.c
@@ -764,6 +764,40 @@ static void bnx2x_int_disable_sync(struct bnx2x *b=
p, int disable_hw)
  * General service functions
  */
=20
+/* Return true if succeeded to acquire the lock */
+static bool bnx2x_trylock_hw_lock(struct bnx2x *bp, u32 resource)
+{
+	u32 lock_status;
+	u32 resource_bit =3D (1 << resource);
+	int func =3D BP_FUNC(bp);
+	u32 hw_lock_control_reg;
+
+	DP(NETIF_MSG_HW, "Trying to take a lock on resource %d\n", resource);
+
+	/* Validating that the resource is within range */
+	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
+		DP(NETIF_MSG_HW,
+		   "resource(0x%x) > HW_LOCK_MAX_RESOURCE_VALUE(0x%x)\n",
+		   resource, HW_LOCK_MAX_RESOURCE_VALUE);
+		return -EINVAL;
+	}
+
+	if (func <=3D 5)
+		hw_lock_control_reg =3D (MISC_REG_DRIVER_CONTROL_1 + func*8);
+	else
+		hw_lock_control_reg =3D
+				(MISC_REG_DRIVER_CONTROL_7 + (func - 6)*8);
+
+	/* Try to acquire the lock */
+	REG_WR(bp, hw_lock_control_reg + 4, resource_bit);
+	lock_status =3D REG_RD(bp, hw_lock_control_reg);
+	if (lock_status & resource_bit)
+		return true;
+
+	DP(NETIF_MSG_HW, "Failed to get a lock on resource %d\n", resource);
+	return false;
+}
+
 static inline void bnx2x_ack_sb(struct bnx2x *bp, u8 sb_id,
 				u8 storm, u16 index, u8 op, u8 update)
 {
@@ -1901,6 +1935,8 @@ static int bnx2x_release_hw_lock(struct bnx2x *bp=
, u32 resource)
 	int func =3D BP_FUNC(bp);
 	u32 hw_lock_control_reg;
=20
+	DP(NETIF_MSG_HW, "Releasing a lock on resource %d\n", resource);
+
 	/* Validating that the resource is within range */
 	if (resource > HW_LOCK_MAX_RESOURCE_VALUE) {
 		DP(NETIF_MSG_HW,
@@ -2741,12 +2777,11 @@ static int bnx2x_sp_post(struct bnx2x *bp, int =
command, int cid,
 /* acquire split MCP access lock register */
 static int bnx2x_acquire_alr(struct bnx2x *bp)
 {
-	u32 i, j, val;
+	u32 j, val;
 	int rc =3D 0;
=20
 	might_sleep();
-	i =3D 100;
-	for (j =3D 0; j < i*10; j++) {
+	for (j =3D 0; j < 1000; j++) {
 		val =3D (1UL << 31);
 		REG_WR(bp, GRCBASE_MCP + 0x9c, val);
 		val =3D REG_RD(bp, GRCBASE_MCP + 0x9c);
@@ -2766,9 +2801,7 @@ static int bnx2x_acquire_alr(struct bnx2x *bp)
 /* release split MCP access lock register */
 static void bnx2x_release_alr(struct bnx2x *bp)
 {
-	u32 val =3D 0;
-
-	REG_WR(bp, GRCBASE_MCP + 0x9c, val);
+	REG_WR(bp, GRCBASE_MCP + 0x9c, 0);
 }
=20
 static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)
@@ -2824,7 +2857,7 @@ static void bnx2x_attn_int_asserted(struct bnx2x =
*bp, u32 asserted)
=20
 	DP(NETIF_MSG_HW, "aeu_mask %x  newly asserted %x\n",
 	   aeu_mask, asserted);
-	aeu_mask &=3D ~(asserted & 0xff);
+	aeu_mask &=3D ~(asserted & 0x3ff);
 	DP(NETIF_MSG_HW, "new mask %x\n", aeu_mask);
=20
 	REG_WR(bp, aeu_addr, aeu_mask);
@@ -3105,10 +3138,311 @@ static inline void bnx2x_attn_int_deasserted3(=
struct bnx2x *bp, u32 attn)
 	}
 }
=20
-static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted=
)
+static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode);
+static int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
+
+
+#define BNX2X_MISC_GEN_REG      MISC_REG_GENERIC_POR_1
+#define LOAD_COUNTER_BITS	16 /* Number of bits for load counter */
+#define LOAD_COUNTER_MASK	(((u32)0x1 << LOAD_COUNTER_BITS) - 1)
+#define RESET_DONE_FLAG_MASK	(~LOAD_COUNTER_MASK)
+#define RESET_DONE_FLAG_SHIFT	LOAD_COUNTER_BITS
+#define CHIP_PARITY_SUPPORTED(bp)   (CHIP_IS_E1(bp) || CHIP_IS_E1H(bp)=
)
+/*
+ * should be run under rtnl lock
+ */
+static inline void bnx2x_set_reset_done(struct bnx2x *bp)
+{
+	u32 val	=3D REG_RD(bp, BNX2X_MISC_GEN_REG);
+	val &=3D ~(1 << RESET_DONE_FLAG_SHIFT);
+	REG_WR(bp, BNX2X_MISC_GEN_REG, val);
+	barrier();
+	mmiowb();
+}
+
+/*
+ * should be run under rtnl lock
+ */
+static inline void bnx2x_set_reset_in_progress(struct bnx2x *bp)
+{
+	u32 val	=3D REG_RD(bp, BNX2X_MISC_GEN_REG);
+	val |=3D (1 << 16);
+	REG_WR(bp, BNX2X_MISC_GEN_REG, val);
+	barrier();
+	mmiowb();
+}
+
+/*
+ * should be run under rtnl lock
+ */
+static inline bool bnx2x_reset_is_done(struct bnx2x *bp)
+{
+	u32 val	=3D REG_RD(bp, BNX2X_MISC_GEN_REG);
+	DP(NETIF_MSG_HW, "GEN_REG_VAL=3D0x%08x\n", val);
+	return (val & RESET_DONE_FLAG_MASK) ? false : true;
+}
+
+/*
+ * should be run under rtnl lock
+ */
+static inline void bnx2x_inc_load_cnt(struct bnx2x *bp)
+{
+	u32 val1, val =3D REG_RD(bp, BNX2X_MISC_GEN_REG);
+
+	DP(NETIF_MSG_HW, "Old GEN_REG_VAL=3D0x%08x\n", val);
+
+	val1 =3D ((val & LOAD_COUNTER_MASK) + 1) & LOAD_COUNTER_MASK;
+	REG_WR(bp, BNX2X_MISC_GEN_REG, (val & RESET_DONE_FLAG_MASK) | val1);
+	barrier();
+	mmiowb();
+}
+
+/*
+ * should be run under rtnl lock
+ */
+static inline u32 bnx2x_dec_load_cnt(struct bnx2x *bp)
+{
+	u32 val1, val =3D REG_RD(bp, BNX2X_MISC_GEN_REG);
+
+	DP(NETIF_MSG_HW, "Old GEN_REG_VAL=3D0x%08x\n", val);
+
+	val1 =3D ((val & LOAD_COUNTER_MASK) - 1) & LOAD_COUNTER_MASK;
+	REG_WR(bp, BNX2X_MISC_GEN_REG, (val & RESET_DONE_FLAG_MASK) | val1);
+	barrier();
+	mmiowb();
+
+	return val1;
+}
+
+/*
+ * should be run under rtnl lock
+ */
+static inline u32 bnx2x_get_load_cnt(struct bnx2x *bp)
+{
+	return REG_RD(bp, BNX2X_MISC_GEN_REG) & LOAD_COUNTER_MASK;
+}
+
+static inline void bnx2x_clear_load_cnt(struct bnx2x *bp)
+{
+	u32 val =3D REG_RD(bp, BNX2X_MISC_GEN_REG);
+	REG_WR(bp, BNX2X_MISC_GEN_REG, val & (~LOAD_COUNTER_MASK));
+}
+
+static inline void _print_next_block(int idx, const char *blk)
+{
+	if (idx)
+		pr_cont(", ");
+	pr_cont("%s", blk);
+}
+
+static inline int bnx2x_print_blocks_with_parity0(u32 sig, int par_num=
)
+{
+	int i =3D 0;
+	u32 cur_bit =3D 0;
+	for (i =3D 0; sig; i++) {
+		cur_bit =3D ((u32)0x1 << i);
+		if (sig & cur_bit) {
+			switch (cur_bit) {
+			case AEU_INPUTS_ATTN_BITS_BRB_PARITY_ERROR:
+				_print_next_block(par_num++, "BRB");
+				break;
+			case AEU_INPUTS_ATTN_BITS_PARSER_PARITY_ERROR:
+				_print_next_block(par_num++, "PARSER");
+				break;
+			case AEU_INPUTS_ATTN_BITS_TSDM_PARITY_ERROR:
+				_print_next_block(par_num++, "TSDM");
+				break;
+			case AEU_INPUTS_ATTN_BITS_SEARCHER_PARITY_ERROR:
+				_print_next_block(par_num++, "SEARCHER");
+				break;
+			case AEU_INPUTS_ATTN_BITS_TSEMI_PARITY_ERROR:
+				_print_next_block(par_num++, "TSEMI");
+				break;
+			}
+
+			/* Clear the bit */
+			sig &=3D ~cur_bit;
+		}
+	}
+
+	return par_num;
+}
+
+static inline int bnx2x_print_blocks_with_parity1(u32 sig, int par_num=
)
+{
+	int i =3D 0;
+	u32 cur_bit =3D 0;
+	for (i =3D 0; sig; i++) {
+		cur_bit =3D ((u32)0x1 << i);
+		if (sig & cur_bit) {
+			switch (cur_bit) {
+			case AEU_INPUTS_ATTN_BITS_PBCLIENT_PARITY_ERROR:
+				_print_next_block(par_num++, "PBCLIENT");
+				break;
+			case AEU_INPUTS_ATTN_BITS_QM_PARITY_ERROR:
+				_print_next_block(par_num++, "QM");
+				break;
+			case AEU_INPUTS_ATTN_BITS_XSDM_PARITY_ERROR:
+				_print_next_block(par_num++, "XSDM");
+				break;
+			case AEU_INPUTS_ATTN_BITS_XSEMI_PARITY_ERROR:
+				_print_next_block(par_num++, "XSEMI");
+				break;
+			case AEU_INPUTS_ATTN_BITS_DOORBELLQ_PARITY_ERROR:
+				_print_next_block(par_num++, "DOORBELLQ");
+				break;
+			case AEU_INPUTS_ATTN_BITS_VAUX_PCI_CORE_PARITY_ERROR:
+				_print_next_block(par_num++, "VAUX PCI CORE");
+				break;
+			case AEU_INPUTS_ATTN_BITS_DEBUG_PARITY_ERROR:
+				_print_next_block(par_num++, "DEBUG");
+				break;
+			case AEU_INPUTS_ATTN_BITS_USDM_PARITY_ERROR:
+				_print_next_block(par_num++, "USDM");
+				break;
+			case AEU_INPUTS_ATTN_BITS_USEMI_PARITY_ERROR:
+				_print_next_block(par_num++, "USEMI");
+				break;
+			case AEU_INPUTS_ATTN_BITS_UPB_PARITY_ERROR:
+				_print_next_block(par_num++, "UPB");
+				break;
+			case AEU_INPUTS_ATTN_BITS_CSDM_PARITY_ERROR:
+				_print_next_block(par_num++, "CSDM");
+				break;
+			}
+
+			/* Clear the bit */
+			sig &=3D ~cur_bit;
+		}
+	}
+
+	return par_num;
+}
+
+static inline int bnx2x_print_blocks_with_parity2(u32 sig, int par_num=
)
+{
+	int i =3D 0;
+	u32 cur_bit =3D 0;
+	for (i =3D 0; sig; i++) {
+		cur_bit =3D ((u32)0x1 << i);
+		if (sig & cur_bit) {
+			switch (cur_bit) {
+			case AEU_INPUTS_ATTN_BITS_CSEMI_PARITY_ERROR:
+				_print_next_block(par_num++, "CSEMI");
+				break;
+			case AEU_INPUTS_ATTN_BITS_PXP_PARITY_ERROR:
+				_print_next_block(par_num++, "PXP");
+				break;
+			case AEU_IN_ATTN_BITS_PXPPCICLOCKCLIENT_PARITY_ERROR:
+				_print_next_block(par_num++,
+					"PXPPCICLOCKCLIENT");
+				break;
+			case AEU_INPUTS_ATTN_BITS_CFC_PARITY_ERROR:
+				_print_next_block(par_num++, "CFC");
+				break;
+			case AEU_INPUTS_ATTN_BITS_CDU_PARITY_ERROR:
+				_print_next_block(par_num++, "CDU");
+				break;
+			case AEU_INPUTS_ATTN_BITS_IGU_PARITY_ERROR:
+				_print_next_block(par_num++, "IGU");
+				break;
+			case AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR:
+				_print_next_block(par_num++, "MISC");
+				break;
+			}
+
+			/* Clear the bit */
+			sig &=3D ~cur_bit;
+		}
+	}
+
+	return par_num;
+}
+
+static inline int bnx2x_print_blocks_with_parity3(u32 sig, int par_num=
)
+{
+	int i =3D 0;
+	u32 cur_bit =3D 0;
+	for (i =3D 0; sig; i++) {
+		cur_bit =3D ((u32)0x1 << i);
+		if (sig & cur_bit) {
+			switch (cur_bit) {
+			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_ROM_PARITY:
+				_print_next_block(par_num++, "MCP ROM");
+				break;
+			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_RX_PARITY:
+				_print_next_block(par_num++, "MCP UMP RX");
+				break;
+			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY:
+				_print_next_block(par_num++, "MCP UMP TX");
+				break;
+			case AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY:
+				_print_next_block(par_num++, "MCP SCPAD");
+				break;
+			}
+
+			/* Clear the bit */
+			sig &=3D ~cur_bit;
+		}
+	}
+
+	return par_num;
+}
+
+static inline bool bnx2x_parity_attn(struct bnx2x *bp, u32 sig0, u32 s=
ig1,
+				     u32 sig2, u32 sig3)
+{
+	if ((sig0 & HW_PRTY_ASSERT_SET_0) || (sig1 & HW_PRTY_ASSERT_SET_1) ||
+	    (sig2 & HW_PRTY_ASSERT_SET_2) || (sig3 & HW_PRTY_ASSERT_SET_3)) {
+		int par_num =3D 0;
+		DP(NETIF_MSG_HW, "Was parity error: HW block parity attention: "
+			"[0]:0x%08x [1]:0x%08x "
+			"[2]:0x%08x [3]:0x%08x\n",
+			  sig0 & HW_PRTY_ASSERT_SET_0,
+			  sig1 & HW_PRTY_ASSERT_SET_1,
+			  sig2 & HW_PRTY_ASSERT_SET_2,
+			  sig3 & HW_PRTY_ASSERT_SET_3);
+		printk(KERN_ERR"%s: Parity errors detected in blocks: ",
+		       bp->dev->name);
+		par_num =3D bnx2x_print_blocks_with_parity0(
+			sig0 & HW_PRTY_ASSERT_SET_0, par_num);
+		par_num =3D bnx2x_print_blocks_with_parity1(
+			sig1 & HW_PRTY_ASSERT_SET_1, par_num);
+		par_num =3D bnx2x_print_blocks_with_parity2(
+			sig2 & HW_PRTY_ASSERT_SET_2, par_num);
+		par_num =3D bnx2x_print_blocks_with_parity3(
+			sig3 & HW_PRTY_ASSERT_SET_3, par_num);
+		printk("\n");
+		return true;
+	} else
+		return false;
+}
+
+static bool bnx2x_chk_parity_attn(struct bnx2x *bp)
 {
 	struct attn_route attn;
-	struct attn_route group_mask;
+	int port =3D BP_PORT(bp);
+
+	attn.sig[0] =3D REG_RD(bp,
+		MISC_REG_AEU_AFTER_INVERT_1_FUNC_0 +
+			     port*4);
+	attn.sig[1] =3D REG_RD(bp,
+		MISC_REG_AEU_AFTER_INVERT_2_FUNC_0 +
+			     port*4);
+	attn.sig[2] =3D REG_RD(bp,
+		MISC_REG_AEU_AFTER_INVERT_3_FUNC_0 +
+			     port*4);
+	attn.sig[3] =3D REG_RD(bp,
+		MISC_REG_AEU_AFTER_INVERT_4_FUNC_0 +
+			     port*4);
+
+	return bnx2x_parity_attn(bp, attn.sig[0], attn.sig[1], attn.sig[2],
+					attn.sig[3]);
+}
+
+static void bnx2x_attn_int_deasserted(struct bnx2x *bp, u32 deasserted=
)
+{
+	struct attn_route attn, *group_mask;
 	int port =3D BP_PORT(bp);
 	int index;
 	u32 reg_addr;
@@ -3119,6 +3453,19 @@ static void bnx2x_attn_int_deasserted(struct bnx=
2x *bp, u32 deasserted)
 	   try to handle this event */
 	bnx2x_acquire_alr(bp);
=20
+	if (bnx2x_chk_parity_attn(bp)) {
+		bp->recovery_state =3D BNX2X_RECOVERY_INIT;
+		bnx2x_set_reset_in_progress(bp);
+		schedule_delayed_work(&bp->reset_task, 0);
+		/* Disable HW interrupts */
+		bnx2x_int_disable(bp);
+		bnx2x_release_alr(bp);
+		/* In case of parity errors don't handle attentions so that
+		 * other function would "see" parity errors.
+		 */
+		return;
+	}
+
 	attn.sig[0] =3D REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_1_FUNC_0 + port*=
4);
 	attn.sig[1] =3D REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_2_FUNC_0 + port*=
4);
 	attn.sig[2] =3D REG_RD(bp, MISC_REG_AEU_AFTER_INVERT_3_FUNC_0 + port*=
4);
@@ -3128,28 +3475,20 @@ static void bnx2x_attn_int_deasserted(struct bn=
x2x *bp, u32 deasserted)
=20
 	for (index =3D 0; index < MAX_DYNAMIC_ATTN_GRPS; index++) {
 		if (deasserted & (1 << index)) {
-			group_mask =3D bp->attn_group[index];
+			group_mask =3D &bp->attn_group[index];
=20
 			DP(NETIF_MSG_HW, "group[%d]: %08x %08x %08x %08x\n",
-			   index, group_mask.sig[0], group_mask.sig[1],
-			   group_mask.sig[2], group_mask.sig[3]);
+			   index, group_mask->sig[0], group_mask->sig[1],
+			   group_mask->sig[2], group_mask->sig[3]);
=20
 			bnx2x_attn_int_deasserted3(bp,
-					attn.sig[3] & group_mask.sig[3]);
+					attn.sig[3] & group_mask->sig[3]);
 			bnx2x_attn_int_deasserted1(bp,
-					attn.sig[1] & group_mask.sig[1]);
+					attn.sig[1] & group_mask->sig[1]);
 			bnx2x_attn_int_deasserted2(bp,
-					attn.sig[2] & group_mask.sig[2]);
+					attn.sig[2] & group_mask->sig[2]);
 			bnx2x_attn_int_deasserted0(bp,
-					attn.sig[0] & group_mask.sig[0]);
-
-			if ((attn.sig[0] & group_mask.sig[0] &
-						HW_PRTY_ASSERT_SET_0) ||
-			    (attn.sig[1] & group_mask.sig[1] &
-						HW_PRTY_ASSERT_SET_1) ||
-			    (attn.sig[2] & group_mask.sig[2] &
-						HW_PRTY_ASSERT_SET_2))
-				BNX2X_ERR("FATAL HW block parity attention\n");
+					attn.sig[0] & group_mask->sig[0]);
 		}
 	}
=20
@@ -3173,7 +3512,7 @@ static void bnx2x_attn_int_deasserted(struct bnx2=
x *bp, u32 deasserted)
=20
 	DP(NETIF_MSG_HW, "aeu_mask %x  newly deasserted %x\n",
 	   aeu_mask, deasserted);
-	aeu_mask |=3D (deasserted & 0xff);
+	aeu_mask |=3D (deasserted & 0x3ff);
 	DP(NETIF_MSG_HW, "new mask %x\n", aeu_mask);
=20
 	REG_WR(bp, reg_addr, aeu_mask);
@@ -5963,6 +6302,50 @@ static void enable_blocks_attention(struct bnx2x=
 *bp)
 	REG_WR(bp, PBF_REG_PBF_INT_MASK, 0X18);		/* bit 3,4 masked */
 }
=20
+static const struct {
+	u32 addr;
+	u32 mask;
+} bnx2x_parity_mask[] =3D {
+	{PXP_REG_PXP_PRTY_MASK, 0xffffffff},
+	{PXP2_REG_PXP2_PRTY_MASK_0, 0xffffffff},
+	{PXP2_REG_PXP2_PRTY_MASK_1, 0xffffffff},
+	{HC_REG_HC_PRTY_MASK, 0xffffffff},
+	{MISC_REG_MISC_PRTY_MASK, 0xffffffff},
+	{QM_REG_QM_PRTY_MASK, 0x0},
+	{DORQ_REG_DORQ_PRTY_MASK, 0x0},
+	{GRCBASE_UPB + PB_REG_PB_PRTY_MASK, 0x0},
+	{GRCBASE_XPB + PB_REG_PB_PRTY_MASK, 0x0},
+	{SRC_REG_SRC_PRTY_MASK, 0x4}, /* bit 2 */
+	{CDU_REG_CDU_PRTY_MASK, 0x0},
+	{CFC_REG_CFC_PRTY_MASK, 0x0},
+	{DBG_REG_DBG_PRTY_MASK, 0x0},
+	{DMAE_REG_DMAE_PRTY_MASK, 0x0},
+	{BRB1_REG_BRB1_PRTY_MASK, 0x0},
+	{PRS_REG_PRS_PRTY_MASK, (1<<6)},/* bit 6 */
+	{TSDM_REG_TSDM_PRTY_MASK, 0x18},/* bit 3,4 */
+	{CSDM_REG_CSDM_PRTY_MASK, 0x8},	/* bit 3 */
+	{USDM_REG_USDM_PRTY_MASK, 0x38},/* bit 3,4,5 */
+	{XSDM_REG_XSDM_PRTY_MASK, 0x8},	/* bit 3 */
+	{TSEM_REG_TSEM_PRTY_MASK_0, 0x0},
+	{TSEM_REG_TSEM_PRTY_MASK_1, 0x0},
+	{USEM_REG_USEM_PRTY_MASK_0, 0x0},
+	{USEM_REG_USEM_PRTY_MASK_1, 0x0},
+	{CSEM_REG_CSEM_PRTY_MASK_0, 0x0},
+	{CSEM_REG_CSEM_PRTY_MASK_1, 0x0},
+	{XSEM_REG_XSEM_PRTY_MASK_0, 0x0},
+	{XSEM_REG_XSEM_PRTY_MASK_1, 0x0}
+};
+
+static void enable_blocks_parity(struct bnx2x *bp)
+{
+	int i, mask_arr_len =3D
+		sizeof(bnx2x_parity_mask)/(sizeof(bnx2x_parity_mask[0]));
+
+	for (i =3D 0; i < mask_arr_len; i++)
+		REG_WR(bp, bnx2x_parity_mask[i].addr,
+			bnx2x_parity_mask[i].mask);
+}
+
=20
 static void bnx2x_reset_common(struct bnx2x *bp)
 {
@@ -6306,6 +6689,8 @@ static int bnx2x_init_common(struct bnx2x *bp)
 	REG_RD(bp, PXP2_REG_PXP2_INT_STS_CLR_0);
=20
 	enable_blocks_attention(bp);
+	if (CHIP_PARITY_SUPPORTED(bp))
+		enable_blocks_parity(bp);
=20
 	if (!BP_NOMCP(bp)) {
 		bnx2x_acquire_phy_lock(bp);
@@ -7657,6 +8042,7 @@ static int bnx2x_nic_load(struct bnx2x *bp, int l=
oad_mode)
 	if (bp->state =3D=3D BNX2X_STATE_OPEN)
 		bnx2x_cnic_notify(bp, CNIC_CTL_START_CMD);
 #endif
+	bnx2x_inc_load_cnt(bp);
=20
 	return 0;
=20
@@ -7844,33 +8230,12 @@ static void bnx2x_reset_chip(struct bnx2x *bp, =
u32 reset_code)
 	}
 }
=20
-/* must be called with rtnl_lock */
-static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
+static void bnx2x_chip_cleanup(struct bnx2x *bp, int unload_mode)
 {
 	int port =3D BP_PORT(bp);
 	u32 reset_code =3D 0;
 	int i, cnt, rc;
=20
-#ifdef BCM_CNIC
-	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
-#endif
-	bp->state =3D BNX2X_STATE_CLOSING_WAIT4_HALT;
-
-	/* Set "drop all" */
-	bp->rx_mode =3D BNX2X_RX_MODE_NONE;
-	bnx2x_set_storm_rx_mode(bp);
-
-	/* Disable HW interrupts, NAPI and Tx */
-	bnx2x_netif_stop(bp, 1);
-
-	del_timer_sync(&bp->timer);
-	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
-		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
-	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
-
-	/* Release IRQs */
-	bnx2x_free_irq(bp, false);
-
 	/* Wait until tx fastpath tasks complete */
 	for_each_queue(bp, i) {
 		struct bnx2x_fastpath *fp =3D &bp->fp[i];
@@ -8011,6 +8376,69 @@ unload_error:
 	if (!BP_NOMCP(bp))
 		bnx2x_fw_command(bp, DRV_MSG_CODE_UNLOAD_DONE);
=20
+}
+
+static inline void bnx2x_disable_close_the_gate(struct bnx2x *bp)
+{
+	u32 val;
+
+	DP(NETIF_MSG_HW, "Disabling \"close the gates\"\n");
+
+	if (CHIP_IS_E1(bp)) {
+		int port =3D BP_PORT(bp);
+		u32 addr =3D port ? MISC_REG_AEU_MASK_ATTN_FUNC_1 :
+			MISC_REG_AEU_MASK_ATTN_FUNC_0;
+
+		val =3D REG_RD(bp, addr);
+		val &=3D ~(0x300);
+		REG_WR(bp, addr, val);
+	} else if (CHIP_IS_E1H(bp)) {
+		val =3D REG_RD(bp, MISC_REG_AEU_GENERAL_MASK);
+		val &=3D ~(MISC_AEU_GENERAL_MASK_REG_AEU_PXP_CLOSE_MASK |
+			 MISC_AEU_GENERAL_MASK_REG_AEU_NIG_CLOSE_MASK);
+		REG_WR(bp, MISC_REG_AEU_GENERAL_MASK, val);
+	}
+}
+
+/* must be called with rtnl_lock */
+static int bnx2x_nic_unload(struct bnx2x *bp, int unload_mode)
+{
+	int i;
+
+	if (bp->state =3D=3D BNX2X_STATE_CLOSED) {
+		/* Interface has been removed - nothing to recover */
+		bp->recovery_state =3D BNX2X_RECOVERY_DONE;
+		bp->is_leader =3D 0;
+		bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
+		smp_wmb();
+
+		return -EINVAL;
+	}
+
+#ifdef BCM_CNIC
+	bnx2x_cnic_notify(bp, CNIC_CTL_STOP_CMD);
+#endif
+	bp->state =3D BNX2X_STATE_CLOSING_WAIT4_HALT;
+
+	/* Set "drop all" */
+	bp->rx_mode =3D BNX2X_RX_MODE_NONE;
+	bnx2x_set_storm_rx_mode(bp);
+
+	/* Disable HW interrupts, NAPI and Tx */
+	bnx2x_netif_stop(bp, 1);
+
+	del_timer_sync(&bp->timer);
+	SHMEM_WR(bp, func_mb[BP_FUNC(bp)].drv_pulse_mb,
+		 (DRV_PULSE_ALWAYS_ALIVE | bp->fw_drv_pulse_wr_seq));
+	bnx2x_stats_handle(bp, STATS_EVENT_STOP);
+
+	/* Release IRQs */
+	bnx2x_free_irq(bp, false);
+
+	/* Cleanup the chip if needed */
+	if (unload_mode !=3D UNLOAD_RECOVERY)
+		bnx2x_chip_cleanup(bp, unload_mode);
+
 	bp->port.pmf =3D 0;
=20
 	/* Free SKBs, SGEs, TPA pool and driver internals */
@@ -8025,17 +8453,448 @@ unload_error:
=20
 	netif_carrier_off(bp->dev);
=20
+	/* The last driver must disable a "close the gate" if there is no
+	 * parity attention or "process kill" pending.
+	 */
+	if ((!bnx2x_dec_load_cnt(bp)) && (!bnx2x_chk_parity_attn(bp)) &&
+	    bnx2x_reset_is_done(bp))
+		bnx2x_disable_close_the_gate(bp);
+
+	/* Reset MCP mail box sequence if there is on going recovery */
+	if (unload_mode =3D=3D UNLOAD_RECOVERY)
+		bp->fw_seq =3D 0;
+
+	return 0;
+}
+
+/* Close gates #2, #3 and #4: */
+static void bnx2x_set_234_gates(struct bnx2x *bp, bool close)
+{
+	u32 val, addr;
+
+	/* Gates #2 and #4a are closed/opened for "not E1" only */
+	if (!CHIP_IS_E1(bp)) {
+		/* #4 */
+		val =3D REG_RD(bp, PXP_REG_HST_DISCARD_DOORBELLS);
+		REG_WR(bp, PXP_REG_HST_DISCARD_DOORBELLS,
+		       close ? (val | 0x1) : (val & (~(u32)1)));
+		/* #2 */
+		val =3D REG_RD(bp, PXP_REG_HST_DISCARD_INTERNAL_WRITES);
+		REG_WR(bp, PXP_REG_HST_DISCARD_INTERNAL_WRITES,
+		       close ? (val | 0x1) : (val & (~(u32)1)));
+	}
+
+	/* #3 */
+	addr =3D BP_PORT(bp) ? HC_REG_CONFIG_1 : HC_REG_CONFIG_0;
+	val =3D REG_RD(bp, addr);
+	REG_WR(bp, addr, (!close) ? (val | 0x1) : (val & (~(u32)1)));
+
+	DP(NETIF_MSG_HW, "%s gates #2, #3 and #4\n",
+		close ? "closing" : "opening");
+	mmiowb();
+}
+
+#define SHARED_MF_CLP_MAGIC  0x80000000 /* `magic' bit */
+
+static void bnx2x_clp_reset_prep(struct bnx2x *bp, u32 *magic_val)
+{
+	/* Do some magic... */
+	u32 val =3D MF_CFG_RD(bp, shared_mf_config.clp_mb);
+	*magic_val =3D val & SHARED_MF_CLP_MAGIC;
+	MF_CFG_WR(bp, shared_mf_config.clp_mb, val | SHARED_MF_CLP_MAGIC);
+}
+
+/* Restore the value of the `magic' bit.
+ *
+ * @param pdev Device handle.
+ * @param magic_val Old value of the `magic' bit.
+ */
+static void bnx2x_clp_reset_done(struct bnx2x *bp, u32 magic_val)
+{
+	/* Restore the `magic' bit value... */
+	/* u32 val =3D SHMEM_RD(bp, mf_cfg.shared_mf_config.clp_mb);
+	SHMEM_WR(bp, mf_cfg.shared_mf_config.clp_mb,
+		(val & (~SHARED_MF_CLP_MAGIC)) | magic_val); */
+	u32 val =3D MF_CFG_RD(bp, shared_mf_config.clp_mb);
+	MF_CFG_WR(bp, shared_mf_config.clp_mb,
+		(val & (~SHARED_MF_CLP_MAGIC)) | magic_val);
+}
+
+/* Prepares for MCP reset: takes care of CLP configurations.
+ *
+ * @param bp
+ * @param magic_val Old value of 'magic' bit.
+ */
+static void bnx2x_reset_mcp_prep(struct bnx2x *bp, u32 *magic_val)
+{
+	u32 shmem;
+	u32 validity_offset;
+
+	DP(NETIF_MSG_HW, "Starting\n");
+
+	/* Set `magic' bit in order to save MF config */
+	if (!CHIP_IS_E1(bp))
+		bnx2x_clp_reset_prep(bp, magic_val);
+
+	/* Get shmem offset */
+	shmem =3D REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+	validity_offset =3D offsetof(struct shmem_region, validity_map[0]);
+
+	/* Clear validity map flags */
+	if (shmem > 0)
+		REG_WR(bp, shmem + validity_offset, 0);
+}
+
+#define MCP_TIMEOUT      5000   /* 5 seconds (in ms) */
+#define MCP_ONE_TIMEOUT  100    /* 100 ms */
+
+/* Waits for MCP_ONE_TIMEOUT or MCP_ONE_TIMEOUT*10,
+ * depending on the HW type.
+ *
+ * @param bp
+ */
+static inline void bnx2x_mcp_wait_one(struct bnx2x *bp)
+{
+	/* special handling for emulation and FPGA,
+	   wait 10 times longer */
+	if (CHIP_REV_IS_SLOW(bp))
+		msleep(MCP_ONE_TIMEOUT*10);
+	else
+		msleep(MCP_ONE_TIMEOUT);
+}
+
+static int bnx2x_reset_mcp_comp(struct bnx2x *bp, u32 magic_val)
+{
+	u32 shmem, cnt, validity_offset, val;
+	int rc =3D 0;
+
+	msleep(100);
+
+	/* Get shmem offset */
+	shmem =3D REG_RD(bp, MISC_REG_SHARED_MEM_ADDR);
+	if (shmem =3D=3D 0) {
+		BNX2X_ERR("Shmem 0 return failure\n");
+		rc =3D -ENOTTY;
+		goto exit_lbl;
+	}
+
+	validity_offset =3D offsetof(struct shmem_region, validity_map[0]);
+
+	/* Wait for MCP to come up */
+	for (cnt =3D 0; cnt < (MCP_TIMEOUT / MCP_ONE_TIMEOUT); cnt++) {
+		/* TBD: its best to check validity map of last port.
+		 * currently checks on port 0.
+		 */
+		val =3D REG_RD(bp, shmem + validity_offset);
+		DP(NETIF_MSG_HW, "shmem 0x%x validity map(0x%x)=3D0x%x\n", shmem,
+		   shmem + validity_offset, val);
+
+		/* check that shared memory is valid. */
+		if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+		    =3D=3D (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB))
+			break;
+
+		bnx2x_mcp_wait_one(bp);
+	}
+
+	DP(NETIF_MSG_HW, "Cnt=3D%d Shmem validity map 0x%x\n", cnt, val);
+
+	/* Check that shared memory is valid. This indicates that MCP is up. =
*/
+	if ((val & (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB)) !=3D
+	    (SHR_MEM_VALIDITY_DEV_INFO | SHR_MEM_VALIDITY_MB)) {
+		BNX2X_ERR("Shmem signature not present. MCP is not up !!\n");
+		rc =3D -ENOTTY;
+		goto exit_lbl;
+	}
+
+exit_lbl:
+	/* Restore the `magic' bit value */
+	if (!CHIP_IS_E1(bp))
+		bnx2x_clp_reset_done(bp, magic_val);
+
+	return rc;
+}
+
+static void bnx2x_pxp_prep(struct bnx2x *bp)
+{
+	if (!CHIP_IS_E1(bp)) {
+		REG_WR(bp, PXP2_REG_RD_START_INIT, 0);
+		REG_WR(bp, PXP2_REG_RQ_RBC_DONE, 0);
+		REG_WR(bp, PXP2_REG_RQ_CFG_DONE, 0);
+		mmiowb();
+	}
+}
+
+/*
+ * Reset the whole chip except for:
+ *      - PCIE core
+ *      - PCI Glue, PSWHST, PXP/PXP2 RF (all controlled by
+ *              one reset bit)
+ *      - IGU
+ *      - MISC (including AEU)
+ *      - GRC
+ *      - RBCN, RBCP
+ */
+static void bnx2x_process_kill_chip_reset(struct bnx2x *bp)
+{
+	u32 not_reset_mask1, reset_mask1, not_reset_mask2, reset_mask2;
+
+	not_reset_mask1 =3D
+		MISC_REGISTERS_RESET_REG_1_RST_HC |
+		MISC_REGISTERS_RESET_REG_1_RST_PXPV |
+		MISC_REGISTERS_RESET_REG_1_RST_PXP;
+
+	not_reset_mask2 =3D
+		MISC_REGISTERS_RESET_REG_2_RST_MDIO |
+		MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE |
+		MISC_REGISTERS_RESET_REG_2_RST_EMAC1_HARD_CORE |
+		MISC_REGISTERS_RESET_REG_2_RST_MISC_CORE |
+		MISC_REGISTERS_RESET_REG_2_RST_RBCN |
+		MISC_REGISTERS_RESET_REG_2_RST_GRC  |
+		MISC_REGISTERS_RESET_REG_2_RST_MCP_N_RESET_REG_HARD_CORE |
+		MISC_REGISTERS_RESET_REG_2_RST_MCP_N_HARD_CORE_RST_B;
+
+	reset_mask1 =3D 0xffffffff;
+
+	if (CHIP_IS_E1(bp))
+		reset_mask2 =3D 0xffff;
+	else
+		reset_mask2 =3D 0x1ffff;
+
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_CLEAR,
+	       reset_mask1 & (~not_reset_mask1));
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_CLEAR,
+	       reset_mask2 & (~not_reset_mask2));
+
+	barrier();
+	mmiowb();
+
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_1_SET, reset_mask1=
);
+	REG_WR(bp, GRCBASE_MISC + MISC_REGISTERS_RESET_REG_2_SET, reset_mask2=
);
+	mmiowb();
+}
+
+static int bnx2x_process_kill(struct bnx2x *bp)
+{
+	int cnt =3D 1000;
+	u32 val =3D 0;
+	u32 sr_cnt, blk_cnt, port_is_idle_0, port_is_idle_1, pgl_exp_rom2;
+
+
+	/* Empty the Tetris buffer, wait for 1s */
+	do {
+		sr_cnt  =3D REG_RD(bp, PXP2_REG_RD_SR_CNT);
+		blk_cnt =3D REG_RD(bp, PXP2_REG_RD_BLK_CNT);
+		port_is_idle_0 =3D REG_RD(bp, PXP2_REG_RD_PORT_IS_IDLE_0);
+		port_is_idle_1 =3D REG_RD(bp, PXP2_REG_RD_PORT_IS_IDLE_1);
+		pgl_exp_rom2 =3D REG_RD(bp, PXP2_REG_PGL_EXP_ROM2);
+		if ((sr_cnt =3D=3D 0x7e) && (blk_cnt =3D=3D 0xa0) &&
+		    ((port_is_idle_0 & 0x1) =3D=3D 0x1) &&
+		    ((port_is_idle_1 & 0x1) =3D=3D 0x1) &&
+		    (pgl_exp_rom2 =3D=3D 0xffffffff))
+			break;
+		msleep(1);
+	} while (cnt-- > 0);
+
+	if (cnt <=3D 0) {
+		DP(NETIF_MSG_HW, "Tetris buffer didn't get empty or there"
+			  " are still"
+			  " outstanding read requests after 1s!\n");
+		DP(NETIF_MSG_HW, "sr_cnt=3D0x%08x, blk_cnt=3D0x%08x,"
+			  " port_is_idle_0=3D0x%08x,"
+			  " port_is_idle_1=3D0x%08x, pgl_exp_rom2=3D0x%08x\n",
+			  sr_cnt, blk_cnt, port_is_idle_0, port_is_idle_1,
+			  pgl_exp_rom2);
+		return -EAGAIN;
+	}
+
+	barrier();
+
+	/* Close gates #2, #3 and #4 */
+	bnx2x_set_234_gates(bp, true);
+
+	/* TBD: Indicate that "process kill" is in progress to MCP */
+
+	/* Clear "unprepared" bit */
+	REG_WR(bp, MISC_REG_UNPREPARED, 0);
+	barrier();
+
+	/* Make sure all is written to the chip before the reset */
+	mmiowb();
+
+	/* Wait for 1ms to empty GLUE and PCI-E core queues,
+	 * PSWHST, GRC and PSWRD Tetris buffer.
+	 */
+	msleep(1);
+
+	/* Prepare to chip reset: */
+	/* MCP */
+	bnx2x_reset_mcp_prep(bp, &val);
+
+	/* PXP */
+	bnx2x_pxp_prep(bp);
+	barrier();
+
+	/* reset the chip */
+	bnx2x_process_kill_chip_reset(bp);
+	barrier();
+
+	/* Recover after reset: */
+	/* MCP */
+	if (bnx2x_reset_mcp_comp(bp, val))
+		return -EAGAIN;
+
+	/* PXP */
+	bnx2x_pxp_prep(bp);
+
+	/* Open the gates #2, #3 and #4 */
+	bnx2x_set_234_gates(bp, false);
+
+	/* TBD: IGU/AEU preparation bring back the AEU/IGU to a
+	 * reset state, re-enable attentions. */
+
 	return 0;
 }
=20
+static int bnx2x_leader_reset(struct bnx2x *bp)
+{
+	int rc =3D 0;
+	/* Try to recover after the failure */
+	if (bnx2x_process_kill(bp)) {
+		printk(KERN_ERR "%s: Something bad had happen! Aii!\n",
+		       bp->dev->name);
+		rc =3D -EAGAIN;
+		goto exit_leader_reset;
+	}
+
+	/* Clear "reset is in progress" bit and update the driver state */
+	bnx2x_set_reset_done(bp);
+	bp->recovery_state =3D BNX2X_RECOVERY_DONE;
+
+exit_leader_reset:
+	bp->is_leader =3D 0;
+	bnx2x_release_hw_lock(bp, HW_LOCK_RESOURCE_RESERVED_08);
+	smp_wmb();
+	return rc;
+}
+
+static int bnx2x_set_power_state(struct bnx2x *bp, pci_power_t state);
+
+/* Assumption: runs under rtnl lock. This together with the fact
+ * that it's called only from bnx2x_reset_task() ensure that it
+ * will never be called when netif_running(bp->dev) is false.
+ */
+static void bnx2x_parity_recover(struct bnx2x *bp)
+{
+	DP(NETIF_MSG_HW, "Handling parity\n");
+	while (1) {
+		switch (bp->recovery_state) {
+		case BNX2X_RECOVERY_INIT:
+			DP(NETIF_MSG_HW, "State is BNX2X_RECOVERY_INIT\n");
+			/* Try to get a LEADER_LOCK HW lock */
+			if (bnx2x_trylock_hw_lock(bp,
+				HW_LOCK_RESOURCE_RESERVED_08))
+				bp->is_leader =3D 1;
+
+			/* Stop the driver */
+			/* If interface has been removed - break */
+			if (bnx2x_nic_unload(bp, UNLOAD_RECOVERY))
+				return;
+
+			bp->recovery_state =3D BNX2X_RECOVERY_WAIT;
+			/* Ensure "is_leader" and "recovery_state"
+			 *  update values are seen on other CPUs
+			 */
+			smp_wmb();
+			break;
+
+		case BNX2X_RECOVERY_WAIT:
+			DP(NETIF_MSG_HW, "State is BNX2X_RECOVERY_WAIT\n");
+			if (bp->is_leader) {
+				u32 load_counter =3D bnx2x_get_load_cnt(bp);
+				if (load_counter) {
+					/* Wait until all other functions get
+					 * down.
+					 */
+					schedule_delayed_work(&bp->reset_task,
+								HZ/10);
+					return;
+				} else {
+					/* If all other functions got down -
+					 * try to bring the chip back to
+					 * normal. In any case it's an exit
+					 * point for a leader.
+					 */
+					if (bnx2x_leader_reset(bp) ||
+					bnx2x_nic_load(bp, LOAD_NORMAL)) {
+						printk(KERN_ERR"%s: Recovery "
+						"has failed. Power cycle is "
+						"needed.\n", bp->dev->name);
+						/* Disconnect this device */
+						netif_device_detach(bp->dev);
+						/* Block ifup for all function
+						 * of this ASIC until
+						 * "process kill" or power
+						 * cycle.
+						 */
+						bnx2x_set_reset_in_progress(bp);
+						/* Shut down the power */
+						bnx2x_set_power_state(bp,
+								PCI_D3hot);
+						return;
+					}
+
+					return;
+				}
+			} else { /* non-leader */
+				if (!bnx2x_reset_is_done(bp)) {
+					/* Try to get a LEADER_LOCK HW lock as
+					 * long as a former leader may have
+					 * been unloaded by the user or
+					 * released a leadership by another
+					 * reason.
+					 */
+					if (bnx2x_trylock_hw_lock(bp,
+					    HW_LOCK_RESOURCE_RESERVED_08)) {
+						/* I'm a leader now! Restart a
+						 * switch case.
+						 */
+						bp->is_leader =3D 1;
+						break;
+					}
+
+					schedule_delayed_work(&bp->reset_task,
+								HZ/10);
+					return;
+
+				} else { /* A leader has completed
+					  * the "process kill". It's an exit
+					  * point for a non-leader.
+					  */
+					bnx2x_nic_load(bp, LOAD_NORMAL);
+					bp->recovery_state =3D
+						BNX2X_RECOVERY_DONE;
+					smp_wmb();
+					return;
+				}
+			}
+		default:
+			return;
+		}
+	}
+}
+
+/* bnx2x_nic_unload() flushes the bnx2x_wq, thus reset task is
+ * scheduled on a general queue in order to prevent a dead lock.
+ */
 static void bnx2x_reset_task(struct work_struct *work)
 {
-	struct bnx2x *bp =3D container_of(work, struct bnx2x, reset_task);
+	struct bnx2x *bp =3D container_of(work, struct bnx2x, reset_task.work=
);
=20
 #ifdef BNX2X_STOP_ON_ERROR
 	BNX2X_ERR("reset task called but STOP_ON_ERROR defined"
 		  " so reset not done to allow debug dump,\n"
-		  " you will need to reboot when done\n");
+	 KERN_ERR " you will need to reboot when done\n");
 	return;
 #endif
=20
@@ -8044,8 +8903,12 @@ static void bnx2x_reset_task(struct work_struct =
*work)
 	if (!netif_running(bp->dev))
 		goto reset_task_exit;
=20
-	bnx2x_nic_unload(bp, UNLOAD_NORMAL);
-	bnx2x_nic_load(bp, LOAD_NORMAL);
+	if (unlikely(bp->recovery_state !=3D BNX2X_RECOVERY_DONE))
+		bnx2x_parity_recover(bp);
+	else {
+		bnx2x_nic_unload(bp, UNLOAD_NORMAL);
+		bnx2x_nic_load(bp, LOAD_NORMAL);
+	}
=20
 reset_task_exit:
 	rtnl_unlock();
@@ -8913,7 +9776,7 @@ static int __devinit bnx2x_init_bp(struct bnx2x *=
bp)
 #endif
=20
 	INIT_DELAYED_WORK(&bp->sp_task, bnx2x_sp_task);
-	INIT_WORK(&bp->reset_task, bnx2x_reset_task);
+	INIT_DELAYED_WORK(&bp->reset_task, bnx2x_reset_task);
=20
 	rc =3D bnx2x_get_hwinfo(bp);
=20
@@ -9888,6 +10751,11 @@ static int bnx2x_set_ringparam(struct net_devic=
e *dev,
 	struct bnx2x *bp =3D netdev_priv(dev);
 	int rc =3D 0;
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		return -EAGAIN;
+	}
+
 	if ((ering->rx_pending > MAX_RX_AVAIL) ||
 	    (ering->tx_pending > MAX_TX_AVAIL) ||
 	    (ering->tx_pending <=3D MAX_SKB_FRAGS + 4))
@@ -9973,6 +10841,11 @@ static int bnx2x_set_flags(struct net_device *d=
ev, u32 data)
 	int changed =3D 0;
 	int rc =3D 0;
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		return -EAGAIN;
+	}
+
 	/* TPA requires Rx CSUM offloading */
 	if ((data & ETH_FLAG_LRO) && bp->rx_csum) {
 		if (!disable_tpa) {
@@ -10009,6 +10882,11 @@ static int bnx2x_set_rx_csum(struct net_device=
 *dev, u32 data)
 	struct bnx2x *bp =3D netdev_priv(dev);
 	int rc =3D 0;
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		return -EAGAIN;
+	}
+
 	bp->rx_csum =3D data;
=20
 	/* Disable TPA, when Rx CSUM is disabled. Otherwise all
@@ -10471,6 +11349,12 @@ static void bnx2x_self_test(struct net_device =
*dev,
 {
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		etest->flags |=3D ETH_TEST_FL_FAILED;
+		return;
+	}
+
 	memset(buf, 0, sizeof(u64) * BNX2X_NUM_TESTS);
=20
 	if (!netif_running(dev))
@@ -11456,6 +12340,40 @@ static int bnx2x_open(struct net_device *dev)
=20
 	bnx2x_set_power_state(bp, PCI_D0);
=20
+	if (!bnx2x_reset_is_done(bp)) {
+		do {
+			/* Reset MCP mail box sequence if there is on going
+			 * recovery
+			 */
+			bp->fw_seq =3D 0;
+
+			/* If it's the first function to load and reset done
+			 * is still not cleared it may mean that. We don't
+			 * check the attention state here because it may have
+			 * already been cleared by a "common" reset but we
+			 * shell proceed with "process kill" anyway.
+			 */
+			if ((bnx2x_get_load_cnt(bp) =3D=3D 0) &&
+				bnx2x_trylock_hw_lock(bp,
+				HW_LOCK_RESOURCE_RESERVED_08) &&
+				(!bnx2x_leader_reset(bp))) {
+				DP(NETIF_MSG_HW, "Recovered in open\n");
+				break;
+			}
+
+			bnx2x_set_power_state(bp, PCI_D3hot);
+
+			printk(KERN_ERR"%s: Recovery flow hasn't been properly"
+			" completed yet. Try again later. If u still see this"
+			" message after a few retries then power cycle is"
+			" required.\n", bp->dev->name);
+
+			return -EAGAIN;
+		} while (0);
+	}
+
+	bp->recovery_state =3D BNX2X_RECOVERY_DONE;
+
 	return bnx2x_nic_load(bp, LOAD_OPEN);
 }
=20
@@ -11694,6 +12612,11 @@ static int bnx2x_change_mtu(struct net_device =
*dev, int new_mtu)
 	struct bnx2x *bp =3D netdev_priv(dev);
 	int rc =3D 0;
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		return -EAGAIN;
+	}
+
 	if ((new_mtu > ETH_MAX_JUMBO_PACKET_SIZE) ||
 	    ((new_mtu + ETH_HLEN) < ETH_MIN_PACKET_SIZE))
 		return -EINVAL;
@@ -11721,7 +12644,7 @@ static void bnx2x_tx_timeout(struct net_device =
*dev)
 		bnx2x_panic();
 #endif
 	/* This allows the netif to be shutdown gracefully before resetting *=
/
-	schedule_work(&bp->reset_task);
+	schedule_delayed_work(&bp->reset_task, 0);
 }
=20
 #ifdef BCM_VLAN
@@ -11880,6 +12803,9 @@ static int __devinit bnx2x_init_dev(struct pci_=
dev *pdev,
 	REG_WR(bp, PXP2_REG_PGL_ADDR_90_F0 + BP_PORT(bp)*16, 0);
 	REG_WR(bp, PXP2_REG_PGL_ADDR_94_F0 + BP_PORT(bp)*16, 0);
=20
+	/* Reset the load counter */
+	bnx2x_clear_load_cnt(bp);
+
 	dev->watchdog_timeo =3D TX_TIMEOUT;
=20
 	dev->netdev_ops =3D &bnx2x_netdev_ops;
@@ -12205,6 +13131,9 @@ static void __devexit bnx2x_remove_one(struct p=
ci_dev *pdev)
=20
 	unregister_netdev(dev);
=20
+	/* Make sure RESET task is not scheduled before continuing */
+	cancel_delayed_work_sync(&bp->reset_task);
+
 	kfree(bp->init_ops_offsets);
 	kfree(bp->init_ops);
 	kfree(bp->init_data);
@@ -12268,6 +13197,11 @@ static int bnx2x_resume(struct pci_dev *pdev)
 	}
 	bp =3D netdev_priv(dev);
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		return -EAGAIN;
+	}
+
 	rtnl_lock();
=20
 	pci_restore_state(pdev);
@@ -12434,6 +13368,11 @@ static void bnx2x_io_resume(struct pci_dev *pd=
ev)
 	struct net_device *dev =3D pci_get_drvdata(pdev);
 	struct bnx2x *bp =3D netdev_priv(dev);
=20
+	if (bp->recovery_state !=3D BNX2X_RECOVERY_DONE) {
+		printk(KERN_ERR "Handling parity error recovery. Try again later\n")=
;
+		return;
+	}
+
 	rtnl_lock();
=20
 	bnx2x_eeh_recover(bp);
diff --git a/drivers/net/bnx2x_reg.h b/drivers/net/bnx2x_reg.h
index 944964e..a1f3bf0 100644
--- a/drivers/net/bnx2x_reg.h
+++ b/drivers/net/bnx2x_reg.h
@@ -766,6 +766,8 @@
 #define MCP_REG_MCPR_NVM_SW_ARB 				 0x86420
 #define MCP_REG_MCPR_NVM_WRITE					 0x86408
 #define MCP_REG_MCPR_SCRATCH					 0xa0000
+#define MISC_AEU_GENERAL_MASK_REG_AEU_NIG_CLOSE_MASK		 (0x1<<1)
+#define MISC_AEU_GENERAL_MASK_REG_AEU_PXP_CLOSE_MASK		 (0x1<<0)
 /* [R 32] read first 32 bit after inversion of function 0. mapped as
    follows: [0] NIG attention for function0; [1] NIG attention for
    function1; [2] GPIO1 mcp; [3] GPIO2 mcp; [4] GPIO3 mcp; [5] GPIO4 m=
cp;
@@ -1249,6 +1251,8 @@
 #define MISC_REG_E1HMF_MODE					 0xa5f8
 /* [RW 32] Debug only: spare RW register reset by core reset */
 #define MISC_REG_GENERIC_CR_0					 0xa460
+/* [RW 32] Debug only: spare RW register reset by por reset */
+#define MISC_REG_GENERIC_POR_1					 0xa474
 /* [RW 32] GPIO. [31-28] FLOAT port 0; [27-24] FLOAT port 0; When any =
of
    these bits is written as a '1'; the corresponding SPIO bit will tur=
n off
    it's drivers and become an input. This is the reset state of all GP=
IO
@@ -1438,7 +1442,7 @@
    (~misc_registers_sw_timer_cfg_4.sw_timer_cfg_4[1] ) is set */
 #define MISC_REG_SW_TIMER_RELOAD_VAL_4				 0xa2fc
 /* [RW 32] the value of the counter for sw timers1-8. there are 8 addr=
esses
-   in this register. addres 0 - timer 1; address - timer 2=EF=BF=BDadd=
ress 7 -
+   in this register. addres 0 - timer 1; address 1 - timer 2, ...  add=
ress 7 -
    timer 8 */
 #define MISC_REG_SW_TIMER_VAL					 0xa5c0
 /* [RW 1] Set by the MCP to remember if one or more of the drivers is/=
are
@@ -2407,10 +2411,16 @@
 /* [R 8] debug only: A bit mask for all PSWHST arbiter clients. '1' me=
ans
    this client is waiting for the arbiter. */
 #define PXP_REG_HST_CLIENTS_WAITING_TO_ARB			 0x103008
+/* [RW 1] When 1; doorbells are discarded and not passed to doorbell q=
ueue
+   block. Should be used for close the gates. */
+#define PXP_REG_HST_DISCARD_DOORBELLS				 0x1030a4
 /* [R 1] debug only: '1' means this PSWHST is discarding doorbells. Th=
is bit
    should update accoring to 'hst_discard_doorbells' register when the=
 state
    machine is idle */
 #define PXP_REG_HST_DISCARD_DOORBELLS_STATUS			 0x1030a0
+/* [RW 1] When 1; new internal writes arriving to the block are discar=
ded.
+   Should be used for close the gates. */
+#define PXP_REG_HST_DISCARD_INTERNAL_WRITES			 0x1030a8
 /* [R 6] debug only: A bit mask for all PSWHST internal write clients.=
 '1'
    means this PSWHST is discarding inputs from this client. Each bit s=
hould
    update accoring to 'hst_discard_internal_writes' register when the =
state
@@ -4422,11 +4432,21 @@
 #define MISC_REGISTERS_GPIO_PORT_SHIFT				 4
 #define MISC_REGISTERS_GPIO_SET_POS				 8
 #define MISC_REGISTERS_RESET_REG_1_CLEAR			 0x588
+#define MISC_REGISTERS_RESET_REG_1_RST_HC			 (0x1<<29)
 #define MISC_REGISTERS_RESET_REG_1_RST_NIG			 (0x1<<7)
+#define MISC_REGISTERS_RESET_REG_1_RST_PXP			 (0x1<<26)
+#define MISC_REGISTERS_RESET_REG_1_RST_PXPV			 (0x1<<27)
 #define MISC_REGISTERS_RESET_REG_1_SET				 0x584
 #define MISC_REGISTERS_RESET_REG_2_CLEAR			 0x598
 #define MISC_REGISTERS_RESET_REG_2_RST_BMAC0			 (0x1<<0)
 #define MISC_REGISTERS_RESET_REG_2_RST_EMAC0_HARD_CORE		 (0x1<<14)
+#define MISC_REGISTERS_RESET_REG_2_RST_EMAC1_HARD_CORE		 (0x1<<15)
+#define MISC_REGISTERS_RESET_REG_2_RST_GRC			 (0x1<<4)
+#define MISC_REGISTERS_RESET_REG_2_RST_MCP_N_HARD_CORE_RST_B	 (0x1<<6)
+#define MISC_REGISTERS_RESET_REG_2_RST_MCP_N_RESET_REG_HARD_CORE (0x1<=
<5)
+#define MISC_REGISTERS_RESET_REG_2_RST_MDIO			 (0x1<<13)
+#define MISC_REGISTERS_RESET_REG_2_RST_MISC_CORE		 (0x1<<11)
+#define MISC_REGISTERS_RESET_REG_2_RST_RBCN			 (0x1<<9)
 #define MISC_REGISTERS_RESET_REG_2_SET				 0x594
 #define MISC_REGISTERS_RESET_REG_3_CLEAR			 0x5a8
 #define MISC_REGISTERS_RESET_REG_3_MISC_NIG_MUX_SERDES0_IDDQ	 (0x1<<1)
@@ -4454,6 +4474,7 @@
 #define HW_LOCK_RESOURCE_GPIO					 1
 #define HW_LOCK_RESOURCE_MDIO					 0
 #define HW_LOCK_RESOURCE_PORT0_ATT_MASK 			 3
+#define HW_LOCK_RESOURCE_RESERVED_08				 8
 #define HW_LOCK_RESOURCE_SPIO					 2
 #define HW_LOCK_RESOURCE_UNDI					 5
 #define PRS_FLAG_OVERETH_IPV4					 1
@@ -4474,6 +4495,10 @@
 #define AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_0		      (1<<5)
 #define AEU_INPUTS_ATTN_BITS_GPIO3_FUNCTION_1		      (1<<9)
 #define AEU_INPUTS_ATTN_BITS_IGU_PARITY_ERROR		      (1<<12)
+#define AEU_INPUTS_ATTN_BITS_MCP_LATCHED_ROM_PARITY	      (1<<28)
+#define AEU_INPUTS_ATTN_BITS_MCP_LATCHED_SCPAD_PARITY	      (1<<31)
+#define AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_RX_PARITY	      (1<<29)
+#define AEU_INPUTS_ATTN_BITS_MCP_LATCHED_UMP_TX_PARITY	      (1<<30)
 #define AEU_INPUTS_ATTN_BITS_MISC_HW_INTERRUPT		      (1<<15)
 #define AEU_INPUTS_ATTN_BITS_MISC_PARITY_ERROR		      (1<<14)
 #define AEU_INPUTS_ATTN_BITS_PARSER_PARITY_ERROR	      (1<<20)
--=20
1.7.0.4




