From: "Andrew.an" <bh74.an@samsung.com>
Subject: RE: [PATCH V2 RE-SEND 1/7] net: sxgbe: add basic framework for Samsung
 10Gb ethernet driver
Date: Sat, 15 Mar 2014 17:09:40 -0700
Message-ID: <000e01cf40ac$08c19290$1a44b7b0$@samsung.com>
References: <007a01cf3e89$3bbdf460$b339dd20$%an@samsung.com>
 <20140314004454.GA10982@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-samsung-soc@vger.kernel.org,
	davem@davemloft.net, ilho215.lee@samsung.com,
	siva.kallam@samsung.com, vipul.pandya@samsung.com,
	ks.giri@samsung.com, 'Joe Perches' <joe@perches.com>
To: 'Francois Romieu' <romieu@fr.zoreil.com>
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
In-reply-to: <20140314004454.GA10982@electric-eye.fr.zoreil.com>
Content-language: en-us
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu <romieu@fr.zoreil.com>
> Byungho An <bh74.an@samsung.com> :
> > From: Siva Reddy <siva.kallam@samsung.com>
> >
> > This patch adds support for Samsung 10Gb ethernet driver(sxgbe).
> > - sxgbe core initialization
> > - Tx and Rx support
> > - MDIO support
> > - ISRs for Tx and Rx
> > - ifconfig support to driver
> 
> You'll find a partial review below.
> 
> [...]
> > diff --git a/drivers/net/ethernet/samsung/sxgbe_common.h
> b/drivers/net/ethernet/samsung/sxgbe_common.h
> > new file mode 100644
> > index 0000000..3f16220
> > --- /dev/null
> > +++ b/drivers/net/ethernet/samsung/sxgbe_common.h
> [...]
> > +enum dma_irq_status {
> > +	tx_hard_error = BIT(0),
> > +	tx_bump_tc = BIT(1),
> > +	handle_tx = BIT(2),
> > +	rx_hard_error = BIT(3),
> > +	rx_bump_tc = BIT(4),
> > +	handle_rx = BIT(5),
> 
> Please use tabs before "=" to line things up.
OK.

> 
> [...]
> > +struct sxgbe_hwtimestamp {
> > +	void (*config_hw_tstamping)(void __iomem *ioaddr, u32 data);
> > +	void (*config_sub_second_increment)(void __iomem *ioaddr);
> > +	int (*init_systime)(void __iomem *ioaddr, u32 sec, u32 nsec);
> > +	int (*config_addend)(void __iomem *ioaddr, u32 addend);
> > +	int (*adjust_systime)(void __iomem *ioaddr, u32 sec, u32 nsec,
> > +			      int add_sub);
> > +	u64 (*get_systime)(void __iomem *ioaddr);
> > +};
> 
> None of these method is ever used.
OK. Those methods will be posted later.
> 
> Even annotated with __iomem, I'd rather keep the void * to a minimum and
> push the device driver pointer through the call chain. Your call.
I think either will be fine. 

> 
> [...]
> > +struct sxgbe_core_ops {
> > +	/* MAC core initialization */
> > +	void (*core_init)(void __iomem *ioaddr);
> > +	/* Dump MAC registers */
> > +	void (*dump_regs)(void __iomem *ioaddr);
> > +	/* Handle extra events on specific interrupts hw dependent */
> > +	int (*host_irq_status)(void __iomem *ioaddr,
> > +			       struct sxgbe_extra_stats *x);
> > +	/* Set power management mode (e.g. magic frame) */
> > +	void (*pmt)(void __iomem *ioaddr, unsigned long mode);
> > +	/* Set/Get Unicast MAC addresses */
> > +	void (*set_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
> > +			      unsigned int reg_n);
> > +	void (*get_umac_addr)(void __iomem *ioaddr, unsigned char *addr,
> > +			      unsigned int reg_n);
> > +	void (*enable_rx)(void __iomem *ioaddr, bool enable);
> > +	void (*enable_tx)(void __iomem *ioaddr, bool enable);
> > +
> > +	/* controller version specific operations */
> > +	int (*get_controller_version)(void __iomem *ioaddr);
> > +
> > +	/* If supported then get the optional core features */
> > +	unsigned int (*get_hw_feature)(void __iomem *ioaddr,
> > +				       unsigned char feature_index);
> > +	/* adjust SXGBE speed */
> > +	void (*set_speed)(void __iomem *ioaddr, unsigned char speed);
> > +};
> 
> This indirection level is never used.
Those are used, can you give more detail?

> 
> > +
> > +const struct sxgbe_core_ops *sxgbe_get_core_ops(void);
> > +
> > +struct sxgbe_ops {
> > +	const struct sxgbe_core_ops *mac;
> > +	const struct sxgbe_desc_ops *desc;
> > +	const struct sxgbe_dma_ops *dma;
> > +	const struct sxgbe_mtl_ops *mtl;
> 
> Will these indirection levels ever be used ?
Those are used, can you give more detail?

> 
> > +	const struct sxgbe_hwtimestamp *ptp;
> > +	struct mii_regs mii;	/* MII register Addresses */
> > +	struct mac_link link;
> > +	unsigned int ctrl_uid;
> > +	unsigned int ctrl_id;
> > +};
> > +
> > +/* SXGBE private data structures */
> > +struct sxgbe_tx_queue {
> > +	u8 queue_no;
> > +	unsigned int irq_no;
> > +	struct sxgbe_priv_data *priv_ptr;
> > +	struct sxgbe_tx_norm_desc *dma_tx;
> 
> You may lay things a bit differently.
can you give more detail?

> 
> [...]
> > +/* SXGBE HW capabilities */
> > +struct sxgbe_hw_features {
> > +	/****** CAP [0] *******/
> > +	unsigned int gmii_1000mbps;
> 
> This field is never read.
It will be used later and will be removed in the next post.

> 
> > +	unsigned int vlan_hfilter;
> 
> This field is never read.
Same above.

> 
> > +	unsigned int sma_mdio;
> 
> This field is never read.
Same above.

> 
> > +	unsigned int pmt_remote_wake_up;
> 
> This field *is* read.
> 
> > +	unsigned int pmt_magic_frame;
> 
> So is this one.
> 
> > +	unsigned int rmon;
> 
> But this one isn't :o/
> 
> > +	unsigned int arp_offload;
> 
> Sic.
> 
> The storage is a bit expensive. You may pack some boolean into a single
> unsigned int.
It can be packed but not for all.

> 
> [...]
> > +struct sxgbe_priv_data {
> > +	/* DMA descriptos */
> > +	struct sxgbe_tx_queue *txq[SXGBE_TX_QUEUES];
> > +	struct sxgbe_rx_queue *rxq[SXGBE_RX_QUEUES];
> > +	u8 cur_rx_qnum;
> > +
> > +	unsigned int dma_tx_size;
> > +	unsigned int dma_rx_size;
> > +	unsigned int dma_buf_sz;
> > +	u32 rx_riwt;
> > +
> > +	struct napi_struct napi;
> > +
> > +	void __iomem *ioaddr;
> > +	struct net_device *dev;
> > +	struct device *device;
> > +	struct sxgbe_ops *hw;/* sxgbe specific ops */
> > +	int no_csum_insertion;
> > +	spinlock_t lock;
> 
> There is no spin_lock_init for this field.
OK. Need to cleanup.

> 
> OTOH it isn't really used at all.
> 
> [...]
> > +	int oldlink;
> > +	int speed;
> > +	int oldduplex;
> > +	unsigned int flow_ctrl;
> > +	unsigned int pause;
> 
> You may add some extra inner struct when fields are related.
> 
> [...]
> > diff --git a/drivers/net/ethernet/samsung/sxgbe_desc.c
> b/drivers/net/ethernet/samsung/sxgbe_desc.c
> > new file mode 100644
> > index 0000000..9a93553
> > --- /dev/null
> > +++ b/drivers/net/ethernet/samsung/sxgbe_desc.c
> [...]
> > +static u64 sxgbe_get_rx_timestamp(struct sxgbe_rx_ctxt_desc *p)
> > +{
> > +	u64 ns;
> > +	ns = p->tstamp_lo;
> 
> Please insert an empty line between the declaration and the body of the
> function.
OK.

> 
> [...]
> > diff --git a/drivers/net/ethernet/samsung/sxgbe_desc.h
> b/drivers/net/ethernet/samsung/sxgbe_desc.h
> > new file mode 100644
> > index 0000000..761b521
> > --- /dev/null
> > +++ b/drivers/net/ethernet/samsung/sxgbe_desc.h
> [...]
> > +struct sxgbe_tx_norm_desc {
> > +	u64 tdes01; /* buf1 address */
> > +	union {
> > +		/* TX Read-Format Desc 2,3 */
> > +		struct {
> > +			/* TDES2 */
> > +			u32 buf1_size:14;
> > +			u32 vlan_tag_ctl:2;
> > +			u32 buf2_size:14;
> > +			u32 timestmp_enable:1;
> > +			u32 int_on_com:1;
> 
> Is there a device endianness control bit to make it safe ?
> 
> It's quite common to use __{le / be}32 and the relevant cpu_to_leXY
> helpers.
I'll consider it.

> 
> [...]
> > diff --git a/drivers/net/ethernet/samsung/sxgbe_dma.c
> b/drivers/net/ethernet/samsung/sxgbe_dma.c
> > new file mode 100644
> > index 0000000..9ee4a3c
> > --- /dev/null
> > +++ b/drivers/net/ethernet/samsung/sxgbe_dma.c
> [...]
> > +static int sxgbe_dma_init(void __iomem *ioaddr, int fix_burst,
> > +			  int burst_map, int adv_addr_mode)
> > +{
> > +	int retry_count = 10;
> > +	u32 reg_val;
> > +
> > +	/* reset the DMA */
> > +	writel(SXGBE_DMA_SOFT_RESET, ioaddr +
> SXGBE_DMA_MODE_REG);
> > +	while (retry_count--) {
> > +		if (!(readl(ioaddr + SXGBE_DMA_MODE_REG) &
> > +		      SXGBE_DMA_SOFT_RESET))
> 
> 		if (!(readl(ioaddr + SXGBE_DMA_MODE_REG) &
> 			    SXGBE_DMA_SOFT_RESET))
> 
> Btw some ad-hoc helpers may shorten the code, for instance:
> 
> 		if (!(sx_r32(sp, SXGBE_DMA_MODE_REG) &
> SXGBE_DMA_SOFT_RESET))
> 
> [...]
> > +static void sxgbe_dma_channel_init(void __iomem *ioaddr, int cha_num,
> > +				   int fix_burst, int pbl, dma_addr_t
dma_tx,
> > +				   dma_addr_t dma_rx, int t_rsize, int
r_rsize)
> > +{
> > +	u32 reg_val;
> > +	dma_addr_t dma_addr;
> > +
> > +	reg_val = readl(ioaddr + SXGBE_DMA_CHA_CTL_REG(cha_num));
> > +	/* set the pbl */
> > +	if (fix_burst) {
> > +		reg_val |= SXGBE_DMA_PBL_X8MODE;
> > +		writel(reg_val, ioaddr +
> SXGBE_DMA_CHA_CTL_REG(cha_num));
> > +		/* program the TX pbl */
> > +		reg_val = readl(ioaddr +
> SXGBE_DMA_CHA_TXCTL_REG(cha_num));
> > +		reg_val |= (pbl << SXGBE_DMA_TXPBL_LSHIFT);
> > +		writel(reg_val, ioaddr +
> SXGBE_DMA_CHA_TXCTL_REG(cha_num));
> > +		/* program the RX pbl */
> > +		reg_val = readl(ioaddr +
> SXGBE_DMA_CHA_RXCTL_REG(cha_num));
> > +		reg_val |= (pbl << SXGBE_DMA_RXPBL_LSHIFT);
> > +		writel(reg_val, ioaddr +
> SXGBE_DMA_CHA_RXCTL_REG(cha_num));
> > +	}
> > +
> > +	/* program desc registers */
> > +	writel((dma_tx >> 32),
> 
> Excess parenthesis.
OK.

> 
> > +	       ioaddr + SXGBE_DMA_CHA_TXDESC_HADD_REG(cha_num));
> > +	writel((dma_tx & 0xFFFFFFFF),
> > +	       ioaddr + SXGBE_DMA_CHA_TXDESC_LADD_REG(cha_num));
> > +
> > +	writel((dma_rx >> 32),
> > +	       ioaddr + SXGBE_DMA_CHA_RXDESC_HADD_REG(cha_num));
> > +	writel((dma_rx & 0xFFFFFFFF),
> > +	       ioaddr + SXGBE_DMA_CHA_RXDESC_LADD_REG(cha_num));
> > +
> > +	/* program tail pointers */
> > +	/* assumption: upper 32 bits are constant and
> > +	 * same as TX/RX desc list
> > +	 */
> > +	dma_addr = dma_tx + ((t_rsize-1) * SXGBE_DESC_SIZE_BYTES);
> 
> 	dma_addr = dma_tx + ((t_rsize - 1) * SXGBE_DESC_SIZE_BYTES);
OK.

> 
> [...]
> > diff --git a/drivers/net/ethernet/samsung/sxgbe_main.c
> b/drivers/net/ethernet/samsung/sxgbe_main.c
> > new file mode 100644
> > index 0000000..7b5a6bd
> > --- /dev/null
> > +++ b/drivers/net/ethernet/samsung/sxgbe_main.c
> [...]
> > +struct sxgbe_priv_data *sxgbe_dvr_probe(struct device *device,
> > +					struct sxgbe_plat_data *plat_dat,
> > +					void __iomem *addr)
> > +{
> [...]
> > +	/* Rx Watchdog is available, enable depend on platform data */
> > +	if (!priv->plat->riwt_off) {
> > +		priv->use_riwt = 1;
> > +		pr_info("Enable RX Mitigation via HW Watchdog Timer\n");
> > +	}
> > +
> > +	netif_napi_add(ndev, &priv->napi, sxgbe_poll, 64);
> 
> There's no balancing netif_napi_del in sxgbe_dvr_remove.
OK.

Thanks.
> 
> --
> Ueimor
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
