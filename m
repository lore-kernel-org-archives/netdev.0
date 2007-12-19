From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] e1000: Use deferrable timer for watchdog
Date: Wed, 19 Dec 2007 15:00:02 -0800
Message-ID: <4769A272.5060802@intel.com>
References: <Pine.LNX.4.64.0712182040470.3616@mini.warudkars.net>	 <47696AC9.90204@intel.com>	 <82e4877d0712191139k4dbae463icf2a59c8c0104010@mail.gmail.com>	 <47698F4E.40209@intel.com> <82e4877d0712191435r5d3163f2i684270b6b41f4fd0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, Arjan van de Ven <arjan@linux.intel.com>
To: Parag Warudkar <parag.warudkar@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:7034 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752582AbXLSXAh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Dec 2007 18:00:37 -0500
In-Reply-To: <82e4877d0712191435r5d3163f2i684270b6b41f4fd0@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parag Warudkar wrote:
> On Dec 19, 2007 4:38 PM, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> Parag Warudkar wrote:
>>> On 12/19/07, Kok, Auke <auke-jan.h.kok@intel.com> wrote:
>> why would this patch reduce wakeups even more than round_jiffies()? Does it make
>> our ~2 second update interval not reliable? can you quantify "shows it reduces" ?
>> Or timer only runs once every two seconds...
> 
> Without the patch - here is what powertop reports steady on my desktop -
> 
> Wakeups-from-idle per second :  8.5     interval: 1.9s
> no ACPI power usage estimate available
> 
> Top causes for wakeups:
>   28.6% (  4.0)     <kernel core> : clocksource_register (clocksource_watchdog)
>   14.3% (  2.0)         automount : futex_wait (hrtimer_wakeup)
>   14.3% (  2.0)              ntpd : do_setitimer (it_real_fn)
>   14.3% (  2.0)           ntpdate : do_adjtimex (sync_cmos_clock)
>    7.1% (  1.0)       <interrupt> : PS/2 keyboard/mouse/touchpad
>    7.1% (  1.0)       <interrupt> : eth0
>    7.1% (  1.0)                ip : e1000_intr_msi (e1000_watchdog)
> 
> $> stop network; rmmod e1000e
> $> patch e1000e/netdev.c ; rebuild ; insmod
> $> Wait for things to settle
> 
> With the patch here is what it shows steadily -
> 
> Wakeups-from-idle per second :  7.5     interval: 5.8s
> no ACPI power usage estimate available
> 
> Top causes for wakeups:
>   32.4% (  2.2)     <kernel core> : clocksource_register (clocksource_watchdog)
>   17.6% (  1.2)              ntpd : do_setitimer (it_real_fn)
>   14.7% (  1.0)           ntpdate : do_adjtimex (sync_cmos_clock)
>    8.8% (  0.6)       <interrupt> : eth0
>    5.9% (  0.4)          events/1 : __netdev_watchdog_up (dev_watchdog)
>    5.9% (  0.4)     <kernel core> : neigh_table_init_no_netlink
> (neigh_periodic_   5.9% (  0.4)   <kernel module> :
> neigh_table_init_no_netlink (neigh_periodic_timer)
> 
> So no longer e1000_watchdog is waking up the CPU for its own sake - it
> still runs but when the CPU is already out of IDLE to run something
> else that needs to be run undeferred.
> Wakeups from IDLE are down by 1 - from 8.5 to 7.5 .
> 
>> maybe I just don't understand the effect of timer_set_deferrable() - we're already
>> deferring it ourselves when we want to. If that is not working then I suggest that
>> we fix that first instead of postponing the critical first run of the e1000
>> watchdog task.
> 
> There is of course a difference between round_jiffies() and
> timer_set_deferrable() if that's what you were referring to.
> round_jiffies() will make the timer run at whatever rounded value no
> matter if the CPU is already IDLE or not. Making the timer deferrable
> makes it run only when the CPU is NOT IDLE - that is to say it is busy
> running something else - another non-deferrable timer for instance.
> 
>> People in the datacenter really don't want to see more delays when bringing up
>> link, and we get frequent calls about it already being long on gigabit (not even
>> minding spanning tree). Adding 25% to that time isn't going to down very nicely
>> with them.
>>
> Well but when the machine is coming up the CPU is not going to be IDLE
> and your initial timer will likely run when it wants to - i.e.
> deferable timers won't be deferred if the CPU is not IDLE.
> On the other hand Data center people do care about power consumption
> and they would much rather make sure they don't lose network links on
> Production boxes - so a properly configured machine/network should not
> need to bring up the link more than a small number of times if at all.
> Lastly e1000 is also sold with many desktop machines (like mine) and
> those people will surely appreciate lesser wakeups.
> 
> I don't have GigE connection where my desktop is located and with
> 100Mbps I don't notice any measurable delay in bringing up the link -
> may be you could try with this patch and see exactly how longer if at
> all it takes to bring up the link on a GigE connected machine.

OK, I think that would be an interesting venture and I'm willing to see if I can
get those numbers.

I'm just wondering if round_jiffies() is largely obsolete because of this. It
might just make things worse

Auke
