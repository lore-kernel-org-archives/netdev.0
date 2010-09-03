From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: Re: [PATCH v4 0/5] netdev: show a process of packets
Date: Fri, 03 Sep 2010 11:10:51 +0900
Message-ID: <4C80592B.2060406@jp.fujitsu.com>
References: <4C72422C.5070102@jp.fujitsu.com> <1283212210.3656.84.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, kaneshige.kenji@jp.fujitsu.com,
	izumi.taku@jp.fujitsu.com, kosaki.motohiro@jp.fujitsu.com,
	nhorman@tuxdriver.com, laijs@cn.fujitsu.com,
	scott.a.mcmillan@intel.com, eric.dumazet@gmail.com,
	fweisbec@gmail.com, mathieu.desnoyers@polymtl.ca
To: Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1283212210.3656.84.camel@gandalf.stny.rr.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(2010/08/31 8:50), Steven Rostedt wrote:
> On Mon, 2010-08-23 at 18:41 +0900, Koki Sanagi wrote:
>> Rebase to the latest net-next.
>>
>> CHANGE-LOG since v3:
>>     1) change arguments of softirq tracepoint into original one.
>>     2) remove tracepoint of dev_kfree_skb_irq and skb_free_datagram_locked
>>        and add trace_kfree_skb before __kfree_skb instead of them.
>>     3) add tracepoint to netif_rx and display it by netdev-times script.
>>
>> These patch-set adds tracepoints to show us a process of packets.
>> Using these tracepoints and existing points, we can get the time when
>> packet passes through some points in transmit or receive sequence.
>> For example, this is an output of perf script which is attached by patch 5/5.
>>
>> 106133.171439sec cpu=0
>>   irq_entry(+0.000msec irq=24:eth4)
>>          |
>>   softirq_entry(+0.006msec)
>>          |
>>          |---netif_receive_skb(+0.010msec skb=f2d15900 len=100)
>>          |            |
>>          |      skb_copy_datagram_iovec(+0.039msec 10291::10291)
>>          |
>>   napi_poll_exit(+0.022msec eth4)
>>
>> 106134.175634sec cpu=1
>>   irq_entry(+0.000msec irq=28:eth1)
>>          |
>>          |---netif_rx(+0.009msec skb=f3ef0a00)
>>          |
>>   softirq_entry(+0.018msec)
>>          |
>>          |---netif_receive_skb(+0.021msec skb=f3ef0a00 len=84)
>>          |            |
>>          |      skb_copy_datagram_iovec(+0.033msec 0:swapper)
>>          |
>>   napi_poll_exit(+0.035msec (no_device))
>>
>> The above is a receive side(eth4 is NAPI. eth1 is non-NAPI). Like this, it can
>> show receive sequence frominterrupt(irq_entry) to application
>> (skb_copy_datagram_iovec). 
>> This script shows one NET_RX softirq and events related to it. All relative
>> time bases on first irq_entry which raise NET_RX softirq.
>>
>>    dev    len      Qdisc               netdevice             free
>>    eth4    74 106125.030004sec        0.006msec             0.009msec
>>    eth4    87 106125.041020sec        0.007msec             0.023msec
>>    eth4    66 106125.042291sec        0.003msec             0.012msec
>>    eth4    66 106125.043274sec        0.006msec             0.004msec
>>    eth4   850 106125.044283sec        0.007msec             0.018msec
>>
>> The above is a transmit side. There are three check-time-points.
>> Point1 is before putting a packet to Qdisc. point2 is after ndo_start_xmit in
>> dev_hard_start_xmit. It indicates finishing putting a packet to driver.
>> point3 is in consume_skb and kfree_skb. It indicates freeing a transmitted packet.
>> Values of this script are, from left, device name, length of a packet, a time of
>> point1, an interval time between point1 and point2 and an interval time between
>> point2 and point3.
>>
>> These times are useful to analyze a performance or to detect a point where
>> packet delays. For example,
>> - NET_RX softirq calling is late.
>> - Application is late to take a packet.
>> - It takes much time to put a transmitting packet to driver
>>   (It may be caused by packed queue)
>>
>> And also, these tracepoint help us to investigate a network driver's trouble
>> from memory dump because ftrace records it to memory. And ftrace is so light
>> even if always trace on. So, in a case investigating a problem which doesn't
>> reproduce, it is useful.
>>
> 
> The entire series:
> 
> Acked-by: Steven Rostedt <rostedt@goodmis.org>
> 
> -- Steve
> 

Thanks many acks. and I have one question.

These patches have several component.

Patch1 is kernel component, but patch2-5 are netdev component.
What tree is good to be included ?
If it is not net-next, I must rebase to another tree.

Thanks,
Koki Sanagi.
