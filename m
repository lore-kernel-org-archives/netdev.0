From: Scott Wood <scottwood@freescale.com>
Subject: Re: [net-next v4 2/8] dpaa_eth: add support for DPAA Ethernet
Date: Tue, 10 Nov 2015 21:35:48 -0600
Message-ID: <20151111033548.GA6168@home.buserror.net>
References: <1446485500-9782-1-git-send-email-madalin.bucur@freescale.com>
 <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <linuxppc-dev@lists.ozlabs.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<igal.liberman@freescale.com>, <roy.pledge@freescale.com>,
	<ppc@mindchasers.com>, <joe@perches.com>, <pebolle@tiscali.nl>,
	<joakim.tjernlund@transmode.se>, <gregkh@linuxfoundation.org>
To: Madalin Bucur <madalin.bucur@freescale.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1446485500-9782-3-git-send-email-madalin.bucur@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 02, 2015 at 07:31:34PM +0200, Madalin Bucur wrote:
> diff --git a/drivers/net/ethernet/freescale/dpaa/Makefile b/drivers/net/ethernet/freescale/dpaa/Makefile
> new file mode 100644
> index 0000000..3847ec7
> --- /dev/null
> +++ b/drivers/net/ethernet/freescale/dpaa/Makefile
> @@ -0,0 +1,11 @@
> +#
> +# Makefile for the Freescale DPAA Ethernet controllers
> +#
> +
> +# Include FMan headers
> +FMAN        = $(srctree)/drivers/net/ethernet/freescale/fman
> +ccflags-y += -I$(FMAN)

...or just put the two parts of the same driver into the same directory.

> +#define DPA_DESCRIPTION "FSL DPAA Ethernet driver"

Avoiding duplicating those four words is not worth the obfuscation of
moving it somewhere else.

> +static u8 debug = -1;

-1 does not fit in a u8.  Usually this is declared as int.

> +module_param(debug, byte, S_IRUGO);
> +MODULE_PARM_DESC(debug, "Module/Driver verbosity level");

It would be good to document the range of values here.

> +
> +/* This has to work in tandem with the DPA_CS_THRESHOLD_xxx values. */
> +static u16 tx_timeout = 1000;
> +module_param(tx_timeout, ushort, S_IRUGO);
> +MODULE_PARM_DESC(tx_timeout, "The Tx timeout in ms");

Could you elaborate on the relationship with DPA_CS_THRESHOLD_xxx?
Or even tell me where I can find such a symbol?

> +
> +/* BM */

BM?

> +#define DPAA_ETH_MAX_PAD (L1_CACHE_BYTES * 8)

This isn't used.

> +static u8 dpa_priv_common_bpid;
> +
> +static void _dpa_rx_error(struct net_device *net_dev,
> +			  const struct dpa_priv_s *priv,
> +			  struct dpa_percpu_priv_s *percpu_priv,
> +			  const struct qm_fd *fd,
> +			  u32 fqid)

Why the leading underscore?  Likewise elsewhere.

> +{
> +	/* limit common, possibly innocuous Rx FIFO Overflow errors'
> +	 * interference with zero-loss convergence benchmark results.
> +	 */

Spamming the console is bad regardless of whether you're running a
certain benchmark...

> +	if (likely(fd->status & FM_FD_ERR_PHYSICAL))
> +		pr_warn_once("non-zero error counters in fman statistics (sysfs)\n");
> +	else
> +		if (net_ratelimit())
> +			netif_err(priv, hw, net_dev, "Err FD status = 0x%08x\n",
> +				  fd->status & FM_FD_STAT_RX_ERRORS);

Why are you using likely in error paths?
Why do we need to print this error at all?  Do other net drivers do that?

> +	percpu_priv->stats.rx_errors++;
> +
> +	dpa_fd_release(net_dev, fd);

Can we reserve "fd" for file descriptors and call this something else?

> +}
> +
> +static void _dpa_tx_error(struct net_device *net_dev,
> +			  const struct dpa_priv_s *priv,
> +			  struct dpa_percpu_priv_s *percpu_priv,
> +			  const struct qm_fd *fd,
> +			  u32 fqid)
> +{
> +	struct sk_buff *skb;
> +
> +	if (net_ratelimit())
> +		netif_warn(priv, hw, net_dev, "FD status = 0x%08x\n",
> +			   fd->status & FM_FD_STAT_TX_ERRORS);
> +
> +	percpu_priv->stats.tx_errors++;
> +
> +	/* If we intended the buffers from this frame to go into the bpools
> +	 * when the FMan transmit was done, we need to put it in manually.
> +	 */
> +	if (fd->bpid != 0xff) {
> +		dpa_fd_release(net_dev, fd);
> +		return;
> +	}

Define a symbolic constant for this special 0xff value.

> +static enum qman_cb_dqrr_result
> +priv_rx_error_dqrr(struct qman_portal *portal,
> +		   struct qman_fq *fq,
> +		   const struct qm_dqrr_entry *dq)
> +{
> +	struct net_device *net_dev;
> +	struct dpa_priv_s *priv;
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int *count_ptr;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;

Don't open-code the casting of one struct to another like this.  Use
container_of().

> +static enum qman_cb_dqrr_result
> +priv_rx_default_dqrr(struct qman_portal *portal,
> +		     struct qman_fq *fq,
> +		     const struct qm_dqrr_entry *dq)
> +{
> +	struct net_device *net_dev;
> +	struct dpa_priv_s *priv;
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int *count_ptr;
> +	struct dpa_bp *dpa_bp;
> +
> +	net_dev = ((struct dpa_fq *)fq)->net_dev;
> +	priv = netdev_priv(net_dev);
> +	dpa_bp = priv->dpa_bp;
> +
> +	/* IRQ handler, non-migratable; safe to use raw_cpu_ptr here */
> +	percpu_priv = raw_cpu_ptr(priv->percpu_priv);
> +	count_ptr = raw_cpu_ptr(dpa_bp->percpu_count);

But why do you *need* to use raw?

> +
> +	if (unlikely(dpaa_eth_napi_schedule(percpu_priv, portal)))
> +		return qman_cb_dqrr_stop;

If this is always an "IRQ handler" then why is it "unlikely" that this
will return non-zero?

> +static const struct dpa_fq_cbs_t private_fq_cbs = {
> +	.rx_defq = { .cb = { .dqrr = priv_rx_default_dqrr } },
> +	.tx_defq = { .cb = { .dqrr = priv_tx_conf_default_dqrr } },
> +	.rx_errq = { .cb = { .dqrr = priv_rx_error_dqrr } },
> +	.tx_errq = { .cb = { .dqrr = priv_tx_conf_error_dqrr } },
> +	.egress_ern = { .cb = { .ern = priv_ern } }
> +};
> +
> +static void dpaa_eth_napi_enable(struct dpa_priv_s *priv)
> +{
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int i, j;
> +
> +	for_each_possible_cpu(i) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
> +
> +		for (j = 0; j < qman_portal_max; j++) {
> +			percpu_priv->np[j].down = 0;
> +			napi_enable(&percpu_priv->np[j].napi);
> +		}
> +	}
> +}
> +
> +static void dpaa_eth_napi_disable(struct dpa_priv_s *priv)
> +{
> +	struct dpa_percpu_priv_s *percpu_priv;
> +	int i, j;
> +
> +	for_each_possible_cpu(i) {
> +		percpu_priv = per_cpu_ptr(priv->percpu_priv, i);
> +
> +		for (j = 0; j < qman_portal_max; j++) {
> +			percpu_priv->np[j].down = 1;
> +			napi_disable(&percpu_priv->np[j].napi);
> +		}
> +	}
> +}

Why ss there a NAPI instance for every combination of portal and cpu,
even though a portal is normally bound to a single cpu?

> +static int
> +dpaa_eth_priv_probe(struct platform_device *pdev)
> +{

Why "priv"?  That makes sense when talking about the data structure, not
in function names.

Also no need for newline after "static int".

> +	int err = 0, i, channel;
> +	struct device *dev;
> +	struct dpa_bp *dpa_bp;
> +	struct dpa_fq *dpa_fq, *tmp;
> +	size_t count = 1;
> +	struct net_device *net_dev = NULL;
> +	struct dpa_priv_s *priv = NULL;
> +	struct dpa_percpu_priv_s *percpu_priv;

What is this "_s"?  If it means "_struct", drop it.

> +	struct fm_port_fqs port_fqs;
> +	struct dpa_buffer_layout_s *buf_layout = NULL;
> +	struct mac_device *mac_dev;
> +	struct task_struct *kth;
> +
> +	dev = &pdev->dev;
> +
> +	/* Get the buffer pool assigned to this interface;
> +	 * run only once the default pool probing code
> +	 */
> +	dpa_bp = (dpa_bpid2pool(dpa_priv_common_bpid)) ? :
> +			dpa_priv_bp_probe(dev);

This is an awkward/non-idiomatic way of saying:

        dpa_bp = dpa_bpid2pool(dpa_priv_common_bpid);
        if (!dpa_bp)
                dpa_bp = dpa_priv_bp_probe(dev);

> +	if (IS_ERR(dpa_bp))
> +		return PTR_ERR(dpa_bp);
> +
> +	/* Allocate this early, so we can store relevant information in
> +	 * the private area
> +	 */
> +	net_dev = alloc_etherdev_mq(sizeof(*priv), DPAA_ETH_TX_QUEUES);
> +	if (!net_dev) {
> +		dev_err(dev, "alloc_etherdev_mq() failed\n");
> +		goto alloc_etherdev_mq_failed;
> +	}
> +
> +#ifdef CONFIG_FSL_DPAA_ETH_FRIENDLY_IF_NAME
> +	snprintf(net_dev->name, IFNAMSIZ, "fm%d-mac%d",
> +		 dpa_mac_fman_index_get(pdev),
> +		 dpa_mac_hw_index_get(pdev));
> +#endif

Is this sort of in-kernel renaming considered acceptable?
Why is it a compile time option?

> +
> +	/* Do this here, so we can be verbose early */
> +	SET_NETDEV_DEV(net_dev, dev);
> +	dev_set_drvdata(dev, net_dev);
> +
> +	priv = netdev_priv(net_dev);
> +	priv->net_dev = net_dev;
> +
> +	priv->msg_enable = netif_msg_init(debug, -1);

This is the only driver that passes -1 as the second argument of
netif_msg_init().  Why?

> +
> +	mac_dev = dpa_mac_dev_get(pdev);
> +	if (IS_ERR(mac_dev) || !mac_dev) {
> +		err = PTR_ERR(mac_dev);
> +		goto mac_probe_failed;
> +	}

When can dpa_mac_dev_get() return NULL rather than an error value?

> +
> +	/* We have physical ports, so we need to establish
> +	 * the buffer layout.
> +	 */
> +	buf_layout = devm_kzalloc(dev, 2 * sizeof(*buf_layout),
> +				  GFP_KERNEL);
> +	if (!buf_layout)
> +		goto alloc_failed;

Why not just make buf_layout a static array in the priv struct?

> +
> +	dpa_set_buffers_layout(mac_dev, buf_layout);
> +
> +	/* For private ports, need to compute the size of the default
> +	 * buffer pool, based on FMan port buffer layout;also update
> +	 * the maximum buffer size for private ports if necessary
> +	 */
> +	dpa_bp->size = dpa_bp_size(&buf_layout[RX]);

What is a "private port", what is the opposite of a private port, and
what does this code do differently for one versus the other?

> +static int __init dpa_load(void)
> +{
> +	int err;
> +
> +	pr_info(DPA_DESCRIPTION "\n");
> +

Don't spam the console just because a driver has been loaded.  Wait until
a device has actually been found.

> +	/* initialise dpaa_eth mirror values */
> +	dpa_rx_extra_headroom = fman_get_rx_extra_headroom();
> +	dpa_max_frm = fman_get_max_frm();
> +
> +	err = platform_driver_register(&dpa_driver);
> +	if (err < 0)
> +		pr_err("Error, platform_driver_register() = %d\n", err);

A user seeing this would wonder what driver's registration failed.

It's a good habit to use __func__ on all output, especially if it's using
pr_xxx rather than dev_xxx.

> +MODULE_LICENSE("Dual BSD/GPL");
> +MODULE_AUTHOR("Andy Fleming <afleming@freescale.com>");
> +MODULE_DESCRIPTION(DPA_DESCRIPTION);

Andy hasn't touched this code in years, and lots of others have worked on
it.  I'm not sure that citing any individual person here makes sense.

> +#define dpa_get_rx_extra_headroom() dpa_rx_extra_headroom
> +#define dpa_get_max_frm() dpa_max_frm

Why?

> +#define DPA_ERR_ON(cond)

So all the DPA_ERR_ON() users are dead code?

> +/* This is what FMan is ever allowed to use.

-EPARSE

> + * FMan-DMA requires 16-byte alignment for Rx buffers, but SKB_DATA_ALIGN is
> + * even stronger (SMP_CACHE_BYTES-aligned), so we just get away with that,
> + * via SKB_WITH_OVERHEAD(). We can't rely on netdev_alloc_frag() giving us
> + * half-page-aligned buffers (can we?), so we reserve some more space
> + * for start-of-buffer alignment.
> + */
> +#define dpa_bp_size(buffer_layout)	(SKB_WITH_OVERHEAD(DPA_BP_RAW_SIZE) - \
> +						SMP_CACHE_BYTES)

The buffer_layout parameter is not used.

> +/* number of Tx queues to FMan */
> +#define DPAA_ETH_TX_QUEUES	NR_CPUS

It would be better to use nr_cpu_ids in the places where dynamic
allocations are possible (and consider reworking the places that use
static arrays to be dynamic).

> +static inline int dpaa_eth_napi_schedule(struct dpa_percpu_priv_s *percpu_priv,
> +					 struct qman_portal *portal)
> +{
> +	/* In case of threaded ISR for RT enable kernel,
> +	 * in_irq() does not return appropriate value, so use
> +	 * in_serving_softirq to distinguish softirq or irq context.
> +	 */
> +	if (unlikely(in_irq() || !in_serving_softirq())) {
> +		/* Disable QMan IRQ and invoke NAPI */
> +		int ret = qman_p_irqsource_remove(portal, QM_PIRQ_DQRI);
> +
> +		if (likely(!ret)) {
> +			const struct qman_portal_config *pc =
> +					qman_p_get_portal_config(portal);
> +			struct dpa_napi_portal *np =
> +					&percpu_priv->np[pc->channel];
> +
> +			np->p = portal;
> +			napi_schedule(&np->napi);
> +			return 1;
> +		}
> +	}
> +	return 0;
> +}

If nearly the entire function is "unlikely", why is anything other than
the if-statement inlined?

s/for RT enable kernel//

> +/* Use the queue selected by XPS */
> +#define dpa_get_queue_mapping(skb) \
> +	skb_get_queue_mapping(skb)

Why is this wrapper needed?

> +int dpa_remove(struct platform_device *pdev)
> +{
> +	int err;
> +	struct device *dev;
> +	struct net_device *net_dev;
> +	struct dpa_priv_s *priv;
> +
> +	dev = &pdev->dev;
> +	net_dev = dev_get_drvdata(dev);
> +
> +	priv = netdev_priv(net_dev);
> +
> +	dev_set_drvdata(dev, NULL);
> +	unregister_netdev(net_dev);
> +
> +	err = dpa_fq_free(dev, &priv->dpa_fq_list);
> +
> +	qman_delete_cgr_safe(&priv->ingress_cgr);
> +	qman_release_cgrid(priv->ingress_cgr.cgrid);
> +	qman_delete_cgr_safe(&priv->cgr_data.cgr);
> +	qman_release_cgrid(priv->cgr_data.cgr.cgrid);
> +
> +	dpa_private_napi_del(net_dev);
> +
> +	dpa_bp_free(priv);
> +
> +	if (priv->buf_layout)
> +		devm_kfree(dev, priv->buf_layout);
> +
> +	free_netdev(net_dev);
> +
> +	return err;
> +}

You don't need to check for NULL before calling kfree(), and you don't
need to call devm_kfree() in a .remove() function.

> +void dpa_set_buffers_layout(struct mac_device *mac_dev,
> +			    struct dpa_buffer_layout_s *layout)
> +{
> +	/* Rx */
> +	layout[RX].priv_data_size = (u16)DPA_RX_PRIV_DATA_SIZE;

Unnecessary cast.

> +	layout[RX].parse_results = true;
> +	layout[RX].hash_results = true;
> +	layout[RX].data_align = DPA_FD_DATA_ALIGNMENT;
> +
> +	/* Tx */
> +	layout[TX].priv_data_size = DPA_TX_PRIV_DATA_SIZE;

...and not even consistent.

> +	layout[TX].parse_results = true;
> +	layout[TX].hash_results = true;
> +	layout[TX].data_align = DPA_FD_DATA_ALIGNMENT;
> +}

When are parse_results/hash_results ever false?

If the answer is in a future patch, why is the mechanism being introduced
in this patch, resulting both in this patch being cluttered, and the
functionality introduced in the future patch being non-self-contained and
thus harder to review?

> +int dpa_fq_probe_mac(struct device *dev, struct list_head *list,
> +		     struct fm_port_fqs *port_fqs,
> +		     bool alloc_tx_conf_fqs,
> +		     enum port_type ptype)
> +{
> +	const struct fqid_cell *fqids;
> +	struct dpa_fq *dpa_fq;
> +	int num_ranges;
> +	int i;
> +
> +	if (ptype == TX && alloc_tx_conf_fqs) {
> +		if (!dpa_fq_alloc(dev, tx_confirm_fqids, list,
> +				  FQ_TYPE_TX_CONF_MQ))
> +			goto fq_alloc_failed;
> +	}
> +
> +	fqids = default_fqids[ptype];
> +	num_ranges = 3;
> +
> +	for (i = 0; i < num_ranges; i++) {
> +		switch (i) {
> +		case 0:
> +			/* The first queue is the error queue */
> +			if (fqids[i].count != 1)
> +				goto invalid_error_queue;
> +
> +			dpa_fq = dpa_fq_alloc(dev, &fqids[i], list,
> +					      ptype == RX ?
> +						FQ_TYPE_RX_ERROR :
> +						FQ_TYPE_TX_ERROR);
> +			if (!dpa_fq)
> +				goto fq_alloc_failed;
> +
> +			if (ptype == RX)
> +				port_fqs->rx_errq = &dpa_fq[0];
> +			else
> +				port_fqs->tx_errq = &dpa_fq[0];
> +			break;
> +		case 1:
> +			/* the second queue is the default queue */
> +			if (fqids[i].count != 1)
> +				goto invalid_default_queue;
> +
> +			dpa_fq = dpa_fq_alloc(dev, &fqids[i], list,
> +					      ptype == RX ?
> +						FQ_TYPE_RX_DEFAULT :
> +						FQ_TYPE_TX_CONFIRM);
> +			if (!dpa_fq)
> +				goto fq_alloc_failed;
> +
> +			if (ptype == RX)
> +				port_fqs->rx_defq = &dpa_fq[0];
> +			else
> +				port_fqs->tx_defq = &dpa_fq[0];
> +			break;
> +		default:
> +			/* all subsequent queues are Tx */
> +			if (!dpa_fq_alloc(dev, &fqids[i], list, FQ_TYPE_TX))
> +				goto fq_alloc_failed;
> +			break;

num_ranges can only be three, so there's only one "subsequent queue" and
this is overly complicated.  Even if eventually num_queues might be
greater than 3, there's no reason to shove the first two queues into a
loop only to use a switch statement to execute completely separate code
for them.

> +	/* Fill in the relevant L4 parse result fields */
> +	switch (l4_proto) {
> +	case IPPROTO_UDP:
> +		parse_result->l4r = FM_L4_PARSE_RESULT_UDP;
> +		break;
> +	case IPPROTO_TCP:
> +		parse_result->l4r = FM_L4_PARSE_RESULT_TCP;
> +		break;
> +	default:
> +		/* This can as well be a BUG() */

No, it can't.  I'm guessing the assumption is that for other protocols,
skb->ip_summed will != CHECKSUM_PARTIAL, but this should at worst be a
rate-limited WARN.   BUG() is for situations where there's no reasonable
path to error out.

> +/* Convenience macros for storing/retrieving the skb back-pointers.
> + *
> + * NB: @off is an offset from a (struct sk_buff **) pointer!
> + */
> +#define DPA_WRITE_SKB_PTR(skb, skbh, addr, off) \
> +	{ \
> +		skbh = (struct sk_buff **)addr; \
> +		*(skbh + (off)) = skb; \
> +	}
> +#define DPA_READ_SKB_PTR(skb, skbh, addr, off) \
> +	{ \
> +		skbh = (struct sk_buff **)addr; \
> +		skb = *(skbh + (off)); \
> +	}
> +

Why can these not be functions?

> +release_bufs:
> +	/* Release the buffers. In case bman is busy, keep trying
> +	 * until successful. bman_release() is guaranteed to succeed
> +	 * in a reasonable amount of time
> +	 */
> +	while (unlikely(bman_release(dpa_bp->pool, bmb, i, 0)))
> +		cpu_relax();

What is a "reasonable amount of time" and what happens if this guarantee
fails?  Usually we have timeouts on such waiting-on-hardware loops so   
that a device failure doesn't turn into a kernel failure.

> +	/* The only FD type that we may receive is contig */
> +	DPA_ERR_ON((fd->format != qm_fd_contig));

Unnecessary parens.

> +_release_frame:
> +	dpa_fd_release(net_dev, fd);
> +}

No leading underscores on goto labels.

> +
> +static int skb_to_contig_fd(struct dpa_priv_s *priv,
> +			    struct sk_buff *skb, struct qm_fd *fd,
> +			    int *count_ptr, int *offset)
> +{
> +	struct sk_buff **skbh;
> +	dma_addr_t addr;
> +	struct dpa_bp *dpa_bp = priv->dpa_bp;
> +	struct net_device *net_dev = priv->net_dev;
> +	int err;
> +	enum dma_data_direction dma_dir;
> +	unsigned char *buffer_start;
> +
> +	{
> +		/* We are guaranteed to have at least tx_headroom bytes
> +		 * available, so just use that for offset.
> +		 */
> +		fd->bpid = 0xff;
> +		buffer_start = skb->data - priv->tx_headroom;
> +		fd->offset = priv->tx_headroom;
> +		dma_dir = DMA_TO_DEVICE;
> +
> +		DPA_WRITE_SKB_PTR(skb, skbh, buffer_start, 0);
> +	}

Why is this block of code inside braces?

> +
> +	/* Enable L3/L4 hardware checksum computation.
> +	 *
> +	 * We must do this before dma_map_single(DMA_TO_DEVICE), because we may
> +	 * need to write into the skb.
> +	 */
> +	err = dpa_enable_tx_csum(priv, skb, fd,
> +				 ((char *)skbh) + DPA_TX_PRIV_DATA_SIZE);
> +	if (unlikely(err < 0)) {
> +		if (net_ratelimit())
> +			netif_err(priv, tx_err, net_dev, "HW csum error: %d\n",
> +				  err);
> +		return err;
> +	}
> +
> +	/* Fill in the rest of the FD fields */
> +	fd->format = qm_fd_contig;
> +	fd->length20 = skb->len;
> +	fd->cmd |= FM_FD_CMD_FCO;
> +
> +	/* Map the entire buffer size that may be seen by FMan, but no more */
> +	addr = dma_map_single(dpa_bp->dev, skbh,
> +			      skb_tail_pointer(skb) - buffer_start, dma_dir);
> +	if (unlikely(dma_mapping_error(dpa_bp->dev, addr))) {
> +		if (net_ratelimit())
> +			netif_err(priv, tx_err, net_dev, "dma_map_single() failed\n");
> +		return -EINVAL;
> +	}
> +	fd->addr_hi = (u8)upper_32_bits(addr);
> +	fd->addr_lo = lower_32_bits(addr);

Why is addr_hi limited to 8 bits?  E.g. t4240 has 40-bit physical
addresses...

-Scott
