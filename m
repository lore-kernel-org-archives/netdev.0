From: Rick Jones <rick.jones2@hp.com>
Subject: a tap mystery
Date: Mon, 10 Jun 2013 17:16:52 -0700
Message-ID: <51B66C74.2050801@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:3648 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753386Ab3FKAQx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 20:16:53 -0400
Received: from g4t0009.houston.hp.com (g4t0009.houston.hp.com [16.234.32.26])
	by g4t0016.houston.hp.com (Postfix) with ESMTP id 45BF31432E
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 00:16:53 +0000 (UTC)
Received: from [16.103.148.51] (tardy.usa.hp.com [16.103.148.51])
	by g4t0009.houston.hp.com (Postfix) with ESMTP id 1A6EFC0F7
	for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 00:16:52 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a small test script which runs a netperf TCP_RR test with an ever 
increasing number of tap devices on the system.  In this case the system 
is a venerable Centrino-based laptop on AC power at fixed frequency, 
with idle=poll for perf profiling purposes, the irqbalanced shot in the 
head and the IRQ of the Intel Corporation 82566MM pointed at CPU 0, 
whereon I have also bound the netperf process.  The other system is my 
personal workstation and the network connection between them is a 
private, back-to-back link.  The kernel on the laptop is a 3.5.0-30 
generic kernel.

For the first 1024 tap devices created on the system, and put into the 
"UP" state, what netperf reports for CPU utilization and service demand 
is consistent with increasing per-packet costs which seems to be 
consistent with list_for_each_entry_rcu(ptype, &ptype_all, list) usage 
in dev_queue_xmit_nit and __netif_receive_skb.


But somewhere between 1024 and 2048 tap devices some sort of miracle 
occurs and the CPU utilization and service demand drop.  Considerably.

(What netperf reports as Result Tag is what it has been fed - the number 
of tap devices on the system at the time)

root@raj-8510w:~# ./test_taps.sh 2048
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET to 
192.168.1.4 () port 0 AF_INET : nodelay : demo : first burst 0 : cpu bind
Result Tag,Throughput,Local CPU Util %,Local Service Demand,Throughput 
Confidence Width (%),Local CPU Confidence Width (%),Confidence 
Iterations Run
"0",21258.61,13.72,12.912,-1.000,-1.000,1
"1",21327.31,13.00,12.193,-1.000,-1.000,1
"2",21178.54,12.84,12.130,-1.000,-1.000,1
"4",21492.60,13.52,12.580,-1.000,-1.000,1
"8",20904.31,13.35,12.768,-1.000,-1.000,1
"16",20771.23,14.01,13.487,-1.000,-1.000,1
"32",20699.91,13.31,12.863,-1.000,-1.000,1
"64",20394.51,14.60,14.321,-1.000,-1.000,1
"128",19920.74,15.31,15.366,-1.000,-1.000,1
"256",19231.69,17.87,18.585,-1.000,-1.000,1
"512",17798.37,21.14,23.752,-1.000,-1.000,1
"1024",15986.82,44.77,56.005,-1.000,-1.000,1
"2048",21514.10,12.02,11.173,-1.000,-1.000,1


Here is the top of the flat profile at 1024 taps:

# Overhead                                      Symbol 
Shared Object
# ........  .......................................... 
...........................
#
     49.93%  [k] poll_idle                               [kernel.kallsyms]
      5.37%  [k] dev_queue_xmit_nit                      [kernel.kallsyms]
      5.14%  [k] __netif_receive_skb                     [kernel.kallsyms]
      2.80%  [k] snmp_fold_field64                       [kernel.kallsyms]
      2.45%  [k] e1000_irq_enable                        [e1000e]
      1.78%  [k] e1000_intr_msi                          [e1000e]
      1.46%  [.] map_newlink                             libc-2.15.so
      0.93%  [k] memcpy                                  [kernel.kallsyms]
      0.93%  [k] find_next_bit                           [kernel.kallsyms]
      0.90%  [k] rtnl_fill_ifinfo                        [kernel.kallsyms]

and then at 2048 taps:

# Overhead                                      Symbol 
Shared Object
# ........  .......................................... 
..........................
#
     76.04%  [k] poll_idle                               [kernel.kallsyms]
      2.73%  [k] e1000_irq_enable                        [e1000e]
      1.92%  [k] e1000_intr_msi                          [e1000e]
      0.63%  [k] __ticket_spin_unlock                    [kernel.kallsyms]
      0.58%  [k] __ticket_spin_lock                      [kernel.kallsyms]
      0.47%  [k] read_tsc                                [kernel.kallsyms]
      0.44%  [k] ktime_get                               [kernel.kallsyms]
      0.38%  [k] __schedule                              [kernel.kallsyms]
      0.38%  [k] irq_entries_start                       [kernel.kallsyms]
      0.37%  [k] native_sched_clock                      [kernel.kallsyms]

A second run of the test shows no increase at all:

root@raj-8510w:~# ./test_taps.sh 2048
MIGRATED TCP REQUEST/RESPONSE TEST from 0.0.0.0 () port 0 AF_INET to 
192.168.1.4 () port 0 AF_INET : nodelay : demo : first burst 0 : cpu bind
Result Tag,Throughput,Local CPU Util %,Local Service Demand,Throughput 
Confidence Width (%),Local CPU Confidence Width (%),Confidence 
Iterations Run
"0",21796.63,11.92,10.935,-1.000,-1.000,1
"1",21679.00,11.86,10.943,-1.000,-1.000,1
"2",21719.44,11.96,11.013,-1.000,-1.000,1
"4",21413.83,12.60,11.764,-1.000,-1.000,1
"8",21404.47,12.63,11.805,-1.000,-1.000,1
"16",21197.67,13.04,12.300,-1.000,-1.000,1
"32",21216.83,13.11,12.358,-1.000,-1.000,1
"64",21183.16,13.17,12.439,-1.000,-1.000,1
"128",21334.39,13.38,12.542,-1.000,-1.000,1
"256",21061.21,12.88,12.229,-1.000,-1.000,1
"512",21363.41,12.27,11.486,-1.000,-1.000,1
"1024",21658.14,12.50,11.539,-1.000,-1.000,1
"2048",22084.43,11.78,10.668,-1.000,-1.000,1

If though I reboot and run again, I see the same sort of thing as before 
- first run shows increase up to 1024 taps or so, then the drop and no 
more rise in runs thereafter.

Is this extraordinarily miraculous behaviour somewhere between 1024 and 
2048 tap devices expected? Is there a way to make it happen much sooner?

I have all the perf reports and a copy of the script and such at:

ftp://ftp.netperf.org/tap_mystery/

thanks and happy benchmarking,

rick jones
