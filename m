From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH] TCP/IP stack bypass for loopback connections fix
Date: Tue, 14 Aug 2012 11:12:41 +0800
Message-ID: <58003d98a9d32430e5dc9cbadee2ac9a9e5f0002.1344913742.git.wpan@redhat.com>
References: <1344559958-29162-1-git-send-email-brutus@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: brutus@google.com, Weiping Pan <wpan@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14844 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753649Ab2HNDMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Aug 2012 23:12:41 -0400
In-Reply-To: <1344559958-29162-1-git-send-email-brutus@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I found two problems then I tested Bruce Curtis <brutus@google.com> loo=
pback
patch, http://patchwork.ozlabs.org/patch/176304/

1 =E2=80=98friends=E2=80=99 undeclared in function =E2=80=98tcp_recvmsg=
=E2=80=99
I think it should use sysctl_tcp_friends

2 scheduling while atomic

BUG: scheduling while atomic: netperf/3820/0x10000200
Modules linked in: bridge stp llc autofs4 sunrpc ipv6 uinput
iTCO_wdt iTCO_vendor_suppo]
Pid: 3820, comm: netperf Tainted: G        W    3.5.0+ #11
Call Trace:
[<ffffffff810861e2>] __schedule_bug+0x52/0x60
[<ffffffff8151e7de>] __schedule+0x68e/0x710
[<ffffffff8108a80a>] __cond_resched+0x2a/0x40
[<ffffffff8151e8f0>] _cond_resched+0x30/0x40
[<ffffffff8149b68e>] tcp_sendmsg+0x96e/0x12c0
[<ffffffff814bf928>] inet_sendmsg+0x48/0xb0
[<ffffffff812081a3>] ? selinux_socket_sendmsg+0x23/0x30
[<ffffffff8143c4be>] sock_sendmsg+0xbe/0xf0
[<ffffffff81078958>] ? finish_wait+0x68/0x90
[<ffffffff81172660>] ? fget_light+0x50/0xc0
[<ffffffff8143c629>] sys_sendto+0x139/0x190
[<ffffffff810d21cc>] ?  __audit_syscall_entry+0xcc/0x210
[<ffffffff810d20a6>] ?  __audit_syscall_exit+0x3d6/0x430
[<ffffffff81527c29>] system_call_fastpath+0x16/0x1b

The reason is that in tcp_friend_tail(), it holds a spinlock,
spin_lock_bh(&friend->sk_lock.slock);
but skb_add_data_nocache() can cause schedule, so this warning happends=
=2E

Wit this patch, the original patch can apply on top of net-next tree
commit 79cda75a107da(fib: use __fls() on non null argument),
and I test it works fine on x86_64 system.

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 net/ipv4/tcp.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 6dc267c..bab15da 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -628,7 +628,7 @@ static inline struct sk_buff *tcp_friend_tail(struc=
t sock *sk, int *copy)
 	int		sz =3D 0;
=20
 	if (skb_peek_tail(&friend->sk_receive_queue)) {
-		spin_lock_bh(&friend->sk_lock.slock);
+		lock_sock(friend);
 		skb =3D skb_peek_tail(&friend->sk_receive_queue);
 		if (skb && skb->friend) {
 			if (!*copy)
@@ -637,7 +637,7 @@ static inline struct sk_buff *tcp_friend_tail(struc=
t sock *sk, int *copy)
 				sz =3D *copy - skb->len;
 		}
 		if (!skb || sz <=3D 0)
-			spin_unlock_bh(&friend->sk_lock.slock);
+			release_sock(friend);
 	}
=20
 	*copy =3D sz;
@@ -655,7 +655,7 @@ static inline void tcp_friend_seq(struct sock *sk, =
int copy, int charge)
 	}
 	tp->rcv_nxt +=3D copy;
 	tp->rcv_wup +=3D copy;
-	spin_unlock_bh(&friend->sk_lock.slock);
+	release_sock(friend);
=20
 	friend->sk_data_ready(friend, copy);
=20
@@ -676,7 +676,7 @@ static inline int tcp_friend_push(struct sock *sk, =
struct sk_buff *skb)
 		return -ECONNRESET;
 	}
=20
-	spin_lock_bh(&friend->sk_lock.slock);
+	lock_sock(friend);
 	skb->friend =3D sk;
 	skb_set_owner_r(skb, friend);
 	__skb_queue_tail(&friend->sk_receive_queue, skb);
@@ -1505,7 +1505,7 @@ out:
=20
 do_fault:
 	if (friend_tail)
-		spin_unlock_bh(&friend->sk_lock.slock);
+		release_sock(friend);
 	else if (!skb->len) {
 		if (friend)
 			__kfree_skb(skb);
@@ -1932,7 +1932,7 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *=
sk, struct msghdr *msg,
 			available =3D TCP_SKB_CB(skb)->seq + skb->len - (*seq);
 		if ((available < target) &&
 		    (len > sysctl_tcp_dma_copybreak) && !(flags & MSG_PEEK) &&
-		    !sysctl_tcp_low_latency && !friends &&
+		    !sysctl_tcp_low_latency && !sysctl_tcp_friends &&
 		    net_dma_find_channel()) {
 			preempt_enable_no_resched();
 			tp->ucopy.pinned_list =3D
--=20
1.7.1
