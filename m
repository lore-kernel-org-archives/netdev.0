From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Crash due to mutex genl_lock called from RCU context
Date: Fri, 25 Nov 2016 20:11:33 -0800
Message-ID: <1480133493.8455.584.camel@edumazet-glaptop3.roam.corp.google.com>
References: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: subashab@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35204 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750857AbcKZELf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 23:11:35 -0500
Received: by mail-pf0-f193.google.com with SMTP id i88so3637442pfk.2
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 20:11:35 -0800 (PST)
In-Reply-To: <c669cd06c3e50febd95b5ed4aaa78532@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-11-25 at 19:15 -0700, subashab@codeaurora.org wrote:
> We are seeing a crash due to gen_lock mutex being acquired in RCU 
> context.
> Crash is seen on a 4.4 based kernel ARM64 device. This occurred in a
> regression rack, so unfortunately I don't have steps for a reproducer.
> 
> It looks like freeing socket in RCU was brought in through commit
> 21e4902aea80ef35afc00ee8d2abdea4f519b7f7 ("netlink: Lockless lookup with
> RCU grace period in socket release").
> I am not very familiar with generic netlink sockets so I am not sure
> if there is any other way to fix this apart from reverting this patch.
> 
> Any pointers to debug this would be appreciated.
> 
> Here is the call stack -
> 
> BUG: sleeping function called from invalid context 
> kernel/locking/mutex.c:98
> in_atomic(): 1, irqs_disabled(): 0, pid: 16400, name: busybox
> [<ffffff80080cad20>] ___might_sleep+0x134/0x144
> [<ffffff80080cadac>] __might_sleep+0x7c/0x8c
> [<ffffff8008ef09a8>] mutex_lock+0x2c/0x4c
> [<ffffff8008d307f0>] genl_lock+0x1c/0x24
> [<ffffff8008d30848>] genl_lock_done+0x2c/0x50
> [<ffffff8008d2ccac>] netlink_sock_destruct+0x30/0x94
> [<ffffff8008cdef44>] sk_destruct+0x2c/0x150
> [<ffffff8008cdf104>] __sk_free+0x9c/0xc4
> [<ffffff8008cdf16c>] sk_free+0x40/0x4c
> [<ffffff8008d2c7fc>] deferred_put_nlk_sk+0x40/0x4c
> [<ffffff800810b104>] rcu_process_callbacks+0x4d4/0x644
> [<ffffff80080a6598>] __do_softirq+0x1b8/0x3c4
> [<ffffff80080a6a60>] irq_exit+0x80/0xd4
> [<ffffff800808e554>] handle_IPI+0x1c0/0x364
> [<ffffff80080817f8>] gic_handle_irq+0x154/0x1a4

Right, Thomas commit looks buggy.

Unfortunately the proper infra was added later in commit 
a4298e4522d687a79af8 ("net: add SOCK_RCU_FREE socket flag")

I guess we should backport it, then apply following (untested) fix

Could you test this solution ? Thanks !

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 62bea4591054..fe0d43314198 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -456,8 +456,9 @@ static struct sock *netlink_lookup(struct net *net, int protocol, u32 portid)
 
 	rcu_read_lock();
 	sk = __netlink_lookup(table, portid, net);
-	if (sk)
-		sock_hold(sk);
+	if (sk && !atomic_inc_not_zero(&sk->sk_refcnt))
+		sk = NULL;
+
 	rcu_read_unlock();
 
 	return sk;
@@ -581,6 +582,7 @@ static int __netlink_create(struct net *net, struct socket *sock,
 	}
 	init_waitqueue_head(&nlk->wait);
 
+	sock_set_flag(sk, SOCK_RCU_FREE);
 	sk->sk_destruct = netlink_sock_destruct;
 	sk->sk_protocol = protocol;
 	return 0;
@@ -645,13 +647,6 @@ static int netlink_create(struct net *net, struct socket *sock, int protocol,
 	goto out;
 }
 
-static void deferred_put_nlk_sk(struct rcu_head *head)
-{
-	struct netlink_sock *nlk = container_of(head, struct netlink_sock, rcu);
-
-	sock_put(&nlk->sk);
-}
-
 static int netlink_release(struct socket *sock)
 {
 	struct sock *sk = sock->sk;
@@ -724,7 +719,7 @@ static int netlink_release(struct socket *sock)
 	local_bh_disable();
 	sock_prot_inuse_add(sock_net(sk), &netlink_proto, -1);
 	local_bh_enable();
-	call_rcu(&nlk->rcu, deferred_put_nlk_sk);
+	sock_put(sk);
 	return 0;
 }
 
diff --git a/net/netlink/af_netlink.h b/net/netlink/af_netlink.h
index 3cfd6cc60504..5dc08a7b0a2b 100644
--- a/net/netlink/af_netlink.h
+++ b/net/netlink/af_netlink.h
@@ -32,7 +32,6 @@ struct netlink_sock {
 	struct module		*module;
 
 	struct rhash_head	node;
-	struct rcu_head		rcu;
 };
 
 static inline struct netlink_sock *nlk_sk(struct sock *sk)
