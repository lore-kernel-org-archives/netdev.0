From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH] netlink: fix for too early rmmod
Date: Sat, 30 Jan 2010 22:05:05 +0200
Message-ID: <20100130200505.GA5318@x200>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kaber@trash.net, kuznet@ms2.inr.ac.ru
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:39566 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752196Ab0A3UFM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Jan 2010 15:05:12 -0500
Received: by fxm20 with SMTP id 20so2989430fxm.21
        for <netdev@vger.kernel.org>; Sat, 30 Jan 2010 12:05:10 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Netlink code does module autoload if protocol userspace is asking for is
not ready. However, module can dissapear right after it was autoloaded.
Example: modprobe/rmmod stress-testing and xfrm_user.ko providing NETLINK_XFRM.

netlink_create() in such situation _will_ create userspace socket and
_will_not_ pin module. Now if module was removed and we're going to call
->netlink_rcv into nothing:

BUG: unable to handle kernel paging request at ffffffffa02f842a
					       ^^^^^^^^^^^^^^^^
	modules are loaded near these addresses here

IP: [<ffffffffa02f842a>] 0xffffffffa02f842a
PGD 161f067 PUD 1623063 PMD baa12067 PTE 0
Oops: 0010 [#1] PREEMPT SMP DEBUG_PAGEALLOC
last sysfs file: /sys/devices/pci0000:00/0000:00:1f.2/host0/target0:0:0/0:0:0:0/block/sda/uevent
CPU 1 
Pid: 11515, comm: ip Not tainted 2.6.33-rc5-netns-00594-gaaa5728-dirty #6 P5E/P5E
RIP: 0010:[<ffffffffa02f842a>]  [<ffffffffa02f842a>] 0xffffffffa02f842a
RSP: 0018:ffff8800baa3db48  EFLAGS: 00010292
RAX: ffff8800baa3dfd8 RBX: ffff8800be353640 RCX: 0000000000000000
RDX: ffffffff81959380 RSI: ffff8800bab7f130 RDI: 0000000000000001
RBP: ffff8800baa3db58 R08: 0000000000000001 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000001 R12: 0000000000000011
R13: ffff8800be353640 R14: ffff8800bcdec240 R15: ffff8800bd488010
FS:  00007f93749656f0(0000) GS:ffff880002300000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: ffffffffa02f842a CR3: 00000000ba82b000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process ip (pid: 11515, threadinfo ffff8800baa3c000, task ffff8800bab7eb30)
Stack:
 ffffffff813637c0 ffff8800bd488000 ffff8800baa3dba8 ffffffff8136397d
<0> 0000000000000000 ffffffff81344adc 7fffffffffffffff 0000000000000000
<0> ffff8800baa3ded8 ffff8800be353640 ffff8800bcdec240 0000000000000000
Call Trace:
 [<ffffffff813637c0>] ? netlink_unicast+0x100/0x2d0
 [<ffffffff8136397d>] netlink_unicast+0x2bd/0x2d0

	netlink_unicast_kernel:
		nlk->netlink_rcv(skb);

 [<ffffffff81344adc>] ? memcpy_fromiovec+0x6c/0x90
 [<ffffffff81364263>] netlink_sendmsg+0x1d3/0x2d0
 [<ffffffff8133975b>] sock_sendmsg+0xbb/0xf0
 [<ffffffff8106cdeb>] ? __lock_acquire+0x27b/0xa60
 [<ffffffff810a18c3>] ? might_fault+0x73/0xd0
 [<ffffffff810a18c3>] ? might_fault+0x73/0xd0
 [<ffffffff8106db22>] ? __lock_release+0x82/0x170
 [<ffffffff810a190e>] ? might_fault+0xbe/0xd0
 [<ffffffff810a18c3>] ? might_fault+0x73/0xd0
 [<ffffffff81344c77>] ? verify_iovec+0x47/0xd0
 [<ffffffff8133a509>] sys_sendmsg+0x1a9/0x360
 [<ffffffff813c2be5>] ? _raw_spin_unlock_irqrestore+0x65/0x70
 [<ffffffff8106aced>] ? trace_hardirqs_on+0xd/0x10
 [<ffffffff813c2bc2>] ? _raw_spin_unlock_irqrestore+0x42/0x70
 [<ffffffff81197004>] ? __up_read+0x84/0xb0
 [<ffffffff8106ac95>] ? trace_hardirqs_on_caller+0x145/0x190
 [<ffffffff813c207f>] ? trace_hardirqs_on_thunk+0x3a/0x3f
 [<ffffffff8100262b>] system_call_fastpath+0x16/0x1b
Code:  Bad RIP value.
RIP  [<ffffffffa02f842a>] 0xffffffffa02f842a
 RSP <ffff8800baa3db48>
CR2: ffffffffa02f842a

If module was quickly removed after autoloading, return -E.

Return -EPROTONOSUPPORT if module was quickly removed after autoloading.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---

	NOTE: due to commit 513c25000005257e5474f261bf27d4a3c1dff1e3
	"[NETLINK]: Don't prevent creating sockets when no kernel socket is registered"
	error should probably be -ENOENT, but I have no idea what this
	pam-audit thing is.

 net/netlink/af_netlink.c |    5 +++++
 1 file changed, 5 insertions(+)

--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -455,9 +455,14 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	if (nl_table[protocol].registered &&
 	    try_module_get(nl_table[protocol].module))
 		module = nl_table[protocol].module;
+	else
+		err = -EPROTONOSUPPORT;
 	cb_mutex = nl_table[protocol].cb_mutex;
 	netlink_unlock_table();
 
+	if (err < 0)
+		goto out;
+
 	err = __netlink_create(net, sock, cb_mutex, protocol);
 	if (err < 0)
 		goto out_module;
