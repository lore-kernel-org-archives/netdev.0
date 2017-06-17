From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH V3 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 17 Jun 2017 21:41:37 +0200
Message-ID: <20170617194137.GC1974@lunn.ch>
References: <20170617172431.177044-1-salil.mehta@huawei.com>
 <20170617172431.177044-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, yisen.zhuang@huawei.com,
        huangdaode@hisilicon.com, lipeng321@huawei.com,
        mehta.salil.lnk@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:52637 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752290AbdFQTlp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 17 Jun 2017 15:41:45 -0400
Content-Disposition: inline
In-Reply-To: <20170617172431.177044-2-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +
> +	for (i = 0; i < priv->vector_num; i++) {
> +		tqp_vectors = &priv->tqp_vector[i];
> +
> +		if (tqp_vectors->irq_init_flag == HNS3_VEVTOR_INITED)

Should VEVTOR be VECTOR?


> +static void hns3_set_vector_gl(struct hns3_enet_tqp_vector *tqp_vector,
> +			       u32 gl_value)
> +{
> +	writel(gl_value, tqp_vector->mask_addr + HNS3_VECTOR_GL0_OFFSET);
> +	writel(gl_value, tqp_vector->mask_addr + HNS3_VECTOR_GL1_OFFSET);
> +	writel(gl_value, tqp_vector->mask_addr + HNS3_VECTOR_GL2_OFFSET);
> +}
> +
> +static void hns3_set_vector_rl(struct hns3_enet_tqp_vector *tqp_vector,
> +			       u32 rl_value)

Could you use more informative names. What does gl and rl mean?

> +{
> +	writel(rl_value, tqp_vector->mask_addr + HNS3_VECTOR_RL_OFFSET);
> +}
> +
> +static void hns3_vector_gl_rl_init(struct hns3_enet_tqp_vector *tqp_vector)
> +{
> +	/* Default :enable interrupt coalesce */
> +	tqp_vector->rx_group.int_gl = HNS3_INT_GL_50K;
> +	tqp_vector->tx_group.int_gl = HNS3_INT_GL_50K;
> +	hns3_set_vector_gl(tqp_vector, HNS3_INT_GL_50K);
> +	hns3_set_vector_rl(tqp_vector, 0);
> +	tqp_vector->rx_group.flow_level = HNS3_FLOW_LOW;
> +	tqp_vector->tx_group.flow_level = HNS3_FLOW_LOW;
> +}
> +
> +static int hns3_nic_net_up(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int i, j;
> +	int ret;
> +
> +	ret = hns3_nic_init_irq(priv);
> +	if (ret != 0) {
> +		netdev_err(ndev, "hns init irq failed! ret=%d\n", ret);
> +		return ret;
> +	}
> +
> +	for (i = 0; i < priv->vector_num; i++)
> +		hns3_vector_enable(&priv->tqp_vector[i]);
> +
> +	ret = h->ae_algo->ops->start ? h->ae_algo->ops->start(h) : 0;
> +	if (ret)
> +		goto out_start_err;
> +
> +	return 0;
> +
> +out_start_err:
> +	netif_stop_queue(ndev);

This seems asymmetric. Where is the netif_start_queue()?

> +
> +	for (j = i - 1; j >= 0; j--)
> +		hns3_vector_disable(&priv->tqp_vector[j]);
> +
> +	return ret;
> +}
> +
> +static int hns3_nic_net_open(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int ret;
> +
> +	netif_carrier_off(ndev);
> +
> +	ret = netif_set_real_num_tx_queues(ndev, h->kinfo.num_tqps);
> +	if (ret < 0) {
> +		netdev_err(ndev, "netif_set_real_num_tx_queues fail, ret=%d!\n",
> +			   ret);
> +		return ret;
> +	}
> +
> +	ret = netif_set_real_num_rx_queues(ndev, h->kinfo.num_tqps);
> +	if (ret < 0) {
> +		netdev_err(ndev,
> +			   "netif_set_real_num_rx_queues fail, ret=%d!\n", ret);
> +		return ret;
> +	}
> +
> +	ret = hns3_nic_net_up(ndev);
> +	if (ret) {
> +		netdev_err(ndev,
> +			   "hns net up fail, ret=%d!\n", ret);
> +		return ret;
> +	}
> +
> +	netif_carrier_on(ndev);

Carrier on should be performed when the PHY says there is link.

> +	netif_tx_wake_all_queues(ndev);
> +
> +	return 0;
> +}
> +
> +static void hns3_nic_net_down(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_ae_ops *ops;
> +	int i;
> +
> +	netif_tx_stop_all_queues(ndev);
> +	netif_carrier_off(ndev);
> +
> +	ops = priv->ae_handle->ae_algo->ops;
> +
> +	if (ops->stop)
> +		ops->stop(priv->ae_handle);
> +
> +	for (i = 0; i < priv->vector_num; i++)
> +		hns3_vector_disable(&priv->tqp_vector[i]);
> +}
> +
> +static int hns3_nic_net_stop(struct net_device *ndev)
> +{
> +	hns3_nic_net_down(ndev);
> +
> +	return 0;
> +}
> +
> +void hns3_set_multicast_list(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	struct netdev_hw_addr *ha = NULL;
> +
> +	if (!h)	{
> +		netdev_err(ndev, "hnae handle is null\n");
> +		return;
> +	}
> +
> +	if (h->ae_algo->ops->set_mc_addr) {
> +		netdev_for_each_mc_addr(ha, ndev)
> +			if (h->ae_algo->ops->set_mc_addr(h, ha->addr))
> +				netdev_err(ndev, "set multicast fail\n");
> +	}
> +}
> +
> +static int hns3_nic_uc_sync(struct net_device *netdev,
> +			    const unsigned char *addr)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (h->ae_algo->ops->add_uc_addr)
> +		return h->ae_algo->ops->add_uc_addr(h, addr);
> +
> +	return 0;
> +}
> +
> +static int hns3_nic_uc_unsync(struct net_device *netdev,
> +			      const unsigned char *addr)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (h->ae_algo->ops->rm_uc_addr)
> +		return h->ae_algo->ops->rm_uc_addr(h, addr);
> +
> +	return 0;
> +}
> +
> +static int hns3_nic_mc_sync(struct net_device *netdev,
> +			    const unsigned char *addr)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (h->ae_algo->ops->add_uc_addr)
> +		return h->ae_algo->ops->add_mc_addr(h, addr);
> +
> +	return 0;
> +}
> +
> +static int hns3_nic_mc_unsync(struct net_device *netdev,
> +			      const unsigned char *addr)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (h->ae_algo->ops->rm_uc_addr)
> +		return h->ae_algo->ops->rm_mc_addr(h, addr);
> +
> +	return 0;
> +}
> +
> +void hns3_nic_set_rx_mode(struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (h->ae_algo->ops->set_promisc_mode) {
> +		if (ndev->flags & IFF_PROMISC)
> +			h->ae_algo->ops->set_promisc_mode(h, 1);
> +		else
> +			h->ae_algo->ops->set_promisc_mode(h, 0);
> +	}
> +	if (__dev_uc_sync(ndev, hns3_nic_uc_sync, hns3_nic_uc_unsync))
> +		netdev_err(ndev, "sync uc address fail\n");
> +	if (ndev->flags & IFF_MULTICAST)
> +		if (__dev_mc_sync(ndev, hns3_nic_mc_sync, hns3_nic_mc_unsync))
> +			netdev_err(ndev, "sync mc address fail\n");
> +}
> +
> +static int hns3_set_tso(struct sk_buff *skb, u32 *paylen,
> +			u16 *mss, u32 *type_cs_vlan_tso)
> +{
> +	union {
> +		struct iphdr *v4;
> +		struct ipv6hdr *v6;
> +		unsigned char *hdr;
> +	} l3;

You have this repeated a few times. Might be better to pull it out
into a header file.

> +	union {
> +		struct tcphdr *tcp;
> +		struct udphdr *udp;
> +		unsigned char *hdr;
> +	} l4;

You can probably pull this out as well, or maybe the version with the
gre header.

> +static int hns3_fill_desc(struct hns3_enet_ring *ring, void *priv,
> +			  int size, dma_addr_t dma, int frag_end,
> +			  enum hns_desc_type type)
> +{
> +	struct hns3_desc_cb *desc_cb = &ring->desc_cb[ring->next_to_use];
> +	struct hns3_desc *desc = &ring->desc[ring->next_to_use];
> +	u32 ol_type_vlan_len_msec = 0;
> +	u16 bdtp_fe_sc_vld_ra_ri = 0;
> +	u32 type_cs_vlan_tso = 0;
> +	struct sk_buff *skb;
> +	u32 paylen = 0;
> +	u16 mss = 0;
> +	__be16 protocol;
> +	u8 ol4_proto;
> +	u8 il4_proto;
> +	int ret;
> +
> +	/* The txbd's baseinfo of DESC_TYPE_PAGE & DESC_TYPE_SKB */
> +	desc_cb->priv = priv;
> +	desc_cb->length = size;
> +	desc_cb->dma = dma;
> +	desc_cb->type = type;
> +
> +	/* now, fill the descriptor */
> +	desc->addr = cpu_to_le64(dma);
> +	desc->tx.send_size = cpu_to_le16((u16)size);
> +	hns3_set_txbd_baseinfo(&bdtp_fe_sc_vld_ra_ri, frag_end);
> +	desc->tx.bdtp_fe_sc_vld_ra_ri = cpu_to_le16(bdtp_fe_sc_vld_ra_ri);
> +
> +	if (type == DESC_TYPE_SKB) {
> +		skb = (struct sk_buff *)priv;
> +		paylen = cpu_to_le16(skb->len);
> +
> +		if (skb->ip_summed == CHECKSUM_PARTIAL) {
> +			skb_reset_mac_len(skb);
> +			protocol = skb->protocol;
> +
> +			/* vlan packe t*/
> +			if (protocol == htons(ETH_P_8021Q)) {
> +				protocol = vlan_get_protocol(skb);
> +				skb->protocol = protocol;
> +			}
> +			hns3_get_l4_protocol(skb, &ol4_proto, &il4_proto);
> +			hns3_set_l2l3l4_len(skb, ol4_proto, il4_proto,
> +					    &type_cs_vlan_tso,
> +					    &ol_type_vlan_len_msec);
> +			ret = hns3_set_l3l4_type_csum(skb, ol4_proto, il4_proto,
> +						      &type_cs_vlan_tso,
> +						      &ol_type_vlan_len_msec);
> +			if (ret)
> +				return ret;
> +
> +			ret = hns3_set_tso(skb, &paylen, &mss,
> +					   &type_cs_vlan_tso);
> +			if (ret)
> +				return ret;
> +		}
> +
> +		/* Set txbd */
> +		desc->tx.ol_type_vlan_len_msec =
> +			cpu_to_le32(ol_type_vlan_len_msec);
> +		desc->tx.type_cs_vlan_tso_len =
> +			cpu_to_le32(type_cs_vlan_tso);
> +		desc->tx.paylen = cpu_to_le16(paylen);
> +		desc->tx.mss = cpu_to_le16(mss);
> +	}
> +
> +	/* move ring pointer to next.*/
> +	ring_ptr_move_fw(ring, next_to_use);
> +
> +	return 0;
> +}
> +
> +static int hns3_fill_desc_tso(struct hns3_enet_ring *ring, void *priv,
> +			      int size, dma_addr_t dma, int frag_end,
> +			      enum hns_desc_type type)
> +{
> +	int frag_buf_num;
> +	int sizeoflast;
> +	int ret, k;
> +
> +	frag_buf_num = (size + HNS3_MAX_BD_SIZE - 1) / HNS3_MAX_BD_SIZE;
> +	sizeoflast = size % HNS3_MAX_BD_SIZE;
> +	sizeoflast = sizeoflast ? sizeoflast : HNS3_MAX_BD_SIZE;
> +
> +	/* When the frag size is bigger than hardware, split this frag */
> +	for (k = 0; k < frag_buf_num; k++) {
> +		ret = hns3_fill_desc(ring, priv,
> +				     (k == frag_buf_num - 1) ?
> +				sizeoflast : HNS3_MAX_BD_SIZE,
> +				dma + HNS3_MAX_BD_SIZE * k,
> +				frag_end && (k == frag_buf_num - 1) ? 1 : 0,
> +				(type == DESC_TYPE_SKB && !k) ?
> +					DESC_TYPE_SKB : DESC_TYPE_PAGE);
> +		if (ret)
> +			return ret;
> +	}
> +
> +	return 0;
> +}
> +
> +static int hns3_nic_maybe_stop_tso(struct sk_buff **out_skb, int *bnum,
> +				   struct hns3_enet_ring *ring)
> +{
> +	struct sk_buff *skb = *out_skb;
> +	struct skb_frag_struct *frag;
> +	int bdnum_for_frag;
> +	int frag_num;
> +	int buf_num;
> +	int size;
> +	int i;
> +
> +	size = skb_headlen(skb);
> +	buf_num = (size + HNS3_MAX_BD_SIZE - 1) / HNS3_MAX_BD_SIZE;
> +
> +	frag_num = skb_shinfo(skb)->nr_frags;
> +	for (i = 0; i < frag_num; i++) {
> +		frag = &skb_shinfo(skb)->frags[i];
> +		size = skb_frag_size(frag);
> +		bdnum_for_frag =
> +			(size + HNS3_MAX_BD_SIZE - 1) / HNS3_MAX_BD_SIZE;
> +		if (bdnum_for_frag > HNS3_MAX_BD_PER_FRAG)
> +			return -ENOMEM;
> +
> +		buf_num += bdnum_for_frag;
> +	}
> +
> +	if (buf_num > ring_space(ring))
> +		return -EBUSY;
> +
> +	*bnum = buf_num;
> +	return 0;
> +}
> +
> +static int hns3_nic_maybe_stop_tx(struct sk_buff **out_skb, int *bnum,
> +				  struct hns3_enet_ring *ring)
> +{
> +	struct sk_buff *skb = *out_skb;
> +	int buf_num;
> +
> +	/* No. of segments (plus a header) */
> +	buf_num = skb_shinfo(skb)->nr_frags + 1;
> +
> +	if (buf_num > ring_space(ring))
> +		return -EBUSY;
> +
> +	*bnum = buf_num;
> +
> +	return 0;
> +}
> +
> +static void hns_nic_dma_unmap(struct hns3_enet_ring *ring, int next_to_use_orig)
> +{
> +	struct device *dev = ring_to_dev(ring);
> +
> +	while (1) {
> +		/* check if this is where we started */
> +		if (ring->next_to_use == next_to_use_orig)
> +			break;
> +
> +		/* unmap the descriptor dma address */
> +		if (ring->desc_cb[ring->next_to_use].type == DESC_TYPE_SKB)
> +			dma_unmap_single(dev,
> +					 ring->desc_cb[ring->next_to_use].dma,
> +					ring->desc_cb[ring->next_to_use].length,
> +					DMA_TO_DEVICE);
> +		else
> +			dma_unmap_page(dev,
> +				       ring->desc_cb[ring->next_to_use].dma,
> +				       ring->desc_cb[ring->next_to_use].length,
> +				       DMA_TO_DEVICE);
> +
> +		/* rollback one */
> +		ring_ptr_move_bw(ring, next_to_use);
> +	}
> +}
> +
> +int hns3_nic_net_xmit_hw(struct net_device *ndev,
> +			 struct sk_buff *skb,
> +			 struct hns3_nic_ring_data *ring_data)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hns3_enet_ring *ring = ring_data->ring;
> +	struct device *dev = priv->dev;
> +	struct netdev_queue *dev_queue;
> +	struct skb_frag_struct *frag;
> +	int next_to_use_head;
> +	int next_to_use_frag;
> +	dma_addr_t dma;
> +	int buf_num;
> +	int seg_num;
> +	int size;
> +	int ret;
> +	int i;
> +
> +	if (!skb || !ring)
> +		return -ENOMEM;
> +
> +	/* Prefetch the data used later */
> +	prefetch(skb->data);
> +
> +	switch (priv->ops.maybe_stop_tx(&skb, &buf_num, ring)) {
> +	case -EBUSY:
> +		ring->stats.tx_busy++;
> +		goto out_net_tx_busy;
> +	case -ENOMEM:
> +		ring->stats.sw_err_cnt++;
> +		netdev_err(ndev, "no memory to xmit!\n");
> +		goto out_err_tx_ok;
> +	default:
> +		break;
> +	}
> +
> +	/* No. of segments (plus a header) */
> +	seg_num = skb_shinfo(skb)->nr_frags + 1;
> +	/* Fill the first part */
> +	size = skb_headlen(skb);
> +
> +	next_to_use_head = ring->next_to_use;
> +
> +	dma = dma_map_single(dev, skb->data, size, DMA_TO_DEVICE);
> +	if (dma_mapping_error(dev, dma)) {
> +		netdev_err(ndev, "TX head DMA map failed\n");
> +		ring->stats.sw_err_cnt++;
> +		goto out_err_tx_ok;
> +	}
> +
> +	ret = priv->ops.fill_desc(ring, skb, size, dma, seg_num == 1 ? 1 : 0,
> +			   DESC_TYPE_SKB);
> +	if (ret)
> +		goto head_dma_map_err;
> +
> +	next_to_use_frag = ring->next_to_use;
> +	/* Fill the fragments */
> +	for (i = 1; i < seg_num; i++) {
> +		frag = &skb_shinfo(skb)->frags[i - 1];
> +		size = skb_frag_size(frag);
> +		dma = skb_frag_dma_map(dev, frag, 0, size, DMA_TO_DEVICE);
> +		if (dma_mapping_error(dev, dma)) {
> +			netdev_err(ndev, "TX frag(%d) DMA map failed\n", i);
> +			ring->stats.sw_err_cnt++;
> +			goto frag_dma_map_err;
> +		}
> +		ret = priv->ops.fill_desc(ring, skb_frag_page(frag), size, dma,
> +				    seg_num - 1 == i ? 1 : 0,
> +				    DESC_TYPE_PAGE);
> +
> +		if (ret)
> +			goto frag_dma_map_err;
> +	}
> +
> +	/* Complete translate all packets */
> +	dev_queue = netdev_get_tx_queue(ndev, ring_data->queue_index);
> +	netdev_tx_sent_queue(dev_queue, skb->len);
> +
> +	wmb(); /* Commit all data before submit */
> +
> +	hnae_queue_xmit(ring->tqp, buf_num);
> +
> +	ring->stats.tx_pkts++;
> +	ring->stats.tx_bytes += skb->len;
> +
> +	return NETDEV_TX_OK;
> +
> +frag_dma_map_err:
> +	hns_nic_dma_unmap(ring, next_to_use_frag);
> +
> +head_dma_map_err:
> +	hns_nic_dma_unmap(ring, next_to_use_head);
> +
> +out_err_tx_ok:
> +	dev_kfree_skb_any(skb);
> +	return NETDEV_TX_OK;
> +
> +out_net_tx_busy:
> +	netif_stop_subqueue(ndev, ring_data->queue_index);
> +	smp_mb(); /* Commit all data before submit */
> +
> +	return NETDEV_TX_BUSY;
> +}
> +
> +static netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb,
> +				     struct net_device *ndev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	int ret;
> +
> +	ret = hns3_nic_net_xmit_hw(ndev, skb,
> +				   &tx_ring_data(priv, skb->queue_mapping));
> +	if (ret == NETDEV_TX_OK) {
> +		netif_trans_update(ndev);
> +		ndev->stats.tx_bytes += skb->len;
> +		ndev->stats.tx_packets++;
> +	}
> +
> +	return (netdev_tx_t)ret;
> +}
> +
> +static int hns3_nic_net_set_mac_address(struct net_device *ndev, void *p)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	struct sockaddr *mac_addr = p;
> +	int ret;
> +
> +	if (!mac_addr || !is_valid_ether_addr((const u8 *)mac_addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	ret = h->ae_algo->ops->set_mac_addr(h, mac_addr->sa_data);
> +	if (ret) {
> +		netdev_err(ndev, "set_mac_address fail, ret=%d!\n", ret);
> +		return ret;
> +	}
> +
> +	ether_addr_copy(ndev->dev_addr, mac_addr->sa_data);
> +
> +	return 0;
> +}
> +
> +static int hns3_nic_set_features(struct net_device *netdev,
> +				 netdev_features_t features)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +
> +	if (features & (NETIF_F_TSO | NETIF_F_TSO6)) {
> +		priv->ops.fill_desc = hns3_fill_desc_tso;
> +		priv->ops.maybe_stop_tx = hns3_nic_maybe_stop_tso;
> +	} else {
> +		priv->ops.fill_desc = hns3_fill_desc;
> +		priv->ops.maybe_stop_tx = hns3_nic_maybe_stop_tx;
> +	}
> +
> +	netdev->features = features;
> +	return 0;
> +}
> +
> +static void
> +hns3_nic_get_stats64(struct net_device *ndev, struct rtnl_link_stats64 *stats)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	int queue_num = priv->ae_handle->kinfo.num_tqps;
> +	u64 tx_bytes = 0;
> +	u64 rx_bytes = 0;
> +	u64 tx_pkts = 0;
> +	u64 rx_pkts = 0;
> +	int idx = 0;
> +
> +	for (idx = 0; idx < queue_num; idx++) {
> +		tx_bytes += priv->ring_data[idx].ring->stats.tx_bytes;
> +		tx_pkts += priv->ring_data[idx].ring->stats.tx_pkts;
> +		rx_bytes +=
> +			priv->ring_data[idx + queue_num].ring->stats.rx_bytes;
> +		rx_pkts += priv->ring_data[idx + queue_num].ring->stats.rx_pkts;
> +	}
> +
> +	stats->tx_bytes = tx_bytes;
> +	stats->tx_packets = tx_pkts;
> +	stats->rx_bytes = rx_bytes;
> +	stats->rx_packets = rx_pkts;
> +
> +	stats->rx_errors = ndev->stats.rx_errors;
> +	stats->multicast = ndev->stats.multicast;
> +	stats->rx_length_errors = ndev->stats.rx_length_errors;
> +	stats->rx_crc_errors = ndev->stats.rx_crc_errors;
> +	stats->rx_missed_errors = ndev->stats.rx_missed_errors;
> +
> +	stats->tx_errors = ndev->stats.tx_errors;
> +	stats->rx_dropped = ndev->stats.rx_dropped;
> +	stats->tx_dropped = ndev->stats.tx_dropped;
> +	stats->collisions = ndev->stats.collisions;
> +	stats->rx_over_errors = ndev->stats.rx_over_errors;
> +	stats->rx_frame_errors = ndev->stats.rx_frame_errors;
> +	stats->rx_fifo_errors = ndev->stats.rx_fifo_errors;
> +	stats->tx_aborted_errors = ndev->stats.tx_aborted_errors;
> +	stats->tx_carrier_errors = ndev->stats.tx_carrier_errors;
> +	stats->tx_fifo_errors = ndev->stats.tx_fifo_errors;
> +	stats->tx_heartbeat_errors = ndev->stats.tx_heartbeat_errors;
> +	stats->tx_window_errors = ndev->stats.tx_window_errors;
> +	stats->rx_compressed = ndev->stats.rx_compressed;
> +	stats->tx_compressed = ndev->stats.tx_compressed;
> +}
> +
> +static void hns3_add_tunnel_port(struct net_device *ndev, u16 port,
> +				 enum hns3_udp_tnl_type type)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hns3_udp_tunnel *udp_tnl = &priv->udp_tnl[type];
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (udp_tnl->used && udp_tnl->dst_port == port) {
> +		udp_tnl->used++;
> +		return;
> +	}
> +
> +	if (udp_tnl->used) {
> +		netdev_warn(ndev,
> +			    "UDP tunnel [%d], port [%d] offload\n", type, port);
> +		return;
> +	}
> +
> +	udp_tnl->dst_port = port;
> +	udp_tnl->used = 1;
> +	/* TBD send command to hardware to add port */
> +	if (h->ae_algo->ops->add_tunnel_udp)
> +		h->ae_algo->ops->add_tunnel_udp(h, port);
> +}
> +
> +static void hns3_del_tunnel_port(struct net_device *ndev, u16 port,
> +				 enum hns3_udp_tnl_type type)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hns3_udp_tunnel *udp_tnl = &priv->udp_tnl[type];
> +	struct hnae3_handle *h = priv->ae_handle;
> +
> +	if (!udp_tnl->used || udp_tnl->dst_port != port) {
> +		netdev_warn(ndev,
> +			    "Invalid UDP tunnel port %d\n", port);
> +		return;
> +	}
> +
> +	udp_tnl->used--;
> +	if (udp_tnl->used)
> +		return;
> +
> +	udp_tnl->dst_port = 0;
> +	/* TBD send command to hardware to del port  */
> +	if (h->ae_algo->ops->del_tunnel_udp)
> +		h->ae_algo->ops->add_tunnel_udp(h, port);
> +}
> +
> +/* hns3_nic_udp_tunnel_add - Get notifiacetion about UDP tunnel ports
> + * @netdev: This physical ports's netdev
> + * @ti: Tunnel information
> + */
> +static void hns3_nic_udp_tunnel_add(struct net_device *ndev,
> +				    struct udp_tunnel_info *ti)
> +{
> +	u16 port_n = ntohs(ti->port);
> +
> +	switch (ti->type) {
> +	case UDP_TUNNEL_TYPE_VXLAN:
> +		hns3_add_tunnel_port(ndev, port_n, HNS3_UDP_TNL_VXLAN);
> +		break;
> +	case UDP_TUNNEL_TYPE_GENEVE:
> +		hns3_add_tunnel_port(ndev, port_n, HNS3_UDP_TNL_GENEVE);
> +		break;
> +	default:
> +		netdev_err(ndev, "unsupported tunnel type %d\n", ti->type);
> +		break;
> +	}
> +}
> +
> +static void hns3_nic_udp_tunnel_del(struct net_device *ndev,
> +				    struct udp_tunnel_info *ti)
> +{
> +	u16 port_n = ntohs(ti->port);
> +
> +	switch (ti->type) {
> +	case UDP_TUNNEL_TYPE_VXLAN:
> +		hns3_del_tunnel_port(ndev, port_n, HNS3_UDP_TNL_VXLAN);
> +		break;
> +	case UDP_TUNNEL_TYPE_GENEVE:
> +		hns3_del_tunnel_port(ndev, port_n, HNS3_UDP_TNL_GENEVE);
> +		break;
> +	default:
> +		break;
> +	}
> +}
> +
> +static int hns3_setup_tc(struct net_device *ndev, u8 tc)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	struct hnae3_knic_private_info *kinfo = &h->kinfo;
> +	int i, ret;
> +
> +	if (tc > HNAE3_MAX_TC)
> +		return -EINVAL;
> +
> +	if (kinfo->num_tc == tc)
> +		return 0;
> +
> +	if (!ndev)
> +		return -EINVAL;
> +
> +	if (!tc) {
> +		netdev_reset_tc(ndev);
> +		return 0;
> +	}
> +
> +	/* Set num_tc for netdev */
> +	ret = netdev_set_num_tc(ndev, tc);
> +	if (ret)
> +		return ret;
> +
> +	/* Set per TC queues for the VSI */
> +	for (i = 0; i < HNAE3_MAX_TC; i++) {
> +		if (kinfo->tc_info[i].enable)
> +			netdev_set_tc_queue(ndev,
> +					    kinfo->tc_info[i].tc,
> +					    kinfo->tc_info[i].tqp_count,
> +					    kinfo->tc_info[i].tqp_offset);
> +	}
> +
> +	return 0;
> +}
> +
> +static int hns3_nic_setup_tc(struct net_device *dev, u32 handle,
> +			     u32 chain_index, __be16 protocol,
> +			     struct tc_to_netdev *tc)
> +{
> +	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
> +		return -EINVAL;
> +
> +	return hns3_setup_tc(dev, tc->mqprio->num_tc);
> +}
> +
> +static int hns3_vlan_rx_add_vid(struct net_device *ndev,
> +				__be16 proto, u16 vid)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int ret = -EIO;
> +
> +	if (h->ae_algo->ops->set_vlan_filter)
> +		ret = h->ae_algo->ops->set_vlan_filter(h, proto, vid, false);
> +
> +	return ret;
> +}
> +
> +static int hns3_vlan_rx_kill_vid(struct net_device *ndev,
> +				 __be16 proto, u16 vid)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int ret = -EIO;
> +
> +	if (h->ae_algo->ops->set_vlan_filter)
> +		ret = h->ae_algo->ops->set_vlan_filter(h, proto, vid, true);
> +
> +	return ret;
> +}
> +
> +static int hns3_ndo_set_vf_vlan(struct net_device *ndev, int vf, u16 vlan,
> +				u8 qos, __be16 vlan_proto)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int ret = -EIO;
> +
> +	if (h->ae_algo->ops->set_vf_vlan_filter)
> +		ret = h->ae_algo->ops->set_vf_vlan_filter(h, vf, vlan,
> +						   qos, vlan_proto);
> +
> +	return ret;
> +}
> +
> +static const struct net_device_ops hns3_nic_netdev_ops = {
> +	.ndo_open		= hns3_nic_net_open,
> +	.ndo_stop		= hns3_nic_net_stop,
> +	.ndo_start_xmit		= hns3_nic_net_xmit,
> +	.ndo_set_mac_address	= hns3_nic_net_set_mac_address,
> +	.ndo_set_features	= hns3_nic_set_features,
> +	.ndo_get_stats64	= hns3_nic_get_stats64,
> +	.ndo_setup_tc		= hns3_nic_setup_tc,
> +	.ndo_set_rx_mode	= hns3_nic_set_rx_mode,
> +	.ndo_udp_tunnel_add	= hns3_nic_udp_tunnel_add,
> +	.ndo_udp_tunnel_del	= hns3_nic_udp_tunnel_del,
> +	.ndo_vlan_rx_add_vid	= hns3_vlan_rx_add_vid,
> +	.ndo_vlan_rx_kill_vid	= hns3_vlan_rx_kill_vid,
> +	.ndo_set_vf_vlan	= hns3_ndo_set_vf_vlan,
> +};
> +
> +/* hns3_probe - Device initialization routine
> + * @pdev: PCI device information struct
> + * @ent: entry in hns3_pci_tbl
> + *
> + * hns3_probe initializes a PF identified by a pci_dev structure.
> + * The OS initialization, configuring of the PF private structure,
> + * and a hardware reset occur.
> + *
> + * Returns 0 on success, negative on failure
> + */
> +static int hns3_probe(struct pci_dev *pdev, const struct pci_device_id *ent)
> +{
> +	struct hnae3_ae_dev *ae_dev;
> +	int ret;
> +
> +	ae_dev = kzalloc(sizeof(*ae_dev), GFP_KERNEL);
> +	if (!ae_dev) {
> +		ret = -ENOMEM;
> +		return ret;
> +	}
> +
> +	ae_dev->pdev = pdev;
> +	ae_dev->dev_type = HNAE3_DEV_KNIC;
> +	pci_set_drvdata(pdev, ae_dev);
> +
> +	return hnae3_register_ae_dev(ae_dev);
> +}
> +
> +/* hns3_remove - Device removal routine
> + * @pdev: PCI device information struct
> + */
> +static void hns3_remove(struct pci_dev *pdev)
> +{
> +	struct hnae3_ae_dev *ae_dev = pci_get_drvdata(pdev);
> +
> +	hnae3_unregister_ae_dev(ae_dev);
> +
> +	pci_set_drvdata(pdev, NULL);
> +}
> +
> +static struct pci_driver hns3_driver = {
> +	.name     = hns3_driver_name,
> +	.id_table = hns3_pci_tbl,
> +	.probe    = hns3_probe,
> +	.remove   = hns3_remove,
> +};
> +
> +/* set default feature to hns3 */
> +static void hns3_set_default_feature(struct net_device *ndev)
> +{
> +	ndev->priv_flags |= IFF_UNICAST_FLT;
> +
> +	ndev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
> +		NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_GRE |
> +		NETIF_F_GSO_GRE_CSUM | NETIF_F_GSO_UDP_TUNNEL |
> +		NETIF_F_GSO_UDP_TUNNEL_CSUM;
> +
> +	ndev->hw_enc_features |= NETIF_F_TSO_MANGLEID;
> +
> +	ndev->gso_partial_features |= NETIF_F_GSO_GRE_CSUM;
> +
> +	ndev->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_HW_VLAN_CTAG_FILTER |
> +		NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
> +		NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_GRE |
> +		NETIF_F_GSO_GRE_CSUM | NETIF_F_GSO_UDP_TUNNEL |
> +		NETIF_F_GSO_UDP_TUNNEL_CSUM;
> +
> +	ndev->vlan_features |=
> +		NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM |
> +		NETIF_F_SG | NETIF_F_GSO | NETIF_F_GRO |
> +		NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_GRE |
> +		NETIF_F_GSO_GRE_CSUM | NETIF_F_GSO_UDP_TUNNEL |
> +		NETIF_F_GSO_UDP_TUNNEL_CSUM;
> +
> +	ndev->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
> +		NETIF_F_HW_VLAN_CTAG_FILTER |
> +		NETIF_F_RXCSUM | NETIF_F_SG | NETIF_F_GSO |
> +		NETIF_F_GRO | NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_GSO_GRE |
> +		NETIF_F_GSO_GRE_CSUM | NETIF_F_GSO_UDP_TUNNEL |
> +		NETIF_F_GSO_UDP_TUNNEL_CSUM;
> +}
> +
> +static int hns3_alloc_buffer(struct hns3_enet_ring *ring,
> +			     struct hns3_desc_cb *cb)
> +{
> +	unsigned int order = hnae_page_order(ring);
> +	struct page *p;
> +
> +	p = dev_alloc_pages(order);
> +	if (!p)
> +		return -ENOMEM;
> +
> +	cb->priv = p;
> +	cb->page_offset = 0;
> +	cb->reuse_flag = 0;
> +	cb->buf  = page_address(p);
> +	cb->length = hnae_page_size(ring);
> +	cb->type = DESC_TYPE_PAGE;
> +
> +	memset(cb->buf, 0, cb->length);
> +
> +	return 0;
> +}
> +
> +static void hns3_free_buffer(struct hns3_enet_ring *ring,
> +			     struct hns3_desc_cb *cb)
> +{
> +	if (cb->type == DESC_TYPE_SKB)
> +		dev_kfree_skb_any((struct sk_buff *)cb->priv);
> +	else if (!HNAE3_IS_TX_RING(ring))
> +		put_page((struct page *)cb->priv);
> +	memset(cb, 0, sizeof(*cb));
> +}
> +
> +static int hns3_map_buffer(struct hns3_enet_ring *ring, struct hns3_desc_cb *cb)
> +{
> +	cb->dma = dma_map_page(ring_to_dev(ring), cb->priv, 0,
> +			       cb->length, ring_to_dma_dir(ring));
> +
> +	if (dma_mapping_error(ring_to_dev(ring), cb->dma))
> +		return -EIO;
> +
> +	return 0;
> +}
> +
> +static void hns3_unmap_buffer(struct hns3_enet_ring *ring,
> +			      struct hns3_desc_cb *cb)
> +{
> +	if (cb->type == DESC_TYPE_SKB)
> +		dma_unmap_single(ring_to_dev(ring), cb->dma, cb->length,
> +				 ring_to_dma_dir(ring));
> +	else
> +		dma_unmap_page(ring_to_dev(ring), cb->dma, cb->length,
> +			       ring_to_dma_dir(ring));
> +}
> +
> +static inline void hns3_buffer_detach(struct hns3_enet_ring *ring, int i)
> +{
> +	hns3_unmap_buffer(ring, &ring->desc_cb[i]);
> +	ring->desc[i].addr = 0;
> +}
> +
> +static inline void hns3_free_buffer_detach(struct hns3_enet_ring *ring, int i)
> +{
> +	struct hns3_desc_cb *cb = &ring->desc_cb[i];
> +
> +	if (!ring->desc_cb[i].dma)
> +		return;
> +
> +	hns3_buffer_detach(ring, i);
> +	hns3_free_buffer(ring, cb);
> +}
> +
> +static void hns3_free_buffers(struct hns3_enet_ring *ring)
> +{
> +	int i;
> +
> +	for (i = 0; i < ring->desc_num; i++)
> +		hns3_free_buffer_detach(ring, i);
> +}
> +
> +/* free desc along with its attached buffer */
> +static void hns3_free_desc(struct hns3_enet_ring *ring)
> +{
> +	hns3_free_buffers(ring);
> +
> +	dma_unmap_single(ring_to_dev(ring), ring->desc_dma_addr,
> +			 ring->desc_num * sizeof(ring->desc[0]),
> +			 DMA_BIDIRECTIONAL);
> +	ring->desc_dma_addr = 0;
> +	kfree(ring->desc);
> +	ring->desc = NULL;
> +}
> +
> +static int hns3_alloc_desc(struct hns3_enet_ring *ring)
> +{
> +	int size = ring->desc_num * sizeof(ring->desc[0]);
> +
> +	ring->desc = kzalloc(size, GFP_KERNEL);
> +	if (!ring->desc)
> +		return -ENOMEM;
> +
> +	ring->desc_dma_addr = dma_map_single(ring_to_dev(ring),
> +		ring->desc, size, DMA_BIDIRECTIONAL);
> +	if (dma_mapping_error(ring_to_dev(ring), ring->desc_dma_addr)) {
> +		ring->desc_dma_addr = 0;
> +		kfree(ring->desc);
> +		ring->desc = NULL;
> +		return -ENOMEM;
> +	}
> +
> +	return 0;
> +}
> +
> +static inline int hns3_reserve_buffer_map(struct hns3_enet_ring *ring,
> +					  struct hns3_desc_cb *cb)

No need to use inline. Leave the compiler to decide. This is true in
general.

> +static bool hns3_get_new_int_gl(struct hns3_enet_ring_group *ring_group)
> +{
> +	enum hns3_flow_level_range new_flow_level;
> +	struct hns3_enet_tqp_vector *tqp_vector;
> +	int packets_per_secs;
> +	int bytes_per_usecs;
> +	u16 new_int_gl;
> +	int usecs;
> +
> +	if (!ring_group->int_gl)
> +		return false;
> +
> +	if (ring_group->total_packets == 0) {
> +		ring_group->int_gl = HNS3_INT_GL_50K;
> +		ring_group->flow_level = HNS3_FLOW_LOW;
> +		return true;
> +	}
> +	/* Simple throttlerate management
> +	 * 0-10MB/s   lower     (50000 ints/s)
> +	 * 10-20MB/s   middle    (20000 ints/s)
> +	 * 20-1249MB/s high      (18000 ints/s)
> +	 * > 40000pps  ultra     (8000 ints/s)
> +	 */
> +
> +	new_flow_level = ring_group->flow_level;
> +	new_int_gl = ring_group->int_gl;
> +	tqp_vector = ring_group->ring->tqp_vector;
> +	usecs = (ring_group->int_gl << 1);
> +	bytes_per_usecs = ring_group->total_bytes / usecs;
> +	/* 1000000 microseconds */
> +	packets_per_secs = ring_group->total_packets * 1000000 / usecs;
> +
> +	switch (new_flow_level) {
> +	case HNS3_FLOW_LOW:
> +		if (bytes_per_usecs > 10)
> +			new_flow_level = HNS3_FLOW_MID;
> +		break;
> +	case HNS3_FLOW_MID:
> +		if (bytes_per_usecs > 20)
> +			new_flow_level = HNS3_FLOW_HIGH;
> +		else if (bytes_per_usecs <= 10)
> +			new_flow_level = HNS3_FLOW_LOW;
> +		break;
> +	case HNS3_FLOW_HIGH:
> +	case HNS3_FLOW_ULTRA:
> +	default:
> +		if (bytes_per_usecs <= 20)
> +			new_flow_level = HNS3_FLOW_MID;
> +		break;
> +	}
> +#define HNS3_RX_ULTRA_PACKET_RATE 40000

It is not normal to put #defines like this in the middle of the code.

> +
> +	if ((packets_per_secs > HNS3_RX_ULTRA_PACKET_RATE) &&
> +	    (&tqp_vector->rx_group == ring_group))
> +		new_flow_level = HNS3_FLOW_ULTRA;
> +
> +	switch (new_flow_level) {
> +	case HNS3_FLOW_LOW:
> +		new_int_gl = HNS3_INT_GL_50K;
> +		break;
> +	case HNS3_FLOW_MID:
> +		new_int_gl = HNS3_INT_GL_20K;
> +		break;
> +	case HNS3_FLOW_HIGH:
> +		new_int_gl = HNS3_INT_GL_18K;
> +		break;
> +	case HNS3_FLOW_ULTRA:
> +		new_int_gl = HNS3_INT_GL_8K;
> +		break;
> +	default:
> +		break;
> +	}
> +
> +	ring_group->total_bytes = 0;
> +	ring_group->total_packets = 0;
> +	ring_group->flow_level = new_flow_level;
> +	if (new_int_gl != ring_group->int_gl) {
> +		ring_group->int_gl = new_int_gl;
> +		return true;
> +	}
> +	return false;
> +}

> +/* Set mac addr if it is configed. or leave it to the AE driver */

configured

> +/* hns3_init_module - Driver registration routine
> + * hns3_init_module is the first routine called when the driver is
> + * loaded. All it does is register with the PCI subsystem.
> + */
> +static int __init hns3_init_module(void)
> +{
> +	struct hnae3_client *client;
> +	int ret;
> +
> +	pr_info("%s: %s - version\n", hns3_driver_name, hns3_driver_string);
> +	pr_info("%s: %s\n", hns3_driver_name, hns3_copyright);
> +
> +	client = kzalloc(sizeof(*client), GFP_KERNEL);
> +	if (!client) {
> +		ret = -ENOMEM;
> +		goto err_client_alloc;
> +	}
> +
> +	client->type = HNAE3_CLIENT_KNIC;
> +	snprintf(client->name, HNAE3_CLIENT_NAME_LENGTH - 1, "%s",
> +		 hns3_driver_name);
> +
> +	client->ops = &client_ops;
> +
> +	ret = hnae3_register_client(client);
> +	if (ret)
> +		return ret;
> +
> +	return pci_register_driver(&hns3_driver);
> +
> +err_client_alloc:
> +	return ret;
> +}
> +module_init(hns3_init_module);
> +
> +/* hns3_exit_module - Driver exit cleanup routine
> + * hns3_exit_module is called just before the driver is removed
> + * from memory.
> + */
> +static void __exit hns3_exit_module(void)
> +{
> +	pci_unregister_driver(&hns3_driver);

You would normally expect any memory allocated in the init function to
be cleared in the exit function. When does client memory get freed?

   Andrew
