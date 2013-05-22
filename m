From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v8 02/11] ipv6: make ip6_dst_hoplimit() static
 inline
Date: Wed, 22 May 2013 12:54:13 +0800
Message-ID: <1369198453.5722.12.camel@cr0>
References: <1368750099-14086-1-git-send-email-amwang@redhat.com>
	 <1368750099-14086-3-git-send-email-amwang@redhat.com>
	 <20130517.141327.2084320693913331713.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:61132 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750974Ab3EVEyb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 May 2013 00:54:31 -0400
In-Reply-To: <20130517.141327.2084320693913331713.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-05-17 at 14:13 -0700, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Fri, 17 May 2013 08:21:30 +0800
> 
> > @@ -201,4 +200,24 @@ static inline struct in6_addr *rt6_nexthop(struct rt6_info *rt, struct in6_addr
> >  	return dest;
> >  }
> >  
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +static inline int ip6_dst_hoplimit(struct dst_entry *dst)
> > +{
> > +	int hoplimit = dst_metric_raw(dst, RTAX_HOPLIMIT);
> > +	if (hoplimit == 0) {
> > +		struct net_device *dev = dst->dev;
> > +		struct inet6_dev *idev;
> > +
> > +		rcu_read_lock();
> > +		idev = __in6_dev_get(dev);
> > +		if (idev)
> > +			hoplimit = idev->cnf.hop_limit;
> > +		else
> > +			hoplimit = dev_net(dev)->ipv6.devconf_all->hop_limit;
> > +		rcu_read_unlock();
> > +	}
> > +	return hoplimit;
> > +}
> > +#endif
> 
> Create a dummy stub version in an #else branch here, so that you have
> to ifdef less in vxlan.c

The reason why we need #if IS_ENABLED(CONFIG_IPV6) here is that
dev_net(dev)->ipv6 is defined only in such case, not just for its caller
in vxlan. Nor I think anyone will seriously call ip6_dst_hoplimit()
for !CONFIG_IPV6 case, since its name is obvious.

> 
> In fact I think you can avoid nearly every ifdef in vxlan.c if you apply
> this technique throughout your changes.
> 
> Please do that and resubmit this series.
> 

Actually that is exactly what I _did_ in v1 or RFC, IIRC, it is David
Stevens who prefers to use #ifdef inside these functions, so I changed
it based on his suggestion.

I myself don't have any strong opinion here, either is okay, I just
don't like changing it again and again. :)

Thanks.
