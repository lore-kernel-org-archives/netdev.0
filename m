From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next v3 05/17] rtnl: expose physical switch id for
 particular device
Date: Tue, 25 Nov 2014 10:16:55 -0500
Message-ID: <20141125151655.GE27416@gospo.rtplab.test>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-6-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, tgraf@suug.ch, dborkman@redhat.com,
	ogerlitz@mellanox.com, jesse@nicira.com, pshelar@nicira.com,
	azhou@nicira.com, ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ext3.cumulusnetworks.com ([198.211.106.187]:37382 "EHLO
	ext3.cumulusnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750780AbaKYPRL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 10:17:11 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-6-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 25, 2014 at 11:28:36AM +0100, Jiri Pirko wrote:
> The netdevice represents a port in a switch, it will expose
> IFLA_PHYS_SWITCH_ID value via rtnl. Two netdevices with the same value
> belong to one physical switch.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> Reviewed-by: Thomas Graf <tgraf@suug.ch>
> Acked-by: John Fastabend <john.r.fastabend@intel.com>

Acked-by: Andy Gospodarek <gospo@cumulusnetworks.com>

> ---
> v2->v3:
> -changed "sw" string to "switch" to avoid confusion
> v1->v2:
> -no change
> ---
>  include/uapi/linux/if_link.h |  1 +
>  net/core/rtnetlink.c         | 26 +++++++++++++++++++++++++-
>  2 files changed, 26 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 7072d83..4163753 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
> @@ -145,6 +145,7 @@ enum {
>  	IFLA_CARRIER,
>  	IFLA_PHYS_PORT_ID,
>  	IFLA_CARRIER_CHANGES,
> +	IFLA_PHYS_SWITCH_ID,
>  	__IFLA_MAX
>  };
>  
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 0fb3a68..bd5e783 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -44,6 +44,7 @@
>  
>  #include <linux/inet.h>
>  #include <linux/netdevice.h>
> +#include <net/switchdev.h>
>  #include <net/ip.h>
>  #include <net/protocol.h>
>  #include <net/arp.h>
> @@ -869,7 +870,8 @@ static noinline size_t if_nlmsg_size(const struct net_device *dev,
>  	       + rtnl_port_size(dev, ext_filter_mask) /* IFLA_VF_PORTS + IFLA_PORT_SELF */
>  	       + rtnl_link_get_size(dev) /* IFLA_LINKINFO */
>  	       + rtnl_link_get_af_size(dev) /* IFLA_AF_SPEC */
> -	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_PORT_ID */
> +	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN) /* IFLA_PHYS_PORT_ID */
> +	       + nla_total_size(MAX_PHYS_ITEM_ID_LEN); /* IFLA_PHYS_SWITCH_ID */
>  }
>  
>  static int rtnl_vf_ports_fill(struct sk_buff *skb, struct net_device *dev)
> @@ -968,6 +970,24 @@ static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
>  	return 0;
>  }
>  
> +static int rtnl_phys_switch_id_fill(struct sk_buff *skb, struct net_device *dev)
> +{
> +	int err;
> +	struct netdev_phys_item_id psid;
> +
> +	err = netdev_switch_parent_id_get(dev, &psid);
> +	if (err) {
> +		if (err == -EOPNOTSUPP)
> +			return 0;
> +		return err;
> +	}
> +
> +	if (nla_put(skb, IFLA_PHYS_SWITCH_ID, psid.id_len, psid.id))
> +		return -EMSGSIZE;
> +
> +	return 0;
> +}
> +
>  static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  			    int type, u32 pid, u32 seq, u32 change,
>  			    unsigned int flags, u32 ext_filter_mask)
> @@ -1040,6 +1060,9 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>  	if (rtnl_phys_port_id_fill(skb, dev))
>  		goto nla_put_failure;
>  
> +	if (rtnl_phys_switch_id_fill(skb, dev))
> +		goto nla_put_failure;
> +
>  	attr = nla_reserve(skb, IFLA_STATS,
>  			sizeof(struct rtnl_link_stats));
>  	if (attr == NULL)
> @@ -1199,6 +1222,7 @@ static const struct nla_policy ifla_policy[IFLA_MAX+1] = {
>  	[IFLA_NUM_RX_QUEUES]	= { .type = NLA_U32 },
>  	[IFLA_PHYS_PORT_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>  	[IFLA_CARRIER_CHANGES]	= { .type = NLA_U32 },  /* ignored */
> +	[IFLA_PHYS_SWITCH_ID]	= { .type = NLA_BINARY, .len = MAX_PHYS_ITEM_ID_LEN },
>  };
>  
>  static const struct nla_policy ifla_info_policy[IFLA_INFO_MAX+1] = {
> -- 
> 1.9.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
