From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Subject: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 16 Oct 2009 21:20:06 +0100
Message-ID: <1255724406.2869.70.camel@achroite>
References: <200910161824.n9GIOuoX010135@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, amathur@brocade.com
To: Rasesh Mody <rmody@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:26898 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751049AbZJPUUF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2009 16:20:05 -0400
In-Reply-To: <200910161824.n9GIOuoX010135@blc-10-10.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-10-16 at 11:24 -0700, Rasesh Mody wrote:
> From: Rasesh Mody <rmody@brocade.com>
>=20
> This is patch 1/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
>=20
> We wish this patch to be considered for inclusion in 2.6.32

I think it's a bit late for that.

[...]
> +#ifdef NETIF_F_TSO
> +#include <net/checksum.h>
> +#endif

NETIF_F_TSO is always defined; remove the check.

[...]
> +#ifdef BNAD_NO_IP_ALIGN
> +#undef NET_IP_ALIGN
> +#define NET_IP_ALIGN	0
> +#endif

Don't redefine standard macros.  Define your own which is set to either
NET_IP_ALIGN or 0 as appropriate.

> +#define BNAD_TXQ_WI_NEEDED(_vectors)	(((_vectors) + 3) >> 2)
> +
> +#define BNAD_RESET_Q(_bnad, _q, _unmap_q)				\
> +do {									\
> +	if ((_q)->producer_index !=3D (_q)->consumer_index) {      \
> +		DPRINTK(ERR, "Q producer index %u !=3D ",	(_q)->producer_index);  =
    \
> +		DPRINTK(ERR, "consumer index %u\n", (_q)->consumer_index);      \
> +	}								\
> +	BNA_ASSERT((_q)->producer_index =3D=3D (_q)->consumer_index);      =
\
> +	if ((_unmap_q)->producer_index !=3D (_unmap_q)->consumer_index) {  =
    \
> +		DPRINTK(ERR, "UnmapQ producer index %u !=3D ", (_unmap_q)->produce=
r_index);      \
> +		DPRINTK(ERR, "consumer index %u\n", (_unmap_q)->consumer_index);  =
    \
> +	}								\
> +	BNA_ASSERT((_unmap_q)->producer_index =3D=3D \
> +		(_unmap_q)->consumer_index);      \
> +	(_q)->producer_index =3D 0;	\
> +	(_q)->consumer_index =3D 0;	\
> +	(_unmap_q)->producer_index =3D 0;	\
> +	(_unmap_q)->consumer_index =3D 0;	\
> +	{	\
> +		u32 _ui;	\
> +		for (_ui =3D 0; _ui < (_unmap_q)->q_depth; _ui++)		\
> +			BNA_ASSERT(!(_unmap_q)->unmap_array[_ui].skb);      \
> +	}	\
> +} while (0)

Is there any reason not to write this as a function?  It looks like an
infrequent control operation that shouldn't even be an inline function.

[...]
> +static const struct net_device_ops bnad_netdev_ops =3D {
> +	.ndo_open				=3D bnad_open,
> +	.ndo_stop				=3D bnad_stop,
> +	.ndo_start_xmit			=3D bnad_start_xmit,
> +	.ndo_get_stats			=3D bnad_get_stats,
> +#ifdef HAVE_SET_RX_MODE
> +	.ndo_set_rx_mode		=3D &bnad_set_rx_mode,
> +#endif

The HAVE_* macros are meant for use by out-of-tree drivers.  There is n=
o
need to test them in in-tree code.

[...]
> +static int bnad_check_module_params(void)
> +{
> +	/* bnad_msix */
> +	if (bnad_msix && bnad_msix !=3D 1)
> +		printk(KERN_WARNING "bna: bnad_msix should be 0 or 1, "
> +		    "%u is invalid, set bnad_msix to 1\n", bnad_msix);
> +
> +	/* bnad_small_large_rxbufs */
> +	if (bnad_small_large_rxbufs && bnad_small_large_rxbufs !=3D 1)
> +		printk(KERN_WARNING "bna: bnad_small_large_rxbufs should be "
> +		    "0 or 1, %u is invalid, set bnad_small_large_rxbufs to 1\n",
> +		    bnad_small_large_rxbufs);
> +	if (bnad_small_large_rxbufs)
> +		bnad_rxqs_per_cq =3D 2;
> +	else
> +		bnad_rxqs_per_cq =3D 1;
> +
> +	/* bnad_rxqsets_used */
> +	if (bnad_rxqsets_used > BNAD_MAX_RXQS / bnad_rxqs_per_cq) {
> +		printk(KERN_ERR "bna: the maximum value for bnad_rxqsets_used "
> +		    "is %u, %u is invalid\n",
> +		    BNAD_MAX_RXQS / bnad_rxqs_per_cq, bnad_rxqsets_used);
> +		return -EINVAL;
> +	}

There is a cleaner way to validate and reject module parameter values
which is to define the parameters with module_param_call().

> +static void bnad_alloc_rxbufs(struct bnad_rxq_info *rxqinfo)
> +{
> +	u16 to_alloc, alloced, unmap_prod, wi_range;
> +	struct bnad_skb_unmap *unmap_array;
> +	struct bna_rxq_entry *rxent;
> +	struct sk_buff *skb;
> +	dma_addr_t dma_addr;
> +
> +	alloced =3D 0;
> +	to_alloc =3D BNA_QE_FREE_CNT(&rxqinfo->skb_unmap_q,
> +	    rxqinfo->skb_unmap_q.q_depth);
> +
> +	unmap_array =3D rxqinfo->skb_unmap_q.unmap_array;
> +	unmap_prod =3D rxqinfo->skb_unmap_q.producer_index;
> +	BNA_RXQ_QPGE_PTR_GET(unmap_prod, &rxqinfo->rxq.q, rxent, wi_range);
> +	BNA_ASSERT(wi_range && wi_range <=3D rxqinfo->rxq.q.q_depth);
> +
> +	while (to_alloc--) {
> +		if (!wi_range) {
> +			BNA_RXQ_QPGE_PTR_GET(unmap_prod, &rxqinfo->rxq.q,
> +			    rxent, wi_range);
> +			BNA_ASSERT(wi_range &&
> +			    wi_range <=3D rxqinfo->rxq.q.q_depth);
> +		}
> +#ifdef BNAD_RXBUF_HEADROOM
> +		skb =3D netdev_alloc_skb(rxqinfo->bnad->netdev,
> +		    rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN);
> +#else
> +		skb =3D alloc_skb(rxqinfo->rxq_config.buffer_size + NET_IP_ALIGN,
> +		    GFP_ATOMIC);
> +#endif

Why is this conditional?

[...]
> +static irqreturn_t bnad_msix_rx(int irq, void *data)
> +{
> +	struct bnad_cq_info *cqinfo =3D (struct bnad_cq_info *)data;
> +	struct bnad *bnad =3D cqinfo->bnad;
> +
> +		if (likely(netif_rx_schedule_prep(bnad->netdev,
> +			&cqinfo->napi))) {
> +			bnad_disable_rx_irq(bnad, cqinfo);
> +			__netif_rx_schedule(bnad->netdev, &cqinfo->napi);
> +		}
> +
> +	return IRQ_HANDLED;
> +}

Indentation is wrong.

[...]
> +static irqreturn_t bnad_isr(int irq, void *data)
> +{
> +	struct net_device *netdev =3D data;
> +	struct bnad *bnad =3D netdev_priv(netdev);
> +	u32 intr_status;
> +
> +	spin_lock(&bnad->priv_lock);
> +	bna_intr_status_get(bnad->priv, &intr_status);
> +	spin_unlock(&bnad->priv_lock);
> +
> +	if (!intr_status)
> +		return IRQ_NONE;
> +
> +	DPRINTK(DEBUG, "port %u bnad_isr: 0x%x\n", bnad->bna_id, intr_statu=
s);
> +	if (BNA_IS_MBOX_ERR_INTR(intr_status)) {
> +		spin_lock(&bnad->priv_lock);
> +		bna_mbox_err_handler(bnad->priv, intr_status);
> +		spin_unlock(&bnad->priv_lock);
> +		if (BNA_IS_ERR_INTR(intr_status) ||
> +		    !BNA_IS_INTX_DATA_INTR(intr_status))
> +			goto exit_isr;
> +	}
> +
> +	if (likely(netif_rx_schedule_prep(bnad->netdev,
> +	    &bnad->cq_table[0].napi))) {
> +		bnad_disable_txrx_irqs(bnad);
> +		__netif_rx_schedule(bnad->netdev, &bnad->cq_table[0].napi);
> +	}

These functions don't exist any more!

[...]
> +static int bnad_request_txq_irq(struct bnad *bnad, uint txq_id)
> +{
> +	BNA_ASSERT(txq_id < bnad->txq_num);
> +	if (!(bnad->flags & BNAD_F_MSIX))
> +		return 0;
> +	DPRINTK(DEBUG, "port %u requests irq %u for TxQ %u in MSIX mode\n",
> +		bnad->bna_id, bnad->msix_table[txq_id].vector, txq_id);
> +	return request_irq(bnad->msix_table[txq_id].vector,
> +	    (irq_handler_t)&bnad_msix_tx, 0, bnad->txq_table[txq_id].name,

Why are you casting this function pointer?  It has the right type
already, and if it didn't then casting wouldn't fix the matter.

> +	    &bnad->txq_table[txq_id]);
> +}
> +
> +int bnad_request_cq_irq(struct bnad *bnad, uint cq_id)
> +{
> +	BNA_ASSERT(cq_id < bnad->cq_num);
> +	if (!(bnad->flags & BNAD_F_MSIX))
> +		return 0;
> +	DPRINTK(DEBUG, "port %u requests irq %u for CQ %u in MSIX mode\n",
> +		bnad->bna_id,
> +		bnad->msix_table[bnad->txq_num + cq_id].vector, cq_id);
> +	return request_irq(bnad->msix_table[bnad->txq_num + cq_id].vector,
> +	    (irq_handler_t)&bnad_msix_rx, 0, bnad->cq_table[cq_id].name,

Same here.

[...]
> +static void bnad_link_up_cb(void *arg, u8 status)
> +{
> +	struct bnad *bnad =3D (struct bnad *)arg;
> +	struct net_device *netdev =3D bnad->netdev;
> +
> +	DPRINTK(INFO, "%s bnad_link_up_cb\n", netdev->name);
> +	if (netif_running(netdev)) {
> +		if (!netif_carrier_ok(netdev) &&
> +		    !test_bit(BNAD_DISABLED, &bnad->state)) {
> +				printk(KERN_INFO "%s link up\n", netdev->name);
> +			netif_carrier_on(netdev);
> +			netif_wake_queue(netdev);
> +			bnad->stats.netif_queue_wakeup++;
> +		}
> +	}
> +}
> +
> +static void bnad_link_down_cb(void *arg, u8 status)
> +{
> +	struct bnad *bnad =3D (struct bnad *)arg;
> +	struct net_device *netdev =3D bnad->netdev;
> +
> +	DPRINTK(INFO, "%s bnad_link_down_cb\n", netdev->name);
> +	if (netif_running(netdev)) {
> +		if (netif_carrier_ok(netdev)) {
> +			printk(KERN_INFO "%s link down\n", netdev->name);
> +			netif_carrier_off(netdev);
> +			netif_stop_queue(netdev);
> +			bnad->stats.netif_queue_stop++;
> +		}
> +	}
> +}

There is no need to wake/stop the TX queues here; the netdev core
understands that TX queues must be stopped while the link is down.

[...]
> +static void bnad_detach(struct bnad *bnad)
> +{
[...]
> +	/* Wait to make sure Tx and Rx are stopped. */
> +	msleep(1000);
> +	bnad_free_txrx_irqs(bnad);
> +	bnad_sync_mbox_irq(bnad);
> +
> +		bnad_napi_disable(bnad);
> +		bnad_napi_uninit(bnad);
> +
> +	/* Delete the stats timer after synchronize with mbox irq. */
> +	del_timer_sync(&bnad->stats_timer);
> +		netif_tx_disable(bnad->netdev);
> +		netif_carrier_off(bnad->netdev);
> +}

Some incorrect indentation here.

[...]
> +void bnad_rxib_init(struct bnad *bnad, uint cq_id, uint ib_id)
> +{
[...]
> +#if 1
> +	ib_config->control_flags =3D BNA_IB_CF_INT_ENABLE |
> +	    BNA_IB_CF_MASTER_ENABLE;
> +#else
> +	ib_config->control_flags =3D BNA_IB_CF_INT_ENABLE |
> +	    BNA_IB_CF_INTER_PKT_ENABLE | BNA_IB_CF_MASTER_ENABLE;
> +	ib_config->interpkt_count =3D bnad->rx_interpkt_count;
> +	ib_config->interpkt_timer =3D bnad->rx_interpkt_timeo;
> +#endif

If you always want to use the first version (#if 1) then get rid of the
second version.

[...]
> +/* Note: bnad_cleanup doesn't not free irqs and queues. */

A double negative can mean a positive, but this is ambiguous.  Either
change the comment to say clearly that it does free irqs and queues, or
remove the comment since the code is clear enough.

> +static void bnad_cleanup(struct bnad *bnad)
> +{
> +	kfree(bnad->rit);
> +	bnad->rit =3D NULL;
> +	kfree(bnad->txf_table);
> +	bnad->txf_table =3D NULL;
> +	kfree(bnad->rxf_table);
> +	bnad->rxf_table =3D NULL;
> +
> +	bnad_free_ibs(bnad);
> +	bnad_free_queues(bnad);
> +}
[...]
> +int bnad_open_locked(struct net_device *netdev)
> +{
> +	struct bnad *bnad =3D netdev_priv(netdev);
> +	uint i;
> +	int err;
> +
> +	ASSERT_RTNL();
> +	DPRINTK(WARNING, "%s open\n", netdev->name);
> +
> +	if (BNAD_NOT_READY(bnad)) {
> +		DPRINTK(WARNING, "%s is not ready yet (0x%lx)\n",
> +			netdev->name, bnad->state);
> +		return 0;
> +	}
> +
> +	if (!test_bit(BNAD_DISABLED, &bnad->state)) {
> +		DPRINTK(WARNING, "%s is already opened (0x%lx)\n",
> +			netdev->name, bnad->state);
> +
> +		return 0;
> +	}

Why are you returning 0 in these error cases?

[...]
> +int bnad_open(struct net_device *netdev)
> +{
> +	struct bnad *bnad =3D netdev_priv(netdev);
> +	int error =3D 0;
> +
> +	bnad_lock();
> +	if (!test_bit(BNAD_PORT_DISABLED, &bnad->state))
> +		error =3D bnad_open_locked(netdev);
> +	bnad_unlock();
> +	return error;
> +}
> +
> +int bnad_stop(struct net_device *netdev)
> +{
> +	int error =3D 0;
> +
> +	bnad_lock();
> +	error =3D bnad_stop_locked(netdev);
> +	bnad_unlock();
> +	return error;
> +}

Given that bnad_lock() and bnad_unlock() are defined as doing nothing,
you should merge these with the functions they call.

[...]
> +static int bnad_tso_prepare(struct bnad *bnad, struct sk_buff *skb)
> +{
> +#ifdef NETIF_F_TSO
> +	int err;
> +
> +#ifdef SKB_GSO_TCPV4
> +	/* SKB_GSO_TCPV4 and SKB_GSO_TCPV6 is defined since 2.6.18. */

So there is no need to test for it. :-)

[...]
> +int bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)

Return type must be netdev_tx_t.

[...]
> +static void bnad_set_rx_mode(struct net_device *netdev)
> +{
> +	bnad_lock();
> +	bnad_set_rx_mode_locked(netdev);
> +	bnad_unlock();
> +}
[...]
> +static int bnad_set_mac_address(struct net_device *netdev, void *add=
r)
> +{
> +	int err =3D 0;
> +
> +	bnad_lock();
> +	err =3D bnad_set_mac_address_locked(netdev, addr);
> +	bnad_unlock();
> +	return err;
> +
> +}

Can also be merged with the functions they call.

[...]
> +static int bnad_ioctl(struct net_device *netdev, struct ifreq *ifr, =
int cmd)
> +{
> +	return -EOPNOTSUPP;
> +}

You don't need to define an ioctl() operation at all.

[...]
> +#ifdef CONFIG_NET_POLL_CONTROLLER
> +static void bnad_netpoll(struct net_device *netdev)
> +{
> +	struct bnad *bnad =3D netdev_priv(netdev);
> +
> +	DPRINTK(INFO, "%s bnad_netpoll\n", netdev->name);
> +	disable_irq(bnad->pcidev->irq);
> +	bnad_isr(bnad->pcidev->irq, netdev);
> +	enable_irq(bnad->pcidev->irq);
> +}
> +#endif
=EF=BB=BF
This doesn't look like it will work when the hardware is configured for
MSI-X.

[...]
> +static void bnad_stats_timeo(unsigned long data)
> +{
> +	struct bnad *bnad =3D (struct bnad *)data;
> +	int i;
> +	struct bnad_rxq_info *rxqinfo;
> +
> +	spin_lock_irq(&bnad->priv_lock);
> +	bna_stats_get(bnad->priv);
> +	spin_unlock_irq(&bnad->priv_lock);
> +
> +	if (bnad->rx_dyn_coalesce_on) {
> +		u8 cls_timer;
> +		struct bnad_cq_info *cq;
> +		for (i =3D 0; i < bnad->cq_num; i++) {
> +			cq =3D &bnad->cq_table[i];
> +
> +			if ((cq->pkt_rate.small_pkt_cnt =3D=3D 0)
> +			    && (cq->pkt_rate.large_pkt_cnt =3D=3D 0))
> +				continue;
> +
> +				cls_timer =3D bna_calc_coalescing_timer(
> +				bnad->priv, &cq->pkt_rate);
> +
> +			/*For NAPI version, coalescing timer need to stored*/
> +			cq->rx_coalescing_timeo =3D cls_timer;

I can't parse this comment.

[...]
> +static int bnad_priv_init(struct bnad *bnad)
> +{
> +	dma_addr_t dma_addr;
> +	struct bna_dma_addr bna_dma_addr;
> +	char inst_name[16];
> +	int err, i;
> +	struct bfa_pcidev_s pcidev_info;
> +	u32 intr_mask;
> +
> +	DPRINTK(DEBUG, "port %u bnad_priv_init\n", bnad->bna_id);
> +
> +	if (bnad_msix)
> +		bnad->flags |=3D BNAD_F_MSIX;
> +	bnad_q_num_init(bnad, bnad_rxqsets_used);
> +
> +	bnad->work_flags =3D 0;
> +	INIT_WORK(&bnad->work, bnad_work);
> +
> +	init_timer(&bnad->stats_timer);
> +	bnad->stats_timer.function =3D &bnad_stats_timeo;
> +	bnad->stats_timer.data =3D (unsigned long)bnad;
[...]
> +	init_timer(&bnad->ioc_timer);
> +	bnad->ioc_timer.function =3D &bnad_ioc_timeout;
> +	bnad->ioc_timer.data =3D (unsigned long)bnad;

Each of these groups of three statements can be written as one call to
setup_timer().

> +	mod_timer(&bnad->ioc_timer, jiffies + HZ * BNA_IOC_TIMER_FREQ / 100=
0);

It would be clearer to write the timeout as jiffies +
msecs_to_jiffies(BNA_IOC_TIMER_FREQ).  Also, given that
BNA_IOC_TIMER_FREQ is the *period* of the timer, maybe it should be
called BNA_IOC_TIMER_PERIOD.

> +static int __devinit
> +bnad_pci_probe(struct pci_dev *pcidev, const struct pci_device_id *p=
cidev_id)
> +{
> +	int err, using_dac;
> +	struct net_device *netdev;
> +	struct bnad *bnad;
> +	unsigned long mmio_start, mmio_len;
> +	static u32 bna_id;
> +
> +	DPRINTK(INFO, "bnad_pci_probe(0x%p, 0x%p)\n", pcidev, pcidev_id);
> +
> +	DPRINTK(DEBUG, "PCI func %d\n", PCI_FUNC(pcidev->devfn));
> +	if (!bfad_get_firmware_buf(pcidev)) {
> +		printk(KERN_WARNING "Failed to load Firmware Image!\n");
> +		return 0;

You *must* return an error code here.

[...]
> +	netdev->netdev_ops =3D &bnad_netdev_ops;
> +	netdev->features =3D NETIF_F_SG | NETIF_F_IP_CSUM;
> +#ifdef NETIF_F_IPV6_CSUM
> +	netdev->features |=3D NETIF_F_IPV6_CSUM;
> +#endif
> +#ifdef NETIF_F_TSO
> +	netdev->features |=3D NETIF_F_TSO;
> +#endif
> +#ifdef NETIF_F_TSO6
> +	netdev->features |=3D NETIF_F_TSO6;
> +#endif
> +#ifdef NETIF_F_LRO
> +	netdev->features |=3D NETIF_F_LRO;
> +#endif
> +#ifdef BNAD_VLAN_FEATURES
> +	netdev->vlan_features =3D netdev->features;
> +#endif

Get rid of these macro conditions.

> +	if (using_dac)
> +		netdev->features |=3D NETIF_F_HIGHDMA;
> +	netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
> +	    NETIF_F_HW_VLAN_FILTER;
> +
> +	netdev->mem_start =3D mmio_start;
> +	netdev->mem_end =3D mmio_start + mmio_len - 1;
> +
> +	bnad_set_ethtool_ops(netdev);
> +
> +	bnad->bna_id =3D bna_id;
> +	err =3D bnad_priv_init(bnad);
> +	if (err) {
> +		printk(KERN_ERR "port %u init failed: %d\n", bnad->bna_id, err);
> +		goto unmap_bar0;
> +	}
> +
> +	BNA_ASSERT(netdev->addr_len =3D=3D ETH_ALEN);
> +#ifdef ETHTOOL_GPERMADDR
> +	memcpy(netdev->perm_addr, bnad->perm_addr, netdev->addr_len);
> +#endif

Just put the address in netdev->perm_addr in the first place, and don't
test ETHTOOL_GPERMADDR.

[...]
> +static void __devexit bnad_pci_remove(struct pci_dev *pcidev)
> +{
> +	struct net_device *netdev =3D pci_get_drvdata(pcidev);
> +	struct bnad *bnad;
> +
> +	DPRINTK(INFO, "%s bnad_pci_remove\n", netdev->name);
> +	if (!netdev)
> +		return;

Surely this would indicate a bug?

[...]
> =EF=BB=BFdiff -ruP linux-2.6.32-rc4-orig/drivers/net/bna/bnad.h linux=
-2.6.32-rc4-mod/drivers/net/bna/bnad.h
> --- linux-2.6.32-rc4-orig/drivers/net/bna/bnad.h        1969-12-31 16=
:00:00.000000000 -0800
> +++ linux-2.6.32-rc4-mod/drivers/net/bna/bnad.h 2009-10-16 10:30:53.0=
75436000 -0700
[...]
> +#if !defined(CONFIG_INET_LRO) && !defined(CONFIG_INET_LRO_MODULE)
> +#include <net/ip.h>
> +#include <net/tcp.h>
> +#else
> +#include <linux/inet_lro.h>
> +#endif
> +
> +#include "bnad_compat.h"
> +
> +#if !defined(CONFIG_INET_LRO) && !defined(CONFIG_INET_LRO_MODULE)
> +#include "inet_lro.h"
> +#endif

What is this?  You want to use your own copy of inet_lro?

You should really be using GRO instead (which is a lot easier).

[...]
> +#define bnad_lock()
> +#define bnad_unlock()

What's the point of this?

[...]
> +struct bnad {
[...]
> +	struct net_device_stats net_stats;

You don't need this; use the stats in struct net_device.

[...]
> +	unsigned char perm_addr[ETH_ALEN];

Use the perm_addr in struct net_device.

> +	u32 pci_saved_config[16];
[...]

You don't need this; the PCI core saves config registers in struct
pci_dev.

You should rebase this against net-next-2.6 and run
scripts/checkpatch.pl over it before resubmitting.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

