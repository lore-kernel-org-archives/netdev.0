From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] dropmon: add ability to detect when hardware
	dropsrxpackets
Date: Wed, 13 May 2009 18:03:59 -0700
Message-ID: <20090514010359.GL6752@linux.vnet.ibm.com>
References: <20090508195026.GB13017@hmsreliant.think-freely.org> <4A05230B.6070806@cosmosbay.com> <20090512163044.GD5019@hmsreliant.think-freely.org> <20090513182354.GH6752@linux.vnet.ibm.com> <20090514004548.GA14428@localhost.localdomain>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>, netdev@vger.kernel.org,
	davem@davemloft.net
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:52103 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754181AbZENBEA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2009 21:04:00 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e7.ny.us.ibm.com (8.13.1/8.13.1) with ESMTP id n4E0qsa0007064
	for <netdev@vger.kernel.org>; Wed, 13 May 2009 20:52:54 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4E140eD252772
	for <netdev@vger.kernel.org>; Wed, 13 May 2009 21:04:00 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4E13xgx029133
	for <netdev@vger.kernel.org>; Wed, 13 May 2009 21:04:00 -0400
Content-Disposition: inline
In-Reply-To: <20090514004548.GA14428@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 13, 2009 at 08:45:48PM -0400, Neil Horman wrote:
> On Wed, May 13, 2009 at 11:23:54AM -0700, Paul E. McKenney wrote:
> > On Tue, May 12, 2009 at 12:30:44PM -0400, Neil Horman wrote:
> > > On Sat, May 09, 2009 at 08:30:35AM +0200, Eric Dumazet wrote:
> > > > 
> > > > I dont fully understand your patch, but at least have some questions
> > > > about rcu stuff.
> > > > 
> > > 
> > > 
> > > Ok, so I went back and I think I managed to better understand the RCU interface.
> > > New patch attached, works the same way, saving for the gross previous misuse of
> > > rcu.
> > > 
> > > 
> > > Patch to add the ability to detect drops in hardware interfaces via dropwatch.
> > > Adds a tracepoint to net_rx_action to signal everytime a napi instance is
> > > polled.  The dropmon code then periodically checks to see if the rx_frames
> > > counter has changed, and if so, adds a drop notification to the netlink
> > > protocol, using the reserved all-0's vector to indicate the drop location was in
> > > hardware, rather than somewhere in the code.
> > 
> > One concern shown below.
> > 
> <snip>
> >  		tracepoint_synchronize_unregister();
> > > +
> > > +		/*
> > > +		 * Clean the device list
> > > +		 */
> > > +		list_for_each_entry_rcu(new_stat, &hw_stats_list, list) {
> > > +			if (new_stat->dev == NULL) {
> > > +				list_del_rcu(&new_stat->list);
> > > +				call_rcu(&new_stat->rcu, free_dm_hw_stat);
> > 
> > Much better!  ;-)
> > 
> Thanks! :)
> <snip>
> 
> > > +
> > > +	switch (event) {
> > > +	case NETDEV_REGISTER:
> > > +		new_stat = kzalloc(sizeof(struct dm_hw_stat_delta), GFP_KERNEL);
> > > +
> > > +		if (!new_stat)
> > > +			goto out;
> > > +
> > > +		new_stat->dev = dev;
> > > +		INIT_RCU_HEAD(&new_stat->rcu);
> > > +		list_add_rcu(&new_stat->list, &hw_stats_list);
> > 
> > Don't we need to be holding trace_state_lock at this point?  Otherwise,
> > can't we mangle the list with a concurrent list_add_rcu() and
> > list_del_rcu()?
> > 
> I thought the purpose of list_add_rcu and list_del_rcu was to be
> able to modify lists without needing to hold additional locks.  Or am
> I missing something else about the nuance of how RCU works?

The purpose of list_add_rcu() and list_del_rcu() is to be able to permit
concurrent readers to traverse the list while you are modifying that same
list.  You still need something to handle concurrent updates to the list.
The usual approach is to use locks, in this case, to hold trace_state_lock
across the addition, given that it is already held across the removal.

The reason that I expect holding the lock to be OK is that you cannot
add elements faster than you delete them long-term, so given that you
are willing to hold the lock over deletions, you are probably OK also
holding that same lock over additions.  But please let me know if that
is not the case!

							Thanx, Paul
