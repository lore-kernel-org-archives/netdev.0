From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Thu, 19 Jun 2008 00:05:27 +0200
Message-ID: <20080618220527.GA19155@elte.hu>
References: <20080617083220.GA11393@elte.hu> <20080618200805.GA18756@elte.hu>
	<20080618213230.GA17821@elte.hu>
	<200806190041.52532.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, "Kok, Auke" <auke-jan.h.kok@intel.com>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, rjw@sisk.pl, mcmanus@ducksong.com,
	ilpo.jarvinen@helsinki.fi, kuznet@ms2.inr.ac.ru,
	Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, xemul@openvz.org
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <200806190041.52532.denys@visp.net.lb>
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


* Denys Fedoryshchenko <denys@visp.net.lb> wrote:

> > * Ingo Molnar <mingo@elte.hu> wrote:
> > with e1000e i get:
> > 
> >  64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=0.212 ms
> >  64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=0.372 ms
> >  64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=0.815 ms
> >  64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=0.961 ms
> >  64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=0.201 ms
> >  64 bytes from europe (10.0.1.15): icmp_seq=6 ttl=64 time=0.788 ms
> > 
> > TCP latencies are fine too - ssh feels snappy again.
> > 
> > it still does not have nearly as good latencies as say forcedeth though:
> > 
> >  64 bytes from mercury (10.0.1.13): icmp_seq=1 ttl=64 time=0.076 ms
> >  64 bytes from mercury (10.0.1.13): icmp_seq=2 ttl=64 time=0.085 ms
> >  64 bytes from mercury (10.0.1.13): icmp_seq=3 ttl=64 time=0.045 ms
> >  64 bytes from mercury (10.0.1.13): icmp_seq=4 ttl=64 time=0.053 ms
> > 
> > that's 10 times better packet latencies.
> > 
> > and even an ancient Realtek RTL-8139 over 10 megabit Ethernet (!) has 
> > better latencies than the e1000e over 1000 megabit:
> > 
> >  64 bytes from pluto (10.0.1.10): icmp_seq=2 ttl=64 time=0.309 ms
> >  64 bytes from pluto (10.0.1.10): icmp_seq=3 ttl=64 time=0.333 ms
> >  64 bytes from pluto (10.0.1.10): icmp_seq=4 ttl=64 time=0.329 ms
> >  64 bytes from pluto (10.0.1.10): icmp_seq=5 ttl=64 time=0.311 ms
> >  64 bytes from pluto (10.0.1.10): icmp_seq=6 ttl=64 time=0.302 ms
> > 
> > is it done intentionally perhaps? I dont think it makes much sense to 
> > delay rx/tx processing on a completely idle box for such a long time.
> Idle box, ICH8 chipset, e1000e, latest git.
> 
> MegaRouterCore-KARAM ~ # ping 192.168.20.26
> PING 192.168.20.26 (192.168.20.26) 56(84) bytes of data.
> 64 bytes from 192.168.20.26: icmp_seq=1 ttl=64 time=0.109 ms
> 64 bytes from 192.168.20.26: icmp_seq=2 ttl=64 time=0.134 ms
> 64 bytes from 192.168.20.26: icmp_seq=3 ttl=64 time=0.120 ms
> 64 bytes from 192.168.20.26: icmp_seq=4 ttl=64 time=0.117 ms
> 64 bytes from 192.168.20.26: icmp_seq=5 ttl=64 time=0.117 ms
> 64 bytes from 192.168.20.26: icmp_seq=6 ttl=64 time=0.113 ms

ok, that looks much better! i have another box with e1000, ich7:

64 bytes from titan (10.0.1.14): icmp_seq=5 ttl=64 time=0.345 ms
64 bytes from titan (10.0.1.14): icmp_seq=6 ttl=64 time=1.03 ms
64 bytes from titan (10.0.1.14): icmp_seq=7 ttl=64 time=0.383 ms
64 bytes from titan (10.0.1.14): icmp_seq=8 ttl=64 time=0.320 ms
64 bytes from titan (10.0.1.14): icmp_seq=9 ttl=64 time=0.996 ms
64 bytes from titan (10.0.1.14): icmp_seq=10 ttl=64 time=0.248 ms

> Disabling interrupt moderation
> MegaRouterCore-KARAM ~ # ethtool -C eth0 rx-usecs 0
> MegaRouterCore-KARAM ~ # ping 192.168.20.26
> PING 192.168.20.26 (192.168.20.26) 56(84) bytes of data.
> 64 bytes from 192.168.20.26: icmp_seq=1 ttl=64 time=0.072 ms
> 64 bytes from 192.168.20.26: icmp_seq=2 ttl=64 time=0.091 ms
> 64 bytes from 192.168.20.26: icmp_seq=3 ttl=64 time=0.066 ms
> 64 bytes from 192.168.20.26: icmp_seq=4 ttl=64 time=0.065 ms
> 64 bytes from 192.168.20.26: icmp_seq=5 ttl=64 time=0.077 ms
> 64 bytes from 192.168.20.26: icmp_seq=6 ttl=64 time=0.073 ms
> 
> Maybe try the same?
> ethtool -C eth0 rx-usecs 0

well i tend not to tweak my drivers with such options because i want to 
experience and test what 99.9% of our users will experience in the 
field. The reality is that if it's not the default behavior, it's almost 
as if it didnt exist at all.

but even with that tune on e1000e (on the t60, ich7) i still get rather 
large numbers:

earth4:~/s> ping eu
PING europe (10.0.1.15) 56(84) bytes of data.
64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=0.250 ms
64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=0.250 ms
64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=0.225 ms
64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=0.932 ms
64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=0.251 ms
64 bytes from europe (10.0.1.15): icmp_seq=6 ttl=64 time=0.915 ms
64 bytes from europe (10.0.1.15): icmp_seq=7 ttl=64 time=0.250 ms
64 bytes from europe (10.0.1.15): icmp_seq=8 ttl=64 time=0.238 ms
64 bytes from europe (10.0.1.15): icmp_seq=9 ttl=64 time=0.390 ms
64 bytes from europe (10.0.1.15): icmp_seq=10 ttl=64 time=0.260 ms

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
