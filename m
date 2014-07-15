From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v2 05/11] openvswitch: Add recirc action
Date: Tue, 15 Jul 2014 19:42:07 +0200
Message-ID: <53C567EF.60208@redhat.com>
References: <1405444503-17000-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Andy Zhou <azhou@nicira.com>
To: Pravin B Shelar <pshelar@nicira.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1973 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754573AbaGORmL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 13:42:11 -0400
In-Reply-To: <1405444503-17000-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 07:15 PM, Pravin B Shelar wrote:
> From: Andy Zhou <azhou@nicira.com>
> 
> Recirculation implementation for Linux kernel data path.
> 
> Signed-off-by: Andy Zhou <azhou@nicira.com>
> Acked-by: Jesse Gross <jesse@nicira.com>
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/uapi/linux/openvswitch.h |  2 ++
>  net/openvswitch/actions.c        | 46 +++++++++++++++++++++++++++++++++++++-
>  net/openvswitch/datapath.c       | 48 ++++++++++++++++++++++++++++------------
>  net/openvswitch/datapath.h       |  8 +++++--
>  net/openvswitch/flow.h           |  1 +
>  net/openvswitch/flow_netlink.c   | 16 ++++++++++++++
>  6 files changed, 104 insertions(+), 17 deletions(-)
>  };
<snip>
> diff --git a/net/openvswitch/actions.c b/net/openvswitch/actions.c
> index 56c22f0..8875697 100644
> --- a/net/openvswitch/actions.c
> +++ b/net/openvswitch/actions.c
> @@ -1,5 +1,5 @@
>  /*
> - * Copyright (c) 2007-2013 Nicira, Inc.
> + * Copyright (c) 2007-2014 Nicira, Inc.
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of version 2 of the GNU General Public
> @@ -520,6 +520,26 @@ static int execute_set_action(struct sk_buff *skb,
>  	return err;
>  }
>  
> +static int execute_recirc(struct datapath *dp, struct sk_buff *skb,
> +			  const struct nlattr *a)
> +{
> +	struct sw_flow_key recirc_key;
> +	const struct vport *p = OVS_CB(skb)->input_vport;
> +	uint32_t hash = OVS_CB(skb)->pkt_key->ovs_flow_hash;
> +	int err;
> +
> +	err = ovs_flow_extract(skb, p->port_no, &recirc_key);
> +	if (err)
> +		return err;
> +
> +	recirc_key.ovs_flow_hash = hash;
> +	recirc_key.recirc_id = nla_get_u32(a);
> +
> +	ovs_dp_process_packet_with_key(skb, &recirc_key);
> +
> +	return 0;
> +}
> +
>  /* Execute a list of actions against 'skb'. */
>  static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>  			const struct nlattr *attr, int len, bool keep_skb)
> @@ -564,6 +584,30 @@ static int do_execute_actions(struct datapath *dp, struct sk_buff *skb,
>  			err = pop_vlan(skb);
>  			break;
>  
> +		case OVS_ACTION_ATTR_RECIRC: {
> +			struct sk_buff *recirc_skb;
> +			const bool last_action = (a->nla_len == rem);
> +
> +			if (__this_cpu_read(net_xmit_recursion) > NET_RECURSION_LIMIT) {
> +				net_crit_ratelimited("Net recursion limit readched\n");
> +				break;
> +			}
> +
> +			if (!last_action || keep_skb)
> +				recirc_skb = skb_clone(skb, GFP_ATOMIC);
				^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
skb_clone can return NULL and later recirc_skb will be dereferenced in
execute_recirc(). Shouldn't there be a NULL check in this "if" case ?


> +			else
> +				recirc_skb = skb;
> +
> +			__this_cpu_inc(net_xmit_recursion);
> +			err = execute_recirc(dp, recirc_skb, a);
> +			__this_cpu_dec(net_xmit_recursion);
> +
> +			if (last_action || err)
> +				return err;
> +
> +			break;
> +		}
> +
>  		case OVS_ACTION_ATTR_SET:
>  			err = execute_set_action(skb, nla_data(a));
>  			break;
<snip>
