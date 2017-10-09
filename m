From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next v2 2/5] net: bridge: Export bridge multicast
 router state
Date: Mon, 9 Oct 2017 12:19:12 +0200
Message-ID: <e4b3ca34-d88b-0b6a-da0f-f3a8a35fcbfc@redhat.com>
References: <20171009091535.1315-1-jiri@resnulli.us>
 <20171009091535.1315-3-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        nogahf@mellanox.com, mlxsw@mellanox.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        stephen@networkplumber.org, nbd@nbd.name, roopa@cumulusnetworks.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44252 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751636AbdJIKTQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 9 Oct 2017 06:19:16 -0400
In-Reply-To: <20171009091535.1315-3-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9.10.2017 11:15, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Add an access function that, given a bridge netdevice, returns whether the
> bridge device is currently an mrouter or not. The function uses the already
> existing br_multicast_is_router function to check that.
> 
> This function is needed in order to allow ports that join an already
> existing bridge to know the current mrouter state of the bridge device.
> Together with the bridge device mrouter ports switchdev notifications, it
> is possible to have full offloading of the semantics of the bridge device
> mcast router state.
> 
> Due to the fact that the bridge multicast router status can change in
> packet RX path, take the multicast_router bridge spinlock to protect the
> read.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Nogah Frankel <nogahf@mellanox.com>
> Reviewed-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/linux/if_bridge.h |  5 +++++
>  net/bridge/br_multicast.c | 12 ++++++++++++
>  2 files changed, 17 insertions(+)
> 
> diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
> index 316ee11..02639eb 100644
> --- a/include/linux/if_bridge.h
> +++ b/include/linux/if_bridge.h
> @@ -64,6 +64,7 @@ int br_multicast_list_adjacent(struct net_device *dev,
>  bool br_multicast_has_querier_anywhere(struct net_device *dev, int proto);
>  bool br_multicast_has_querier_adjacent(struct net_device *dev, int proto);
>  bool br_multicast_enabled(const struct net_device *dev);
> +bool br_multicast_router(const struct net_device *dev);
>  #else
>  static inline int br_multicast_list_adjacent(struct net_device *dev,
>  					     struct list_head *br_ip_list)
> @@ -84,6 +85,10 @@ static inline bool br_multicast_enabled(const struct net_device *dev)
>  {
>  	return false;
>  }
> +static inline bool br_multicast_router(const struct net_device *dev)
> +{
> +	return false;
> +}
>  #endif
>  
>  #if IS_ENABLED(CONFIG_BRIDGE) && IS_ENABLED(CONFIG_BRIDGE_VLAN_FILTERING)
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index bd50550..7947e04 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -2216,6 +2216,18 @@ bool br_multicast_enabled(const struct net_device *dev)
>  }
>  EXPORT_SYMBOL_GPL(br_multicast_enabled);
>  
> +bool br_multicast_router(const struct net_device *dev)
> +{
> +	struct net_bridge *br = netdev_priv(dev);
> +	bool is_router;
> +
> +	spin_lock_bh(&br->multicast_lock);
> +	is_router = br_multicast_is_router(br);
> +	spin_unlock_bh(&br->multicast_lock);
> +	return is_router;
> +}
> +EXPORT_SYMBOL_GPL(br_multicast_router);
> +
>  int br_multicast_set_querier(struct net_bridge *br, unsigned long val)
>  {
>  	unsigned long max_delay;
> 

Reviewed by: Ivan Vecera <ivecera@redhat.com>
