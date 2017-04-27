From: Matthias Brugger <matthias.bgg@gmail.com>
Subject: Re: [PATCH net v4 1/3] net: hns: support deferred probe when can not
 obtain irq
Date: Thu, 27 Apr 2017 13:58:15 +0200
Message-ID: <e6e0b752-9a9a-5d0f-c9bf-1be242eaea09@gmail.com>
References: <1493261053-68197-1-git-send-email-yankejian@huawei.com>
 <1493261053-68197-2-git-send-email-yankejian@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxarm@huawei.com
To: Yankejian <yankejian@huawei.com>, davem@davemloft.net,
        salil.mehta@huawei.com, yisen.zhuang@huawei.com,
        lipeng321@huawei.com, zhouhuiru@huawei.com,
        huangdaode@hisilicon.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:32963 "EHLO
        mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752585AbdD0L6T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 07:58:19 -0400
Received: by mail-wm0-f66.google.com with SMTP id y10so4086837wmh.0
        for <netdev@vger.kernel.org>; Thu, 27 Apr 2017 04:58:18 -0700 (PDT)
In-Reply-To: <1493261053-68197-2-git-send-email-yankejian@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 27/04/17 04:44, Yankejian wrote:
> From: lipeng <lipeng321@huawei.com>
>
> In the hip06 and hip07 SoCs, the interrupt lines from the
> DSAF controllers are connected to mbigen hw module.
> The mbigen module is probed with module_init, and, as such,
> is not guaranteed to probe before the HNS driver. So we need
> to support deferred probe.
>
> Signed-off-by: lipeng <lipeng321@huawei.com>
> Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
> Reviewed-by: Matthias Brugger <mbrugger@suse.com>
> ---
> change log:
> V3 -> V4:
> 1. Delete redundant commit message;
> 2. add Reviewed-by: Matthias Brugger <mbrugger@suse.com>;
>
> V2 -> V3:
> 1. Check return value when  platform_get_irq in hns_rcb_get_cfg;
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c | 4 +++-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c | 8 +++++++-
>  drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h | 2 +-
>  3 files changed, 11 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> index 6ea8722..a41cf95 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_ppe.c
> @@ -510,7 +510,9 @@ int hns_ppe_init(struct dsaf_device *dsaf_dev)
>
>  		hns_ppe_get_cfg(dsaf_dev->ppe_common[i]);
>
> -		hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
> +		ret = hns_rcb_get_cfg(dsaf_dev->rcb_common[i]);
> +		if (ret)
> +			goto get_rcb_cfg_fail;

a2185587ade7 ("net: hns: Simplify the exception sequence in hns_ppe_init()")
deleted get_rcb_cfg_fail label. This does not compile. Please rebase 
against net-next.

Best regards,
Matthias

>  	}
>
>  	for (i = 0; i < HNS_PPE_COM_NUM; i++)
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> index f0ed80d6..673a5d3 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.c
> @@ -452,7 +452,7 @@ static int hns_rcb_get_base_irq_idx(struct rcb_common_cb *rcb_common)
>   *hns_rcb_get_cfg - get rcb config
>   *@rcb_common: rcb common device
>   */
> -void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
> +int hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
>  {
>  	struct ring_pair_cb *ring_pair_cb;
>  	u32 i;
> @@ -477,10 +477,16 @@ void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common)
>  		ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] =
>  		is_ver1 ? platform_get_irq(pdev, base_irq_idx + i * 2 + 1) :
>  			  platform_get_irq(pdev, base_irq_idx + i * 3);
> +		if ((ring_pair_cb->virq[HNS_RCB_IRQ_IDX_TX] == -EPROBE_DEFER) ||
> +		    (ring_pair_cb->virq[HNS_RCB_IRQ_IDX_RX] == -EPROBE_DEFER))
> +			return -EPROBE_DEFER;
> +
>  		ring_pair_cb->q.phy_base =
>  			RCB_COMM_BASE_TO_RING_BASE(rcb_common->phy_base, i);
>  		hns_rcb_ring_pair_get_cfg(ring_pair_cb);
>  	}
> +
> +	return 0;
>  }
>
>  /**
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> index 99b4e1b..3d7b484 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_dsaf_rcb.h
> @@ -110,7 +110,7 @@ struct rcb_common_cb {
>  void hns_rcb_common_free_cfg(struct dsaf_device *dsaf_dev, u32 comm_index);
>  int hns_rcb_common_init_hw(struct rcb_common_cb *rcb_common);
>  void hns_rcb_start(struct hnae_queue *q, u32 val);
> -void hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
> +int hns_rcb_get_cfg(struct rcb_common_cb *rcb_common);
>  void hns_rcb_get_queue_mode(enum dsaf_mode dsaf_mode,
>  			    u16 *max_vfn, u16 *max_q_per_vf);
>
>
