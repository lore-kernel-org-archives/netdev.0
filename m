From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [Bugme-new] [Bug 7974] New: BUG: scheduling while atomic: swapper/0x10000100/0
Date: Tue, 13 Feb 2007 18:08:03 -0500
Message-ID: <20070213230803.GB26818@gospo.rdu.redhat.com>
References: <20070209133802.01286bbb.akpm@linux-foundation.org> <20070213202905.GA26818@gospo.rdu.redhat.com> <200702132226.l1DMQS22009230@death.nxdomain.ibm.com> <20070213.143243.78711492.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, shemminger@linux-foundation.org,
	lpiccilli@gelre.com.br, bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:57123 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751453AbXBMXeh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 18:34:37 -0500
Content-Disposition: inline
In-Reply-To: <20070213.143243.78711492.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 13, 2007 at 02:32:43PM -0800, David Miller wrote:
> From: Jay Vosburgh <fubar@us.ibm.com>
> Date: Tue, 13 Feb 2007 14:26:28 -0800
> 
> > 	In reference to Andy's recent patch (which first did conditional
> > locking for rtnl, then later acquired rtnl for every entry into the
> > timer function), I know the conditional locking isn't popular, but it
> > seems to me that it's a less bad alternative than holding rtnl every
> > time the bond_mii_monitor() runs (typically 10 - 50 times per second).
> > Or is the rtnl lock really so cheap that this isn't an issue?  The
> > overwhelming majority of cases the mii_monitor won't need to do anything
> > that requires rtnl, so only holding it when needed is better.
> 
> We definitely don't want to take the RTNL that often if it can
> be avoided.
> 
> Maybe if you put the RTNL acquisition deeper into the call
> path, ie. down into the code that knows RTNL is needed,
> perhaps it won't be so ugly.  Replace the conditions with
> functions.


That is almost exactly what I am working on right now.  I'm trying to
determine where the best place to put this would be so reduce the
chance that I'd be using conditional locking.  

I once put together a patch that used a macro like this (ignore the
whitespace problems, this was just a cut and paste):

/**
 * bond_rtnl_wrapper - take the rtnl_lock if needed
 * @x:         function with args
 *
 */
#define RTNL_WRAPPER(x)                \
({                                     \
       int __rc__;                     \
       if (rtnl_trylock()) {           \
               __rc__ = x;             \
               rtnl_unlock();          \
       } else {                        \
               __rc__ = x;             \
       }                               \
       __rc__;                         \
})


and wrapped it around the calls to dev_set_mac_address.  I wasn't
pleased with it, but it seemed like it worked pretty well based on the
testing I did.

