From: Tomasz Mloduchowski <q@qdot.me>
Subject: TCP out of memory - possible bug [3.18.0-rc3] / sched?
Date: Mon, 03 Nov 2014 19:59:33 +0100
Message-ID: <5457D095.9070502@qdot.me>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f41.google.com ([74.125.82.41]:60753 "EHLO
	mail-wg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752329AbaKCTAV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2014 14:00:21 -0500
Received: by mail-wg0-f41.google.com with SMTP id k14so11835722wgh.14
        for <netdev@vger.kernel.org>; Mon, 03 Nov 2014 11:00:20 -0800 (PST)
Received: from [192.168.15.126] (my83-216-94-251.cust.relish.net. [83.216.94.251])
        by mx.google.com with ESMTPSA id q10sm23128711wjq.35.2014.11.03.11.00.19
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 03 Nov 2014 11:00:19 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi List,

I hope this is the right place to report a networking issue with
3.18.0-rc2 and 3.18.0-rc3 - under heavy P2P load (tested both
rtorrent/libtorrent and bitcoind, so not protocol-specific), the system
quickly exhausts tcp_mem limits in a very strange sequence of events.

It might be scheduler or networking subsystem related.

It's 100% reproducible on my system, first observed under 3.18.0-rc2.

Neither terminating the offending application, nor removing the network
card seems to bring the 'mem' item in /proc/net/sockstat down from it's
extreme values.

http://static.qdot.me/tcp_mem_issue.png contains the plot of the 'mem'
and 'sockets' fields from sockstat - violet is the 'mem', quickly
exhausting the default 512k pages limit after a short period of reliable
operation.


Best Regards,
Tomasz

-- snip --

sched: RT throttling activated
kworker/dying (792) used greatest stack depth: 11984 bytes left
TCP: out of memory -- consider tuning tcp_mem
TCP: out of memory -- consider tuning tcp_mem
------------[ cut here ]------------
WARNING: CPU: 0 PID: 5802 at net/core/stream.c:201
sk_stream_kill_queues+0x12c/0x130()
Modules linked in:
CPU: 0 PID: 5802 Comm: main Not tainted 3.18.0-rc3 #2
Hardware name: LENOVO 37023L0/37023L0, BIOS GFET48WW (1.27 ) 07/01/2014
 0000000000000009 ffff8800cae2fd88 ffffffff81b6c0ff 0000000000000000
 0000000000000000 ffff8800cae2fdc8 ffffffff810c235c ffff8800cae2fda8
 ffff8800bd996580 ffff8800bd996700 0000000000000004 ffff8800bd996610
Call Trace:
 [<ffffffff81b6c0ff>] dump_stack+0x46/0x58
 [<ffffffff810c235c>] warn_slowpath_common+0x7c/0xa0
 [<ffffffff810c2425>] warn_slowpath_null+0x15/0x20
 [<ffffffff81954fbc>] sk_stream_kill_queues+0x12c/0x130
 [<ffffffff819b8b45>] inet_csk_destroy_sock+0x55/0x140
 [<ffffffff819bd9ee>] tcp_close+0x22e/0x430
 [<ffffffff819e3b82>] inet_release+0x72/0x80
 [<ffffffff819455fa>] sock_release+0x1a/0x90
 [<ffffffff8194567d>] sock_close+0xd/0x20
 [<ffffffff811dfdf6>] __fput+0xc6/0x1d0
 [<ffffffff811dff49>] ____fput+0x9/0x10
 [<ffffffff810db94f>] task_work_run+0x8f/0xd0
 [<ffffffff81046b12>] do_notify_resume+0x82/0xa0
 [<ffffffff81b7613f>] int_signal+0x12/0x17
---[ end trace 080b1124407d2571 ]---
------------[ cut here ]------------
WARNING: CPU: 0 PID: 5802 at net/ipv4/af_inet.c:153
inet_sock_destruct+0x1d9/0x1e0()
Modules linked in:
CPU: 0 PID: 5802 Comm: main Tainted: G        W      3.18.0-rc3 #2
Hardware name: LENOVO 37023L0/37023L0, BIOS GFET48WW (1.27 ) 07/01/2014
 0000000000000009 ffff8800cae2fd68 ffffffff81b6c0ff 0000000000000000
 0000000000000000 ffff8800cae2fda8 ffffffff810c235c ffff8800cae2fd88
 ffff8800bd996580 ffff8800bd996700 0000000000000004 ffff8800bd996610
Call Trace:
 [<ffffffff81b6c0ff>] dump_stack+0x46/0x58
 [<ffffffff810c235c>] warn_slowpath_common+0x7c/0xa0
 [<ffffffff810c2425>] warn_slowpath_null+0x15/0x20
 [<ffffffff819e5179>] inet_sock_destruct+0x1d9/0x1e0
 [<ffffffff81949e7e>] __sk_free+0x1e/0x100
 [<ffffffff81949f79>] sk_free+0x19/0x20
 [<ffffffff819bd918>] tcp_close+0x158/0x430
 [<ffffffff819e3b82>] inet_release+0x72/0x80
 [<ffffffff819455fa>] sock_release+0x1a/0x90
 [<ffffffff8194567d>] sock_close+0xd/0x20
 [<ffffffff811dfdf6>] __fput+0xc6/0x1d0
 [<ffffffff811dff49>] ____fput+0x9/0x10
 [<ffffffff810db94f>] task_work_run+0x8f/0xd0
 [<ffffffff81046b12>] do_notify_resume+0x82/0xa0
 [<ffffffff81b7613f>] int_signal+0x12/0x17
---[ end trace 080b1124407d2572 ]---
kworker/dying (679) used greatest stack depth: 11784 bytes left
TCP: out of memory -- consider tuning tcp_mem

-- snip --
