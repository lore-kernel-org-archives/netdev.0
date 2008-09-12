From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 2/3] enic: add main netdev file with module
	infrastructure
Date: Fri, 12 Sep 2008 20:47:51 +0100
Message-ID: <1221248871.3244.69.camel@achroite>
References: <Pine.LNX.4.64.0809082051080.18196@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: Scott Feldman <scofeldm@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34339 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754671AbYILTrz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Sep 2008 15:47:55 -0400
In-Reply-To: <Pine.LNX.4.64.0809082051080.18196@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-08 at 20:57 -0700, Scott Feldman wrote:
[...]
> diff -Naurp -X linux-2.6.26.3/Documentation/dontdiff linux-2.6.26.3/d=
rivers/net/enic/enic_main.c linux-2.6.26.3-enic/drivers/net/enic/enic_m=
ain.c
> --- linux-2.6.26.3/drivers/net/enic/enic_main.c	1969-12-31 16:00:00.0=
00000000 -0800
> +++ linux-2.6.26.3-enic/drivers/net/enic/enic_main.c	2008-09-08 15:16=
:23.000000000 -0700
[...]
> +static int enic_set_rx_csum(struct net_device *netdev, u32 data)
> +{
> +	struct enic *enic =3D netdev_priv(netdev);
> +
> +	enic->csum_rx_enabled =3D
> +		(data && ENIC_SETTING(enic, RXCSUM)) ? 1 : 0;
> +
> +	return 0;
> +}

This should return an error code if it can't enable RX checksum:

	if (data && !ENIC_SETTING(enic, RXCSUM))
		return -EOPNOTSUPP;
	enic->csum_rx_enabled =3D !!data;
	return 0;

(I'm not sure what the correct error code is in this situation though.)

> +static int enic_set_tx_csum(struct net_device *netdev, u32 data)
> +{
> +	struct enic *enic =3D netdev_priv(netdev);
> +
> +	if (data && ENIC_SETTING(enic, TXCSUM))
> +		netdev->features |=3D NETIF_F_HW_CSUM;
> +	else
> +		netdev->features &=3D ~NETIF_F_HW_CSUM;
> +
> +	return 0;
> +}

Similarly here.

[...]
> +static struct ethtool_ops enic_ethtool_ops =3D {
> +	.get_settings =3D enic_get_settings,
> +	.get_drvinfo =3D enic_get_drvinfo,
> +	.get_msglevel =3D enic_get_msglevel,
> +	.set_msglevel =3D enic_set_msglevel,
> +	.get_link =3D ethtool_op_get_link,
> +	.get_strings =3D enic_get_strings,
> +	.get_stats_count =3D enic_get_stats_count,

get_stats_count is deprecated; you should implement get_sset_count.

[...]
> +static int enic_wq_service(struct vnic_dev *vdev, struct cq_desc *cq=
_desc,
> +	u8 type, u16 q_number, u16 completed_index, void *opaque)
> +{
> +	struct enic *enic =3D vnic_dev_priv(vdev);
> +
> +	spin_lock(&enic->wq_lock[q_number]);
> +
> +	vnic_wq_service(&enic->wq[q_number], cq_desc,
> +		completed_index, enic_wq_free_buf,
> +		opaque);
> +
> +	if (netif_queue_stopped(enic->netdev) &&
> +	    vnic_wq_desc_avail(&enic->wq[q_number]) >=3D MAX_SKB_FRAGS + 1)
> +		netif_wake_queue(enic->netdev);

The call to netif_queue_stopped() seems redundant since
netif_wake_queue() starts by checking the same thing.

> +	spin_unlock(&enic->wq_lock[q_number]);
> +
> +	return 0;
> +}
[...]
> +/* dev_base_lock rwlock held, nominally process context */
> +static struct net_device_stats *enic_get_stats(struct net_device *ne=
tdev)
> +{
> +	struct enic *enic =3D netdev_priv(netdev);
> +	struct vnic_stats *stats;
> +
> +	spin_lock(&enic->devcmd_lock);
> +	vnic_dev_stats_dump(enic->vdev, &stats);
> +	spin_unlock(&enic->devcmd_lock);
> +
> +	enic->net_stats.tx_packets =3D stats->tx.tx_frames_ok;
> +	enic->net_stats.tx_bytes =3D stats->tx.tx_bytes_ok;
> +	enic->net_stats.tx_errors =3D stats->tx.tx_errors;
> +	enic->net_stats.tx_dropped =3D stats->tx.tx_drops;
> +
> +	enic->net_stats.rx_packets =3D stats->rx.rx_frames_ok;
> +	enic->net_stats.rx_bytes =3D stats->rx.rx_bytes_ok;
> +	enic->net_stats.rx_errors =3D stats->rx.rx_errors;
> +	enic->net_stats.multicast =3D stats->rx.rx_multicast_frames_ok;
> +	enic->net_stats.rx_crc_errors =3D stats->rx.rx_crc_errors;
> +	enic->net_stats.rx_dropped =3D stats->rx.rx_no_bufs;
> +
> +	return &enic->net_stats;
> +}

Why not use netdev->stats?

> +/* netif_tx_lock held, BHs disabled */
> +static void enic_set_multicast_list(struct net_device *netdev)
> +{
> +	struct enic *enic =3D netdev_priv(netdev);
> +	struct dev_mc_list *list =3D netdev->mc_list;
> +	int directed =3D 1;
> +	int multicast =3D (netdev->flags & IFF_MULTICAST) ? 1 : 0;
> +	int broadcast =3D (netdev->flags & IFF_BROADCAST) ? 1 : 0;
> +	int promisc =3D (netdev->flags & IFF_PROMISC) ? 1 : 0;
> +	int allmulti =3D (netdev->flags & IFF_ALLMULTI) ||
> +	    (netdev->mc_count > ENIC_MULTICAST_PERFECT_FILTERS);
> +	u8 mc_addr[ENIC_MULTICAST_PERFECT_FILTERS][ETH_ALEN];
> +	unsigned int mc_count =3D netdev->mc_count;
> +	unsigned int i, j;
> +
> +	if (mc_count > ENIC_MULTICAST_PERFECT_FILTERS)
> +		mc_count =3D ENIC_MULTICAST_PERFECT_FILTERS;
> +
> +	spin_lock(&enic->devcmd_lock);
> +
> +	vnic_dev_packet_filter(enic->vdev, directed,
> +		multicast, broadcast, promisc, allmulti);
> +
> +	/* Is there an easier way?  Trying to minimize to
> +	 * calls to add/del multicast addrs.  We keep the
> +	 * addrs from the last call in enic->mc_addr and
> +	 * look for changes to add/del.
> +	 */

If you sort the table then the following comparison can be done with a
single loop.  But then you move the complexity to the sort itself.  And
it doesn't really seem worth doing that for at most 32 addresses.

> +static int enic_get_skb_header(struct sk_buff *skb, void **iphdr,
> +	void **tcph, u64 *hdr_flags, void *priv)
> +{
> +	struct cq_enet_rq_desc *cq_desc =3D priv;
> +	unsigned int ip_len;
> +	struct iphdr *iph;
> +
> +	u8 type, color, eop, sop, ingress_port, vlan_stripped;
> +	u8 fcoe, fcoe_sof, fcoe_fc_crc_ok, fcoe_enc_error, fcoe_eof;
> +	u8 tcp_udp_csum_ok, udp, tcp, ipv4_csum_ok;
> +	u8 ipv6, ipv4, ipv4_fragment, fcs_ok, rss_type, csum_not_calc;
> +	u8 packet_error;
> +	u16 q_number, completed_index, bytes_written, vlan, checksum;
> +	u32 rss_hash;
> +
> +	cq_enet_rq_desc_dec(cq_desc,
> +		&type, &color, &q_number, &completed_index,
> +		&ingress_port, &fcoe, &eop, &sop, &rss_type,
> +		&csum_not_calc, &rss_hash, &bytes_written,
> +		&packet_error, &vlan_stripped, &vlan, &checksum,
> +		&fcoe_sof, &fcoe_fc_crc_ok, &fcoe_enc_error,
> +		&fcoe_eof, &tcp_udp_csum_ok, &udp, &tcp,
> +		&ipv4_csum_ok, &ipv6, &ipv4, &ipv4_fragment,
> +		&fcs_ok);

I don't know where that function is defined, but it's badly designed.
It will be easy to get the order of arguments wrong and the compiler
will probably not help because most of them have the same type.  It is
probably better to define a structure to hold all these attributes.

> +	if (!(ipv4 && tcp && !ipv4_fragment))
> +		return -1;
> +
> +	skb_reset_network_header(skb);
> +	iph =3D ip_hdr(skb);
> +
> +	ip_len =3D ip_hdrlen(skb);
> +	skb_set_transport_header(skb, ip_len);
> +
> +	/* check if ip header and tcp header are complete */
> +	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
> +		return -1;
> +
> +	*hdr_flags =3D LRO_IPV4 | LRO_TCP;
> +	*tcph =3D tcp_hdr(skb);
> +	*iphdr =3D iph;
> +
> +	return 0;
> +}
[...]
> +static void enic_rq_indicate_buf(struct vnic_rq *rq,
> +	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
> +	int skipped, void *opaque)
> +{
> +	struct enic *enic =3D vnic_dev_priv(rq->vdev);
> +	struct sk_buff *skb;
> +
> +	u8 type, color, eop, sop, ingress_port, vlan_stripped;
> +	u8 fcoe, fcoe_sof, fcoe_fc_crc_ok, fcoe_enc_error, fcoe_eof;
> +	u8 tcp_udp_csum_ok, udp, tcp, ipv4_csum_ok;
> +	u8 ipv6, ipv4, ipv4_fragment, fcs_ok, rss_type, csum_not_calc;
> +	u8 packet_error;
> +	u16 q_number, completed_index, bytes_written, vlan, checksum;
> +	u32 rss_hash;
> +
> +	if (skipped)
> +		return;
> +
> +	skb =3D buf->os_buf;
> +	prefetch(skb->data - NET_IP_ALIGN);
> +	pci_unmap_single(enic->pdev, buf->dma_addr,
> +		buf->len, PCI_DMA_FROMDEVICE);
> +
> +	cq_enet_rq_desc_dec((struct cq_enet_rq_desc *)cq_desc,
> +		&type, &color, &q_number, &completed_index,
> +		&ingress_port, &fcoe, &eop, &sop, &rss_type,
> +		&csum_not_calc, &rss_hash, &bytes_written,
> +		&packet_error, &vlan_stripped, &vlan, &checksum,
> +		&fcoe_sof, &fcoe_fc_crc_ok, &fcoe_enc_error,
> +		&fcoe_eof, &tcp_udp_csum_ok, &udp, &tcp,
> +		&ipv4_csum_ok, &ipv6, &ipv4, &ipv4_fragment,
> +		&fcs_ok);
> +
> +	if (packet_error) {
> +
> +		if (bytes_written > 0 && !fcs_ok) {
> +			if (net_ratelimit())
> +				printk(KERN_ERR PFX
> +					"%s: packet error: bad FCS\n",
> +					enic->netdev->name);
> +		}
> +
> +		dev_kfree_skb_any(skb);
> +
> +		return;
> +	}
> +
> +	if (eop && bytes_written > 0) {
> +
> +		/* Good receive
> +		 */
> +
> +		skb_put(skb, bytes_written);
> +		skb->protocol =3D eth_type_trans(skb, enic->netdev);
> +
> +		if (enic->csum_rx_enabled && !csum_not_calc) {
> +			skb->csum =3D htons(checksum);
> +			skb->ip_summed =3D CHECKSUM_COMPLETE;
> +		}
> +
> +		skb->dev =3D enic->netdev;
> +		enic->netdev->last_rx =3D jiffies;
> +
> +		if (enic->vlan_group && vlan_stripped) {
> +
> +			if (ENIC_SETTING(enic, LRO))
> +				lro_vlan_hwaccel_receive_skb(&enic->lro_mgr,
> +					skb, enic->vlan_group,
> +					vlan, cq_desc);
> +			else
> +				vlan_hwaccel_receive_skb(skb,
> +					enic->vlan_group, vlan);
> +
> +		} else {
> +
> +			if (ENIC_SETTING(enic, LRO))
> +				lro_receive_skb(&enic->lro_mgr, skb, cq_desc);
> +			else
> +				netif_receive_skb(skb);
> +
> +		}
> +
> +	} else {
> +
> +		/* Buffer overflow
> +		 */
> +
> +		dev_kfree_skb_any(skb);
> +	}

Why so much vertical whitespace?  It doesn't make this easier to read;
on the contrary, it's harder to see the whole function.

[...]
> +static void enic_notify_timer(unsigned long data)
> +{
> +	struct enic *enic =3D (struct enic *)data;
> +
> +	enic_notify_check(enic);
> +
> +	mod_timer(&enic->notify_timer, round_jiffies(ENIC_NOTIFY_TIMER_PERI=
OD));

You want =EF=BB=BFround_jiffies_relative() not round_jiffies().

> +}
[...]
> +static void enic_notify_timer_start(struct enic *enic)
> +{
> +	switch (vnic_dev_get_intr_mode(enic->vdev)) {
> +	case VNIC_DEV_INTR_MODE_MSI:
> +		mod_timer(&enic->notify_timer, jiffies);

Do you really want this to run immediately?

> +		break;
> +	default:
> +		/* Using intr for notification for INTx/MSI-X */
> +		break;
> +	};
> +}
[...]
> +static int enic_change_mtu(struct net_device *netdev, int new_mtu)
> +{
> +	struct enic *enic =3D netdev_priv(netdev);
> +	int running =3D netif_running(netdev);
> +
> +	if (running)
> +		enic_stop(netdev);
> +
> +	if (new_mtu < ENIC_MIN_MTU)
> +		new_mtu =3D ENIC_MIN_MTU;
> +	if (new_mtu > ENIC_MAX_MTU)
> +		new_mtu =3D ENIC_MAX_MTU;

Don't silently adjust an MTU that's out of the supported range; return
-EINVAL.

> +	netdev->mtu =3D new_mtu;
> +
> +	if (netdev->mtu > enic->port_mtu)
> +		printk(KERN_WARNING PFX
> +			"%s: interface MTU (%d) set higher "
> +			"than port MTU (%d)\n",
> +			netdev->name, netdev->mtu, enic->port_mtu);
> +
> +	if (running)
> +		enic_open(netdev);
> +
> +	return 0;
> +}
[...]
> +static int enic_dev_soft_reset(struct enic *enic)
> +{
> +	int err;
> +
> +	err =3D enic_dev_wait(enic->vdev, vnic_dev_soft_reset,
> +		vnic_dev_soft_reset_done, 0);
> +	if (err)
> +		printk(KERN_ERR PFX
> +			"vNIC soft reset failed, err %d.\n", err);
> +
> +	return err;
> +}
> +
> +static void enic_reset(struct work_struct *work)
> +{
> +	struct enic *enic =3D container_of(work, struct enic, reset);
> +
> +	if (!netif_running(enic->netdev))
> +		return;
> +
> +	rtnl_lock();
> +
> +	spin_lock(&enic->devcmd_lock);
> +	vnic_dev_hang_notify(enic->vdev);
> +	spin_unlock(&enic->devcmd_lock);
> +
> +	enic_stop(enic->netdev);
> +	enic_dev_soft_reset(enic);

What if the soft reset fails?

> +	enic_reset_mcaddrs(enic);
> +	enic_init_vnic_resources(enic);
> +	enic_open(enic->netdev);
> +
> +	rtnl_unlock();
> +}
[...]

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

