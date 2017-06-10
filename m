From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next 1/9] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sat, 10 Jun 2017 12:43:21 +0000
Message-ID: <BY2PR0701MB2005075560E4EA9F455049988DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "yisen.zhuang@huawei.com" <yisen.zhuang@huawei.com>,
        "huangdaode@hisilicon.com" <huangdaode@hisilicon.com>,
        "lipeng321@huawei.com" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linuxarm@huawei.com" <linuxarm@huawei.com>
To: Salil Mehta <salil.mehta@huawei.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0042.outbound.protection.outlook.com ([104.47.33.42]:38818
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751583AbdFJMnZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 10 Jun 2017 08:43:25 -0400
In-Reply-To: <20170610034630.493852-2-salil.mehta@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> +static void hns3_nic_net_down(struct net_device *ndev) {
> +	struct hns3_nic_priv *priv =3D netdev_priv(ndev);
> +	struct hnae3_ae_ops *ops;
> +	int i;
> +
> +	netif_tx_stop_all_queues(ndev);
> +	netif_carrier_off(ndev);
> +	netif_tx_disable(ndev);
> +
> +	ops =3D priv->ae_handle->ae_algo->ops;
> +
> +	if (ops->stop)
> +		ops->stop(priv->ae_handle);
> +
> +	netif_tx_stop_all_queues(ndev);

Looks a bit excessive. Why do you need all these netif_tx_stop_all_queues()=
?

> +int hns3_nic_net_xmit_hw(struct net_device *ndev,
...
> +out_map_frag_fail:
> +
> +	while (ring->next_to_use !=3D next_to_use) {
> +		if (ring->next_to_use !=3D next_to_use)
> +			dma_unmap_page(dev,
> +				       ring->desc_cb[ring->next_to_use].dma,
> +				       ring->desc_cb[ring->next_to_use].length,
> +				       DMA_TO_DEVICE);
> +		else
> +			dma_unmap_single(dev,
> +					 ring->desc_cb[next_to_use].dma,
> +					 ring->desc_cb[next_to_use].length,
> +					 DMA_TO_DEVICE);
> +	}

Something looks completely broken in this error-handling 'loop'.

> +static int hns3_setup_tc(struct net_device *ndev, u8 tc) {
...
> +	/* Assign UP2TC map for the VSI */
> +	for (i =3D 0; i < HNAE3_MAX_TC; i++) {
> +		netdev_set_prio_tc_map(ndev,
> +				       kinfo->tc_info[i].up,
> +				       kinfo->tc_info[i].tc);
> +	}
...
> +static int hns3_nic_setup_tc(struct net_device *dev, u32 handle,
> +			     u32 chain_index, __be16 protocol,
> +			     struct tc_to_netdev *tc)
> +{
> +	if (handle !=3D TC_H_ROOT || tc->type !=3D TC_SETUP_MQPRIO)
> +		return -EINVAL;
> +
> +	return hns3_setup_tc(dev, tc->mqprio->num_tc); }

Isn't mqprio going to override your priority2tc mapping with the one provid=
ed
by user?

> +
> +static int hns3_handle_rx_bd(struct hns3_enet_ring *ring,
> +			     struct sk_buff **out_skb, int *out_bnum) {
...
> +	/* Prefetch first cache line of first page */
> +	prefetch(va);
> +#if L1_CACHE_BYTES < 128
> +	prefetch(va + L1_CACHE_BYTES);
> +#endif

Might be better to comment what you're actually fetching
