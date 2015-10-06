From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net] openvswitch: Fix egress tunnel info.
Date: Tue, 6 Oct 2015 17:42:05 +0200
Message-ID: <20151006174205.799ac484@griffin>
References: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37330 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764AbbJFPmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Oct 2015 11:42:09 -0400
In-Reply-To: <1444067897-1951-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Some more feedback after doing a deeper review.

On Mon,  5 Oct 2015 10:58:17 -0700, Pravin B Shelar wrote:
> --- a/drivers/net/geneve.c
> +++ b/drivers/net/geneve.c
> @@ -703,6 +703,32 @@ err:
>  	return NETDEV_TX_OK;
>  }
>  
> +static int geneve_egress_tun_info(struct net_device *dev, struct sk_buff *skb,
> +				  struct ip_tunnel_info *egress_tun_info,
> +				  const void **egress_tun_opts)
> +{
> +	struct geneve_dev *geneve = netdev_priv(dev);
> +	struct ip_tunnel_info *info;
> +	struct rtable *rt;
> +	struct flowi4 fl4;
> +	__be16 sport;
> +
> +	info = skb_tunnel_info(skb);
> +	if (ip_tunnel_info_af(info) != AF_INET)
> +		return -EINVAL;
> +
> +	rt = geneve_get_rt(skb, dev, &fl4, info);

This will increase dev tx error stats in case the lookup fails which is
probably something we don't want.

[...]
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -60,6 +60,7 @@ struct wireless_dev;
>  /* 802.15.4 specific */
>  struct wpan_dev;
>  struct mpls_dev;
> +struct ip_tunnel_info;
>  
>  void netdev_set_default_ethtool_ops(struct net_device *dev,
>  				    const struct ethtool_ops *ops);
> @@ -1054,6 +1055,11 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
>   *	This function is used to pass protocol port error state information
>   *	to the switch driver. The switch driver can react to the proto_down
>   *      by doing a phys down on the associated switch port.
> + * int (*ndo_get_egress_info)(struct net_device *dev, struct sk_buff *skb,
> + *			      __be32 *saddr, __be16 *sport, __be16 *dport);
> + *	This function is used to get egress tunnel information for given skb.
> + *	This is useful for retrieving outer tunnel header parameters while
> + *	sampling packet.
>   *
>   */
>  struct net_device_ops {
> @@ -1227,6 +1233,10 @@ struct net_device_ops {
>  	int			(*ndo_get_iflink)(const struct net_device *dev);
>  	int			(*ndo_change_proto_down)(struct net_device *dev,
>  							 bool proto_down);
> +	int			(*ndo_get_egress_info)(struct net_device *dev,
> +						       struct sk_buff *skb,
> +						       struct ip_tunnel_info *egress_tun_info,
> +						       const void **egress_tun_opts);

This should have at least a better name to reflect it is about IP
tunnels.

But I don't like having an IP tunnel specific ndo, that doesn't sound
right. The real thing that is wanted here is to complete the dst
metadata. What about:

int (*ndo_fill_metadata_dst)(struct net_device *dev, struct sk_buff *skb);

The function will use skb_tunnel_info to get the template info, then
skb_dst_drop and allocate and attach a fully populated metadata_dst.
The egress_tun_info in struct dp_upcall_info then can be completely
dropped, as all the necessary tunnel information will be available
through skb_tunnel_info(skb). Also, when implemented correctly, such
skb will be just sent out without route lookups etc. if afterwards
handed to ndo_start_xmit.

[...]
> --- a/include/net/ip_tunnels.h
> +++ b/include/net/ip_tunnels.h
> @@ -337,6 +337,11 @@ void __init ip_tunnel_core_init(void);
>  void ip_tunnel_need_metadata(void);
>  void ip_tunnel_unneed_metadata(void);
>  
> +void ipv4_egress_info_init(struct ip_tunnel_info *egress_tun_info,
> +			   const void **egress_tun_opts,
> +			   struct ip_tunnel_info *info, __be32 saddr,
> +			   __be16 sport, __be16 dport);

Please use the ip_tunnel prefix as the rest of the functions, this is
not ipv4 egress info but ip *tunnel* egress info.

Also, it's not clear what the difference between "egress_tun_info" and
"info" is. I'd suggest to use "dst_info" and "src_info" or something
similar.

[...]
> --- a/net/ipv4/ip_tunnel_core.c
> +++ b/net/ipv4/ip_tunnel_core.c
> @@ -424,3 +424,40 @@ void ip_tunnel_unneed_metadata(void)
>  	static_key_slow_dec(&ip_tunnel_metadata_cnt);
>  }
>  EXPORT_SYMBOL_GPL(ip_tunnel_unneed_metadata);
> +
> +static void tnl_egress_opts_init(struct ip_tunnel_info *egress_tun_info,
> +				 const void **egress_tun_opts,
> +				 struct ip_tunnel_info *info)
> +{
> +	egress_tun_info->options_len = info->options_len;
> +	egress_tun_info->mode = info->mode;
> +
> +	/* Tunnel options. */
> +	if (info->options_len)
> +		*egress_tun_opts = ip_tunnel_info_opts(info);
> +	else
> +		*egress_tun_opts = NULL;
> +}
> +
> +void ipv4_egress_info_init(struct ip_tunnel_info *egress_tun_info,
> +			   const void **egress_tun_opts,
> +			   struct ip_tunnel_info *info, __be32 saddr,
> +			   __be16 sport, __be16 dport)
> +{
> +	const struct ip_tunnel_key *tun_key;
> +
> +	/* Generate egress_tun_info based on tun_info,
> +	 * saddr, tp_src and tp_dst
> +	 */
> +	tun_key = &egress_tun_info->key;
> +	ip_tunnel_key_init(&egress_tun_info->key,

Just pass tun_key as the first parameter, it will be clearer what's
going on. (I believe the assignments that have no effect will be
optimized out by the compiler, since ip_tunnel_key_init is an inline
function.)

> +			   saddr, tun_key->u.ipv4.dst,
> +			   tun_key->tos,
> +			   tun_key->ttl,
> +			   sport, dport,
> +			   tun_key->tun_id,
> +			   tun_key->tun_flags);

-- 
Jiri Benc
