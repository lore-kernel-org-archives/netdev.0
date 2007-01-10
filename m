From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH 1/1] bonding: eliminate RTNL assertion spew
Date: Wed, 10 Jan 2007 11:53:45 -0800
Message-ID: <20070110115345.116f1fef@freekitty>
References: <20070109225900.GA11755@gospo.rdu.redhat.com>
	<20070109150935.6ec3ce69@localhost>
	<20070110193355.GA13249@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, fubar@us.ibm.com,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:47478 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965050AbXAJUEb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 15:04:31 -0500
To: Andy Gospodarek <andy@greyhouse.net>
In-Reply-To: <20070110193355.GA13249@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 10 Jan 2007 14:33:58 -0500
Andy Gospodarek <andy@greyhouse.net> wrote:

> On Tue, Jan 09, 2007 at 03:09:35PM -0800, Stephen Hemminger wrote:
> > On Tue, 9 Jan 2007 17:59:01 -0500
> > Andy Gospodarek <andy@greyhouse.net> wrote:
> > 
> > > 
> > > These changes eliminate the messages indicating that the rtnetlink lock
> > > isn't held when bonding tries to change the MAC address of an interface.
> > > These calls generally come from timer-pops, but also from sysfs events
> > > since neither hold the rtnl lock.  
> > > 
> > > The spew generally looks something like this:
> > > 
> > > RTNL: assertion failed at net/core/fib_rules.c (391)
> > >  [<c028d12e>] fib_rules_event+0x3a/0xeb
> > >  [<c02da576>] notifier_call_chain+0x19/0x29
> > >  [<c0280ce6>] dev_set_mac_address+0x46/0x4b
> > >  [<f8a2a686>] alb_set_slave_mac_addr+0x5d/0x88 [bonding]
> > >  [<f8a2aa7e>] alb_swap_mac_addr+0x88/0x134 [bonding]
> > >  [<f8a25ed9>] bond_change_active_slave+0x1a1/0x2c5 [bonding]
> > >  [<f8a262e8>] bond_select_active_slave+0xa8/0xe1 [bonding]
> > >  [<f8a27ecb>] bond_mii_monitor+0x3af/0x3fd [bonding]
> > >  [<c0121896>] run_workqueue+0x85/0xc5
> > >  [<f8a27b1c>] bond_mii_monitor+0x0/0x3fd [bonding]
> > >  [<c0121d83>] worker_thread+0xe8/0x119
> > >  [<c0111179>] default_wake_function+0x0/0xc
> > >  [<c0121c9b>] worker_thread+0x0/0x119
> > >  [<c0124099>] kthread+0xad/0xd8
> > >  [<c0123fec>] kthread+0x0/0xd8
> > >  .....
> > > 
> > > This patch was mostly inspired from parts of some potential bonding
> > > updates Jay Vosburgh <fubar@us.ibm.com> and I discussed in December, so
> > > he deserves most of the credit for the idea.
> > > 
> > > I've tested it on several systems and it works as I expect.  Deadlocks
> > > between the rtnl and global bond lock are avoided since we drop the
> > > global bond lock before taking the rtnl lock.
> > > 
> > 
> > 
> > This seems like the ugly way to do it. Couldn't you just change figure out
> > how to acquire RTNL first. It wouldn't hurt to acquire it in the monitor
> > routine even if you don't need it.
> > 
> > Conditional locking is a bad road to start down.
> 
> 
> Stephen and Jeff, 
> 
> Does this seem like a better alternative?  Taking the rtnetlink lock
> before the global bond luck should avoid deadlocks since it is done that
> way throughout the bonding code.  I didn't notice any immediate problems,
> but it was by no means and exhaustive stress test.  
> 
> Thanks,
> 
> -andy

Looks good, you might be able to skip it for the pure read case of monitor.
In future you might be able to replace the read lock with RCU, and just
use RTNL as the write_lock.

-- 
Stephen Hemminger <shemminger@osdl.org>
