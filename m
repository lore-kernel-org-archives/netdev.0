From: Phil Sutter <phil@nwl.cc>
Subject: NULL pointer dereference in rt6_get_cookie()
Date: Sat, 10 Oct 2015 15:24:37 +0200
Message-ID: <20151010132437.GB25926@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	Julian Anastasov <ja@ssi.bg>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([176.31.251.142]:59927 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbbJJNYk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 10 Oct 2015 09:24:40 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Linux 4.2.0 and above dereferences a NULL pointer for me when sending an
IPsec secured packet for the first time. I use kernel IPsec with racoon
and setkey. This is what my configuration looks like:

Local host: 2001:4dd0:ff3b:13::23
Remote host: 2001:4dd0:ff3b:13::5

Setkey instructions:

| # allow for ND
| spdadd ::/0 ::/0 icmp6 -P in prio def + 100 none;
| spdadd ::/0 ::/0 icmp6 -P out prio def + 100 none;
| 
| # transport mode
| spdadd 2001:4dd0:ff3b:13::23 2001:4dd0:ff3b:13::5 any -P out
|         ipsec esp/transport//require;
| spdadd 2001:4dd0:ff3b:13::5 2001:4dd0:ff3b:13::23 any -P in
|         ipsec esp/transport//require;

After booting the local system, a simple call to ping6 suffices to
trigger the bug:

| # ping6 2001:4dd0:ff3b:13::5

This is the kernel log:

| BUG: unable to handle kernel NULL pointer dereference at 00000000000000a0
| IP: [<ffffffff8171a95e>] __ip6_datagram_connect+0x71e/0xa20
| PGD c2cb1067 PUD c2d7a067 PMD 0 
| Oops: 0000 [#1] PREEMPT SMP 
| Modules linked in: cmac nfs lockd grace sunrpc bridge stp llc nvidia(PO) snd_usb_audio snd_usbmidi_lib iTCO_wdt
| CPU: 1 PID: 2964 Comm: ping6 Tainted: P           O    4.2.1-aufs #10
| Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./4Core1333-Viiv, BIOS P1.60 07/01/2008
| task: ffff8800ca62bc00 ti: ffff880129a14000 task.ti: ffff880129a14000
| RIP: 0010:[<ffffffff8171a95e>]  [<ffffffff8171a95e>] __ip6_datagram_connect+0x71e/0xa20
| RSP: 0018:ffff880129a17da8  EFLAGS: 00010296
| RAX: 000000000000000b RBX: 0000000000000000 RCX: 0000000000000006
| RDX: 0000000000000007 RSI: 0000000000000246 RDI: ffff88012fc8d5a0
| RBP: ffff8800cb9a9048 R08: 756e207369207472 R09: 216c6c756e207369
| R10: 0000000000000665 R11: 0000000000000006 R12: ffff8800cb9a8cf8
| R13: ffff8800cb9a8cf8 R14: 0000000000000000 R15: ffff8800cb9a8cc0
| FS:  00007fb76ad74700(0000) GS:ffff88012fc80000(0000) knlGS:0000000000000000
| CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
| CR2: 00000000000000a0 CR3: 00000000c2dba000 CR4: 00000000000406e0
| Stack:
|  ffff8800cb9a9048 ffff8800cb9a8de0 ffff8800cb9feb70 ffffffff816b2c41
|  00007fb70000000b ffffea0000df7200 ffff8800cb9f5cfc ffff8800cb9a8cc0
|  03fffffffe068a20 ffff8800cb9a8cc0 ffffffff817097c0 0000000100000000
| Call Trace:
|  [<ffffffff816b2c41>] ? udp_lib_get_port+0x1a1/0x380
|  [<ffffffff817097c0>] ? udpv6_rcv+0x20/0x20
|  [<ffffffff8171ac82>] ? ip6_datagram_connect+0x22/0x40
|  [<ffffffff8163ae9b>] ? SyS_connect+0x6b/0xb0
|  [<ffffffff810767ac>] ? __do_page_fault+0x15c/0x380
|  [<ffffffff8163a8d3>] ? SyS_socket+0x63/0xa0
|  [<ffffffff81741957>] ? entry_SYSCALL_64_fastpath+0x12/0x6a
| Code: ba ae 00 00 00 48 c7 c6 7b 71 94 81 48 c7 c7 63 71 94 81 e8 6c 0f 02 00 48 85 db 75 0e 48 c7 c7 9f 71 94 81 31 c0 e8 59 0f 02 00 <48> 83 bb a0 00 00 00 00 75 0e 48 c7 c7 ae 71 94 81 31 c0 e8 41 
| RIP  [<ffffffff8171a95e>] __ip6_datagram_connect+0x71e/0xa20
|  RSP <ffff880129a17da8>
| CR2: 00000000000000a0
| ---[ end trace a8591fc98c30e10f ]---
| note: ping6[2964] exited with preempt_count 1
| BUG: scheduling while atomic: ping6/2964/0x00000002
| Modules linked in: cmac nfs lockd grace sunrpc bridge stp llc nvidia(PO) snd_usb_audio snd_usbmidi_lib iTCO_wdt
| CPU: 1 PID: 2964 Comm: ping6 Tainted: P      D    O    4.2.1-aufs #10
| Hardware name: To Be Filled By O.E.M. To Be Filled By O.E.M./4Core1333-Viiv, BIOS P1.60 07/01/2008
|  0000000000000000 ffff8800ca62bc00 ffffffff8173c728 ffff88012fc940c0
|  ffffffff810f8130 0000000000000002 ffffffff8173e578 ffff8800c2d323c8
|  0000000000000202 0000000000000001 ffff880129a17a88 ffff880129a17aa8
| Call Trace:
|  [<ffffffff8173c728>] ? dump_stack+0x47/0x67
|  [<ffffffff810f8130>] ? __schedule_bug+0x40/0x50
|  [<ffffffff8173e578>] ? __schedule+0x6d8/0x830
|  [<ffffffff8173e701>] ? schedule+0x31/0x80
|  [<ffffffff8163cec4>] ? __lock_sock+0x64/0x90
|  [<ffffffff8110b9d0>] ? wait_woken+0x80/0x80
|  [<ffffffff8163cf3a>] ? lock_sock_nested+0x4a/0x50
|  [<ffffffff8170bb1b>] ? udpv6_destroy_sock+0xb/0x50
|  [<ffffffff8163eb28>] ? sk_common_release+0x18/0xf0
|  [<ffffffff816be618>] ? inet_release+0x38/0x60
|  [<ffffffff81639499>] ? sock_release+0x19/0x80
|  [<ffffffff8163950d>] ? sock_close+0xd/0x20
|  [<ffffffff811bdadf>] ? __fput+0x8f/0x1d0
|  [<ffffffff810f2bb5>] ? task_work_run+0x95/0xb0
|  [<ffffffff810ddff7>] ? do_exit+0x357/0x9f0
|  [<ffffffff81041fb6>] ? oops_end+0x66/0x90
|  [<ffffffff81076058>] ? no_context+0x128/0x350
|  [<ffffffff81118594>] ? wake_up_klogd+0x34/0x50
|  [<ffffffff81742f82>] ? page_fault+0x22/0x30
|  [<ffffffff8171a95e>] ? __ip6_datagram_connect+0x71e/0xa20
|  [<ffffffff8171a95e>] ? __ip6_datagram_connect+0x71e/0xa20
|  [<ffffffff816b2c41>] ? udp_lib_get_port+0x1a1/0x380
|  [<ffffffff817097c0>] ? udpv6_rcv+0x20/0x20
|  [<ffffffff8171ac82>] ? ip6_datagram_connect+0x22/0x40
|  [<ffffffff8163ae9b>] ? SyS_connect+0x6b/0xb0
|  [<ffffffff810767ac>] ? __do_page_fault+0x15c/0x380
|  [<ffffffff8163a8d3>] ? SyS_socket+0x63/0xa0
|  [<ffffffff81741957>] ? entry_SYSCALL_64_fastpath+0x12/0x6a

I assume the second BUG is just a follow-up and therefore not
interesting. Using printk-debugging I could track down the problem to
rt6_get_cookie() function in include/net/ip6_fib.h:

The conditional at the start of the function evaluates true, since
'rt->rt6i_flags & RTF_PCPU' is non-zero. Due to that, 'rt' pointer is
reassigned:

| rt = (struct rt6_info *)(rt->dst.from);

It appears that this effectively assigns NULL to it, and the following
dereference causes the bug. This seems to be the culprit change:

| commit d52d3997f843ffefaa8d8462790ffcaca6c74192
| Author: Martin KaFai Lau <kafai@fb.com>
| Date:   Fri May 22 20:56:06 2015 -0700
| 
|     ipv6: Create percpu rt6_info
|     
|     After the patch
|     'ipv6: Only create RTF_CACHE routes after encountering pmtu exception',
|     we need to compensate the performance hit (bouncing dst->__refcnt).
|     
|     Signed-off-by: Martin KaFai Lau <kafai@fb.com>
|     Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
|     Cc: Steffen Klassert <steffen.klassert@secunet.com>
|     Cc: Julian Anastasov <ja@ssi.bg>
|     Signed-off-by: David S. Miller <davem@davemloft.net>

Kernel version 4.1.9 and below is not affected (the above commit exists
only in versions 4.2.0 and above).

Feel free to send me patches for testing, reproducing the problem is no
big deal for me.

Cheers, Phil
