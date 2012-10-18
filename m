From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH 1/6] drivers: net: ethernet: cpsw: add support for CPSW
 register offset changes in different IP version
Date: Thu, 18 Oct 2012 04:45:23 +0200
Message-ID: <20121018024523.GA2867@netboy.at.omicron.at>
References: <1350427518-7230-1-git-send-email-mugunthanvnm@ti.com>
 <1350427518-7230-2-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:57717 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753653Ab2JRCpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2012 22:45:36 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so6823521wgb.1
        for <netdev@vger.kernel.org>; Wed, 17 Oct 2012 19:45:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1350427518-7230-2-git-send-email-mugunthanvnm@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 17, 2012 at 04:15:13AM +0530, Mugunthan V N wrote:
>  
> +#define CPSW_VERSION_1		0x19010a
> +#define CPSW_VERSION_2		0x19010c

Are you sure about these codes? What about 0x19010b?
I could not find them documented anywhere.

> +#define cpsw_slave_reg(priv, slave, reg)				\
> +	((slave)->regs + (priv)->slave_reg_ofs[(reg)])
> +
>  #define CPSW_MAJOR_VERSION(reg)		(reg >> 8 & 0x7)
>  #define CPSW_MINOR_VERSION(reg)		(reg & 0xff)
>  #define CPSW_RTL_VERSION(reg)		((reg >> 11) & 0x1f)
> @@ -117,6 +122,48 @@ do {								\
>  			disable_irq_nosync(priv->irqs_table[i]); \
>  	} while (0);
>  
> +enum CPSW_SLAVE_REG_OFS {
> +	MAX_BLKS,
> +	BLK_CNT,
> +	FLOW_THRESH,
> +	PORT_VLAN,
> +	TX_PRI_MAP,
> +	TS_CTL,
> +	TS_SEQ_LTYPE,
> +	TS_VLAN,
> +	SA_LO,
> +	SA_HI,
> +	PORT_CONTROL,
> +	TS_SEQ_MTYPE,
> +	TS_CONTROL,
> +};
> +
> +static const u32 slave_reg_map_ip_v1[] = {
> +	[MAX_BLKS]	= 0x00,
> +	[BLK_CNT]	= 0x04,
> +	[FLOW_THRESH]	= 0x08,
> +	[PORT_VLAN]	= 0x0c,
> +	[TX_PRI_MAP]	= 0x10,
> +	[TS_CTL]	= 0x14,
> +	[TS_SEQ_LTYPE]	= 0x18,
> +	[TS_VLAN]	= 0x1c,
> +	[SA_LO]		= 0x20,
> +	[SA_HI]		= 0x24,
> +};
> +
> +static const u32 slave_reg_map_ip_v2[] = {
> +	[PORT_CONTROL]	= 0x00,
> +	[TS_CONTROL]	= 0x04,

You don't make use of this register in your driver, so what is the
point?

> +	[MAX_BLKS]	= 0x08,
> +	[BLK_CNT]	= 0x0c,
> +	[FLOW_THRESH]	= 0x10,
> +	[PORT_VLAN]	= 0x14,
> +	[TX_PRI_MAP]	= 0x18,
> +	[TS_SEQ_MTYPE]	= 0x1c,
> +	[SA_LO]		= 0x20,
> +	[SA_HI]		= 0x24,
> +};
> +

This is wasting memory with unused static stables. There is a better
way to handle this issue.

>  static int debug_level;
>  module_param(debug_level, int, 0);
>  MODULE_PARM_DESC(debug_level, "cpsw debug level (NETIF_MSG bits)");
> @@ -146,19 +193,13 @@ struct cpsw_regs {
>  	u32	soft_reset;
>  	u32	stat_port_en;
>  	u32	ptype;
> -};
> -
> -struct cpsw_slave_regs {
> -	u32	max_blks;
> -	u32	blk_cnt;
> -	u32	flow_thresh;
> -	u32	port_vlan;
> -	u32	tx_pri_map;
> -	u32	ts_ctl;
> -	u32	ts_seq_ltype;
> -	u32	ts_vlan;
> -	u32	sa_lo;
> -	u32	sa_hi;
> +	u32	soft_idle;
> +	u32	thru_rate;
> +	u32	gap_thresh;
> +	u32	tx_start_wds;
> +	u32	flow_control;
> +	u32	vlan_ltype;
> +	u32	ts_ltype;
>  };
>  
>  struct cpsw_host_regs {
> @@ -185,7 +226,7 @@ struct cpsw_sliver_regs {
>  };
>  
>  struct cpsw_slave {
> -	struct cpsw_slave_regs __iomem	*regs;
> +	void __iomem			*regs;
>  	struct cpsw_sliver_regs __iomem	*sliver;
>  	int				slave_num;
>  	u32				mac_control;
> @@ -215,6 +256,8 @@ struct cpsw_priv {
>  	struct cpdma_ctlr		*dma;
>  	struct cpdma_chan		*txch, *rxch;
>  	struct cpsw_ale			*ale;
> +	u32				cpsw_version;
> +	u32				*slave_reg_ofs;
>  	/* snapshot of IRQ numbers */
>  	u32 irqs_table[4];
>  	u32 num_irqs;
> @@ -359,8 +402,8 @@ static inline void soft_reset(const char *module, void __iomem *reg)
>  static void cpsw_set_slave_mac(struct cpsw_slave *slave,
>  			       struct cpsw_priv *priv)
>  {
> -	__raw_writel(mac_hi(priv->mac_addr), &slave->regs->sa_hi);
> -	__raw_writel(mac_lo(priv->mac_addr), &slave->regs->sa_lo);
> +	writel(mac_hi(priv->mac_addr), cpsw_slave_reg(priv, slave, SA_HI));
> +	writel(mac_lo(priv->mac_addr), cpsw_slave_reg(priv, slave, SA_LO));
>  }
>  
>  static void _cpsw_adjust_link(struct cpsw_slave *slave,
> @@ -445,8 +488,8 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>  	soft_reset(name, &slave->sliver->soft_reset);
>  
>  	/* setup priority mapping */
> -	__raw_writel(RX_PRIORITY_MAPPING, &slave->sliver->rx_pri_map);
> -	__raw_writel(TX_PRIORITY_MAPPING, &slave->regs->tx_pri_map);
> +	writel(RX_PRIORITY_MAPPING, &slave->sliver->rx_pri_map);
> +	writel(TX_PRIORITY_MAPPING, cpsw_slave_reg(priv, slave, TX_PRI_MAP));
>  
>  	/* setup max packet size, and mac address */
>  	__raw_writel(priv->rx_packet_max, &slave->sliver->rx_maxlen);
> @@ -505,7 +548,12 @@ static int cpsw_ndo_open(struct net_device *ndev)
>  
>  	pm_runtime_get_sync(&priv->pdev->dev);
>  
> -	reg = __raw_readl(&priv->regs->id_ver);
> +	reg = readl(&priv->regs->id_ver);
> +	priv->cpsw_version = reg;
> +	if (reg == CPSW_VERSION_1)
> +		priv->slave_reg_ofs = (u32 *)slave_reg_map_ip_v1;
> +	else
> +		priv->slave_reg_ofs = (u32 *)slave_reg_map_ip_v2;

You didn't provide a way to even use this code, like a dts for a
non-am335x board with the older version.

I think it would be better to start off supporting one version and
have that fully working, and then add the older version, but *really*
add it so that it is actually working.

Thanks,
Richard
