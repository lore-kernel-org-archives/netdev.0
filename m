From: Michal Schmidt <mschmidt@redhat.com>
Subject: significant napi_gro_frags() slowdown
Date: Thu, 27 Mar 2014 17:39:11 +0100
Message-ID: <5334542F.1050702@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jerry Chu <hkchu@google.com>, Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60521 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753304AbaC0QjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2014 12:39:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I received a report about a performance regression on a simple workload 
of receiving a single TCP stream using a be2net NIC. Previously the 
reporter was able to reach more than 9 Gb/s, but now he sees less than 7 
Gb/s.

On my system the performance loss was not so obvious, but profiling with 
perf showed significant time spent in copying memory in 
__pskb_pull_tail(). Here is an example perf histogram from 3.14-rc8:

-  14.03%         swapper  [kernel.kallsyms]        [k] memcpy
    - memcpy
       - 99.99% __pskb_pull_tail
          - 46.16% tcp_gro_receive
               tcp4_gro_receive
               inet_gro_receive
               dev_gro_receive
               napi_gro_frags
               be_process_rx
               be_poll
               net_rx_action
               __do_softirq
             + irq_exit
          - 31.18% napi_gro_frags
               be_process_rx
               be_poll
               net_rx_action
               __do_softirq
               irq_exit
               do_IRQ
             + ret_from_intr
          - 22.66% inet_gro_receive
               dev_gro_receive
               napi_gro_frags
               be_process_rx
               be_poll
               net_rx_action
               __do_softirq
               irq_exit
               do_IRQ
             + ret_from_intr
-  13.44%       netserver  [kernel.kallsyms]        [k] 
copy_user_generic_string
    - copy_user_generic_string
    - skb_copy_datagram_iovec
       + 56.70% skb_copy_datagram_iovec
       + 32.27% tcp_recvmsg
       + 11.03% tcp_rcv_established
-   5.64%         swapper  [kernel.kallsyms]        [k] __pskb_pull_tail
    - __pskb_pull_tail
       + 48.58% tcp_gro_receive
       + 24.48% inet_gro_receive
       + 24.11% napi_gro_frags
       + 1.28% tcp4_gro_receive
       + 0.91% be_process_rx
       + 0.64% dev_gro_receive
+   5.13%         swapper  [kernel.kallsyms]        [k] skb_copy_bits
...

Bisection identified this first bad commit:

     commit 299603e8370a93dd5d8e8d800f0dff1ce2c53d36
     Author: Jerry Chu <hkchu@google.com>
     Date:   Wed Dec 11 20:53:45 2013 -0800

         net-gro: Prepare GRO stack for the upcoming tunneling support

Before this commit, the GRO code was able to access the received 
packets' headers quickly via NAPI_GRO_CB(skb)->frag0. After the commit, 
this optimization no longer applies. napi_frags_skb() will now always 
pull the Ethernet header from the first frag. Subsequently, the slow 
paths are being taken in .gro_receive functions, always pulling the 
other headers with __pskb_pull_tail().

To demonstrate the call chains, let's see the function graph traced by 
ftrace.
Before the commit:

  13)               |  napi_gro_frags() {
  13)   0.038 us    |    skb_gro_reset_offset();
  13)               |    dev_gro_receive() {
  13)               |      inet_gro_receive() {
  13)               |        tcp4_gro_receive() {
  13)               |          tcp_gro_receive() {
  13)   0.059 us    |            skb_gro_receive();
  13)   0.385 us    |          }
  13)   0.675 us    |        }
  13)   1.012 us    |      }
  13)   1.336 us    |    }
  13)   0.040 us    |    napi_reuse_skb.isra.57();
  13)   2.235 us    |  }

After the commit:

   7)               |  napi_gro_frags() {
   7)               |    __pskb_pull_tail() {
   7)   0.204 us    |      skb_copy_bits();
   7)   0.551 us    |    }
   7)   0.046 us    |    eth_type_trans();
   7)               |    dev_gro_receive() {
   7)               |      inet_gro_receive() {
   7)               |        __pskb_pull_tail() {
   7)   0.095 us    |          skb_copy_bits();
   7)   0.412 us    |        }
   7)               |        tcp4_gro_receive() {
   7)               |          tcp_gro_receive() {
   7)               |            __pskb_pull_tail() {
   7)   0.095 us    |              skb_copy_bits();
   7)   0.410 us    |            }
   7)               |            __pskb_pull_tail() {
   7)   0.095 us    |              skb_copy_bits();
   7)   0.412 us    |            }
   7)   0.055 us    |            skb_gro_receive();
   7)   1.771 us    |          }
   7)   2.077 us    |        }
   7)   3.078 us    |      }
   7)   3.403 us    |    }
   7)   0.043 us    |    napi_reuse_skb.isra.72();
   7)   5.152 us    |  }

Here are typical times spent in napi_gro_frags(), measured using ftrace 
and making napi_gro_frags() a leaf function (thus avoiding the tracing 
overhead in child functions).
Before the commit:

...
  12)   0.130 us    |  napi_gro_frags();
  12)   0.129 us    |  napi_gro_frags();
  12)   0.132 us    |  napi_gro_frags();
  12)   0.128 us    |  napi_gro_frags();
  12)   0.126 us    |  napi_gro_frags();
  12)   0.129 us    |  napi_gro_frags();
  12)   1.423 us    |  napi_gro_frags();
...

After the commit:

...
  20)   0.812 us    |  napi_gro_frags();
  20)   0.820 us    |  napi_gro_frags();
  20)   0.811 us    |  napi_gro_frags();
  20)   0.812 us    |  napi_gro_frags();
  20)   0.814 us    |  napi_gro_frags();
  20)   0.819 us    |  napi_gro_frags();
  20)   1.526 us    |  napi_gro_frags();
...

This should affect not just be2net, but all drivers that use 
napi_gro_frags().
Any suggestions how to restore the frag0 optimization?

Thanks,
Michal
