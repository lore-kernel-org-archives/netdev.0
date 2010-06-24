From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH v2 0/5] netdev: show a process of packets
Date: Thu, 24 Jun 2010 17:09:12 +0900
Message-ID: <4C2312A8.9060903@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, scott.a.mcmillan@intel.com,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:52778 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab0FXIJY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 04:09:24 -0400
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o5O89LVB031357
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Thu, 24 Jun 2010 17:09:21 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FFC745DE53
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:09:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id 4E83945DE51
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:09:21 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 32EE9E08002
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:09:21 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id D25011DB8015
	for <netdev@vger.kernel.org>; Thu, 24 Jun 2010 17:09:20 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CHANGE-LOG since v1:
    1) fix to enable "perf trace record netdev-times" run with a script.
    2) add some options to "perf trace report netdev-times". A detail is in
       PATCH 5/5.

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
interrupt(irq_entry) to application(skb_copy_datagram_iovec). There are 8
tracepoints in this side. All events except for skb_copy_datagram_iovec can be
associated with each other by CPU number. skb_copy_datagram_iovec can be
associated with netif_receive_skb by skbaddr.
This script shows one NET_RX softirq and events related to it. All relative
time bases on first irq_entry which raise NET_RX softirq.

   dev    len      dev_queue_xmit|----------|dev_hard_start_xmit|-----|free_skb
                         |             |                           |
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

