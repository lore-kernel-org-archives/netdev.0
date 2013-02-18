From: Peter Korsgaard <jacmet-OfajU3CKLf1/SzgSGea1oA@public.gmane.org>
Subject: Re: [PATCH 3/3] driver: net: ethernet: cpsw: dual emac interface
 implementation
Date: Mon, 18 Feb 2013 14:36:20 +0100
Message-ID: <87mwv1kaln.fsf@dell.be.48ers.dk>
References: <1360612340-9266-1-git-send-email-mugunthanvnm@ti.com>
 <1360612340-9266-4-git-send-email-mugunthanvnm@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
 linux-omap-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
 linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
Return-path: <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
In-Reply-To: <1360612340-9266-4-git-send-email-mugunthanvnm-l0cyMroinI0@public.gmane.org> (Mugunthan
 V. N.'s message of "Tue, 12 Feb 2013 01:22:20 +0530")
List-Unsubscribe: <https://lists.ozlabs.org/options/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/devicetree-discuss/>
List-Post: <mailto:devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Help: <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/devicetree-discuss>,
 <mailto:devicetree-discuss-request-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org?subject=subscribe>
Errors-To: devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org
Sender: "devicetree-discuss"
 <devicetree-discuss-bounces+gldd-devicetree-discuss=m.gmane.org-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

>>>>> "M" == Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org> writes:

 M> The CPSW switch can act as Dual EMAC by segregating the switch ports
 M> using VLAN and port VLAN as per the TRM description in
 M> 14.3.2.10.2 Dual Mac Mode

 M> Following CPSW components will be common for both the interfaces.
 M> * Interrupt source is common for both eth interfaces
 M> * Interrupt pacing is common for both interfaces
 M> * Hardware statistics is common for all the ports
 M> * CPDMA is common for both eth interface
 M> * CPTS is common for both the interface and it should not be enabled on
 M>   both the interface as timestamping information doesn't contain port
 M>   information.

 M> Constrains
 M> * Reserved VID of One port should not be used in other interface which will
 M>   enable switching functionality
 M> * Same VID must not be used in both the interface which will enable switching
 M>   functionality

 M> Signed-off-by: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
 M> ---
 M>  Documentation/devicetree/bindings/net/cpsw.txt |    2 +
 M>  drivers/net/ethernet/ti/cpsw.c                 |  335 ++++++++++++++++++++----
 M>  include/linux/platform_data/cpsw.h             |    3 +
 M>  3 files changed, 288 insertions(+), 52 deletions(-)

 M> diff --git a/Documentation/devicetree/bindings/net/cpsw.txt b/Documentation/devicetree/bindings/net/cpsw.txt
 M> index 6ddd028..ecfdf75 100644
 M> --- a/Documentation/devicetree/bindings/net/cpsw.txt
 M> +++ b/Documentation/devicetree/bindings/net/cpsw.txt
 M> @@ -24,6 +24,8 @@ Required properties:
 M>  Optional properties:
 M>  - ti,hwmods		: Must be "cpgmac0"
 M>  - no_bd_ram		: Must be 0 or 1
 M> +- dual_emac		: Specifies Switch to act as Dual EMAC
 M> +- dual_emac_res_vlan	: Specifies VID to be used to segregate the ports

You forgot to CC devicetree-discuss. Properties normally use dashes (-)
instead of underscores (_). These properties are more about
configuration and not hardware.

It is not clear to me from the description that dual_emac is a boolean
(0/1). Shouldn't dual_emacs_res_vlan be a property of the slave?

It would also be good to update the example below with this.




 M>  Note: "ti,hwmods" field is used to fetch base address and irq
 M>  resources from TI, omap hwmod data base during device registration.
 M> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
 M> index 4b964bb..4ceed6e 100644
 M> --- a/drivers/net/ethernet/ti/cpsw.c
 M> +++ b/drivers/net/ethernet/ti/cpsw.c
 M> @@ -122,6 +122,10 @@ do {								\
 M>  #define CPSW_VLAN_AWARE		BIT(1)
 M>  #define CPSW_ALE_VLAN_AWARE	1
 
 M> +#define CPSW_FIFO_NORMAL_MODE		(0 << 15)
 M> +#define CPSW_FIFO_DUAL_MAC_MODE		(1 << 15)
 M> +#define CPSW_FIFO_RATE_LIMIT_MODE	(2 << 15)
 M> +
 M>  #define cpsw_enable_irq(priv)	\
 M>  	do {			\
 M>  		u32 i;		\
 M> @@ -254,7 +258,7 @@ struct cpsw_ss_regs {
 M>  struct cpsw_host_regs {
 M>  	u32	max_blks;
 M>  	u32	blk_cnt;
 M> -	u32	flow_thresh;
 M> +	u32	tx_in_ctl;
 M>  	u32	port_vlan;
 M>  	u32	tx_pri_map;
 M>  	u32	cpdma_tx_pri_map;
 M> @@ -281,6 +285,9 @@ struct cpsw_slave {
 M>  	u32				mac_control;
 M>  	struct cpsw_slave_data		*data;
 M>  	struct phy_device		*phy;
 M> +	struct net_device		*ndev;
 M> +	u32				port_vlan;
 M> +	u32				open_stat;
 M>  };
 
 M>  static inline u32 slave_read(struct cpsw_slave *slave, u32 offset)
 M> @@ -320,15 +327,63 @@ struct cpsw_priv {
 M>  	u32 irqs_table[4];
 M>  	u32 num_irqs;
 M>  	struct cpts *cpts;
 M> +	u32 emac_port;
 M>  };
 
 M>  #define napi_to_priv(napi)	container_of(napi, struct cpsw_priv, napi)
 M> -#define for_each_slave(priv, func, arg...)			\
 M> -	do {							\
 M> -		int idx;					\
 M> -		for (idx = 0; idx < (priv)->data.slaves; idx++)	\
 M> -			(func)((priv)->slaves + idx, ##arg);	\
 M> +#define for_each_slave(priv, func, arg...)				\
 M> +	do {								\
 M> +		int idx;						\
 M> +		if (priv->data.dual_emac)				\
 M> +			(func)((priv)->slaves + priv->emac_port, ##arg);\
 M> +		else							\
 M> +			for (idx = 0; idx < (priv)->data.slaves; idx++)	\
 M> +				(func)((priv)->slaves + idx, ##arg);	\
 M> +	} while (0)
 M> +#define cpsw_get_slave_ndev(priv, __slave_no__)				\
 M> +	(priv->slaves[__slave_no__].ndev)
 M> +#define cpsw_get_slave_priv(priv, __slave_no__)				\
 M> +	((priv->slaves[__slave_no__].ndev) ?				\
 M> +		netdev_priv(priv->slaves[__slave_no__].ndev) : NULL)	\
 M> +
 M> +#define cpsw_dual_emac_src_port_detect(status, priv, ndev, skb)		\
 M> +	do {								\
 M> +		if (!priv->data.dual_emac)				\
 M> +			break;						\
 M> +		if (CPDMA_RX_SOURCE_PORT(status) == 1) {		\
 M> +			ndev = cpsw_get_slave_ndev(priv, 0);		\
 M> +			priv = netdev_priv(ndev);			\
 M> +			skb->dev = ndev;				\
 M> +		} else if (CPDMA_RX_SOURCE_PORT(status) == 2) {		\
 M> +			ndev = cpsw_get_slave_ndev(priv, 1);		\
 M> +			priv = netdev_priv(ndev);			\
 M> +			skb->dev = ndev;				\
 M> +		}							\
 M>  	} while (0)
 M> +#define cpsw_add_mcast(priv, addr)					\
 M> +	do {								\
 M> +		if (priv->data.dual_emac) {				\
 M> +			struct cpsw_slave *slave = priv->slaves +	\
 M> +						priv->emac_port;	\
 M> +			int slave_port = cpsw_get_slave_port(priv,	\
 M> +						slave->slave_num);	\
 M> +			cpsw_ale_add_mcast(priv->ale, addr,		\
 M> +				1 << slave_port | 1 << priv->host_port,	\
 M> +				ALE_VLAN, slave->port_vlan, 0);		\
 M> +		} else {						\
 M> +			cpsw_ale_add_mcast(priv->ale, addr,		\
 M> +				ALE_ALL_PORTS << priv->host_port,	\
 M> +				0, 0, 0);				\
 M> +		}							\
 M> +	} while (0)
 M> +
 M> +static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
 M> +{
 M> +	if (priv->host_port == 0)
 M> +		return slave_num + 1;
 M> +	else
 M> +		return slave_num;
 M> +}
 
 M>  static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 M>  {
 M> @@ -348,8 +403,7 @@ static void cpsw_ndo_set_rx_mode(struct net_device *ndev)
 
 M>  		/* program multicast address list into ALE register */
 M>  		netdev_for_each_mc_addr(ha, ndev) {
 M> -			cpsw_ale_add_mcast(priv->ale, (u8 *)ha->addr,
 M> -				ALE_ALL_PORTS << priv->host_port, 0, 0, 0);
 M> +			cpsw_add_mcast(priv, (u8 *)ha->addr);
 M>  		}
 M>  	}
 M>  }
 M> @@ -396,6 +450,8 @@ void cpsw_rx_handler(void *token, int len, int status)
 M>  	struct cpsw_priv	*priv = netdev_priv(ndev);
 M>  	int			ret = 0;
 
 M> +	cpsw_dual_emac_src_port_detect(status, priv, ndev, skb);
 M> +
 M>  	/* free and bail if we are shutting down */
 M>  	if (unlikely(!netif_running(ndev)) ||
 M>  			unlikely(!netif_carrier_ok(ndev))) {
 M> @@ -437,18 +493,17 @@ static irqreturn_t cpsw_interrupt(int irq, void *dev_id)
 M>  		cpsw_intr_disable(priv);
 M>  		cpsw_disable_irq(priv);
 M>  		napi_schedule(&priv->napi);
 M> +	} else {
 M> +		priv = cpsw_get_slave_priv(priv, 1);
 M> +		if (likely(priv) && likely(netif_running(priv->ndev))) {
 M> +			cpsw_intr_disable(priv);
 M> +			cpsw_disable_irq(priv);
 M> +			napi_schedule(&priv->napi);
 M> +		}
 M>  	}
 M>  	return IRQ_HANDLED;
 M>  }
 
 M> -static inline int cpsw_get_slave_port(struct cpsw_priv *priv, u32 slave_num)
 M> -{
 M> -	if (priv->host_port == 0)
 M> -		return slave_num + 1;
 M> -	else
 M> -		return slave_num;
 M> -}
 M> -
 M>  static int cpsw_poll(struct napi_struct *napi, int budget)
 M>  {
 M>  	struct cpsw_priv	*priv = napi_to_priv(napi);
 M> @@ -566,6 +621,54 @@ static inline int __show_stat(char *buf, int maxlen, const char *name, u32 val)
 M>  				leader + strlen(name), val);
 M>  }
 
 M> +static int cpsw_common_res_usage_state(struct cpsw_priv *priv)
 M> +{
 M> +	u32 i;
 M> +	u32 usage_count = 0;
 M> +
 M> +	if (!priv->data.dual_emac)
 M> +		return 0;
 M> +
 M> +	for (i = 0; i < priv->data.slaves; i++)
 M> +		if (priv->slaves[i].open_stat)
 M> +			usage_count++;
 M> +
 M> +	return usage_count;
 M> +}
 M> +
 M> +static inline int cpsw_tx_packet_submit(struct net_device *ndev,
 M> +			struct cpsw_priv *priv, struct sk_buff *skb)
 M> +{
 M> +	if (!priv->data.dual_emac)
 M> +		return cpdma_chan_submit(priv->txch, skb, skb->data,
 M> +				  skb->len, 0, GFP_KERNEL);
 M> +
 M> +	if (ndev == cpsw_get_slave_ndev(priv, 0))
 M> +		return cpdma_chan_submit(priv->txch, skb, skb->data,
 M> +				  skb->len, 1, GFP_KERNEL);
 M> +	else
 M> +		return cpdma_chan_submit(priv->txch, skb, skb->data,
 M> +				  skb->len, 2, GFP_KERNEL);
 M> +}
 M> +
 M> +static inline void cpsw_add_dual_emac_def_ale_entries(
 M> +		struct cpsw_priv *priv, struct cpsw_slave *slave,
 M> +		u32 slave_port)
 M> +{
 M> +	u32 port_mask = 1 << slave_port | 1 << priv->host_port;
 M> +
 M> +	if (priv->version == CPSW_VERSION_1)
 M> +		slave_write(slave, slave->port_vlan, CPSW1_PORT_VLAN);
 M> +	else
 M> +		slave_write(slave, slave->port_vlan, CPSW2_PORT_VLAN);
 M> +	cpsw_ale_add_vlan(priv->ale, slave->port_vlan, port_mask,
 M> +			  port_mask, port_mask, 0);
 M> +	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 M> +			   port_mask, ALE_VLAN, slave->port_vlan, 0);
 M> +	cpsw_ale_add_ucast(priv->ale, priv->mac_addr,
 M> +		priv->host_port, ALE_VLAN, slave->port_vlan);
 M> +}
 M> +
 M>  static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 M>  {
 M>  	char name[32];
 M> @@ -595,8 +698,11 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
 
 M>  	slave_port = cpsw_get_slave_port(priv, slave->slave_num);
 
 M> -	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 M> -			   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 M> +	if (priv->data.dual_emac)
 M> +		cpsw_add_dual_emac_def_ale_entries(priv, slave, slave_port);
 M> +	else
 M> +		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 M> +				   1 << slave_port, 0, 0, ALE_MCAST_FWD_2);
 
 slave-> phy = phy_connect(priv->ndev, slave->data->phy_id,
 M>  				 &cpsw_adjust_link, slave->data->phy_if);
 M> @@ -634,6 +740,7 @@ static inline void cpsw_add_default_vlan(struct cpsw_priv *priv)
 M>  static void cpsw_init_host_port(struct cpsw_priv *priv)
 M>  {
 M>  	u32 control_reg;
 M> +	u32 fifo_mode;
 
 M>  	/* soft reset the controller and initialize ale */
 M>  	soft_reset("cpsw", &priv->regs->soft_reset);
 M> @@ -645,6 +752,9 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 M>  	control_reg = readl(&priv->regs->control);
 M>  	control_reg |= CPSW_VLAN_AWARE;
 M>  	writel(control_reg, &priv->regs->control);
 M> +	fifo_mode = (priv->data.dual_emac) ? CPSW_FIFO_DUAL_MAC_MODE :
 M> +		     CPSW_FIFO_NORMAL_MODE;
 M> +	writel(fifo_mode, &priv->host_port_regs->tx_in_ctl);
 
 M>  	/* setup host port priority mapping */
 M>  	__raw_writel(CPDMA_TX_PRIORITY_MAP,
 M> @@ -654,9 +764,12 @@ static void cpsw_init_host_port(struct cpsw_priv *priv)
 M>  	cpsw_ale_control_set(priv->ale, priv->host_port,
 M>  			     ALE_PORT_STATE, ALE_PORT_STATE_FORWARD);
 
 M> -	cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port, 0, 0);
 M> -	cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 M> -			   1 << priv->host_port, 0, 0, ALE_MCAST_FWD_2);
 M> +	if (!priv->data.dual_emac) {
 M> +		cpsw_ale_add_ucast(priv->ale, priv->mac_addr, priv->host_port,
 M> +				   0, 0);
 M> +		cpsw_ale_add_mcast(priv->ale, priv->ndev->broadcast,
 M> +				   1 << priv->host_port, 0, 0, ALE_MCAST_FWD_2);
 M> +	}
 M>  }
 
 M>  static int cpsw_ndo_open(struct net_device *ndev)
 M> @@ -665,7 +778,8 @@ static int cpsw_ndo_open(struct net_device *ndev)
 M>  	int i, ret;
 M>  	u32 reg;
 
 M> -	cpsw_intr_disable(priv);
 M> +	if (!cpsw_common_res_usage_state(priv))
 M> +		cpsw_intr_disable(priv);
 M>  	netif_carrier_off(ndev);
 
 M>  	pm_runtime_get_sync(&priv->pdev->dev);
 M> @@ -677,46 +791,54 @@ static int cpsw_ndo_open(struct net_device *ndev)
 M>  		 CPSW_RTL_VERSION(reg));
 
 M>  	/* initialize host and slave ports */
 M> -	cpsw_init_host_port(priv);
 M> +	if (!cpsw_common_res_usage_state(priv))
 M> +		cpsw_init_host_port(priv);
 M>  	for_each_slave(priv, cpsw_slave_open, priv);
 
 M>  	/* Add default VLAN */
 M> -	cpsw_add_default_vlan(priv);
 M> +	if (!priv->data.dual_emac)
 M> +		cpsw_add_default_vlan(priv);
 
 M> -	/* setup tx dma to fixed prio and zero offset */
 M> -	cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
 M> -	cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
 M> +	if (!cpsw_common_res_usage_state(priv)) {
 M> +		/* setup tx dma to fixed prio and zero offset */
 M> +		cpdma_control_set(priv->dma, CPDMA_TX_PRIO_FIXED, 1);
 M> +		cpdma_control_set(priv->dma, CPDMA_RX_BUFFER_OFFSET, 0);
 
 M> -	/* disable priority elevation and enable statistics on all ports */
 M> -	__raw_writel(0, &priv->regs->ptype);
 M> +		/* disable priority elevation */
 M> +		__raw_writel(0, &priv->regs->ptype);
 
 M> -	/* enable statistics collection only on the host port */
 M> -	__raw_writel(0x7, &priv->regs->stat_port_en);
 M> +		/* enable statistics collection only on all ports */
 M> +		__raw_writel(0x7, &priv->regs->stat_port_en);
 
 M> -	if (WARN_ON(!priv->data.rx_descs))
 M> -		priv->data.rx_descs = 128;
 M> +		if (WARN_ON(!priv->data.rx_descs))
 M> +			priv->data.rx_descs = 128;
 
 M> -	for (i = 0; i < priv->data.rx_descs; i++) {
 M> -		struct sk_buff *skb;
 M> +		for (i = 0; i < priv->data.rx_descs; i++) {
 M> +			struct sk_buff *skb;
 
 M> -		ret = -ENOMEM;
 M> -		skb = netdev_alloc_skb_ip_align(priv->ndev,
 M> -						priv->rx_packet_max);
 M> -		if (!skb)
 M> -			break;
 M> -		ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
 M> +			ret = -ENOMEM;
 M> +			skb = netdev_alloc_skb_ip_align(priv->ndev,
 M> +							priv->rx_packet_max);
 M> +			if (!skb)
 M> +				break;
 M> +			ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
 M>  					skb_tailroom(skb), 0, GFP_KERNEL);
 M> -		if (WARN_ON(ret < 0))
 M> -			break;
 M> +			if (WARN_ON(ret < 0))
 M> +				break;
 M> +		}
 M> +		/* continue even if we didn't manage to submit all
 M> +		 * receive descs
 M> +		 */
 M> +		cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 M>  	}
 M> -	/* continue even if we didn't manage to submit all receive descs */
 M> -	cpsw_info(priv, ifup, "submitted %d rx descriptors\n", i);
 
 M>  	cpdma_ctlr_start(priv->dma);
 M>  	cpsw_intr_enable(priv);
 M>  	napi_enable(&priv->napi);
 M>  	cpdma_ctlr_eoi(priv->dma);
 
 M> +	if (priv->data.dual_emac)
 M> +		priv->slaves[priv->emac_port].open_stat = true;
 M>  	return 0;
 M>  }
 
 M> @@ -737,12 +859,17 @@ static int cpsw_ndo_stop(struct net_device *ndev)
 M>  	netif_stop_queue(priv->ndev);
 M>  	napi_disable(&priv->napi);
 M>  	netif_carrier_off(priv->ndev);
 M> -	cpsw_intr_disable(priv);
 M> -	cpdma_ctlr_int_ctrl(priv->dma, false);
 M> -	cpdma_ctlr_stop(priv->dma);
 M> -	cpsw_ale_stop(priv->ale);
 M> +
 M> +	if (cpsw_common_res_usage_state(priv) <= 1) {
 M> +		cpsw_intr_disable(priv);
 M> +		cpdma_ctlr_int_ctrl(priv->dma, false);
 M> +		cpdma_ctlr_stop(priv->dma);
 M> +		cpsw_ale_stop(priv->ale);
 M> +	}
 M>  	for_each_slave(priv, cpsw_slave_stop, priv);
 M>  	pm_runtime_put_sync(&priv->pdev->dev);
 M> +	if (priv->data.dual_emac)
 M> +		priv->slaves[priv->emac_port].open_stat = false;
 M>  	return 0;
 M>  }
 
 M> @@ -766,8 +893,7 @@ static netdev_tx_t cpsw_ndo_start_xmit(struct sk_buff *skb,
 
 M>  	skb_tx_timestamp(skb);
 
 M> -	ret = cpdma_chan_submit(priv->txch, skb, skb->data,
 M> -				skb->len, 0, GFP_KERNEL);
 M> +	ret = cpsw_tx_packet_submit(ndev, priv, skb);
 M>  	if (unlikely(ret != 0)) {
 M>  		cpsw_err(priv, tx_err, "desc submit failed\n");
 M>  		goto fail;
 M> @@ -836,9 +962,14 @@ static void cpsw_hwtstamp_v1(struct cpsw_priv *priv)
 
 M>  static void cpsw_hwtstamp_v2(struct cpsw_priv *priv)
 M>  {
 M> -	struct cpsw_slave *slave = &priv->slaves[priv->data.cpts_active_slave];
 M> +	struct cpsw_slave *slave;
 M>  	u32 ctrl, mtype;
 
 M> +	if (priv->data.dual_emac)
 M> +		slave = &priv->slaves[priv->emac_port];
 M> +	else
 M> +		slave = &priv->slaves[priv->data.cpts_active_slave];
 M> +
 M>  	ctrl = slave_read(slave, CPSW2_CONTROL);
 M>  	ctrl &= ~CTRL_ALL_TS_MASK;
 
 M> @@ -1124,6 +1255,7 @@ static void cpsw_slave_init(struct cpsw_slave *slave, struct cpsw_priv *priv,
 slave-> data	= data;
 slave-> regs	= regs + slave_reg_ofs;
 slave-> sliver	= regs + sliver_reg_ofs;
 M> +	slave->port_vlan = data->dual_emac_res_vlan;
 M>  }
 
 M>  static int cpsw_probe_dt(struct cpsw_platform_data *data,
 M> @@ -1204,6 +1336,9 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 M>  	}
 data-> mac_control = prop;
 
 M> +	if (!of_property_read_u32(node, "dual_emac", &prop))
 M> +		data->dual_emac = prop;
 M> +
 M>  	/*
 M>  	 * Populate all the child nodes here...
 M>  	 */
 M> @@ -1237,6 +1372,18 @@ static int cpsw_probe_dt(struct cpsw_platform_data *data,
 M>  		if (mac_addr)
 M>  			memcpy(slave_data->mac_addr, mac_addr, ETH_ALEN);
 
 M> +		if (data->dual_emac) {
 M> +			if (of_property_read_u32(node, "dual_emac_res_vlan",
 M> +						 &prop)) {
 M> +				pr_err("Missing dual_emac_res_vlan in DT.\n");
 M> +				slave_data->dual_emac_res_vlan = i+1;
 M> +				pr_err("Using %d as Reserved VLAN for %d slave\n",
 M> +				       slave_data->dual_emac_res_vlan, i);
 M> +			} else {
 M> +				slave_data->dual_emac_res_vlan = prop;
 M> +			}
 M> +		}
 M> +
 M>  		i++;
 M>  	}
 
 M> @@ -1247,6 +1394,79 @@ error_ret:
 M>  	return ret;
 M>  }
 
 M> +static int cpsw_probe_dual_emac(struct platform_device *pdev,
 M> +				struct cpsw_priv *priv)
 M> +{
 M> +	struct cpsw_platform_data	*data = &priv->data;
 M> +	struct net_device		*ndev;
 M> +	struct cpsw_priv		*priv_sl2;
 M> +	int ret = 0, i;
 M> +
 M> +	ndev = alloc_etherdev(sizeof(struct cpsw_priv));
 M> +	if (!ndev) {
 M> +		pr_err("cpsw: error allocating net_device\n");
 M> +		return -ENOMEM;
 M> +	}
 M> +
 M> +	priv_sl2 = netdev_priv(ndev);
 M> +	spin_lock_init(&priv_sl2->lock);
 M> +	priv_sl2->data = *data;
 M> +	priv_sl2->pdev = pdev;
 M> +	priv_sl2->ndev = ndev;
 M> +	priv_sl2->dev  = &ndev->dev;
 M> +	priv_sl2->msg_enable = netif_msg_init(debug_level, CPSW_DEBUG);
 M> +	priv_sl2->rx_packet_max = max(rx_packet_max, 128);
 M> +
 M> +	if (is_valid_ether_addr(data->slave_data[1].mac_addr)) {
 M> +		memcpy(priv_sl2->mac_addr, data->slave_data[1].mac_addr,
 M> +			ETH_ALEN);
 M> +		pr_info("cpsw: Detected MACID = %pM\n", priv_sl2->mac_addr);
 M> +	} else {
 M> +		random_ether_addr(priv_sl2->mac_addr);
 M> +		pr_info("cpsw: Random MACID = %pM\n", priv_sl2->mac_addr);
 M> +	}
 M> +	memcpy(ndev->dev_addr, priv_sl2->mac_addr, ETH_ALEN);
 M> +
 M> +	priv_sl2->slaves = priv->slaves;
 M> +	priv_sl2->clk = priv->clk;
 M> +
 M> +	priv_sl2->cpsw_res = priv->cpsw_res;
 M> +	priv_sl2->regs = priv->regs;
 M> +	priv_sl2->host_port = priv->host_port;
 M> +	priv_sl2->host_port_regs = priv->host_port_regs;
 M> +	priv_sl2->wr_regs = priv->wr_regs;
 M> +	priv_sl2->dma = priv->dma;
 M> +	priv_sl2->txch = priv->txch;
 M> +	priv_sl2->rxch = priv->rxch;
 M> +	priv_sl2->ale = priv->ale;
 M> +	priv_sl2->emac_port = 1;
 M> +	priv->slaves[1].ndev = ndev;
 M> +	priv_sl2->cpts = priv->cpts;
 M> +	priv_sl2->version = priv->version;
 M> +
 M> +	for (i = 0; i < priv->num_irqs; i++) {
 M> +		priv_sl2->irqs_table[i] = priv->irqs_table[i];
 M> +		priv_sl2->num_irqs = priv->num_irqs;
 M> +	}
 M> +
 M> +	ndev->features |= NETIF_F_HW_VLAN_FILTER;
 M> +
 M> +	ndev->netdev_ops = &cpsw_netdev_ops;
 M> +	SET_ETHTOOL_OPS(ndev, &cpsw_ethtool_ops);
 M> +	netif_napi_add(ndev, &priv_sl2->napi, cpsw_poll, CPSW_POLL_WEIGHT);
 M> +
 M> +	/* register the network device */
 M> +	SET_NETDEV_DEV(ndev, &pdev->dev);
 M> +	ret = register_netdev(ndev);
 M> +	if (ret) {
 M> +		pr_err("cpsw: error registering net device\n");
 M> +		free_netdev(ndev);
 M> +		ret = -ENODEV;
 M> +	}
 M> +
 M> +	return ret;
 M> +}
 M> +
 M>  static int cpsw_probe(struct platform_device *pdev)
 M>  {
 M>  	struct cpsw_platform_data	*data = pdev->dev.platform_data;
 M> @@ -1310,6 +1530,9 @@ static int cpsw_probe(struct platform_device *pdev)
 M>  	for (i = 0; i < data->slaves; i++)
 priv-> slaves[i].slave_num = i;
 
 M> +	priv->slaves[0].ndev = ndev;
 M> +	priv->emac_port = 0;
 M> +
 priv-> clk = clk_get(&pdev->dev, "fck");
 M>  	if (IS_ERR(priv->clk)) {
 M>  		dev_err(&pdev->dev, "fck is not found\n");
 M> @@ -1484,6 +1707,14 @@ static int cpsw_probe(struct platform_device *pdev)
 M>  	cpsw_notice(priv, probe, "initialized device (regs %x, irq %d)\n",
 priv-> cpsw_res->start, ndev->irq);
 
 M> +	if (priv->data.dual_emac) {
 M> +		ret = cpsw_probe_dual_emac(pdev, priv);
 M> +		if (ret) {
 M> +			cpsw_err(priv, probe, "error probe slave 2 emac interface\n");
 M> +			goto clean_irq_ret;
 M> +		}
 M> +	}
 M> +
 M>  	return 0;
 
 M>  clean_irq_ret:
 M> diff --git a/include/linux/platform_data/cpsw.h b/include/linux/platform_data/cpsw.h
 M> index e962cfd..798fb80 100644
 M> --- a/include/linux/platform_data/cpsw.h
 M> +++ b/include/linux/platform_data/cpsw.h
 M> @@ -21,6 +21,8 @@ struct cpsw_slave_data {
 M>  	char		phy_id[MII_BUS_ID_SIZE];
 M>  	int		phy_if;
 M>  	u8		mac_addr[ETH_ALEN];
 M> +	u16		dual_emac_res_vlan;	/* Reserved VLAN for DualEMAC */
 M> +
 M>  };
 
 M>  struct cpsw_platform_data {
 M> @@ -36,6 +38,7 @@ struct cpsw_platform_data {
 M>  	u32	rx_descs;	/* Number of Rx Descriptios */
 M>  	u32	mac_control;	/* Mac control register */
 M>  	u16	default_vlan;	/* Def VLAN for ALE lookup in VLAN aware mode*/
 M> +	bool	dual_emac;	/* Enable Dual EMAC mode */
 M>  };
 
 M>  #endif /* __CPSW_H__ */
 M> -- 
 M> 1.7.9.5

 M> --
 M> To unsubscribe from this list: send the line "unsubscribe netdev" in
 M> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
 M> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Bye, Peter Korsgaard
