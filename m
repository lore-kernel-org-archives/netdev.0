From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 0/2] netdev: show the number of tx-packets in device
Date: Mon, 24 May 2010 13:49:21 +0900
Message-ID: <4BFA0551.3080304@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nhorman@tuxdriver.com,
	kaneshige.kenji@jp.fujitsu.com, izumi.taku@jp.fujitsu.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:46757 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866Ab0EXEtU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 May 2010 00:49:20 -0400
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o4O4nIDd025670
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 24 May 2010 13:49:18 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0A8BF45DE52
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:49:18 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D9EF445DE50
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:49:17 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id C091EE08005
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:49:17 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6506EE08002
	for <netdev@vger.kernel.org>; Mon, 24 May 2010 13:49:17 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch-set adds tracepoints to dev_hard_start_xmit, consume_skb and
dev_kfree_skb_irq and perf script which calculates the time from entry of
ndo_start_xmit to dev_kfree_skb_* and the number of tx-packets in device.

-Perf script description
This script calculates two metric.

metric1: lap time between start_xmit - free_skb
This script calculate the time a packet passes from entry of ndo_start_xmit to
dev_kfree_skb_irq or consume_skb. It indicate a time driver/device owns that
packet. This script outputs an average time of all packets and a longest of
that.

metric2: number of packets in device
>From the above time, we can calculate the number of packets in device at a
certain time. This script outputs an average of the number of packets in device
and a largest of that.

-Merit
These tracepoints and script have two merits.

1. Detecting a packed tx-ring of network device
2. Detecting a defect of transmit functionality of network device

merit1: Detecting a packed tx-ring of network device

Using attached scripts, we can get a maximum number of packets in a device. If
it reaches to the number of packets a device can own, tx-ring of that device is
full and causes loss of network transmit performance. Because the driver of the
device drop packet or stops tx-ring and reject it until it keeps some space.
So, to keep good network transmit performance, it is good to keep some space in
tx-ring. To keep some space in tx-ring, these tracepoints and script are
useful.

To check this merit, I did a test.

Before starting a test, I want you to know that a maximum number of tx-packets
e1000e can own is (tx-ring size - 20) / 2 packets.
Because e1000e keeps 20 descriptors for frags and 1 packet needs 2 descriptors
due to tx-checksum.
So, if tx-ring size is 256,
(256 - 20) / 2 = 118 packets
If tx-ring size is 512,
(512 - 20) / 2 = 246 packets

Environment:
Test NIC:     Intel 82571EB (InterruptThrottleRate=1000)
Opponent NIC: Broadcom BCM5703X
InterruptThrottleRate was set to 1000 to make tx-ring packed deliberately.

Test load tool:
netperf -H XXX.XXX.XXX.XXX -t UDP_STREAM -- -m 1

With this environment, I compared following 2 cases.
1.Tx-ring size=256 case
2.Tx-ring size=512 case

Result:
1.The case of Tx-ring=256:
eth0    TX packets=1137811
        lap time between start_xmit - free_skb:
            avg=0.795687msec
            max=0.985911msec
         number of packets in device:
            avg=  64.66
            max= 118

netperf's result:
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec
112640       1   10.00     1179077      0       0.94
109568           10.00      544750              0.44

2.The case of Tx-ring=512:
eth0    TX packets=1531629
        lap time between start_xmit - free_skb:
            avg=0.370052msec
            max=0.982069msec
        number of packets in device:
            avg=  49.70
            max= 164

netperf's result:
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec
112640       1   10.00     1577840      0       1.26
109568           10.00      871058              0.70

In the case of tx-ring size=256(default),  maximum number of packets in device
reaches to 118. So this tx-ring is full and becomes a cause of network
performance loss.
On the other hand, in the case of tx-ring size=512, e1000e can own 246 packets,
but maximum number of packets in device doesn't reach it. so tx-ring has always
some space and there is  no network performance loss caused by packed tx-ring.
Actually, about transmit throughput, The case of Tx-ring size=512 is better
than the case of tx-ring size=256.
Like this, the number of packets in device is available to tune tx-ring size or
other parameters to avoid packed tx-ring and is related to network transmit
performance.

merit2: Detecting a defect of transmit functionality of network device

When device can't transmit due to hardware fault or driver's bug(I've
encountered this), we can detect it. Because in such case, dev_hard_start_xmit
is passed, but dev_kfree_skb_* is not passed.

NOTE:
This script has some problem,

-The number of tx-packets of netperf and  that of this script are not equal.
-Sometimes The max number of packets in device larger than the device can own.

Thanks,
Koki Sanagi.

