From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [TCP]: TCP_DEFER_ACCEPT causes leak sockets
Date: Wed, 18 Jun 2008 23:32:30 +0200
Message-ID: <20080618213230.GA17821@elte.hu>
References: <20080617083220.GA11393@elte.hu>
	<20080617.020840.169830916.davem@davemloft.net>
	<20080617092706.GB20621@elte.hu>
	<20080617.022909.173003136.davem@davemloft.net>
	<20080617093929.GA10334@elte.hu> <48595910.8000905@intel.com>
	<20080618200805.GA18756@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: vgusev@openvz.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org, rjw@sisk.pl,
	mcmanus@ducksong.com, ilpo.jarvinen@helsinki.fi,
	kuznet@ms2.inr.ac.ru, Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>, xemul@openvz.org
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <20080618200805.GA18756@elte.hu>
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

> * Kok, Auke <auke-jan.h.kok@intel.com> wrote:
> 
> > > Any ideas about what i should try next?
> > 
> > have you tried e1000e?
> 
> will try it.

ok, i tried it now, and there's good news: the latency problem seems 
largely fixed by e1000e. (yay!)

with e1000 i got these anomalous latencies:

 64 bytes from europe (10.0.1.15): icmp_seq=10 ttl=64 time=1000 ms
 64 bytes from europe (10.0.1.15): icmp_seq=11 ttl=64 time=0.882 ms
 64 bytes from europe (10.0.1.15): icmp_seq=12 ttl=64 time=1007 ms
 64 bytes from europe (10.0.1.15): icmp_seq=13 ttl=64 time=0.522 ms
 64 bytes from europe (10.0.1.15): icmp_seq=14 ttl=64 time=1003 ms
 64 bytes from europe (10.0.1.15): icmp_seq=15 ttl=64 time=0.381 ms
 64 bytes from europe (10.0.1.15): icmp_seq=16 ttl=64 time=1010 ms

with e1000e i get:

 64 bytes from europe (10.0.1.15): icmp_seq=1 ttl=64 time=0.212 ms
 64 bytes from europe (10.0.1.15): icmp_seq=2 ttl=64 time=0.372 ms
 64 bytes from europe (10.0.1.15): icmp_seq=3 ttl=64 time=0.815 ms
 64 bytes from europe (10.0.1.15): icmp_seq=4 ttl=64 time=0.961 ms
 64 bytes from europe (10.0.1.15): icmp_seq=5 ttl=64 time=0.201 ms
 64 bytes from europe (10.0.1.15): icmp_seq=6 ttl=64 time=0.788 ms

TCP latencies are fine too - ssh feels snappy again.

it still does not have nearly as good latencies as say forcedeth though:

 64 bytes from mercury (10.0.1.13): icmp_seq=1 ttl=64 time=0.076 ms
 64 bytes from mercury (10.0.1.13): icmp_seq=2 ttl=64 time=0.085 ms
 64 bytes from mercury (10.0.1.13): icmp_seq=3 ttl=64 time=0.045 ms
 64 bytes from mercury (10.0.1.13): icmp_seq=4 ttl=64 time=0.053 ms

that's 10 times better packet latencies.

and even an ancient Realtek RTL-8139 over 10 megabit Ethernet (!) has 
better latencies than the e1000e over 1000 megabit:

 64 bytes from pluto (10.0.1.10): icmp_seq=2 ttl=64 time=0.309 ms
 64 bytes from pluto (10.0.1.10): icmp_seq=3 ttl=64 time=0.333 ms
 64 bytes from pluto (10.0.1.10): icmp_seq=4 ttl=64 time=0.329 ms
 64 bytes from pluto (10.0.1.10): icmp_seq=5 ttl=64 time=0.311 ms
 64 bytes from pluto (10.0.1.10): icmp_seq=6 ttl=64 time=0.302 ms

is it done intentionally perhaps? I dont think it makes much sense to 
delay rx/tx processing on a completely idle box for such a long time.

The options i used are:

 CONFIG_E1000=y
 CONFIG_E1000_NAPI=y
 # CONFIG_E1000_DISABLE_PACKET_SPLIT is not set
 CONFIG_E1000E=y
 CONFIG_E1000E_ENABLED=y

> But even it if solves the problem it's a nasty complication: given how 
> many times i have to bisect back into the times when there was only 
> e1000 around, how do i handle the transition? I have automated 
> bisection tools, etc. and i bisect very frequently.

one possibility would be to change 'make oldconfig' to keep old options 
around - as long as they look "unknown" to a particular kernel. It would 
list them in some special "unknown options" section near the end of the 
.config or so. That way the E1000E=y setting could survive a bisection 
run which dives down into older kernel versions. (obviously old kernels 
wont grow this capability magically, so if we do such a change we'll 
have to wait years for it all to trickle through.)

and eventually E1000E could become the default.

	Ingo

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
