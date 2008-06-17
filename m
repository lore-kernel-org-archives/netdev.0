From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Tue, 17 Jun 2008 10:32:20 +0200
Message-ID: <20080617083220.GA11393@elte.hu>
References: <20080613114746.GA27811@elte.hu>
	<20080616.165900.189566405.davem@davemloft.net>
	<20080617072658.GA12535@elte.hu>
	<20080617.003832.130616157.davem@davemloft.net>
	<20080617080958.GC12535@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, mcmanus@ducksong.com,
	ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru, xemul@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080617080958.GC12535@elte.hu>
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


* Ingo Molnar <mingo@elte.hu> wrote:

> 
> > FWIW I don't think your TX timeout problem has anything to do with 
> > packet ordering.  The TX element of the network device is totally 
> > stateless, but it's hanging under some set of circumstances to the 
> > point where we timeout and reset the hardware to get it going again.
> 
> ok. That's e1000 then. Cc:s added. Stock T60 laptop, 32-bit:
> 
> 02:00.0 Ethernet controller: Intel Corporation 82573L Gigabit Ethernet Controller
>         Subsystem: Lenovo ThinkPad T60
>         Flags: bus master, fast devsel, latency 0, IRQ 16
>         Memory at ee000000 (32-bit, non-prefetchable) [size=128K]
>         I/O ports at 2000 [size=32]
>         Capabilities: <access denied>
>         Kernel driver in use: e1000
> 
> the problem is this non-fatal warning showing up after bootup, 
> sporadically, in a non-reproducible way:
> 
> [  173.354049] NETDEV WATCHDOG: eth0: transmit timed out
> [  173.354148] ------------[ cut here ]------------
> [  173.354221] WARNING: at net/sched/sch_generic.c:222 dev_watchdog+0x9a/0xec()
> [  173.354298] Modules linked in:
> [  173.354421] Pid: 13452, comm: cc1 Tainted: G        W 2.6.26-rc6-00273-g81ae43a-dirty #2573
> [  173.354516]  [<c01250ca>] warn_on_slowpath+0x46/0x76
> [  173.354641]  [<c011d428>] ? try_to_wake_up+0x1d6/0x1e0
> [  173.354815]  [<c01411e9>] ? trace_hardirqs_off+0xb/0xd
> [  173.357370]  [<c011d43d>] ? default_wake_function+0xb/0xd
> [  173.357370]  [<c014112a>] ? trace_hardirqs_off_caller+0x15/0xc9
> [  173.357370]  [<c01411e9>] ? trace_hardirqs_off+0xb/0xd
> [  173.357370]  [<c0142c83>] ? trace_hardirqs_on+0xb/0xd
> [  173.357370]  [<c0142b33>] ? trace_hardirqs_on_caller+0x16/0x15b
> [  173.357370]  [<c0142c83>] ? trace_hardirqs_on+0xb/0xd
> [  173.357370]  [<c06bb3c9>] ? _spin_unlock_irqrestore+0x5b/0x71
> [  173.357370]  [<c0133d46>] ? __queue_work+0x2d/0x32
> [  173.357370]  [<c0134023>] ? queue_work+0x50/0x72
> [  173.357483]  [<c0134059>] ? schedule_work+0x14/0x16
> [  173.357654]  [<c05c59b8>] dev_watchdog+0x9a/0xec
> [  173.357783]  [<c012d456>] run_timer_softirq+0x13d/0x19d
> [  173.357905]  [<c05c591e>] ? dev_watchdog+0x0/0xec
> [  173.358073]  [<c05c591e>] ? dev_watchdog+0x0/0xec
> [  173.360804]  [<c0129ad7>] __do_softirq+0xb2/0x15c
> [  173.360804]  [<c0129a25>] ? __do_softirq+0x0/0x15c
> [  173.360804]  [<c0105526>] do_softirq+0x84/0xe9
> [  173.360804]  [<c0129996>] irq_exit+0x4b/0x88
> [  173.360804]  [<c010ec7a>] smp_apic_timer_interrupt+0x73/0x81
> [  173.360804]  [<c0103ddd>] apic_timer_interrupt+0x2d/0x34
> [  173.360804]  =======================
> [  173.360804] ---[ end trace a7919e7f17c0a725 ]---
> 
> full report can be found at:
> 
>    http://lkml.org/lkml/2008/6/13/224
> 
> i have 3 other test-systems with e1000 (with a similar CPU) which are 
> _not_ showing this symptom, so this could be some model-specific e1000 
> issue.

btw., this reminds me that this is the same system that has a serious 
e1000 network latency bug which i have reported more than a year ago, 
but which still does not appear to be fixed in latest mainline:

 PING europe (10.0.1.15) 56(84) bytes of data.
 64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=1.51 ms
 64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=404 ms
 64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=487 ms
 64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=296 ms
 64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=305 ms
 64 bytes from europe (10.0.1.15): icmp_seq=6 ttl=64 time=1011 ms
 64 bytes from europe (10.0.1.15): icmp_seq=7 ttl=64 time=0.209 ms
 64 bytes from europe (10.0.1.15): icmp_seq=8 ttl=64 time=763 ms
 64 bytes from europe (10.0.1.15): icmp_seq=9 ttl=64 time=1000 ms
 64 bytes from europe (10.0.1.15): icmp_seq=10 ttl=64 time=0.438 ms
 64 bytes from europe (10.0.1.15): icmp_seq=11 ttl=64 time=1000 ms
 64 bytes from europe (10.0.1.15): icmp_seq=12 ttl=64 time=0.299 ms
 ^C
 --- europe ping statistics ---
 12 packets transmitted, 12 received, 0% packet loss, time 11085ms

those up to 1000 msec delays can be 'felt' via ssh too, if this problem 
triggers then the system is almost unusable via the network. Local 
latencies are perfect so it's an e1000 problem.

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
