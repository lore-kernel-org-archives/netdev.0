From: Koki Sanagi <sanagi.koki@jp.fujitsu.com>
Subject: [RFC PATCH 0/2] netdev: implement a buffer to log network driver's
 information
Date: Mon, 05 Apr 2010 15:50:16 +0900
Message-ID: <4BB98828.5030302@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: izumi.taku@jp.fujitsu.com, kaneshige.kenji@jp.fujitsu.com,
	davem@davemloft.net, nhorman@tuxdriver.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	bruce.w.allan@intel.com, alexander.h.duyck@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:51286 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818Ab0DEGuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Apr 2010 02:50:19 -0400
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o356oHsN010440
	for <netdev@vger.kernel.org> (envelope-from sanagi.koki@jp.fujitsu.com);
	Mon, 5 Apr 2010 15:50:17 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 794CE45DE70
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:50:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3769645DE4D
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:50:17 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 049871DB803B
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:50:17 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 86CFCE18003
	for <netdev@vger.kernel.org>; Mon,  5 Apr 2010 15:50:16 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch implements a buffer for recording network driver's message.
This patch extends below patch to make other network driver use it.

http://marc.info/?l=e1000-devel&m=126690500618157&w=2

When I investigate some network driver's trouble, I feel like I want more
detailed debug information, for example, all device register information
(like ethtool -d) when device reset was happened or tx/rx ring's move when
network stream is not smooth etc.
As a recording measure of such information, there are syslog and ftrace now.
but they have some weak points.
Syslog is not appropriate for the size of message is large(ex. recording
all register information) or the number of is large(ex.tracing internal move).
Ftrace is appropriate for recording such messages.
But ftrace has only one buffer for all ftrace event in kernel. As a result,
one adapter's event may be flushed by the others(Of course, syslog has same
weak point).

This patch implements a buffer system which beats those weak points.

Features of that are

1.Each interface can hold respective buffer.
     It prevents recorded data from being flowed by other's recorded data.

2.An interface can hold multi-buffers.
     It makes one adapter have several buffer for each different purpose.
     For example, one is to trace a driver's internal move, the another is to
     log error message and some releveant information.

3.resize and on/off per buffer.
     if you implement this patch's buffer and you regist buffer in driver's
	probe function, all adapter which use that driver must have same size
     buffer. If you want trace to one adapter, but not to another, you can make
     another adapter's buffer off.

The implementation example of igb is patch 2.

HOW TO USE:

If you want to know how to use from driver side, see patch 2.
User side is below.

# mount -t debugfs nodev /sys/kernel/debug
# ls /sys/kernel/debug/ndrvbuf
igb-trace-0000:03:00.0 igb-trace-0000:03:00.1
# ls /sys/kernel/debug/ndrvbuf/igb-trace-0000:03:00.0
buffer  buffer_size

"buffer" is output interface. If you set read_format function in
register_ndrvbuf, it is used. If not, default read function is used.
It displays recorded data by hex style.

# cat buffer
[  1] 50462.369207: clean_tx qidx=1 ntu=154->156
[  0] 50462.369241: clean_rx qidx=0 ntu=111->112
[  0] 50462.369250: xmit qidx=1 ntu=156->158
[  1] 50462.369256: clean_tx qidx=1 ntu=156->158
[  1] 50462.369342: clean_rx qidx=0 ntu=113->114
[  1] 50462.369439: clean_rx qidx=0 ntu=114->115

"buffer_size" is size of buffer per CPU. If you want to change that,
# echo 1000000 > buffer_size
# cat buffer_size
1000000

If you want to disable recording,
# echo 0 > buffer_size

Thanks,
Koki Sanagi.

