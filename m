From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Sat, 21 Jul 2012 00:42:46 +0200
Message-ID: <1342824166.2626.8112.camel@edumazet-glaptop>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
	 <1342821959.2626.8052.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:52676 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751768Ab2GTWmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 18:42:52 -0400
Received: by weyx8 with SMTP id x8so2951465wey.19
        for <netdev@vger.kernel.org>; Fri, 20 Jul 2012 15:42:50 -0700 (PDT)
In-Reply-To: <1342821959.2626.8052.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-07-21 at 00:06 +0200, Eric Dumazet wrote:

> Hmm, ok, please give me few hours to make some tests ;)
> 

It seems we have a big regression somewhere with net-next,
but it is already there...

(Apparently we choke on neighbour entries count.

entries = atomic_inc_return(&tbl->entries) - 1;

We need a percpu_counter ? Or something is wrong ?

We also choke on write_lock_bh(&tbl->lock); (__write_lock_failed())
 in __neigh_create()

current 'linux' tree :

tbench 24 -t 60

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX    8433514     0.023     1.566
 Close        6195255     0.023     1.450
 Rename        357080     0.022     1.457
 Unlink       1702925     0.023     1.409
 Deltree          240     0.000     0.001
 Mkdir            120     0.024     0.032
 Qpathinfo    7643560     0.023     1.565
 Qfileinfo    1340393     0.023     1.566
 Qfsinfo      1401593     0.023     1.425
 Sfileinfo     686932     0.023     0.237
 Find         2955412     0.023     1.566
 WriteX       4209695     0.043     1.468
 ReadX        13218668     0.029     1.614
 LockX          27458     0.024     0.059
 UnlockX        27458     0.024     0.056
 Flush         591126     0.023     0.317

Throughput 4418.83 MB/sec  24 clients  24 procs  max_latency=2.433 ms

net-next tree with your 16 patches :

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX    6545220     0.031    14.433
 Close        4808070     0.031    14.105
 Rename        277171     0.030     0.737
 Unlink       1321711     0.031     2.370
 Deltree          172     0.000     0.001
 Mkdir             86     0.033     0.134
 Qpathinfo    5932577     0.031    11.607
 Qfileinfo    1039922     0.031     6.075
 Qfsinfo      1087803     0.031    12.178
 Sfileinfo     533226     0.031     0.993
 Find         2293696     0.031    11.059
 WriteX       3264634     0.054    19.164
 ReadX        10260208     0.038    11.857
 LockX          21319     0.032     0.168
 UnlockX        21319     0.032     0.162
 Flush         458724     0.032     1.774

Throughput 3425.42 MB/sec  24 clients  24 procs  max_latency=19.174 ms



perf output for linux tree :

Samples: 6M of event 'cycles', Event count (approx.): 4966119889380                                                                                            
  4,18%           tbench  tbench                             [.] 0x0000000000001f49
  4,09%           tbench  libc-2.15.so                       [.] 0x000000000003cb08
  3,10%       tbench_srv  [kernel.kallsyms]                  [k] copy_user_generic_string
  2,05%       tbench_srv  [kernel.kallsyms]                  [k] ipt_do_table
  2,04%           tbench  [kernel.kallsyms]                  [k] ipt_do_table
  1,48%           tbench  [kernel.kallsyms]                  [k] copy_user_generic_string
  1,43%       tbench_srv  [kernel.kallsyms]                  [k] tcp_ack
  1,08%       tbench_srv  [kernel.kallsyms]                  [k] tcp_recvmsg
  1,06%           tbench  [kernel.kallsyms]                  [k] nf_iterate
  1,00%       tbench_srv  [kernel.kallsyms]                  [k] nf_iterate
  0,94%       tbench_srv  [nf_conntrack]                     [k] tcp_packet
  0,94%           tbench  [nf_conntrack]                     [k] tcp_packet
  0,90%       tbench_srv  [kernel.kallsyms]                  [k] __schedule
  0,87%           tbench  [kernel.kallsyms]                  [k] __schedule
  0,87%       tbench_srv  [kernel.kallsyms]                  [k] _raw_spin_lock_bh
  0,85%       tbench_srv  [kernel.kallsyms]                  [k] tcp_sendmsg
  0,80%           tbench  [kernel.kallsyms]                  [k] __switch_to
  0,79%           tbench  [kernel.kallsyms]                  [k] _raw_spin_lock_bh
  0,77%           tbench  libc-2.15.so                       [.] vfprintf
  0,76%           tbench  [kernel.kallsyms]                  [k] tcp_sendmsg
  0,74%           tbench  [kernel.kallsyms]                  [k] select_task_rq_fair
  0,72%       tbench_srv  tbench_srv                         [.] 0x0000000000001840
  0,70%       tbench_srv  libc-2.15.so                       [.] recv
  0,65%       tbench_srv  [kernel.kallsyms]                  [k] tcp_rcv_established
  0,65%           tbench  [kernel.kallsyms]                  [k] tcp_transmit_skb
  0,64%           tbench  [vdso]                             [.] 0x00007fffd93459e8
  0,63%       tbench_srv  [kernel.kallsyms]                  [k] tcp_transmit_skb
  0,63%           tbench  [kernel.kallsyms]                  [k] tcp_recvmsg
  0,55%       tbench_srv  [nf_conntrack]                     [k] nf_conntrack_in

perf for net-next tree :

Samples: 6M of event 'cycles', Event count (approx.): 4685309724658                                                                                            
  3,42%           tbench  tbench                         [.] 0x00000000000035ab
  3,32%           tbench  libc-2.15.so                   [.] 0x00000000000913f0
  2,52%       tbench_srv  [kernel.kallsyms]              [k] copy_user_generic_string
  1,75%           tbench  [kernel.kallsyms]              [k] ipt_do_table
  1,71%       tbench_srv  [kernel.kallsyms]              [k] ipt_do_table
  1,31%           tbench  [kernel.kallsyms]              [k] __neigh_create
  1,25%       tbench_srv  [kernel.kallsyms]              [k] __neigh_create
  1,23%           tbench  [kernel.kallsyms]              [k] nf_iterate
  1,19%           tbench  [kernel.kallsyms]              [k] copy_user_generic_string
  1,19%       tbench_srv  [kernel.kallsyms]              [k] nf_iterate
  1,02%       tbench_srv  [kernel.kallsyms]              [k] tcp_ack
  0,96%       tbench_srv  [kernel.kallsyms]              [k] tcp_recvmsg
  0,88%       tbench_srv  [kernel.kallsyms]              [k] __write_lock_failed
  0,88%           tbench  [kernel.kallsyms]              [k] __write_lock_failed
  0,82%           tbench  [kernel.kallsyms]              [k] __schedule
  0,77%       tbench_srv  [kernel.kallsyms]              [k] tcp_sendmsg
  0,76%       tbench_srv  [kernel.kallsyms]              [k] __schedule
  0,76%           tbench  [nf_conntrack]                 [k] tcp_packet
  0,74%       tbench_srv  [nf_conntrack]                 [k] tcp_packet
  0,74%           tbench  [kernel.kallsyms]              [k] __switch_to
  0,71%       tbench_srv  [kernel.kallsyms]              [k] _raw_spin_lock_bh
  0,68%           tbench  [kernel.kallsyms]              [k] tcp_sendmsg
  0,66%           tbench  [kernel.kallsyms]              [k] _raw_spin_lock_bh
  0,63%           tbench  [kernel.kallsyms]              [k] ip_finish_output
  0,63%           tbench  [kernel.kallsyms]              [k] tcp_recvmsg
  0,61%       tbench_srv  [kernel.kallsyms]              [k] ip_finish_output
  0,61%           tbench  [vdso]                         [.] 0x00007fffb57ff8d1
  0,60%       tbench_srv  libc-2.15.so                   [.] recv
  0,59%           tbench  [kernel.kallsyms]              [k] neigh_destroy
