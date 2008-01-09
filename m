From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 0/3] bonding: 3 fixes for 2.6.24
Date: Wed, 9 Jan 2008 15:17:09 -0500
Message-ID: <20080109201709.GF8728@gospo.usersys.redhat.com>
References: <11997574203125-git-send-email-fubar@us.ibm.com> <Pine.LNX.4.64.0801081949290.1135@bizon.gios.gov.pl> <29560.1199820632@death> <Pine.LNX.4.64.0801090732490.1135@bizon.gios.gov.pl> <17850.1199865514@death> <20080109152740.GE8728@gospo.usersys.redhat.com> <32361.1199901296@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Krzysztof Oledzki <olel@ans.pl>, netdev@vger.kernel.org,
	Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753849AbYAIU0H (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 15:26:07 -0500
Content-Disposition: inline
In-Reply-To: <32361.1199901296@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 09, 2008 at 09:54:56AM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> [...]
> >My initial concern was that a slave device could disappear out from
> >under us, but it seems like this certainly isn't the case since all
> >calls to bond_release are protected by rtnl-locks, so I think you are
> >correct that we are safe.  I'll test this on my setup here and let you
> >know if I see any problems.
> 
> 	Yep, all entries into enslave or remove come in with RTNL, so if
> we have RTNL there then slaves can't vanish.
> 
> 	On further inspection, I don't think it's safe to simply drop
> the locks in bond_set_multicast_list, I'm seeing a couple of cases that
> could be troublesome:
> 
> 	bond_set_promiscuity and bond_set_allmulti both reference
> curr_active_slave, which isn't protected from change by RTNL, so that
> could conflict with a change_active_slave calling bond_mc_swap (which is
> also holding the wrong locks for dev_set_promisc/allmulti).
> 
> 	It also looks like there are paths (igmp6 for one) into
> dev_mc_add that just hold a bunch of regular locks, and not RTNL, so
> those wouldn't be safe from having slaves vanish due to concurrent
> deslavement.

Eeeek!  I didn't realize that rtnl wasn't held for all those calls.  If
that's the case we can't drop all the locks.

> 	Looks like read_lock_bh for bond-lock and curr_slave_lock is
> needed in bond_set_multicast_list, and some dropping of locks is needed
> inside bond_set_promisc/allmulti.  Methinks that without any locks,
> bond_mc_add/delete could race with either a change of active slave or a
> de-enslavement of the active slave.
 
Agreed.  And despite Herbert's opinion that this isn't the correct fix,
I think this will work fine.  This is one of the cases where we can take
a write_lock(bond->lock) in softirq context, so we need to drop that (or
make sure all the read_lock's are read_lock_bh's).  The latter isn't
really an option since having a majority of the bonding code run in
softirq context was what we are trying to avoid with the workqueue
conversion.

> 	I'm wondering if this is worth trying to make perfect for 2.6.24
> (and maybe making things worse), and, instead, just do this:
> 
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> index 77d004d..8b9e33a 100644
> --- a/drivers/net/bonding/bond_main.c
> +++ b/drivers/net/bonding/bond_main.c
> @@ -3937,7 +3937,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>  	struct bonding *bond = bond_dev->priv;
>  	struct dev_mc_list *dmi;
>  
> -	write_lock_bh(&bond->lock);
> +	read_lock_bh(&bond->lock);
>  
>  	/*
>  	 * Do promisc before checking multicast_mode
> @@ -3979,7 +3979,7 @@ static void bond_set_multicast_list(struct net_device *bond_dev)
>  	bond_mc_list_destroy(bond);
>  	bond_mc_list_copy(bond_dev->mc_list, bond, GFP_ATOMIC);
>  
> -	write_unlock_bh(&bond->lock);
> +	read_unlock_bh(&bond->lock);
>  }
>  
>  /*
> 
> 
> 	This should silence the lockdep (if I'm understanding what
> everybody's saying), and keep the change set to a minimum.  This might

The lockdep problem is easy to trigger.  The lockdep code does a good
job of noticing problems quickly regardless of how easy the deadlocks
are to create.

> not even be worth pushing for 2.6.24; I'm not exactly sure how difficult
> the lockdep problem would be to trigger.
> 

I'd like to see it go in there (for correct-ness) and to avoid hearing
about these lockdep issues for the next few months until it makes it
into 2.4.25.

> 	The other stuff I mention above can be dealt with later; they're
> very low-probability races that would be pretty difficult to hit even on
> purpose.
> 
> 	Thoughts?
> 
> 	-J
> 
> ---
> 	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
