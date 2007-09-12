From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [PATCH] veth: Cleanly handle a missing peer_tb argument on creation.
Date: Wed, 12 Sep 2007 18:15:02 +0400
Message-ID: <46E7F466.1060704@openvz.org>
References: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:34975 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965354AbXILORm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 12 Sep 2007 10:17:42 -0400
In-Reply-To: <m17imwaumb.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman wrote:
> I was getting strange kernel crashes when attempting to
> create veth devices when I did not specify a peer argument
> to /bin/ip.
> 
> So this patch defaults peer_tb to all zeros and doesn't attempt to
> reuse the netlink attributes for the primary link to create the
> secondary link and now I can't reproduce the failures.
> 
> Given that some of the most interesting netlink attributes to specify
> like a mac address or a network device name seem are generally
> the wrong thing to do this seems like the right approach.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>
> ---
>  drivers/net/veth.c |   16 +++++++---------
>  1 files changed, 7 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/veth.c b/drivers/net/veth.c
> index 9e6a746..d49bd2c 100644
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -313,7 +313,7 @@ static int veth_newlink(struct net_device *dev,
>  	struct net_device *peer;
>  	struct veth_priv *priv;
>  	char ifname[IFNAMSIZ];
> -	struct nlattr *peer_tb[IFLA_MAX + 1], **tbp;
> +	struct nlattr *peer_tb[IFLA_MAX + 1];
>  
>  	/*
>  	 * create and register peer first
> @@ -322,6 +322,7 @@ static int veth_newlink(struct net_device *dev,
>  	 * skip it since no info from it is useful yet
>  	 */
>  
> +	memset(peer_tb, 0, sizeof(peer_tb));
>  	if (data != NULL && data[VETH_INFO_PEER] != NULL) {
>  		struct nlattr *nla_peer;
>  
> @@ -336,21 +337,18 @@ static int veth_newlink(struct net_device *dev,
>  		err = veth_validate(peer_tb, NULL);
>  		if (err < 0)
>  			return err;
> +	}
>  
> -		tbp = peer_tb;
> -	} else
> -		tbp = tb;

The intention of this part was to get the same parameters for
peer as for the first device if no "peer" argument was specified
for ip utility. Does it still work?

> -
> -	if (tbp[IFLA_IFNAME])
> -		nla_strlcpy(ifname, tbp[IFLA_IFNAME], IFNAMSIZ);
> +	if (peer_tb[IFLA_IFNAME])
> +		nla_strlcpy(ifname, peer_tb[IFLA_IFNAME], IFNAMSIZ);
>  	else
>  		snprintf(ifname, IFNAMSIZ, DRV_NAME "%%d");
>  
> -	peer = rtnl_create_link(dev->nd_net, ifname, &veth_link_ops, tbp);
> +	peer = rtnl_create_link(dev->nd_net, ifname, &veth_link_ops, peer_tb);
>  	if (IS_ERR(peer))
>  		return PTR_ERR(peer);
>  
> -	if (tbp[IFLA_ADDRESS] == NULL)
> +	if (peer_tb[IFLA_ADDRESS] == NULL)
>  		random_ether_addr(peer->dev_addr);
>  
>  	err = register_netdevice(peer);

