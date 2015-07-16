From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [RFC net-next 22/22] openvswitch: Use regular GRE net_device
 instead of vport
Date: Thu, 16 Jul 2015 17:59:17 +0900
Message-ID: <20150716085915.GA11294@penelope.isobedori.kobe.vergenet.net>
References: <cover.1436537414.git.tgraf@suug.ch>
 <74f200a9e634a9fefd6de85265f54b8a6697ab72.1436537414.git.tgraf@suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
	ebiederm@xmission.com, hannes@stressinduktion.org,
	pshelar@nicira.com, jesse@nicira.com, davem@davemloft.net,
	daniel@iogearbox.net, tom@herbertland.com, edumazet@google.com,
	jiri@resnulli.us, marcelo.leitner@gmail.com,
	stephen@networkplumber.org, jpettit@nicira.com, kaber@trash.net,
	netdev@vger.kernel.org, dev@openvswitch.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:35738 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752681AbbGPI7d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:59:33 -0400
Received: by pdrg1 with SMTP id g1so40838347pdr.2
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:59:32 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <74f200a9e634a9fefd6de85265f54b8a6697ab72.1436537414.git.tgraf@suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 04:19:24PM +0200, Thomas Graf wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> 
> Removes all of the OVS specific GRE code and makes OVS use a
> GRE net_device.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>

[snip]

> @@ -115,6 +117,8 @@ static bool log_ecn_error = true;
>  module_param(log_ecn_error, bool, 0644);
>  MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
>  
> +#define GRE_TAP_FB_NAME "gretap0"
> +
>  static struct rtnl_link_ops ipgre_link_ops __read_mostly;
>  static int ipgre_tunnel_init(struct net_device *dev);
>  

[snip]

> @@ -690,12 +836,27 @@ static const struct net_device_ops gre_tap_netdev_ops = {
>  	.ndo_get_iflink		= ip_tunnel_get_iflink,
>  };
>  
> +static const struct net_device_ops gre_fb_netdev_ops = {
> +	.ndo_init		= gre_tap_init,
> +	.ndo_uninit		= ip_tunnel_uninit,
> +	.ndo_start_xmit		= gre_fb_xmit,
> +	.ndo_set_mac_address 	= eth_mac_addr,
> +	.ndo_validate_addr	= eth_validate_addr,
> +	.ndo_change_mtu		= ip_tunnel_change_mtu,
> +	.ndo_get_stats64	= ip_tunnel_get_stats64,
> +	.ndo_get_iflink		= ip_tunnel_get_iflink,
> +};
> +
>  static void ipgre_tap_setup(struct net_device *dev)
>  {
>  	ether_setup(dev);
> -	dev->netdev_ops		= &gre_tap_netdev_ops;
>  	dev->priv_flags 	|= IFF_LIVE_ADDR_CHANGE;
>  	ip_tunnel_setup(dev, gre_tap_net_id);
> +
> +	if (!strcmp(dev->name, GRE_TAP_FB_NAME))
> +		dev->netdev_ops		= &gre_fb_netdev_ops;
> +	else
> +		dev->netdev_ops		= &gre_tap_netdev_ops;
>  }
>  
>  static int ipgre_newlink(struct net *src_net, struct net_device *dev,

[snip]

Is there a side-effect of the above that if a user creates a gretap device
whose name is "gretap0" then the device will use gre_fb_netdev_ops instead
of gre_tap_netdev_ops. If so, does that imply a change in behaviour for
gretap devices created with that name?
