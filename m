From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net v3] openvswitch: Fix egress tunnel info.
Date: Fri, 23 Oct 2015 14:17:38 +0200
Message-ID: <20151023141738.4db54324@griffin>
References: <1445563036-9623-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48484 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752146AbbJWMRl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Oct 2015 08:17:41 -0400
In-Reply-To: <1445563036-9623-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Oct 2015 18:17:16 -0700, Pravin B Shelar wrote:
> While transitioning to netdev based vport we broke OVS
> feature which allows user to retrieve tunnel packet egress
> information for lwtunnel devices.  Following patch fixes it
> by introducing ndo operation to get the tunnel egress info.
> Same ndo operation can be used for lwtunnel devices and compat
> ovs-tnl-vport devices. So after adding such device operation
> we can remove similar operation from ovs-vport.
> 
> Fixes: 614732eaa12d ("openvswitch: Use regular VXLAN net_device device").
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> --
> v2-v3:
> - Remove unused tun_info
> v1-v2:
> - changed ndo operation name to ndo_fill_metadata_dst()
> - Fix geneve stats update

This looks good overall, thanks. I see some issues with the patch but
most of it can be fixed in net-next.git. See below.

[...]
> --- a/drivers/net/vxlan.c
> +++ b/drivers/net/vxlan.c
> @@ -2337,6 +2337,46 @@ static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
>  	return 0;
>  }
>  
> +static int egress_ipv4_tun_info(struct net_device *dev, struct sk_buff *skb,
> +				struct ip_tunnel_info *info,
> +				__be16 sport, __be16 dport)
> +{
> +	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	struct rtable *rt;
> +	struct flowi4 fl4;
> +
> +	memset(&fl4, 0, sizeof(fl4));
> +	fl4.flowi4_tos = RT_TOS(info->key.tos);
> +	fl4.flowi4_mark = skb->mark;
> +	fl4.flowi4_proto = IPPROTO_UDP;
> +	fl4.daddr = info->key.u.ipv4.dst;
> +
> +	rt = ip_route_output_key(vxlan->net, &fl4);
> +	if (IS_ERR(rt))
> +		return PTR_ERR(rt);
> +	ip_rt_put(rt);
> +
> +	info->key.u.ipv4.src = fl4.saddr;
> +	info->key.tp_src = sport;
> +	info->key.tp_dst = dport;
> +	return 0;
> +}

Do you plan to address the introduced code duplication for net-next.git?

> +
> +static int vxlan_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
> +{
> +	struct vxlan_dev *vxlan = netdev_priv(dev);
> +	struct ip_tunnel_info *info = skb_tunnel_info(skb);
> +	__be16 sport, dport;
> +
> +	sport = udp_flow_src_port(dev_net(dev), skb, vxlan->cfg.port_min,
> +				  vxlan->cfg.port_max, true);
> +	dport = info->key.tp_dst ? : vxlan->cfg.dst_port;
> +
> +	if (ip_tunnel_info_af(info) == AF_INET)
> +		return egress_ipv4_tun_info(dev, skb, info, sport, dport);
> +	return -EINVAL;

What about IPv6? There's IPv6 support for metadata based vxlan in
net.git, thus this should have IPv6 support, too. But then, this is
currently used only by ovs which got the IPv6 support only in
net-next.git, thus it may be enough to fix it there.

[...]
> --- a/include/net/dst_metadata.h
> +++ b/include/net/dst_metadata.h
[...]
> +static inline struct ip_tunnel_info *skb_tunnel_info_unclone(struct sk_buff *skb)
> +{
> +	struct metadata_dst *dst;
> +
> +	dst = tun_dst_unclone(skb);
> +	if (IS_ERR(dst))
> +		return NULL;
> +
> +	return &dst->u.tun_info;
> +}

This doesn't do what the name suggests and is, actually, ovs specific.
The ip_tunnel_info can be provided as a part of lwtstate and this
function should handle that case, too. This is not a problem for
net.git, as the function just returns EINVAL in such case, but should
be addressed for net-next.git. As ovs is currently the only user, I'd
be also fine with just a comment stating that, so it's clear for future
users of this function that it needs to be extended before it can be
used out of ovs.

[...]
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -99,6 +99,7 @@
>  #include <linux/rtnetlink.h>
>  #include <linux/stat.h>
>  #include <net/dst.h>
> +#include <net/dst_metadata.h>
>  #include <net/pkt_sched.h>
>  #include <net/checksum.h>
>  #include <net/xfrm.h>
> @@ -682,6 +683,32 @@ int dev_get_iflink(const struct net_device *dev)
>  EXPORT_SYMBOL(dev_get_iflink);
>  
>  /**
> + *	dev_fill_metadata_dst - Retrieve tunnel egress information.
> + *	@dev: targeted interface
> + *	@skb: The packet.
> + *
> + *	For better visibility of tunnel traffic OVS needs to retrieve
> + *	egress tunnel information for a packet. Following API allows
> + *	user to get this info.
> + */
> +int dev_fill_metadata_dst(struct net_device *dev, struct sk_buff *skb)
> +{
> +	struct ip_tunnel_info *info;
> +
> +	if (!dev->netdev_ops  || !dev->netdev_ops->ndo_fill_metadata_dst)
> +		return -EINVAL;
> +
> +	info = skb_tunnel_info_unclone(skb);
> +	if (!info)
> +		return -ENOMEM;

ENOMEM is a wrong error code to return. skb_tunnel_info_unclone should
return the error code returned by tun_dst_unclone, in particular the
EINVAL case which will be much more common than the ENOMEM case.

> +	if (unlikely(!(info->mode & IP_TUNNEL_INFO_TX)))
> +		return -EINVAL;

It would be much better to check the mode before copying the metadata.

[...]
> --- a/net/openvswitch/flow_netlink.c
> +++ b/net/openvswitch/flow_netlink.c
[...]
> @@ -749,13 +749,12 @@ static int ipv4_tun_to_nlattr(struct sk_buff *skb,
>  	return 0;
>  }
>  
> -int ovs_nla_put_egress_tunnel_key(struct sk_buff *skb,
> -				  const struct ip_tunnel_info *egress_tun_info,
> -				  const void *egress_tun_opts)
> +int ovs_nla_put_tunnel_info(struct sk_buff *skb,
> +			    struct ip_tunnel_info *tun_info)
>  {
> -	return __ipv4_tun_to_nlattr(skb, &egress_tun_info->key,
> -				    egress_tun_opts,
> -				    egress_tun_info->options_len);
> +	return __ipv4_tun_to_nlattr(skb, &tun_info->key,
> +				    ip_tunnel_info_opts(tun_info),
> +				    tun_info->options_len);
>  }

This should at least check whether the tun_info is indeed IPv4. Actual
IPv6 support for this function can be added to net-next.git.

 Jiri

-- 
Jiri Benc
