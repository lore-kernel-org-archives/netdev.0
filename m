From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next 01/10] switchdev: bridge: Offload multicast
 disabled
Date: Thu, 9 Feb 2017 16:10:58 +0100
Message-ID: <85dfe8bb-6f62-7803-a6d0-e75c65f6eb4c@redhat.com>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
 <1486648489-16455-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52936 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753659AbdBIP3T (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 10:29:19 -0500
In-Reply-To: <1486648489-16455-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 9.2.2017 v 14:54 Jiri Pirko napsal(a):
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Offload multicast disabled flag, for more accurate mc flood behavior:
> When it is on, the mdb should be ignored.
> When it is off, unregistered mc packets should be flooded to mc router
> ports.
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/switchdev.h   |  2 ++
>  net/bridge/br_multicast.c | 16 ++++++++++++++++
>  2 files changed, 18 insertions(+)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index eba80c4..2971c2a 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -48,6 +48,7 @@ enum switchdev_attr_id {
>  	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
>  	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>  	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
> +	SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
>  };
>
>  struct switchdev_attr {
> @@ -62,6 +63,7 @@ struct switchdev_attr {
>  		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
>  		clock_t ageing_time;			/* BRIDGE_AGEING_TIME */
>  		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
> +		bool mc_disabled;			/* MC_DISABLED */
>  	} u;
>  };
>
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 1de3438..8c0e896 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -27,6 +27,7 @@
>  #include <linux/inetdevice.h>
>  #include <linux/mroute.h>
>  #include <net/ip.h>
> +#include <net/switchdev.h>
>  #if IS_ENABLED(CONFIG_IPV6)
>  #include <net/ipv6.h>
>  #include <net/mld.h>
> @@ -1007,6 +1008,18 @@ static void br_ip6_multicast_port_query_expired(unsigned long data)
>  }
>  #endif
>
> +static void br_mc_disabled_update(struct net_device *dev, bool value)
> +{
> +	struct switchdev_attr attr = {
> +		.orig_dev = dev,
> +		.id = SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
> +		.flags = SWITCHDEV_F_DEFER,
> +		.u.mc_disabled = value,
> +	};
> +
> +	switchdev_port_attr_set(dev, &attr);
> +}
> +
>  int br_multicast_add_port(struct net_bridge_port *port)
>  {
>  	port->multicast_router = MDB_RTR_TYPE_TEMP_QUERY;
> @@ -1019,6 +1032,8 @@ int br_multicast_add_port(struct net_bridge_port *port)
>  	setup_timer(&port->ip6_own_query.timer,
>  		    br_ip6_multicast_port_query_expired, (unsigned long)port);
>  #endif
> +	br_mc_disabled_update(port->dev, port->br->multicast_disabled);
> +
>  	port->mcast_stats = netdev_alloc_pcpu_stats(struct bridge_mcast_stats);
>  	if (!port->mcast_stats)
>  		return -ENOMEM;
> @@ -2121,6 +2136,7 @@ int br_multicast_toggle(struct net_bridge *br, unsigned long val)
>  	if (br->multicast_disabled == !val)
>  		goto unlock;
>
> +	br_mc_disabled_update(br->dev, !val);
>  	br->multicast_disabled = !val;
>  	if (br->multicast_disabled)
>  		goto unlock;
>
Acked-by: Ivan Vecera <ivecera@redhat.com>
