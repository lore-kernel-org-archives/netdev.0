From: Timo Teras <timo.teras@iki.fi>
Subject: r8169 rx_missed increasing in bursts (regression)
Date: Tue, 8 Jan 2013 10:28:14 +0200
Message-ID: <20130108102814.7abe8c08@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f48.google.com ([74.125.83.48]:49102 "EHLO
	mail-ee0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751099Ab3AHIgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 03:36:08 -0500
Received: by mail-ee0-f48.google.com with SMTP id b57so70858eek.7
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 00:36:06 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

While upgrading IPsec gateway, I noticed that few boxes have started to
drop packets since upgrading from 2.6.38.8 to 3.3+ kernels. Known bad
kernels are 3.3.8 and 3.4.24.

This happens with:
r8169 0000:02:00.0: eth0: RTL8168e/8111e at 0xf8318000, 00:30:18:a3:ae:e4, XID 0c200000 IRQ 68
r8169 0000:02:00.0: eth0: jumbo features [frames: 9200 bytes, tx checksumming: ko]

as well as with:
r8169 0000:02:00.0: eth0: RTL8168c/8111c at 0xf8360000, 00:30:18:a1:6e:58, XID 1c4000c0 IRQ 67

The boxes have relatively high softirq usage due to the fact that they
are forwarding data over IPsec tunnels; and the forwarded traffic
getting encrypted is done in softirq.

The symptoms include that "watch ethtool -S eth0" says rx_missed
increases in bursts. No other "dropped" stat counter is increasing.

This is happens only when the box is getting lot of traffic, is hard to
reproduce and happens only on few of the nodes. It might be also
related to specific network config: e.g. if the r8169 interfaces are
bonded or not, and if vlans are used or not.

My current hypothesis is that due to high softirq and recent(ish)
commit da78dbf "r8169: remove work from irq handler" moving more work
to softirq makes the receive path now suffer from latency from getting
irq to reading packets from the NIC on these boxes. And that at times
the rx fifo can get full causing a missed packet or so.

This might be further escalated by the bug fixed in commit 7dbb491
"r8169: avoid NAPI scheduling delay" (which is not present in -stable
trees). So my guess is that when a packet is lost it generates
RxOverflow triggering rtl_slow_event_work (but nothing is done with
this IRQ - not even printk). And this just causes the IRQs to be left
off due to the bug above - and ends up dropping a "burst" of packets.

So would it be sensible to do something like:
-#define NUM_RX_DESC    256     /* Number of Rx descriptor registers */
+#define NUM_RX_DESC    512     /* Number of Rx descriptor registers */

And cherry-picking the commit 7dbb491? Perhaps this could be pushed to
the -stable queues too.

Thanks,
 Timo
