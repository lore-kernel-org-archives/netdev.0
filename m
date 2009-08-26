From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Receive side performance issue with multi-10-GigE and NUMA
Date: Wed, 26 Aug 2009 22:28:27 +0200
Message-ID: <20090826202827.GA17451@elte.hu>
References: <20090826181502.GC13632@elte.hu> <20090826190435.GC10816@hmsreliant.think-freely.org> <20090826190830.GF13632@elte.hu> <20090826.123631.79533250.davem@davemloft.net> <20090826194835.GA16508@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nhorman@tuxdriver.com, rostedt@goodmis.org, fweisbec@gmail.com,
	billfink@mindspring.com, netdev@vger.kernel.org, brice@myri.com,
	gallatin@myri.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:45969 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752953AbZHZU2t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2009 16:28:49 -0400
Content-Disposition: inline
In-Reply-To: <20090826194835.GA16508@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> * David Miller <davem@davemloft.net> wrote:
> 
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Wed, 26 Aug 2009 21:08:30 +0200
> > 
> > > Sigh, no. Please re-read the past discussions about this. 
> > > trace_skb_sources.c is a hack and should be converted to generic 
> > > tracepoints. Is there anything in it that cannot be expressed in 
> > > terms of TRACE_EVENT()?
> > 
> > Neil explained why he needed to implement it this way in his reply 
> > to Steven Rostedt.  I attach it here for your convenience.
> 
> thanks. The argument is invalid:
> 
> > > BTW, why not just do this as events? Or was this just a easy way 
> > > to communicate with the user space tools?
> > 
> > Thats exactly why I did it.  the idea is for me to now write a 
> > user space tool that lets me analyze the events and ajust process 
> > scheduling to optimize the rx path. Neil
> 
> All tooling (in fact _more_ tooling) can be done based on generic, 
> TRACE_EVENT() based tracepoints. Generic tracepoints are far more 
> available, have a generalized format with format parsers and user 
> tooling implemented, etc. etc.

To expand on the 'etc. etc.'.

Right now we already have once TRACE_EVENT() based generic 
tracepoint for skbs - the skb_free one in 
include/trace/events/skb.h.

Here's a list of examples of what that single generic tracepoint 
allows us to do, which Neil's kernel/trace/trace_skb_sources.c code 
cannot do:

 - structured format/field description:

  aldebaran:~> cat /debug/tracing/events/skb/kfree_skb/format 

 name: kfree_skb
 ID: 603
 format:
	field:unsigned short common_type;	offset:0;	size:2;
	field:unsigned char common_flags;	offset:2;	size:1;
	field:unsigned char common_preempt_count;	offset:3;	size:1;
	field:int common_pid;	offset:4;	size:4;
	field:int common_tgid;	offset:8;	size:4;

	field:void * skbaddr;	offset:16;	size:8;
	field:unsigned short protocol;	offset:24;	size:2;
	field:void * location;	offset:32;	size:8;

 print fmt: "skbaddr=%p protocol=%u location=%p", REC->skbaddr, REC->protocol, REC->location

  The advantages of that are numerous: we have a user-space parser
  for that, so new tracepoints or changes to tracepoints can be 
  propagated across the tooling automatically. (see below examples 
  about how this works in practice)

 - perfcounters integration:

    - it's enumerated and visible in the list of tracepoints:

        aldebaran:~> perf list 2>&1 | grep skb
        skb:kfree_skb                              [Tracepoint event]

    - the tracepoint can be used for statistics (perf stat):

        aldebaran:~> perf stat -e skb:kfree_skb -a sleep 1

        Performance counter stats for 'sleep 1':

    - noise analysis:

        aldebaran:~> perf stat --repeat 10 -e skb:kfree_skb -a sleep 1

        Performance counter stats for 'sleep 1' (10 runs):

             25  skb:kfree_skb              ( +-   7.692% )

    - the tracepoint can be used for profiling:

        aldebaran:~> perf top -e skb:kfree_skb -c 1

  ------------------------------------------------------------------------------
   PerfTop:     334 irqs/sec  kernel: 0.3% [1 skb:kfree_skb],  (all, 16 CPUs)
  ------------------------------------------------------------------------------
             samples    pcnt         RIP          kernel function
  ______     _______   _____   ________________   _______________
 
               23.00 - 100.0% - ffffffff81266828 : store_bind

    - can be used to do call-graph profiling that captures kernel 
      and user-space call-graphs as well:

     aldebaran:~> perf record --call-graph -e skb:kfree_skb -c 1 -f -a sleep 1
     [ perf record: Captured and wrote 0.035 MB perf.data (~1547 samples) ]

     aldebaran:~> perf report
     ...

# Samples: 4102
#
# Overhead          Command                                                                                             Shared Object  Symbol
# ........  ...............  ........................................................................................................  ......
#
    88.44%          distccd                                                                                                3641efb1d0  [.] 0x00003641efb1d0

     3.07%             Xorg                                                                                                3641ed6590  [.] 0x00003641ed6590

     2.51%  at-spi-registry                                                                                                3642a0db50  [.] 0x00003642a0db50

     2.24%             sshd  /lib64/libc-2.8.so                                                                                        [.] __libc_read

     0.73%             sshd                                                                                              7f71d4e69590  [.] 0x007f71d4e69590

     0.63%             init  [kernel]                                                                                                  [k] store_bind
     0.56%             sshd  /lib64/libc-2.8.so                                                                                        [.] __recvmsg

     0.49%  gnome-settings-                                                                                                3642a0db8b  [.] 0x00003642a0db8b

     0.39%             sshd  /lib64/libc-2.8.so                                                                                        [.] __GI___libc_connect

     0.39%             sshd  /lib64/libc-2.8.so                                                                                        [.] __sendto_nocancel

     0.15%               id  /lib64/libc-2.8.so                                                                                        [.] __GI___libc_connect
                |          
                |--50.00%-- get_mapping
                |          __nscd_get_map_ref
                |          
                 --50.00%-- __nscd_open_socket

     0.10%         metacity                                                                                                3641ed6590  [.] 0x00003641ed6590

     0.07%  gdm-simple-gree                                                                                                3642a0db8b  [.] 0x00003642a0db8b
                |          
                |--66.67%-- 0x3641ed65cb
                |          
                 --33.33%-- 0x3642a0db8b

     0.05%             bash  /lib64/libc-2.8.so                                                                                        [.] __GI___libc_connect
                |          
                |--50.00%-- get_mapping
                |          __nscd_get_map_ref
                |          
                 --50.00%-- __nscd_open_socket

     0.05%            :3129  /lib64/libc-2.8.so                                                                                        [.] __GI___libc_connect
                |          
                |--50.00%-- get_mapping
                |          __nscd_get_map_ref
                |          
                 --50.00%-- __nscd_open_socket

     0.05%            :3098  /lib64/libc-2.8.so                                                                                        [.] __GI___libc_connect
                |          
                |--50.00%-- get_mapping
                |          __nscd_get_map_ref
                |          
                 --50.00%-- __nscd_open_socket

     0.02%             init  [kernel]                                                                                                  [k] bind_con_driver
     0.02%  gnome-power-man                                                                                                3642a0db50  [.] 0x00003642a0db50

     0.02%              cc1  /opt/crosstool/gcc-4.2.2-glibc-2.3.6/i686-unknown-linux-gnu/libexec/gcc/i686-unknown-linux-gnu/4.2.2/cc1  [.] num_positive

   - can be used to capture traces to user-space and analyze them 
     there:

     aldebaran:/home/mingo> perf record -e skb:kfree_skb:r -c 1 -R -f -a sleep 10
     [ perf record: Captured and wrote 4.426 MB perf.data (~193365 samples) ]

     aldebaran:/home/mingo> perf trace
     version = 0.5B6
            init-0     [000]     0.000000: kfree_skb: skbaddr=0xffff8801bcc15300 protocol=2048 location=0xffffffff81461c94
            Xorg-4411  [000]     0.000000: kfree_skb: skbaddr=0xffff8801bb955a00 protocol=0 location=0xffffffff814e8aff
 at-spi-registry-4948  [000]     0.000000: kfree_skb: skbaddr=0xffff8801bb955a00 protocol=0 location=0xffffffff814e8aff
     ...

 - generic tracepoints can be available with lots of other 
   tracepoints at once - while the skb_sources plugin is exclusive.
   (no other plugin can be active at the same time) Generic 
   tracepoints have separate toggles - any sub-set of tracepoints 
   can be active at any time.

 - per tracepoint filter expressions support, such as:

    aldebaran:/debug/tracing/events/skb/kfree_skb> echo 'protocol == 0 && common_pid == 123' > filter 
    aldebaran:/debug/tracing/events/skb/kfree_skb> cat filter protocol == 0 && common_pid == 123
    protocol == 0 && common_pid == 123

   When this filter is modified, the kernel creates a (safe) list of
   (atomically evaluatable) predicaments from the expression and the
   data is filtered before it's traced.

   The filter engine works in process, softirq, IRQ, NMI and any
   other context and is very fast as well. (no parsing overhead in 
   the fastpath - we pre-parse the expression and break it down.)

In other words, generic tracepoints are _vastly_ superior to the 
skb_sources plugin, and this fact is obvious to all tracing 
developers, that's why every tracing developer who commented on this 
thread asked (in a rather befuddled way) "why not TRACE_EVENT()?".

And note that the above examples were based on a _single_ existing 
generic tracepoint of very limited utility - and still it already 
allowed a lot of interesting data to be captured. If we had a more 
comprehensive set of skb tracepoints, a whole lot of interesting 
possibilities would open up ...

All in one, we dont do new ftrace plugins that can be done via 
generic tracepoints - we only limit ftrace plugins to vastly 
different things like the function tracer or the latency tracer.

That's why we have things like a tracing tree and a review process, 
to address such issues before patches get committed.

David, please sort this out before sending any bits in this area to 
Linus, Neil's response is basically "i want it this way" which is 
not really acceptable - the maintainers of kernel/trace/* dont want 
it this way, for very good technical reasons.

The skb_sources hack should be converted to a proper 
TRACE_EVENT(skb_dequeue) tracepoint. Also, as we offered it on the 
onset, we'd be glad to help out with the conversion. I can do a 
patch if nobody volunteers.

Plus we'd like to encourage more TRACE_EVENT() networking 
tracepoints like the existing skb_free. They are a great tool.

	Ingo
