From: Zoltan Kiss <zoltan.kiss@citrix.com>
Subject: NAPI rescheduling and the delay caused by it
Date: Wed, 4 Dec 2013 18:55:03 +0000
Message-ID: <529F7A87.5080303@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	Malcolm Crossley <malcolm.crossley@citrix.com>,
	Jonathan Davies <Jonathan.Davies@eu.citrix.com>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:1087 "EHLO SMTP02.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933010Ab3LDSzG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Dec 2013 13:55:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Recently I've found a strange behaviour in NAPI, and I hope someone can 
shed some light about it. The basic issue I see that an instance is 
scheduled on one CPU, and then becomes rescheduled on an another one. I 
don't understand why, there shouldn't be any load on that CPU, but it 
would be fine, however there is a 3-4 msec delay between original 
scheduling and actual run, and it causes terrible TCP single stream 
performance. Let me explain it with some ftrace logs.
I'm using Xen 4.3, Dom0 kernel is a net-next 3.12 one, the iperf client 
guest (TX) has the same kernel, and the iperf server (RX) is a stock 
Debian 7. vif2.0-10088 is the TX netback thread (it has to deal only 
with the TCP ACKs mostly) and vif1.0-9854 is the RX thread (it copies 
the packets to the receiving guest). I've added some trace_printk's to 
get more details, and the ftrace filter is:

echo net_rx_action kthread_should_stop xenvif_rx_action 
xenvif_start_xmit xenvif_tx_action > /debug/tracing/set_ftrace_filter

Also an important thing, that I set the affinity of vif interrupts and 
vif2.0 to CPU#3, while vif1.0 is forced to run on CPU#2. That's not 
necessarily ideal, but it can happen, and it does, that's why I started 
to poke around with affinities. I've tried to pin vCPU's to make sure no 
other domains are running on the same pCPU, but it haven't changed anything.

Here are the logs and my inline comments:

<idle>-0     [003] d.h. 73994.027432: xenvif_interrupt: vif1.0 interrupt
<idle>-0     [003] d.h. 73994.027433: xenvif_tx_interrupt: vif1.0 
tx_interrupt napi_schedule for tx_action
<idle>-0     [003] d.h. 73994.027434: xenvif_rx_interrupt: vif1.0 
rx_interrupt wake start_xmit
Domain 1 sent an interrupt, we kicked the vif1.0 (TX) thread and woke 
NAPI to deal with the sent packet.

<idle>-0     [003] ..s. 73994.027436: net_rx_action <-__do_softirq
<idle>-0     [003] ..s. 73994.027436: xenvif_tx_action <-xenvif_poll
<idle>-0     [003] ..s. 73994.027460: xenvif_start_xmit 
<-dev_hard_start_xmit
<idle>-0     [003] .ps. 73994.027465: xenvif_start_xmit: vif2.0 
packet_queued
The sent packet is now at vif2.0's queue.

vif2.0-10088 [003] .... 73994.027475: kthread_should_stop <-xenvif_kthread
vif2.0-10088 [003] .... 73994.027475: xenvif_rx_action <-xenvif_kthread
vif2.0-10088 [003] .... 73994.027483: kthread_should_stop <-xenvif_kthread
vif2.0-10088 [003] .... 73994.027483: kthread_should_stop <-xenvif_kthread
vif2.0-10088 [003] .... 73994.027484: kthread_should_stop <-xenvif_kthread
vif2.0 thread now delivered the packet to Domain 2. It was probably a 
TCP ACK anyway. The pattern of 3 kthread_should_stop marks that the 
thread called schedule()

<idle>-0     [003] d.h. 73994.027543: xenvif_interrupt: vif2.0 interrupt
<idle>-0     [003] d.h. 73994.027544: xenvif_tx_interrupt: vif2.0 
tx_interrupt napi_schedule for tx_action
<idle>-0     [003] d.h. 73994.027545: xenvif_rx_interrupt: vif2.0 
rx_interrupt wake start_xmit
Domain2's iperf client sent a big packet, and here is the issue: despite 
we scheduled NAPI on CPU#3, it will run on CPU#2 (which would be fine), 
but there is an almost 4 milisec delay! Both threads are sleeping, and 
there is no other load on the system which would justify such a delay.

<idle>-0     [002] ..s. 73994.031248: net_rx_action <-__do_softirq
<idle>-0     [002] ..s. 73994.031249: xenvif_tx_action <-xenvif_poll
<idle>-0     [002] ..s. 73994.031323: xenvif_start_xmit 
<-dev_hard_start_xmit
<idle>-0     [002] .ps. 73994.031329: xenvif_start_xmit: vif1.0
vif1.0-9854  [002] .... 73994.031338: kthread_should_stop <-xenvif_kthread
vif1.0-9854  [002] .... 73994.031338: xenvif_rx_action <-xenvif_kthread
vif1.0-9854  [002] .... 73994.031391: kthread_should_stop <-xenvif_kthread
vif1.0-9854  [002] .... 73994.031391: kthread_should_stop <-xenvif_kthread
vif1.0-9854  [002] .... 73994.031392: kthread_should_stop <-xenvif_kthread
NAPI called the poll, and our thread woke up to serve the packet.

So, my questions are:
- why is NAPI rescheduled on an another CPU?
- why does it cause a 3-4 milisec delay?
