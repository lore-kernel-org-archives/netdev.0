From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 1/3] ethernet: Add new driver for Marvell Armada 375
 network unit
Date: Mon, 7 Jul 2014 11:26:53 -0300
Message-ID: <20140707142653.GA18910@arch.cereza>
References: <1404498697-21978-1-git-send-email-ezequiel.garcia@free-electrons.com>
 <1404498697-21978-2-git-send-email-ezequiel.garcia@free-electrons.com>
 <20140705210359.GA19441@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Marcin Wojtas <mw@semihalf.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Tawfik Bayouk <tawfik@marvell.com>,
	Lior Amsalem <alior@marvell.com>, joe@perches.com
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from top.free-electrons.com ([176.31.233.9]:57196 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751661AbaGGO1p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2014 10:27:45 -0400
Content-Disposition: inline
In-Reply-To: <20140705210359.GA19441@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Francois,

=46irst of all, thanks a lot for such a detailed review!

On 05 Jul 11:03 PM, Francois Romieu wrote:
> > diff --git a/drivers/net/ethernet/marvell/mvpp2.c b/drivers/net/eth=
ernet/marvell/mvpp2.c
> > new file mode 100644
> > index 0000000..154b866
> > --- /dev/null
> > +++ b/drivers/net/ethernet/marvell/mvpp2.c
> [...]
> > +static int mvpp2_prs_tcam_first_free(struct mvpp2 *pp2, int start,=
 int end)
> > +{
> > +	int tid;
> > +	bool found =3D false;
> > +
> > +	if (start < end)
> > +		for (tid =3D start; tid <=3D end; tid++) {
> > +			if (!pp2->prs_shadow[tid].valid) {
> > +				found =3D true;
> > +				break;
> > +			}
> > +		}
> > +	else
> > +		for (tid =3D start; tid >=3D end; tid--) {
> > +			if (!pp2->prs_shadow[tid].valid) {
> > +				found =3D true;
> > +				break;
> > +			}
> > +		}
>=20
> Missing parenthsesis in "if ... else ..." block.
>=20
> [...]

Right, I'll do as Joe suggests and use swap() to have just one loop.

> > +static void mvpp2_defaults_set(struct mvpp2_port *pp)
> > +{
> [...]
> > +	/* At default, mask all interrupts to all present cpus */
> > +	for_each_present_cpu(cpu)
> > +		mvpp2_cpu_interrupts_disable(pp, cpu);
>=20
> Would it hurt to issue a single write and disable all irqs ?
>=20

No, that sounds just fine. I'll fix it.

> [...]
> > +static int mvpp2_tx_frag_process(struct mvpp2_port *pp, struct sk_=
buff *skb,
> > +				 struct mvpp2_tx_queue *aggr_txq,
> > +				 struct mvpp2_tx_queue *txq)
> > +{
> [...]
> > +error:
> > +	/* Release all descriptors that were used to map fragments of
> > +	 * this packet, as well as the corresponding DMA mappings
> > +	 */
> > +	for (i =3D i - 1; i >=3D 0; i--) {
>=20
> You may consider "while (--i >=3D 0) {" as an idiom to balance a
> "for (i =3D 0; .." loop. Your call.
>=20

Hm... we've used the same idiom in the mvneta driver so I'd rather keep=
 it
just to have some consistency between the mvneta and the mvpp2 drivers.

> > +		tx_desc =3D txq->descs + i;
> > +		dma_unmap_single(pp->dev->dev.parent,
> > +				 tx_desc->buf_phys_addr,
> > +				 tx_desc->data_size,
> > +				 DMA_TO_DEVICE);
>=20
> 		dma_unmap_single(pp->dev->dev.parent, tx_desc->buf_phys_addr,
> 				 tx_desc->data_size, DMA_TO_DEVICE);
>=20
> You may also factor out mvpp2_dma_unmap_single(pp, tx_desc) or the wh=
ole
> dma_unmap_single + mvpp2_txq_desc_put sequence.
>=20

Refactoring those two sounds a good cleanup.

> [...]
> > +/* Main tx processing */
> > +static int mvpp2_tx(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	struct mvpp2_port *pp =3D netdev_priv(dev);
> > +	struct mvpp2_tx_queue *txq, *aggr_txq;
> > +	struct mvpp2_txq_pcpu *txq_pcpu;
> > +	struct mvpp2_tx_desc *tx_desc;
> > +	dma_addr_t buf_phys_addr;
> > +	int frags =3D 0;
> > +	u16 txq_id;
> > +	u32 tx_cmd;
> > +
> > +	if (!netif_running(dev))
> > +		goto out;
>=20
> The driver is expected to netif_stop_queue when the device goes down,=
 not
> the opposite.
>=20

Right, these netif_running() checks are redundant: the driver already s=
tops
the queues when it goes down, so it seems safe to drop them.

> [...]
> > +static int mvpp2_poll(struct napi_struct *napi, int budget)
> > +{
> > +	u32 cause_rx_tx, cause_rx;
> > +	int rx_done =3D 0;
> > +	struct mvpp2_port *pp =3D netdev_priv(napi->dev);
> > +
> > +	if (!netif_running(pp->dev)) {
> > +		napi_complete(napi);
> > +		return rx_done;
> > +	}
>=20
> Same thing as above.
>=20
> [...]
> > +static int mvpp2_ethtool_set_ringparam(struct net_device *dev,
> > +				       struct ethtool_ringparam *ring)
> > +{
> > +	struct mvpp2_port *pp =3D netdev_priv(dev);
> > +
> > +	if ((ring->rx_pending =3D=3D 0) || (ring->tx_pending =3D=3D 0))
> > +		return -EINVAL;
> > +	pp->rx_ring_size =3D ring->rx_pending < MVPP2_MAX_RXD ?
> > +		ring->rx_pending : MVPP2_MAX_RXD;
> > +	pp->tx_ring_size =3D ring->tx_pending < MVPP2_MAX_TXD ?
> > +		ring->tx_pending : MVPP2_MAX_TXD;
> > +
> > +	if (netif_running(dev)) {
> > +		mvpp2_stop(dev);
> > +		if (mvpp2_open(dev)) {
>=20
> You aren't supposed to (ab)use net_device_ops.{ndo_open / stop} like =
that.
> mvpp2_tx() is still racing with mvpp2_cleanup_txqs(). Even if you go =
through
> the hassle of (1) avoiding this race, then (2) enforcing a safe doubl=
e call
> of mvpp2_stop without any mvpp2_open inbetween, nobody wants its devi=
ce to
> become unresponsive because of a failed ring parameter change: the dr=
iver
> must stop and configure the physical device more gently.
>=20
> Depending on the rework, you may consider postponing ethtool ring cha=
nge to
> a separate patch series.
>=20

Right, we will rework this.

> [...]
> > +static const struct net_device_ops mvpp2_netdev_ops =3D {
> > +	.ndo_open            =3D mvpp2_open,
> > +	.ndo_stop            =3D mvpp2_stop,
> > +	.ndo_start_xmit      =3D mvpp2_tx,
> > +	.ndo_set_rx_mode     =3D mvpp2_set_rx_mode,
> > +	.ndo_set_mac_address =3D mvpp2_set_mac_address,
> > +	.ndo_change_mtu      =3D mvpp2_change_mtu,
> > +	.ndo_get_stats64     =3D mvpp2_get_stats64,
> > +};
>=20
> Please replace spaces by tabs before "=3D".
>=20

Done.

> > +
> > +static const struct ethtool_ops mvpp2_eth_tool_ops =3D {
> > +	.get_link       =3D ethtool_op_get_link,
> > +	.get_settings   =3D mvpp2_ethtool_get_settings,
> > +	.set_settings   =3D mvpp2_ethtool_set_settings,
> > +	.set_coalesce   =3D mvpp2_ethtool_set_coalesce,
> > +	.get_coalesce   =3D mvpp2_ethtool_get_coalesce,
> > +	.get_drvinfo    =3D mvpp2_ethtool_get_drvinfo,
> > +	.get_ringparam  =3D mvpp2_ethtool_get_ringparam,
> > +	.set_ringparam	=3D mvpp2_ethtool_set_ringparam,
> > +};
>=20
> Same as above.
>=20

Done.

> [...]
> > +static int mvpp2_port_init(struct mvpp2_port *pp)
> > +{
> > +	struct device *dev =3D pp->dev->dev.parent;
> > +	struct mvpp2 *pp2 =3D pp->pp2;
> > +	struct mvpp2_txq_pcpu *txq_pcpu;
> > +	int queue, txp, cpu;
> > +
> > +	if (pp->first_rxq + rxq_number > MVPP2_RXQ_TOTAL_NUM)
> > +		return -EINVAL;
> > +
> > +	/* Disable port */
> > +	mvpp2_egress_disable(pp);
> > +	mvpp2_port_disable(pp);
> > +
> > +	pp->txqs =3D devm_kzalloc(dev, pp->txp_num * txq_number *
> > +				sizeof(struct mvpp2_tx_queue *), GFP_KERNEL);
> > +	if (!pp->txqs)
> > +		return -ENOMEM;
> > +
> > +	/* Associate physical Tx queues to this port and initialize.
> > +	 * The mapping is predefined.
> > +	 */
> > +	for (txp =3D 0; txp < pp->txp_num; txp++) {
> > +		for (queue =3D 0; queue < txq_number; queue++) {
> > +			int txq_idx =3D txp * txq_number + queue;
> > +			int queue_phy_id =3D mvpp2_txq_phys(pp->id, queue);
> > +			struct mvpp2_tx_queue *txq;
> > +
> > +			txq =3D devm_kzalloc(dev, sizeof(*txq), GFP_KERNEL);
> > +			if (!txq)
> > +				return -ENOMEM;
> > +
> > +			txq->pcpu =3D alloc_percpu(struct mvpp2_txq_pcpu);
> > +			if (!txq->pcpu)
> > +				return -ENOMEM;
>=20
> There is a per_cpu leak if mvpp2_port_init fails.
>=20

Yes, good catch.

> [...]
> > +/* Ports initialization */
> > +static int mvpp2_port_probe(struct platform_device *pdev,
> > +			    struct device_node *port_node,
> > +			    struct mvpp2 *pp2,
> > +			    int *next_first_rxq)
> > +{
> > +	struct device_node *phy_node;
> > +	struct mvpp2_port *pp;
>=20
> (nit below)
>=20
> I am not a huge fan of the "pp2" variable as there's no "pp1" but I'v=
e seen
> worse. However naming "pp" some completely unrelated data imho verges=
 on
> confusing
>=20

Hm, yes, I see what you mean. These names bother me too, and I think we=
 could
probably change it so "pp2" is "dev", and "pp" is "port". But on the ot=
her
side, I'm not sure it's worth doing such an intrusive change just to fi=
x these
names.

What do you think?

> [...]
> > +	dev->irq =3D irq_of_parse_and_map(port_node, 0);
> > +	if (dev->irq =3D=3D 0) {
> > +		err =3D -EINVAL;
> > +		goto err_free_netdev;
> > +	}
>=20
> net_device.irq should be considered legacy. It would be nice to avoid
> more uses of it. You may store it near pp->base for instance.
>=20

Done.

Thanks a lot for the feedback!
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
