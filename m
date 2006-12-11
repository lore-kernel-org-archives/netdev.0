From: "Ramkrishna Vepa" <Ramkrishna.Vepa@neterion.com>
Subject: RE: [S2IO] De-typedef driver
Date: Mon, 11 Dec 2006 13:39:14 -0500
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77010097D1@nekter>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda.s2io.com ([72.1.205.138]:60732 "EHLO
	barracuda.s2io.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1763013AbWLKSnV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 13:43:21 -0500
Received: from owa.neterion.com (unknown [72.1.205.142])
	by barracuda.s2io.com (Spam Firewall) with ESMTP id 90A902003A4B
	for <netdev@vger.kernel.org>; Mon, 11 Dec 2006 13:43:19 -0500 (EST)
Content-class: urn:content-classes:message
To: "Ralf Baechle" <ralf@linux-mips.org>, <netdev@vger.kernel.org>,
	"Jeff Garzik" <jeff@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> 
> I stomped over the s2io driver when doing an allyesconfig build for
IP27
> where there was a namespace collision between the IP27 code and the
s2io
> driver which both use a nic_t.  I decieded both were broken, IP27
should
> not export the type and s2io was a totally typedef polluted piece of
code.
> So here's the s2io part of the fix.
[Ram] Agreed this is a problem. Please leave the typedef but change
nic_t to xframe_t. This will make it unique and is a much simpler
change.

Ram
> 
> I don't have an S2IO card so this is only build tested.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
>  drivers/net/s2io-regs.h |    6 -
>  drivers/net/s2io.c      |  488
++++++++++++++++++++++++------------------
> -----
>  drivers/net/s2io.h      |  199 ++++++++++---------
>  3 files changed, 347 insertions(+), 346 deletions(-)
> 
> diff --git a/drivers/net/s2io-regs.h b/drivers/net/s2io-regs.h
> index a914fef..e01bf27 100644
> --- a/drivers/net/s2io-regs.h
> +++ b/drivers/net/s2io-regs.h
> @@ -15,7 +15,7 @@ #define _REGS_H
> 
>  #define TBD 0
> 
> -typedef struct _XENA_dev_config {
> +struct XENA_dev_config {
>  /* Convention: mHAL_XXX is mask, vHAL_XXX is value */
> 
>  /* General Control-Status Registers */
> @@ -851,9 +851,9 @@ #define SPI_CONTROL_NACK		BIT(5)
>  #define SPI_CONTROL_DONE		BIT(6)
>  	u64 spi_data;
>  #define SPI_DATA_WRITE(data,len)	vBIT(data,0,len)
> -} XENA_dev_config_t;
> +};
> 
> -#define XENA_REG_SPACE	sizeof(XENA_dev_config_t)
> +#define XENA_REG_SPACE	sizeof(struct XENA_dev_config)
>  #define	XENA_EEPROM_SPACE (0x01 << 11)
> 
>  #endif				/* _REGS_H */
> diff --git a/drivers/net/s2io.c b/drivers/net/s2io.c
> index 250cdbe..13cf291 100644
> --- a/drivers/net/s2io.c
> +++ b/drivers/net/s2io.c
> @@ -86,7 +86,7 @@ static char s2io_driver_version[] = DRV_
>  static int rxd_size[4] = {32,48,48,64};
>  static int rxd_count[4] = {127,85,85,63};
> 
> -static inline int RXD_IS_UP2DT(RxD_t *rxdp)
> +static inline int RXD_IS_UP2DT(struct RxD_t *rxdp)
>  {
>  	int ret;
> 
> @@ -111,9 +111,9 @@ #define LINK_IS_UP(val64) (!(val64 & (AD
>  #define TASKLET_IN_USE test_and_set_bit(0, (&sp->tasklet_status))
>  #define PANIC	1
>  #define LOW	2
> -static inline int rx_buffer_level(nic_t * sp, int rxb_size, int ring)
> +static inline int rx_buffer_level(struct s2io_nic * sp, int rxb_size,
int
> ring)
>  {
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
> 
>  	mac_control = &sp->mac_control;
>  	if (rxb_size <= rxd_count[sp->rxd_mode])
> @@ -286,7 +286,7 @@ #define S2IO_TIMER_CONF(timer, handle, a
>  static void s2io_vlan_rx_register(struct net_device *dev,
>  					struct vlan_group *grp)
>  {
> -	nic_t *nic = dev->priv;
> +	struct s2io_nic *nic = dev->priv;
>  	unsigned long flags;
> 
>  	spin_lock_irqsave(&nic->tx_lock, flags);
> @@ -297,7 +297,7 @@ static void s2io_vlan_rx_register(struct
>  /* Unregister the vlan */
>  static void s2io_vlan_rx_kill_vid(struct net_device *dev, unsigned
long
> vid)
>  {
> -	nic_t *nic = dev->priv;
> +	struct s2io_nic *nic = dev->priv;
>  	unsigned long flags;
> 
>  	spin_lock_irqsave(&nic->tx_lock, flags);
> @@ -457,14 +457,14 @@ static int init_shared_mem(struct s2io_n
>  	u32 size;
>  	void *tmp_v_addr, *tmp_v_addr_next;
>  	dma_addr_t tmp_p_addr, tmp_p_addr_next;
> -	RxD_block_t *pre_rxd_blk = NULL;
> +	struct RxD_block *pre_rxd_blk = NULL;
>  	int i, j, blk_cnt, rx_sz, tx_sz;
>  	int lst_size, lst_per_page;
>  	struct net_device *dev = nic->dev;
>  	unsigned long tmp;
> -	buffAdd_t *ba;
> +	struct bufAdd *ba;
> 
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	mac_control = &nic->mac_control;
> @@ -482,13 +482,13 @@ static int init_shared_mem(struct s2io_n
>  		return -EINVAL;
>  	}
> 
> -	lst_size = (sizeof(TxD_t) * config->max_txds);
> +	lst_size = (sizeof(struct TxD) * config->max_txds);
>  	tx_sz = lst_size * size;
>  	lst_per_page = PAGE_SIZE / lst_size;
> 
>  	for (i = 0; i < config->tx_fifo_num; i++) {
>  		int fifo_len = config->tx_cfg[i].fifo_len;
> -		int list_holder_size = fifo_len *
sizeof(list_info_hold_t);
> +		int list_holder_size = fifo_len * sizeof(struct
> list_info_hold);
>  		mac_control->fifos[i].list_info =
kmalloc(list_holder_size,
>  							  GFP_KERNEL);
>  		if (!mac_control->fifos[i].list_info) {
> @@ -580,9 +580,9 @@ static int init_shared_mem(struct s2io_n
>  			mac_control->rings[i].block_count;
>  	}
>  	if (nic->rxd_mode == RXD_MODE_1)
> -		size = (size * (sizeof(RxD1_t)));
> +		size = (size * (sizeof(struct RxD1)));
>  	else
> -		size = (size * (sizeof(RxD3_t)));
> +		size = (size * (sizeof(struct RxD3)));
>  	rx_sz = size;
> 
>  	for (i = 0; i < config->rx_ring_num; i++) {
> @@ -601,7 +601,7 @@ static int init_shared_mem(struct s2io_n
>  				(rxd_count[nic->rxd_mode] + 1);
>  		/*  Allocating all the Rx blocks */
>  		for (j = 0; j < blk_cnt; j++) {
> -			rx_block_info_t *rx_blocks;
> +			struct rx_block_info *rx_blocks;
>  			int l;
> 
>  			rx_blocks = &mac_control->rings[i].rx_blocks[j];
> @@ -621,7 +621,7 @@ static int init_shared_mem(struct s2io_n
>  			memset(tmp_v_addr, 0, size);
>  			rx_blocks->block_virt_addr = tmp_v_addr;
>  			rx_blocks->block_dma_addr = tmp_p_addr;
> -			rx_blocks->rxds = kmalloc(sizeof(rxd_info_t)*
> +			rx_blocks->rxds = kmalloc(sizeof(struct
rxd_info)*
>
rxd_count[nic->rxd_mode],
>  						  GFP_KERNEL);
>  			for (l=0; l<rxd_count[nic->rxd_mode];l++) {
> @@ -646,7 +646,7 @@ static int init_shared_mem(struct s2io_n
>  				mac_control->rings[i].rx_blocks[(j + 1)
%
>  					      blk_cnt].block_dma_addr;
> 
> -			pre_rxd_blk = (RxD_block_t *) tmp_v_addr;
> +			pre_rxd_blk = (struct RxD_block *) tmp_v_addr;
>  			pre_rxd_blk->reserved_2_pNext_RxD_block =
>  			    (unsigned long) tmp_v_addr_next;
>  			pre_rxd_blk->pNext_RxD_Blk_physical =
> @@ -662,14 +662,14 @@ static int init_shared_mem(struct s2io_n
>  			blk_cnt = config->rx_cfg[i].num_rxd /
>  			   (rxd_count[nic->rxd_mode]+ 1);
>  			mac_control->rings[i].ba =
> -				kmalloc((sizeof(buffAdd_t *) * blk_cnt),
> +				kmalloc((sizeof(struct bufAdd *) *
blk_cnt),
>  				     GFP_KERNEL);
>  			if (!mac_control->rings[i].ba)
>  				return -ENOMEM;
>  			for (j = 0; j < blk_cnt; j++) {
>  				int k = 0;
>  				mac_control->rings[i].ba[j] =
> -					kmalloc((sizeof(buffAdd_t) *
> +					kmalloc((sizeof(struct bufAdd) *
>
(rxd_count[nic->rxd_mode] + 1)),
>  						GFP_KERNEL);
>  				if (!mac_control->rings[i].ba[j])
> @@ -701,7 +701,7 @@ static int init_shared_mem(struct s2io_n
>  	}
> 
>  	/* Allocation and initialization of Statistics block */
> -	size = sizeof(StatInfo_t);
> +	size = sizeof(struct stat_block);
>  	mac_control->stats_mem = pci_alloc_consistent
>  	    (nic->pdev, size, &mac_control->stats_mem_phy);
> 
> @@ -716,7 +716,7 @@ static int init_shared_mem(struct s2io_n
>  	mac_control->stats_mem_sz = size;
> 
>  	tmp_v_addr = mac_control->stats_mem;
> -	mac_control->stats_info = (StatInfo_t *) tmp_v_addr;
> +	mac_control->stats_info = (struct stat_block *) tmp_v_addr;
>  	memset(tmp_v_addr, 0, size);
>  	DBG_PRINT(INIT_DBG, "%s:Ring Mem PHY: 0x%llx\n", dev->name,
>  		  (unsigned long long) tmp_p_addr);
> @@ -736,7 +736,7 @@ static void free_shared_mem(struct s2io_
>  	int i, j, blk_cnt, size;
>  	void *tmp_v_addr;
>  	dma_addr_t tmp_p_addr;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	int lst_size, lst_per_page;
>  	struct net_device *dev = nic->dev;
> @@ -747,7 +747,7 @@ static void free_shared_mem(struct s2io_
>  	mac_control = &nic->mac_control;
>  	config = &nic->config;
> 
> -	lst_size = (sizeof(TxD_t) * config->max_txds);
> +	lst_size = (sizeof(struct TxD) * config->max_txds);
>  	lst_per_page = PAGE_SIZE / lst_size;
> 
>  	for (i = 0; i < config->tx_fifo_num; i++) {
> @@ -810,7 +810,7 @@ static void free_shared_mem(struct s2io_
>  				if (!mac_control->rings[i].ba[j])
>  					continue;
>  				while (k != rxd_count[nic->rxd_mode]) {
> -					buffAdd_t *ba =
> +					struct bufAdd *ba =
>
&mac_control->rings[i].ba[j][k];
>  					kfree(ba->ba_0_org);
>  					kfree(ba->ba_1_org);
> @@ -836,9 +836,9 @@ static void free_shared_mem(struct s2io_
>   * s2io_verify_pci_mode -
>   */
> 
> -static int s2io_verify_pci_mode(nic_t *nic)
> +static int s2io_verify_pci_mode(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	register u64 val64 = 0;
>  	int     mode;
> 
> @@ -869,9 +869,9 @@ static int bus_speed[8] = {33, 133, 133,
>  /**
>   * s2io_print_pci_mode -
>   */
> -static int s2io_print_pci_mode(nic_t *nic)
> +static int s2io_print_pci_mode(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	register u64 val64 = 0;
>  	int	mode;
>  	struct config_param *config = &nic->config;
> @@ -939,13 +939,13 @@ static int s2io_print_pci_mode(nic_t *ni
> 
>  static int init_nic(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	struct net_device *dev = nic->dev;
>  	register u64 val64 = 0;
>  	void __iomem *add;
>  	u32 time;
>  	int i, j;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	int dtx_cnt = 0;
>  	unsigned long long mem_share;
> @@ -1627,7 +1627,7 @@ static int init_nic(struct s2io_nic *nic
>  #define LINK_UP_DOWN_INTERRUPT		1
>  #define MAC_RMAC_ERR_TIMER		2
> 
> -static int s2io_link_fault_indication(nic_t *nic)
> +static int s2io_link_fault_indication(struct s2io_nic *nic)
>  {
>  	if (nic->intr_type != INTA)
>  		return MAC_RMAC_ERR_TIMER;
> @@ -1650,7 +1650,7 @@ static int s2io_link_fault_indication(ni
> 
>  static void en_dis_able_nic_intrs(struct s2io_nic *nic, u16 mask, int
> flag)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	register u64 val64 = 0, temp64 = 0;
> 
>  	/*  Top level interrupt classification */
> @@ -1931,7 +1931,7 @@ static int check_prc_pcc_state(u64 val64
>   *          0 If Xena is not quiescence
>   */
> 
> -static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag)
> +static int verify_xena_quiescence(struct s2io_nic *sp, u64 val64, int
> flag)
>  {
>  	int ret = 0, herc;
>  	u64 tmp64 = ~((u64) val64);
> @@ -1959,9 +1959,9 @@ static int verify_xena_quiescence(nic_t
>   *
>   */
> 
> -static void fix_mac_address(nic_t * sp)
> +static void fix_mac_address(struct s2io_nic * sp)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64;
>  	int i = 0;
> 
> @@ -1987,11 +1987,11 @@ static void fix_mac_address(nic_t * sp)
> 
>  static int start_nic(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	struct net_device *dev = nic->dev;
>  	register u64 val64 = 0;
>  	u16 subid, i;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	mac_control = &nic->mac_control;
> @@ -2096,11 +2096,11 @@ static int start_nic(struct s2io_nic *ni
>  /**
>   * s2io_txdl_getskb - Get the skb from txdl, unmap and return skb
>   */
> -static struct sk_buff *s2io_txdl_getskb(fifo_info_t *fifo_data, TxD_t
> *txdlp, int get_off)
> +static struct sk_buff *s2io_txdl_getskb(struct fifo_info *fifo_data,
> struct TxD *txdlp, int get_off)
>  {
> -	nic_t *nic = fifo_data->nic;
> +	struct s2io_nic *nic = fifo_data->nic;
>  	struct sk_buff *skb;
> -	TxD_t *txds;
> +	struct TxD *txds;
>  	u16 j, frg_cnt;
> 
>  	txds = txdlp;
> @@ -2114,7 +2114,7 @@ static struct sk_buff *s2io_txdl_getskb(
>  	skb = (struct sk_buff *) ((unsigned long)
>  			txds->Host_Control);
>  	if (!skb) {
> -		memset(txdlp, 0, (sizeof(TxD_t) * fifo_data->max_txds));
> +		memset(txdlp, 0, (sizeof(struct TxD) *
fifo_data->max_txds));
>  		return NULL;
>  	}
>  	pci_unmap_single(nic->pdev, (dma_addr_t)
> @@ -2133,7 +2133,7 @@ static struct sk_buff *s2io_txdl_getskb(
>  				       frag->size, PCI_DMA_TODEVICE);
>  		}
>  	}
> -	memset(txdlp,0, (sizeof(TxD_t) * fifo_data->max_txds));
> +	memset(txdlp,0, (sizeof(struct TxD) * fifo_data->max_txds));
>  	return(skb);
>  }
> 
> @@ -2149,9 +2149,9 @@ static void free_tx_buffers(struct s2io_
>  {
>  	struct net_device *dev = nic->dev;
>  	struct sk_buff *skb;
> -	TxD_t *txdp;
> +	struct TxD *txdp;
>  	int i, j;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	int cnt = 0;
> 
> @@ -2160,7 +2160,7 @@ static void free_tx_buffers(struct s2io_
> 
>  	for (i = 0; i < config->tx_fifo_num; i++) {
>  		for (j = 0; j < config->tx_cfg[i].fifo_len - 1; j++) {
> -			txdp = (TxD_t *)
mac_control->fifos[i].list_info[j].
> +			txdp = (struct TxD *) mac_control-
> >fifos[i].list_info[j].
>  			    list_virt_addr;
>  			skb = s2io_txdl_getskb(&mac_control->fifos[i],
txdp, j);
>  			if (skb) {
> @@ -2188,10 +2188,10 @@ static void free_tx_buffers(struct s2io_
> 
>  static void stop_nic(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	register u64 val64 = 0;
>  	u16 interruptible;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	mac_control = &nic->mac_control;
> @@ -2209,14 +2209,14 @@ static void stop_nic(struct s2io_nic *ni
>  	writeq(val64, &bar0->adapter_control);
>  }
> 
> -static int fill_rxd_3buf(nic_t *nic, RxD_t *rxdp, struct sk_buff
*skb)
> +static int fill_rxd_3buf(struct s2io_nic *nic, struct RxD_t *rxdp,
struct
> sk_buff *skb)
>  {
>  	struct net_device *dev = nic->dev;
>  	struct sk_buff *frag_list;
>  	void *tmp;
> 
>  	/* Buffer-1 receives L3/L4 headers */
> -	((RxD3_t*)rxdp)->Buffer1_ptr = pci_map_single
> +	((struct RxD3*)rxdp)->Buffer1_ptr = pci_map_single
>  			(nic->pdev, skb->data, l3l4hdr_size + 4,
>  			PCI_DMA_FROMDEVICE);
> 
> @@ -2233,7 +2233,7 @@ static int fill_rxd_3buf(nic_t *nic, RxD
>  	frag_list->tail = tmp;
> 
>  	/* Buffer-2 receives L4 data payload */
> -	((RxD3_t*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
> +	((struct RxD3*)rxdp)->Buffer2_ptr = pci_map_single(nic->pdev,
>  				frag_list->data, dev->mtu,
>  				PCI_DMA_FROMDEVICE);
>  	rxdp->Control_2 |= SET_BUFFER1_SIZE_3(l3l4hdr_size + 4);
> @@ -2267,18 +2267,18 @@ static int fill_rx_buffers(struct s2io_n
>  {
>  	struct net_device *dev = nic->dev;
>  	struct sk_buff *skb;
> -	RxD_t *rxdp;
> +	struct RxD_t *rxdp;
>  	int off, off1, size, block_no, block_no1;
>  	u32 alloc_tab = 0;
>  	u32 alloc_cnt;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	u64 tmp;
> -	buffAdd_t *ba;
> +	struct bufAdd *ba;
>  #ifndef CONFIG_S2IO_NAPI
>  	unsigned long flags;
>  #endif
> -	RxD_t *first_rxdp = NULL;
> +	struct RxD_t *first_rxdp = NULL;
> 
>  	mac_control = &nic->mac_control;
>  	config = &nic->config;
> @@ -2357,9 +2357,9 @@ #endif
>  		}
>  		if (nic->rxd_mode == RXD_MODE_1) {
>  			/* 1 buffer mode - normal operation mode */
> -			memset(rxdp, 0, sizeof(RxD1_t));
> +			memset(rxdp, 0, sizeof(struct RxD1));
>  			skb_reserve(skb, NET_IP_ALIGN);
> -			((RxD1_t*)rxdp)->Buffer0_ptr = pci_map_single
> +			((struct RxD1*)rxdp)->Buffer0_ptr =
pci_map_single
>  			    (nic->pdev, skb->data, size - NET_IP_ALIGN,
>  				PCI_DMA_FROMDEVICE);
>  			rxdp->Control_2 = SET_BUFFER0_SIZE_1(size -
> NET_IP_ALIGN);
> @@ -2376,7 +2376,7 @@ #endif
>  			 * payload
>  			 */
> 
> -			memset(rxdp, 0, sizeof(RxD3_t));
> +			memset(rxdp, 0, sizeof(struct RxD3));
>  			ba =
&mac_control->rings[ring_no].ba[block_no][off];
>  			skb_reserve(skb, BUF0_LEN);
>  			tmp = (u64)(unsigned long) skb->data;
> @@ -2385,13 +2385,13 @@ #endif
>  			skb->data = (void *) (unsigned long)tmp;
>  			skb->tail = (void *) (unsigned long)tmp;
> 
> -			if (!(((RxD3_t*)rxdp)->Buffer0_ptr))
> -				((RxD3_t*)rxdp)->Buffer0_ptr =
> +			if (!(((struct RxD3*)rxdp)->Buffer0_ptr))
> +				((struct RxD3*)rxdp)->Buffer0_ptr =
>  				   pci_map_single(nic->pdev, ba->ba_0,
BUF0_LEN,
>  					   PCI_DMA_FROMDEVICE);
>  			else
>
pci_dma_sync_single_for_device(nic->pdev,
> -				    (dma_addr_t)
((RxD3_t*)rxdp)->Buffer0_ptr,
> +				    (dma_addr_t) ((struct RxD3*)rxdp)-
> >Buffer0_ptr,
>  				    BUF0_LEN, PCI_DMA_FROMDEVICE);
>  			rxdp->Control_2 = SET_BUFFER0_SIZE_3(BUF0_LEN);
>  			if (nic->rxd_mode == RXD_MODE_3B) {
> @@ -2401,13 +2401,13 @@ #endif
>  				 * Buffer2 will have L3/L4 header plus
>  				 * L4 payload
>  				 */
> -				((RxD3_t*)rxdp)->Buffer2_ptr =
pci_map_single
> +				((struct RxD3*)rxdp)->Buffer2_ptr =
pci_map_single
>  				(nic->pdev, skb->data, dev->mtu + 4,
>  						PCI_DMA_FROMDEVICE);
> 
>  				/* Buffer-1 will be dummy buffer. Not
used */
> -				if (!(((RxD3_t*)rxdp)->Buffer1_ptr)) {
> -					((RxD3_t*)rxdp)->Buffer1_ptr =
> +				if (!(((struct
RxD3*)rxdp)->Buffer1_ptr)) {
> +					((struct
RxD3*)rxdp)->Buffer1_ptr =
>
pci_map_single(nic->pdev,
>  						ba->ba_1, BUF1_LEN,
>  						PCI_DMA_FROMDEVICE);
> @@ -2467,9 +2467,9 @@ static void free_rxd_blk(struct s2io_nic
>  	struct net_device *dev = sp->dev;
>  	int j;
>  	struct sk_buff *skb;
> -	RxD_t *rxdp;
> -	mac_info_t *mac_control;
> -	buffAdd_t *ba;
> +	struct RxD_t *rxdp;
> +	struct mac_info *mac_control;
> +	struct bufAdd *ba;
> 
>  	mac_control = &sp->mac_control;
>  	for (j = 0 ; j < rxd_count[sp->rxd_mode]; j++) {
> @@ -2482,41 +2482,41 @@ static void free_rxd_blk(struct s2io_nic
>  		}
>  		if (sp->rxd_mode == RXD_MODE_1) {
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				 ((RxD1_t*)rxdp)->Buffer0_ptr,
> +				 ((struct RxD1*)rxdp)->Buffer0_ptr,
>  				 dev->mtu +
>  				 HEADER_ETHERNET_II_802_3_SIZE
>  				 + HEADER_802_2_SIZE +
>  				 HEADER_SNAP_SIZE,
>  				 PCI_DMA_FROMDEVICE);
> -			memset(rxdp, 0, sizeof(RxD1_t));
> +			memset(rxdp, 0, sizeof(struct RxD1));
>  		} else if(sp->rxd_mode == RXD_MODE_3B) {
>  			ba = &mac_control->rings[ring_no].
>  				ba[blk][j];
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				 ((RxD3_t*)rxdp)->Buffer0_ptr,
> +				 ((struct RxD3*)rxdp)->Buffer0_ptr,
>  				 BUF0_LEN,
>  				 PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				 ((RxD3_t*)rxdp)->Buffer1_ptr,
> +				 ((struct RxD3*)rxdp)->Buffer1_ptr,
>  				 BUF1_LEN,
>  				 PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				 ((RxD3_t*)rxdp)->Buffer2_ptr,
> +				 ((struct RxD3*)rxdp)->Buffer2_ptr,
>  				 dev->mtu + 4,
>  				 PCI_DMA_FROMDEVICE);
> -			memset(rxdp, 0, sizeof(RxD3_t));
> +			memset(rxdp, 0, sizeof(struct RxD3));
>  		} else {
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				((RxD3_t*)rxdp)->Buffer0_ptr, BUF0_LEN,
> +				((struct RxD3*)rxdp)->Buffer0_ptr,
BUF0_LEN,
>  				PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				((RxD3_t*)rxdp)->Buffer1_ptr,
> +				((struct RxD3*)rxdp)->Buffer1_ptr,
>  				l3l4hdr_size + 4,
>  				PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(sp->pdev, (dma_addr_t)
> -				((RxD3_t*)rxdp)->Buffer2_ptr, dev->mtu,
> +				((struct RxD3*)rxdp)->Buffer2_ptr,
dev->mtu,
>  				PCI_DMA_FROMDEVICE);
> -			memset(rxdp, 0, sizeof(RxD3_t));
> +			memset(rxdp, 0, sizeof(struct RxD3));
>  		}
>  		dev_kfree_skb(skb);
>  		atomic_dec(&sp->rx_bufs_left[ring_no]);
> @@ -2536,7 +2536,7 @@ static void free_rx_buffers(struct s2io_
>  {
>  	struct net_device *dev = sp->dev;
>  	int i, blk = 0, buf_cnt = 0;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	mac_control = &sp->mac_control;
> @@ -2572,11 +2572,11 @@ static void free_rx_buffers(struct s2io_
>  #if defined(CONFIG_S2IO_NAPI)
>  static int s2io_poll(struct net_device *dev, int *budget)
>  {
> -	nic_t *nic = dev->priv;
> +	struct s2io_nic *nic = dev->priv;
>  	int pkt_cnt = 0, org_pkts_to_process;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
>  	int i;
> 
> @@ -2648,10 +2648,10 @@ #ifdef CONFIG_NET_POLL_CONTROLLER
>   */
>  static void s2io_netpoll(struct net_device *dev)
>  {
> -	nic_t *nic = dev->priv;
> -	mac_info_t *mac_control;
> +	struct s2io_nic *nic = dev->priv;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u64 val64 = 0xFFFFFFFFFFFFFFFFULL;
>  	int i;
> 
> @@ -2700,13 +2700,13 @@ #endif
>   *  Return Value:
>   *  NONE.
>   */
> -static void rx_intr_handler(ring_info_t *ring_data)
> +static void rx_intr_handler(struct ring_info *ring_data)
>  {
> -	nic_t *nic = ring_data->nic;
> +	struct s2io_nic *nic = ring_data->nic;
>  	struct net_device *dev = (struct net_device *) nic->dev;
>  	int get_block, put_block, put_offset;
> -	rx_curr_get_info_t get_info, put_info;
> -	RxD_t *rxdp;
> +	struct rx_curr_get_info get_info, put_info;
> +	struct RxD_t *rxdp;
>  	struct sk_buff *skb;
>  #ifndef CONFIG_S2IO_NAPI
>  	int pkt_cnt = 0;
> @@ -2723,7 +2723,7 @@ #endif
> 
>  	get_info = ring_data->rx_curr_get_info;
>  	get_block = get_info.block_index;
> -	put_info = ring_data->rx_curr_put_info;
> +	memcpy(&put_info, &ring_data->rx_curr_put_info,
sizeof(put_info));
>  	put_block = put_info.block_index;
>  	rxdp = ring_data-
> >rx_blocks[get_block].rxds[get_info.offset].virt_addr;
>  #ifndef CONFIG_S2IO_NAPI
> @@ -2751,7 +2751,7 @@ #endif
>  		}
>  		if (nic->rxd_mode == RXD_MODE_1) {
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> -				 ((RxD1_t*)rxdp)->Buffer0_ptr,
> +				 ((struct RxD1*)rxdp)->Buffer0_ptr,
>  				 dev->mtu +
>  				 HEADER_ETHERNET_II_802_3_SIZE +
>  				 HEADER_802_2_SIZE +
> @@ -2759,22 +2759,22 @@ #endif
>  				 PCI_DMA_FROMDEVICE);
>  		} else if (nic->rxd_mode == RXD_MODE_3B) {
>  			pci_dma_sync_single_for_cpu(nic->pdev,
(dma_addr_t)
> -				 ((RxD3_t*)rxdp)->Buffer0_ptr,
> +				 ((struct RxD3*)rxdp)->Buffer0_ptr,
>  				 BUF0_LEN, PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> -				 ((RxD3_t*)rxdp)->Buffer2_ptr,
> +				 ((struct RxD3*)rxdp)->Buffer2_ptr,
>  				 dev->mtu + 4,
>  				 PCI_DMA_FROMDEVICE);
>  		} else {
>  			pci_dma_sync_single_for_cpu(nic->pdev,
(dma_addr_t)
> -					 ((RxD3_t*)rxdp)->Buffer0_ptr,
BUF0_LEN,
> +					 ((struct
RxD3*)rxdp)->Buffer0_ptr,
> BUF0_LEN,
>  					 PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> -					 ((RxD3_t*)rxdp)->Buffer1_ptr,
> +					 ((struct
RxD3*)rxdp)->Buffer1_ptr,
>  					 l3l4hdr_size + 4,
>  					 PCI_DMA_FROMDEVICE);
>  			pci_unmap_single(nic->pdev, (dma_addr_t)
> -					 ((RxD3_t*)rxdp)->Buffer2_ptr,
> +					 ((struct
RxD3*)rxdp)->Buffer2_ptr,
>  					 dev->mtu, PCI_DMA_FROMDEVICE);
>  		}
>  		prefetch(skb->data);
> @@ -2806,7 +2806,7 @@ #endif
>  	if (nic->lro) {
>  		/* Clear all LRO sessions before exiting */
>  		for (i=0; i<MAX_LRO_SESSIONS; i++) {
> -			lro_t *lro = &nic->lro0_n[i];
> +			struct lro *lro = &nic->lro0_n[i];
>  			if (lro->in_use) {
>  				update_L3L4_header(nic, lro);
>  				queue_rx_frame(lro->parent);
> @@ -2830,17 +2830,17 @@ #endif
>   *  NONE
>   */
> 
> -static void tx_intr_handler(fifo_info_t *fifo_data)
> +static void tx_intr_handler(struct fifo_info *fifo_data)
>  {
> -	nic_t *nic = fifo_data->nic;
> +	struct s2io_nic *nic = fifo_data->nic;
>  	struct net_device *dev = (struct net_device *) nic->dev;
> -	tx_curr_get_info_t get_info, put_info;
> +	struct tx_curr_get_info get_info, put_info;
>  	struct sk_buff *skb;
> -	TxD_t *txdlp;
> +	struct TxD *txdlp;
> 
>  	get_info = fifo_data->tx_curr_get_info;
> -	put_info = fifo_data->tx_curr_put_info;
> -	txdlp = (TxD_t *) fifo_data->list_info[get_info.offset].
> +	memcpy(&put_info, &fifo_data->tx_curr_put_info,
sizeof(put_info));
> +	txdlp = (struct TxD *) fifo_data->list_info[get_info.offset].
>  	    list_virt_addr;
>  	while ((!(txdlp->Control_1 & TXD_LIST_OWN_XENA)) &&
>  	       (get_info.offset != put_info.offset) &&
> @@ -2878,7 +2878,7 @@ to loss of link\n");
>  		get_info.offset++;
>  		if (get_info.offset == get_info.fifo_len + 1)
>  			get_info.offset = 0;
> -		txdlp = (TxD_t *) fifo_data->list_info
> +		txdlp = (struct TxD *) fifo_data->list_info
>  		    [get_info.offset].list_virt_addr;
>  		fifo_data->tx_curr_get_info.offset =
>  		    get_info.offset;
> @@ -2903,8 +2903,8 @@ to loss of link\n");
>  static void s2io_mdio_write(u32 mmd_type, u64 addr, u16 value, struct
> net_device *dev)
>  {
>  	u64 val64 = 0x0;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> 
>  	//address transaction
>  	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
> @@ -2952,8 +2952,8 @@ static u64 s2io_mdio_read(u32 mmd_type,
>  {
>  	u64 val64 = 0x0;
>  	u64 rval64 = 0x0;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> 
>  	/* address transaction */
>  	val64 = val64 | MDIO_MMD_INDX_ADDR(addr)
> @@ -3056,8 +3056,8 @@ static void s2io_updt_xpak_counter(struc
>  	u64 val64 = 0x0;
>  	u64 addr  = 0x0;
> 
> -	nic_t *sp = dev->priv;
> -	StatInfo_t *stat_info = sp->mac_control.stats_info;
> +	struct s2io_nic *sp = dev->priv;
> +	struct stat_block *stat_info = sp->mac_control.stats_info;
> 
>  	/* Check the communication with the MDIO slave */
>  	addr = 0x0000;
> @@ -3155,7 +3155,7 @@ static void s2io_updt_xpak_counter(struc
>  static void alarm_intr_handler(struct s2io_nic *nic)
>  {
>  	struct net_device *dev = (struct net_device *) nic->dev;
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	register u64 val64 = 0, err_reg = 0;
>  	u64 cnt;
>  	int i;
> @@ -3309,9 +3309,9 @@ static int wait_for_cmd_complete(void __
>   *  void.
>   */
> 
> -static void s2io_reset(nic_t * sp)
> +static void s2io_reset(struct s2io_nic * sp)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64;
>  	u16 subid, pci_cmd;
> 
> @@ -3400,10 +3400,10 @@ static void s2io_reset(nic_t * sp)
>   *  SUCCESS on success and FAILURE on failure.
>   */
> 
> -static int s2io_set_swapper(nic_t * sp)
> +static int s2io_set_swapper(struct s2io_nic * sp)
>  {
>  	struct net_device *dev = sp->dev;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64, valt, valr;
> 
>  	/*
> @@ -3528,9 +3528,9 @@ #endif
>  	return SUCCESS;
>  }
> 
> -static int wait_for_msix_trans(nic_t *nic, int i)
> +static int wait_for_msix_trans(struct s2io_nic *nic, int i)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u64 val64;
>  	int ret = 0, cnt = 0;
> 
> @@ -3549,9 +3549,9 @@ static int wait_for_msix_trans(nic_t *ni
>  	return ret;
>  }
> 
> -static void restore_xmsi_data(nic_t *nic)
> +static void restore_xmsi_data(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u64 val64;
>  	int i;
> 
> @@ -3567,9 +3567,9 @@ static void restore_xmsi_data(nic_t *nic
>  	}
>  }
> 
> -static void store_xmsi_data(nic_t *nic)
> +static void store_xmsi_data(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u64 val64, addr, data;
>  	int i;
> 
> @@ -3590,9 +3590,9 @@ static void store_xmsi_data(nic_t *nic)
>  	}
>  }
> 
> -int s2io_enable_msi(nic_t *nic)
> +int s2io_enable_msi(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u16 msi_ctrl, msg_val;
>  	struct config_param *config = &nic->config;
>  	struct net_device *dev = nic->dev;
> @@ -3640,9 +3640,9 @@ int s2io_enable_msi(nic_t *nic)
>  	return 0;
>  }
> 
> -static int s2io_enable_msi_x(nic_t *nic)
> +static int s2io_enable_msi_x(struct s2io_nic *nic)
>  {
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	u64 tx_mat, rx_mat;
>  	u16 msi_control; /* Temp variable */
>  	int ret, i, j, msix_indx = 1;
> @@ -3750,7 +3750,7 @@ static int s2io_enable_msi_x(nic_t *nic)
> 
>  static int s2io_open(struct net_device *dev)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	int err = 0;
> 
>  	/*
> @@ -3803,7 +3803,7 @@ hw_init_failed:
> 
>  static int s2io_close(struct net_device *dev)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	flush_scheduled_work();
>  	netif_stop_queue(dev);
> @@ -3829,15 +3829,15 @@ static int s2io_close(struct net_device
> 
>  static int s2io_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	u16 frg_cnt, frg_len, i, queue, queue_len, put_off, get_off;
>  	register u64 val64;
> -	TxD_t *txdp;
> -	TxFIFO_element_t __iomem *tx_fifo;
> +	struct TxD *txdp;
> +	struct TxFIFO_element __iomem *tx_fifo;
>  	unsigned long flags;
>  	u16 vlan_tag = 0;
>  	int vlan_priority = 0;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	int offload_type;
> 
> @@ -3865,7 +3865,7 @@ static int s2io_xmit(struct sk_buff *skb
> 
>  	put_off = (u16)
mac_control->fifos[queue].tx_curr_put_info.offset;
>  	get_off = (u16)
mac_control->fifos[queue].tx_curr_get_info.offset;
> -	txdp = (TxD_t *) mac_control->fifos[queue].list_info[put_off].
> +	txdp = (struct TxD *)
mac_control->fifos[queue].list_info[put_off].
>  		list_virt_addr;
> 
>  	queue_len = mac_control->fifos[queue].tx_curr_put_info.fifo_len
+ 1;
> @@ -3994,13 +3994,13 @@ #endif
>  static void
>  s2io_alarm_handle(unsigned long data)
>  {
> -	nic_t *sp = (nic_t *)data;
> +	struct s2io_nic *sp = (struct s2io_nic *)data;
> 
>  	alarm_intr_handler(sp);
>  	mod_timer(&sp->alarm_timer, jiffies + HZ / 2);
>  }
> 
> -static int s2io_chk_rx_buffers(nic_t *sp, int rng_n)
> +static int s2io_chk_rx_buffers(struct s2io_nic *sp, int rng_n)
>  {
>  	int rxb_size, level;
> 
> @@ -4032,9 +4032,9 @@ static int s2io_chk_rx_buffers(nic_t *sp
>  static irqreturn_t s2io_msi_handle(int irq, void *dev_id)
>  {
>  	struct net_device *dev = (struct net_device *) dev_id;
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	int i;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	atomic_inc(&sp->isr_cnt);
> @@ -4064,8 +4064,8 @@ static irqreturn_t s2io_msi_handle(int i
> 
>  static irqreturn_t s2io_msix_ring_handle(int irq, void *dev_id)
>  {
> -	ring_info_t *ring = (ring_info_t *)dev_id;
> -	nic_t *sp = ring->nic;
> +	struct ring_info *ring = (struct ring_info *)dev_id;
> +	struct s2io_nic *sp = ring->nic;
> 
>  	atomic_inc(&sp->isr_cnt);
> 
> @@ -4078,17 +4078,17 @@ static irqreturn_t s2io_msix_ring_handle
> 
>  static irqreturn_t s2io_msix_fifo_handle(int irq, void *dev_id)
>  {
> -	fifo_info_t *fifo = (fifo_info_t *)dev_id;
> -	nic_t *sp = fifo->nic;
> +	struct fifo_info *fifo = (struct fifo_info *)dev_id;
> +	struct s2io_nic *sp = fifo->nic;
> 
>  	atomic_inc(&sp->isr_cnt);
>  	tx_intr_handler(fifo);
>  	atomic_dec(&sp->isr_cnt);
>  	return IRQ_HANDLED;
>  }
> -static void s2io_txpic_intr_handle(nic_t *sp)
> +static void s2io_txpic_intr_handle(struct s2io_nic *sp)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64;
> 
>  	val64 = readq(&bar0->pic_int_status);
> @@ -4164,11 +4164,11 @@ static void s2io_txpic_intr_handle(nic_t
>  static irqreturn_t s2io_isr(int irq, void *dev_id)
>  {
>  	struct net_device *dev = (struct net_device *) dev_id;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	int i;
>  	u64 reason = 0, val64, org_mask;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	atomic_inc(&sp->isr_cnt);
> @@ -4246,9 +4246,9 @@ #endif
>  /**
>   * s2io_updt_stats -
>   */
> -static void s2io_updt_stats(nic_t *sp)
> +static void s2io_updt_stats(struct s2io_nic *sp)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64;
>  	int cnt = 0;
> 
> @@ -4267,7 +4267,7 @@ static void s2io_updt_stats(nic_t *sp)
>  				break; /* Updt failed */
>  		} while(1);
>  	} else {
> -		memset(sp->mac_control.stats_info, 0,
sizeof(StatInfo_t));
> +		memset(sp->mac_control.stats_info, 0, sizeof(struct
> stat_block));
>  	}
>  }
> 
> @@ -4283,8 +4283,8 @@ static void s2io_updt_stats(nic_t *sp)
> 
>  static struct net_device_stats *s2io_get_stats(struct net_device
*dev)
>  {
> -	nic_t *sp = dev->priv;
> -	mac_info_t *mac_control;
> +	struct s2io_nic *sp = dev->priv;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
> 
> @@ -4325,8 +4325,8 @@ static void s2io_set_multicast(struct ne
>  {
>  	int i, j, prev_cnt;
>  	struct dev_mc_list *mclist;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64 = 0, multi_mac = 0x010203040506ULL, mask =
>  	    0xfeffffffffffULL;
>  	u64 dis_addr = 0xffffffffffffULL, mac_addr = 0;
> @@ -4479,8 +4479,8 @@ static void s2io_set_multicast(struct ne
> 
>  static int s2io_set_mac_addr(struct net_device *dev, u8 * addr)
>  {
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	register u64 val64, mac_addr = 0;
>  	int i;
> 
> @@ -4526,7 +4526,7 @@ static int s2io_set_mac_addr(struct net_
>  static int s2io_ethtool_sset(struct net_device *dev,
>  			     struct ethtool_cmd *info)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	if ((info->autoneg == AUTONEG_ENABLE) ||
>  	    (info->speed != SPEED_10000) || (info->duplex !=
DUPLEX_FULL))
>  		return -EINVAL;
> @@ -4552,7 +4552,7 @@ static int s2io_ethtool_sset(struct net_
> 
>  static int s2io_ethtool_gset(struct net_device *dev, struct
ethtool_cmd
> *info)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	info->supported = (SUPPORTED_10000baseT_Full | SUPPORTED_FIBRE);
>  	info->advertising = (SUPPORTED_10000baseT_Full |
SUPPORTED_FIBRE);
>  	info->port = PORT_FIBRE;
> @@ -4585,7 +4585,7 @@ static int s2io_ethtool_gset(struct net_
>  static void s2io_ethtool_gdrvinfo(struct net_device *dev,
>  				  struct ethtool_drvinfo *info)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	strncpy(info->driver, s2io_driver_name, sizeof(info->driver));
>  	strncpy(info->version, s2io_driver_version,
sizeof(info->version));
> @@ -4617,7 +4617,7 @@ static void s2io_ethtool_gregs(struct ne
>  	int i;
>  	u64 reg;
>  	u8 *reg_space = (u8 *) space;
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	regs->len = XENA_REG_SPACE;
>  	regs->version = sp->pdev->subsystem_device;
> @@ -4639,8 +4639,8 @@ static void s2io_ethtool_gregs(struct ne
>  */
>  static void s2io_phy_id(unsigned long data)
>  {
> -	nic_t *sp = (nic_t *) data;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = (struct s2io_nic *) data;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64 = 0;
>  	u16 subid;
> 
> @@ -4677,8 +4677,8 @@ static void s2io_phy_id(unsigned long da
>  static int s2io_ethtool_idnic(struct net_device *dev, u32 data)
>  {
>  	u64 val64 = 0, last_gpio_ctrl_val;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u16 subid;
> 
>  	subid = sp->pdev->subsystem_device;
> @@ -4726,8 +4726,8 @@ static void s2io_ethtool_getpause_data(s
>  				       struct ethtool_pauseparam *ep)
>  {
>  	u64 val64;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> 
>  	val64 = readq(&bar0->rmac_pause_cfg);
>  	if (val64 & RMAC_PAUSE_GEN_ENABLE)
> @@ -4753,8 +4753,8 @@ static int s2io_ethtool_setpause_data(st
>  			       struct ethtool_pauseparam *ep)
>  {
>  	u64 val64;
> -	nic_t *sp = dev->priv;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct s2io_nic *sp = dev->priv;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> 
>  	val64 = readq(&bar0->rmac_pause_cfg);
>  	if (ep->tx_pause)
> @@ -4786,12 +4786,12 @@ static int s2io_ethtool_setpause_data(st
>   */
> 
>  #define S2IO_DEV_ID		5
> -static int read_eeprom(nic_t * sp, int off, u64 * data)
> +static int read_eeprom(struct s2io_nic * sp, int off, u64 * data)
>  {
>  	int ret = -1;
>  	u32 exit_cnt = 0;
>  	u64 val64;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> 
>  	if (sp->device_type == XFRAME_I_DEVICE) {
>  		val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) |
> I2C_CONTROL_ADDR(off) |
> @@ -4851,11 +4851,11 @@ static int read_eeprom(nic_t * sp, int o
>   *  0 on success, -1 on failure.
>   */
> 
> -static int write_eeprom(nic_t * sp, int off, u64 data, int cnt)
> +static int write_eeprom(struct s2io_nic * sp, int off, u64 data, int
cnt)
>  {
>  	int exit_cnt = 0, ret = -1;
>  	u64 val64;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
> 
>  	if (sp->device_type == XFRAME_I_DEVICE) {
>  		val64 = I2C_CONTROL_DEV_ID(S2IO_DEV_ID) |
> I2C_CONTROL_ADDR(off) |
> @@ -4900,7 +4900,7 @@ static int write_eeprom(nic_t * sp, int
>  	}
>  	return ret;
>  }
> -static void s2io_vpd_read(nic_t *nic)
> +static void s2io_vpd_read(struct s2io_nic *nic)
>  {
>  	u8 *vpd_data;
>  	u8 data;
> @@ -4963,7 +4963,7 @@ static int s2io_ethtool_geeprom(struct n
>  {
>  	u32 i, valid;
>  	u64 data;
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	eeprom->magic = sp->pdev->vendor | (sp->pdev->device << 16);
> 
> @@ -5001,7 +5001,7 @@ static int s2io_ethtool_seeprom(struct n
>  {
>  	int len = eeprom->len, cnt = 0;
>  	u64 valid = 0, data;
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	if (eeprom->magic != (sp->pdev->vendor | (sp->pdev->device <<
16)))
> {
>  		DBG_PRINT(ERR_DBG,
> @@ -5045,9 +5045,9 @@ static int s2io_ethtool_seeprom(struct n
>   * 0 on success.
>   */
> 
> -static int s2io_register_test(nic_t * sp, uint64_t * data)
> +static int s2io_register_test(struct s2io_nic * sp, uint64_t * data)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64 = 0, exp_val;
>  	int fail = 0;
> 
> @@ -5112,7 +5112,7 @@ static int s2io_register_test(nic_t * sp
>   * 0 on success.
>   */
> 
> -static int s2io_eeprom_test(nic_t * sp, uint64_t * data)
> +static int s2io_eeprom_test(struct s2io_nic * sp, uint64_t * data)
>  {
>  	int fail = 0;
>  	u64 ret_data, org_4F0, org_7F0;
> @@ -5214,7 +5214,7 @@ static int s2io_eeprom_test(nic_t * sp,
>   * 0 on success and -1 on failure.
>   */
> 
> -static int s2io_bist_test(nic_t * sp, uint64_t * data)
> +static int s2io_bist_test(struct s2io_nic * sp, uint64_t * data)
>  {
>  	u8 bist = 0;
>  	int cnt = 0, ret = -1;
> @@ -5250,9 +5250,9 @@ static int s2io_bist_test(nic_t * sp, ui
>   * 0 on success.
>   */
> 
> -static int s2io_link_test(nic_t * sp, uint64_t * data)
> +static int s2io_link_test(struct s2io_nic * sp, uint64_t * data)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64;
> 
>  	val64 = readq(&bar0->adapter_status);
> @@ -5277,9 +5277,9 @@ static int s2io_link_test(nic_t * sp, ui
>   *  0 on success.
>   */
> 
> -static int s2io_rldram_test(nic_t * sp, uint64_t * data)
> +static int s2io_rldram_test(struct s2io_nic * sp, uint64_t * data)
>  {
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	u64 val64;
>  	int cnt, iteration = 0, test_fail = 0;
> 
> @@ -5381,7 +5381,7 @@ static void s2io_ethtool_test(struct net
>  			      struct ethtool_test *ethtest,
>  			      uint64_t * data)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	int orig_state = netif_running(sp->dev);
> 
>  	if (ethtest->flags == ETH_TEST_FL_OFFLINE) {
> @@ -5437,8 +5437,8 @@ static void s2io_get_ethtool_stats(struc
>  				   u64 * tmp_stats)
>  {
>  	int i = 0;
> -	nic_t *sp = dev->priv;
> -	StatInfo_t *stat_info = sp->mac_control.stats_info;
> +	struct s2io_nic *sp = dev->priv;
> +	struct stat_block *stat_info = sp->mac_control.stats_info;
> 
>  	s2io_updt_stats(sp);
>  	tmp_stats[i++] =
> @@ -5665,14 +5665,14 @@ static int s2io_ethtool_get_regs_len(str
> 
>  static u32 s2io_ethtool_get_rx_csum(struct net_device * dev)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	return (sp->rx_csum);
>  }
> 
>  static int s2io_ethtool_set_rx_csum(struct net_device *dev, u32 data)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	if (data)
>  		sp->rx_csum = 1;
> @@ -5795,7 +5795,7 @@ static int s2io_ioctl(struct net_device
> 
>  static int s2io_change_mtu(struct net_device *dev, int new_mtu)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	if ((new_mtu < MIN_MTU) || (new_mtu > S2IO_JUMBO_SIZE)) {
>  		DBG_PRINT(ERR_DBG, "%s: MTU size is invalid.\n",
> @@ -5814,7 +5814,7 @@ static int s2io_change_mtu(struct net_de
>  		if (netif_queue_stopped(dev))
>  			netif_wake_queue(dev);
>  	} else { /* Device is down */
> -		XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +		struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  		u64 val64 = new_mtu;
> 
>  		writeq(vBIT(val64, 2, 14), &bar0->rmac_max_pyld_len);
> @@ -5839,9 +5839,9 @@ static int s2io_change_mtu(struct net_de
>  static void s2io_tasklet(unsigned long dev_addr)
>  {
>  	struct net_device *dev = (struct net_device *) dev_addr;
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
>  	int i, ret;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
> 
>  	mac_control = &sp->mac_control;
> @@ -5874,9 +5874,9 @@ static void s2io_tasklet(unsigned long d
> 
>  static void s2io_set_link(struct work_struct *work)
>  {
> -	nic_t *nic = container_of(work, nic_t, set_link_task);
> +	struct s2io_nic *nic = container_of(work, struct s2io_nic,
> set_link_task);
>  	struct net_device *dev = nic->dev;
> -	XENA_dev_config_t __iomem *bar0 = nic->bar0;
> +	struct XENA_dev_config __iomem *bar0 = nic->bar0;
>  	register u64 val64;
>  	u16 subid;
> 
> @@ -5943,7 +5943,7 @@ static void s2io_set_link(struct work_st
>  	clear_bit(0, &(nic->link_state));
>  }
> 
> -static int set_rxd_buffer_pointer(nic_t *sp, RxD_t *rxdp, buffAdd_t
*ba,
> +static int set_rxd_buffer_pointer(struct s2io_nic *sp, struct RxD_t
> *rxdp, struct bufAdd *ba,
>  			   struct sk_buff **skb, u64 *temp0, u64 *temp1,
>  			   u64 *temp2, int size)
>  {
> @@ -5959,7 +5959,7 @@ static int set_rxd_buffer_pointer(nic_t
>  			 * using same mapped address for the Rxd
>  			 * buffer pointer
>  			 */
> -			((RxD1_t*)rxdp)->Buffer0_ptr = *temp0;
> +			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0;
>  		} else {
>  			*skb = dev_alloc_skb(size);
>  			if (!(*skb)) {
> @@ -5971,7 +5971,7 @@ static int set_rxd_buffer_pointer(nic_t
>  			 * such it will be used for next rxd whose
>  			 * Host Control is NULL
>  			 */
> -			((RxD1_t*)rxdp)->Buffer0_ptr = *temp0 =
> +			((struct RxD1*)rxdp)->Buffer0_ptr = *temp0 =
>  				pci_map_single( sp->pdev, (*skb)->data,
>  					size - NET_IP_ALIGN,
>  					PCI_DMA_FROMDEVICE);
> @@ -5980,9 +5980,9 @@ static int set_rxd_buffer_pointer(nic_t
>  	} else if ((sp->rxd_mode == RXD_MODE_3B) && (rxdp->Host_Control
==
> 0)) {
>  		/* Two buffer Mode */
>  		if (*skb) {
> -			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2;
> -			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0;
> -			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1;
> +			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
> +			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
> +			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
>  		} else {
>  			*skb = dev_alloc_skb(size);
>  			if (!(*skb)) {
> @@ -5990,26 +5990,26 @@ static int set_rxd_buffer_pointer(nic_t
>  					  dev->name);
>  				return -ENOMEM;
>  			}
> -			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2 =
> +			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
>  				pci_map_single(sp->pdev, (*skb)->data,
>  					       dev->mtu + 4,
>  					       PCI_DMA_FROMDEVICE);
> -			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0 =
> +			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
>  				pci_map_single( sp->pdev, ba->ba_0,
BUF0_LEN,
>  						PCI_DMA_FROMDEVICE);
>  			rxdp->Host_Control = (unsigned long) (*skb);
> 
>  			/* Buffer-1 will be dummy buffer not used */
> -			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1 =
> +			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
>  				pci_map_single(sp->pdev, ba->ba_1,
BUF1_LEN,
>  					       PCI_DMA_FROMDEVICE);
>  		}
>  	} else if ((rxdp->Host_Control == 0)) {
>  		/* Three buffer mode */
>  		if (*skb) {
> -			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0;
> -			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1;
> -			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2;
> +			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0;
> +			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1;
> +			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2;
>  		} else {
>  			*skb = dev_alloc_skb(size);
>  			if (!(*skb)) {
> @@ -6017,11 +6017,11 @@ static int set_rxd_buffer_pointer(nic_t
>  					  dev->name);
>  				return -ENOMEM;
>  			}
> -			((RxD3_t*)rxdp)->Buffer0_ptr = *temp0 =
> +			((struct RxD3*)rxdp)->Buffer0_ptr = *temp0 =
>  				pci_map_single(sp->pdev, ba->ba_0,
BUF0_LEN,
>  					       PCI_DMA_FROMDEVICE);
>  			/* Buffer-1 receives L3/L4 headers */
> -			((RxD3_t*)rxdp)->Buffer1_ptr = *temp1 =
> +			((struct RxD3*)rxdp)->Buffer1_ptr = *temp1 =
>  				pci_map_single( sp->pdev, (*skb)->data,
>  						l3l4hdr_size + 4,
>  						PCI_DMA_FROMDEVICE);
> @@ -6041,14 +6041,14 @@ static int set_rxd_buffer_pointer(nic_t
>  			/*
>  			 * Buffer-2 receives L4 data payload
>  			 */
> -			((RxD3_t*)rxdp)->Buffer2_ptr = *temp2 =
> +			((struct RxD3*)rxdp)->Buffer2_ptr = *temp2 =
>  				pci_map_single( sp->pdev,
frag_list->data,
>  						dev->mtu,
PCI_DMA_FROMDEVICE);
>  		}
>  	}
>  	return 0;
>  }
> -static void set_rxd_buffer_size(nic_t *sp, RxD_t *rxdp, int size)
> +static void set_rxd_buffer_size(struct s2io_nic *sp, struct RxD_t
*rxdp,
> int size)
>  {
>  	struct net_device *dev = sp->dev;
>  	if (sp->rxd_mode == RXD_MODE_1) {
> @@ -6064,15 +6064,15 @@ static void set_rxd_buffer_size(nic_t *s
>  	}
>  }
> 
> -static  int rxd_owner_bit_reset(nic_t *sp)
> +static  int rxd_owner_bit_reset(struct s2io_nic *sp)
>  {
>  	int i, j, k, blk_cnt = 0, size;
> -	mac_info_t * mac_control = &sp->mac_control;
> +	struct mac_info * mac_control = &sp->mac_control;
>  	struct config_param *config = &sp->config;
>  	struct net_device *dev = sp->dev;
> -	RxD_t *rxdp = NULL;
> +	struct RxD_t *rxdp = NULL;
>  	struct sk_buff *skb = NULL;
> -	buffAdd_t *ba = NULL;
> +	struct bufAdd *ba = NULL;
>  	u64 temp0_64 = 0, temp1_64 = 0, temp2_64 = 0;
> 
>  	/* Calculate the size based on ring mode */
> @@ -6111,7 +6111,7 @@ static  int rxd_owner_bit_reset(nic_t *s
> 
>  }
> 
> -static int s2io_add_isr(nic_t * sp)
> +static int s2io_add_isr(struct s2io_nic * sp)
>  {
>  	int ret = 0;
>  	struct net_device *dev = sp->dev;
> @@ -6126,7 +6126,7 @@ static int s2io_add_isr(nic_t * sp)
>  		sp->intr_type = INTA;
>  	}
> 
> -	/* Store the values of the MSIX table in the nic_t structure */
> +	/* Store the values of the MSIX table in the struct s2io_nic
> structure */
>  	store_xmsi_data(sp);
> 
>  	/* After proper initialization of H/W, register ISR */
> @@ -6181,7 +6181,7 @@ static int s2io_add_isr(nic_t * sp)
>  	}
>  	return 0;
>  }
> -static void s2io_rem_isr(nic_t * sp)
> +static void s2io_rem_isr(struct s2io_nic * sp)
>  {
>  	int cnt = 0;
>  	struct net_device *dev = sp->dev;
> @@ -6223,10 +6223,10 @@ static void s2io_rem_isr(nic_t * sp)
>  	} while(cnt < 5);
>  }
> 
> -static void s2io_card_down(nic_t * sp)
> +static void s2io_card_down(struct s2io_nic * sp)
>  {
>  	int cnt = 0;
> -	XENA_dev_config_t __iomem *bar0 = sp->bar0;
> +	struct XENA_dev_config __iomem *bar0 = sp->bar0;
>  	unsigned long flags;
>  	register u64 val64 = 0;
> 
> @@ -6286,10 +6286,10 @@ static void s2io_card_down(nic_t * sp)
>  	clear_bit(0, &(sp->link_state));
>  }
> 
> -static int s2io_card_up(nic_t * sp)
> +static int s2io_card_up(struct s2io_nic * sp)
>  {
>  	int i, ret = 0;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	struct net_device *dev = (struct net_device *) sp->dev;
>  	u16 interruptible;
> @@ -6381,7 +6381,7 @@ static int s2io_card_up(nic_t * sp)
> 
>  static void s2io_restart_nic(struct work_struct *work)
>  {
> -	nic_t *sp = container_of(work, nic_t, rst_timer_task);
> +	struct s2io_nic *sp = container_of(work, struct s2io_nic,
> rst_timer_task);
>  	struct net_device *dev = sp->dev;
> 
>  	s2io_card_down(sp);
> @@ -6410,7 +6410,7 @@ static void s2io_restart_nic(struct work
> 
>  static void s2io_tx_watchdog(struct net_device *dev)
>  {
> -	nic_t *sp = dev->priv;
> +	struct s2io_nic *sp = dev->priv;
> 
>  	if (netif_carrier_ok(dev)) {
>  		schedule_work(&sp->rst_timer_task);
> @@ -6435,16 +6435,16 @@ static void s2io_tx_watchdog(struct net_
>   *   Return value:
>   *   SUCCESS on success and -1 on failure.
>   */
> -static int rx_osm_handler(ring_info_t *ring_data, RxD_t * rxdp)
> +static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t *
> rxdp)
>  {
> -	nic_t *sp = ring_data->nic;
> +	struct s2io_nic *sp = ring_data->nic;
>  	struct net_device *dev = (struct net_device *) sp->dev;
>  	struct sk_buff *skb = (struct sk_buff *)
>  		((unsigned long) rxdp->Host_Control);
>  	int ring_no = ring_data->ring_no;
>  	u16 l3_csum, l4_csum;
>  	unsigned long long err = rxdp->Control_1 & RXD_T_CODE;
> -	lro_t *lro;
> +	struct lro *lro;
> 
>  	skb->dev = dev;
> 
> @@ -6489,7 +6489,7 @@ static int rx_osm_handler(ring_info_t *r
>  		int buf2_len = RXD_GET_BUFFER2_SIZE_3(rxdp->Control_2);
>  		unsigned char *buff = skb_push(skb, buf0_len);
> 
> -		buffAdd_t *ba = &ring_data->ba[get_block][get_off];
> +		struct bufAdd *ba = &ring_data->ba[get_block][get_off];
>  		sp->stats.rx_bytes += buf0_len + buf2_len;
>  		memcpy(buff, ba->ba_0, buf0_len);
> 
> @@ -6623,7 +6623,7 @@ aggregate:
>   *  void.
>   */
> 
> -static void s2io_link(nic_t * sp, int link)
> +static void s2io_link(struct s2io_nic * sp, int link)
>  {
>  	struct net_device *dev = (struct net_device *) sp->dev;
> 
> @@ -6667,7 +6667,7 @@ static int get_xena_rev_id(struct pci_de
>   *  void
>   */
> 
> -static void s2io_init_pci(nic_t * sp)
> +static void s2io_init_pci(struct s2io_nic * sp)
>  {
>  	u16 pci_cmd = 0, pcix_cmd = 0;
> 
> @@ -6752,15 +6752,15 @@ #endif
>  static int __devinit
>  s2io_init_nic(struct pci_dev *pdev, const struct pci_device_id *pre)
>  {
> -	nic_t *sp;
> +	struct s2io_nic *sp;
>  	struct net_device *dev;
>  	int i, j, ret;
>  	int dma_flag = FALSE;
>  	u32 mac_up, mac_down;
>  	u64 val64 = 0, tmp64 = 0;
> -	XENA_dev_config_t __iomem *bar0 = NULL;
> +	struct XENA_dev_config __iomem *bar0 = NULL;
>  	u16 subid;
> -	mac_info_t *mac_control;
> +	struct mac_info *mac_control;
>  	struct config_param *config;
>  	int mode;
>  	u8 dev_intr_type = intr_type;
> @@ -6815,7 +6815,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
>  		}
>  	}
> 
> -	dev = alloc_etherdev(sizeof(nic_t));
> +	dev = alloc_etherdev(sizeof(struct s2io_nic));
>  	if (dev == NULL) {
>  		DBG_PRINT(ERR_DBG, "Device allocation failed\n");
>  		pci_disable_device(pdev);
> @@ -6830,7 +6830,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
> 
>  	/*  Private member variable initialized to s2io NIC structure */
>  	sp = dev->priv;
> -	memset(sp, 0, sizeof(nic_t));
> +	memset(sp, 0, sizeof(struct s2io_nic));
>  	sp->dev = dev;
>  	sp->pdev = pdev;
>  	sp->high_dma_flag = dma_flag;
> @@ -6946,7 +6946,7 @@ s2io_init_nic(struct pci_dev *pdev, cons
> 
>  	/* Initializing the BAR1 address as the start of the FIFO
pointer.
> */
>  	for (j = 0; j < MAX_TX_FIFOS; j++) {
> -		mac_control->tx_FIFO_start[j] = (TxFIFO_element_t
__iomem *)
> +		mac_control->tx_FIFO_start[j] = (struct TxFIFO_element
__iomem
> *)
>  		    (sp->bar1 + (j * 0x00020000));
>  	}
> 
> @@ -7203,7 +7203,7 @@ static void __devexit s2io_rem_nic(struc
>  {
>  	struct net_device *dev =
>  	    (struct net_device *) pci_get_drvdata(pdev);
> -	nic_t *sp;
> +	struct s2io_nic *sp;
> 
>  	if (dev == NULL) {
>  		DBG_PRINT(ERR_DBG, "Driver Data is NULL!!\n");
> @@ -7255,7 +7255,7 @@ module_init(s2io_starter);
>  module_exit(s2io_closer);
> 
>  static int check_L2_lro_capable(u8 *buffer, struct iphdr **ip,
> -		struct tcphdr **tcp, RxD_t *rxdp)
> +		struct tcphdr **tcp, struct RxD_t *rxdp)
>  {
>  	int ip_off;
>  	u8 l2_type = (u8)((rxdp->Control_1 >> 37) & 0x7), ip_len;
> @@ -7289,7 +7289,7 @@ static int check_L2_lro_capable(u8 *buff
>  	return 0;
>  }
> 
> -static int check_for_socket_match(lro_t *lro, struct iphdr *ip,
> +static int check_for_socket_match(struct lro *lro, struct iphdr *ip,
>  				  struct tcphdr *tcp)
>  {
>  	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
> @@ -7304,7 +7304,7 @@ static inline int get_l4_pyld_length(str
>  	return(ntohs(ip->tot_len) - (ip->ihl << 2) - (tcp->doff << 2));
>  }
> 
> -static void initiate_new_session(lro_t *lro, u8 *l2h,
> +static void initiate_new_session(struct lro *lro, u8 *l2h,
>  		     struct iphdr *ip, struct tcphdr *tcp, u32
tcp_pyld_len)
>  {
>  	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
> @@ -7330,12 +7330,12 @@ static void initiate_new_session(lro_t *
>  	lro->in_use = 1;
>  }
> 
> -static void update_L3L4_header(nic_t *sp, lro_t *lro)
> +static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro)
>  {
>  	struct iphdr *ip = lro->iph;
>  	struct tcphdr *tcp = lro->tcph;
>  	u16 nchk;
> -	StatInfo_t *statinfo = sp->mac_control.stats_info;
> +	struct stat_block *statinfo = sp->mac_control.stats_info;
>  	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
> 
>  	/* Update L3 header */
> @@ -7361,7 +7361,7 @@ static void update_L3L4_header(nic_t *sp
>  	statinfo->sw_stat.num_aggregations++;
>  }
> 
> -static void aggregate_new_rx(lro_t *lro, struct iphdr *ip,
> +static void aggregate_new_rx(struct lro *lro, struct iphdr *ip,
>  		struct tcphdr *tcp, u32 l4_pyld)
>  {
>  	DBG_PRINT(INFO_DBG,"%s: Been here...\n", __FUNCTION__);
> @@ -7383,7 +7383,7 @@ static void aggregate_new_rx(lro_t *lro,
>  	}
>  }
> 
> -static int verify_l3_l4_lro_capable(lro_t *l_lro, struct iphdr *ip,
> +static int verify_l3_l4_lro_capable(struct lro *l_lro, struct iphdr
*ip,
>  				    struct tcphdr *tcp, u32
tcp_pyld_len)
>  {
>  	u8 *ptr;
> @@ -7441,8 +7441,8 @@ static int verify_l3_l4_lro_capable(lro_
>  }
> 
>  static int
> -s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, lro_t
**lro,
> -		      RxD_t *rxdp, nic_t *sp)
> +s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len, struct lro
> **lro,
> +		      struct RxD_t *rxdp, struct s2io_nic *sp)
>  {
>  	struct iphdr *ip;
>  	struct tcphdr *tcph;
> @@ -7459,7 +7459,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
>  	tcph = (struct tcphdr *)*tcp;
>  	*tcp_len = get_l4_pyld_length(ip, tcph);
>  	for (i=0; i<MAX_LRO_SESSIONS; i++) {
> -		lro_t *l_lro = &sp->lro0_n[i];
> +		struct lro *l_lro = &sp->lro0_n[i];
>  		if (l_lro->in_use) {
>  			if (check_for_socket_match(l_lro, ip, tcph))
>  				continue;
> @@ -7497,7 +7497,7 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
>  		}
> 
>  		for (i=0; i<MAX_LRO_SESSIONS; i++) {
> -			lro_t *l_lro = &sp->lro0_n[i];
> +			struct lro *l_lro = &sp->lro0_n[i];
>  			if (!(l_lro->in_use)) {
>  				*lro = l_lro;
>  				ret = 3; /* Begin anew */
> @@ -7536,9 +7536,9 @@ s2io_club_tcp_session(u8 *buffer, u8 **t
>  	return ret;
>  }
> 
> -static void clear_lro_session(lro_t *lro)
> +static void clear_lro_session(struct lro *lro)
>  {
> -	static u16 lro_struct_size = sizeof(lro_t);
> +	static u16 lro_struct_size = sizeof(struct lro);
> 
>  	memset(lro, 0, lro_struct_size);
>  }
> @@ -7555,7 +7555,7 @@ #else
>  #endif
>  }
> 
> -static void lro_append_pkt(nic_t *sp, lro_t *lro, struct sk_buff
*skb,
> +static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
struct
> sk_buff *skb,
>  			   u32 tcp_len)
>  {
>  	struct sk_buff *first = lro->parent;
> diff --git a/drivers/net/s2io.h b/drivers/net/s2io.h
> index 3b0bafd..1729a11 100644
> --- a/drivers/net/s2io.h
> +++ b/drivers/net/s2io.h
> @@ -37,7 +37,7 @@ #define CHECKBIT(value, nbit) (value & (
>  #define MAX_FLICKER_TIME	60000 /* 60 Secs */
> 
>  /* Maximum outstanding splits to be configured into xena. */
> -typedef enum xena_max_outstanding_splits {
> +enum {
>  	XENA_ONE_SPLIT_TRANSACTION = 0,
>  	XENA_TWO_SPLIT_TRANSACTION = 1,
>  	XENA_THREE_SPLIT_TRANSACTION = 2,
> @@ -46,7 +46,7 @@ typedef enum xena_max_outstanding_splits
>  	XENA_TWELVE_SPLIT_TRANSACTION = 5,
>  	XENA_SIXTEEN_SPLIT_TRANSACTION = 6,
>  	XENA_THIRTYTWO_SPLIT_TRANSACTION = 7
> -} xena_max_outstanding_splits;
> +};
>  #define XENA_MAX_OUTSTANDING_SPLITS(n) (n << 4)
> 
>  /*  OS concerned variables and constants */
> @@ -77,7 +77,7 @@ #define L4_CKSUM_OK 0xFFFF
>  #define S2IO_JUMBO_SIZE 9600
> 
>  /* Driver statistics maintained by driver */
> -typedef struct {
> +struct swStat {
>  	unsigned long long single_ecc_errs;
>  	unsigned long long double_ecc_errs;
>  	unsigned long long parity_err_cnt;
> @@ -92,10 +92,10 @@ typedef struct {
>  	unsigned long long flush_max_pkts;
>  	unsigned long long sum_avg_pkts_aggregated;
>  	unsigned long long num_aggregations;
> -} swStat_t;
> +};
> 
>  /* Xpak releated alarm and warnings */
> -typedef struct {
> +struct xpakStat {
>  	u64 alarm_transceiver_temp_high;
>  	u64 alarm_transceiver_temp_low;
>  	u64 alarm_laser_bias_current_high;
> @@ -110,11 +110,11 @@ typedef struct {
>  	u64 warn_laser_output_power_low;
>  	u64 xpak_regs_stat;
>  	u32 xpak_timer_count;
> -} xpakStat_t;
> +};
> 
> 
>  /* The statistics block of Xena */
> -typedef struct stat_block {
> +struct stat_block {
>  /* Tx MAC statistics counters. */
>  	__le32 tmac_data_octets;
>  	__le32 tmac_frms;
> @@ -290,9 +290,9 @@ typedef struct stat_block {
>  	__le32 reserved_14;
>  	__le32 link_fault_cnt;
>  	u8  buffer[20];
> -	swStat_t sw_stat;
> -	xpakStat_t xpak_stat;
> -} StatInfo_t;
> +	struct swStat sw_stat;
> +	struct xpakStat xpak_stat;
> +};
> 
>  /*
>   * Structures representing different init time configuration
> @@ -315,7 +315,7 @@ static int fifo_map[][MAX_TX_FIFOS] = {
>  };
> 
>  /* Maintains Per FIFO related information. */
> -typedef struct tx_fifo_config {
> +struct tx_fifo_config {
>  #define	MAX_AVAILABLE_TXDS	8192
>  	u32 fifo_len;		/* specifies len of FIFO upto 8192, ie
no of
> TxDLs */
>  /* Priority definition */
> @@ -332,11 +332,11 @@ #define TX_FIFO_PRI_7               7	/*
>  	u8 f_no_snoop;
>  #define NO_SNOOP_TXD                0x01
>  #define NO_SNOOP_TXD_BUFFER          0x02
> -} tx_fifo_config_t;
> +};
> 
> 
>  /* Maintains per Ring related information */
> -typedef struct rx_ring_config {
> +struct rx_ring_config {
>  	u32 num_rxd;		/*No of RxDs per Rx Ring */
>  #define RX_RING_PRI_0               0	/* highest */
>  #define RX_RING_PRI_1               1
> @@ -357,7 +357,7 @@ #define RX_RING_ORG_BUFF5	0x05
>  	u8 f_no_snoop;
>  #define NO_SNOOP_RXD                0x01
>  #define NO_SNOOP_RXD_BUFFER         0x02
> -} rx_ring_config_t;
> +};
> 
>  /* This structure provides contains values of the tunable parameters
>   * of the H/W
> @@ -367,7 +367,7 @@ struct config_param {
>  	u32 tx_fifo_num;	/*Number of Tx FIFOs */
> 
>  	u8 fifo_mapping[MAX_TX_FIFOS];
> -	tx_fifo_config_t tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO config */
> +	struct tx_fifo_config tx_cfg[MAX_TX_FIFOS];	/*Per-Tx FIFO
config
> */
>  	u32 max_txds;		/*Max no. of Tx buffer descriptor per
TxDL
> */
>  	u64 tx_intr_type;
>  	/* Specifies if Tx Intr is UTILZ or PER_LIST type. */
> @@ -376,7 +376,7 @@ struct config_param {
>  	u32 rx_ring_num;	/*Number of receive rings */
>  #define MAX_RX_BLOCKS_PER_RING  150
> 
> -	rx_ring_config_t rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring config */
> +	struct rx_ring_config rx_cfg[MAX_RX_RINGS];	/*Per-Rx Ring
config
> */
>  	u8 bimodal;		/*Flag for setting bimodal interrupts*/
> 
>  #define HEADER_ETHERNET_II_802_3_SIZE 14
> @@ -395,14 +395,14 @@ #define MAX_MTU_JUMBO_VLAN          (MAX
>  };
> 
>  /* Structure representing MAC Addrs */
> -typedef struct mac_addr {
> +struct mac_addr {
>  	u8 mac_addr[ETH_ALEN];
> -} macaddr_t;
> +};
> 
>  /* Structure that represent every FIFO element in the BAR1
>   * Address location.
>   */
> -typedef struct _TxFIFO_element {
> +struct TxFIFO_element {
>  	u64 TxDL_Pointer;
> 
>  	u64 List_Control;
> @@ -413,10 +413,10 @@ #define TX_FIFO_FIRSTNLAST_LIST        v
>  #define TX_FIFO_SPECIAL_FUNC           BIT(23)
>  #define TX_FIFO_DS_NO_SNOOP            BIT(31)
>  #define TX_FIFO_BUFF_NO_SNOOP          BIT(30)
> -} TxFIFO_element_t;
> +};
> 
>  /* Tx descriptor structure */
> -typedef struct _TxD {
> +struct TxD {
>  	u64 Control_1;
>  /* bit mask */
>  #define TXD_LIST_OWN_XENA       BIT(7)
> @@ -447,16 +447,16 @@ #define TXD_SET_MARKER         vBIT(0x6,
> 
>  	u64 Buffer_Pointer;
>  	u64 Host_Control;	/* reserved for host */
> -} TxD_t;
> +};
> 
>  /* Structure to hold the phy and virt addr of every TxDL. */
> -typedef struct list_info_hold {
> +struct list_info_hold {
>  	dma_addr_t list_phy_addr;
>  	void *list_virt_addr;
> -} list_info_hold_t;
> +};
> 
>  /* Rx descriptor structure for 1 buffer mode */
> -typedef struct _RxD_t {
> +struct RxD_t {
>  	u64 Host_Control;	/* reserved for host */
>  	u64 Control_1;
>  #define RXD_OWN_XENA            BIT(7)
> @@ -479,23 +479,22 @@ #define	GET_RXD_MARKER(ctrl)	((ctrl & SE
>  #define MASK_VLAN_TAG           vBIT(0xFFFF,48,16)
>  #define SET_VLAN_TAG(val)       vBIT(val,48,16)
>  #define SET_NUM_TAG(val)       vBIT(val,16,32)
> +};
> 
> -
> -} RxD_t;
>  /* Rx descriptor structure for 1 buffer mode */
> -typedef struct _RxD1_t {
> -	struct _RxD_t h;
> +struct RxD1 {
> +	struct RxD_t h;
> 
>  #define MASK_BUFFER0_SIZE_1       vBIT(0x3FFF,2,14)
>  #define SET_BUFFER0_SIZE_1(val)   vBIT(val,2,14)
>  #define RXD_GET_BUFFER0_SIZE_1(_Control_2) \
>  	(u16)((_Control_2 & MASK_BUFFER0_SIZE_1) >> 48)
>  	u64 Buffer0_ptr;
> -} RxD1_t;
> -/* Rx descriptor structure for 3 or 2 buffer mode */
> +};
> 
> -typedef struct _RxD3_t {
> -	struct _RxD_t h;
> +/* Rx descriptor structure for 3 or 2 buffer mode */
> +struct RxD3 {
> +	struct RxD_t h;
> 
>  #define MASK_BUFFER0_SIZE_3       vBIT(0xFF,2,14)
>  #define MASK_BUFFER1_SIZE_3       vBIT(0xFFFF,16,16)
> @@ -515,15 +514,15 @@ #define BUF1_LEN	1
>  	u64 Buffer0_ptr;
>  	u64 Buffer1_ptr;
>  	u64 Buffer2_ptr;
> -} RxD3_t;
> +};
> 
> 
>  /* Structure that represents the Rx descriptor block which contains
>   * 128 Rx descriptors.
>   */
> -typedef struct _RxD_block {
> +struct RxD_block {
>  #define MAX_RXDS_PER_BLOCK_1            127
> -	RxD1_t rxd[MAX_RXDS_PER_BLOCK_1];
> +	struct RxD1 rxd[MAX_RXDS_PER_BLOCK_1];
> 
>  	u64 reserved_0;
>  #define END_OF_BLOCK    0xFEFFFFFFFFFFFFFFULL
> @@ -533,7 +532,7 @@ #define END_OF_BLOCK    0xFEFFFFFFFFFFFF
>  	u64 pNext_RxD_Blk_physical;	/* Buff0_ptr.In a 32 bit arch
>  					 * the upper 32 bits should
>  					 * be 0 */
> -} RxD_block_t;
> +};
> 
>  #define SIZE_OF_BLOCK	4096
> 
> @@ -541,14 +540,13 @@ #define RXD_MODE_1	0
>  #define RXD_MODE_3A	1
>  #define RXD_MODE_3B	2
> 
> -/* Structure to hold virtual addresses of Buf0 and Buf1 in
> - * 2buf mode. */
> -typedef struct bufAdd {
> +/* Structure to hold virtual addresses of Buf0 and Buf1 in 2buf mode.
*/
> +struct bufAdd {
>  	void *ba_0_org;
>  	void *ba_1_org;
>  	void *ba_0;
>  	void *ba_1;
> -} buffAdd_t;
> +};
> 
>  /* Structure which stores all the MAC control parameters */
> 
> @@ -556,43 +554,46 @@ typedef struct bufAdd {
>   * from which the Rx Interrupt processor can start picking
>   * up the RxDs for processing.
>   */
> -typedef struct _rx_curr_get_info_t {
> +struct rx_curr_get_info {
>  	u32 block_index;
>  	u32 offset;
>  	u32 ring_len;
> -} rx_curr_get_info_t;
> +};
> 
> -typedef rx_curr_get_info_t rx_curr_put_info_t;
> +struct rx_curr_put_info {
> +	u32 block_index;
> +	u32 offset;
> +	u32 ring_len;
> +};
> 
>  /* This structure stores the offset of the TxDl in the FIFO
>   * from which the Tx Interrupt processor can start picking
>   * up the TxDLs for send complete interrupt processing.
>   */
> -typedef struct {
> +struct tx_curr_get_info {
>  	u32 offset;
>  	u32 fifo_len;
> -} tx_curr_get_info_t;
> -
> -typedef tx_curr_get_info_t tx_curr_put_info_t;
> +};
> 
> +struct tx_curr_put_info {
> +	u32 offset;
> +	u32 fifo_len;
> +};
> 
> -typedef struct rxd_info {
> +struct rxd_info {
>  	void *virt_addr;
>  	dma_addr_t dma_addr;
> -}rxd_info_t;
> +};
> 
>  /* Structure that holds the Phy and virt addresses of the Blocks */
> -typedef struct rx_block_info {
> +struct rx_block_info {
>  	void *block_virt_addr;
>  	dma_addr_t block_dma_addr;
> -	rxd_info_t *rxds;
> -} rx_block_info_t;
> -
> -/* pre declaration of the nic structure */
> -typedef struct s2io_nic nic_t;
> +	struct rxd_info *rxds;
> +};
> 
>  /* Ring specific structure */
> -typedef struct ring_info {
> +struct ring_info {
>  	/* The ring number */
>  	int ring_no;
> 
> @@ -600,7 +601,7 @@ typedef struct ring_info {
>  	 *  Place holders for the virtual and physical addresses of
>  	 *  all the Rx Blocks
>  	 */
> -	rx_block_info_t rx_blocks[MAX_RX_BLOCKS_PER_RING];
> +	struct rx_block_info rx_blocks[MAX_RX_BLOCKS_PER_RING];
>  	int block_count;
>  	int pkt_cnt;
> 
> @@ -608,13 +609,13 @@ typedef struct ring_info {
>  	 * Put pointer info which indictes which RxD has to be
replenished
>  	 * with a new buffer.
>  	 */
> -	rx_curr_put_info_t rx_curr_put_info;
> +	struct rx_curr_put_info rx_curr_put_info;
> 
>  	/*
>  	 * Get pointer info which indictes which is the last RxD that
was
>  	 * processed by the driver.
>  	 */
> -	rx_curr_get_info_t rx_curr_get_info;
> +	struct rx_curr_get_info rx_curr_get_info;
> 
>  #ifndef CONFIG_S2IO_NAPI
>  	/* Index to the absolute position of the put pointer of Rx ring
*/
> @@ -622,12 +623,12 @@ #ifndef CONFIG_S2IO_NAPI
>  #endif
> 
>  	/* Buffer Address store. */
> -	buffAdd_t **ba;
> -	nic_t *nic;
> -} ring_info_t;
> +	struct bufAdd **ba;
> +	struct s2io_nic *nic;
> +};
> 
>  /* Fifo specific structure */
> -typedef struct fifo_info {
> +struct fifo_info {
>  	/* FIFO number */
>  	int fifo_no;
> 
> @@ -635,40 +636,40 @@ typedef struct fifo_info {
>  	int max_txds;
> 
>  	/* Place holder of all the TX List's Phy and Virt addresses. */
> -	list_info_hold_t *list_info;
> +	struct list_info_hold *list_info;
> 
>  	/*
>  	 * Current offset within the tx FIFO where driver would write
>  	 * new Tx frame
>  	 */
> -	tx_curr_put_info_t tx_curr_put_info;
> +	struct tx_curr_put_info tx_curr_put_info;
> 
>  	/*
>  	 * Current offset within tx FIFO from where the driver would
start
> freeing
>  	 * the buffers
>  	 */
> -	tx_curr_get_info_t tx_curr_get_info;
> +	struct tx_curr_get_info tx_curr_get_info;
> 
> -	nic_t *nic;
> -}fifo_info_t;
> +	struct s2io_nic *nic;
> +};
> 
>  /* Information related to the Tx and Rx FIFOs and Rings of Xena
>   * is maintained in this structure.
>   */
> -typedef struct mac_info {
> +struct mac_info {
>  /* tx side stuff */
>  	/* logical pointer of start of each Tx FIFO */
> -	TxFIFO_element_t __iomem *tx_FIFO_start[MAX_TX_FIFOS];
> +	struct TxFIFO_element __iomem *tx_FIFO_start[MAX_TX_FIFOS];
> 
>  	/* Fifo specific structure */
> -	fifo_info_t fifos[MAX_TX_FIFOS];
> +	struct fifo_info fifos[MAX_TX_FIFOS];
> 
>  	/* Save virtual address of TxD page with zero DMA addr(if any)
*/
>  	void *zerodma_virt_addr;
> 
>  /* rx side stuff */
>  	/* Ring specific structure */
> -	ring_info_t rings[MAX_RX_RINGS];
> +	struct ring_info rings[MAX_RX_RINGS];
> 
>  	u16 rmac_pause_time;
>  	u16 mc_pause_threshold_q0q3;
> @@ -677,14 +678,14 @@ typedef struct mac_info {
>  	void *stats_mem;	/* orignal pointer to allocated mem */
>  	dma_addr_t stats_mem_phy;	/* Physical address of the stat
block
> */
>  	u32 stats_mem_sz;
> -	StatInfo_t *stats_info;	/* Logical address of the stat block */
> -} mac_info_t;
> +	struct stat_block *stats_info;	/* Logical address of the stat
> block */
> +};
> 
>  /* structure representing the user defined MAC addresses */
> -typedef struct {
> +struct usr_addr {
>  	char addr[ETH_ALEN];
>  	int usage_cnt;
> -} usr_addr_t;
> +};
> 
>  /* Default Tunable parameters of the NIC. */
>  #define DEFAULT_FIFO_0_LEN 4096
> @@ -717,7 +718,7 @@ struct msix_info_st {
>  };
> 
>  /* Data structure to represent a LRO session */
> -typedef struct lro {
> +struct lro {
>  	struct sk_buff	*parent;
>  	struct sk_buff  *last_frag;
>  	u8		*l2h;
> @@ -733,7 +734,7 @@ typedef struct lro {
>  	u32		cur_tsval;
>  	u32		cur_tsecr;
>  	u8		saw_ts;
> -}lro_t;
> +};
> 
>  /* Structure representing one instance of the NIC */
>  struct s2io_nic {
> @@ -746,7 +747,7 @@ #ifdef CONFIG_S2IO_NAPI
>  	int pkts_to_process;
>  #endif
>  	struct net_device *dev;
> -	mac_info_t mac_control;
> +	struct mac_info mac_control;
>  	struct config_param config;
>  	struct pci_dev *pdev;
>  	void __iomem *bar0;
> @@ -754,8 +755,8 @@ #endif
>  #define MAX_MAC_SUPPORTED   16
>  #define MAX_SUPPORTED_MULTICASTS MAX_MAC_SUPPORTED
> 
> -	macaddr_t def_mac_addr[MAX_MAC_SUPPORTED];
> -	macaddr_t pre_mac_addr[MAX_MAC_SUPPORTED];
> +	struct mac_addr def_mac_addr[MAX_MAC_SUPPORTED];
> +	struct mac_addr pre_mac_addr[MAX_MAC_SUPPORTED];
> 
>  	struct net_device_stats stats;
>  	int high_dma_flag;
> @@ -785,7 +786,7 @@ #define ALL_MULTI   2
>  #define MAX_ADDRS_SUPPORTED 64
>  	u16 usr_addr_count;
>  	u16 mc_addr_count;
> -	usr_addr_t usr_addrs[MAX_ADDRS_SUPPORTED];
> +	struct usr_addr usr_addrs[MAX_ADDRS_SUPPORTED];
> 
>  	u16 m_cast_flg;
>  	u16 all_multi_pos;
> @@ -841,7 +842,7 @@ #define XFRAME_II_DEVICE	2
>  	u8 device_type;
> 
>  #define MAX_LRO_SESSIONS	32
> -	lro_t lro0_n[MAX_LRO_SESSIONS];
> +	struct lro lro0_n[MAX_LRO_SESSIONS];
>  	unsigned long	clubbed_frms_cnt;
>  	unsigned long	sending_both;
>  	u8		lro;
> @@ -975,43 +976,43 @@ static void __devexit s2io_rem_nic(struc
>  static int init_shared_mem(struct s2io_nic *sp);
>  static void free_shared_mem(struct s2io_nic *sp);
>  static int init_nic(struct s2io_nic *nic);
> -static void rx_intr_handler(ring_info_t *ring_data);
> -static void tx_intr_handler(fifo_info_t *fifo_data);
> +static void rx_intr_handler(struct ring_info *ring_data);
> +static void tx_intr_handler(struct fifo_info *fifo_data);
>  static void alarm_intr_handler(struct s2io_nic *sp);
> 
>  static int s2io_starter(void);
>  static void s2io_tx_watchdog(struct net_device *dev);
>  static void s2io_tasklet(unsigned long dev_addr);
>  static void s2io_set_multicast(struct net_device *dev);
> -static int rx_osm_handler(ring_info_t *ring_data, RxD_t * rxdp);
> -static void s2io_link(nic_t * sp, int link);
> +static int rx_osm_handler(struct ring_info *ring_data, struct RxD_t *
> rxdp);
> +static void s2io_link(struct s2io_nic * sp, int link);
>  #if defined(CONFIG_S2IO_NAPI)
>  static int s2io_poll(struct net_device *dev, int *budget);
>  #endif
> -static void s2io_init_pci(nic_t * sp);
> +static void s2io_init_pci(struct s2io_nic * sp);
>  static int s2io_set_mac_addr(struct net_device *dev, u8 * addr);
>  static void s2io_alarm_handle(unsigned long data);
> -static int s2io_enable_msi(nic_t *nic);
> +static int s2io_enable_msi(struct s2io_nic *nic);
>  static irqreturn_t s2io_msi_handle(int irq, void *dev_id);
>  static irqreturn_t
>  s2io_msix_ring_handle(int irq, void *dev_id);
>  static irqreturn_t
>  s2io_msix_fifo_handle(int irq, void *dev_id);
>  static irqreturn_t s2io_isr(int irq, void *dev_id);
> -static int verify_xena_quiescence(nic_t *sp, u64 val64, int flag);
> +static int verify_xena_quiescence(struct s2io_nic *sp, u64 val64, int
> flag);
>  static const struct ethtool_ops netdev_ethtool_ops;
>  static void s2io_set_link(struct work_struct *work);
> -static int s2io_set_swapper(nic_t * sp);
> -static void s2io_card_down(nic_t *nic);
> -static int s2io_card_up(nic_t *nic);
> +static int s2io_set_swapper(struct s2io_nic * sp);
> +static void s2io_card_down(struct s2io_nic *nic);
> +static int s2io_card_up(struct s2io_nic *nic);
>  static int get_xena_rev_id(struct pci_dev *pdev);
> -static void restore_xmsi_data(nic_t *nic);
> +static void restore_xmsi_data(struct s2io_nic *nic);
> 
> -static int s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len,
> lro_t **lro, RxD_t *rxdp, nic_t *sp);
> -static void clear_lro_session(lro_t *lro);
> +static int s2io_club_tcp_session(u8 *buffer, u8 **tcp, u32 *tcp_len,
> struct lro **lro, struct RxD_t *rxdp, struct s2io_nic *sp);
> +static void clear_lro_session(struct lro *lro);
>  static void queue_rx_frame(struct sk_buff *skb);
> -static void update_L3L4_header(nic_t *sp, lro_t *lro);
> -static void lro_append_pkt(nic_t *sp, lro_t *lro, struct sk_buff
*skb,
> u32 tcp_len);
> +static void update_L3L4_header(struct s2io_nic *sp, struct lro *lro);
> +static void lro_append_pkt(struct s2io_nic *sp, struct lro *lro,
struct
> sk_buff *skb, u32 tcp_len);
> 
>  #define s2io_tcp_mss(skb) skb_shinfo(skb)->gso_size
>  #define s2io_udp_mss(skb) skb_shinfo(skb)->gso_size
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

