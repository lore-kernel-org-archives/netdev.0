From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: Re: [PATCH net] net/ipv4: Use non-atomic allocation of udp offloads
 structure instance
Date: Wed, 29 Jan 2014 18:42:58 +0200
Message-ID: <52E92F92.9080307@mellanox.com>
References: <1391011739-8597-1-git-send-email-ogerlitz@mellanox.com> <1391012411.28432.55.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dan.carpenter@oracle.com>, Shlomo Pongratz <shlomop@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog114.obsmtp.com ([207.126.144.137]:46769 "EHLO
	eu1sys200aog114.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752691AbaA2QnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jan 2014 11:43:06 -0500
In-Reply-To: <1391012411.28432.55.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 29/01/2014 18:20, Eric Dumazet wrote:
> Could you also fix all the rcu_dereference() calls ?
>
> Try CONFIG_PROVE_RCU=y

Thanks Eric, I tried this out now and got one alarm on udp_add_offload, 
which I will loop up how to fix,
do you see anything else?


===============================
[ INFO: suspicious RCU usage. ]
3.13.0+ #109 Not tainted
-------------------------------
net/ipv4/udp_offload.c:112 suspicious rcu_dereference_check() usage!

other info that might help us debug this:


rcu_scheduler_active = 1, debug_locks = 0
4 locks held by kworker/2:2/2752:
  #0:  (vxlan){.+.+.+}, at: [<ffffffff8108bd5a>] 
process_one_work+0x15a/0x710
  #1:  ((&vxlan->sock_work)){+.+.+.}, at: [<ffffffff8108bd5a>] 
process_one_work+0x15a/0x710
  #2:  (&(&vn->sock_lock)->rlock){+.+...}, at: [<ffffffffa03caae3>] 
vxlan_sock_add+0x323/0xb70 [vxlan]
  #3:  (udp_offload_lock){+.+...}, at: [<ffffffff814d22e1>] 
udp_add_offload+0x41/0xd0

stack backtrace:
CPU: 2 PID: 2752 Comm: kworker/2:2 Not tainted 3.13.0+ #109
Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
Workqueue: vxlan vxlan_sock_work [vxlan]
  0000000000000001 ffff8800d1949bf8 ffffffff81528412 0000000000000002
  ffff88021ef2e060 ffff8800d1949c28 ffffffff810b8373 ffff880218f59160
  0000000000000000 ffffffff81aa3540 ffff88021dcaf000 ffff8800d1949c48
Call Trace:
  [<ffffffff81528412>] dump_stack+0x51/0x77
  [<ffffffff810b8373>] lockdep_rcu_suspicious+0x103/0x140
  [<ffffffff814d234a>] udp_add_offload+0xaa/0xd0
  [<ffffffffa03cb0ad>] vxlan_sock_add+0x8ed/0xb70 [vxlan]
  [<ffffffffa03caa77>] ? vxlan_sock_add+0x2b7/0xb70 [vxlan]
  [<ffffffffa03ce390>] ? vxlan_xmit+0x650/0x650 [vxlan]
  [<ffffffffa03cb330>] ? vxlan_sock_add+0xb70/0xb70 [vxlan]
  [<ffffffff81291f7c>] ? delay_tsc+0x6c/0xd0
  [<ffffffffa03cb439>] vxlan_sock_work+0x109/0x260 [vxlan]
  [<ffffffffa03cb330>] ? vxlan_sock_add+0xb70/0xb70 [vxlan]
  [<ffffffff8108bdd1>] process_one_work+0x1d1/0x710
  [<ffffffff8108bd5a>] ? process_one_work+0x15a/0x710
  [<ffffffff8108c432>] worker_thread+0x122/0x400
  [<ffffffff8108c310>] ? process_one_work+0x710/0x710
  [<ffffffff810943fe>] kthread+0xde/0x100
  [<ffffffff81094320>] ? __init_kthread_worker+0x70/0x70
  [<ffffffff8152f3bc>] ret_from_fork+0x7c/0xb0
  [<ffffffff81094320>] ? __init_kthread_worker+0x70/0x70
