From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] af_key: do not use GFP_KERNEL in atomic contexts
Date: Mon, 14 Aug 2017 10:16:45 -0700
Message-ID: <1502731005.4936.29.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34636 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752026AbdHNRQr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 14 Aug 2017 13:16:47 -0400
Received: by mail-pg0-f66.google.com with SMTP id y192so11632800pgd.1
        for <netdev@vger.kernel.org>; Mon, 14 Aug 2017 10:16:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

pfkey_broadcast() might be called from non process contexts,
we can not use GFP_KERNEL in these cases [1].

This patch partially reverts commit ba51b6be38c1 ("net: Fix RCU splat in
af_key"), only keeping the GFP_ATOMIC forcing under rcu_read_lock()
section.

[1] : syzkaller reported :

in_atomic(): 1, irqs_disabled(): 0, pid: 2932, name: syzkaller183439
3 locks held by syzkaller183439/2932:
 #0:  (&net->xfrm.xfrm_cfg_mutex){+.+.+.}, at: [<ffffffff83b43888>] pfkey_sendmsg+0x4c8/0x9f0 net/key/af_key.c:3649
 #1:  (&pfk->dump_lock){+.+.+.}, at: [<ffffffff83b467f6>] pfkey_do_dump+0x76/0x3f0 net/key/af_key.c:293
 #2:  (&(&net->xfrm.xfrm_policy_lock)->rlock){+...+.}, at: [<ffffffff83957632>] spin_lock_bh include/linux/spinlock.h:304 [inline]
 #2:  (&(&net->xfrm.xfrm_policy_lock)->rlock){+...+.}, at: [<ffffffff83957632>] xfrm_policy_walk+0x192/0xa30 net/xfrm/xfrm_policy.c:1028
CPU: 0 PID: 2932 Comm: syzkaller183439 Not tainted 4.13.0-rc4+ #24
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
Call Trace:
 __dump_stack lib/dump_stack.c:16 [inline]
 dump_stack+0x194/0x257 lib/dump_stack.c:52
 ___might_sleep+0x2b2/0x470 kernel/sched/core.c:5994
 __might_sleep+0x95/0x190 kernel/sched/core.c:5947
 slab_pre_alloc_hook mm/slab.h:416 [inline]
 slab_alloc mm/slab.c:3383 [inline]
 kmem_cache_alloc+0x24b/0x6e0 mm/slab.c:3559
 skb_clone+0x1a0/0x400 net/core/skbuff.c:1037
 pfkey_broadcast_one+0x4b2/0x6f0 net/key/af_key.c:207
 pfkey_broadcast+0x4ba/0x770 net/key/af_key.c:281
 dump_sp+0x3d6/0x500 net/key/af_key.c:2685
 xfrm_policy_walk+0x2f1/0xa30 net/xfrm/xfrm_policy.c:1042
 pfkey_dump_sp+0x42/0x50 net/key/af_key.c:2695
 pfkey_do_dump+0xaa/0x3f0 net/key/af_key.c:299
 pfkey_spddump+0x1a0/0x210 net/key/af_key.c:2722
 pfkey_process+0x606/0x710 net/key/af_key.c:2814
 pfkey_sendmsg+0x4d6/0x9f0 net/key/af_key.c:3650
sock_sendmsg_nosec net/socket.c:633 [inline]
 sock_sendmsg+0xca/0x110 net/socket.c:643
 ___sys_sendmsg+0x755/0x890 net/socket.c:2035
 __sys_sendmsg+0xe5/0x210 net/socket.c:2069
 SYSC_sendmsg net/socket.c:2080 [inline]
 SyS_sendmsg+0x2d/0x50 net/socket.c:2076
 entry_SYSCALL_64_fastpath+0x1f/0xbe
RIP: 0033:0x445d79
RSP: 002b:00007f32447c1dc8 EFLAGS: 00000202 ORIG_RAX: 000000000000002e
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 0000000000445d79
RDX: 0000000000000000 RSI: 000000002023dfc8 RDI: 0000000000000008
RBP: 0000000000000086 R08: 00007f32447c2700 R09: 00007f32447c2700
R10: 00007f32447c2700 R11: 0000000000000202 R12: 0000000000000000
R13: 00007ffe33edec4f R14: 00007f32447c29c0 R15: 0000000000000000

Fixes: ba51b6be38c1 ("net: Fix RCU splat in af_key")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
---
 net/key/af_key.c |   48 ++++++++++++++++++++++++---------------------
 1 file changed, 26 insertions(+), 22 deletions(-)

diff --git a/net/key/af_key.c b/net/key/af_key.c
index ca9d3ae665e7..98f4d8211b9a 100644
--- a/net/key/af_key.c
+++ b/net/key/af_key.c
@@ -228,7 +228,7 @@ static int pfkey_broadcast_one(struct sk_buff *skb, struct sk_buff **skb2,
 #define BROADCAST_ONE		1
 #define BROADCAST_REGISTERED	2
 #define BROADCAST_PROMISC_ONLY	4
-static int pfkey_broadcast(struct sk_buff *skb,
+static int pfkey_broadcast(struct sk_buff *skb, gfp_t allocation,
 			   int broadcast_flags, struct sock *one_sk,
 			   struct net *net)
 {
@@ -278,7 +278,7 @@ static int pfkey_broadcast(struct sk_buff *skb,
 	rcu_read_unlock();
 
 	if (one_sk != NULL)
-		err = pfkey_broadcast_one(skb, &skb2, GFP_KERNEL, one_sk);
+		err = pfkey_broadcast_one(skb, &skb2, allocation, one_sk);
 
 	kfree_skb(skb2);
 	kfree_skb(skb);
@@ -311,7 +311,7 @@ static int pfkey_do_dump(struct pfkey_sock *pfk)
 		hdr = (struct sadb_msg *) pfk->dump.skb->data;
 		hdr->sadb_msg_seq = 0;
 		hdr->sadb_msg_errno = rc;
-		pfkey_broadcast(pfk->dump.skb, BROADCAST_ONE,
+		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
 				&pfk->sk, sock_net(&pfk->sk));
 		pfk->dump.skb = NULL;
 	}
@@ -355,7 +355,7 @@ static int pfkey_error(const struct sadb_msg *orig, int err, struct sock *sk)
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) /
 			     sizeof(uint64_t));
 
-	pfkey_broadcast(skb, BROADCAST_ONE, sk, sock_net(sk));
+	pfkey_broadcast(skb, GFP_KERNEL, BROADCAST_ONE, sk, sock_net(sk));
 
 	return 0;
 }
@@ -1389,7 +1389,7 @@ static int pfkey_getspi(struct sock *sk, struct sk_buff *skb, const struct sadb_
 
 	xfrm_state_put(x);
 
-	pfkey_broadcast(resp_skb, BROADCAST_ONE, sk, net);
+	pfkey_broadcast(resp_skb, GFP_KERNEL, BROADCAST_ONE, sk, net);
 
 	return 0;
 }
@@ -1476,7 +1476,7 @@ static int key_notify_sa(struct xfrm_state *x, const struct km_event *c)
 	hdr->sadb_msg_seq = c->seq;
 	hdr->sadb_msg_pid = c->portid;
 
-	pfkey_broadcast(skb, BROADCAST_ALL, NULL, xs_net(x));
+	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL, xs_net(x));
 
 	return 0;
 }
@@ -1589,7 +1589,7 @@ static int pfkey_get(struct sock *sk, struct sk_buff *skb, const struct sadb_msg
 	out_hdr->sadb_msg_reserved = 0;
 	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
 	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, BROADCAST_ONE, sk, sock_net(sk));
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, sk, sock_net(sk));
 
 	return 0;
 }
@@ -1694,8 +1694,8 @@ static int pfkey_register(struct sock *sk, struct sk_buff *skb, const struct sad
 		return -ENOBUFS;
 	}
 
-	pfkey_broadcast(supp_skb, BROADCAST_REGISTERED, sk, sock_net(sk));
-
+	pfkey_broadcast(supp_skb, GFP_KERNEL, BROADCAST_REGISTERED, sk,
+			sock_net(sk));
 	return 0;
 }
 
@@ -1712,7 +1712,8 @@ static int unicast_flush_resp(struct sock *sk, const struct sadb_msg *ihdr)
 	hdr->sadb_msg_errno = (uint8_t) 0;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
 
-	return pfkey_broadcast(skb, BROADCAST_ONE, sk, sock_net(sk));
+	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ONE, sk,
+			       sock_net(sk));
 }
 
 static int key_notify_sa_flush(const struct km_event *c)
@@ -1733,7 +1734,7 @@ static int key_notify_sa_flush(const struct km_event *c)
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
 	hdr->sadb_msg_reserved = 0;
 
-	pfkey_broadcast(skb, BROADCAST_ALL, NULL, c->net);
+	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL, c->net);
 
 	return 0;
 }
@@ -1790,7 +1791,7 @@ static int dump_sa(struct xfrm_state *x, int count, void *ptr)
 	out_hdr->sadb_msg_pid = pfk->dump.msg_portid;
 
 	if (pfk->dump.skb)
-		pfkey_broadcast(pfk->dump.skb, BROADCAST_ONE,
+		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
 				&pfk->sk, sock_net(&pfk->sk));
 	pfk->dump.skb = out_skb;
 
@@ -1878,7 +1879,7 @@ static int pfkey_promisc(struct sock *sk, struct sk_buff *skb, const struct sadb
 		new_hdr->sadb_msg_errno = 0;
 	}
 
-	pfkey_broadcast(skb, BROADCAST_ALL, NULL, sock_net(sk));
+	pfkey_broadcast(skb, GFP_KERNEL, BROADCAST_ALL, NULL, sock_net(sk));
 	return 0;
 }
 
@@ -2206,7 +2207,7 @@ static int key_notify_policy(struct xfrm_policy *xp, int dir, const struct km_ev
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_seq = c->seq;
 	out_hdr->sadb_msg_pid = c->portid;
-	pfkey_broadcast(out_skb, BROADCAST_ALL, NULL, xp_net(xp));
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ALL, NULL, xp_net(xp));
 	return 0;
 
 }
@@ -2426,7 +2427,7 @@ static int key_pol_get_resp(struct sock *sk, struct xfrm_policy *xp, const struc
 	out_hdr->sadb_msg_errno = 0;
 	out_hdr->sadb_msg_seq = hdr->sadb_msg_seq;
 	out_hdr->sadb_msg_pid = hdr->sadb_msg_pid;
-	pfkey_broadcast(out_skb, BROADCAST_ONE, sk, xp_net(xp));
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_ONE, sk, xp_net(xp));
 	err = 0;
 
 out:
@@ -2682,7 +2683,7 @@ static int dump_sp(struct xfrm_policy *xp, int dir, int count, void *ptr)
 	out_hdr->sadb_msg_pid = pfk->dump.msg_portid;
 
 	if (pfk->dump.skb)
-		pfkey_broadcast(pfk->dump.skb, BROADCAST_ONE,
+		pfkey_broadcast(pfk->dump.skb, GFP_ATOMIC, BROADCAST_ONE,
 				&pfk->sk, sock_net(&pfk->sk));
 	pfk->dump.skb = out_skb;
 
@@ -2739,7 +2740,7 @@ static int key_notify_policy_flush(const struct km_event *c)
 	hdr->sadb_msg_satype = SADB_SATYPE_UNSPEC;
 	hdr->sadb_msg_len = (sizeof(struct sadb_msg) / sizeof(uint64_t));
 	hdr->sadb_msg_reserved = 0;
-	pfkey_broadcast(skb_out, BROADCAST_ALL, NULL, c->net);
+	pfkey_broadcast(skb_out, GFP_ATOMIC, BROADCAST_ALL, NULL, c->net);
 	return 0;
 
 }
@@ -2803,7 +2804,7 @@ static int pfkey_process(struct sock *sk, struct sk_buff *skb, const struct sadb
 	void *ext_hdrs[SADB_EXT_MAX];
 	int err;
 
-	pfkey_broadcast(skb_clone(skb, GFP_KERNEL),
+	pfkey_broadcast(skb_clone(skb, GFP_KERNEL), GFP_KERNEL,
 			BROADCAST_PROMISC_ONLY, NULL, sock_net(sk));
 
 	memset(ext_hdrs, 0, sizeof(ext_hdrs));
@@ -3024,7 +3025,8 @@ static int key_notify_sa_expire(struct xfrm_state *x, const struct km_event *c)
 	out_hdr->sadb_msg_seq = 0;
 	out_hdr->sadb_msg_pid = 0;
 
-	pfkey_broadcast(out_skb, BROADCAST_REGISTERED, NULL, xs_net(x));
+	pfkey_broadcast(out_skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL,
+			xs_net(x));
 	return 0;
 }
 
@@ -3212,7 +3214,8 @@ static int pfkey_send_acquire(struct xfrm_state *x, struct xfrm_tmpl *t, struct
 		       xfrm_ctx->ctx_len);
 	}
 
-	return pfkey_broadcast(skb, BROADCAST_REGISTERED, NULL, xs_net(x));
+	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL,
+			       xs_net(x));
 }
 
 static struct xfrm_policy *pfkey_compile_policy(struct sock *sk, int opt,
@@ -3408,7 +3411,8 @@ static int pfkey_send_new_mapping(struct xfrm_state *x, xfrm_address_t *ipaddr,
 	n_port->sadb_x_nat_t_port_port = sport;
 	n_port->sadb_x_nat_t_port_reserved = 0;
 
-	return pfkey_broadcast(skb, BROADCAST_REGISTERED, NULL, xs_net(x));
+	return pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_REGISTERED, NULL,
+			       xs_net(x));
 }
 
 #ifdef CONFIG_NET_KEY_MIGRATE
@@ -3599,7 +3603,7 @@ static int pfkey_send_migrate(const struct xfrm_selector *sel, u8 dir, u8 type,
 	}
 
 	/* broadcast migrate message to sockets */
-	pfkey_broadcast(skb, BROADCAST_ALL, NULL, &init_net);
+	pfkey_broadcast(skb, GFP_ATOMIC, BROADCAST_ALL, NULL, &init_net);
 
 	return 0;
 
