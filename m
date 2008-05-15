From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/15] BE NIC driver - interrupt, ethtool, stack i/f functions
Date: Thu, 15 May 2008 13:14:28 +0100
Message-ID: <20080515121427.GJ28241@solarflare.com>
References: <20080515090613.03bf6fa6@mailhost.serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Subbu Seetharaman <subbus@serverengines.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 82-69-137-158.dsl.in-addr.zen.co.uk ([82.69.137.158]:47723 "EHLO
	uklogin.uk.level5networks.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751640AbYEOMOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 08:14:35 -0400
Content-Disposition: inline
In-Reply-To: <20080515090613.03bf6fa6@mailhost.serverengines.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Subbu Seetharaman wrote:
> +#define NET_DEV_STATS_LEN \
> +	(sizeof(struct net_device_stats)/sizeof(unsigned long))
> +#define BENET_STATS_LEN  sizeof(benet_gstrings_stats) / ETH_GSTRING_LEN

You can use the ARRAY_SIZE() macro for this.

> +
> +static void
> +be_get_drvinfo(struct net_device *netdev, struct ethtool_drvinfo *drvinfo)
> +{
> +	struct bni_net_object *pnob = netdev->priv;
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +
> +	strncpy(drvinfo->driver, be_driver_name, 32);
> +	strncpy(drvinfo->version, be_drvr_ver, 32);
> +	strncpy(drvinfo->fw_version, be_fw_ver, 32);
> +	strcpy(drvinfo->bus_info, pci_name(adapter->pdev));

You can use ETHTOOL_BUSINFO_LEN as a limit here, though it's longer than
the pci_name() string can currently be.

> +static int
> +be_set_coalesce(struct net_device *netdev,
> +		struct ethtool_coalesce *coalesce)
> +{
> +	struct bni_net_object *pnob = netdev->priv;
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +	u32 max, min, cur;
> +
> +	adapter->max_rx_coal = coalesce->rx_max_coalesced_frames;
> +	if (adapter->max_rx_coal < 0)
> +		adapter->max_rx_coal = 0;

rx_max_coalesced_frames is unsigned.  If you make max_rx_coal unsigned too
then you don't need to worry about this case.

> +	if (adapter->max_rx_coal >= BE_LRO_MAX_PKTS)
> +		adapter->max_rx_coal = BE_LRO_MAX_PKTS;

Why are you applying an LRO limit here?  This is supposed to control
interrupt coalescing.

> +static void
> +be_get_ethtool_stats(struct net_device *netdev,
> +		     struct ethtool_stats *stats, uint64_t *data)
> +{
> +	struct bni_net_object *pnob = netdev->priv;
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +	int i;
> +
> +	data[0] = adapter->pdev->irq;

That's a very strange way to expose the IRQ number.

> +static void
> +be_get_pauseparam(struct net_device *netdev,
> +		  struct ethtool_pauseparam *ecmd)
> +{
> +	struct bni_net_object *pnob = netdev->priv;
> +	bool rxfc = FALSE;
> +	bool txfc = FALSE;
> +	BESTATUS status;
> +	if (ecmd->cmd != ETHTOOL_GPAUSEPARAM)
> +		return;

How could this happen?

> +	status = bni_get_flow_ctl(&pnob->fn_obj, &txfc, &rxfc);
> +	if (status != BE_SUCCESS)
> +		printk(KERN_WARNING "Unable to get pause frame settings\n");
> +
> +	if (txfc == TRUE)
> +		ecmd->tx_pause = 1;
> +	else
> +		ecmd->tx_pause = 0;
> +
> +	if (rxfc == TRUE)
> +		ecmd->rx_pause = 1;
> +	else
> +		ecmd->rx_pause = 0;
> +
> +	/* Always setting autoneg to TRUE */
> +	ecmd->autoneg = 1;
> +
> +	return;

Don't use return here; it's redundant.

> +}
> +
> +static int
> +be_set_pauseparam(struct net_device *netdev,
> +		  struct ethtool_pauseparam *ecmd)
> +{
[...]
> +	status = bni_set_flow_ctll(&pnob->fn_obj, txfc, rxfc);
> +	if (status != BE_SUCCESS)
> +		printk(KERN_ERR "Unable to set pause frame settings\n");
> +	return 0;

Don't printk() the error, return an error code.

> +}
> +
> +struct ethtool_ops be_ethtool_ops = {
> +	.get_settings = be_get_settings,
> +	.get_drvinfo = be_get_drvinfo,
> +	.get_link = ethtool_op_get_link,
> +	.get_coalesce = be_get_coalesce,
> +	.set_coalesce = be_set_coalesce,
> +	.get_ringparam = be_get_ringparam,
> +	.get_pauseparam = be_get_pauseparam,
> +	.set_pauseparam = be_set_pauseparam,
> +	.get_rx_csum = be_get_rx_csum,	/*Yes */
> +	.set_rx_csum = be_set_rx_csum,
> +	.get_tx_csum = ethtool_op_get_tx_csum,	/*Yes */
> +	.set_tx_csum = ethtool_op_set_tx_csum,	/*Yes */
> +	.get_sg = ethtool_op_get_sg,	/*Yes */
> +	.set_sg = ethtool_op_set_sg,	/*Yes */

These comments aren't at all helpful.

> --- /dev/null
> +++ b/drivers/net/benet/be_int.c
[...]
> + * The full GNU General Public License is included in this distribution
> + * in the file called GPL.

Actually it's called COPYING.

> +#ifdef CONFIG_BENET_NAPI
> +#define NETIF_RX(skb) netif_receive_skb(skb);
> +#else
> +#define NETIF_RX(skb) netif_rx(skb);
> +#endif

Don't put semi-colons on the end of macros.

> +
> +/*
> + * adds additional receive frags indicated by BE starting from given
> + * frag index (fi) to specified skb's frag list
> + */
> +static inline void
> +add_skb_frags(struct bni_net_object *pnob, struct sk_buff *skb,
> +		int nresid, u32 fi)

Probably shouldn't be declared inline - the compiler can work that out.
(And yes, this is hypocrisy on my part.)

> +{
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +	u32 sk_frag_idx, n;
> +	struct be_rx_page_info *rx_page_info;
> +	u32 frag_sz = pnob->rx_buf_size;
> +
> +	sk_frag_idx = skb_shinfo(skb)->nr_frags;
> +	while (nresid) {
> +		fi = (fi + 1) % pnob->rx_q_len; /* frag index */

If rx_q_len is always a power of two, you can mask and avoid a division
(relatively slow).

> +/*
> + * This function processes incoming nic packets over various Rx queues.
> + * This function takes the adapter, the current Rx status descriptor
> + * entry and the Rx completion queue ID as argument.
> + */
> +static inline int process_nic_rx_completion(struct bni_net_object *pnob,
> +					    struct ETH_RX_COMPL_AMAP *rxcp)
> +{
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +	struct sk_buff *skb;
> +	int udpcksm, tcpcksm;
> +	int n, fi;
> +	int nresid;
> +	unsigned int frag_sz = pnob->rx_buf_size;
> +	u8 *va;
> +	struct be_rx_page_info *rx_page_info;
> +	u32 numfrags, vtp, vtm, vlan_tag, pktsize;
> +
> +	fi  = AMAP_GET_BITS_PTR(ETH_RX_COMPL, fragndx, rxcp);
> +	SA_ASSERT(fi < (int)pnob->rx_q_len);
> +	SA_ASSERT(fi >= 0);

You should use BUG_ON, not your own assertion macros.

> +	rx_page_info = (struct be_rx_page_info *) pnob->rx_ctxt[fi];
> +	SA_ASSERT(rx_page_info->page);
> +	pnob->rx_ctxt[fi] = (void *)NULL;

The cast is redundant.

> +	sa_atomic_decrement(&pnob->rx_q_posted);

Why not atomic_dec()?

[...]
> +#ifdef CONFIG_INET_LRO
[... 127 lines ...]
> +#else
> +		process_nic_rx_completion(pnob, rxcp);
> +#endif

It looks like you should create a separate function for the LRO case.

> +static void process_bcast_rx_completion(struct bni_net_object *pnob)
> +{
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +	struct ETH_RX_COMPL_AMAP *rxcp;
> +
> +	u32 nc = 0;
> +
> +	adapter->be_stat.bes_bcrx_events++;
> +
> +	nc = 0;

Redundant assignment.

> +/*
> + * posts receive buffers to the Eth receive queue.
> + */
> +void post_eth_rx_buffs(struct bni_net_object *pnob)
> +{
> +	struct be_adapter *adapter = OSM_NOB(pnob)->adapter;
> +	u32 num_bufs, r;
> +	u64 busaddr = 0, tmp_pa;
> +	u32 max_bufs, pg_hd;
> +	u32 frag_size;
> +	struct BNI_RECV_BUFFER *rxbp;
> +	SA_LIST_ENTRY rxbl;
> +	struct be_rx_page_info *rx_page_info;
> +	struct page *page = NULL;
> +	u32 page_order = 0;
> +	gfp_t alloc_flags = (gfp_t)GFP_ATOMIC;

Redundant cast.  We all know what GFP_ATOMIC is used for and the compiler
is happy to convert it.

> +	SA_ASSERT(adapter);
> +
> +	max_bufs = (u32) 64;	/* should be even # <= 255. */
> +	SA_ASSERT(max_bufs < 255 && (max_bufs & 1) == 0);

Why are you making an assertion about a constant?  Perhaps you want
something like:

#define MAX_POST_RX_BUFS 64 /* should be even # <= 255. */

and then you can use a compile-time assertion:

	BUILD_BUG_ON(MAX_POST_RX_BUFS > 255 || MAX_POST_RX_BUFS & 1);

> +	frag_size = pnob->rx_buf_size;
> +
> +	if (frag_size == 8192) {
> +		page_order = 1;
> +		alloc_flags |= (gfp_t)__GFP_COMP;
> +	}

You're assuming PAGE_SIZE == 4096.

> +#ifdef CONFIG_BENET_NAPI
> +/*
> + * Poll function called by NAPI with a work budget.
> + * We process as many UC. BC and MC receive completions
> + * as the budget allows and return the actual number of
> + * RX ststutses processed.
> + */
> +int be_poll(struct napi_struct *napi, int budget)
> +{
> +	struct net_device *netdev = napi->dev;
> +	struct bni_net_object *pnob = (struct bni_net_object *) netdev->priv;
> +	struct be_adapter *adapter = (struct be_adapter *)
> +						OSM_NOB(pnob)->adapter;
> +	u32 work_done;
> +
> +	adapter->be_stat.bes_polls++;
> +	OSM_NOB(pnob)->work_quota = budget;
> +	process_ucast_rx_completion(pnob);
> +	process_bcast_rx_completion(pnob);
> +	if (pnob->rx_q_posted < 900)
> +		post_eth_rx_buffs(pnob);
> +
> +	work_done = (budget - OSM_NOB(pnob)->work_quota);
[...]
> +	return (budget - OSM_NOB(pnob)->work_quota);
> +}

These lines appear to be redundant.

> --- /dev/null
> +++ b/drivers/net/benet/be_netif.c
[...]
> +/* Strings to print Link properties */
> +static char *link_speed[] = {
> +	"Invalid link Speed Value",
> +	"10 Mbps",
> +	"100 Mbps",
> +	"1 Gbps",
> +	"10 Gbps"
> +};
> +
> +static char *link_duplex[] = {
> +	"Invalid Duplex Value",
> +	"Half Duplex",
> +	"Full Duplex"
> +};
> 
> +static char *link_state[] = {
> +	"",
> +	"(active)"
> +};
> +
> +
> +void be_print_link_info(struct BE_LINK_STATUS *lnk_status)
> +{
> +	u16 si, di, ai;
> +
> +	/* Port 0 */
> +	if (lnk_status->mac0_speed && lnk_status->mac0_duplex) {
> +		/* Port is up and running */
> +		si = (lnk_status->mac0_speed < 5) ?
> +			lnk_status->mac0_speed : 0;
> +		di = (lnk_status->mac0_duplex < 3) ?
> +			lnk_status->mac0_duplex : 0;
> +		ai = (lnk_status->active_port == 0) ?  1 : 0;
> +		printk(KERN_INFO "PortNo. 0: Speed - %s %s %s\n",
> +			link_speed[si], link_duplex[di], link_state[ai]);
> +	} else
> +		printk(KERN_INFO "PortNo. 0: Down\n");
> +
> +	/* Port 1 */
> +	if (lnk_status->mac1_speed && lnk_status->mac1_duplex) {
> +		/* Port is up and running */
> +		si = (lnk_status->mac1_speed < 5) ?
> +			lnk_status->mac1_speed : 0;
> +		di = (lnk_status->mac1_duplex < 3) ?
> +			lnk_status->mac1_duplex : 0;
> +		ai = (lnk_status->active_port == 0) ?  1 : 0;
> +		printk(KERN_INFO "PortNo. 1: Speed - %s %s %s\n",
> +			link_speed[si], link_duplex[di], link_state[ai]);
> +	} else
> +		printk(KERN_INFO "PortNo. 1: Down\n");
> +
> +	return;
> +}

Can't you leave this to ethtool and linkwatch?

> +/*
> + * Setting a Mac Address for BE
> + * Takes netdev and a void pointer as arguments.
> + * The pointer holds the new addres to be used.
> + */
> +static int benet_set_mac_addr(struct net_device *netdev, void *p)
> +{
> +	struct sockaddr *addr = p;
> +	struct bni_net_object *pnob;
> +	struct SA_MAC_ADDRESS mac_addr;
> +
> +	SA_ASSERT(netdev);
> +	pnob = (struct bni_net_object *) netdev->priv;
> +	SA_ASSERT(pnob);
> +
> +	memcpy(pnob->mac_address, addr->sa_data, netdev->addr_len);
> +	memcpy(netdev->dev_addr, addr->sa_data, netdev->addr_len);
> +	memcpy(mac_addr.bytes, pnob->mac_address, SA_MAC_ADDRESS_SIZE);
> +	bni_set_uc_mac_adr(pnob, 0, 0, OSM_NOB(pnob)->devno,
> +			   &mac_addr, NULL, NULL);

Do you *really* need all these separate copies of the MAC address?

> +	/*
> +	 * Since we are doing Active-Passive failover, both
> +	 * ports should have matching MAC addresses everytime.
> +	 */
> +	bni_set_uc_mac_adr(pnob, 1, 0, OSM_NOB(pnob)->devno,
> +			   &mac_addr, NULL, NULL);
> +
> +	return 0;
> +}
> +
> +void get_stats_timer_handler(unsigned long context)
> +{
> +	struct be_timer_ctxt *ctxt = (struct be_timer_ctxt *) context;
> +
> +	if (atomic_read(&ctxt->get_stat_flag)) {
> +		atomic_dec(&ctxt->get_stat_flag);
> +		up((void *) ctxt->get_stat_sem);

get_stat_sem is declared as an unsigned long, so why are you treating it as
struct semaphore?

> +	}
> +	del_timer(&ctxt->get_stats_timer);
> +	return;
> +}

That's as far as I read.  I'll leave the rest for others.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
