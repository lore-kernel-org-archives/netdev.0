From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: [PATCH 2/5] net/cpsw: don't continue if we miss to allocate rx
 skbs
Date: Thu, 18 Apr 2013 14:09:16 +0200
Message-ID: <516FE26C.5040601@linutronix.de>
References: <1366235536-15744-1-git-send-email-bigeasy@linutronix.de> <1366235536-15744-3-git-send-email-bigeasy@linutronix.de> <516FDDEE.6030906@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tglx@linutronix.de,
	"David S. Miller" <davem@davemloft.net>
To: Mugunthan V N <mugunthanvnm@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:44290 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755301Ab3DRMJT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Apr 2013 08:09:19 -0400
In-Reply-To: <516FDDEE.6030906@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/18/2013 01:50 PM, Mugunthan V N wrote:

>> diff --git a/drivers/net/ethernet/ti/cpsw.c
>> b/drivers/net/ethernet/ti/cpsw.c
>> index e2ba702..3b22a36 100644
>> --- a/drivers/net/ethernet/ti/cpsw.c
>> +++ b/drivers/net/ethernet/ti/cpsw.c
>> @@ -912,14 +912,16 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>               struct sk_buff *skb;
>>                 ret = -ENOMEM;
>> -            skb = netdev_alloc_skb_ip_align(priv->ndev,
>> -                            priv->rx_packet_max);
>> +            skb = __netdev_alloc_skb_ip_align(priv->ndev,
>> +                    priv->rx_packet_max, GFP_KERNEL);
>>               if (!skb)
>> -                break;
>> +                goto err_cleanup;
>>               ret = cpdma_chan_submit(priv->rxch, skb, skb->data,
>>                       skb_tailroom(skb), 0, GFP_KERNEL);
>> -            if (WARN_ON(ret < 0))
>> -                break;
>> +            if (ret < 0) {
>> +                kfree_skb(skb);
>> +                goto err_cleanup;
> Why you need to close the device even you have some skb allocated and
> submitted successfully. Can allow the device to continue with lower
> performance

Because this should not happen. If you run out-of-memory because an
application is going crazy than you won't have much anyway. If you
configured too much skbs then this should be fixed as well.

>> +            }
>>           }
>>           /* continue even if we didn't manage to submit all
>>            * receive descs
>> @@ -944,6 +946,10 @@ static int cpsw_ndo_open(struct net_device *ndev)
>>       if (priv->data.dual_emac)
>>           priv->slaves[priv->emac_port].open_stat = true;
>>       return 0;
>> +
>> +err_cleanup:
>> +    cpdma_ctlr_stop(priv->dma);
>> +    return ret;
>>   }
> only cpdma is halted and allocated skb are released, need to have other
> calls like pm_runtime_put_sync, close host and slave ports

Okay, will fix.

> 
> Regards
> Mugunthan V N


Sebastian
