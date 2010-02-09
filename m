From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] IPv6: keep permanent addresses on admin down
Date: Tue, 9 Feb 2010 08:36:59 -0800
Message-ID: <20100209083659.16b0961a@nehalam>
References: <20100208214805.1f8f2c6d@nehalam>
	<4B7173CB.3020506@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki / =?UTF-8?B?5ZCJ?=
	 =?UTF-8?B?6Jek6Iux5piO?= <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60880 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754063Ab0BIQhf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Feb 2010 11:37:35 -0500
In-Reply-To: <4B7173CB.3020506@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 09 Feb 2010 09:40:11 -0500
Brian Haley <brian.haley@hp.com> wrote:

> Stephen Hemminger wrote:
> > @@ -2686,18 +2687,30 @@ static int addrconf_ifdown(struct net_de
> >  		write_lock_bh(&idev->lock);
> >  	}
> >  #endif
> > -	while ((ifa = idev->addr_list) != NULL) {
> > -		idev->addr_list = ifa->if_next;
> > -		ifa->if_next = NULL;
> > -		ifa->dead = 1;
> > -		addrconf_del_timer(ifa);
> > -		write_unlock_bh(&idev->lock);
> > -
> > -		__ipv6_ifa_notify(RTM_DELADDR, ifa);
> > -		atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
> > -		in6_ifa_put(ifa);
> > +	bifa = &idev->addr_list;
> > +	while ((ifa = *bifa) != NULL) {
> > +		if (how == 0 && (ifa->flags&IFA_F_PERMANENT)) {
> > +			/* Retain permanent address on admin down */
> > +			bifa = &ifa->if_next;
> > +
> > +			/* Restart DAD if needed when link comes back up */
> > +			if ( !((dev->flags&(IFF_NOARP|IFF_LOOPBACK)) ||
> > +			       idev->cnf.accept_dad <= 0 ||
> > +			       (ifa->flags & IFA_F_NODAD)))
> > +				ifa->flags |= IFA_F_TENTATIVE;
> > +		} else {
> > +			*bifa = ifa->if_next;
> > +			ifa->if_next = NULL;
> > +
> > +			ifa->dead = 1;
> > +			write_unlock_bh(&idev->lock);
> > +
> > +			__ipv6_ifa_notify(RTM_DELADDR, ifa);
> > +			atomic_notifier_call_chain(&inet6addr_chain, NETDEV_DOWN, ifa);
> > +			in6_ifa_put(ifa);
> >  
> > -		write_lock_bh(&idev->lock);
> > +			write_lock_bh(&idev->lock);
> > +		}
> 
> What about addrconf_del_timer()?  It didn't seem to make it to this else{} from
> the original.
> 
> -Brian

addrconf_del_timer is already being done earlier in same code
no need to do it twice.

-- 
