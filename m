From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH net-next] [v2] bonding: remove entries for master_ip
	and vlan_ip and query devices instead
Date: Thu, 22 Mar 2012 16:22:22 -0400
Message-ID: <20120322202222.GA15291@gospo.rdu.redhat.com>
References: <1332365802-21550-1-git-send-email-andy@greyhouse.net> <20120321.223411.1471023630379810739.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: andy@greyhouse.net, netdev@vger.kernel.org, ralf.zeidler@nsn.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11852 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954Ab2CVUW2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2012 16:22:28 -0400
Content-Disposition: inline
In-Reply-To: <20120321.223411.1471023630379810739.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 10:34:11PM -0400, David Miller wrote:
> From: Andy Gospodarek <andy@greyhouse.net>
> Date: Wed, 21 Mar 2012 17:36:42 -0400
> 
> > As the Subject indicates this patch drops the master_ip and vlan_ip
> > elements from the 'bonding' and 'vlan_entry' structs, respectively.
> > This can be done because a device's address-list is now traversed to
> > determine the optimal source IP address for ARP requests and for checks
> > to see if the bonding device has a particular IP address.  This code
> > could have all be contained inside the bonding driver, but it made more
> > sense to me to EXPORT and call inet_confirm_addr since it did exactly
> > what was needed.
> 
> I like this patch a lot but you have one little bug that needs to be
> fixed:
> 
> > +	rcu_read_lock();
> > +	in_dev = __in_dev_get_rcu(dev);
> > +	rcu_read_unlock();
> > +
> > +	if (in_dev)
> > +		addr = inet_confirm_addr(in_dev, dst, local, RT_SCOPE_HOST);
> 
> If you're going to do an RCU ref-less lookup of in_dev and then use
> it, you have to include the "use" inside of the RCU protected section
> as well.
> 
> Otherwise as soon as you rcu_read_unlock() the in_dev could be freed
> up on you.
> 
> The only exception would be if you know that all callers of
> bond_confirm_addr() ran in an RCU protected section, but I do not
> think that is universally the case here.
> 
> If you think it might be the case that we are RCU protected in all of
> these code paths already, you can remove the RCU locking altogether
> from bond_confirm_addr() and run with lockdep enabled while exercising
> all of the relevant code paths.


Thanks for catching that, Dave.  I'm pretty sure there is at least one
path where rcu_read_lock has not already been called so the protection
is needed.  I know that rcu_read_lock/unlock is called in
inet_confirm_addr, but since rcu locks can be nested, so I'll go ahead
and make that change.

There are 2 more places in the bonding driver where this is also done
incorrectly in some vlan code, so I'll fix those with a subsequent patch.
