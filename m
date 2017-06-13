From: Salil Mehta <salil.mehta@huawei.com>
Subject: RE: [PATCH net-next 1/9] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Tue, 13 Jun 2017 17:08:18 +0000
Message-ID: <F4CC6FACFEB3C54C9141D49AD221F7F93B7A1B62@FRAEML521-MBX.china.huawei.com>
References: <20170610034630.493852-1-salil.mehta@huawei.com>
 <20170610034630.493852-2-salil.mehta@huawei.com>
 <BY2PR0701MB2005075560E4EA9F455049988DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Zhuangyuzeng (Yisen)" <yisen.zhuang@huawei.com>,
        huangdaode <huangdaode@hisilicon.com>,
        "lipeng (Y)" <lipeng321@huawei.com>,
        "mehta.salil.lnk@gmail.com" <mehta.salil.lnk@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Linuxarm <linuxarm@huawei.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <BY2PR0701MB2005075560E4EA9F455049988DCF0@BY2PR0701MB2005.namprd07.prod.outlook.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yuval

> -----Original Message-----
> From: Mintz, Yuval [mailto:Yuval.Mintz@cavium.com]
> Sent: Saturday, June 10, 2017 1:43 PM
> To: Salil Mehta; davem@davemloft.net
> Cc: Zhuangyuzeng (Yisen); huangdaode; lipeng (Y);
> mehta.salil.lnk@gmail.com; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; Linuxarm
> Subject: RE: [PATCH net-next 1/9] net: hns3: Add support of HNS3
> Ethernet Driver for hip08 SoC
> 
> > +static void hns3_nic_net_down(struct net_device *ndev) {
> > +	struct hns3_nic_priv *priv = netdev_priv(ndev);
> > +	struct hnae3_ae_ops *ops;
> > +	int i;
> > +
> > +	netif_tx_stop_all_queues(ndev);
> > +	netif_carrier_off(ndev);
> > +	netif_tx_disable(ndev);
> > +
> > +	ops = priv->ae_handle->ae_algo->ops;
> > +
> > +	if (ops->stop)
> > +		ops->stop(priv->ae_handle);
> > +
> > +	netif_tx_stop_all_queues(ndev);
> 
> Looks a bit excessive. Why do you need all these
> netif_tx_stop_all_queues()?
If we are disabling the netdev. We need to stop scheduling
the queues associated with that netdev for TX, so we need
this code. Why do you think it is excessive? 

Thanks
Salil
> 
> > +int hns3_nic_net_xmit_hw(struct net_device *ndev,
> ...
> > +out_map_frag_fail:
> > +
> > +	while (ring->next_to_use != next_to_use) {
> > +		if (ring->next_to_use != next_to_use)
> > +			dma_unmap_page(dev,
> > +				       ring->desc_cb[ring->next_to_use].dma,
> > +				       ring->desc_cb[ring->next_to_use].length,
> > +				       DMA_TO_DEVICE);
> > +		else
> > +			dma_unmap_single(dev,
> > +					 ring->desc_cb[next_to_use].dma,
> > +					 ring->desc_cb[next_to_use].length,
> > +					 DMA_TO_DEVICE);
> > +	}
> 
> Something looks completely broken in this error-handling 'loop'.
This looks bad indeed. I will clean this logic. 

Thanks
Salil
> 
> > +static int hns3_setup_tc(struct net_device *ndev, u8 tc) {
> ...
> > +	/* Assign UP2TC map for the VSI */
> > +	for (i = 0; i < HNAE3_MAX_TC; i++) {
> > +		netdev_set_prio_tc_map(ndev,
> > +				       kinfo->tc_info[i].up,
> > +				       kinfo->tc_info[i].tc);
> > +	}
> ...
> > +static int hns3_nic_setup_tc(struct net_device *dev, u32 handle,
> > +			     u32 chain_index, __be16 protocol,
> > +			     struct tc_to_netdev *tc)
> > +{
> > +	if (handle != TC_H_ROOT || tc->type != TC_SETUP_MQPRIO)
> > +		return -EINVAL;
> > +
> > +	return hns3_setup_tc(dev, tc->mqprio->num_tc); }
> 
> Isn't mqprio going to override your priority2tc mapping with the one
> provided
> by user?
I guess you are referring to below code in the mqprio_init() - right?

static int mqprio_init(struct Qdisc *sch, struct nlattr *opt)
{
  [...]
	/* Always use supplied priority mappings */
	for (i = 0; i < TC_BITMASK + 1; i++)
		netdev_set_prio_tc_map(dev, i, qopt->prio_tc_map[i]);
  [...]
}

In this case yes, you are right below code seems to be redundant:

 +	/* Assign UP2TC map for the VSI */
 +	for (i = 0; i < HNAE3_MAX_TC; i++) {
 +		netdev_set_prio_tc_map(ndev,
 +				       kinfo->tc_info[i].up,
 +				       kinfo->tc_info[i].tc);

Hope I am not missing anything here?

Thanks
Salil
> 
> > +
> > +static int hns3_handle_rx_bd(struct hns3_enet_ring *ring,
> > +			     struct sk_buff **out_skb, int *out_bnum) {
> ...
> > +	/* Prefetch first cache line of first page */
> > +	prefetch(va);
> > +#if L1_CACHE_BYTES < 128
> > +	prefetch(va + L1_CACHE_BYTES);
> > +#endif
> 
> Might be better to comment what you're actually fetching
Idea is to cache few bytes of the header of the packet. Our L1
Cache line size is 64B so need to prefetch twice to make it
128B. But in actual we can have greater size of caches with
128B Level 1 cache lines. In such a case, single fetch would
suffice to cache in the relevant part of the header.

Will provide a comment over it - no problem.

Thanks
Salil
> 
> 
