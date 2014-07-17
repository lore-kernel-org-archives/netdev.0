From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: /proc/net/sockstat invalid memory accounting or memory leak in
 latest =?UTF-8?Q?kernels=3F?=
Date: Thu, 17 Jul 2014 13:52:42 +0300
Message-ID: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:37686 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755709AbaGQK6E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 06:58:04 -0400
Received: from hosting.visp.net.lb (localhost [127.0.0.1])
	by hosting.visp.net.lb (Postfix) with ESMTP id E9338480D51
	for <netdev@vger.kernel.org>; Thu, 17 Jul 2014 13:52:42 +0300 (EEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I noticed TCP transfer rate slowdown after few days of operation on 
kernel 3.15.3, after some digging found out this:

balancer-backup ~ # cat /proc/net/sockstat
sockets: used 118236
TCP: inuse 122958 orphan 4986 tw 108010 alloc 123179 mem 1955339
UDP: inuse 1 mem 0
UDPLITE: inuse 0
RAW: inuse 0
FRAG: inuse 1 memory 2

after shutting down program
balancer-backup ~ # cat /proc/net/sockstat
sockets: used 47
TCP: inuse 10552 orphan 10547 tw 142645 alloc 10552 mem 1877061
UDP: inuse 0 mem 0
UDPLITE: inuse 0
RAW: inuse 0
FRAG: inuse 0 memory 0

sysctl settings:
net.ipv4.tcp_mem = 1767103      2045612 3068412

I restarted recently process, and mem value didnt changed (while because 
it is sockets should release all memory), also it looks incorrect, 
because at same time:
balancer-backup ~ # cat /proc/meminfo
MemTotal:       32939492 kB
MemFree:        29876564 kB

While 1955339 * 4096 should be around 8GB.
Probably it is just accounting issue or is it real memory leak?
What other info i can provide to troubleshoot this info more properly?
I will upgrade to 3.15.5 also now, to see if issue persist there.

Also i noticed several warnings:
[1116634.378936] ------------[ cut here ]------------
[1116634.379169] WARNING: CPU: 0 PID: 28350 at net/core/stream.c:201 
sk_stream_kill_queues+0xff/0x104()
[1116634.379606] Modules linked in: microcode xt_tcpudp xt_mark 
iptable_mangle ip_tables x_tables 8021q garp stp mrp llc
[1116634.380069] CPU: 0 PID: 28350 Comm: haproxy Tainted: G        W     
3.15.3-build-0007 #2
[1116634.380492] Hardware name: Dell Inc. PowerEdge R710/0HYPX2, BIOS 
2.0.11 02/26/2010
[1116634.380921]  0000000000000000 ffff880778393db0 ffffffff8160042b 
0000000000000000
[1116634.381352]  ffff880778393de8 ffffffff810b4e03 ffffffff81584db2 
ffff8807e4df9380
[1116634.381780]  ffff8807e4df94c8 0000000000000007 ffff8807e4df93f0 
ffff880778393df8
[1116634.382212] Call Trace:
[1116634.382440]  [<ffffffff8160042b>] dump_stack+0x45/0x56
[1116634.382659]  [<ffffffff810b4e03>] warn_slowpath_common+0x75/0x8e
[1116634.382871]  [<ffffffff81584db2>] ? 
sk_stream_kill_queues+0xff/0x104
[1116634.383087]  [<ffffffff810b4ebb>] warn_slowpath_null+0x15/0x17
[1116634.383308]  [<ffffffff81584db2>] sk_stream_kill_queues+0xff/0x104
[1116634.383522]  [<ffffffff815bf066>] inet_csk_destroy_sock+0x77/0xb7
[1116634.383741]  [<ffffffff815c31c1>] tcp_close+0x287/0x37a
[1116634.383953]  [<ffffffff815e03d5>] inet_release+0x6f/0x76
[1116634.384167]  [<ffffffff81578bfe>] sock_release+0x1a/0x79
[1116634.384379]  [<ffffffff81578c6a>] sock_close+0xd/0x11
[1116634.384600]  [<ffffffff8115750e>] __fput+0xdc/0x18d
[1116634.384826]  [<ffffffff811575eb>] ____fput+0x9/0xb
[1116634.385052]  [<ffffffff810ca5e2>] task_work_run+0x78/0x8e
[1116634.385276]  [<ffffffff81002880>] do_notify_resume+0x52/0x60
[1116634.385504]  [<ffffffff81606970>] int_signal+0x12/0x17
[1116634.385728] ---[ end trace fb11499084e23ab6 ]---
[1116634.386531] ------------[ cut here ]------------
[1116634.386792] WARNING: CPU: 0 PID: 28350 at net/ipv4/af_inet.c:153 
inet_sock_destruct+0x160/0x189()
[1116634.387264] Modules linked in: microcode xt_tcpudp xt_mark 
iptable_mangle ip_tables x_tables 8021q garp stp mrp llc
[1116634.387781] CPU: 0 PID: 28350 Comm: haproxy Tainted: G        W     
3.15.3-build-0007 #2
[1116634.388236] Hardware name: Dell Inc. PowerEdge R710/0HYPX2, BIOS 
2.0.11 02/26/2010
[1116634.388680]  0000000000000000 ffff880778393d98 ffffffff8160042b 
0000000000000000
[1116634.389157]  ffff880778393dd0 ffffffff810b4e03 ffffffff815e00d7 
ffff8807e4df9380
[1116634.389602]  ffff8807e4df94c8 0000000000000007 ffff8807e4df93f0 
ffff880778393de0
[1116634.390046] Call Trace:
[1116634.390270]  [<ffffffff8160042b>] dump_stack+0x45/0x56
[1116634.390499]  [<ffffffff810b4e03>] warn_slowpath_common+0x75/0x8e
[1116634.390742]  [<ffffffff815e00d7>] ? inet_sock_destruct+0x160/0x189
[1116634.390979]  [<ffffffff810b4ebb>] warn_slowpath_null+0x15/0x17
[1116634.391221]  [<ffffffff815e00d7>] inet_sock_destruct+0x160/0x189
[1116634.391457]  [<ffffffff8157ca3a>] __sk_free+0x18/0xd5
[1116634.391688]  [<ffffffff8157cb0a>] sk_free+0x13/0x15
[1116634.391927]  [<ffffffff815c32a8>] tcp_close+0x36e/0x37a
[1116634.392141]  [<ffffffff815e03d5>] inet_release+0x6f/0x76
[1116634.392484]  [<ffffffff81578bfe>] sock_release+0x1a/0x79
[1116634.392774]  [<ffffffff81578c6a>] sock_close+0xd/0x11
[1116634.392996]  [<ffffffff8115750e>] __fput+0xdc/0x18d
[1116634.393226]  [<ffffffff811575eb>] ____fput+0x9/0xb
[1116634.393450]  [<ffffffff810ca5e2>] task_work_run+0x78/0x8e
[1116634.393696]  [<ffffffff81002880>] do_notify_resume+0x52/0x60
[1116634.393935]  [<ffffffff81606970>] int_signal+0x12/0x17
[1116634.394159] ---[ end trace fb11499084e23ab7 ]---

P.S. After restarting server and around 5 minutes of operation:
sockets: used 109439
TCP: inuse 110642 orphan 1372 tw 98904 alloc 110768 mem 215254
UDP: inuse 1 mem 0
UDPLITE: inuse 0
RAW: inuse 0
FRAG: inuse 0 memory 0
