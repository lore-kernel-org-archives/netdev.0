From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: bridge: add a br_set_state helper function
Date: Tue, 30 Sep 2014 16:00:20 -0700
Message-ID: <542B3604.2070206@gmail.com>
References: <1412117947-796-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, bridge@lists.linux-foundation.org,
	stephen@networkplumber.org, vyasevich@gmail.com, jiri@resnulli.us
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:65411 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbaI3XAp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 19:00:45 -0400
Received: by mail-pd0-f177.google.com with SMTP id v10so1523035pde.8
        for <netdev@vger.kernel.org>; Tue, 30 Sep 2014 16:00:44 -0700 (PDT)
In-Reply-To: <1412117947-796-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/30/2014 03:59 PM, Florian Fainelli wrote:
> In preparation for being able to propagate port states to e.g: notifiers
> or other kernel parts, do not manipulate the port state directly, but
> instead use a helper function which will allow us to do a bit more than
> just setting the state.

I sent the wrong version of the patch, but I would still appreciate if
you could comment on the idea. Thanks!

> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  net/bridge/br_if.c        |  2 +-
>  net/bridge/br_multicast.c |  2 +-
>  net/bridge/br_netlink.c   |  2 +-
>  net/bridge/br_private.h   |  1 +
>  net/bridge/br_stp.c       | 15 ++++++++++-----
>  net/bridge/br_stp_if.c    |  4 ++--
>  net/bridge/br_stp_timer.c |  4 ++--
>  7 files changed, 18 insertions(+), 12 deletions(-)
> 
> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
> index a9f54a9b6690..7b7289ca2992 100644
> --- a/net/bridge/br_if.c
> +++ b/net/bridge/br_if.c
> @@ -332,7 +332,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
>  	p->port_no = index;
>  	p->flags = BR_LEARNING | BR_FLOOD;
>  	br_init_port(p);
> -	p->state = BR_STATE_DISABLED;
> +	br_set_state(p, BR_STATE_DISABLED);
>  	br_stp_port_timer_init(p);
>  	br_multicast_add_port(p);
>  
> diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
> index 648d79ccf462..1f4fd22c84fc 100644
> --- a/net/bridge/br_multicast.c
> +++ b/net/bridge/br_multicast.c
> @@ -645,7 +645,7 @@ struct net_bridge_port_group *br_multicast_new_port_group(
>  
>  	p->addr = *group;
>  	p->port = port;
> -	p->state = state;
> +	br_set_state(p, state);
>  	rcu_assign_pointer(p->next, next);
>  	hlist_add_head(&p->mglist, &port->mglist);
>  	setup_timer(&p->timer, br_multicast_port_group_expired,
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 0fa66b83685f..2ff9706647f2 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -301,7 +301,7 @@ static int br_set_port_state(struct net_bridge_port *p, u8 state)
>  	    (!netif_oper_up(p->dev) && state != BR_STATE_DISABLED))
>  		return -ENETDOWN;
>  
> -	p->state = state;
> +	br_set_state(p, state);
>  	br_log_state(p);
>  	br_port_state_selection(p->br);
>  	return 0;
> diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
> index f53592fc3ef9..4ff82fc0e79c 100644
> --- a/net/bridge/br_private.h
> +++ b/net/bridge/br_private.h
> @@ -766,6 +766,7 @@ static inline void br_nf_core_fini(void) {}
>  
>  /* br_stp.c */
>  void br_log_state(const struct net_bridge_port *p);
> +void br_set_stp_state(const struct net_bridge_port *p);
>  struct net_bridge_port *br_get_port(struct net_bridge *br, u16 port_no);
>  void br_init_port(struct net_bridge_port *p);
>  void br_become_designated_port(struct net_bridge_port *p);
> diff --git a/net/bridge/br_stp.c b/net/bridge/br_stp.c
> index 3c86f0538cbb..a859373b7d68 100644
> --- a/net/bridge/br_stp.c
> +++ b/net/bridge/br_stp.c
> @@ -36,6 +36,11 @@ void br_log_state(const struct net_bridge_port *p)
>  		br_port_state_names[p->state]);
>  }
>  
> +void br_set_state(const struct net_bridge_port *p, unsigned int state)
> +{
> +	p->state = state;
> +}
> +
>  /* called under bridge lock */
>  struct net_bridge_port *br_get_port(struct net_bridge *br, u16 port_no)
>  {
> @@ -107,7 +112,7 @@ static void br_root_port_block(const struct net_bridge *br,
>  	br_notice(br, "port %u(%s) tried to become root port (blocked)",
>  		  (unsigned int) p->port_no, p->dev->name);
>  
> -	p->state = BR_STATE_LISTENING;
> +	br_set_state(p, BR_STATE_LISTENING);
>  	br_log_state(p);
>  	br_ifinfo_notify(RTM_NEWLINK, p);
>  
> @@ -387,7 +392,7 @@ static void br_make_blocking(struct net_bridge_port *p)
>  		    p->state == BR_STATE_LEARNING)
>  			br_topology_change_detection(p->br);
>  
> -		p->state = BR_STATE_BLOCKING;
> +		br_set_state(p, BR_STATE_BLOCKING);
>  		br_log_state(p);
>  		br_ifinfo_notify(RTM_NEWLINK, p);
>  
> @@ -404,13 +409,13 @@ static void br_make_forwarding(struct net_bridge_port *p)
>  		return;
>  
>  	if (br->stp_enabled == BR_NO_STP || br->forward_delay == 0) {
> -		p->state = BR_STATE_FORWARDING;
> +		br_set_state(p, BR_STATE_FORWARDING);
>  		br_topology_change_detection(br);
>  		del_timer(&p->forward_delay_timer);
>  	} else if (br->stp_enabled == BR_KERNEL_STP)
> -		p->state = BR_STATE_LISTENING;
> +		br_set_state(p, BR_STATE_LISTENING);
>  	else
> -		p->state = BR_STATE_LEARNING;
> +		br_set_state(p, BR_STATE_LEARNING);
>  
>  	br_multicast_enable_port(p);
>  	br_log_state(p);
> diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
> index 189ba1e7d851..41146872c1b4 100644
> --- a/net/bridge/br_stp_if.c
> +++ b/net/bridge/br_stp_if.c
> @@ -37,7 +37,7 @@ void br_init_port(struct net_bridge_port *p)
>  {
>  	p->port_id = br_make_port_id(p->priority, p->port_no);
>  	br_become_designated_port(p);
> -	p->state = BR_STATE_BLOCKING;
> +	br_set_state(p, BR_STATE_BLOCKING);
>  	p->topology_change_ack = 0;
>  	p->config_pending = 0;
>  }
> @@ -100,7 +100,7 @@ void br_stp_disable_port(struct net_bridge_port *p)
>  
>  	wasroot = br_is_root_bridge(br);
>  	br_become_designated_port(p);
> -	p->state = BR_STATE_DISABLED;
> +	br_set_state(p, BR_STATE_DISABLED);
>  	p->topology_change_ack = 0;
>  	p->config_pending = 0;
>  
> diff --git a/net/bridge/br_stp_timer.c b/net/bridge/br_stp_timer.c
> index 558c46d19e05..4fcaa67750fd 100644
> --- a/net/bridge/br_stp_timer.c
> +++ b/net/bridge/br_stp_timer.c
> @@ -87,11 +87,11 @@ static void br_forward_delay_timer_expired(unsigned long arg)
>  		 (unsigned int) p->port_no, p->dev->name);
>  	spin_lock(&br->lock);
>  	if (p->state == BR_STATE_LISTENING) {
> -		p->state = BR_STATE_LEARNING;
> +		br_set_state(p, BR_STATE_LEARNING);
>  		mod_timer(&p->forward_delay_timer,
>  			  jiffies + br->forward_delay);
>  	} else if (p->state == BR_STATE_LEARNING) {
> -		p->state = BR_STATE_FORWARDING;
> +		br_set_state(p, BR_STATE_FORWARDING);
>  		if (br_is_designated_for_some_port(br))
>  			br_topology_change_detection(br);
>  		netif_carrier_on(br->dev);
> 
