From: Ivan Vecera <ivecera@redhat.com>
Subject: Re: [patch net-next 03/10] switchdev: bridge: Offload mc router ports
Date: Thu, 9 Feb 2017 16:11:24 +0100
Message-ID: <8902000e-28d3-f3f1-9d1c-edb0dbe176ba@redhat.com>
References: <1486648489-16455-1-git-send-email-jiri@resnulli.us>
 <1486648489-16455-4-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com,
        stephen@networkplumber.org, mlxsw@mellanox.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41692 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750941AbdBIPWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 10:22:16 -0500
In-Reply-To: <1486648489-16455-4-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dne 9.2.2017 v 14:54 Jiri Pirko napsal(a):
> From: Nogah Frankel <nogahf@mellanox.com>
>
> Offload the mc router ports list, whenever it is being changed.
> It is done because in some cases mc packets needs to be flooded to all
> the ports in this list.
>
> Signed-off-by: Nogah Frankel <nogahf@mellanox.com>
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  include/net/switchdev.h   |  2 ++
>  net/bridge/br_multicast.c | 15 +++++++++++++++
>  2 files changed, 17 insertions(+)
>
> diff --git a/include/net/switchdev.h b/include/net/switchdev.h
> index 2971c2a..929d6af 100644
> --- a/include/net/switchdev.h
> +++ b/include/net/switchdev.h
> @@ -46,6 +46,7 @@ enum switchdev_attr_id {
>  	SWITCHDEV_ATTR_ID_PORT_PARENT_ID,
>  	SWITCHDEV_ATTR_ID_PORT_STP_STATE,
>  	SWITCHDEV_ATTR_ID_PORT_BRIDGE_FLAGS,
> +	SWITCHDEV_ATTR_ID_PORT_MROUTER,
>  	SWITCHDEV_ATTR_ID_BRIDGE_AGEING_TIME,
>  	SWITCHDEV_ATTR_ID_BRIDGE_VLAN_FILTERING,
>  	SWITCHDEV_ATTR_ID_BRIDGE_MC_DISABLED,
> @@ -61,6 +62,7 @@ struct switchdev_attr {
>  		struct netdev_phys_item_id ppid;	/* PORT_PARENT_ID */
>  		u8 stp_state;				/* PORT_STP_STATE */
>  		unsigned long brport_flags;		/* PORT_BRIDGE_FLAGS */
> +		bool mrouter;				/* PORT_MROUTER */
>  		clock_t ageing_time;			/* BRIDGE_AGEING_TIME */
>  		bool vlan_filtering;			/* BRIDGE_VLAN_FILTERING */
>  		bool mc_disabled;			/* MC_DISABLED */
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 2add6d4..b760f26 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -1317,6 +1317,19 @@ br_multicast_update_query_timer(struct net_bridge *br,
>  	mod_timer(&query->timer, jiffies + br->multicast_querier_interval);
>  }
>
> +static void br_port_mc_router_state_change(struct net_bridge_port *p,
> +					   bool is_mc_router)
> +{
> +	struct switchdev_attr attr = {
> +		.orig_dev = p->dev,
> +		.id = SWITCHDEV_ATTR_ID_PORT_MROUTER,
> +		.flags = SWITCHDEV_F_DEFER,
> +		.u.mrouter = is_mc_router,
> +	};
> +
> +	switchdev_port_attr_set(p->dev, &attr);
> +}
> +
>  /*
>   * Add port to router_list
>   *  list is maintained ordered by pointer value
> @@ -1342,6 +1355,7 @@ static void br_multicast_add_router(struct net_bridge *br,
>  	else
>  		hlist_add_head_rcu(&port->rlist, &br->router_list);
>  	br_rtr_notify(br->dev, port, RTM_NEWMDB);
> +	br_port_mc_router_state_change(port, true);
>  }
>
>  static void br_multicast_mark_router(struct net_bridge *br,
> @@ -2049,6 +2063,7 @@ static void __del_port_router(struct net_bridge_port *p)
>  		return;
>  	hlist_del_init_rcu(&p->rlist);
>  	br_rtr_notify(p->br->dev, p, RTM_DELMDB);
> +	br_port_mc_router_state_change(p, false);
>
>  	/* don't allow timer refresh */
>  	if (p->multicast_router == MDB_RTR_TYPE_TEMP)
>
Acked-by: Ivan Vecera <ivecera@redhat.com>
