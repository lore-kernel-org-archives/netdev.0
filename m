From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next v2 1/5] net: bridge: Notify on bridge device
 mrouter state changes
Date: Mon, 9 Oct 2017 12:19:02 +0200
Message-ID: <13d5789a-90e1-2ffd-bb9f-15a257f5710e@redhat.com>
References: <20171009091535.1315-1-jiri@resnulli.us>
 <20171009091535.1315-2-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33500 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753906AbdJIKTH (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 06:19:07 -0400
In-Reply-To: <20171009091535.1315-2-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9.10.2017 11:15, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Add the SWITCHDEV_ATTR_ID_BRIDGE_MROUTER switchdev notification type, used
> to indicate whether the bridge is or isn't mrouter. Notify when the bridge
> changes its state, similarly to the already existing bridged port mrouter
> notifications.
> 
> The notification uses the switchdev_attr.u.mrouter boolean flag to indicate
> the current bridge mrouter status. Thus, it only indicates whether the
> bridge is currently used as an mrouter or not, and does not indicate the
> exact mrouter state of the bridge (learning, permanent, etc.).
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
> v1->v2:
>  - use the timer_pending to distinguish between learning-on and
>    learning-off states
> ---
>  include/net/switchdev.h   |  1 +
>  net/bridge/br_multicast.c | 38 +++++++++++++++++++++++++++++++++++---
>  2 files changed, 36 insertions(+), 3 deletions(-)
> 
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index d767b79..d756fbe 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -51,6 +51,7 @@ enum switchdev_attr_id {
>  	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>  	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
>  	SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
> +	SWITCHDEV_ATTR_ID_BRIDGE_MROUTER,
>  };
>  
>  struct switchdev_attr {
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 8dc5c8d..bd50550 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -859,8 +859,32 @@ static void br_multicast_router_expired(unsigned long data)
>  	spin_unlock(&br->multicast_lock);
>  }
>  
> +static void br_mc_router_state_change(struct net_bridge *p,
> +				      bool is_mc_router)
> +{
> +	struct switchdev_attr attr = {
> +		.orig_dev = p->dev,
> +		.id = SWITCHDEV_ATTR_ID_BRIDGE_MROUTER,
> +		.flags = SWITCHDEV_F_DEFER,
> +		.u.mrouter = is_mc_router,
> +	};
> +
> +	switchdev_port_attr_set(p->dev, &attr);
> +}
> +
>  static void br_multicast_local_router_expired(unsigned long data)
>  {
> +	struct net_bridge *br = (struct net_bridge *)data;
> +
> +	spin_lock(&br->multicast_lock);
> +	if (br->multicast_router == MDB_RTR_TYPE_DISABLED ||
> +	    br->multicast_router == MDB_RTR_TYPE_PERM ||
> +	    timer_pending(&br->multicast_router_timer))
> +		goto out;
> +
> +	br_mc_router_state_change(br, false);
> +out:
> +	spin_unlock(&br->multicast_lock);
>  }
>  
>  static void br_multicast_querier_expired(struct net_bridge *br,
> @@ -1364,9 +1388,12 @@ static void br_multicast_mark_router(struct net_bridge *br,
>  	unsigned long now = jiffies;
>  
>  	if (!port) {
> -		if (br->multicast_router == MDB_RTR_TYPE_TEMP_QUERY)
> +		if (br->multicast_router == MDB_RTR_TYPE_TEMP_QUERY) {
> +			if (!timer_pending(&br->multicast_router_timer))
> +				br_mc_router_state_change(br, true);
>  			mod_timer(&br->multicast_router_timer,
>  				  now + br->multicast_querier_interval);
> +		}
>  		return;
>  	}
>  
> @@ -1952,7 +1979,7 @@ void br_multicast_init(struct net_bridge *br)
>  
>  	spin_lock_init(&br->multicast_lock);
>  	setup_timer(&br->multicast_router_timer,
> -		    br_multicast_local_router_expired, 0);
> +		    br_multicast_local_router_expired, (unsigned long)br);
>  	setup_timer(&br->ip4_other_query.timer,
>  		    br_ip4_multicast_querier_expired, (unsigned long)br);
>  	setup_timer(&br->ip4_own_query.timer, br_ip4_multicast_query_expired,
> @@ -2042,9 +2069,14 @@ int br_multicast_set_router(struct net_bridge *br, unsigned long val)
>  	switch (val) {
>  	case MDB_RTR_TYPE_DISABLED:
>  	case MDB_RTR_TYPE_PERM:
> +		br_mc_router_state_change(br, val == MDB_RTR_TYPE_PERM);
>  		del_timer(&br->multicast_router_timer);
> -		/* fall through */
> +		br->multicast_router = val;
> +		err = 0;
> +		break;
>  	case MDB_RTR_TYPE_TEMP_QUERY:
> +		if (br->multicast_router != MDB_RTR_TYPE_TEMP_QUERY)
> +			br_mc_router_state_change(br, false);
>  		br->multicast_router = val;
>  		err = 0;
>  		break;
> 

Reviewed by: Ivan Vecera <ivecera@redhat.com>
