From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: Re: [patch net-next 15/26] bonding: allow notifications for
 bond_set_slave_link_state
Date: Wed, 2 Dec 2015 12:27:09 +0100
Message-ID: <565ED58D.2040002@cumulusnetworks.com>
References: <1448977744-17930-1-git-send-email-jiri@resnulli.us>
 <1448977744-17930-16-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, eladr@mellanox.com,
	yotamg@mellanox.com, ogerlitz@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:34420 "EHLO
	mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757095AbbLBL1L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Dec 2015 06:27:11 -0500
Received: by wmvv187 with SMTP id v187so249975056wmv.1
        for <netdev@vger.kernel.org>; Wed, 02 Dec 2015 03:27:10 -0800 (PST)
In-Reply-To: <1448977744-17930-16-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/01/2015 02:48 PM, Jiri Pirko wrote:
> From: Jiri Pirko <jiri@mellanox.com>
> 
> Similar to state notifications.
> 
> We allow caller to indicate if the notification should happen now or later,
> depending on if he holds rtnl mutex or not. Introduce bond_slave_link_notify
> function (similar to bond_slave_state_notify) which is later on called
> with rtnl mutex and goes over slaves and executes delayed notification.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  drivers/net/bonding/bond_main.c | 54 +++++++++++++++++++++++++++--------------
>  include/net/bonding.h           | 32 +++++++++++++++++++++---
>  2 files changed, 65 insertions(+), 21 deletions(-)
> 
[snip]
> diff --git a/include/net/bonding.h b/include/net/bonding.h
> index c1740a2..50496ec 100644
> --- a/include/net/bonding.h
> +++ b/include/net/bonding.h
> @@ -165,7 +165,8 @@ struct slave {
>  	u8     backup:1,   /* indicates backup slave. Value corresponds with
>  			      BOND_STATE_ACTIVE and BOND_STATE_BACKUP */
>  	       inactive:1, /* indicates inactive slave */
> -	       should_notify:1; /* indicateds whether the state changed */
> +	       should_notify:1, /* indicateds whether the state changed */
> +	       should_notify_link:1; /* indicateds whether the link changed */

s/indicateds/indicates/

>  	u8     duplex;
>  	u32    original_mtu;
>  	u32    link_failure_count;
> @@ -504,10 +505,35 @@ static inline bool bond_is_slave_inactive(struct slave *slave)
>  	return slave->inactive;
>  }
[snip]
> +
> +static inline void bond_slave_link_notify(struct bonding *bond)
> +{
> +	struct list_head *iter;
> +	struct slave *tmp;
> +
> +	bond_for_each_slave(bond, tmp, iter) {
> +		if (tmp->should_notify_link) {
> +			bond_queue_slave_event(tmp);
> +			tmp->should_notify_link = 0;
> +		}
> +	}
>  }
>  
>  static inline __be32 bond_confirm_addr(struct net_device *dev, __be32 dst, __be32 local)
> 
