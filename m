From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 10:09:58 +0200
Message-ID: <20080617080958.GC12535@elte.hu>
References: <20080613114746.GA27811@elte.hu>
	<20080616.165900.189566405.davem@davemloft.net>
	<20080617072658.GA12535@elte.hu>
	<20080617.003832.130616157.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mcmanus@ducksong.com, ilpo.jarvinen@helsinki.fi,
	kuznet@ms2.inr.ac.ru, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080617.003832.130616157.davem@davemloft.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: e1000-devel-bounces@lists.sourceforge.net
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Tue, 17 Jun 2008 09:26:58 +0200
> 
> > So since there's no clear bug pattern and no sure reproducability on 
> > my side i'd suggest we track this problem separately and "do 
> > nothing" right now. I've excluded this warning from my 'is the 
> > freshly booted kernel buggy' list of conditions of -tip testing so 
> > it's not holding me up.
> 
> I'm going to push the revert through just to be safe and I think it's 
> a good idea to do so because all of those defer accept changes should 
> be resubmitted as a group for 2.6.27

okay - in that case the full revert is well-tested on my side as well, 
fwiw.

Tested-by: Ingo Molnar <mingo@elte.hu>

> > and i can apply any test-patch if that would be helpful - if it does 
> > a WARN_ON() i'll notice it. (pure extra debug printks with no stack 
> > trace are much harder to notice in automated tests)
> 
> I don't have time to work on your bug, sorry.  Someone else will have 
> to step forward and help you with it.

it's not really "my bug" - i just offered help to debug someone else's 
bug :-) This is pretty common hw so i guess there will be such reports.

Let me describe what i'm doing exactly: i do a lot of randomized testing 
on about a dozen real systems (all across the x86 spectrum) so i tend to 
trigger a lot of mainline bugs pretty early on.

My collection of kernel bugs for the last 8 months shows 1285 bugs 
(kernel crashes or build failures - about 50%/50%) triggered. One 
test-system alone has a serial log of 15 gigabytes - and there's a dozen 
of them. That's about 5 kernel bugs a day handled by me, on average.

These systems have about 10 times the hardware variability of your 
Niagara system for example, and many of them are rather difficult to 
debug (laptops without serial port, etc.). So i physically cannot avoid 
and debug all bugs on all my test-systems, like you do on the Niagara. I 
will report bugs, i'll bisect anything that is bisectable (on average i 
bisect once a day), and i can add patches and report any test-results, 
and i'll of course debug any bugs that look like heavy mainline 
showstoppers.

> FWIW I don't think your TX timeout problem has anything to do with 
> packet ordering.  The TX element of the network device is totally 
> stateless, but it's hanging under some set of circumstances to the 
> point where we timeout and reset the hardware to get it going again.

ok. That's e1000 then. Cc:s added. Stock T60 laptop, 32-bit:

02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
        Subsystem: Lenovo ThinkPad T60
        Flags: bus master, fast devsel, latency 0, IRQ 16
        Memory at ee000000 (32-bit, non-prefetchable) [size=128K]
        I/O ports at 2000 [size=32]
        Capabilities: <access denied>
        Kernel driver in use: e1000

the problem is this non-fatal warning showing up after bootup, 
sporadically, in a non-reproducible way:

[  173.354049] NETDEV WATCHDOG: eth0: transmit timed out
[  173.354148] ------------[ cut here ]------------
[  173.354221] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x9a/0xec()
[  173.354298] Modules linked in:
[  173.354421] Pid: 13452, comm: cc1 Tainted: G        W 2.6.26-rc6-00273-g81ae43a-dirty #2573
[  173.354516]  [<c01250ca>] warn_on_slowpath+0x46/0x76
[  173.354641]  [<c011d428>] ? try_to_wake_up+0x1d6/0x1e0
[  173.354815]  [<c01411e9>] ? trace_hardirqs_off+0xb/0xd
[  173.357370]  [<c011d43d>] ? default_wake_function+0xb/0xd
[  173.357370]  [<c014112a>] ? trace_hardirqs_off_caller+0x15/0xc9
[  173.357370]  [<c01411e9>] ? trace_hardirqs_off+0xb/0xd
[  173.357370]  [<c0142c83>] ? trace_hardirqs_on+0xb/0xd
[  173.357370]  [<c0142b33>] ? trace_hardirqs_on_caller+0x16/0x15b
[  173.357370]  [<c0142c83>] ? trace_hardirqs_on+0xb/0xd
[  173.357370]  [<c06bb3c9>] ? _spin_unlock_irqrestore+0x5b/0x71
[  173.357370]  [<c0133d46>] ? __queue_work+0x2d/0x32
[  173.357370]  [<c0134023>] ? queue_work+0x50/0x72
[  173.357483]  [<c0134059>] ? schedule_work+0x14/0x16
[  173.357654]  [<c05c59b8>] dev_watchdog+0x9a/0xec
[  173.357783]  [<c012d456>] run_timer_softirq+0x13d/0x19d
[  173.357905]  [<c05c591e>] ? dev_watchdog+0x0/0xec
[  173.358073]  [<c05c591e>] ? dev_watchdog+0x0/0xec
[  173.360804]  [<c0129ad7>] __do_softirq+0xb2/0x15c
[  173.360804]  [<c0129a25>] ? __do_softirq+0x0/0x15c
[  173.360804]  [<c0105526>] do_softirq+0x84/0xe9
[  173.360804]  [<c0129996>] irq_exit+0x4b/0x88
[  173.360804]  [<c010ec7a>] smp_apic_timer_interrupt+0x73/0x81
[  173.360804]  [<c0103ddd>] apic_timer_interrupt+0x2d/0x34
[  173.360804]  =======================
[  173.360804] ---[ end trace a7919e7f17c0a725 ]---

full report can be found at:

   http://lkml.org/lkml/2008/6/13/224

i have 3 other test-systems with e1000 (with a similar CPU) which are 
_not_ showing this symptom, so this could be some model-specific e1000 
issue.

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
