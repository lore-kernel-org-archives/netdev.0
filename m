From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [patch net-next v2 1/3] team: handle sending port list in the
 same way option list is sent
Date: Fri, 1 Feb 2013 19:30:46 +0100
Message-ID: <20130201183045.GA5822@localhost>
References: <1359742646-1485-1-git-send-email-jiri@resnulli.us>
 <1359742646-1485-2-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, fbl@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([174.127.110.175]:62231 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755464Ab3BATDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 14:03:32 -0500
Content-Disposition: inline
In-Reply-To: <1359742646-1485-2-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jiri,

On Fri, Feb 01, 2013 at 07:17:24PM +0100, Jiri Pirko wrote:
> Essentially do the same thing with port list as with option list.
> Multipart netlink message.
> Side effect is that port event message can send port which is not longer
> in team->port_list.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  drivers/net/team/team.c | 177 +++++++++++++++++++++++++-----------------------
>  1 file changed, 93 insertions(+), 84 deletions(-)
> 
> diff --git a/drivers/net/team/team.c b/drivers/net/team/team.c
> index 70d5d6b..738f744 100644
> --- a/drivers/net/team/team.c
> +++ b/drivers/net/team/team.c
> @@ -1965,30 +1965,6 @@ static void team_nl_team_put(struct team *team)
>  	dev_put(team->dev);
>  }
>  
> -static int team_nl_send_generic(struct genl_info *info, struct team *team,
> -				int (*fill_func)(struct sk_buff *skb,
> -						 struct genl_info *info,
> -						 int flags, struct team *team))
> -{
> -	struct sk_buff *skb;
> -	int err;
> -
> -	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> -	if (!skb)
> -		return -ENOMEM;
> -
> -	err = fill_func(skb, info, NLM_F_ACK, team);
> -	if (err < 0)
> -		goto err_fill;
> -
> -	err = genlmsg_unicast(genl_info_net(info), skb, info->snd_portid);
> -	return err;
> -
> -err_fill:
> -	nlmsg_free(skb);
> -	return err;
> -}
> -
>  typedef int team_nl_send_func_t(struct sk_buff *skb,
>  				struct team *team, u32 portid);
>  
> @@ -2333,16 +2309,57 @@ team_put:
>  	return err;
>  }
>  
> -static int team_nl_fill_port_list_get(struct sk_buff *skb,
> -				      u32 portid, u32 seq, int flags,
> -				      struct team *team,
> -				      bool fillall)
> +static int team_nl_fill_one_port_get(struct sk_buff *skb,
> +				     struct team_port *port)
> +{
> +	struct nlattr *port_item;
> +
> +	port_item = nla_nest_start(skb, TEAM_ATTR_ITEM_PORT);
> +	if (!port_item)
> +		goto nest_cancel;
> +	if (nla_put_u32(skb, TEAM_ATTR_PORT_IFINDEX, port->dev->ifindex))
> +		goto nest_cancel;
> +	if (port->changed) {
> +		if (nla_put_flag(skb, TEAM_ATTR_PORT_CHANGED))
> +			goto nest_cancel;
> +		port->changed = false;
> +	}
> +	if ((port->removed &&
> +	     nla_put_flag(skb, TEAM_ATTR_PORT_REMOVED)) ||
> +	    (port->state.linkup &&
> +	     nla_put_flag(skb, TEAM_ATTR_PORT_LINKUP)) ||
> +	    nla_put_u32(skb, TEAM_ATTR_PORT_SPEED, port->state.speed) ||
> +	    nla_put_u8(skb, TEAM_ATTR_PORT_DUPLEX, port->state.duplex))
> +		goto nest_cancel;
> +	nla_nest_end(skb, port_item);
> +	return 0;
> +
> +nest_cancel:
> +	nla_nest_cancel(skb, port_item);
> +	return -EMSGSIZE;
> +}
> +
> +static int team_nl_send_port_list_get(struct team *team, u32 portid, u32 seq,
> +				      int flags, team_nl_send_func_t *send_func,
> +				      struct team_port *one_port)
>  {
>  	struct nlattr *port_list;
> +	struct nlmsghdr *nlh;
>  	void *hdr;
>  	struct team_port *port;
> +	int err;
> +	struct sk_buff *skb = NULL;
> +	bool incomplete;
> +	int i;
>  
> -	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags,
> +	port = list_first_entry(&team->port_list, struct team_port, list);
> +
> +start_again:
> +	err = __send_and_alloc_skb(&skb, team, portid, send_func);
> +	if (err)
> +		return err;
> +
> +	hdr = genlmsg_put(skb, portid, seq, &team_nl_family, flags | NLM_F_MULTI,
>  			  TEAM_CMD_PORT_LIST_GET);
>  	if (!hdr)
>  		return -EMSGSIZE;
> @@ -2353,47 +2370,54 @@ static int team_nl_fill_port_list_get(struct sk_buff *skb,
>  	if (!port_list)
>  		goto nla_put_failure;
>  
> -	list_for_each_entry(port, &team->port_list, list) {
> -		struct nlattr *port_item;
> +	i = 0;
> +	incomplete = false;
>  
> -		/* Include only changed ports if fill all mode is not on */
> -		if (!fillall && !port->changed)
> -			continue;
> -		port_item = nla_nest_start(skb, TEAM_ATTR_ITEM_PORT);
> -		if (!port_item)
> -			goto nla_put_failure;
> -		if (nla_put_u32(skb, TEAM_ATTR_PORT_IFINDEX, port->dev->ifindex))
> -			goto nla_put_failure;
> -		if (port->changed) {
> -			if (nla_put_flag(skb, TEAM_ATTR_PORT_CHANGED))
> -				goto nla_put_failure;
> -			port->changed = false;
> +	/* If one port is selected, called wants to send port list containing
> +	 * only this port. Otherwise go through all listed ports and send all
> +	 */
> +	if (one_port) {
> +		err = team_nl_fill_one_port_get(skb, one_port);
> +		if (err)
> +			goto errout;
> +	} else {
> +		list_for_each_entry(port, &team->port_list, list) {
> +			err = team_nl_fill_one_port_get(skb, port);
> +			if (err) {
> +				if (err == -EMSGSIZE) {
> +					if (!i)
> +						goto errout;
> +					incomplete = true;
> +					break;
> +				}
> +				goto errout;
> +			}
> +			i++;
>  		}
> -		if ((port->removed &&
> -		     nla_put_flag(skb, TEAM_ATTR_PORT_REMOVED)) ||
> -		    (port->state.linkup &&
> -		     nla_put_flag(skb, TEAM_ATTR_PORT_LINKUP)) ||
> -		    nla_put_u32(skb, TEAM_ATTR_PORT_SPEED, port->state.speed) ||
> -		    nla_put_u8(skb, TEAM_ATTR_PORT_DUPLEX, port->state.duplex))
> -			goto nla_put_failure;
> -		nla_nest_end(skb, port_item);
>  	}
>  
>  	nla_nest_end(skb, port_list);
> -	return genlmsg_end(skb, hdr);
> +	genlmsg_end(skb, hdr);
> +	if (incomplete)
> +		goto start_again;
> +
> +send_done:
> +	nlh = nlmsg_put(skb, portid, seq, NLMSG_DONE, 0, flags | NLM_F_MULTI);
> +	if (!nlh) {
> +		err = __send_and_alloc_skb(&skb, team, portid, send_func);
> +		if (err)
> +			goto errout;
> +		goto send_done;
> +	}

I'd suggest to use netlink_dump_start for this, so you don't need to
manually create the NLMSG_DONE message.

> +
> +	return send_func(skb, team, portid);
>  
>  nla_put_failure:
> +	err = -EMSGSIZE;
> +errout:
>  	genlmsg_cancel(skb, hdr);
> -	return -EMSGSIZE;
> -}
> -
> -static int team_nl_fill_port_list_get_all(struct sk_buff *skb,
> -					  struct genl_info *info, int flags,
> -					  struct team *team)
> -{
> -	return team_nl_fill_port_list_get(skb, info->snd_portid,
> -					  info->snd_seq, NLM_F_ACK,
> -					  team, true);
> +	nlmsg_free(skb);
> +	return err;
>  }
>  
>  static int team_nl_cmd_port_list_get(struct sk_buff *skb,
> @@ -2406,7 +2430,8 @@ static int team_nl_cmd_port_list_get(struct sk_buff *skb,
>  	if (!team)
>  		return -EINVAL;
>  
> -	err = team_nl_send_generic(info, team, team_nl_fill_port_list_get_all);
> +	err = team_nl_send_port_list_get(team, info->snd_portid, info->snd_seq,
> +					 NLM_F_ACK, team_nl_send_unicast, NULL);
>  
>  	team_nl_team_put(team);
>  
> @@ -2457,27 +2482,11 @@ static int team_nl_send_event_options_get(struct team *team,
>  					sel_opt_inst_list);
>  }
>  
> -static int team_nl_send_event_port_list_get(struct team *team)
> +static int team_nl_send_event_port_get(struct team *team,
> +				       struct team_port *port)
>  {
> -	struct sk_buff *skb;
> -	int err;
> -	struct net *net = dev_net(team->dev);
> -
> -	skb = nlmsg_new(NLMSG_DEFAULT_SIZE, GFP_KERNEL);
> -	if (!skb)
> -		return -ENOMEM;
> -
> -	err = team_nl_fill_port_list_get(skb, 0, 0, 0, team, false);
> -	if (err < 0)
> -		goto err_fill;
> -
> -	err = genlmsg_multicast_netns(net, skb, 0, team_change_event_mcgrp.id,
> -				      GFP_KERNEL);
> -	return err;
> -
> -err_fill:
> -	nlmsg_free(skb);
> -	return err;
> +	return team_nl_send_port_list_get(team, 0, 0, 0, team_nl_send_multicast,
> +					  port);
>  }
>  
>  static int team_nl_init(void)
> @@ -2550,7 +2559,7 @@ static void __team_port_change_send(struct team_port *port, bool linkup)
>  	port->state.duplex = 0;
>  
>  send_event:
> -	err = team_nl_send_event_port_list_get(port->team);
> +	err = team_nl_send_event_port_get(port->team, port);
>  	if (err && err != -ESRCH)
>  		netdev_warn(port->team->dev, "Failed to send port change of device %s via netlink (err %d)\n",
>  			    port->dev->name, err);
> -- 
> 1.8.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
