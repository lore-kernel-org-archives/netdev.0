From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] netpoll: Don't call driver methods from interrupt context.
Date: Wed, 05 Mar 2014 11:14:02 -0800
Message-ID: <87ob1kxxtx.fsf@xmission.com>
References: <874n3fow2i.fsf@xmission.com>
	<20140304.160825.893718566461536483.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, mpm@selenic.com,
	satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:44611 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755626AbaCETOL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Mar 2014 14:14:11 -0500
In-Reply-To: <20140304.160825.893718566461536483.davem@davemloft.net> (David
	Miller's message of "Tue, 04 Mar 2014 16:08:25 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Mon, 03 Mar 2014 12:40:05 -0800
>
>> <IRQ>  [<ffffffff8104934c>] warn_slowpath_common+0x85/0x9d
>> [<ffffffff8104937e>] warn_slowpath_null+0x1a/0x1c
>> [<ffffffff81429aa7>] skb_release_head_state+0x7b/0xe1
>> [<ffffffff814297e1>] __kfree_skb+0x16/0x81
>> [<ffffffff814298a0>] consume_skb+0x54/0x69
>> [<ffffffffa015925b>] bnx2_tx_int.clone.6+0x1b0/0x33e [bnx2]
>
> Other drivers, such as bnx2x, uses dev_kfree_skb_any(), probably
> exactly to deal with this situation.
>
> If in_irq() is true or interrupts are disabled, __dev_kfree_skb_any
> will use __dev_kfree_skb_irq, which will queue up the SKB and schedule
> a software interrupt to do the actual work.
>
> For example, see this commit, which we probably just need to duplicate
> into other poll supporting drivers:

Fair enough.  I will cook up a patch to see about doing this.
Especially as this appears to be all that drivers need to do differently
in practice.

Looking at bnx2x I found at least one more case that needs to be
changed, so for netpoll supporting drivers I will plan on simply
changing all of the dev_kfree_skb instances to dev_kfree_skby_any
so I don't have to worry about missing one by not having audited the
code properly.

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 9d7419e0390b..e790d654f35f 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -3719,7 +3719,7 @@ netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev)
                        struct bnx2x_eth_q_stats *q_stats =
                                bnx2x_fp_qstats(bp, txdata->parent_fp);
                        q_stats->driver_filtered_tx_pkt++;
-                       dev_kfree_skb(skb);
+                       dev_kfree_skb_any(skb);
                        return NETDEV_TX_OK;
                }
                bnx2x_fp_qstats(bp, txdata->parent_fp)->driver_xoff++;

Eric



> commit 40955532bc9d865999dfc58b7896605d58650655
> Author: Vladislav Zolotarov <vladz@broadcom.com>
> Date:   Sun May 22 10:06:58 2011 +0000
>
>     bnx2x: call dev_kfree_skb_any instead of dev_kfree_skb
>     
>     replace function calls when possible call in both irq/non-irq contexts
>     
>     Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
>     Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
>
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
> index 64d01e7..d5bd35b 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.c
> +++ b/drivers/net/bnx2x/bnx2x_cmn.c
> @@ -131,7 +131,7 @@ static u16 bnx2x_free_tx_pkt(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  
>  	/* release skb */
>  	WARN_ON(!skb);
> -	dev_kfree_skb(skb);
> +	dev_kfree_skb_any(skb);
>  	tx_buf->first_bd = 0;
>  	tx_buf->skb = NULL;
>  
> @@ -465,7 +465,7 @@ static void bnx2x_tpa_stop(struct bnx2x *bp, struct bnx2x_fastpath *fp,
>  		} else {
>  			DP(NETIF_MSG_RX_STATUS, "Failed to allocate new pages"
>  			   " - dropping packet!\n");
> -			dev_kfree_skb(skb);
> +			dev_kfree_skb_any(skb);
>  		}
>  
>  
> diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
> index fab161e..1a3545b 100644
> --- a/drivers/net/bnx2x/bnx2x_cmn.h
> +++ b/drivers/net/bnx2x/bnx2x_cmn.h
> @@ -840,7 +840,7 @@ static inline int bnx2x_alloc_rx_skb(struct bnx2x *bp,
>  	mapping = dma_map_single(&bp->pdev->dev, skb->data, fp->rx_buf_size,
>  				 DMA_FROM_DEVICE);
>  	if (unlikely(dma_mapping_error(&bp->pdev->dev, mapping))) {
> -		dev_kfree_skb(skb);
> +		dev_kfree_skb_any(skb);
>  		return -ENOMEM;
>  	}
>  
