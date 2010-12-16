From: Steven Rostedt <srostedt@redhat.com>
Subject: Re: Possible regression: Packet drops during iptables calls
Date: Thu, 16 Dec 2010 09:20:44 -0500
Message-ID: <1292509244.2733.224.camel@fedora>
References: <1292337974.9155.68.camel@firesoul.comx.local>
	 <1292340702.5934.5.camel@edumazet-laptop>
	 <1292342958.9155.91.camel@firesoul.comx.local>
	 <1292343855.5934.27.camel@edumazet-laptop>
	 <1292508266.31289.12.camel@firesoul.comx.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arnaldo Carvalho de Melo <acme@infradead.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netfilter-devel <netfilter-devel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1292508266.31289.12.camel@firesoul.comx.local>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2010-12-16 at 15:04 +0100, Jesper Dangaard Brouer wrote:

> 
> To do some further investigation into the unfortunate behavior of the
> iptables get_counters() function I started to use "ftrace".  This is a
> really useful tool (thanks Steven Rostedt).
> 
>  # Select the tracer "function_graph"
>  echo function_graph > /sys/kernel/debug/tracing/current_tracer
> 
>  # Limit the number of function we look at:
>  echo local_bh_\*  >   /sys/kernel/debug/tracing/set_ftrace_filter
>  echo get_counters >>  /sys/kernel/debug/tracing/set_ftrace_filter
> 
>  # Enable tracing while calling iptables
>  cd /sys/kernel/debug/tracing
>  echo 0 > trace
>  echo 1 > tracing_enabled;
>    taskset 1 iptables -vnL > /dev/null ;
>  echo 0 > tracing_enabled
>  cat trace | less

Just an fyi, you can do the above much easier with trace-cmd:

git://git.kernel.org/pub/scm/linux/kernel/git/rostedt/trace-cmd.git

# trace-cmd record -p function_graph -l 'local_bh_*' -l get_counters taskset 1 iptables -vnL > /dev/null
# trace-cmd report

-- Steve

> 
> 
> The reduced output:
> 
> # tracer: function_graph
> #
> # CPU  DURATION                  FUNCTION CALLS
> # |     |   |                     |   |   |   |
>   2)   2.772 us    |  local_bh_disable();
> ....
>   0)   0.228 us    |  local_bh_enable();
>   0)               |  get_counters() {
>   0)   0.232 us    |    local_bh_disable();
>   0)   7.919 us    |    local_bh_enable();
>   0) ! 109467.1 us |  }
>   0)   2.344 us    |  local_bh_disable();
> 
> 
> The output show that we spend no less that 100 ms with local BH
> disabled.  So, no wonder that this causes packet drops in the NIC
> (attached to this CPU).
> 
> My iptables rule set in question is also very large, it contains:
>  Chains: 20929
>  Rules: 81239
> 
> The vmalloc size is approx 19 MB (19.820.544 bytes) (see
> /proc/vmallocinfo).  Looking through vmallocinfo I realized that
> even-though I only have 16 CPUs, there is 32 allocated rulesets
> "xt_alloc_table_info" (for the filter table). Thus, I have approx
> 634MB iptables filter rules in the kernel, half of which is totally
> unused.
> 
> Guess this is because we use: "for_each_possible_cpu" instead of
> "for_each_online_cpu". (Feel free to fix this, or point me to some
> documentation of this CPU hotplug stuff... I see we are missing
> get_cpu() and put_cpu() a lot of places).
> 
> 
> The GOOD NEWS, is that moving the local BH disable section into the
> "for_each_possible_cpu" fixed the problem with packet drops during
> iptables calls.
> 
> I wanted to profile with ftrace on the new code, but I cannot get the
> measurement I want. Perhaps Steven or Acme can help?
> 
> Now I want to measure the time used between the local_bh_disable() and
> local_bh_enable, within the loop.  I cannot figure out howto do that?
> The new trace looks almost the same as before, just a lot of
> local_bh_* inside the get_counters() function call.
> 
>  Guess is that the time spend is: 100 ms / 32 = 3.125 ms.
> 
> Now I just need to calculate, how large a NIC buffer I need to buffer
> 3.125 ms at 1Gbit/s.
> 
>  3.125 ms *  1Gbit/s = 390625 bytes
> 
> Can this be correct?
> 
> How much buffer does each queue have in the 82576 NIC?
> (Hope Alexander Duyck can answer this one?)
> 


