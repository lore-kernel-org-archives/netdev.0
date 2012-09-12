From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_tx_action: Call trace_consume_skb() instead of
 trace_kfree_skb()
Date: Wed, 12 Sep 2012 09:33:19 +0200
Message-ID: <1347435199.13103.690.camel@edumazet-glaptop>
References: <1347406098-22071-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sanagi.koki@jp.fujitsu.com,
	davem@davemloft.net
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:56034 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751143Ab2ILHdY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2012 03:33:24 -0400
Received: by eekc1 with SMTP id c1so987363eek.19
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2012 00:33:22 -0700 (PDT)
In-Reply-To: <1347406098-22071-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-11 at 18:28 -0500, Shawn Bohrer wrote:
> Call trace_consume_skb() instead of trace_kfree_skb() as skbs are
> removed from the completion_queue during transmit.  This avoids false
> positives from dropwatch/drop_monitor making them more useful.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
> 
> In my case I seem to hit this tracepoint for every packet I transmit so
> these appear to be false positives to me.  Perhaps there are cases where
> you could hit this and it is a real packet drop?
> 
>  net/core/dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/core/dev.c b/net/core/dev.c
> index 8398836..00774ce 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3015,7 +3015,7 @@ static void net_tx_action(struct softirq_action *h)
>  			clist = clist->next;
>  
>  			WARN_ON(atomic_read(&skb->users));
> -			trace_kfree_skb(skb, net_tx_action);
> +			trace_consume_skb(skb);
>  			__kfree_skb(skb);
>  		}
>  	}
> -- 
> 1.7.7.6
> 
> 


Problem here is : we dont know if caller of dev_kfree_skb_irq(skb)
wanted to drop or consume skb.

(We dont have a dev_consume_skb_irq(skb) function)

For example, drivers/infiniband/ulp/ipoib/ipoib_main.c function
path_free() does :

while ((skb = __skb_dequeue(&path->queue)))
	dev_kfree_skb_irq(skb);

Are these packets dropped or consumed, I dont really know...

Note : NAPI drivers dont use dev_kfree_skb_irq(skb).

What is the NIC driver you are using, I thought it was mellanox (wich is
NAPI) ?
