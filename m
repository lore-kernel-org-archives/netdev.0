From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] Fix Warnings from net/netlink/genetlink.c
Date: Tue, 11 Aug 2009 21:03:55 -0700
Message-ID: <1250049835.30166.47.camel@localhost.localdomain>
References: <1249985224.13065.11.camel@HunTEr>
	 <1250035061.30166.42.camel@localhost.localdomain>
	 <20090811202459.7f98e496@nehalam>
	 <20090812135031.a38be3f6.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	vibi_sreenivasan@cms.com, netdev <netdev@vger.kernel.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	Thomas Graf <tgraf@suug.ch>,
	linux-next <linux-next@vger.kernel.org>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57485 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbZHLEEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Aug 2009 00:04:16 -0400
In-Reply-To: <20090812135031.a38be3f6.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stephen,

> > > > @@ -136,7 +136,7 @@ int genl_register_mc_group(struct genl_family *family,
> > > >  {
> > > >         int id;
> > > >         unsigned long *new_groups;
> > > > -       int err;
> > > > +       int err = 0;
> > > >  
> > > >         BUG_ON(grp->name[0] == '\0');
> > > 
> > > this looks fishy. How does gcc thinks this variable is uninitialized. If
> > > I look at the code in Linus' tree, I don't see it.
> > 
> > Agreed, and the line numbers are off.
> 
> In the -next tree, it looks like this:

it would have been nice if the patch actually indicates that it is for
-next since otherwise just shutting up a compiler warning is a bad idea
in this case.

> int genl_register_mc_group(struct genl_family *family,
> 			   struct genl_multicast_group *grp)
> {
> 	int id;
> 	unsigned long *new_groups;
> 	int err;
> 
> 	BUG_ON(grp->name[0] == '\0');
> 
> 	genl_lock();
> 
> 	/* special-case our own group */
> 	if (grp == &notify_grp)
> 		id = GENL_ID_CTRL;
> 	else
> 		id = find_first_zero_bit(mc_groups,
> 					 mc_groups_longs * BITS_PER_LONG);
> 
> 
> 	if (id >= mc_groups_longs * BITS_PER_LONG) {
> 		size_t nlen = (mc_groups_longs + 1) * sizeof(unsigned long);
> 
> 		if (mc_groups == &mc_group_start) {
> 			new_groups = kzalloc(nlen, GFP_KERNEL);
> 			if (!new_groups) {
> 				err = -ENOMEM;
> 				goto out;
> 			}
> 			mc_groups = new_groups;
> 			*mc_groups = mc_group_start;
> 		} else {
> 			new_groups = krealloc(mc_groups, nlen, GFP_KERNEL);
> 			if (!new_groups) {
> 				err = -ENOMEM;
> 				goto out;
> 			}
> 			mc_groups = new_groups;
> 			mc_groups[mc_groups_longs] = 0;
> 		}
> 		mc_groups_longs++;
> 	}
> 
> 	if (family->netnsok) {
> 		struct net *net;
> 
> 		rcu_read_lock();
> 		for_each_net_rcu(net) {
> 			err = netlink_change_ngroups(net->genl_sock,
> 					mc_groups_longs * BITS_PER_LONG);
> 			if (err) {
> 				rcu_read_unlock();
> 				goto out;
> 			}
> 		}
> 		rcu_read_unlock();
> 	} else {
> 		err = netlink_change_ngroups(init_net.genl_sock,
> 					     mc_groups_longs * BITS_PER_LONG);
> 		if (err)
> 			goto out;
> 	}
> 
> 	grp->id = id;
> 	set_bit(id, mc_groups);
> 	list_add_tail(&grp->list, &family->mcast_groups);
> 	grp->family = family;
> 
> 	genl_ctrl_event(CTRL_CMD_NEWMCAST_GRP, grp);
>  out:
> 	genl_unlock();
> 	return err;
> }
> 
> so if family->netnsok is true and the for_each_net_rcu loop executes 0
> times, err will not be set ...  Now, that may not be logically possible,
> but I can't tell that from this code.

I prefer we add a err = 0 in the if (family->netnsok) { block instead of
just globally setting it to a value.

Regards

Marcel


