From: Michal Soltys <soltys@ziu.info>
Subject: Re: r8169 (+others ?) and note_interrupt performance hit on 2.6.30.x
Date: Sun, 26 Jul 2009 20:43:59 +0200
Message-ID: <4A6CA3EF.7080909@ziu.info>
References: <4A6BA3CE.9000607@ziu.info> <20090726091803.GA28374@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from drutsystem.com ([80.72.38.138]:1732 "EHLO drutsystem.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753919AbZGZSoR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 26 Jul 2009 14:44:17 -0400
In-Reply-To: <20090726091803.GA28374@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I did some more tests, with kernel booted both with noirqdebug and
without (as this decides if note_interrupt gets called from
handle_edge_irq).

As far as cpu load goes, everything remained the same - 100% on chosen
core, unable to reach 1gbit. When noirqdebug was enabled, oprofile showed
majority of time spent in handle_edge_irq:

CPU: AMD64 processors, speed 2517.35 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 50000
samples  cum. samples  %        cum. %     symbol name
15238    15238         38.1723  38.1723    handle_edge_irq
2146     17384          5.3759  43.5482    rb_get_reader_page
1877     19261          4.7020  48.2502    csum_partial_copy_generic
1671     20932          4.1860  52.4362    getnstimeofday
1618     22550          4.0532  56.4894    udp_sendmsg
1366     23916          3.4219  59.9113    ip_append_data
1159     25075          2.9034  62.8147    ring_buffer_consume
1153     26228          2.8883  65.7030    handle_IRQ_event
779      27007          1.9515  67.6545    __kmalloc_track_caller

... and with callgraph:

CPU: AMD64 processors, speed 2517.35 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 50000
samples  cum. samples  %        cum. %     symbol name
-------------------------------------------------------------------------------
   1        1              0.0030   0.0030    vmlinux-test             do_IRQ
   1        2              0.0030   0.0060    vmlinux-test             sock_poll
   1        3              0.0030   0.0090    vmlinux-test             net_rx_action
   2        5              0.0060   0.0149    vmlinux-test             do_softirq
   2        7              0.0060   0.0209    vmlinux-test             op_add_code
   3        10             0.0090   0.0298    vmlinux-test             handle_IRQ_event
   12       22             0.0358   0.0657    vmlinux-test             inet_sendmsg
   13       35             0.0388   0.1045    vmlinux-test             sk_filter
   39       74             0.1164   0.2209    vmlinux-test             ktime_get_real
   61       135            0.1821   0.4029    vmlinux-test             log_sample
   104      239            0.3104   0.7133    vmlinux-test             x86_backtrace
   15178    15417         45.2993  46.0127    vmlinux-test             handle_edge_irq
   18089    33506         53.9873  100.000    vmlinux-test             handle_irq
15238    15238         38.1723  38.1723    vmlinux-test             handle_edge_irq
   15238    15238         45.4404  45.4404    vmlinux-test             handle_edge_irq [self]
   15178    30416         45.2615  90.7020    vmlinux-test             handle_edge_irq
   2833     33249          8.4481  99.1501    vmlinux-test             handle_IRQ_event
   166      33415          0.4950  99.6451    vmlinux-test             udp_sendmsg
   42       33457          0.1252  99.7704    vmlinux-test             ack_apic_edge
   39       33496          0.1163  99.8867    vmlinux-test             getnstimeofday
   8        33504          0.0239  99.9105    r8169.ko                 rtl8169_poll
   7        33511          0.0209  99.9314    vmlinux-test             do_IRQ
   5        33516          0.0149  99.9463    vmlinux-test             __pollwait
   5        33521          0.0149  99.9612    vmlinux-test             log_sample
   5        33526          0.0149  99.9761    r8169.ko                 rtl8169_interrupt
   2        33528          0.0060  99.9821    vmlinux-test             __do_softirq
   1        33529          0.0030  99.9851    vmlinux-test             sk_run_filter
   1        33530          0.0030  99.9881    vmlinux-test             udp_poll
   1        33531          0.0030  99.9911    vmlinux-test             op_add_code
   1        33532          0.0030  99.9940    vmlinux-test             x86_backtrace
   1        33533          0.0030  99.9970    vmlinux-test             _spin_lock
   1        33534          0.0030  100.000    vmlinux-test             apic_timer_interrupt
-------------------------------------------------------------------------------

Additional note - with noirqdebug, I often had to sync and reboot through sysreq.


Without noirqdebug, oprofile showed:

CPU: AMD64 processors, speed 2517.14 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 50000
samples  cum. samples  %        cum. %     symbol name
24056    24056         63.5108  63.5108    note_interrupt
3415     27471          9.0160  72.5269    rb_get_reader_page
1633     29104          4.3113  76.8382    ring_buffer_consume
728      29832          1.9220  78.7602    add_event_entry
681      30513          1.7979  80.5581    rb_buffer_peek
621      31134          1.6395  82.1976    getnstimeofday
[...]
29       36831          0.0766  97.2384    handle_edge_irq

... and with callgraph:

CPU: AMD64 processors, speed 2517.14 MHz (estimated)
Counted CPU_CLK_UNHALTED events (Cycles outside of halt state) with a unit mask of 0x00 (No unit mask) count 50000
samples  cum. samples  %        cum. %     image name               symbol name
-------------------------------------------------------------------------------
   1        1              0.0041   0.0041    vmlinux-test             do_timer
   10       11             0.0414   0.0456    vmlinux-test             inet_sendmsg
   26       37             0.1077   0.1533    vmlinux-test             timer_start
   43       80             0.1782   0.3315    vmlinux-test             _spin_lock_bh
   24054    24134         99.6685  100.000    vmlinux-test             handle_edge_irq
24056    24056         63.5108  63.5108    vmlinux-test             note_interrupt
   24056    24056         99.6644  99.6644    vmlinux-test             note_interrupt [self]
   44       24100          0.1823  99.8467    vmlinux-test             __pollwait
   37       24137          0.1533  100.000    vmlinux-test             dump_trace
-------------------------------------------------------------------------------
[...]
-------------------------------------------------------------------------------
   1        1              0.0039   0.0039    vmlinux-test             do_softirq
   1        2              0.0039   0.0079    vmlinux-test             irq_exit
   1        3              0.0039   0.0118    vmlinux-test             sock_def_write_space
   3        6              0.0118   0.0236    vmlinux-test             net_rx_action
   3        9              0.0118   0.0354    vmlinux-test             sk_filter
   5        14             0.0197   0.0551    vmlinux-test             do_IRQ
   8        22             0.0315   0.0865    vmlinux-test             handle_edge_irq
   10       32             0.0393   0.1259    vmlinux-test             ktime_get_real
   25389    25421         99.8741  100.000    vmlinux-test             handle_irq
29       36831          0.0766  97.2384    vmlinux-test             handle_edge_irq
   24054    24054         94.5742  94.5742    vmlinux-test             note_interrupt
   1286     25340          5.0562  99.6304    vmlinux-test             handle_IRQ_event
   29       25369          0.1140  99.7444    vmlinux-test             handle_edge_irq [self]
   18       25387          0.0708  99.8152    vmlinux-test             ack_apic_edge
   15       25402          0.0590  99.8742    r8169.ko                 rtl8169_poll
   10       25412          0.0393  99.9135    vmlinux-test             getnstimeofday
   8        25420          0.0315  99.9450    vmlinux-test             handle_edge_irq
   4        25424          0.0157  99.9607    vmlinux-test             apic_timer_interrupt
   3        25427          0.0118  99.9725    r8169.ko                 rtl8169_interrupt
   2        25429          0.0079  99.9803    r8169.ko                 rtl8169_rx_interrupt
   1        25430          0.0039  99.9843    vmlinux-test             __do_softirq
   1        25431          0.0039  99.9882    vmlinux-test             move_native_irq
   1        25432          0.0039  99.9921    vmlinux-test             sk_run_filter
   1        25433          0.0039  99.9961    vmlinux-test             __pollwait
   1        25434          0.0039  100.000    ip_tables.ko             ipt_do_table
-------------------------------------------------------------------------------


 From a breif look over the above, rtl8169_rx_interrupt
is not called in noirqdebug case, and handle_edge_irq gets called
from within handle_edge_irq ?

Anwyay, not sure if this is useful, so if there is anything better
I could do, just push me in the right direction.

