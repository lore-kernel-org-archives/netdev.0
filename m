From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [RFC][BNX2X]: New driver for Broadcom 10Gb Ethernet.
Date: Thu, 2 Aug 2007 00:06:12 +0200
Message-ID: <200708020006.13457.mb@bu3sch.de>
References: <1185957077.5552.22.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, jeff@garzik.org, netdev@vger.kernel.org,
	eliezert@broadcom.com, lusinsky@broadcom.com, eilong@broadcom.com
To: "Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:46317
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbXHAWGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Aug 2007 18:06:51 -0400
In-Reply-To: <1185957077.5552.22.camel@dell>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 01 August 2007 10:31:17 Michael Chan wrote:

> +typedef struct {
> +	u8 reserved[64];
> +} license_key_t;

No typedef.
What is a "license key" used for, anyway?

> +#define RUN_AT(x)		(jiffies + (x))

That macro does only obfuscate code, in my opinion.
If you want jiffies+x, better opencode it.

> +typedef enum {
> +	BCM5710 = 0,
> +} board_t;

No typedef. Do
enum bnx2x_board {
	BCM5710 = 0,
};
Or something like that.

> +static struct pci_device_id bnx2x_pci_tbl[] = {

static const struct...

> +	{ PCI_VENDOR_ID_BROADCOM, PCI_DEVICE_ID_NX2_5710,
> +		PCI_ANY_ID, PCI_ANY_ID, 0, 0, BCM5710 },
> +	{ 0 }
> +};

> +static inline u32 bnx2x_bits_en(struct bnx2x *bp, u32 block, u32 reg,
> +				u32 bits)

Does that really need to be inline? I'd suggest dropping inline.

> +{
> +	u32 val = REG_RD(bp, block, reg);
> +
> +	val |= bits;
> +	REG_WR(bp, block, reg, val);
> +	return val;
> +}
> +
> +static inline u32 bnx2x_bits_dis(struct bnx2x *bp, u32 block, u32 reg,
> +				 u32 bits)

Same here.

> +{
> +	u32 val = REG_RD(bp, block, reg);
> +
> +	val &= ~bits;
> +	REG_WR(bp, block, reg, val);
> +	return val;
> +}
> +
> +static int bnx2x_mdio22_write(struct bnx2x *bp, u32 reg, u32 val)
> +{
> +	int rc;
> +	u32 tmp, i;
> +	int port = bp->port;
> +	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
> +
> +	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
> +
> +		tmp = REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_MODE);
> +		tmp &= ~EMAC_MDIO_MODE_AUTO_POLL;
> +		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
> +		REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_MODE);
> +		udelay(40);
> +	}
> +
> +	tmp = ((bp->phy_addr << 21) | (reg << 16) |
> +	       (val & EMAC_MDIO_COMM_DATA) |
> +	       EMAC_MDIO_COMM_COMMAND_WRITE_22 |
> +	       EMAC_MDIO_COMM_START_BUSY);
> +	EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, tmp);
> +
> +	for (i = 0; i < 50; i++) {
> +		udelay(10);
> +
> +		tmp = REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_COMM);
> +		if (!(tmp & EMAC_MDIO_COMM_START_BUSY)) {
> +			udelay(5);
> +			break;
> +		}
> +	}
> +
> +	if (tmp & EMAC_MDIO_COMM_START_BUSY) {
> +		BNX2X_ERR("write phy register failed\n");
> +
> +		rc = -EBUSY;
> +	} else {
> +		rc = 0;
> +	}
> +
> +	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
> +
> +		tmp = REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_MODE);
> +		tmp |= EMAC_MDIO_MODE_AUTO_POLL;
> +		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, tmp);
> +	}
> +
> +	return rc;
> +}
> +
> +static int bnx2x_mdio22_read(struct bnx2x *bp, u32 reg, u32 *ret_val)
> +{
> +	int rc;
> +	u32 val, i;
> +	int port = bp->port;
> +	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;
> +
> +	if (bp->phy_flags & PHY_INT_MODE_AUTO_POLLING_FLAG) {
> +
> +		val = REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_MODE);
> +		val &= ~EMAC_MDIO_MODE_AUTO_POLL;
> +		EMAC_WR(EMAC_REG_EMAC_MDIO_MODE, val);
> +		REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_MODE);
> +		udelay(40);
> +	}
> +
> +	val = ((bp->phy_addr << 21) | (reg << 16) |
> +	       EMAC_MDIO_COMM_COMMAND_READ_22 |
> +	       EMAC_MDIO_COMM_START_BUSY);
> +	EMAC_WR(EMAC_REG_EMAC_MDIO_COMM, val);
> +
> +	for (i = 0; i < 50; i++) {
> +		udelay(10);
> +
> +		val = REG_RD(bp, emac_base, EMAC_REG_EMAC_MDIO_COMM);
> +		if (!(val & EMAC_MDIO_COMM_START_BUSY)) {

No udelay(5) here, like in write above?

> +			val &= EMAC_MDIO_COMM_DATA;
> +			break;
> +		}
> +	}

> +static int bnx2x_mdio45_vwrite(struct bnx2x *bp, u32 reg, u32 addr, u32 val)
> +{
> +	int i;
> +	u32 rd_val;
> +
> +	for (i = 0; i < 10; i++) {
> +		bnx2x_mdio45_write(bp, reg, addr, val);
> +		mdelay(5);

Can you msleep(5) here?

> +		bnx2x_mdio45_read(bp, reg, addr, &rd_val);
> +		/* if the read value is not the same as the value we wrote,
> +		   we should write it again */
> +		if (rd_val == val) {
> +			return 0;
> +		}
> +	}
> +	BNX2X_ERR("MDIO write in CL45 failed\n");
> +	return -EBUSY;
> +}

> +/* DMAE command positions used
> + * Port0 14
> + * Port1 15
> + */
> +static void bnx2x_wb_write_dmae(struct bnx2x *bp, u32 wb_addr, u32 *wb_write,
> +				u32 wb_len)
> +{
> +	struct dmae_command *dmae = &bp->dmae;
> +	int port = bp->port;
> +	u32 *wb_comp = bnx2x_sp(bp, wb_comp);
> +
> +	memcpy(bnx2x_sp(bp, wb_write[0]), wb_write, wb_len * 4);
> +	memset(dmae, 0, sizeof(struct dmae_command));
> +
> +	dmae->opcode = (DMAE_CMD_SRC_PCI | DMAE_CMD_DST_GRC |
> +			DMAE_CMD_C_DST_PCI | DMAE_CMD_C_ENABLE |
> +			DMAE_CMD_SRC_RESET | DMAE_CMD_DST_RESET |
> +			DMAE_CMD_ENDIANITY_DW_SWAP |
> +			(port? DMAE_CMD_PORT_1 : DMAE_CMD_PORT_0));
> +	dmae->src_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_write));
> +	dmae->src_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_write));
> +	dmae->dst_addr_lo = wb_addr >> 2;
> +	dmae->dst_addr_hi = 0;
> +	dmae->len = wb_len;
> +	dmae->comp_addr_lo = U64_LO(bnx2x_sp_mapping(bp, wb_comp));
> +	dmae->comp_addr_hi = U64_HI(bnx2x_sp_mapping(bp, wb_comp));
> +	dmae->comp_val = BNX2X_WB_COMP_VAL;
> +	bnx2x_post_dmae(bp, port? 15 : 14);
> +
> +	*wb_comp = 0;

wmb();

> +	REG_WR32(bp, GRCBASE_DMAE,
> +		 (bp->port? DMAE_REGISTERS_GO_C15 :
> +			    DMAE_REGISTERS_GO_C14), 1);
> +	udelay(5);
> +	while (*wb_comp != BNX2X_WB_COMP_VAL) {
> +		udelay(5);

Not sure what this is doing here.
Do we need some DMA syncing here?

Anyway, we _do_ need a timeout here.
Probably also some kind of memory barrier, if no DMA syncing is needed.

> +	}
> +}

> +static void bnx2x_emac_enable(struct bnx2x *bp)
> +{
> +	u32 val;
> +	int port = bp->port;
> +	u32 emac_base = port ? GRCBASE_EMAC1 : GRCBASE_EMAC0;

> +	while (val & EMAC_MODE_RESET) {
> +		val = REG_RD(bp, emac_base, EMAC_REG_EMAC_MODE);
> +		DP(NETIF_MSG_LINK, "EMAC reset reg is %u\n", val);
> +	}

A timeout, please.

> +	/* reset tx part */
> +	EMAC_WR(EMAC_REG_EMAC_TX_MODE, EMAC_TX_MODE_RESET);
> +
> +	while (val & EMAC_TX_MODE_RESET) {
> +		val = REG_RD(bp, emac_base, EMAC_REG_EMAC_TX_MODE);
> +		DP(NETIF_MSG_LINK, "EMAC reset reg is %u\n", val);
> +	}

A timeout, please.

> +static void bnx2x_pbf_update(struct bnx2x *bp)
> +{
> +	int port = bp->port;
> +	u32 init_crd, crd;
> +	u32 count = 1000;
> +	u32 pause = 0;
> +
> +	/* disable port */
> +	REG_WR(bp, GRCBASE_PBF,
> +	       PBF_REGISTERS_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x1);
> +
> +	/* wait for init credit */
> +	init_crd = REG_RD(bp, GRCBASE_PBF,
> +			  PBF_REGISTERS_P0_INIT_CRD + port*4);
> +	crd = REG_RD(bp, GRCBASE_PBF, PBF_REGISTERS_P0_CREDIT + port*8);
> +	DP(NETIF_MSG_LINK, "init_crd 0x%x  crd 0x%x\n", init_crd, crd);
> +
> +	while ((init_crd != crd) && count) {
> +		mdelay(5);

msleep(5)?

> +		crd = REG_RD(bp, GRCBASE_PBF,
> +			     PBF_REGISTERS_P0_CREDIT + port*8);
> +		count--;
> +	}

> +	/* probe the credit changes */
> +	REG_WR(bp, GRCBASE_PBF, PBF_REGISTERS_INIT_P0 + port*4, 0x1);
> +	mdelay(5);

msleep(5)?

> +	REG_WR(bp, GRCBASE_PBF, PBF_REGISTERS_INIT_P0 + port*4, 0x0);
> +
> +	/* enable port */
> +	REG_WR(bp, GRCBASE_PBF,
> +	       PBF_REGISTERS_DISABLE_NEW_TASK_PROC_P0 + port*4, 0x0);
> +}

> +/* This function is called upon link interrupt */
> +static void bnx2x_link_update(struct bnx2x *bp)
> +{
> +	u32 gp_status;
> +	int port = bp->port;
> +	int i;
> +	int link_10g;
> +
> +	DP(NETIF_MSG_LINK, "port %x, is xgxs %x, stat_mask 0x%x, "
> +	   "int_mask 0x%x, saved_mask 0x%x, MI_INT %x, SERDES_LINK %x,"
> +	   " 10G %x, XGXS_LINK %x\n",
> +	   port, (bp->phy_flags & PHY_XGSX_FLAG),
> +	   REG_RD(bp, GRCBASE_NIG,
> +		  NIG_REGISTERS_STATUS_INTERRUPT_PORT0 + port*4),
> +	   REG_RD(bp, GRCBASE_NIG,
> +		  NIG_REGISTERS_MASK_INTERRUPT_PORT0 + port*4),
> +	   bp->nig_mask,
> +	   REG_RD(bp, GRCBASE_NIG,
> +		  NIG_REGISTERS_EMAC0_STATUS_MISC_MI_INT + port*0x18),
> +	   REG_RD(bp, GRCBASE_NIG,
> +		  NIG_REGISTERS_SERDES0_STATUS_LINK_STATUS + port*0x3c),
> +	   REG_RD(bp, GRCBASE_NIG,
> +		  NIG_REGISTERS_XGXS0_STATUS_LINK10G + port*0x68),
> +	   REG_RD(bp, GRCBASE_NIG,
> +		  NIG_REGISTERS_XGXS0_STATUS_LINK_STATUS + port*0x68)
> +	);
> +
> +	MDIO_SET_REG_BANK(bp, MDIO_REG_BANK_GP_STATUS);
> +	/* avoid fast toggling */
> +	for (i = 0 ; i < 10 ; i++) {
> +		mdelay(10);

msleep(10)?

> +		bnx2x_mdio22_read(bp, MDIO_GP_STATUS_TOP_AN_STATUS1,
> +				  &gp_status);
> +	}
> +
> +	bnx2x_link_settings_status(bp, gp_status);
> +
> +	/* anything 10 and over uses the bmac */
> +	link_10g = ((bp->line_speed >= SPEED_10000) &&
> +		    (bp->line_speed <= SPEED_16000));
> +
> +	bnx2x_link_int_ack(bp, link_10g);
> +
> +	/* link is up only if both local phy and external phy are up */
> +	if (bp->link_up && bnx2x_ext_phy_is_link_up(bp)) {
> +		if (link_10g) {
> +			bnx2x_bmac_enable(bp, 0);
> +			bnx2x_leds_set(bp, SPEED_10000);
> +
> +		} else {
> +			bnx2x_emac_enable(bp);
> +			bnx2x_emac_program(bp);
> +
> +			/* AN complete? */
> +			if (gp_status & MDIO_AN_CL73_OR_37_COMPLETE) {
> +				if (!(bp->phy_flags & PHY_SGMII_FLAG)) {
> +					bnx2x_set_sgmii_tx_driver(bp);
> +				}/* Not SGMII */
> +			}
> +		}
> +		bnx2x_link_up(bp);
> +
> +	} else { /* link down */
> +		bnx2x_leds_unset(bp);
> +		bnx2x_link_down(bp);
> +	}
> +}

> +static inline u16 bnx2x_update_dsb_idx(struct bnx2x *bp)

Too big for inlining.
If this func is only used in one place, gcc will inline it automatically.

> +{
> +	struct host_def_status_block *dsb = bp->def_status_blk;
> +	u16 rc = 0;
> +
> +	if (bp->def_att_idx != dsb->atten_status_block.attn_bits_index) {
> +		bp->def_att_idx = dsb->atten_status_block.attn_bits_index;
> +		rc |= 1;
> +	}
> +	if (bp->def_c_idx != dsb->c_def_status_block.status_block_index) {
> +		bp->def_c_idx = dsb->c_def_status_block.status_block_index;
> +		rc |= 2;
> +	}
> +	if (bp->def_u_idx != dsb->u_def_status_block.status_block_index) {
> +		bp->def_u_idx = dsb->u_def_status_block.status_block_index;
> +		rc |= 4;
> +	}
> +	if (bp->def_x_idx != dsb->x_def_status_block.status_block_index) {
> +		bp->def_x_idx = dsb->x_def_status_block.status_block_index;
> +		rc |= 8;
> +	}
> +	if (bp->def_t_idx != dsb->t_def_status_block.status_block_index) {
> +		bp->def_t_idx = dsb->t_def_status_block.status_block_index;
> +		rc |= 16;
> +	}
> +	rmb(); /* TBD chack this */
> +	return rc;
> +}
> +
> +static inline u16 bnx2x_update_fpsb_idx(struct bnx2x_fastpath *fp)

Too big for inlining.

> +{
> +	struct host_status_block *fpsb = fp->status_blk;
> +	u16 rc = 0;
> +
> +	if (fp->fp_c_idx != fpsb->c_status_block.status_block_index) {
> +		fp->fp_c_idx = fpsb->c_status_block.status_block_index;
> +		rc |= 1;
> +	}
> +	if (fp->fp_u_idx != fpsb->u_status_block.status_block_index) {
> +		fp->fp_u_idx = fpsb->u_status_block.status_block_index;
> +		rc |= 2;
> +	}
> +	rmb(); /* TBD chack this */
> +	return rc;
> +}
> +
> +static inline u32 bnx2x_tx_avail(struct bnx2x_fastpath *fp)

Too big for inlining.

> +{
> +	u16 used;
> +	u32 prod = fp->tx_bd_prod;
> +	u32 cons = fp->tx_bd_cons;
> +
> +	smp_mb();

This barrier needs a comment. Why is it there? And why SMP only?

> +
> +	used = (NUM_TX_BD - NUM_TX_RINGS + prod - cons +
> +		(cons / TX_DESC_CNT) - (prod / TX_DESC_CNT));
> +
> +	if (prod >= cons) {
> +		/* used = prod - cons - prod/size + cons/size */
> +		used -= NUM_TX_BD - NUM_TX_RINGS;
> +	}
> +
> +	BUG_TRAP(used <= fp->bp->tx_ring_size);
> +	BUG_TRAP((fp->bp->tx_ring_size - used) <= MAX_TX_AVAIL);
> +	return(fp->bp->tx_ring_size - used);
> +}

> +/*========================================================================*/
> +
> +/* acquire split MCP access lock register */
> +static int bnx2x_lock_alr( struct bnx2x *bp)
> +{
> +	int rc = 0;
> +	u32 i, j, val;
> +
> +	i = 100;
> +	val = 1UL << 31;
> +
> +	REG_WR(bp, GRCBASE_MCP, 0x9c, val);
> +	for (j = 0; j < i*10; j++) {
> +		val = REG_RD(bp, GRCBASE_MCP, 0x9c);
> +		if (val & (1L << 31)) {
> +			break;
> +		}
> +
> +		mdelay(5);

msleep(5)?

> +	}
> +
> +	if (!(val & (1L << 31))) {
> +		BNX2X_ERR("Cannot acquire nvram interface.\n");
> +
> +		rc = -EBUSY;
> +	}
> +
> +	return rc;
> +}

> +static void bnx2x_free_mem(struct bnx2x *bp)
> +{
> +
> +#define BNX2X_PCI_FREE(x, y, size) do { \
> +	if (x) { \
> +		pci_free_consistent(bp->pdev, size, x, y); \
> +		x = NULL; \
> +	} \
> +} while (0)
> +
> +#define BNX2X_KFREE(x) do { \
> +	if (x) { \
> +		vfree(x); \
> +		x = NULL; \
> +	} \
> +} while (0)
> +
> +	int i;
> +
> +	/* fastpath */
> +	for_each_queue(bp, i) {
> +
> +		/* Status blocks */
> +		BNX2X_PCI_FREE(bnx2x_fp(bp, i, status_blk),
> +			       bnx2x_fp(bp, i, status_blk_mapping),
> +			       sizeof(struct host_status_block)
> +			       + sizeof(struct eth_tx_db_data));
> +
> +		/* fast path rings: tx_buf tx_desc rx_buf rx_desc rx_comp */
> +		BNX2X_KFREE(bnx2x_fp(bp, i, tx_buf_ring));
> +		BNX2X_PCI_FREE(bnx2x_fp(bp, i, tx_desc_ring),
> +			       bnx2x_fp(bp, i, tx_desc_mapping),
> +			       sizeof(struct eth_tx_bd) * NUM_TX_BD);
> +
> +		BNX2X_KFREE(bnx2x_fp(bp, i, rx_buf_ring));
> +		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_desc_ring),
> +			       bnx2x_fp(bp, i, rx_desc_mapping),
> +			       sizeof(struct eth_rx_bd) * NUM_RX_BD);
> +
> +		BNX2X_PCI_FREE(bnx2x_fp(bp, i, rx_comp_ring),
> +			       bnx2x_fp(bp, i, rx_comp_mapping),
> +			       sizeof(struct eth_rx_bd) * NUM_RX_BD);
> +	}
> +
> +	BNX2X_KFREE( bp->fp);
> +	/* end of fast path*/
> +
> +	BNX2X_PCI_FREE(bp->def_status_blk, bp->def_status_blk_mapping,
> +		       (sizeof(struct host_def_status_block)));
> +
> +	BNX2X_PCI_FREE(bp->slowpath, bp->slowpath_mapping,
> +		       (sizeof(struct bnx2x_slowpath)));
> +
> +	if (iscsi_active) {
> +		BNX2X_PCI_FREE(bp->t1, bp->t1_mapping, 64*1024);
> +		BNX2X_PCI_FREE(bp->t2, bp->t2_mapping, 16*1024);
> +		BNX2X_PCI_FREE(bp->timers, bp->timers_mapping, 8*1024);
> +		BNX2X_PCI_FREE(bp->qm, bp->qm_mapping, 128*1024);
> +	}
> +
> +	BNX2X_PCI_FREE(bp->spq, bp->spq_mapping, PAGE_SIZE);
> +
> +#undef BNX2X_PCI_FREE
> +#undef BNX2X_KFREE
> +}
> +
> +static int bnx2x_alloc_mem(struct bnx2x *bp)
> +{
> +	int i;
> +
> +#define BNX2X_PCI_ALLOC(x, y, size) do { \
> +	x = pci_alloc_consistent(bp->pdev, size, y); \
> +	if (x == NULL) \
> +		goto alloc_mem_err; \
> +	memset(x, 0, size); \
> +} while (0)
> +
> +#define BNX2X_ALLOC(x, size) do { \
> +	x = vmalloc(size); \

Why not zalloc()?

> +	if (x == NULL) \
> +		goto alloc_mem_err; \
> +	memset(x, 0, size); \
> +} while (0)
> +
> +	/* fastpath */
> +	BNX2X_ALLOC(bp->fp, sizeof(struct bnx2x_fastpath)*bp->num_queues);
> +
> +	for_each_queue(bp, i) {
> +
> +		bnx2x_fp(bp, i, bp) = bp;
> +
> +		/* Status blocks */
> +		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, status_blk),
> +				&bnx2x_fp(bp, i, status_blk_mapping),
> +				sizeof(struct host_status_block) +
> +				sizeof(struct eth_tx_db_data));
> +
> +		bnx2x_fp(bp, i, tx_prods_mapping) =
> +				bnx2x_fp(bp, i, status_blk_mapping) +
> +				sizeof(struct host_status_block);
> +
> +		bnx2x_fp(bp, i, hw_tx_prods) =
> +				(void *)(bnx2x_fp(bp, i, status_blk) + 1);
> +
> +		/* fast path rings: tx_buf tx_desc rx_buf rx_desc rx_comp */
> +		BNX2X_ALLOC(bnx2x_fp(bp, i, tx_buf_ring),
> +				sizeof(struct sw_tx_bd) * NUM_TX_BD);
> +		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, tx_desc_ring),
> +				&bnx2x_fp(bp, i, tx_desc_mapping),
> +				sizeof(struct eth_tx_bd) * NUM_TX_BD);
> +
> +		BNX2X_ALLOC(bnx2x_fp(bp, i, rx_buf_ring),
> +				sizeof(struct sw_rx_bd) * NUM_RX_BD);
> +		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_desc_ring),
> +				&bnx2x_fp(bp, i, rx_desc_mapping),
> +				sizeof(struct eth_rx_bd) * NUM_RX_BD);
> +
> +		BNX2X_PCI_ALLOC(bnx2x_fp(bp, i, rx_comp_ring),
> +				&bnx2x_fp(bp, i, rx_comp_mapping),
> +				sizeof(struct eth_rx_bd) * NUM_RX_BD);
> +	}
> +	/* end of fast path*/
> +
> +	BNX2X_PCI_ALLOC(bp->def_status_blk, &bp->def_status_blk_mapping,
> +			sizeof(struct host_def_status_block));
> +
> +	BNX2X_PCI_ALLOC(bp->slowpath, &bp->slowpath_mapping,
> +			sizeof(struct bnx2x_slowpath));
> +
> +	if (iscsi_active) {
> +		BNX2X_PCI_ALLOC(bp->t1, &bp->t1_mapping, 64*1024);
> +
> +		/* Initialize T1 */
> +		for (i = 0; i < 64*1024; i += 64) {
> +			*(u64 *)((char *)bp->t1 + i+56) = 0x0UL;
> +			*(u64 *)((char *)bp->t1 + i+3) = 0x0UL;
> +		}
> +
> +		/* allocate searcher T2 table
> +		   we allocate 1/4 of alloc num for T2
> +		  (which is not entered into the ILT) */
> +		BNX2X_PCI_ALLOC(bp->t2, &bp->t2_mapping, 16*1024);
> +
> +		/* Initialize T2 */
> +		for (i = 0; i < 16*1024; i += 64) {
> +			*(u64 *)((char *)bp->t2 + i+56) =
> +				bp->t2_mapping + i + 64;
> +		}
> +
> +		/* now sixup the last line in the block
> +		 * to point to the next block
> +		 */
> +		*(u64 *)((char *)bp->t2 + 1024*16-8) = bp->t2_mapping;
> +
> +		/* Timer block array (MAX_CONN*8)
> +		 * phys uncached for now 1024 conns
> +		 */
> +		BNX2X_PCI_ALLOC(bp->timers, &bp->timers_mapping, 8*1024);
> +
> +		/* QM queues (128*MAX_CONN) */
> +		BNX2X_PCI_ALLOC(bp->qm, &bp->qm_mapping, 128*1024);
> +	}
> +
> +	/* Slow path ring */
> +	BNX2X_PCI_ALLOC(bp->spq, &bp->spq_mapping, PAGE_SIZE);
> +
> +	return 0;
> +
> +alloc_mem_err:
> +	bnx2x_free_mem(bp);
> +	return -ENOMEM;
> +
> +#undef BNX2X_PCI_ALLOC
> +#undef BNX2X_ALLOC
> +}
> +
> +
> +
> +static void bnx2x_set_mac_addr(struct bnx2x *bp)
> +{
> +	struct mac_configuration_cmd *config = bnx2x_sp(bp, mac_config);
> +
> +	/* CAM allocation
> +	 * unicasts 0-31:port0 32-63:port1
> +	 * multicast 64-127:port0 128-191:port1
> +	 */
> +	config->hdr.length = 2;
> +	config->hdr.offset = bp->port ? 31 : 0;
> +	config->hdr.reserved0 = 0;
> +	config->hdr.reserved1 = 0;
> +
> +	/* primary MAC */
> +	config->config_table[0].cam_entry.msb_mac_addr =
> +		ntohl(*(u32 *)&bp->dev->dev_addr[0]);
> +	config->config_table[0].cam_entry.lsb_mac_addr =
> +		ntohs(*(u16 *)&bp->dev->dev_addr[4]);

Better use xx_to_cpu()
anyway, ntohX is defined as beX_to_cpu().
Are you sure this is correct? A byte array is little endian.

> +static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
> +				     struct bnx2x_fastpath *fp, u16 index)

Too big for inlining.
If this is only called in one place, gcc will inline it automatically.

> +{
> +	struct sk_buff *skb;
> +	struct sw_rx_bd *rx_buf = &fp->rx_buf_ring[index];
> +	struct eth_rx_bd *rxbd = &fp->rx_desc_ring[index];
> +	dma_addr_t mapping;
> +
> +	skb = netdev_alloc_skb(bp->dev, bp->rx_buf_size);
> +
> +	if (skb == NULL) {
> +		return -ENOMEM;
> +	}
> +
> +	mapping = pci_map_single(bp->pdev, skb->data, bp->rx_buf_use_size,
> +				 PCI_DMA_FROMDEVICE);

You need to check if the mapping succeed.
There's a macro for that: dma_mapping_error()

> +	rx_buf->skb = skb;
> +	pci_unmap_addr_set(rx_buf, mapping, mapping);
> +#ifdef BNX2X_STOP_ON_ERROR
> +	rxbd->reserved = fp->last_alloc++;
> +#else
> +	rxbd->reserved = 0;
> +#endif
> +	rxbd->len = bp->rx_buf_use_size;
> +	rxbd->addr_hi = U64_HI(mapping);
> +	rxbd->addr_lo = U64_LO(mapping);
> +	return 0;
> +}

> +static void bnx2x_tx_int(struct bnx2x_fastpath *fp, int work)
> +{
> +	struct bnx2x *bp = fp->bp;
> +	u16 hw_cons, sw_cons, bd_cons = fp->tx_bd_cons;
> +	int done = 0;
> +
> +	hw_cons = *fp->tx_cons_sb;
> +	sw_cons = fp->tx_pkt_cons;
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +	if (unlikely(bp->panic)) {
> +		return;
> +	}
> +#endif
> +
> +	while (sw_cons != hw_cons) {
> +		u16 pkt_cons;
> +
> +		pkt_cons = TX_BD(sw_cons);
> +
> +		/* prefetch(bp->tx_buf_ring[pkt_cons].skb); */
> +
> +		DP(NETIF_MSG_TX_DONE, "sw_cons=%u  hw_cons=%u pkt_cons=%d\n",
> +		   sw_cons, hw_cons, pkt_cons);
> +
> +/*        if (NEXT_TX_IDX(sw_cons)!=hw_cons){
> +	    rmb();
> +	    prefetch(fp->tx_buf_ring[NEXT_TX_IDX(sw_cons)].skb);
> +	}
> +*/
> +
> +		bd_cons = bnx2x_free_tx_pkt(bp, fp, pkt_cons);
> +		sw_cons++;
> +		done++;
> +
> +		if (done == work) {
> +			break;
> +		}
> +	}
> +
> +	fp->tx_pkt_cons = sw_cons;
> +	fp->tx_bd_cons = bd_cons;
> +
> +	smp_mb();

Please add a comment why we need a SMP MB here.

> +
> +	/* TBD need a thresh?  */
> +	if (unlikely(netif_queue_stopped(bp->dev))) {
> +		netif_tx_lock(bp->dev);
> +		if ((netif_queue_stopped(bp->dev)) &&
> +		    (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)) {
> +			netif_wake_queue(bp->dev);
> +		}
> +		netif_tx_unlock(bp->dev);
> +	}
> +}

> +static inline void bnx2x_reuse_rx_skb(struct bnx2x_fastpath *fp,
> +				      struct sk_buff *skb, u16 cons, u16 prod)

Too big for inlining.

> +{
> +	struct bnx2x *bp = fp->bp;
> +	struct sw_rx_bd *cons_rx_buf = &fp->rx_buf_ring[cons];
> +	struct sw_rx_bd *prod_rx_buf = &fp->rx_buf_ring[prod];
> +	struct eth_rx_bd *cons_bd = &fp->rx_desc_ring[cons];
> +	struct eth_rx_bd *prod_bd = &fp->rx_desc_ring[prod];
> +
> +	pci_dma_sync_single_for_device(bp->pdev,
> +				       pci_unmap_addr(cons_rx_buf, mapping),
> +				       bp->rx_offset + RX_COPY_THRESH,
> +				       PCI_DMA_FROMDEVICE);
> +
> +	prod_rx_buf->skb = cons_rx_buf->skb;
> +	pci_unmap_addr_set(prod_rx_buf, mapping,
> +			   pci_unmap_addr(cons_rx_buf, mapping));
> +	*prod_bd = *cons_bd;
> +#ifdef BNX2X_STOP_ON_ERROR
> +	prod_bd->reserved = fp->last_alloc++;
> +#endif
> +}

> +static void bnx2x_attn_int(struct bnx2x *bp)
> +{
> +	int port = bp->port;
> +
> +	/* read local copy of bits */
> +	u16 attn_bits = bp->def_status_blk->atten_status_block.attn_bits;
> +	u16 attn_ack = bp->def_status_blk->atten_status_block.attn_bits_ack;
> +	u16 attn_state = bp->attn_state;
> +
> +	/* look for changed bits */
> +	u16 asserted   =  attn_bits & ~attn_ack & ~attn_state;
> +	u16 deasserted = ~attn_bits &  attn_ack &  attn_state;

Do you probably want | instead of & here?

> +
> +	DP(NETIF_MSG_HW,
> +	   "attn_bits %x, attn_ack %x, asserted %x, deasserted %x \n",
> +	   attn_bits, attn_ack, asserted, deasserted);
> +
> +	if (~(attn_bits ^ attn_ack) & (attn_bits ^ attn_state)) {

Do you want && or | here, instead of & ?

> +		BNX2X_ERR("bad attention state\n");
> +	}

> +}
> +
> +static inline int bnx2x_has_work(struct bnx2x_fastpath *fp)

Probably better not inline.

> +{
> +	u16 rx_cons_sb = *fp->rx_cons_sb;
> +
> +	if ((rx_cons_sb & MAX_RX_DESC_CNT) == MAX_RX_DESC_CNT)
> +		rx_cons_sb++;
> +
> +	if ((rx_cons_sb != fp->rx_comp_cons) ||
> +	    (*fp->tx_cons_sb != fp->tx_pkt_cons))
> +		return 1;
> +
> +	return 0;
> +}

> +static irqreturn_t bnx2x_msix_sp_int(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;

You need to check if dev==NULL and bail out.
Another driver sharing the IRQ with this might choose to pass the dev
pointer as NULL.

> +	struct bnx2x *bp = netdev_priv(dev);

No check if the device actually _did_ generate the IRQ? Sharing...

> +	/* Return here if interrupt is disabled. */
> +	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
> +		DP(NETIF_MSG_INTR, "called but int_sem not 0, returning. \n");
> +		return IRQ_HANDLED;
> +	}
> +
> +
> +	bnx2x_ack_sb(bp, 16, XSTORM_ID, 0, IGU_INT_DISABLE, 0);
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +	if (unlikely(bp->panic)) {
> +		return IRQ_HANDLED;
> +	}
> +#endif
> +
> +	tasklet_schedule(&bp->sp_task);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t bnx2x_msix_fp_int(int irq, void *fp_cookie)
> +{
> +
> +	struct bnx2x_fastpath *fp = fp_cookie;

Check if fp==NULL

> +	struct bnx2x *bp = fp->bp;
> +	struct net_device *dev = bp->dev;

No share protection either?

> +	DP(NETIF_MSG_INTR, "got an msix interrupt on [%d]\n", fp->index);
> +	bnx2x_ack_sb(bp, fp->index, USTORM_ID, 0 , IGU_INT_DISABLE, 0);
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +	if (unlikely(bp->panic)) {
> +		return IRQ_HANDLED;
> +	}
> +#endif
> +
> +	prefetch(fp->rx_cons_sb);
> +	prefetch(fp->tx_cons_sb);
> +	prefetch(&fp->status_blk->c_status_block.status_block_index);
> +	prefetch(&fp->status_blk->u_status_block.status_block_index);
> +	netif_rx_schedule(dev);
> +	return IRQ_HANDLED;
> +}
> +
> +static irqreturn_t bnx2x_interrupt(int irq, void *dev_instance)
> +{
> +	struct net_device *dev = dev_instance;

Check if dev==NULL

> +	struct bnx2x *bp = netdev_priv(dev);
> +	u16 status = bnx2x_ack_int(bp);
> +
> +	if (unlikely(status == 0)) {

That's not unlikely.

> +		DP(NETIF_MSG_INTR, "not our interrupt!\n");
> +		return IRQ_NONE;
> +	}
> +
> +	DP(NETIF_MSG_INTR, "got an interrupt status is %u\n", status);
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +	if (unlikely(bp->panic)) {
> +		return IRQ_HANDLED;
> +	}
> +#endif
> +
> +	/* Return here if interrupt is shared and is disabled. */
> +	if (unlikely(atomic_read(&bp->intr_sem) != 0)) {
> +		DP(NETIF_MSG_INTR, "called but int_sem not 0, returning. \n");
> +		return IRQ_HANDLED;
> +	}
> +
> +	if (status & 0x2) {
> +
> +		struct bnx2x_fastpath *fp = &bp->fp[0];
> +
> +		prefetch(fp->rx_cons_sb);
> +		prefetch(fp->tx_cons_sb);
> +		prefetch(&fp->status_blk->c_status_block.status_block_index);
> +		prefetch(&fp->status_blk->u_status_block.status_block_index);
> +
> +		netif_rx_schedule(dev);
> +
> +		status &= ~0x2;
> +
> +		if (!status) {
> +			return IRQ_HANDLED;
> +		}
> +	}
> +
> +	if (unlikely(status & 0x1)) {
> +
> +		tasklet_schedule(&bp->sp_task);
> +		status &= ~0x1;
> +		if (!status) {
> +			return IRQ_HANDLED;
> +		}
> +	}
> +
> +	DP(NETIF_MSG_INTR, "got an unknown interrupt! (status is %u)\n",
> +	   status);
> +
> +	return IRQ_HANDLED;
> +}

> +/* some of the internal memories are not directly readable from the driver
> +   to test them we send debug packets
> + */
> +static int bnx2x_int_mem_test(struct bnx2x *bp)
> +{
> +	u32 val;
> +	u32 count;
> +	u8 hw;
> +	u8 port;
> +	u8 i;
> +	u32 factor;
> +
> +	switch (CHIP_REV(bp)) {
> +	case CHIP_REV_EMUL:
> +		hw = INIT_EMULATION;
> +		factor = 2000;
> +		break;
> +	case CHIP_REV_FPGA:
> +		hw = INIT_FPGA;
> +		factor = 120;
> +		break;
> +	default:
> +		hw = INIT_ASIC;
> +		factor = 1;
> +		break;
> +	}
> +
> +	port = PORT0 << bp->port;
> +
> +	DP(NETIF_MSG_HW, "mem_wrk start part1\n");
> +
> +	/* Disable inputs of parser neighbor blocks */
> +	REG_WR(bp, GRCBASE_TSDM, TSDM_REGISTERS_ENABLE_IN1, 0x0);
> +	REG_WR(bp, GRCBASE_TCM, TCM_REGISTERS_PRS_IFEN, 0x0);
> +	REG_WR(bp, GRCBASE_CFC, CFC_REGISTERS_DEBUG0, 0x1);
> +	NIG_WR(NIG_REGISTERS_PRS_REQ_IN_EN, 0x0);
> +
> +	/*  Write 0 to parser credits for CFC search request */
> +	REG_WR(bp, GRCBASE_PRS, PRS_REGISTERS_CFC_SEARCH_INITIAL_CREDIT, 0x0);
> +
> +	/* send Ethernet packet */
> +	bnx2x_lb_pckt(bp);
> +
> +	/* TODO do i reset NIG statistic ?*/
> +	/* Wait until NIG register shows 1 packet of size 0x10 */
> +	count = 1000;
> +	while (count) {
> +		val = REG_RD(bp, GRCBASE_NIG, NIG_REGISTERS_STAT2_BRB_OCTET);
> +		REG_RD(bp, GRCBASE_NIG, NIG_REGISTERS_STAT2_BRB_OCTET + 4);
> +
> +		if (val == 0x10) {
> +			break;
> +		}
> +		msleep(10 * factor);

That would be msleep(20000) for CHIP_REV_EMUL.
besides the sleep being pretty big (does it really need to wait
20 sec?), some arches don't support such a big msleep value.
use ssleep(). It would take 5 and a half hours for the
timeout count to hit in.

> +		count--;
> +	}
> +	if (val != 0x10) {
> +		BNX2X_ERR("NIG timeout val = 0x%x\n", val);
> +		return -1;
> +	}
> +
> +	/* Wait until PRS register shows 1 packet */
> +	count = 1000;
> +	while (count) {
> +		val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_NUM_OF_PACKETS);
> +
> +		if (val == 0x1) {
> +			break;
> +		}
> +		msleep(10 * factor);

Same here.

> +		count--;
> +	}
> +	if (val != 0x1) {
> +		BNX2X_ERR("PRS timeout val = 0x%x\n", val);
> +		return -2;
> +	}

> +	/* Wait until NIG register shows 10 + 1
> +	   packets of size 11*0x10 = 0xb0 */
> +	count = 1000;
> +	while (count) {
> +
> +		val = REG_RD(bp, GRCBASE_NIG, NIG_REGISTERS_STAT2_BRB_OCTET);
> +		REG_RD(bp, GRCBASE_NIG, NIG_REGISTERS_STAT2_BRB_OCTET + 4);
> +
> +		if (val == 0xb0) {
> +			break;
> +		}
> +		msleep(10 * factor);

Same here.

> +		count--;
> +	}
> +	if (val != 0xb0) {
> +		BNX2X_ERR("NIG timeout val = 0x%x\n", val);
> +		return -3;
> +	}
> +
> +	/* Wait until PRS register shows 2 packet */
> +	val = REG_RD(bp, GRCBASE_PRS, PRS_REGISTERS_NUM_OF_PACKETS);
> +
> +	if (val != 0x2) {
> +		BNX2X_ERR("PRS timeout val = 0x%x\n", val);
> +	}
> +
> +	/* Write 1 to parser credits for CFC search request */
> +	REG_WR(bp, GRCBASE_PRS, PRS_REGISTERS_CFC_SEARCH_INITIAL_CREDIT, 0x1);
> +
> +	/* Wait until PRS register shows 3 packet */
> +	msleep(10 * factor);

Same.

> +	DP(NETIF_MSG_HW, "done\n");
> +	return 0; /* OK */
> +}

> +static void bnx2x_stop_stats(struct bnx2x *bp)
> +{
> +	atomic_set(&bp->stats_state, STATS_STATE_STOP);
> +	DP(BNX2X_MSG_STATS, "stats_state - STOP\n");
> +	while (atomic_read(&bp->stats_state) != STATS_STATE_DISABLE) {

This seems to need a memory barrier (on this side _and_ on the write side,
wherever that is (comment!)).
There are special mbs for atomic variables.

> +		msleep(100);
> +	}
> +	DP(BNX2X_MSG_STATS, "stats_state - DISABLE\n");
> +}

> +static void bnx2x_update_stats(struct bnx2x *bp)
> +{
> +
> +	if (!bnx2x_update_storm_stats(bp)) {
> +
> +		if (bp->phy_flags & PHY_BMAC_FLAG) {
> +			bnx2x_update_bmac_stats(bp);
> +
> +		} else if (bp->phy_flags & PHY_EMAC_FLAG) {
> +			bnx2x_update_emac_stats(bp);
> +
> +		} else { /* unreached */
> +			BNX2X_ERR("no MAC active\n");
> +			return;
> +		}
> +
> +		bnx2x_update_net_stats(bp);
> +	}
> +
> +	if (bp->msglevel & NETIF_MSG_TIMER) {
> +		printk(KERN_DEBUG "%s:\n"
> +		       KERN_DEBUG "tx avail(%x)   rx usage(%x)\n"
> +		       KERN_DEBUG "tx pkt (%lx)   rx pkt(%lx)\n"
> +		       KERN_DEBUG "tx hc idx(%x)  rx hc index(%x)\n"
> +		       KERN_DEBUG "%s (Xoff events %u)\n"
> +		       KERN_DEBUG "brb drops                     %u\n"
> +		       KERN_DEBUG "tstats->no_buff_discard,      %u\n"
> +		       KERN_DEBUG "tstats->errors_discard,       %u\n"
> +		       KERN_DEBUG "tstats->mac_filter_discard,   %u\n"
> +		       KERN_DEBUG "tstats->xxoverflow_discard,   %u\n"
> +		       KERN_DEBUG "tstats->ttl0_discard,         %u\n",
> +		       bp->dev->name,
> +		       bnx2x_tx_avail(bp->fp),
> +		       (u16)(*bp->fp->rx_cons_sb - bp->fp->rx_comp_cons),
> +		       bp->net_stats.tx_packets, bp->net_stats.rx_packets,
> +		       *bp->fp->tx_cons_sb, *bp->fp->rx_cons_sb,
> +		       netif_queue_stopped(bp->dev)? "Xoff" : "Xon ",
> +		       bp->slowpath->eth_stats.driver_xoff,
> +		       bp->slowpath->eth_stats.brb_discard,
> +		       bp->slowpath->eth_stats.no_buff_discard,
> +		       bp->slowpath->eth_stats.errors_discard,
> +		       bp->slowpath->eth_stats.mac_filter_discard,
> +		       bp->slowpath->eth_stats.xxoverflow_discard,
> +		       bp->slowpath->eth_stats.ttl0_discard);
> +	}
> +
> +	if (bp->state != BNX2X_STATE_OPEN) {
> +		DP(BNX2X_MSG_STATS, "state is %x, returning\n", bp->state);
> +		return;
> +	}
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +	if (unlikely(bp->panic)) {
> +		return;
> +	}
> +#endif
> +
> +	if (bp->fw_mb) {
> +		REG_WR32(bp, GRCBASE_DMAE,
> +			 (bp->port? DMAE_REGISTERS_GO_C13 :
> +				    DMAE_REGISTERS_GO_C12), 1);
> +	}
> +
> +	if (atomic_read(&bp->stats_state) != STATS_STATE_ENABLE) {
> +		atomic_set(&bp->stats_state, STATS_STATE_DISABLE);

Is that the write side? If yes, you need a mb here, too.
And a comment.

> +		return;
> +	}
> +
> +	if (bp->phy_flags & PHY_BMAC_FLAG) {
> +		REG_WR32(bp, GRCBASE_DMAE,
> +			 (bp->port? DMAE_REGISTERS_GO_C6 :
> +				    DMAE_REGISTERS_GO_C0), 1);
> +
> +	} else if (bp->phy_flags & PHY_EMAC_FLAG) {
> +		REG_WR32(bp, GRCBASE_DMAE,
> +			 (bp->port? DMAE_REGISTERS_GO_C8 :
> +				    DMAE_REGISTERS_GO_C2), 1);
> +	}
> +
> +	if (bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_STAT_QUERY, 0, 0, 0, 0) == 0) {
> +		/* stats ramrod has it's own slot on the spe */
> +		bp->spq_left++;
> +		bp->stat_pending = 1;
> +	}
> +}

> +/* Called with netif_tx_lock.
> + * bnx2x_tx_int() runs without netif_tx_lock unless it needs to call
> + * netif_wake_queue().
> + */
> +static int bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +	dma_addr_t mapping;
> +	struct eth_tx_bd *txbd;
> +	struct eth_tx_parse_bd *pbd = NULL;
> +	struct sw_tx_bd *tx_buf;
> +	u16 pkt_prod, bd_prod;
> +	int nbd, fp_index = 0;
> +	struct bnx2x_fastpath *fp;
> +
> +	fp = &bp->fp[fp_index];
> +#ifdef BNX2X_STOP_ON_ERROR
> +	if (unlikely(bp->panic)) {
> +		return NETDEV_TX_BUSY;
> +	}
> +#endif
> +
> +	if (unlikely(bnx2x_tx_avail(bp->fp) <
> +		     (skb_shinfo(skb)->nr_frags + 3))) {
> +		bp->slowpath->eth_stats.driver_xoff++,
> +		netif_stop_queue(dev);
> +		BNX2X_ERR("BUG! Tx ring full when queue awake!\n");
> +		return NETDEV_TX_BUSY;
> +	}
> +
> +	/*
> +	This is a bit ugly. First we use one BD which we mark as start,
> +	then for TSO or xsum we have a parsing info BD,
> +	and only then we have the rest of the TSO bds.
> +	(don't forget to mark the last one as last,
> +	and to unmap only AFTER you write to the BD ...)
> +	I would like to thank Dov Hirshfeld for this mess.
> +	*/
> +
> +	pkt_prod = fp->tx_pkt_prod++;
> +	bd_prod = fp->tx_bd_prod;
> +
> +	pkt_prod = TX_BD(pkt_prod);
> +	bd_prod = TX_BD(bd_prod);
> +
> +	/* get a tx_buff and first bd */
> +	tx_buf = &fp->tx_buf_ring[pkt_prod];
> +	txbd = &fp->tx_desc_ring[bd_prod];
> +
> +	txbd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_START_BD;
> +
> +	/* remeber the first bd of the packet */
> +	tx_buf->first_bd = bd_prod;
> +
> +	DP(NETIF_MSG_TX_QUEUED,
> +	   "sending pkt=%u @%p, next_idx=%u, bd=%u @%p\n",
> +	   pkt_prod, tx_buf, fp->tx_pkt_prod, bd_prod, txbd);
> +
> +	if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +		u8 len;
> +		struct iphdr *iph = ip_hdr(skb);
> +
> +		txbd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_IP_CSUM ;
> +
> +		/* turn on parsing and get a bd */
> +		bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
> +		pbd = (void *)&fp->tx_desc_ring[bd_prod];
> +		
> +		len = ((u8 *)ip_hdr(skb) - (u8 *)skb->data)/2;
> +
> +		/* for now NS flag is not used in Linux */
> +		pbd->global_data =
> +			len | ((skb->protocol == ETH_P_8021Q)
> +			       << ETH_TX_PARSE_BD_LLC_SNAP_EN_SHIFT);
> +
> +		pbd->ip_hlen = ip_hdrlen(skb)/2;
> +		pbd->total_hlen = len + pbd->ip_hlen;
> +
> +		if (iph->protocol == IPPROTO_TCP) {
> +			struct tcphdr *th = tcp_hdr(skb);
> +			txbd->bd_flags.as_bitfield |=
> +				ETH_TX_BD_FLAGS_TCP_CSUM;
> +			pbd->tcp_flags = htonl(tcp_flag_word(skb))&0xFFFF;
> +			pbd->total_hlen += tcp_hdrlen(skb)/2;
> +
> +			pbd->tcp_pseudo_csum = ntohs(th->check);
> +		} else if (iph->protocol == IPPROTO_UDP) {
> +			struct udphdr *uh = udp_hdr(skb);
> +			txbd->bd_flags.as_bitfield |=
> +				ETH_TX_BD_FLAGS_TCP_CSUM;
> +			pbd->total_hlen += 4;
> +			pbd->global_data |= ETH_TX_PARSE_BD_UDP_FLG;
> +
> +			/* HW bug: we need to subtract 10 bytes before the
> +			 * UDP header from the csum
> +			 */
> +			uh->check = (u16) ~csum_fold(csum_sub(uh->check,
> +				csum_partial(((u8 *)(uh)-10), 10, 0)));
> +		}
> +	}
> +
> +	if (bp->vlgrp != 0 && vlan_tx_tag_present(skb)) {
> +		txbd->vlan = vlan_tx_tag_get(skb);
> +		txbd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_VLAN_TAG;
> +	}
> +#ifdef BNX2X_STOP_ON_ERROR
> +	else {
> +		txbd->vlan = pkt_prod;
> +	}
> +#endif
> +
> +	mapping = pci_map_single(bp->pdev, skb->data,
> +				 skb->len, PCI_DMA_TODEVICE);

dma_mapping_error()

> +
> +	txbd->addr_hi = U64_HI(mapping);
> +	txbd->addr_lo = U64_LO(mapping);
> +	txbd->hdr_nbds = 1;
> +	txbd->nbd = nbd = skb_shinfo(skb)->nr_frags + ((pbd == NULL)? 1 : 2);
> +	txbd->nbytes = skb_headlen(skb);
> +
> +	DP(NETIF_MSG_TX_QUEUED,
> +	   "first bd @%p, addr(%x:%x) hdr_nbds(%d) nbd(%d)"
> +	   " nbytes(%d) flags(%x) vlan(%u)\n",
> +	   txbd, txbd->addr_hi, txbd->addr_lo, txbd->hdr_nbds, txbd->nbd,
> +	   txbd->nbytes, txbd->bd_flags.as_bitfield, txbd->vlan);
> +
> +	if ((skb_shinfo(skb)->gso_size) &&
> +	    (skb->len > (bp->dev->mtu + ETH_HLEN))) {
> +
> +		int hlen = 2*pbd->total_hlen;
> +	DP(NETIF_MSG_TX_QUEUED,
> +	   "TSO packet len %d, hlen %d, total len %d, tso size %d\n",
> +	   skb->len, hlen, skb_headlen(skb), skb_shinfo(skb)->gso_size);
> +
> +		txbd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_SW_LSO;
> +
> +		if (txbd->nbytes > hlen) {
> +		/* we split the first bd into headers and data bds
> +		 * to ease the pain of our fellow micocode engineers
> +		 * we use one mapping for both bds
> +		 * So far this has only been observed to happen
> +		 * in Other Operating Systems(TM)
> +		 */
> +
> +			/* first fix first bd */
> +			nbd++;
> +			txbd->nbd++;
> +			txbd->nbytes = hlen;
> +
> +			/* we only print this as an error
> +			 * because we don't think this will ever happen.
> +			 */
> +			BNX2X_ERR("TSO split headr size is %d (%x:%x)"
> +				  " nbd %d\n", txbd->nbytes, txbd->addr_hi,
> +				  txbd->addr_lo, txbd->nbd);
> +
> +			/* now get a new data bd
> +			 * (after the pbd) and fill it */
> +			bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
> +			txbd = &fp->tx_desc_ring[bd_prod];
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +			txbd->vlan = pkt_prod;
> +#endif
> +			txbd->addr_hi = U64_HI(mapping);
> +			txbd->addr_lo = U64_LO(mapping) + hlen;
> +			txbd->nbytes = skb_headlen(skb) - hlen;
> +			/* this marks the bd
> +			 * as one that has no individual mapping
> +			 * the FW ignors this flag in a bd not maked start
> +			 */
> +			txbd->bd_flags.as_bitfield = ETH_TX_BD_FLAGS_SW_LSO;
> +			DP(NETIF_MSG_TX_QUEUED,
> +			   "TSO split data size is %d (%x:%x)\n",
> +			   txbd->nbytes, txbd->addr_hi, txbd->addr_lo);
> +		}
> +
> +		if (!pbd) {
> +			/* supposed to be unreached
> +			 * (and therefore not handled properly...)
> +			 */
> +			BNX2X_ERR("LSO with no PBD\n");
> +			BUG();
> +		}
> +
> +		pbd->lso_mss = skb_shinfo(skb)->gso_size;
> +		pbd->tcp_send_seq = ntohl(tcp_hdr(skb)->seq);
> +		pbd->ip_id  = ntohs(ip_hdr(skb)->id);
> +		pbd->tcp_pseudo_csum =
> +			ntohs(~csum_tcpudp_magic(ip_hdr(skb)->saddr,
> +						 ip_hdr(skb)->daddr,
> +						 0, IPPROTO_TCP, 0));
> +		pbd->global_data |= ETH_TX_PARSE_BD_PSEUDO_CS_WITHOUT_LEN;
> +	}
> +
> +	{
> +		int i;
> +		for (i = 0; i < skb_shinfo(skb)->nr_frags; i++) {
> +			skb_frag_t *frag = &skb_shinfo(skb)->frags[i];
> +
> +			bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
> +			txbd = &fp->tx_desc_ring[bd_prod];
> +
> +			mapping = pci_map_page(bp->pdev, frag->page,
> +					       frag->page_offset,
> +					       frag->size, PCI_DMA_TODEVICE);
> +
> +			txbd->addr_hi = U64_HI(mapping);
> +			txbd->addr_lo = U64_LO(mapping);
> +			txbd->nbytes = frag->size;
> +			txbd->bd_flags.as_bitfield = 0;
> +#ifdef BNX2X_STOP_ON_ERROR
> +			txbd->vlan = pkt_prod;
> +#endif
> +			DP(NETIF_MSG_TX_QUEUED, "frag (%d) bd @%p,"
> +			   " addr(%x:%x) nbytes(%d) flags(%x)\n",
> +			   i, txbd, txbd->addr_hi, txbd->addr_lo,
> +			   txbd->nbytes, txbd->bd_flags.as_bitfield);
> +
> +		}  /* for */
> +	}
> +
> +	/* now at last mark the bd as the last bd */
> +	txbd->bd_flags.as_bitfield |= ETH_TX_BD_FLAGS_END_BD;
> +
> +	DP(NETIF_MSG_TX_QUEUED, "last bd @%p flags(%x)\n",
> +	   txbd, txbd->bd_flags.as_bitfield);
> +
> +	tx_buf->skb = skb;
> +
> +	bd_prod = TX_BD(NEXT_TX_IDX(bd_prod));
> +
> +	/* now send a tx doorbell, counting the next bd
> +	 * if the packet contains or ends with it
> +	 */
> +	if (TX_BD_POFF(bd_prod) < nbd)
> +		nbd++;
> +
> +	if (pbd) {
> +		DP(NETIF_MSG_TX_QUEUED,
> +		   "PBD @%p, ip_data=%x , ip_hlen %u, ip_id %u, lso_mss %u,"
> +		   " tcp_flags %x, xsum %x, seq %u, hlen %u)\n",
> +		   pbd, pbd->global_data, pbd->ip_hlen, pbd->ip_id,
> +		   pbd->lso_mss, pbd->tcp_flags, pbd->tcp_pseudo_csum,
> +		   pbd->tcp_send_seq, pbd->total_hlen);
> +	}
> +
> +	DP(NETIF_MSG_TX_QUEUED, "doorbell: nbd=%u, bd=%d\n", nbd, bd_prod);
> +
> +	fp->hw_tx_prods->bds_prod += nbd;
> +	fp->hw_tx_prods->packets_prod++;
> +	DOORBELL(bp, fp_index, 0);
> +
> +	mmiowb();
> +
> +	fp->tx_bd_prod = bd_prod;
> +	dev->trans_start = jiffies;
> +
> +	if (unlikely(bnx2x_tx_avail(fp) < MAX_SKB_FRAGS + 3)) {
> +		netif_stop_queue(dev);
> +		bp->slowpath->eth_stats.driver_xoff++;
> +		if (bnx2x_tx_avail(fp) >= MAX_SKB_FRAGS + 3)
> +			netif_wake_queue(dev);
> +	}
> +	fp->tx_pkt++;
> +	return NETDEV_TX_OK;
> +}

> +static int bnx2x_nic_unload(struct bnx2x *bp, int fre_irq)
> +{
> +	u32 reset_code = 0;
> +	int rc /*, j */;
> +	bp->state = BNX2X_STATE_CLOSING_WAIT4_HALT;
> +
> +	/* Calling flush_scheduled_work() may deadlock because
> +	 * linkwatch_event() may be on the workqueue and it will try to get
> +	 * the rtnl_lock which we are holding.
> +	 */
> +	while (bp->in_reset_task)
> +		msleep(1);

Memory barrier?

> +
> +	/* Delete the timer: do it before disabling interrupts, as it
> +	   may be stil STAT_QUERY ramrod pending after stopping the timer */
> +	del_timer_sync(&bp->timer);
> +
> +	/* Wait until stat ramrod returns and all SP tasks complete */
> +	while (bp->stat_pending && (bp->spq_left != MAX_SPQ_PENDING)) {

Memory barrier?

> +		msleep(1);
> +	}
> +
> +	/* Stop fast path, disable MAC, disable interrupts */
> +	bnx2x_netif_stop(bp);

> +	/* Remember cstorm producer in DSB to track it */
> +	bp->dsb_prod_sp_idx = *bp->dsb_sp_prod;
> +	/* Send CFC_DELETE ramrod */
> +	bnx2x_sp_post(bp, RAMROD_CMD_ID_ETH_LEADING_CFC_DEL, 0, 0, 0, 1);
> +	/* Wait for completion to arrive. Do nothing as we are going to reset
> +	   the chip a few lines later */
> +	while ( bp->dsb_prod_sp_idx == *bp->dsb_sp_prod ) {

What's that doing? Poking some DMA?
Barrier needed? DMA sync needed?

> +		msleep(1);
> +	}
> +

> +static void bnx2x_reset_task(struct work_struct *work)
> +{
> +	struct bnx2x *bp = container_of(work, struct bnx2x, reset_task);
> +
> +#ifdef BNX2X_STOP_ON_ERROR
> +	BNX2X_ERR("reset taks called but STOP_ON_ERROR defined"
> +		  " so reset not done to allow debug dump,\n"
> +		  " you will need to reboot when done\n");
> +	return;
> +#endif
> +
> +	if (!netif_running(bp->dev))
> +		return;
> +
> +	bp->in_reset_task = 1;
> +	bnx2x_netif_stop(bp);
> +
> +	bnx2x_nic_unload(bp, 0);
> +	bnx2x_nic_load(bp, 0);


> +	bp->in_reset_task = 0;

smp_wmb()?

> +}

> +static int bnx2x_phys_id(struct net_device *dev, u32 data)
> +{
> +	struct bnx2x *bp = netdev_priv(dev);
> +	int i;
> +
> +	if (data == 0)
> +		data = 2;
> +
> +	for (i = 0; i < (data * 2); i++) {
> +		if ((i % 2) == 0) {
> +			bnx2x_leds_set(bp, SPEED_1000);
> +		} else {
> +			bnx2x_leds_unset(bp);
> +		}
> +		msleep_interruptible(500);

Check the return value of msleep_interruptible and drop the
following check for signals.

> +		if (signal_pending(current))
> +			break;
> +	}
> +
> +	if (bp->link_up) {
> +		bnx2x_leds_set(bp, bp->line_speed);
> +	}
> +	return 0;
> +}

> +#ifdef BNX2X_STOP_ON_ERROR
> +#warning stop on error defined
> +#define bnx2x_panic() \
> +	do { bp->panic = 1; \
> +		BNX2X_ERR("driver assert\n"); \
> +		bnx2x_disable_int(bp); \
> +		bnx2x_panic_dump(bp); \
> +	} while (0);

Drop the last semicolon

> +#else
> +#define bnx2x_panic()
> +#endif


Puh, that was a lot :)


-- 
Greetings Michael.
