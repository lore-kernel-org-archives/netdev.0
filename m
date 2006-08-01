From: Stephane Doyon <sdoyon@max-t.com>
Subject: Re: E1000: bug on error path in e1000_probe()
Date: Tue, 1 Aug 2006 15:29:38 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.0608011503150.3139@madrid.max-t.internal>
References: <Pine.LNX.4.64.0607311522200.3139@madrid.max-t.internal>
 <44CFA382.7040703@intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Cramer, Jeb J" <jeb.j.cramer@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h216-18-124-229.gtcust.grouptelecom.net ([216.18.124.229]:9668
	"EHLO mail.max-t.com") by vger.kernel.org with ESMTP
	id S1751840AbWHATbA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Aug 2006 15:31:00 -0400
To: Auke Kok <auke-jan.h.kok@intel.com>
In-Reply-To: <44CFA382.7040703@intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 1 Aug 2006, Auke Kok wrote:

> Stephane Doyon wrote:
>>  The e1000_probe() function passes references to the netdev structure
>>  before it's actually registered. In the (admittedly obscure) case where
>>  the netdev registration fails, we are left with a dangling reference.
>>
>>  Specifically, e1000_probe() calls
>>          netif_carrier_off(netdev);
>>  before register_netdev(netdev).
>>
>>  (It also calls pci_set_drvdata(pdev, netdev) rather early, not sure how
>>  important that is.)
>>
>>  netif_carrier_off() does linkwatch_fire_event(dev);, which in turn does
>>  dev_hold(dev); and queues up an event with a reference to the netdev.
>>
>>  But the net_device reference counting mechanism only works on registered
>>  netdevs.
>>
>>  Should the register_netdev() call fail, the error path does
>>  free_netdev(netdev);, and when the event goes off, it accesses random
>>  memory through the dangling reference.
>>
>>  I would recommend moving the register_netdev() call earlier.
>
> We agree that this may be an issue and we're looking at how this mis-ordering 
> entered the code in the first place. I'm probably going to send a patch later 
> today or include it in this week-worths upstream patches later this week.

Thank you for looking at this.

> We were wondering however how you encountered this problem? Did you see a 
> case where this race actually happened? it might be an interesting case to 
> look at. Or did you do this by code review only?

Yes I did see a case where this happened, but the failure in 
register_netdev() was due to some unrelated kernel code modifications I 
was working with. The effect of the dangling reference was an unhandled 
"kernel paging request somewhere in the USB EHCI driver where some pointer 
got corrupted. The USB modules were being inserted soon after the e1000. I 
moved things around and eventually I put a sleep after the modprobe e1000, 
and then I got a "BUG at kernel/timer.c:279!" instead, and the backtrace 
showed mod_timer() <= __netdev_watchdog_up() <= ... <= dev_activate)( <= 
linkwatch_run_queue()... I figured out the problem from there. In 
e1000_probe(), I moved netif_carrier_off() (and pci_set_drvdata( and 
netif_stop_queue() too for good measure) to after the register_netdev() 
call, and that made the weird effects go away. The error path in question 
is pretty obscure, but it wasn't easy working backward from the memory 
corruption effect, so that's my extra incentive for reporting the problem.

