From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: [RFC] bonding: fix workqueue re-arming races
Date: Wed, 1 Sep 2010 15:30:56 +0200
Message-ID: <20100901133056.GB12447@midget.suse.cz>
References: <20136.1283288063@death>
 <20100901122356.GB9468@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, Jiri Bohac <jbohac@suse.cz>,
	bonding-devel@lists.sourceforge.net, markine@google.com,
	chavey@google.com, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48262 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753219Ab0IAN3V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Sep 2010 09:29:21 -0400
Content-Disposition: inline
In-Reply-To: <20100901122356.GB9468@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 01, 2010 at 12:23:56PM +0000, Jarek Poplawski wrote:
> On 2010-08-31 22:54, Jay Vosburgh wrote:
> > 	What prevents this from deadlocking such that cpu A is in
> > bond_close, holding RTNL and in cancel_delayed_work_sync, while cpu B is
> > in the above function, trying to acquire RTNL?
> 
> I guess this one isn't cancelled in bond_close, so it should be safe.

Nah, Jay was correct. Although this work item is not explicitly
cancelled with cancel_delayed_work_sync(), it is on the same
workqueue as work items that are being cancelled with
cancel_delayed_work_sync(), so this can still cause a deadlock.
Fixed in the new version of the patch by putting these on a
separate workqueue.

> > 	Also, assuming for the moment that the above isn't a problem,
> > curr_active_slave may be NULL if the last slave is removed between the
> > time bond_alb_promisc_disable is scheduled and when it runs.  I'm not
> > sure that the alb_bond_info can be guaranteed to be valid, either, if
> > the mode changed.
> 
> Probably some or all of these work functions should test for closing
> eg. with netif_running() or some other flag/variable under rtnl_lock().
> 
> ....
> >> static void bond_work_cancel_all(struct bonding *bond)
> >> {
> >> -	write_lock_bh(&bond->lock);
> >> -	bond->kill_timers = 1;
> >> -	write_unlock_bh(&bond->lock);
> >> -
> >> 	if (bond->params.miimon && delayed_work_pending(&bond->mii_work))
> 
> I'd suggest to skip these delayed_work_pending() tests.

I agree, these should not be needed anymore, since bond_close()
now makes sure the re-arming work is cancelled. I'll update the
patch if Jay thinks it's otherwise good.

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ

