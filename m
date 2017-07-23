From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH V4 net-next 1/8] net: hns3: Add support of HNS3 Ethernet
 Driver for hip08 SoC
Date: Sun, 23 Jul 2017 10:24:29 -0700
Message-ID: <79a3a952-acae-2a51-0d49-46acaf92cf3b@gmail.com>
References: <20170722220942.78852-1-salil.mehta@huawei.com>
 <20170722220942.78852-2-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: yisen.zhuang@huawei.com, huangdaode@hisilicon.com,
        lipeng321@huawei.com, mehta.salil.lnk@gmail.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-rdma@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170722220942.78852-2-salil.mehta@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/22/2017 03:09 PM, Salil Mehta wrote:
> This patch adds the support of Hisilicon Network Subsystem 3
> Ethernet driver to hip08 family of SoCs.
> 
> This driver includes basic Rx/Tx functionality. It also includes
> the client registration code with the HNAE3(Hisilicon Network
> Acceleration Engine 3) framework.
> 
> This work provides the initial support to the hip08 SoC and
> would incrementally add features or enhancements.
> 
> Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
> Signed-off-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> ---
> Patch V4: addressed comments by:
>   1. Andrew Lunn:
>      https://lkml.org/lkml/2017/6/17/222
>      https://lkml.org/lkml/2017/6/17/232
>   2. Bo Yu:
>      https://lkml.org/lkml/2017/6/18/110
>      https://lkml.org/lkml/2017/6/18/115
> Patch V3: Addresed below comments:
>   1. Stephen Hemminger:
>      https://lkml.org/lkml/2017/6/13/972
>   2. Yuval Mintz:
>      https://lkml.org/lkml/2017/6/14/151
> Patch V2: Addressed below comments:
>   1. Kbuild:
>      https://lkml.org/lkml/2017/6/11/73
>   2. Yuval Mintz:
>      https://lkml.org/lkml/2017/6/10/78
> Patch V1: Initial Submit
> ---
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c | 2894 ++++++++++++++++++++
>  .../net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h |  598 ++++
>  2 files changed, 3492 insertions(+)
>  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
>  create mode 100644 drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.h
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> new file mode 100644
> index 000000000000..6e0e2967db42
> --- /dev/null
> +++ b/drivers/net/ethernet/hisilicon/hns3/hns3pf/hns3_enet.c
> @@ -0,0 +1,2894 @@
> +/*
> + * Copyright (c) 2016~2017 Hisilicon Limited.
> + *
> + * This program is free software; you can redistribute it and/or modify
> + * it under the terms of the GNU General Public License as published by
> + * the Free Software Foundation; either version 2 of the License, or
> + * (at your option) any later version.
> + */
> +
> +#include <linux/dma-mapping.h>
> +#include <linux/etherdevice.h>
> +#include <net/gre.h>
> +#include <linux/interrupt.h>
> +#include <linux/if_vlan.h>
> +#include <linux/ip.h>
> +#include <linux/ipv6.h>
> +#include <linux/module.h>
> +#include <linux/pci.h>
> +#include <linux/skbuff.h>
> +#include <linux/sctp.h>
> +#include <net/vxlan.h>
> +
> +#include "hnae3.h"
> +#include "hns3_enet.h"
> +
> +const char hns3_driver_name[] = "hns3";
> +static const char hns3_driver_string[] =
> +			"Hisilicon Ethernet Network Driver for Hi162x Family";
> +static const char hns3_copyright[] = "Copyright (c) 2017 Huawei Corporation.";
> +static struct hnae3_client client;
> +
> +/* hns3_pci_tbl - PCI Device ID Table
> + *
> + * Last entry must be all 0s
> + *
> + * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
> + *   Class, Class Mask, private data (not used) }
> + */
> +static const struct pci_device_id hns3_pci_tbl[] = {
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_GE), 0},
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE), 0},
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA), 0},
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_25GE_RDMA_MACSEC), 0},
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA), 0},
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_50GE_RDMA_MACSEC), 0},
> +	{PCI_VDEVICE(HUAWEI, HNAE3_DEV_ID_100G_RDMA_MACSEC), 0},
> +	/* required last entry */
> +	{0, }
> +};
> +MODULE_DEVICE_TABLE(pci, hns3_pci_tbl);
> +
> +static irqreturn_t hns3_irq_handle(int irq, void *dev)
> +{
> +	struct hns3_enet_tqp_vector *tqp_vector = dev;
> +
> +	napi_schedule(&tqp_vector->napi);
> +
> +	return IRQ_HANDLED;
> +}
> +
> +static int hns3_nic_init_irq(struct hns3_nic_priv *priv)
> +{
> +	struct pci_dev *pdev = priv->ae_handle->pdev;
> +	struct hns3_enet_tqp_vector *tqp_vectors;
> +	int txrx_int_idx = 0;
> +	int rx_int_idx = 0;
> +	int tx_int_idx = 0;
> +	int ret;
> +	int i;

unsigned int i

> +
> +	for (i = 0; i < priv->vector_num; i++) {
> +		tqp_vectors = &priv->tqp_vector[i];
> +
> +		if (tqp_vectors->irq_init_flag == HNS3_VECTOR_INITED)
> +			continue;
> +
> +		if (tqp_vectors->tx_group.ring && tqp_vectors->rx_group.ring) {
> +			snprintf(tqp_vectors->name, HNAE3_INT_NAME_LEN - 1,
> +				 "%s-%s-%d", priv->netdev->name, "TxRx",
> +				 txrx_int_idx++);
> +			txrx_int_idx++;
> +		} else if (tqp_vectors->rx_group.ring) {
> +			snprintf(tqp_vectors->name, HNAE3_INT_NAME_LEN - 1,
> +				 "%s-%s-%d", priv->netdev->name, "Rx",
> +				 rx_int_idx++);
> +		} else if (tqp_vectors->tx_group.ring) {
> +			snprintf(tqp_vectors->name, HNAE3_INT_NAME_LEN - 1,
> +				 "%s-%s-%d", priv->netdev->name, "Tx",
> +				 tx_int_idx++);
> +		} else {
> +			/* Skip this unused q_vector */
> +			continue;
> +		}
> +
> +		tqp_vectors->name[HNAE3_INT_NAME_LEN - 1] = '\0';
> +
> +		ret = devm_request_irq(&pdev->dev, tqp_vectors->vector_irq,
> +				       hns3_irq_handle, 0, tqp_vectors->name,
> +				       tqp_vectors);
> +		if (ret) {
> +			netdev_err(priv->netdev, "request irq(%d) fail\n",
> +				   tqp_vectors->vector_irq);
> +			return ret;
> +		}
> +		disable_irq(tqp_vectors->vector_irq);

So why do the request_irq() just yet then?

> +
> +		tqp_vectors->irq_init_flag = HNS3_VECTOR_INITED;
> +	}
> +
> +	return 0;
> +}
> +
> +static void hns3_mask_vector_irq(struct hns3_enet_tqp_vector *tqp_vector,
> +				 u32 mask_en)
> +{
> +	writel(mask_en, tqp_vector->mask_addr);
> +}
> +
> +static void hns3_vector_enable(struct hns3_enet_tqp_vector *tqp_vector)
> +{
> +	napi_enable(&tqp_vector->napi);
> +	enable_irq(tqp_vector->vector_irq);
> +
> +	/* Enable vector */
> +	hns3_mask_vector_irq(tqp_vector, 1);
> +}
> +
> +static void hns3_vector_disable(struct hns3_enet_tqp_vector *tqp_vector)
> +{
> +	/* Disable vector */
> +	hns3_mask_vector_irq(tqp_vector, 0);
> +
> +	disable_irq(tqp_vector->vector_irq);
> +	napi_disable(&tqp_vector->napi);
> +}
> +
> +static void hns3_set_vector_coalesc_gl(struct hns3_enet_tqp_vector *tqp_vector,
> +				       u32 gl_value)
> +{
> +	/* this defines the configuration for GL (Interrupt Gap Limiter)
> +	 * GL defines inter interrupt gap.
> +	 * GL and RL(Rate Limiter) are 2 ways to acheive interrupt coalescing
> +	 */
> +	writel(gl_value, tqp_vector->mask_addr + HNS3_VECTOR_GL0_OFFSET);
> +	writel(gl_value, tqp_vector->mask_addr + HNS3_VECTOR_GL1_OFFSET);
> +	writel(gl_value, tqp_vector->mask_addr + HNS3_VECTOR_GL2_OFFSET);
> +}
> +
> +static void hns3_set_vector_coalesc_rl(struct hns3_enet_tqp_vector *tqp_vector,
> +				       u32 rl_value)
> +{
> +	/* this defines the configuration for RL (Interrupt Rate Limiter).
> +	 * Rl defines rate of interrupts i.e. number of interrupts-per-second
> +	 * GL and RL(Rate Limiter) are 2 ways to acheive interrupt coalescing
> +	 */
> +	writel(rl_value, tqp_vector->mask_addr + HNS3_VECTOR_RL_OFFSET);
> +}
> +
> +static void hns3_vector_gl_rl_init(struct hns3_enet_tqp_vector *tqp_vector)
> +{
> +	/* initialize the configuration for interrupt coalescing.
> +	 * 1. GL (Interrupt Gap Limiter)
> +	 * 2. RL (Interrupt Rate Limiter)
> +	 */
> +
> +	/* Default :enable interrupt coalesce */
> +	tqp_vector->rx_group.int_gl = HNS3_INT_GL_50K;
> +	tqp_vector->tx_group.int_gl = HNS3_INT_GL_50K;
> +	hns3_set_vector_coalesc_gl(tqp_vector, HNS3_INT_GL_50K);
> +	/* for now we are disabling Interrupt RL - we
> +	 * will re-enable later
> +	 */
> +	hns3_set_vector_coalesc_rl(tqp_vector, 0);
> +	tqp_vector->rx_group.flow_level = HNS3_FLOW_LOW;
> +	tqp_vector->tx_group.flow_level = HNS3_FLOW_LOW;
> +}
> +
> +static int hns3_nic_net_up(struct net_device *netdev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int i, j;

unsigned int i, j

> +	int ret;
> +
> +	ret = hns3_nic_init_irq(priv);
> +	if (ret) {
> +		netdev_err(netdev, "hns init irq failed! ret=%d\n", ret);
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
> +	netif_stop_queue(netdev);
> +
> +	for (j = i - 1; j >= 0; j--)
> +		hns3_vector_disable(&priv->tqp_vector[j]);
> +
> +	return ret;
> +}
> +
> +static int hns3_nic_net_open(struct net_device *netdev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	int ret;
> +
> +	netif_carrier_off(netdev);
> +
> +	ret = netif_set_real_num_tx_queues(netdev, h->kinfo.num_tqps);
> +	if (ret) {
> +		netdev_err(netdev, "netif_set_real_num_tx_queues fail, ret=%d!\n",
> +			   ret);
> +		return ret;
> +	}
> +
> +	ret = netif_set_real_num_rx_queues(netdev, h->kinfo.num_tqps);
> +	if (ret) {
> +		netdev_err(netdev,
> +			   "netif_set_real_num_rx_queues fail, ret=%d!\n", ret);
> +		return ret;
> +	}
> +
> +	ret = hns3_nic_net_up(netdev);
> +	if (ret) {
> +		netdev_err(netdev,
> +			   "hns net up fail, ret=%d!\n", ret);
> +		return ret;
> +	}
> +
> +	netif_carrier_on(netdev);
> +	netif_tx_wake_all_queues(netdev);
> +
> +	return 0;
> +}
> +
> +static void hns3_nic_net_down(struct net_device *netdev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	const struct hnae3_ae_ops *ops;
> +	int i;
> +
> +	netif_tx_stop_all_queues(netdev);
> +	netif_carrier_off(netdev);
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
> +static int hns3_nic_net_stop(struct net_device *netdev)
> +{
> +	hns3_nic_net_down(netdev);
> +
> +	return 0;
> +}
> +
> +void hns3_set_multicast_list(struct net_device *netdev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	struct netdev_hw_addr *ha = NULL;
> +
> +	if (!h)	{
> +		netdev_err(netdev, "hnae handle is null\n");
> +		return;
> +	}

This is not supposed to happen, and if it does surely you have a bug in
how the initialization is done.


> +
> +static int hns3_set_tso(struct sk_buff *skb, u32 *paylen,
> +			u16 *mss, u32 *type_cs_vlan_tso)
> +{
> +	u32 l4_offset, hdr_len;
> +	union l3_hdr_info l3;
> +	union l4_hdr_info l4;
> +	u32 l4_paylen;
> +	int ret;
> +
> +	if (skb_is_gso(skb)) {

Reduce the indentation by testing for !skb_is_gso() first and exit if
that's the case.


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

Jut pass an u16 size then?

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
> +			/* vlan packet*/
> +			if (protocol == htons(ETH_P_8021Q)) {
> +				protocol = vlan_get_protocol(skb);
> +				skb->protocol = protocol;

What is this assignment doing exactly?


> +static int hns3_fill_desc_tso(struct hns3_enet_ring *ring, void *priv,
> +			      int size, dma_addr_t dma, int frag_end,
> +			      enum hns_desc_type type)
> +{
> +	int frag_buf_num;
> +	int sizeoflast;
> +	int ret, k;

unsigned int k, frag_buf_num;

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

-ENOSPC rather?

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

Same here?

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

This sounds dangerous, can you come up with an exit condition somehow?

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
> +int hns3_nic_net_xmit_hw(struct net_device *netdev,
> +			 struct sk_buff *skb,
> +			 struct hns3_nic_ring_data *ring_data)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
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

Really?

> +
> +	/* Prefetch the data used later */
> +	prefetch(skb->data);
> +
> +	switch (priv->ops.maybe_stop_tx(&skb, &buf_num, ring)) {
> +	case -EBUSY:
> +		u64_stats_update_begin(&ring->syncp);
> +		ring->stats.tx_busy++;
> +		u64_stats_update_end(&ring->syncp);
> +
> +		goto out_net_tx_busy;
> +	case -ENOMEM:
> +		u64_stats_update_begin(&ring->syncp);
> +		ring->stats.sw_err_cnt++;
> +		u64_stats_update_end(&ring->syncp);
> +		netdev_err(netdev, "no memory to xmit!\n");
> +
> +		goto out_err_tx_ok;
> +	default:
> +		break;
> +	}

Move the u64_stats_update_begin() and u64_stats_update_end() out of the
switch case?

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
> +		netdev_err(netdev, "TX head DMA map failed\n");
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
> +			netdev_err(netdev, "TX frag(%d) DMA map failed\n", i);
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
> +	dev_queue = netdev_get_tx_queue(netdev, ring_data->queue_index);
> +	netdev_tx_sent_queue(dev_queue, skb->len);
> +
> +	wmb(); /* Commit all data before submit */

dma_wmb()?

> +
> +	hnae_queue_xmit(ring->tqp, buf_num);
> +
> +	u64_stats_update_begin(&ring->syncp);
> +	ring->stats.tx_pkts++;
> +	ring->stats.tx_bytes += skb->len;

This can cause use after free bugs, past the point where you tell the HW
to transmit, you can have you reclaiming process run and free your SKBs
in e.g: hard IRQ -> soft IRQ context, so this is not safe at all.

Besides that, you should always update your TX statistics in the
reclaiming/completion process because only then do you know for sure
that the HW has actually transmitted the packets. There is no such
guarantee here yet.

> +	u64_stats_update_end(&ring->syncp);
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
> +	netif_stop_subqueue(netdev, ring_data->queue_index);
> +	smp_mb(); /* Commit all data before submit */
> +
> +	return NETDEV_TX_BUSY;
> +}
> +
> +static netdev_tx_t hns3_nic_net_xmit(struct sk_buff *skb,
> +				     struct net_device *netdev)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	int ret;
> +
> +	ret = hns3_nic_net_xmit_hw(netdev, skb,
> +				   &tx_ring_data(priv, skb->queue_mapping));
> +	if (ret == NETDEV_TX_OK) {
> +		netif_trans_update(netdev);
> +		netdev->stats.tx_bytes += skb->len;
> +		netdev->stats.tx_packets++;
> +	}

Certainly not, this is an even bigger use after free.

> +
> +	return (netdev_tx_t)ret;

Just inline hns3_nic_net_xmit_hw() in this function, or remove
nic_net_xmit() and have them be consistent in returning netdev_tx_t.

> +}
> +
> +static int hns3_nic_net_set_mac_address(struct net_device *netdev, void *p)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	struct sockaddr *mac_addr = p;
> +	int ret;
> +
> +	if (!mac_addr || !is_valid_ether_addr((const u8 *)mac_addr->sa_data))
> +		return -EADDRNOTAVAIL;
> +
> +	ret = h->ae_algo->ops->set_mac_addr(h, mac_addr->sa_data);
> +	if (ret) {
> +		netdev_err(netdev, "set_mac_address fail, ret=%d!\n", ret);
> +		return ret;
> +	}
> +
> +	ether_addr_copy(netdev->dev_addr, mac_addr->sa_data);
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

Is this safe against pending transmissions? How do we not end-up with
some packes being submitting with the TSO descriptors and some with the
normal descriptors?

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
> +hns3_nic_get_stats64(struct net_device *netdev, struct rtnl_link_stats64 *stats)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	int queue_num = priv->ae_handle->kinfo.num_tqps;
> +	struct hns3_enet_ring *ring;
> +	unsigned int start;
> +	u64 tx_bytes = 0;
> +	u64 rx_bytes = 0;
> +	u64 tx_pkts = 0;
> +	u64 rx_pkts = 0;
> +	int idx;

unsigned int idx


> +static int hns3_setup_tc(struct net_device *netdev, u8 tc)
> +{
> +	struct hns3_nic_priv *priv = netdev_priv(netdev);
> +	struct hnae3_handle *h = priv->ae_handle;
> +	struct hnae3_knic_private_info *kinfo = &h->kinfo;
> +	int i, ret;

unsigned int i;

> +
> +	if (tc > HNAE3_MAX_TC)
> +		return -EINVAL;

Should not you be testing for the supported TC offloads that you are
being asked to offload somehow?

> +
> +	if (kinfo->num_tc == tc)
> +		return 0;
> +
> +	if (!netdev)
> +		return -EINVAL;
> +
> +	if (!tc) {
> +		netdev_reset_tc(netdev);
> +		return 0;
> +	}
> +
> +	/* Set num_tc for netdev */
> +	ret = netdev_set_num_tc(netdev, tc);
> +	if (ret)
> +		return ret;
> +
> +	/* Set per TC queues for the VSI */
> +	for (i = 0; i < HNAE3_MAX_TC; i++) {
> +		if (kinfo->tc_info[i].enable)
> +			netdev_set_tc_queue(netdev,
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

Oh ok, we are testing it here, can you just inline hns3_setup_tc() in
this function body then?




> +int hns3_clean_tx_ring(struct hns3_enet_ring *ring, int budget)
> +{
> +	struct net_device *netdev = ring->tqp->handle->kinfo.netdev;
> +	struct netdev_queue *dev_queue;
> +	int bytes, pkts;
> +	int head;
> +
> +	head = readl_relaxed(ring->tqp->io_base + HNS3_RING_TX_RING_HEAD_REG);
> +	rmb(); /* Make sure head is ready before touch any data */
> +
> +	if (is_ring_empty(ring) || head == ring->next_to_clean)
> +		return 0; /* no data to poll */
> +
> +	if (!is_valid_clean_head(ring, head)) {
> +		netdev_err(netdev, "wrong head (%d, %d-%d)\n", head,
> +			   ring->next_to_use, ring->next_to_clean);
> +
> +		u64_stats_update_begin(&ring->syncp);
> +		ring->stats.io_err_cnt++;
> +		u64_stats_update_end(&ring->syncp);
> +		return -EIO;
> +	}
> +
> +	bytes = 0;
> +	pkts = 0;
> +	while (head != ring->next_to_clean && budget) {

TX completion should not be bound to the NAPI budget, just clean the
entire ring.

> +		hns3_nic_reclaim_one_desc(ring, &bytes, &pkts);
> +		/* Issue prefetch for next Tx descriptor */
> +		prefetch(&ring->desc_cb[ring->next_to_clean]);
> +		budget--;
> +	}
> +
> +	ring->tqp_vector->tx_group.total_bytes += bytes;
> +	ring->tqp_vector->tx_group.total_packets += pkts;
> +
> +	dev_queue = netdev_get_tx_queue(netdev, ring->tqp->tqp_index);
> +	netdev_tx_completed_queue(dev_queue, pkts, bytes);

Where is flow control happening? Should not you wake the transmit queue
if you had to stop it somehow?

I kind of stopped reviewing here.
-- 
Florian
