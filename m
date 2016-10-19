From: Jarod Wilson <jarod@redhat.com>
Subject: Re: [PATCH net-next 4/6] net: use core MTU range checking in core
 net infra
Date: Wed, 19 Oct 2016 10:51:43 -0400
Message-ID: <20161019145143.GG18569@redhat.com>
References: <20161019023333.15760-1-jarod@redhat.com>
 <20161019023333.15760-5-jarod@redhat.com>
 <20161019141703.01ff8850@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        Nicolas Dichtel <nicolas.dichtel@6wind.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Tom Herbert <tom@herbertland.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexander Duyck <alexander.h.duyck@intel.com>,
        Paolo Abeni <pabeni@redhat.com>,
        WANG Cong <xiyou.wangcong@gmail.com>,
        Roopa Prabhu <roopa@cumulusnetworks.com>,
        Pravin B Shelar <pshelar@ovn.org>,
        Sabrina Dubroca <sd@queasysnail.net>,
        Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Pravin Shelar <pshelar@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:34199 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S943328AbcJSOv4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2016 10:51:56 -0400
Received: by mail-qk0-f173.google.com with SMTP id f128so38123180qkb.1
        for <netdev@vger.kernel.org>; Wed, 19 Oct 2016 07:51:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20161019141703.01ff8850@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 19, 2016 at 02:17:03PM +0200, Jiri Benc wrote:
> On Tue, 18 Oct 2016 22:33:31 -0400, Jarod Wilson wrote:
> > --- a/drivers/net/vxlan.c
> > +++ b/drivers/net/vxlan.c
> > @@ -2367,43 +2367,31 @@ static void vxlan_set_multicast_list(struct net_device *dev)
> >  {
> >  }
> >  
> > -static int __vxlan_change_mtu(struct net_device *dev,
> > -			      struct net_device *lowerdev,
> > -			      struct vxlan_rdst *dst, int new_mtu, bool strict)
> > +static int vxlan_change_mtu(struct net_device *dev, int new_mtu)
> >  {
> > -	int max_mtu = IP_MAX_MTU;
> > -
> > -	if (lowerdev)
> > -		max_mtu = lowerdev->mtu;
> > +	struct vxlan_dev *vxlan = netdev_priv(dev);
> > +	struct vxlan_rdst *dst = &vxlan->default_dst;
> > +	struct net_device *lowerdev = __dev_get_by_index(vxlan->net,
> > +							 dst->remote_ifindex);
> > +	bool use_ipv6 = false;
> >  
> >  	if (dst->remote_ip.sa.sa_family == AF_INET6)
> > -		max_mtu -= VXLAN6_HEADROOM;
> > -	else
> > -		max_mtu -= VXLAN_HEADROOM;
> > -
> > -	if (new_mtu < 68)
> > -		return -EINVAL;
> > +		use_ipv6 = true;
> >  
> > -	if (new_mtu > max_mtu) {
> > -		if (strict)
> > +	/* We re-check this, because users *could* alter the mtu of the
> > +	 * lower device after we've initialized dev->max_mtu.
> > +	 */
> > +	if (lowerdev) {
> > +		dev->max_mtu = lowerdev->mtu -
> > +			       (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
> > +		if (new_mtu > dev->max_mtu)
> >  			return -EINVAL;
> > -
> > -		new_mtu = max_mtu;
> >  	}
> >  
> >  	dev->mtu = new_mtu;
> >  	return 0;
> >  }
> 
> Sorry for the silly question, how does the min_mtu and max_mtu stuff
> works? I noticed your patches but haven't looked in depth into them.
> 
> When the ndo_change_mtu callback is defined, is the dev->min_mtu and
> dev->max_mtu checked first and if the desired mtu is not within range,
> ndo_change_mtu is not called?
> 
> Or does ndo_change_mtu override the checks?

The former. If the new value is outside min/max, ndo_change_mtu doesn't
get called, which is exactly the chicken and egg problem I introduced by
setting max_mtu to 1500 in ether_setup before having all drivers that call
ether_setup set a more appropriate max_mtu first. :\

> In either case, the code does not look correct. In the first case,
> increasing of lowerdev MTU wouldn't allow increasing of vxlan MTU
> without deleting and recreating the vxlan interface. In the second
> case, you're missing check against the min_mtu.

Okay, this sounds like a similar case to bridge that Sabrina pointed out.
Looks like virtual devices will need to just set no max_mtu directly (or
IP_MAX_MTU), and do dynamic checks in their ndo_change_mtu if they need to
compare against underlying devices on the fly.

...
> > @@ -2847,9 +2842,14 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
> >  	}
> >  
> >  	if (conf->mtu) {
> > -		err = __vxlan_change_mtu(dev, lowerdev, dst, conf->mtu, false);
> > -		if (err)
> > -			return err;
> > +		if (lowerdev)
> > +			dev->max_mtu = lowerdev->mtu;
> > +		dev->max_mtu -= (use_ipv6 ? VXLAN6_HEADROOM : VXLAN_HEADROOM);
> > +
> > +		dev->mtu = conf->mtu;
> > +
> > +		if (conf->mtu > dev->max_mtu)
> > +			dev->mtu = dev->max_mtu;
> >  	}
> 
> You removed the check for min_mtu but it's needed here. The conf->mtu
> value comes from the user space and can be anything.

Hm. Not sure why I did that... Will put it back now...

-- 
Jarod Wilson
jarod@redhat.com
