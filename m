From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH RFC net-next] net: core: Pass XPS select queue decision to
 skb_tx_hash
Date: Tue, 29 Mar 2016 17:18:44 -0700
Message-ID: <56FB1B64.40301@gmail.com>
References: <1459290252-4121-1-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	Tom Herbert <tom@herbertland.com>,
	Jiri Pirko <jiri@resnulli.us>,
	"David S. Miller" <davem@davemloft.net>,
	John Fastabend <john.r.fastabend@intel.com>
To: Saeed Mahameed <saeedm@mellanox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:35677 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751135AbcC3ATC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 20:19:02 -0400
Received: by mail-pa0-f53.google.com with SMTP id td3so25912303pab.2
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 17:19:02 -0700 (PDT)
In-Reply-To: <1459290252-4121-1-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-03-29 03:24 PM, Saeed Mahameed wrote:
> Currently XPS select queue decision is final and overrides/ignores all other
> select queue parameters such as QoS TC, RX recording.
> 
> This patch makes get_xps_queue value as a hint for skb_tx_hash, which will decide
> whether to use this hint as is or to tweak it a little to provide the correct TXQ.
> 
> This will fix bugs in cases such that TC QoS offload (tc_to_txq mapping) and XPS mapping
> are configured but select queue will only respect the XPS configuration which will skip
> the TC QoS queue selection and thus will not satisfy the QoS configuration.
> 
> RFC because I want to discuss how we would like the final behavior of the
> __netdev_pick_tx, with this patch it goes as follows:
> 
> netdev_pick_tx(skb):
>         hint = get_xps_queue
>         txq = skb_tx_hash(skb, hint)
> 
> skb_tx_hash(skb, hint):
>         if (skb_rx_queue_recorded(skb))
>                 return skb_get_rx_queue(skb);
> 
>         queue_offset = 0;
>         if (dev->num_tc)
>                 queue_offset = tc_queue_offset[tc];
> 
>         hash = hint < 0 ? skb_get_hash(skb) : hint;
>         return hash + queue_offset;
> 
> i.e: instead of blindly return the XPS decision, we pass it to skb_tx_hash which can make the final
> decision for us, select queue will now respect and combine XPS and TC QoS tc_to_txq mappings.
> 
> Also there is one additional behavioral change that recorded rx queues will
> now override the XPS configuration.
> 
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_tx.c |    2 +-
>  include/linux/netdevice.h                  |    6 +++---
>  net/core/dev.c                             |   10 ++++++----
>  3 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> index c0d7b72..873cf49 100644
> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
> @@ -693,7 +693,7 @@ u16 mlx4_en_select_queue(struct net_device *dev, struct sk_buff *skb,
>  	u8 up = 0;
>  
>  	if (dev->num_tc)
> -		return skb_tx_hash(dev, skb);
> +		return skb_tx_hash(dev, skb, -1);
>  

I would prefer to not have another strange quirk users have to remember
in order to do tx classification. So with this change depending on the
driver the queue selection precedence changes. In short I agree with
the problem statement but think we can find a better solution.

One idea that comes to mind is we can have a tc action to force the
queue selection? Now that we have the egress tc hook it would probably
be fairly cheap to implement and if users want this behavior they can
ask for it explicitly.

If your thinking about tc stuff we could fix the tooling to set this
action when ever dcb is turned on or hardware rate limiting is enabled,
etc. And even if we wanted we could have the driver add the rule in the
cases where firmware protocols are configuring the QOS/etc.


>  	if (skb_vlan_tag_present(skb))
>  		up = skb_vlan_tag_get(skb) >> VLAN_PRIO_SHIFT;
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index cb0d5d0..ad81ffe 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -3130,16 +3130,16 @@ static inline int netif_set_xps_queue(struct net_device *dev,
>  #endif
>  
>  u16 __skb_tx_hash(const struct net_device *dev, struct sk_buff *skb,
> -		  unsigned int num_tx_queues);
> +		  unsigned int num_tx_queues, int txq_hint);
>  

[...]

And all this seems like it would only ever be called by drivers select
queue routines which I really wish we could kill off one of these days
instead of add to. Now if the signal is something higher in the stack
and not the driver I think it is OK.

.John
