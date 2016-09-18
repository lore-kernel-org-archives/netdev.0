From: Tariq Toukan <ttoukan.linux@gmail.com>
Subject: Re: [net PATCH V3] mlx4: fix XDP_TX is acting like XDP_PASS on TX
 ring full
Date: Sun, 18 Sep 2016 11:30:52 +0300
Message-ID: <aa4e2527-8e67-fe10-bb10-d96969181e9c@gmail.com>
References: <20160917164650.53e68314@redhat.com>
 <20160917154753.3130.16986.stgit@firesoul>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, bblanco@plumgrid.com, rana.shahot@gmail.com,
        "David S. Miller" <davem@davemloft.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
        tariqt@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36293 "EHLO
        mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750849AbcIRIa4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 18 Sep 2016 04:30:56 -0400
Received: by mail-wm0-f65.google.com with SMTP id b184so10116930wma.3
        for <netdev@vger.kernel.org>; Sun, 18 Sep 2016 01:30:55 -0700 (PDT)
In-Reply-To: <20160917154753.3130.16986.stgit@firesoul>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 17/09/2016 6:48 PM, Jesper Dangaard Brouer wrote:
> The XDP_TX action can fail transmitting the frame in case the TX ring
> is full or port is down.  In case of TX failure it should drop the
> frame, and not as now call 'break' which is the same as XDP_PASS.
>
> Fixes: 9ecc2d86171a ("net/mlx4_en: add xdp forwarding and data write support")
> Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>
> ---
> Is this goto lable inside a switch case too ugly?
I thought about getting "shared code" outside of the switch case, but I 
don't think it will look any better.

Given this label, we can change the goto position by re-ordering the 
cases, swapping between XDP_TX and default so that the XDP_TX is 
immediately followed by XDP_ABORTED and XDP_DROP, and won't need a goto 
operation.
Instead, it will be used in default case, which should not be reached 
anyway. This saves a jump for actual (error) cases.

Something like this:

act = bpf_prog_run_xdp(xdp_prog, &xdp);
switch (act) {
case XDP_PASS:
         break;
default:
         bpf_warn_invalid_xdp_action(act);
         goto xdp_drop;
case XDP_TX:
         if (!mlx4_en_xmit_frame(frags, dev,
                                 length, tx_index,
                                 &doorbell_pending))
                 goto consumed;
case XDP_ABORTED:
case XDP_DROP:
xdp_drop:
         if (mlx4_en_rx_recycle(ring, frags))
                 goto consumed;
         goto next;
}

> Note, this fix have nothing to do with the page-refcnt bug I reported.
>
>   drivers/net/ethernet/mellanox/mlx4/en_rx.c |    3 ++-
>   1 file changed, 2 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_rx.c b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> index 2040dad8611d..9eadda431965 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_rx.c
> @@ -906,11 +906,12 @@ int mlx4_en_process_rx_cq(struct net_device *dev, struct mlx4_en_cq *cq, int bud
>   							length, tx_index,
>   							&doorbell_pending))
>   					goto consumed;
> -				break;
> +				goto xdp_drop; /* Drop on xmit failure */
>   			default:
>   				bpf_warn_invalid_xdp_action(act);
>   			case XDP_ABORTED:
>   			case XDP_DROP:
> +			xdp_drop:
>   				if (mlx4_en_rx_recycle(ring, frags))
>   					goto consumed;
>   				goto next;
>
But also this way is fine by me.

Regards,
Tariq
