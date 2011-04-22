From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] netconsole: fix deadlock when removing net driver that
 netconsole is using (v2)
Date: Fri, 22 Apr 2011 17:31:45 -0400
Message-ID: <20110422213145.GA2332@neilslaptop.think-freely.org>
References: <1303481216-10348-1-git-send-email-nhorman@tuxdriver.com>
 <1303495859-12279-1-git-send-email-nhorman@tuxdriver.com>
 <20110422.114033.104072820.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:52698 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773Ab1DVVb4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Apr 2011 17:31:56 -0400
Content-Disposition: inline
In-Reply-To: <20110422.114033.104072820.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 22, 2011 at 11:40:33AM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Fri, 22 Apr 2011 14:10:59 -0400
> 
> > @@ -683,9 +684,16 @@ static int netconsole_netdev_event(struct notifier_block *this,
> >  				 * rtnl_lock already held
> >  				 */
> >  				if (nt->np.dev) {
> > +					spin_unlock_irqrestore(
> > +							      &target_list_lock,
> > +							      flags);
> >  					__netpoll_cleanup(&nt->np);
> > +					spin_lock_irqsave(&target_list_lock,
> > +							  flags);
> >  					dev_put(nt->np.dev);
> >  					nt->np.dev = NULL;
> > +					netconsole_target_put(nt);
> > +					goto restart;
> 
> If you drop the lock here, another cpu can put the device and set it
> to NULL.
> 
> In which case you'll double release when you regrab the lock here.
> 
> Too bad you can't NULL out the device before dropping the lock,
> because that way would be able to ensure you'd be the only releaser.
> 
> But that won't work because __netpoll_cleanup() wants the device
> pointer to be set.
> 
> Hmmm...
> 
I understand what you're saying here, but I think we're ok in this particular
case.  I say that because all other callers of __netpoll_cleanup, call it via
netpoll_cleanup, which does the dev_put under protection of the rtnl_lock.  This
call is also under the rtnl_lock protection, its just taken when the event
notification is made (thats why we call __netpoll_cleanup instead of
netpoll_cleanup).  The target_list_lock just protects the integrity of the
netconsole_target list.  If someone disables a netconsole via configfs, they'll
block on the rtnl_lock.  Since no path through configfs takes the
target_list_lock and rtnl (via netpoll_cleanup) in any nested fashion, we're
safe from deadlock.

Best
Neil

