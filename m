From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net] net: do not use rcu in rtnl_dump_ifinfo()
Date: Fri, 27 Feb 2015 09:42:50 -0800
Message-ID: <1425058970.5130.32.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F09A95.8000507@6wind.com>
	 <1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com, Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f169.google.com ([209.85.213.169]:36931 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752470AbbB0Rmw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 12:42:52 -0500
Received: by igbhn18 with SMTP id hn18so2250687igb.2
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 09:42:52 -0800 (PST)
In-Reply-To: <1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

We did a failed attempt in the past to only use rcu in rtnl dump
operations (commit e67f88dd12f6 "net: dont hold rtnl mutex during
netlink dump callbacks")

Now that dumps are holding RTNL anyway, there is no need to also
use rcu locking, as it forbids any scheduling ability, like
GFP_KERNEL allocations that controlling path should use instead
of GFP_ATOMIC whenever possible.

This should fix following splat Cong Wang reported :

 [ INFO: suspicious RCU usage. ]
 3.19.0+ #805 Tainted: G        W      

 include/linux/rcupdate.h:538 Illegal context switch in RCU read-side critical section!
 
 other info that might help us debug this:
 
 
 rcu_scheduler_active = 1, debug_locks = 0
 2 locks held by ip/771:
  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff8182b8f4>] netlink_dump+0x21/0x26c
  #1:  (rcu_read_lock){......}, at: [<ffffffff817d785b>] rcu_read_lock+0x0/0x6e
 
 stack backtrace:
 CPU: 3 PID: 771 Comm: ip Tainted: G        W       3.19.0+ #805
 Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
  0000000000000001 ffff8800d51e7718 ffffffff81a27457 0000000029e729e6
  ffff8800d6108000 ffff8800d51e7748 ffffffff810b539b ffffffff820013dd
  00000000000001c8 0000000000000000 ffff8800d7448088 ffff8800d51e7758
 Call Trace:
  [<ffffffff81a27457>] dump_stack+0x4c/0x65
  [<ffffffff810b539b>] lockdep_rcu_suspicious+0x107/0x110
  [<ffffffff8109796f>] rcu_preempt_sleep_check+0x45/0x47
  [<ffffffff8109e457>] ___might_sleep+0x1d/0x1cb
  [<ffffffff8109e67d>] __might_sleep+0x78/0x80
  [<ffffffff814b9b1f>] idr_alloc+0x45/0xd1
  [<ffffffff810cb7ab>] ? rcu_read_lock_held+0x3b/0x3d
  [<ffffffff814b9f9d>] ? idr_for_each+0x53/0x101
  [<ffffffff817c1383>] alloc_netid+0x61/0x69
  [<ffffffff817c14c3>] __peernet2id+0x79/0x8d
  [<ffffffff817c1ab7>] peernet2id+0x13/0x1f
  [<ffffffff817d8673>] rtnl_fill_ifinfo+0xa8d/0xc20
  [<ffffffff810b17d9>] ? __lock_is_held+0x39/0x52
  [<ffffffff817d894f>] rtnl_dump_ifinfo+0x149/0x213
  [<ffffffff8182b9c2>] netlink_dump+0xef/0x26c
  [<ffffffff8182bcba>] netlink_recvmsg+0x17b/0x2c5
  [<ffffffff817b0adc>] __sock_recvmsg+0x4e/0x59
  [<ffffffff817b1b40>] sock_recvmsg+0x3f/0x51
  [<ffffffff817b1f9a>] ___sys_recvmsg+0xf6/0x1d9
  [<ffffffff8115dc67>] ? handle_pte_fault+0x6e1/0xd3d
  [<ffffffff8100a3a0>] ? native_sched_clock+0x35/0x37
  [<ffffffff8109f45b>] ? sched_clock_local+0x12/0x72
  [<ffffffff8109f6ac>] ? sched_clock_cpu+0x9e/0xb7
  [<ffffffff810cb7ab>] ? rcu_read_lock_held+0x3b/0x3d
  [<ffffffff811abde8>] ? __fcheck_files+0x4c/0x58
  [<ffffffff811ac556>] ? __fget_light+0x2d/0x52
  [<ffffffff817b376f>] __sys_recvmsg+0x42/0x60
  [<ffffffff817b379f>] SyS_recvmsg+0x12/0x1c

Signed-off-by: Eric Dumazet <edumazet@google.com>
Fixes: commit 0c7aecd4bde4b7302 ("netns: add rtnl cmd to add and get peer netns ids")
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Reported-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 v2: As suggested by Daniel, tweak the changelog to be patchwork compliant ;)

 net/core/rtnetlink.c |    4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 1385de0fa080..74ce25d2cded 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1300,7 +1300,6 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	s_h = cb->args[0];
 	s_idx = cb->args[1];
 
-	rcu_read_lock();
 	cb->seq = net->dev_base_seq;
 
 	/* A hack to preserve kernel<->userspace interface.
@@ -1322,7 +1321,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, struct netlink_callback *cb)
 	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
 		idx = 0;
 		head = &net->dev_index_head[h];
-		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+		hlist_for_each_entry(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
 			err = rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
@@ -1344,7 +1343,6 @@ cont:
 		}
 	}
 out:
-	rcu_read_unlock();
 	cb->args[1] = idx;
 	cb->args[0] = h;
 
