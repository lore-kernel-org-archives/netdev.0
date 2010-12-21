From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: Re: [PATCH v4 net-next-2.6] netfilter: x_tables: dont block BH
 while reading counters
Date: Tue, 21 Dec 2010 17:48:50 +0100
Message-ID: <1292950130.31289.85.camel@firesoul.comx.local>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
	 <1292508733.2883.152.camel@edumazet-laptop>
	 <1292509489.31289.20.camel@firesoul.comx.local>
	 <1292509775.2883.187.camel@edumazet-laptop>
	 <1292511761.2883.236.camel@edumazet-laptop>
	 <1292515625.2883.336.camel@edumazet-laptop>
	 <1292518436.2883.393.camel@edumazet-laptop>
	 <20101216093149.71f082c7@nehalam>
	 <1292521986.2883.472.camel@edumazet-laptop>
	 <1292646579.7894.42.camel@edumazet-laptop>
	 <1292852541.31289.75.camel@firesoul.comx.local>
	 <1292856346.2800.54.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292856346.2800.54.camel@edumazet-laptop>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-12-20 at 15:45 +0100, Eric Dumazet wrote:
...
> > There is no packet overruns/drops, iif I run "iptables -vnL >
> > /dev/null" without tracing enabled and only 1Gbit/s pktgen at 512
> > bytes packets.  If I enable tracing while calling iptables I see
> > packet drops/overruns.  So I guess this is caused by the tracing
> > overhead.
> 
> yes, probably :)
> 
> > 
> > I'll try to rerun my test without all the lock debugging options
> > enabled.

Results are much better without the kernel debugging options enabled.
I took the .config from production and enabled tracer "function_graph".
And applied your patches (plus vzalloc) on top of 2.6.36-stable tree.

I can now hit the system with a pktgen at 128 bytes, and see no
drops/overruns while running iptables.  (This packet load at 128bytes
is 822 kpps and 840Mbit/s) (iptables ruleset is the big chains: 20929
rules: 81239).

If I reduce the ftrace filter to only track get_counters, I can even
run a trace without any drops.

 echo get_counters >  /sys/kernel/debug/tracing/set_ftrace_filter

Some trace funny stats on get_counters(), under the packet storm.
When running iptables on a CPU not processing packets (via taskset),
the execution time is increased to 124ms.  If I force iptables to run
on a CPU processing packets, the execution time is increased to
1308ms, which is large but the expected behavior.

Acked-by: Jesper Dangaard Brouer <hawk@comx.dk>

-- 
Med venlig hilsen / Best regards
  Jesper Brouer
  ComX Networks A/S
  Linux Network Kernel Developer
  Cand. Scient Datalog / MSc.CS
  Author of http://adsl-optimizer.dk
  LinkedIn: http://www.linkedin.com/in/brouer

