From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RTNL]: Validate hardware and broadcast address attribute for
 RTM_NEWLINK
Date: Fri, 22 Feb 2008 14:05:34 +0100
Message-ID: <47BEC89E.9030909@trash.net>
References: <20080222125702.GB20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep20-int.chello.at ([62.179.121.40]:47003 "EHLO
	viefep20-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbYBVNFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Feb 2008 08:05:55 -0500
In-Reply-To: <20080222125702.GB20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Graf wrote:
> RTM_NEWLINK allows for already existing links to be modified. For this
> purpose do_setlink() is called which expects address attributes with a
> payload length of at least dev->addr_len. This patch adds the necessary
> validation for the RTM_NEWLINK case.
> 
> The address length for links to be created is not checked for now as the
> actual attribute length is used when copying the address to the netdevice
> structure. It might make sense to report an error if less than addr_len
> bytes are provided but enforcing this might break drivers trying to be
> smart with not transmitting all zero addresses.
> 
> Signed-off-by: Thomas Graf <tgraf@suug.ch>
> 
> Index: net-2.6.26/net/core/rtnetlink.c
> ===================================================================
> --- net-2.6.26.orig/net/core/rtnetlink.c	2008-02-22 01:50:53.000000000 +0100
> +++ net-2.6.26/net/core/rtnetlink.c	2008-02-22 11:28:59.000000000 +0100
> @@ -726,6 +726,21 @@
>  	return net;
>  }
>  
> +static int validate_linkmsg(struct net_device *dev, struct nlattr *tb[])
> +{
> +	if (dev) {
> +		if (tb[IFLA_ADDRESS] &&
> +		    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
> +			return -EINVAL;
> +
> +		if (tb[IFLA_BROADCAST] &&
> +		    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
> +			return -EINVAL;
> +	}
> +
> +	return 0;
> +}
> +
>  static int do_setlink(struct net_device *dev, struct ifinfomsg *ifm,
>  		      struct nlattr **tb, char *ifname, int modified)
>  {
> @@ -910,12 +925,7 @@
>  		goto errout;
>  	}
>  
> -	if (tb[IFLA_ADDRESS] &&
> -	    nla_len(tb[IFLA_ADDRESS]) < dev->addr_len)
> -		goto errout_dev;
> -
> -	if (tb[IFLA_BROADCAST] &&
> -	    nla_len(tb[IFLA_BROADCAST]) < dev->addr_len)
> +	if ((err = validate_linkmsg(dev, tb)) < 0)
>  		goto errout_dev;
>  
>  	err = do_setlink(dev, ifm, tb, ifname, 0);
> @@ -1036,6 +1046,9 @@
>  	else
>  		dev = NULL;
>  
> +	if ((err = validate_linkmsg(dev, tb)) < 0)
> +		return err;
> +

Minor nitpick: it would be more logical to put this in the

if (dev) {
  ...

branch a bit below since thats the only path that leads to
do_setlink(). That would also allow to remove the
if (dev) check from validate_linkmsg().
