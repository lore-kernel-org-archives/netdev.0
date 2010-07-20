From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v3 0/5] netdev: show a process of packets
Date: Tue, 20 Jul 2010 09:43:27 +0900
Message-ID: <4C44F12F.5090908@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com,
	kosaki.motohiro@jp.fujitsu.com, nhorman@tuxdriver.com,
	laijs@cn.fujitsu.com, scott.a.mcmillan@intel.com,
	rostedt@goodmis.org, eric.dumazet@gmail.com, fweisbec@gmail.com,
	mathieu.desnoyers@polymtl.ca
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

CHANGE-LOG since v2:
    1) let all tracepoints of softirq use DECLARE_EVENT_CLASS
    2) let tracepoint of netdev_queue and netdev_receive use DECLARE_EVENT_CLASS
    3) add tracepoint to skb_free_datagram_locked
    4) show function and time when received packet is freed

These patch-set adds tracepoints to show us a process of packets.
Using these tracepoints and existing points, we can get the time when
packet passes through some points in transmit or receive sequence.
For example, this is an output of perf script which is attached by patch 5/5.

79074.756672832sec cpu=1
irq_entry(+0.000000msec,irq=77:eth3)
         |------------softirq_raise(+0.001277msec)
irq_exit (+0.002278msec)     |
                             |
                      softirq_entry(+0.003562msec)
                             |
                             |---netif_receive_skb(+0.006279msec,len=100)
                             |            |
                             |   skb_copy_datagram_iovec(+0.038778msec, 2285:sshd)
                             |
                      napi_poll_exit(+0.017160msec, eth3)
                             |
                      softirq_exit(+0.018248msec)

The above is a receive side. Like this, it can show receive sequence from
interrupt(irq_entry) to application(skb_copy_datagram_iovec). There are eight
points in this side. All events except for skb_copy_datagram_iovec and
freeing skb events can be associated with each other by CPU number.
skb_copy_datagram_iovec and freeing skb events can be associated with
netif_receive_skb by skbaddr.
This script shows one NET_RX softirq and events related to it. All relative
time bases on first irq_entry which raise NET_RX softirq.

   dev    len      Qdisc               netdevice             free
   eth3   114  79044.417123332sec     0.005242msec          0.103843msec
   eth3   114  79044.580090422sec     0.002306msec          0.103632msec
   eth3   114  79044.719078251sec     0.002288msec          0.104093msec

The above is a transmit side. There are three tracepoints in this side.
Point1 is before putting a packet to Qdisc. point2 is after ndo_start_xmit in
dev_hard_start_xmit. It indicates finishing putting a packet to driver.
point3 is in consume_skb and dev_kfree_skb_irq. It indicates freeing a
transmitted packet.
Values of this script are, from left, device name, length of a packet, a time of
point1, an interval time between point1 and point2 and an interval time between
point2 and point3.

These times are useful to analyze a performance or to detect a point where
packet delays. For example,
- NET_RX softirq calling is late.
- Application is late to take a packet.
- It takes much time to put a transmitting packet to driver
  (It may be caused by packed queue)

And also, these tracepoint help us to investigate a network driver's trouble
from memory dump because ftrace records it to memory. And ftrace is so light
even if always trace on. So, in a case investigating a problem which doesn't
reproduce, it is useful.

Thanks,
Koki Sanagi.
