From: "Zhang, Yanmin" <yanmin_zhang@linux.intel.com>
Subject: Re: Netperf TCP_RR(loopback) 10% regression in 2.6.24-rc6,
	comparing with 2.6.22
Date: Fri, 11 Jan 2008 17:30:54 +0800
Message-ID: <1200043854.3265.24.camel@ymzhang>
References: <1199871330.3298.132.camel@ymzhang>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga10.intel.com ([192.55.52.92]:54980 "EHLO
	fmsmga102.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759287AbYAKJda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jan 2008 04:33:30 -0500
In-Reply-To: <1199871330.3298.132.camel@ymzhang>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-01-09 at 17:35 +0800, Zhang, Yanmin wrote: 
> The regression is:
> 1)stoakley with 2 qual-core processors: 11%;
> 2)Tulsa with 4 dual-core(+hyperThread) processors:13%;
I have new update on this issue and also cc to netdev maillist.
Thank David Miller for pointing me the netdev maillist.

> 
> The test command is:
> #sudo taskset -c 7 ./netserver
> #sudo taskset -c 0 ./netperf -t TCP_RR -l 60 -H 127.0.0.1 -i 50,3 -I 99,5 -- -r 1,1
> 
> As a matter of fact, 2.6.23 has about 6% regression and 2.6.24-rc's
> regression is between 16%~11%.
> 
> I tried to use bisect to locate the bad patch between 2.6.22 and 2.6.23-rc1,
> but the bisected kernel wasn't stable and went crazy.
> 
> I tried both CONFIG_SLUB=y and CONFIG_SLAB=y to make sure SLUB isn't the
> culprit.
> 
> The oprofile data of CONFIG_SLAB=y. Top cpu utilizations are:
> 1) 2.6.22 
> 2067379   9.4888  vmlinux                  schedule
> 1873604   8.5994  vmlinux                  mwait_idle
> 1568131   7.1974  vmlinux                  resched_task
> 1066976   4.8972  vmlinux                  tcp_v4_rcv
> 986641    4.5285  vmlinux                  tcp_rcv_established
> 979518    4.4958  vmlinux                  find_busiest_group
> 767069    3.5207  vmlinux                  sock_def_readable
> 736808    3.3818  vmlinux                  tcp_sendmsg
> 595889    2.7350  vmlinux                  task_rq_lock
> 557193    2.5574  vmlinux                  tcp_ack
> 470570    2.1598  vmlinux                  __mod_timer
> 392220    1.8002  vmlinux                  __alloc_skb
> 358106    1.6436  vmlinux                  skb_release_data
> 313372    1.4383  vmlinux                  skb_clone
> 
> 2) 2.6.24-rc7
> 2668426  12.4497  vmlinux                  vmlinux                  schedule
> 955698    4.4589  vmlinux                  vmlinux                  skb_release_data
> 836311    3.9018  vmlinux                  vmlinux                  tcp_v4_rcv
> 762398    3.5570  vmlinux                  vmlinux                  skb_release_all
> 728907    3.4007  vmlinux                  vmlinux                  task_rq_lock
> 705037    3.2894  vmlinux                  vmlinux                  __wake_up
> 694206    3.2388  vmlinux                  vmlinux                  __mod_timer
> 617616    2.8815  vmlinux                  vmlinux                  mwait_idle
> 
> It looks like tcp in 2.6.22 sends more packets, but frees far less skb than 2.6.24-rc6.
> tcp_rcv_established in 2.6.22 is highlighted on cpu utilization.
I instrumented kernel to capure the function call numbers.
1) 2.6.22
skb_release_data:50148649
tcp_ack:	 25062858	
tcp_transmit_skb:25063150	
tcp_v4_rcv:	 25063279	

2) 2.6.24-rc6
skb_release_data:21429692	
tcp_ack:	 10707710	
tcp_transmit_skb:10707866
tcp_v4_rcv:	 10707959		

The data doesn't show that 2.6.22 sends more packets while freeing far less skb than
2.6.24-rc6.

The data showed skb_release_data of kernel 2.6.22 is more than double of the one of
2.6.24-rc6. But netperf result just showed about 10% regression.

As the packet only has 1 byte, so I suspect 2.6.24-rc6 tries to merge packets after waiting for
a latency. 2.6.22 might haven't the wait latency or the latency is very small, so 2.6.22 almost
sends the packets immediately. I will check the source codes later.

-yanmin


