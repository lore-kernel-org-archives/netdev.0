From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] netns: correct gfp flags for alloc_netid()
Date: Thu, 26 Feb 2015 16:54:50 -0800
Message-ID: <1424998490-9565-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:45765 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753862AbbB0Ay5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 19:54:57 -0500
Received: by pdjz10 with SMTP id z10so16919665pdj.12
        for <netdev@vger.kernel.org>; Thu, 26 Feb 2015 16:54:57 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes the following kernel warning:

 ===============================
 [ INFO: suspicious RCU usage. ]
 3.19.0+ #805 Tainted: G        W      
 -------------------------------
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

Fixes: commit 0c7aecd4bde4b7302 ("netns: add rtnl cmd to add and get peer netns ids")
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

---
diff --git a/net/core/net_namespace.c b/net/core/net_namespace.c
index cb5290b..ecf8e70 100644
--- a/net/core/net_namespace.c
+++ b/net/core/net_namespace.c
@@ -148,7 +148,8 @@ static void ops_free_list(const struct pernet_operations *ops,
 	}
 }
 
-static int alloc_netid(struct net *net, struct net *peer, int reqid)
+static int alloc_netid(struct net *net, struct net *peer, int reqid,
+		       gfp_t flags)
 {
 	int min = 0, max = 0;
 
@@ -159,7 +160,7 @@ static int alloc_netid(struct net *net, struct net *peer, int reqid)
 		max = reqid + 1;
 	}
 
-	return idr_alloc(&net->netns_ids, peer, min, max, GFP_KERNEL);
+	return idr_alloc(&net->netns_ids, peer, min, max, flags);
 }
 
 /* This function is used by idr_for_each(). If net is equal to peer, the
@@ -188,7 +189,7 @@ static int __peernet2id(struct net *net, struct net *peer, bool alloc)
 		return id;
 
 	if (alloc)
-		return alloc_netid(net, peer, -1);
+		return alloc_netid(net, peer, -1, GFP_ATOMIC);
 
 	return -ENOENT;
 }
@@ -524,7 +525,7 @@ static int rtnl_net_newid(struct sk_buff *skb, struct nlmsghdr *nlh)
 		goto out;
 	}
 
-	err = alloc_netid(net, peer, nsid);
+	err = alloc_netid(net, peer, nsid, GFP_KERNEL);
 	if (err > 0)
 		err = 0;
 out:
