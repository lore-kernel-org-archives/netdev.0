From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: [-next] fib_dump_info() suspicious RCU usage
Date: Fri, 26 Jun 2015 18:35:40 +0900
Message-ID: <20150626093540.GA4989@swordfish>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dinesh Dutt <ddutt@cumulusnetworks.com>,
	Scott Feldman <sfeldma@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andy Gospodarek <gospo@cumulusnetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Since 0eeb075fad736 ('net: ipv4 sysctl option to ignore routes when nexthop
link is down') fib_dump_info() and fib_sync_up() are using __in_dev_get_rcu(),
which requires (missing) RCU read side protection.


[   60.605034] ===============================
[   60.605035] [ INFO: suspicious RCU usage. ]
[   60.605037] 4.1.0-next-20150626-dbg-00020-g54a6d91-dirty #244 Not tainted
[   60.605038] -------------------------------
[   60.605040] include/linux/inetdevice.h:205 suspicious rcu_dereference_check() usage!
[   60.605041] 
               other info that might help us debug this:

[   60.605043] 
               rcu_scheduler_active = 1, debug_locks = 0
[   60.605045] 2 locks held by ip/403:
[   60.605046]  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff81453305>] rtnl_lock+0x17/0x19
[   60.605054]  #1:  ((inetaddr_chain).rwsem){.+.+.+}, at: [<ffffffff8105c327>] __blocking_notifier_call_chain+0x35/0x6a
[   60.605060] 
               stack backtrace:
[   60.605062] CPU: 2 PID: 403 Comm: ip Not tainted 4.1.0-next-20150626-dbg-00020-g54a6d91-dirty #244
[   60.605066]  0000000000000001 ffff8800b189b728 ffffffff8150a542 ffffffff8107a8b3
[   60.605069]  ffff880037bbea40 ffff8800b189b758 ffffffff8107cb74 ffff8800379dbd00
[   60.605071]  ffff8800bec85800 ffff8800bf9e13c0 00000000000000ff ffff8800b189b7d8
[   60.605074] Call Trace:
[   60.605078]  [<ffffffff8150a542>] dump_stack+0x4c/0x6e
[   60.605081]  [<ffffffff8107a8b3>] ? up+0x39/0x3e
[   60.605084]  [<ffffffff8107cb74>] lockdep_rcu_suspicious+0xf7/0x100
[   60.605088]  [<ffffffff814b63c3>] fib_dump_info+0x227/0x3e2
[   60.605090]  [<ffffffff814b6624>] rtmsg_fib+0xa6/0x116
[   60.605093]  [<ffffffff814b978f>] fib_table_insert+0x316/0x355
[   60.605095]  [<ffffffff814b362e>] fib_magic+0xb7/0xc7
[   60.605098]  [<ffffffff814b4803>] fib_add_ifaddr+0xb1/0x13b
[   60.605100]  [<ffffffff814b4d09>] fib_inetaddr_event+0x36/0x90
[   60.605102]  [<ffffffff8105c086>] notifier_call_chain+0x4c/0x71
[   60.605104]  [<ffffffff8105c340>] __blocking_notifier_call_chain+0x4e/0x6a
[   60.605106]  [<ffffffff8105c370>] blocking_notifier_call_chain+0x14/0x16
[   60.605108]  [<ffffffff814a7f50>] __inet_insert_ifa+0x1a5/0x1b3
[   60.605110]  [<ffffffff814a894d>] inet_rtm_newaddr+0x350/0x35f
[   60.605113]  [<ffffffff81457866>] rtnetlink_rcv_msg+0x17b/0x18a
[   60.605115]  [<ffffffff8107e7c3>] ? trace_hardirqs_on+0xd/0xf
[   60.605118]  [<ffffffff8146965f>] ? netlink_deliver_tap+0x1cb/0x1f7
[   60.605120]  [<ffffffff814576eb>] ? rtnl_newlink+0x72a/0x72a
[   60.605122]  [<ffffffff8146d299>] netlink_rcv_skb+0x48/0x8a
[   60.605124]  [<ffffffff81455724>] rtnetlink_rcv+0x26/0x2d
[   60.605126]  [<ffffffff8146cb53>] netlink_unicast+0xc6/0x145
[   60.605128]  [<ffffffff8146d144>] netlink_sendmsg+0x4c9/0x4e0
[   60.605131]  [<ffffffff81247a09>] ? import_iovec+0x67/0x89
[   60.605134]  [<ffffffff8142adaf>] sock_sendmsg+0x14/0x1f
[   60.605136]  [<ffffffff8142b38d>] ___sys_sendmsg+0x16a/0x1f1
[   60.605140]  [<ffffffff81119923>] ? handle_mm_fault+0x9dd/0xe17
[   60.605142]  [<ffffffff81119923>] ? handle_mm_fault+0x9dd/0xe17
[   60.605144]  [<ffffffff81119923>] ? handle_mm_fault+0x9dd/0xe17
[   60.605146]  [<ffffffff8107bcbc>] ? __lock_is_held+0x3c/0x57
[   60.605149]  [<ffffffff81158da8>] ? __fget_light+0x50/0x75
[   60.605151]  [<ffffffff8142c1e0>] __sys_sendmsg+0x42/0x63
[   60.605154]  [<ffffffff8142c20f>] SyS_sendmsg+0xe/0x10
[   60.605156]  [<ffffffff81510fd7>] entry_SYSCALL_64_fastpath+0x12/0x6f

	-ss
