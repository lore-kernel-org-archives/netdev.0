From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] netlink: fix an use-after-free issue for nlk groups
Date: Wed,  6 Sep 2017 11:47:12 +0800
Message-ID: <1217baf9faf9d034ba8224cb6362b822c51a0eae.1504669632.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net, fw@strlen.de, chunwang@redhat.com,
        syzkaller@googlegroups.com
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:37890 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751956AbdIFDrV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 23:47:21 -0400
Received: by mail-pf0-f195.google.com with SMTP id q76so2526238pfq.5
        for <netdev@vger.kernel.org>; Tue, 05 Sep 2017 20:47:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ChunYu found a netlink use-after-free issue by syzkaller:

[28448.842981] BUG: KASAN: use-after-free in __nla_put+0x37/0x40 at addr ffff8807185e2378
[28448.969918] Call Trace:
[...]
[28449.117207]  __nla_put+0x37/0x40
[28449.132027]  nla_put+0xf5/0x130
[28449.146261]  sk_diag_fill.isra.4.constprop.5+0x5a0/0x750 [netlink_diag]
[28449.176608]  __netlink_diag_dump+0x25a/0x700 [netlink_diag]
[28449.202215]  netlink_diag_dump+0x176/0x240 [netlink_diag]
[28449.226834]  netlink_dump+0x488/0xbb0
[28449.298014]  __netlink_dump_start+0x4e8/0x760
[28449.317924]  netlink_diag_handler_dump+0x261/0x340 [netlink_diag]
[28449.413414]  sock_diag_rcv_msg+0x207/0x390
[28449.432409]  netlink_rcv_skb+0x149/0x380
[28449.467647]  sock_diag_rcv+0x2d/0x40
[28449.484362]  netlink_unicast+0x562/0x7b0
[28449.564790]  netlink_sendmsg+0xaa8/0xe60
[28449.661510]  sock_sendmsg+0xcf/0x110
[28449.865631]  __sys_sendmsg+0xf3/0x240
[28450.000964]  SyS_sendmsg+0x32/0x50
[28450.016969]  do_syscall_64+0x25c/0x6c0
[28450.154439]  entry_SYSCALL64_slow_path+0x25/0x25

It was caused by no protection between nlk groups' free in netlink_release
and nlk groups' accessing in sk_diag_dump_groups. The similar issue also
exists in netlink_seq_show().

This patch is to defer nlk groups' free in deferred_put_nlk_sk.

Reported-by: ChunYu Wang <chunwang@redhat.com>
Acked-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/netlink/af_netlink.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 5acee49..94a61e6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -691,6 +691,9 @@ static void deferred_put_nlk_sk(struct rcu_head *head)
 	struct netlink_sock *nlk = container_of(head, struct netlink_sock, rcu);
 	struct sock *sk = &nlk->sk;
 
+	kfree(nlk->groups);
+	nlk->groups = NULL;
+
 	if (!refcount_dec_and_test(&sk->sk_refcnt))
 		return;
 
@@ -769,9 +772,6 @@ static int netlink_release(struct socket *sock)
 		netlink_table_ungrab();
 	}
 
-	kfree(nlk->groups);
-	nlk->groups = NULL;
-
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
-- 
2.1.0
