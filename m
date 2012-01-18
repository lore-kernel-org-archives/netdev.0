From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Interpreting perf stat on netperf and netserver
Date: Wed, 18 Jan 2012 09:49:29 -0800
Message-ID: <4F170629.8090307@hp.com>
References: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jean-Michel Hautbois <jhautbois@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:41402 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932322Ab2ARRtb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2012 12:49:31 -0500
In-Reply-To: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2012 03:33 AM, Jean-Michel Hautbois wrote:
> Hi all,
>
> I am currently using netperf/netserver in order to characterize a
> benet emulex network device on a machine with 2 Xeon5670.
> I am using the latest linux kernel from git (3.2.0+).
> I am facing several issues, and I am trying to understand the
> following perf stat launched on netserver :
>
>   Performance counter stats for process id '5043':

If you aren't already you may want to gather system-wide data as well - 
not everything networking is guaranteed to run in the netserver's (or 
netperf's) context.

Might also be good to include the netperf command line driving that 
netserver.  That will help folks know if the netserver is receiving data 
(_STREAM), sending data (_MAERTS) or both (_RR) (though perhaps that can 
be gleaned from the routine names in the profile.

>
>        15452.992135 task-clock                #    0.450 CPUs utilized
>              189678 context-switches          #    0.012 M/sec
>                   5 CPU-migrations            #    0.000 M/sec
>                 275 page-faults               #    0.000 M/sec
>         48490467936 cycles                    #    3.138 GHz
>         33005879963 stalled-cycles-frontend   #   68.07% frontend cycles idle
>         16325855769 stalled-cycles-backend    #   33.67% backend  cycles idle
>         27340520316 instructions              #    0.56  insns per cycle
>                                               #    1.21  stalled cycles per insn
>          4745604818 branches                  #  307.099 M/sec
>            67513124 branch-misses             #    1.42% of all branches
>
>        34.303567279 seconds time elapsed
>
> I am trying to understand the "stalled-cycles-frontend" and
> "stalled-cycles-backend" lines.
> It seems that frontend is high, and in red :) but I can't say why...

Perhaps the stalls are for cache misses - at least cache misses are a 
common reason for stalls.  I believe that perf has a way to be more 
specific about the PMU events of interest.

>
> The be2net driver seems to have difficulties woth IRQ affinity also,
> because it always uses CPU0 even if the affinity is 0-23 !
> netperf result is quite good, and perf top shows :
>     PerfTop:     689 irqs/sec  kernel:99.6% us: 0.3% guest kernel: 0.0%
> guest us: 0.0% exact:  0.0% [1000Hz cycles],  (all, 24 CPUs)
> ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
>
>      29.28%  [kernel]          [k] csum_partial
>       8.46%  [kernel]          [k] copy_user_generic_string
>       3.70%  [be2net]          [k] be_poll_rx
>       3.08%  [be2net]          [k] event_handle
>       2.37%  [kernel]          [k] irq_entries_start
>       2.21%  [be2net]          [k] be_rx_compl_get
>       1.65%  [be2net]          [k] be_post_rx_frags
>       1.64%  [kernel]          [k] __napi_complete
>       1.50%  [kernel]          [k] ip_defrag
>       1.35%  [kernel]          [k] put_page
>       1.34%  [kernel]          [k] get_page_from_freelist
>       1.29%  [kernel]          [k] __netif_receive_skb
>       1.16%  [kernel]          [k] __alloc_pages_nodemask
>       1.14%  [kernel]          [k] debug_smp_processor_id
>       1.08%  [kernel]          [k] add_preempt_count
>       1.06%  [kernel]          [k] sub_preempt_count
>       1.03%  [be2net]          [k] get_rx_page_info
>       1.01%  [kernel]          [k] alloc_pages_current
>
> Checksum calculation seems quite complex :).
> Regards,
> JM
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
