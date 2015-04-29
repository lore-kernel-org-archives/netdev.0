From: Ben Greear <greearb@candelatech.com>
Subject: Bad performance on modified pktgen in 4.0 vs 3.17 kernel.
Date: Wed, 29 Apr 2015 16:39:22 -0700
Message-ID: <55416BAA.8010504@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.candelatech.com ([208.74.158.173]:55578 "EHLO
	mail2.candelatech.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbbD2XjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2015 19:39:23 -0400
Received: from [192.168.100.236] (unknown [50.251.239.81])
	(using TLSv1 with cipher DHE-RSA-CAMELLIA256-SHA (256/256 bits))
	(No client certificate requested)
	by mail2.candelatech.com (Postfix) with ESMTPSA id 040A940B7F0
	for <netdev@vger.kernel.org>; Wed, 29 Apr 2015 16:39:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We run a hacked version of pktgen, it has some pkt-rx logic, and probably spends more time
grabbing timestamps than stock code.  It also should not be doing any busy-spins for sleeping.

You can see pktgen changes, supporting patches, and various other stuff here:

http://dmz2.candelatech.com/git/gitweb.cgi?p=linux-4.0.dev.y/.git;a=summary
git clone git://dmz2.candelatech.com/linux-4.0.dev.y


On a 64-bit atom system, with e1000 driver, we see around 50% cpu usage
when running 40,000 pkts per second on two interfaces on the 3.17.8+ kernel.

# cat perf-top-3-17.txt
   PerfTop:    3682 irqs/sec  kernel:78.7%  exact:  0.0% [4000Hz cycles],  (all, 4 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

     3.43%  [kernel]       [k] pktgen_thread_worker
     2.47%  libc-2.20.so   [.] __strstr_sse2
     2.31%  [kernel]       [k] e1000_xmit_frame
     2.25%  [kernel]       [k] number.isra.1
     2.18%  [kernel]       [k] vsnprintf
     1.96%  libc-2.20.so   [.] __GI___strcmp_ssse3
     1.84%  [kernel]       [k] format_decode
     1.80%  [kernel]       [k] build_skb
     1.79%  [kernel]       [k] kallsyms_expand_symbol.constprop.1
     1.76%  [kernel]       [k] native_read_tsc
     1.74%  perf           [.] rb_next
     1.57%  [kernel]       [k] getRelativeCurNs
     1.48%  perf           [.] symbols__insert
     1.10%  perf           [.] hex2u64
     1.07%  [kernel]       [k] e1000_irq_enable
     1.06%  [kernel]       [k] timekeeping_get_ns
     1.03%  [kernel]       [k] e1000_clean_rx_irq
     1.00%  [kernel]       [k] __getnstimeofday64
     0.97%  [kernel]       [k] string.isra.6
     0.97%  [kernel]       [k] do_raw_spin_lock
     0.97%  [kernel]       [k] kmem_cache_alloc
     0.94%  [kernel]       [k] e1000_intr_msi


On 4.0, there is significantly more CPU usage.  I tried copying the pktgen.c from 3.17 to 4.0
and that did not have any noticeable affect, so I think it must be something outside of my changes.

# cat perf-top-40.txt
   PerfTop:    4566 irqs/sec  kernel:87.4%  exact:  0.0% [4000Hz cycles],  (all, 4 CPUs)
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

    20.72%  [kernel]       [k] mwait_idle_with_hints.constprop.2
    10.98%  [kernel]       [k] __lock_acquire
     3.30%  [kernel]       [k] pktgen_thread_worker
     2.41%  [kernel]       [k] arch_local_save_flags
     2.25%  [kernel]       [k] e1000_xmit_frame
     1.83%  [kernel]       [k] lock_release
     1.57%  [kernel]       [k] lock_acquire
     1.54%  [kernel]       [k] trace_hardirqs_on_caller
     1.50%  libc-2.20.so   [.] __strstr_sse2
     1.41%  [kernel]       [k] number.isra.1
     1.22%  [kernel]       [k] trace_hardirqs_off_caller
     1.20%  [kernel]       [k] kallsyms_expand_symbol.constprop.1
     1.19%  [kernel]       [k] build_skb
     1.18%  [kernel]       [k] format_decode
     1.17%  [kernel]       [k] hlock_class
     1.17%  [kernel]       [k] arch_local_irq_restore
     1.09%  [kernel]       [k] vsnprintf
     1.00%  [kernel]       [k] arch_local_irq_save
     0.97%  libc-2.20.so   [.] __GI___strcmp_ssse3
     0.97%  [kernel]       [k] mark_held_locks
     0.89%  [kernel]       [k] mark_lock


We see similar jump in CPU usage in the 4.0 kernel when using the 40G Intel NIC/driver
on an E5 system, so it is probably not just something to do with the driver.

Due to hooks in the pkt rx logic (and changes to the stock kernel code in that area between
3.17 and 4.), this will not be trivial to do an automated bisect, so I'm hoping to not
have to do that...

I'm curious if anyone has seen any similar performance degradation, and whether there
are any ideas what might be the problem.

Thanks,
Ben



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
