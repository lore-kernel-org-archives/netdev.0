From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: add missing call to genlmsg_end
Date: Sat, 31 Dec 2016 21:41:46 -0500
Message-ID: <20170101024145.GA4719@neilslaptop.think-freely.org>
References: <20161231201157.10800-1-wr0112358@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Reiter Wolfgang <wr0112358@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161231201157.10800-1-wr0112358@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Dec 31, 2016 at 09:11:57PM +0100, Reiter Wolfgang wrote:
> Update nlmsg_len field with genlmsg_end to enable userspace processing
> using nlmsg_next helper. Also adds error handling.
> 
> Signed-off-by: Reiter Wolfgang <wr0112358@gmail.com>
> ---
>  net/core/drop_monitor.c | 33 ++++++++++++++++++++++++---------
>  1 file changed, 24 insertions(+), 9 deletions(-)
> 
> diff --git a/net/core/drop_monitor.c b/net/core/drop_monitor.c
> index 8e0c063..f465bad 100644
> --- a/net/core/drop_monitor.c
> +++ b/net/core/drop_monitor.c
> @@ -75,6 +75,7 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
>  	struct nlattr *nla;
>  	struct sk_buff *skb;
>  	unsigned long flags;
> +	void *msg_header;
>  
>  	al = sizeof(struct net_dm_alert_msg);
>  	al += dm_hit_limit * sizeof(struct net_dm_drop_point);
> @@ -82,17 +83,31 @@ static struct sk_buff *reset_per_cpu_data(struct per_cpu_dm_data *data)
>  
>  	skb = genlmsg_new(al, GFP_KERNEL);
>  
> -	if (skb) {
> -		genlmsg_put(skb, 0, 0, &net_drop_monitor_family,
> -				0, NET_DM_CMD_ALERT);
> -		nla = nla_reserve(skb, NLA_UNSPEC,
> -				  sizeof(struct net_dm_alert_msg));
> -		msg = nla_data(nla);
> -		memset(msg, 0, al);
> -	} else {
> -		mod_timer(&data->send_timer, jiffies + HZ / 10);
> +	if (!skb)
> +		goto err;
> +
> +	msg_header = genlmsg_put(skb, 0, 0, &net_drop_monitor_family,
> +				 0, NET_DM_CMD_ALERT);
> +	if (!msg_header) {
> +		nlmsg_free(skb);
> +		skb = NULL;
> +		goto err;
> +	}
> +	nla = nla_reserve(skb, NLA_UNSPEC,
> +			  sizeof(struct net_dm_alert_msg));
> +	if (!nla) {
> +		nlmsg_free(skb);
> +		skb = NULL;
> +		goto err;
>  	}
> +	msg = nla_data(nla);
> +	memset(msg, 0, al);
> +	genlmsg_end(skb, msg_header);
> +	goto out;
>  
> +err:
> +	mod_timer(&data->send_timer, jiffies + HZ / 10);
> +out:
>  	spin_lock_irqsave(&data->lock, flags);
>  	swap(data->skb, skb);
>  	spin_unlock_irqrestore(&data->lock, flags);
> -- 
> 2.9.3
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
