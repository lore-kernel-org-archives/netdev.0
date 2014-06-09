From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 4/8] enic: alloc/free rx_cpu_rmap
Date: Mon, 09 Jun 2014 22:44:56 +0400
Message-ID: <539600A8.3010703@cogentembedded.com>
References: <1402338773-5996-1-git-send-email-_govind@gmx.com> <1402338773-5996-5-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ssujith@cisco.com, gvaradar@cisco.com, benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:45502 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbaFISo5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2014 14:44:57 -0400
Received: by mail-lb0-f176.google.com with SMTP id p9so3253162lbv.21
        for <netdev@vger.kernel.org>; Mon, 09 Jun 2014 11:44:56 -0700 (PDT)
In-Reply-To: <1402338773-5996-5-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 06/09/2014 10:32 PM, Govindarajulu Varadarajan wrote:

> rx_cpu_rmap provides the reverse irq cpu affinity. This patch allocates and
> sets drivers netdev->rx_cpu_rmap accordingly.

> rx_cpu_rmap is set in enic_request_intr() which is called by enic_open and
> rx_cpu_rmap is freed in enic_free_intr() which is called by enic_stop.

> This is used by Accelerated RFS.

> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
>   drivers/net/ethernet/cisco/enic/enic_main.c | 36 +++++++++++++++++++++++++++++
>   1 file changed, 36 insertions(+)

> diff --git a/drivers/net/ethernet/cisco/enic/enic_main.c b/drivers/net/ethernet/cisco/enic/enic_main.c
> index f32f828..f4508d9 100644
> --- a/drivers/net/ethernet/cisco/enic/enic_main.c
> +++ b/drivers/net/ethernet/cisco/enic/enic_main.c
[...]
> @@ -1192,6 +1195,33 @@ static void enic_calc_int_moderation(struct enic *enic, struct vnic_rq *rq)
>   	pkt_size_counter->small_pkt_bytes_cnt = 0;
>   }
>
> +#ifdef CONFIG_RFS_ACCEL
> +static void enic_free_rx_cpu_rmap(struct enic *enic)
> +{
> +	free_irq_cpu_rmap(enic->netdev->rx_cpu_rmap);
> +	enic->netdev->rx_cpu_rmap = NULL;
> +}
> +
> +static inline void enic_set_rx_cpu_rmap(struct enic *enic)

    No need to use *inline* in a .c file, the compiler should figure it out.

> +{
> +	int i, res;
> +
> +	if (vnic_dev_get_intr_mode(enic->vdev) == VNIC_DEV_INTR_MODE_MSIX) {
> +		enic->netdev->rx_cpu_rmap = alloc_irq_cpu_rmap(enic->rq_count);
> +		if (unlikely(!enic->netdev->rx_cpu_rmap))
> +			return;
> +		for (i = 0; i < enic->rq_count; i++) {
> +			res = irq_cpu_rmap_add(enic->netdev->rx_cpu_rmap,
> +					       enic->msix_entry[i].vector);
> +			if (unlikely(res)) {
> +				enic_free_rx_cpu_rmap(enic);
> +				return;
> +			}
> +		}
> +	}
> +}

    It's better to do the following here:

#else
static void enic_free_rx_cpu_rmap(struct enic *enic)
{
}
static void enic_set_rx_cpu_rmap(struct enic *enic)
{
}

> +#endif
> +
>   static int enic_poll_msix(struct napi_struct *napi, int budget)
>   {
>   	struct net_device *netdev = napi->dev;
> @@ -1267,6 +1297,9 @@ static void enic_free_intr(struct enic *enic)
>   	struct net_device *netdev = enic->netdev;
>   	unsigned int i;
>
> +#ifdef CONFIG_RFS_ACCEL
> +	enic_free_rx_cpu_rmap(enic);
> +#endif

    ... so that you can avoid #ifdef's at the call sites.

WBR, Sergei
