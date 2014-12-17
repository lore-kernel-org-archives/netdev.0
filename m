From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: Re: [RFC PATCH net-next 3/5] tcp: Add a few more tracepoints for tcp
 tracer
Date: Wed, 17 Dec 2014 12:33:49 -0300
Message-ID: <20141217153349.GG11607@kernel.org>
References: <1418608606-1569264-1-git-send-email-kafai@fb.com>
 <1418608606-1569264-4-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Lawrence Brakmo <brakmo@fb.com>, Josef Bacik <jbacik@fb.com>,
	Kernel Team <Kernel-team@fb.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.19.201]:38297 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885AbaLQPd5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Dec 2014 10:33:57 -0500
Content-Disposition: inline
In-Reply-To: <1418608606-1569264-4-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Sun, Dec 14, 2014 at 05:56:44PM -0800, Martin KaFai Lau escreveu:
> The tcp tracer, which will be added in the later patch, depends
> on them to collect statistics.

> --- a/include/trace/events/tcp.h
<SNIP>
> +DECLARE_TRACE(tcp_sacks_rcv,
> +	     TP_PROTO(struct sock *sk, int num_sacks),
> +	     TP_ARGS(sk, num_sacks)
> +);

<SNIP>

> +++ b/net/ipv4/tcp_input.c
> @@ -1650,6 +1650,8 @@ tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
>  	int i, j;
>  	int first_sack_index;
>  
> +	trace_tcp_sacks_rcv(sk, num_sacks);
> +

In another message someone pointed out that we want some tracepoints, but
others would imply ABI, a drag on upstream to keep tons of set in stone
tracepoints, so what I was saying was like below, where one of the above
proposed tracepoints is implemented as a "wannabe tracepoint", i.e. a
dynamic probe, that will be as optimized as the kprobes_tracer can make it,
sometimes even using, IIRC, the ftrace mechanizms, if put on some suitable
place (function entry, etc, IIRC, Steven?).

On a random RHEL7 kernel I had laying around on a test machine:

[root@ssdandy ~]# perf probe -L tcp_sacktag_write_queue | head -20
<tcp_sacktag_write_queue@/usr/src/debug/kernel-3.10.0-123.el7/linux-3.10.0-123.el7.x86_64/net/ipv4/tcp_input.c:0>
      0  tcp_sacktag_write_queue(struct sock *sk, const struct sk_buff *ack_skb,
         			u32 prior_snd_una)
      2  {
         	struct tcp_sock *tp = tcp_sk(sk);
      4  	const unsigned char *ptr = (skb_transport_header(ack_skb) +
         				    TCP_SKB_CB(ack_skb)->sacked);
         	struct tcp_sack_block_wire *sp_wire = (struct tcp_sack_block_wire *)(ptr+2);
         	struct tcp_sack_block sp[TCP_NUM_SACKS];
         	struct tcp_sack_block *cache;
         	struct tcp_sacktag_state state;
         	struct sk_buff *skb;
     11  	int num_sacks = min(TCP_NUM_SACKS, (ptr[1] - TCPOLEN_SACK_BASE) >> 3);
         	int used_sacks;
         	bool found_dup_sack = false;
         	int i, j;
         	int first_sack_index;
         
     17  	state.flag = 0;
     18  	state.reord = tp->packets_out;
[root@ssdandy ~]#

Available variables at tcp_sacktag_write_queue:17
        @<tcp_sacktag_write_queue+77>
                int     num_sacks
                struct sk_buff* ack_skb
                struct sock*    sk
                struct tcp_sack_block_wire*     sp_wire
                u32     prior_snd_una
                unsigned char*  ptr
[root@ssdandy ~]#

Ok, so we can insert a probe at that point and also we can collect the values of the
sk and num_sacks variables, so:

[root@ssdandy ~]# perf probe 'tcp_sacks_rcv=tcp_sacktag_write_queue:17 sk num_sacks'
Added new event:
  probe:tcp_sacks_rcv  (on tcp_sacktag_write_queue:17 with sk num_sacks)

You can now use it in all perf tools, such as:

	perf record -e probe:tcp_sacks_rcv -aR sleep 1

[root@ssdandy ~]

There you go, you have your wannabe tracepoint, dynamic:

[root@ssdandy ~]# perf record -a -g -e probe:tcp_sacks_rcv
^C[ perf record: Woken up 1 times to write data ]
[ perf record: Captured and wrote 0.362 MB perf.data (~15799 samples) ]

[root@ssdandy ~]# perf script
swapper 0 [000] 184175.932790: probe:tcp_sacks_rcv: (ffffffff8151e59d) sk=ffff880425761e00 num_sacks=0
              71e59e tcp_sacktag_write_queue (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              72216e tcp_ack (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              723cf8 tcp_rcv_state_process (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              72d158 tcp_v4_do_rcv (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              72f5c7 tcp_v4_rcv (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              709584 ip_local_deliver_finish (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              709858 ip_local_deliver (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              7091fd ip_rcv_finish (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              709ac4 ip_rcv (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              6cfdb6 __netif_receive_skb_core (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              6cffc8 __netif_receive_skb (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              6d0050 netif_receive_skb (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              6d0aa8 napi_gro_receive (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
               1b5bf e1000_receive_skb (/lib/modules/3.10.0-123.el7.x86_64/kernel/drivers/net/ethernet/intel/e1000e/e1000e.ko)
               1cbda e1000_clean_rx_irq (/lib/modules/3.10.0-123.el7.x86_64/kernel/drivers/net/ethernet/intel/e1000e/e1000e.ko)
               247dc e1000e_poll (/lib/modules/3.10.0-123.el7.x86_64/kernel/drivers/net/ethernet/intel/e1000e/e1000e.ko)
              6d041a net_rx_action (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              267047 __do_softirq (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              7f3a5c call_softirq (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              214d25 do_softirq (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              2673e5 irq_exit (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              7f4358 do_IRQ (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              7e94ad ret_from_intr (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              7c3927 rest_init (/usr/lib/debug/lib/modules/3.10.0-123.el7.x86_64/vmlinux)
              e06fa7 start_kernel ([kernel.vmlinux].init.text)
              e065ee x86_64_start_reservations ([kernel.vmlinux].init.text)
              e06742 x86_64_start_kernel ([kernel.vmlinux].init.text)
<SNIP>

[root@ssdandy ~]# perf script -g python
generated Python script: perf-script.py
[root@ssdandy ~]# vim perf-script.py # Edit it to remove callchain printing, simplify some stuff
[root@ssdandy ~]# mv perf-script.py tcp_sack_rcv.py
[root@ssdandy ~]# cat tcp_sack_rcv.py 
import os, sys

sys.path.append(os.environ['PERF_EXEC_PATH'] + \
	'/scripts/python/Perf-Trace-Util/lib/Perf/Trace')

from perf_trace_context import *
from Core import *

def probe__tcp_sacks_rcv(event_name, context, common_cpu,
	common_secs, common_nsecs, common_pid, common_comm,
	common_callchain, __probe_ip, sk, num_sacks):
		print_header(event_name, common_cpu, common_secs, common_nsecs,
			common_pid, common_comm)

		print "__probe_ip=%#x, sk=%#x, num_sacks=%d" % \
		(__probe_ip, sk, num_sacks)

def print_header(event_name, cpu, secs, nsecs, pid, comm):
	print "%-18s %3u %05u.%09u %1u %-8s " % \
	(event_name, cpu, secs, nsecs, pid, comm),
[root@ssdandy ~]#

[root@ssdandy ~]# perf script -s tcp_sack_rcv.py  | head -10
Failed to open 64/libfreebl3.so, continuing without symbols
probe__tcp_sacks_rcv   0 184175.932790461 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff880425761e00, num_sacks=0
probe__tcp_sacks_rcv   0 184177.487455369 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804047e0780, num_sacks=0
probe__tcp_sacks_rcv   0 184177.588593040 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256af800, num_sacks=0
probe__tcp_sacks_rcv   0 184178.741298627 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256acb00, num_sacks=0
probe__tcp_sacks_rcv   0 184179.902089365 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256ad280, num_sacks=0
probe__tcp_sacks_rcv   0 184180.802761942 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256acb00, num_sacks=0
probe__tcp_sacks_rcv   0 184180.961373503 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256af800, num_sacks=0
probe__tcp_sacks_rcv   0 184182.123660739 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256ad280, num_sacks=0
probe__tcp_sacks_rcv   0 184182.387640636 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256acb00, num_sacks=0
probe__tcp_sacks_rcv   0 184182.859420892 0 swapper   __probe_ip=0xffffffff8151e59d, sk=0xffff8804256af800, num_sacks=0
[root@ssdandy ~]#


>  	state.flag = 0;
>  	state.reord = tp->packets_out;
>  	state.rtt_us = -1L;
> @@ -2932,6 +2934,9 @@ static inline bool tcp_ack_update_rtt(struct sock *sk, const int flag,
>  
>  	/* RFC6298: only reset backoff on valid RTT measurement. */
>  	inet_csk(sk)->icsk_backoff = 0;
> +
> +	trace_tcp_rtt_sample(sk, seq_rtt_us);
> +
>  	return true;
>  }
>  
> @@ -4232,6 +4237,7 @@ static void tcp_data_queue_ofo(struct sock *sk, struct sk_buff *skb)
>  	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_TCPOFOQUEUE);
>  	SOCK_DEBUG(sk, "out of order segment: rcv_next %X seq %X - %X\n",
>  		   tp->rcv_nxt, TCP_SKB_CB(skb)->seq, TCP_SKB_CB(skb)->end_seq);
> +	trace_tcp_ooo_rcv(sk);
>  
>  	skb1 = skb_peek_tail(&tp->out_of_order_queue);
>  	if (!skb1) {
> -- 
> 1.8.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
