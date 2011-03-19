From: Jim Westfall <jwestfall@surrealistic.net>
Subject: Re: ipv6 secondary ips and default ipv6 ip for new outbound
	connections
Date: Fri, 18 Mar 2011 20:35:07 -0700
Message-ID: <20110319033507.GY13831@surrealistic.net>
References: <20110318230312.GX13831@surrealistic.net> <4D8413BE.5000305@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from whipper.surrealistic.net ([75.151.103.193]:39886 "EHLO
	whipper.surrealistic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754403Ab1CSDfJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 23:35:09 -0400
Content-Disposition: inline
In-Reply-To: <4D8413BE.5000305@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote [03.18.11]:
> On 03/18/2011 07:03 PM, Jim Westfall wrote:
> > Hi
> > 
> > On ipv4 the first ip added to a nic will be used as the source ip for 
> > new outbound connections.  Any additional ips, in the same netblock, 
> > will be added as secondaries.
> > 
> > ipv6 seems to have the opposite behavior.  The last ipv6 ip added to a 
> > nic is be used for new outbound connections.
> > 
> > ~# ip -6 addr list br0
> > 11: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 
> >     inet6 fe80::21a:64ff:fe12:54bd/64 scope link 
> >        valid_lft forever preferred_lft forever
> > 
> > ~# ip addr add 2600:c00:0:1::1101/64 dev br0
> > ~# traceroute6 www.kame.net | head -0
> > traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets
> > 
> > ~# ip addr add 2600:c00:0:1::1102/64 dev br0
> > ~# traceroute6 www.kame.net | head -0
> > traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1102, 30 hops max, 16 byte packets
> > 
> > ~# ip -6 addr list br0
> > 11: br0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 
> >     inet6 2600:c00:0:1::1102/64 scope global 
> >        valid_lft forever preferred_lft forever
> >     inet6 2600:c00:0:1::1101/64 scope global 
> >        valid_lft forever preferred_lft forever
> >     inet6 fe80::21a:64ff:fe12:54bd/64 scope link 
> >        valid_lft forever preferred_lft forever
> > 
> > This makes things a bit of a pita when dealing with floater ipv6 ips for 
> > HA.
> > 
> > This there some way to change this behavior to be like ipv4 or force 
> > a specific ipv6 ip to be the default used for new outbound connections?
> 
> According to commit 8a6ce0c083f5736e90dabe6d8ce077e7dd0fa35f it's done this
> way for backward-compatibility - we used to always put new addresses at the
> front, then we started sorting them by scope.  I couldn't find in the archives
> who needed the backward-compatible behavior (it was way back in 2006), but
> Yoshifuji proposed it and I Acked it.
> 
> You could see if this patch helps you out, but I'm not sure if changing this
> would break someone else, you'd have to see about putting a knob to control
> this.
> 
> -Brian
> 
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 3daaf3c..8c7d5a5 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -577,7 +577,7 @@ ipv6_link_dev_addr(struct inet6_dev *idev, struct inet6_ifaddr *ifp)
>  	list_for_each(p, &idev->addr_list) {
>  		struct inet6_ifaddr *ifa
>  			= list_entry(p, struct inet6_ifaddr, if_list);
> -		if (ifp_scope >= ipv6_addr_src_scope(&ifa->addr))
> +		if (ifp_scope > ipv6_addr_src_scope(&ifa->addr))
>  			break;
>  	}
>  

Hi

Your patch fixes it for me.

# ip addr add 2600:c00:0:1::1101/64 dev eth0
~# traceroute6 www.kame.net | head -0
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets

~# ip addr add 2600:c00:0:1::1102/64 dev eth0
~# traceroute6 www.kame.net | head -0
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets

~# ip addr add 2600:c00:0:1::1103/64 dev eth0
~# traceroute6 www.kame.net | head -0
traceroute to orange.kame.net (2001:200:dff:fff1:216:3eff:feb1:44d7) from 2600:c00:0:1::1101, 30 hops max, 16 byte packets

~# ip -6 addr show dev eth0
3: eth0: <BROADCAST,MULTICAST,UP,10000> mtu 1500 qlen 1000
    inet6 2600:c00:0:1::1101/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 2600:c00:0:1::1102/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 2600:c00:0:1::1103/64 scope global 
       valid_lft forever preferred_lft forever
    inet6 fe80::21a:64ff:fe12:54bd/64 scope link 
       valid_lft forever preferred_lft forever

thanks
Jim
