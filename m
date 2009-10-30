From: "Neulinger, Nathan" <nneul@mst.edu>
Subject: RE: How to use gretap with bridge?
Date: Fri, 30 Oct 2009 12:08:21 -0500
Message-ID: <846C5B546E47494CBBD796CA8CA1617EA3B44C@MST-VMAIL1.srv.mst.edu>
References: <846C5B546E47494CBBD796CA8CA1617EA3B43C@MST-VMAIL1.srv.mst.edu> <20091030155148.GA8283@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <shemminger@vyatta.com>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mxtip01-rolla-out.um.umsystem.edu ([209.106.229.47]:58907 "EHLO
	mxtip01-rolla-out.um.umsystem.edu" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932103AbZJ3RIS convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 Oct 2009 13:08:18 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20091030155148.GA8283@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Confirmed, this fixes the problem for me and even now allows changing
the mac access by request. 

Now I'm on to figuring out MTU issues. Thanks!

-- Nathan

------------------------------------------------------------
Nathan Neulinger                       nneul@mst.edu
Missouri S&T Information Technology    (573) 612-1412
System Administrator - Principal       KD0DMH


> -----Original Message-----
> From: Herbert Xu [mailto:herbert@gondor.apana.org.au]
> Sent: Friday, October 30, 2009 10:52 AM
> To: Neulinger, Nathan; David S. Miller
> Cc: shemminger@vyatta.com; netdev@vger.kernel.org
> Subject: Re: How to use gretap with bridge?
> 
> Neulinger, Nathan <nneul@mst.edu> wrote:
> >
> > The above change fixes it for me, but I'm no expert on this chunk of
> > code. (Perhaps it it shouldn't set dev_addr at all?)
> 
> OK, it was a stupid mistake on my part.  I added a netdev ops
> struct for tap but didn't actually use it!  Please let us know
> whether this patch fixes the problem.
> 
> gre: Fix dev_addr clobbering for gretap
> 
> Nathan Neulinger noticed that gretap devices get their MAC address
> from the local IP address, which results in invalid MAC addresses
> half of the time.
> 
> This is because gretap is still using the tunnel netdev ops rather
> than the correct tap netdev ops struct.
> 
> This patch also fixes changelink to not clobber the MAC address
> for the gretap case.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Thanks,
> --
> Visit Openswan at http://www.openswan.org/
> Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
> --
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index 41ada99..1433338 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1464,7 +1464,7 @@ static void ipgre_tap_setup(struct net_device
> *dev)
> 
>  	ether_setup(dev);
> 
> -	dev->netdev_ops		= &ipgre_netdev_ops;
> +	dev->netdev_ops		= &ipgre_tap_netdev_ops;
>  	dev->destructor 	= free_netdev;
> 
>  	dev->iflink		= 0;
> @@ -1525,25 +1525,29 @@ static int ipgre_changelink(struct net_device
> *dev, struct nlattr *tb[],
>  		if (t->dev != dev)
>  			return -EEXIST;
>  	} else {
> -		unsigned nflags = 0;
> -
>  		t = nt;
> 
> -		if (ipv4_is_multicast(p.iph.daddr))
> -			nflags = IFF_BROADCAST;
> -		else if (p.iph.daddr)
> -			nflags = IFF_POINTOPOINT;
> +		if (dev->type != ARPHRD_ETHER) {
> +			unsigned nflags = 0;
> 
> -		if ((dev->flags ^ nflags) &
> -		    (IFF_POINTOPOINT | IFF_BROADCAST))
> -			return -EINVAL;
> +			if (ipv4_is_multicast(p.iph.daddr))
> +				nflags = IFF_BROADCAST;
> +			else if (p.iph.daddr)
> +				nflags = IFF_POINTOPOINT;
> +
> +			if ((dev->flags ^ nflags) &
> +			    (IFF_POINTOPOINT | IFF_BROADCAST))
> +				return -EINVAL;
> +		}
> 
>  		ipgre_tunnel_unlink(ign, t);
>  		t->parms.iph.saddr = p.iph.saddr;
>  		t->parms.iph.daddr = p.iph.daddr;
>  		t->parms.i_key = p.i_key;
> -		memcpy(dev->dev_addr, &p.iph.saddr, 4);
> -		memcpy(dev->broadcast, &p.iph.daddr, 4);
> +		if (dev->type != ARPHRD_ETHER) {
> +			memcpy(dev->dev_addr, &p.iph.saddr, 4);
> +			memcpy(dev->broadcast, &p.iph.daddr, 4);
> +		}
>  		ipgre_tunnel_link(ign, t);
>  		netdev_state_change(dev);
>  	}
