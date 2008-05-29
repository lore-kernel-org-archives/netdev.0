From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [PATCH RFC] net/bonding: announce fail-over for the active-backup
 mode
Date: Thu, 29 May 2008 13:24:58 +0300
Message-ID: <483E847A.9090508@voltaire.com>
References: <Pine.LNX.4.64.0805211550060.27300@zuben.voltaire.com> <Pine.LNX.4.64.0805271012220.18192@zuben.voltaire.com> <12513.1212013148@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:32839 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750768AbYE2KZD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2008 06:25:03 -0400
In-Reply-To: <12513.1212013148@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
>
> 	Philosophically speaking, I don't see a problem with adding a
> notifier like this, but others higher in the food chain may have
> thoughts.
OK. I will be happy to get more feedback.

> 	Your case is similar: you want to issue a notifier call during
> an active-backup failover, so that notifier call will have to be made
> holding RTNL and no other locks.
>
> 	I think the most maintainable way to do that is to convert the
> remaining callers of bond_change_active_slave to hold the correct set of
> locks, and then have bond_change_active_slave drop down to just RTNL at
> the appropriate place to make the notifier call.  That may not be as
> simple as it sounds, as it may open race windows.
>
Lets say that everyone calls bond_change_active_slave with the correct 
locks taken and the code that delivers the event, unlocks these two 
locks, call to the notifier chain through dev_set_xxx() and then locks 
them again. These locks were there in the first place to protect on 
something, so generally speaking I don't see why its allowed to unlock 
them for some window of time... is it some "best effort" compromise?

Second, if it makes sense to have this window at time where the other 
two locks are not taken and only the RTNL one is taken. Is there any 
reason I can't take the approach of bond_alb_handle_active_change() 
which as you pointed out, releases the locks, delivers the event and 
take them again? is there something different between the possible calls 
under the active-backup mode vs the ALB mode that requires to do this 
deeper fix?

>> bonding: bond0: link status definitely down for interface ib0, disabling it
>> bonding: bond0: making interface ib1 the new active one.
>> BUG: scheduling while atomic: bond0/14237/0x10000100
> It's from the call to nlmsg_new (an inline that calls alloc_skb) in rtmsg_ifinfo, which allocates at GFP_KERNEL.  As I recall, there are other similar cases, so it's not simply a matter of changing rtmsg_ifinfo.  The notifier calls have to happen with RTNL and no other locks.
Understood, thanks for clarifying this.

Or.

