From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: [PATCH 00/16] Remove the ipv4 routing cache
Date: Sun, 22 Jul 2012 00:47:27 -0700
Message-ID: <CAGK4HS_ZqH+std9Edbia7i1tdpLxpdsMD83fcTQPnNZbnX4zPA@mail.gmail.com>
References: <20120720.142502.1144557295933737451.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f174.google.com ([209.85.214.174]:56446 "EHLO
	mail-ob0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab2GVHr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Jul 2012 03:47:28 -0400
Received: by obbuo13 with SMTP id uo13so7580742obb.19
        for <netdev@vger.kernel.org>; Sun, 22 Jul 2012 00:47:27 -0700 (PDT)
In-Reply-To: <20120720.142502.1144557295933737451.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 20 July 2012 14:25, David Miller <davem@davemloft.net> wrote:
> On a SPARC-T3 output route lookups are ~876 cycles.  Input route
> lookups are ~1169 cycles with rpfilter disabled, and about ~1468
> cycles with rpfilter enabled.
>
> These measurements were taken with the kbench_mod test module in the
> net_test_tools GIT tree:
...
> In fact anyone suitable motivated can just fire up perf on the loading
> of the test net_test_tools benchmark kernel module.  I spend much of
> my time going:
>
> bash# perf record insmod ./kbench_mod.ko dst=172.30.42.22 src=74.128.0.1 iif=2
> bash# perf report
>

Dave,
I have been running your routing removal patches for the past 3 days
(upgraded yesterday to latest set including the 17th patch you sent in
response to Eric's comment) and have not seen any issues (crashes
etc).

I used the kbench_mod module in net_test_tools for testing. Averaging
after 16 runs (with 4 samples in each run), I get the following for
output route lookups
(ip_route_output_key):

with route-removal patches:   average of 544 cycles with min and max
of 511 and 721
without patches: (commit fa0afcd10 ) :    average of 211 cycles with
min and max of 196 and 266

Apart from time spent in fib_table_lookup(), it seems time is also
spent in check_leaf(). I assume this is expected behavior.
Here are 2 sample perf outputs (I have appended the kbench outputs to
each file)

With patches applied:
# ========
# captured on: Sat Jul 21 23:49:43 2012
# hostname : vijaynsu
# os release : 3.5.0-rc7vns+
# perf version : 3.4.13690.gfda9f
# arch : x86_64
# nrcpus online : 8
# nrcpus avail : 8
# cpudesc : Intel(R) Xeon(R) CPU E5320 @ 1.86GHz
# cpuid : GenuineIntel,6,15,11
# total memory : 16407032 kB
# cmdline : /usr/src/net-next/tools/perf/perf record insmod
./kbench_mod.ko dst=172.27.231.128 src=172.27.231.28
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0,
config2 = 0x0, excl_usr = 0, excl_kern = 0, id = { 1, 2, 3, 4, 5, 6,
7, 8 }
# HEADER_CPU_TOPOLOGY info available, use -I to display
# ========
#
# Samples: 458  of event 'cycles'
# Event count (approx.): 209175177
#
# Overhead  Command      Shared Object                         Symbol
# ........  .......  .................  .............................
#
    40.62%   insmod  [kernel.kallsyms]  [k] fib_table_lookup
    24.38%   insmod  [kernel.kallsyms]  [k] __ip_route_output_key
    12.33%   insmod  [kernel.kallsyms]  [k] check_leaf
     9.29%   insmod  [kernel.kallsyms]  [k] dst_release
     6.43%   insmod  [kernel.kallsyms]  [k] __ip_dev_find
     2.67%   insmod  [edac_core]        [k] 0x000000000000c1d7
     1.33%   insmod  [kernel.kallsyms]  [k] ip_route_output_flow
     0.70%   insmod  [kernel.kallsyms]  [k] copy_user_generic_string
     0.46%   insmod  [kernel.kallsyms]  [k] path_openat
     0.41%   insmod  [kernel.kallsyms]  [k] clear_page_c
     0.38%   insmod  libc-2.11.1.so     [.] _dl_addr
     0.23%   insmod  [kernel.kallsyms]  [k] native_write_msr_safe
     0.22%   insmod  [kernel.kallsyms]  [k] rcu_irq_enter
     0.22%   insmod  [kernel.kallsyms]  [k] mem_cgroup_count_vm_event
     0.19%   insmod  [kernel.kallsyms]  [k] do_mpage_readpage
     0.12%   insmod  [kernel.kallsyms]  [k] math_state_restore
     0.02%   insmod  [kernel.kallsyms]  [k] stop_one_cpu



#
# (For a higher level overview, try: perf report --sort comm,dso)
#
Jul 21 23:49:43 vijaynsu kernel: [  146.382382] kbench:
Jul 21 23:49:43 vijaynsu kernel: [  146.382382] flow
[IIF(0),OIF(0),MARK(0x00000000),D(172.27.231.128),S(172.27.231.28),TOS(0x00)]
Jul 21 23:49:43 vijaynsu kernel: [  146.382388] kbench: sizeof(struct
rtable)==176
Jul 21 23:49:43 vijaynsu kernel: [  146.409943] kbench:
ip_route_output_key tdiff: 546
Jul 21 23:49:43 vijaynsu kernel: [  146.437490] kbench:
ip_route_output_key tdiff: 546
Jul 21 23:49:43 vijaynsu kernel: [  146.465064] kbench:
ip_route_output_key tdiff: 511
Jul 21 23:49:43 vijaynsu kernel: [  146.492615] kbench:
ip_route_output_key tdiff: 672



--------------
Without patches applied : (omitting hardware info)


# Overhead  Command      Shared Object                        Symbol
# ........  .......  .................  ............................
#
    46.47%   insmod  [kernel.kallsyms]  [k] __ip_route_output_key
    17.71%   insmod  [kernel.kallsyms]  [k] dst_release
    15.51%   insmod  [kernel.kallsyms]  [k] local_bh_enable
     5.92%   insmod  [kvm]              [k] 0x00000000000771ea
     4.92%   insmod  [kernel.kallsyms]  [k] local_bh_disable
     2.37%   insmod  [kernel.kallsyms]  [k] ip_route_output_flow
     1.80%   insmod  [kernel.kallsyms]  [k] clear_page_c
     1.32%   insmod  [kernel.kallsyms]  [k] find_get_page
     1.31%   insmod  [kernel.kallsyms]  [k] page_remove_rmap
     1.15%   insmod  [kernel.kallsyms]  [k] copy_user_generic_string
     0.59%   insmod  [kernel.kallsyms]  [k] trace_module_notify
     0.59%   insmod  [kernel.kallsyms]  [k] free_pcppages_bulk
     0.25%   insmod  [kernel.kallsyms]  [k] __do_fault
     0.05%   insmod  [kernel.kallsyms]  [k] wait_for_common
     0.02%   insmod  [kernel.kallsyms]  [k] finish_task_switch
     0.00%   insmod  [kernel.kallsyms]  [k] native_write_msr_safe


#
# (For a higher level overview, try: perf report --sort comm,dso)
#
Jul 21 23:33:09 vijaynsu kernel: [13465.736545] kbench:
Jul 21 23:33:09 vijaynsu kernel: [13465.736545] flow
[IIF(0),OIF(0),MARK(0x00000000),D(172.27.231.128),S(172.27.231.28),TOS(0x00)]
Jul 21 23:33:09 vijaynsu kernel: [13465.736551] kbench: sizeof(struct
rtable)==216
Jul 21 23:33:09 vijaynsu kernel: [13465.746394] kbench:
ip_route_output_key tdiff: 231
Jul 21 23:33:09 vijaynsu kernel: [13465.756229] kbench:
ip_route_output_key tdiff: 210
Jul 21 23:33:09 vijaynsu kernel: [13465.766062] kbench:
ip_route_output_key tdiff: 196
Jul 21 23:33:09 vijaynsu kernel: [13465.775894] kbench:
ip_route_output_key tdiff: 196


Thanks,
Vijay
