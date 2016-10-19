From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net-next 4/6] net: use core MTU range checking in core
 net infra
Date: Wed, 19 Oct 2016 17:28:00 +0200
Message-ID: <20161019152759.GB11224@bistromath.localdomain>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-5-jarod@redhat.com>
 <20161019135529.GA11224@bistromath.localdomain>
 <20161019144006.GF18569@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Paolo Abeni <pabeni@redhat.com>, Jiri Benc <jbenc@redhat.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Pravin Shelar <pshelar@nicira.com>
To: Jarod Wilson <jarod@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161019144006.GF18569@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2016-10-19, 10:40:06 -0400, Jarod Wilson wrote:
> On Wed, Oct 19, 2016 at 03:55:29PM +0200, Sabrina Dubroca wrote:
> > 2016-10-18, 22:33:31 -0400, Jarod Wilson wrote:
> > > geneve:
> > > - Merge __geneve_change_mtu back into geneve_change_mtu, set max_mtu
> > > - This one isn't quite as straight-forward as others, could use some
> > >   closer inspection and testing
> > > 
> > > macvlan:
> > > - set min/max_mtu
> > > 
> > > tun:
> > > - set min/max_mtu, remove tun_net_change_mtu
> > > 
> > > vxlan:
> > > - Merge __vxlan_change_mtu back into vxlan_change_mtu, set min/max_mtu
> > > - This one is also not as straight-forward and could use closer inspection
> > >   and testing from vxlan folks
> > > 
> > > bridge:
> > > - set max_mtu via br_min_mtu()
> > > 
> > > openvswitch:
> > > - set min/max_mtu, remove internal_dev_change_mtu
> > > - note: max_mtu wasn't checked previously, it's been set to 65535, which
> > >   is the largest possible size supported
> > > 
> > > sch_teql:
> > > - set min/max_mtu (note: max_mtu previously unchecked, used max of 65535)
> > 
> > Nothing for other virtual netdevices? (dummy, veth, bond, etc) Their
> > MTU is limited to 1500 now.  Also missing macsec and ip_gre, probably
> > others that are using ether_setup.
> 
> Yeah, I've clearly missed more than I thought. Doing another sweep now.

Thanks.


> I'm thinking more and more that we ought to back out the patch that sets
> min/max in ether_setup, save it for last, after we're sure everyone that
> calls it has been prepared.

I'm not sure how that would work now, if some of the patches that
already went in for ethernet drivers assume that ether_setup will
configure a basic {min,max}_mtu pair (at least e100 makes that
assumption, but that might be the only one).

> > [...]
> > > diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
> > > index 89a687f..81fc79a 100644
> > > --- a/net/bridge/br_device.c
> > > +++ b/net/bridge/br_device.c
> > > @@ -184,17 +184,15 @@ static struct rtnl_link_stats64 *br_get_stats64(struct net_device *dev,
> > >  
> > >  static int br_change_mtu(struct net_device *dev, int new_mtu)
> > >  {
> > > +#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
> > >  	struct net_bridge *br = netdev_priv(dev);
> > > -	if (new_mtu < 68 || new_mtu > br_min_mtu(br))
> > > -		return -EINVAL;
> > > -
> > > -	dev->mtu = new_mtu;
> > >  
> > > -#if IS_ENABLED(CONFIG_BRIDGE_NETFILTER)
> > >  	/* remember the MTU in the rtable for PMTU */
> > >  	dst_metric_set(&br->fake_rtable.dst, RTAX_MTU, new_mtu);
> > >  #endif
> > >  
> > > +	dev->mtu = new_mtu;
> > > +
> > >  	return 0;
> > >  }
> > >  
> > > @@ -390,6 +388,7 @@ void br_dev_setup(struct net_device *dev)
> > >  	dev->hw_features = COMMON_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
> > >  			   NETIF_F_HW_VLAN_STAG_TX;
> > >  	dev->vlan_features = COMMON_FEATURES;
> > > +	dev->max_mtu = br_min_mtu(br);
> > 
> > br_min_mtu uses br->port_list, which is only initialized a few lines
> > later (right after the spin_lock_init() at the end of the context of
> > this diff).
> 
> Ah, okay, I'd just grouped it with the other dev->foo settings.
> 
> > Besides, I don't think this works: br_min_mtu(br) changes when you add
> > and remove ports, or when you change the MTU of an enslaved
> > device. But this makes the max MTU for the bridge fixed (to 1500).
> 
> Okay, how about this: set no max_mtu (or set it to IP_MAX_MTU/65535), and
> then retain a check against the possibly ever-changing br_min_mtu(br) in
> br_change_mtu()?

Sounds good to me.


-- 
Sabrina
