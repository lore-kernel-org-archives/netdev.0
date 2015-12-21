From: Luuk Paulussen <Luuk.Paulussen@alliedtelesis.co.nz>
Subject: Re: [PATCH] Octeon: Fix logic for waking octoen ethernet tx queue.
Date: Mon, 21 Dec 2015 22:53:06 +0000
Message-ID: <567882D2.1020406@alliedtelesis.co.nz>
References: <1450299572-11012-1-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:46467 "EHLO
	gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbbLUWxR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 17:53:17 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(Client did not present a certificate)
	by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id A47FE800E6
	for <netdev@vger.kernel.org>; Tue, 22 Dec 2015 11:53:11 +1300 (NZDT)
In-Reply-To: <1450299572-11012-1-git-send-email-luuk.paulussen@alliedtelesis.co.nz>
Content-Language: en-US
Content-ID: <B4FD9DBA8EE4914693275958FF279F81@atlnz.lc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see that this patch has been marked as "Not applicable" in patchworx.
Is this because I have sent it to the wrong place?  I also noticed that
I forgot to add a signoff line or CC a maintainer, so I'm happy to
resend if those are the issues.

The patch is a bugfix for an ethernet driver in the staging dir.


On 12/17/2015 09:59 AM, Luuk Paulussen wrote:
> The ethernet driver tx queue is stopped when the queue length exceeds
> what is allowed.  It should only be started again when the queue length
> is back within bounds.
>
> The logic here was just reenabling the queue when any buffers had been
> freed.  the queue was stopped whenever the length exceeded 1000
> (MAX_OUT_QUEUE_DEPTH), but then was essentially immediately started again.
> On a congested link, the queue length would just keep increasing up to around
> 8000 (for average size packets), at which point the hardware would start
> refusing the packets and they would begin to be dropped.
> This prevented the qdisc layer from effectively managing and prioritising
> packets, as essentially all packets were being allowed into the driver queue
> and then were being dropped by the hardware.
>
> This change only restarts the queue if the length is less than 1000
> (MAX_OUT_QUEUE_DEPTH).
>
> Reviewed-by: Kyeong Yoo <kyeong.yoo@alliedtelesis.co.nz>
> Reviewed-by: Chris Packham <chris.packham@alliedtelesis.co.nz>
> Reviewed-by: Richard Laing <richard.laing@alliedtelesis.co.nz>
> ---
>   drivers/staging/octeon/ethernet-tx.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/staging/octeon/ethernet-tx.c b/drivers/staging/octeon/ethernet-tx.c
> index c053c4a..31292fe 100644
> --- a/drivers/staging/octeon/ethernet-tx.c
> +++ b/drivers/staging/octeon/ethernet-tx.c
> @@ -126,7 +126,7 @@ static void cvm_oct_free_tx_skbs(struct net_device *dev)
>   		}
>   		total_remaining += skb_queue_len(&priv->tx_free_list[qos]);
>   	}
> -	if (total_freed >= 0 && netif_queue_stopped(dev))
> +	if (total_remaining < MAX_OUT_QUEUE_DEPTH && netif_queue_stopped(dev))
>   		netif_wake_queue(dev);
>   	if (total_remaining)
>   		cvm_oct_kick_tx_poll_watchdog();

-- 

*Luuk Paulussen*

Software Team Lead
*Allied Telesis Labs* | 27 Nazareth Ave | Christchurch 8024 | New Zealand
Phone: +64 3 3399242
Web: *alliedtelesis*.com <http://alliedtelesis.com/>

<%20http://go.alliedtelesis.com/icmg2015>
