From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NULL pointer dereference in veth_stats_one
Date: Fri, 4 Jan 2013 18:17:23 +0000
Message-ID: <1357323443.2693.9.camel@bwh-desktop.uk.solarflarecom.com>
References: <20130104105955.GA3663@raven>
	 <1357314320.1678.1414.camel@edumazet-glaptop>
	 <1357316231.1678.1528.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Tom Parkin <tparkin@katalix.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:20149 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796Ab3ADSR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Jan 2013 13:17:27 -0500
In-Reply-To: <1357316231.1678.1528.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-01-04 at 08:17 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> On Fri, 2013-01-04 at 07:45 -0800, Eric Dumazet wrote:
> > On Fri, 2013-01-04 at 10:59 +0000, Tom Parkin wrote:
> > > Hi list,
> > > 
> > > I recently tripped over a NULL pointer dereference in the veth driver.
> > > I'm running a 3.8.0_rc1 (updated from net-next git tree this morning)
> > > on an Athlon 64 X2 machine running a 32 bit kernel.  To trigger the
> > > oops I simply created a veth interface as follows:
> > > 
> > >         ip link add name ve0 type veth peer name ve1
> > > 
> > > I did a little digging in the git history and I note that veth
> > > statistics changed a little with commit 2681128f0ced8aa4.  I tried
> > > reverting that commit in my tree, which made the oops go away again.
> > > 
> > > Thanks,
> > > Tom
> > 
> > Thanks Tom, I'll fix this.
> > 
> 
> Oh well, a last minute change again...
> 
> I was fooled by veth_get_ethtool_stats() doing the priv->peer->ifindex
> deref without checking.
[...]
> --- a/drivers/net/veth.c
> +++ b/drivers/net/veth.c
> @@ -162,15 +162,18 @@ static struct rtnl_link_stats64 *veth_get_stats64(struct net_device *dev,
>  						  struct rtnl_link_stats64 *tot)
>  {
>  	struct veth_priv *priv = netdev_priv(dev);
> +	struct net_device *peer = priv->peer;
>  	struct pcpu_vstats one;
>  
>  	tot->tx_dropped = veth_stats_one(&one, dev);
>  	tot->tx_bytes = one.bytes;
>  	tot->tx_packets = one.packets;
>  
> -	tot->rx_dropped = veth_stats_one(&one, priv->peer);
> -	tot->rx_bytes = one.bytes;
> -	tot->rx_packets = one.packets;
> +	if (peer) {

This possibly needs some memory barriers to properly synchronise with
veth_newlink().  But can you not move initialisation of the peer
pointers before registration of the devices in veth_newlink(), so that
veth_get_stats64() cannot be called before they are initialised?

Ben.

> +		tot->rx_dropped = veth_stats_one(&one, peer);
> +		tot->rx_bytes = one.bytes;
> +		tot->rx_packets = one.packets;
> +	}
>  
>  	return tot;
>  }

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
