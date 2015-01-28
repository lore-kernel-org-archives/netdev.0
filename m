From: Harout Hedeshian <harouth@codeaurora.org>
Subject: [RFC] net: tcp: null pointer crash in __inet_put_port
Date: Wed, 28 Jan 2015 08:56:53 -0700
Message-ID: <1422460613-10782-1-git-send-email-harouth@codeaurora.org>
Cc: Harout Hedeshian <harouth@codeaurora.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:45166 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761443AbbA1Umw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jan 2015 15:42:52 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We are observing a crash in __inet_put_port() wherein icsk_bind_hash
is null (stack trace below).

net/ipv4/inet_hashtables.c:
tb = inet_csk(sk)->icsk_bind_hash;
__sk_del_bind_node(sk);
tb->num_owners--;       <-- tb is unconditionally dereferenced here

>From the RAM dumps: [D:0xFFFFFFC0222FB6F8] icsk_bind_hash = 0x0 = ,

The caller of inet_put_port() in this case is tcp_set_state() which
already does a null check on this particular field before calling
inet_put_port().

net/ipv4/tcp.c:
if (inet_csk(sk)->icsk_bind_hash &&
   !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
	inet_put_port(sk);

It seems that inet_put_port() does some locking by disabling bottom
halves, but this locking is happening after the null check.

Additionally, I see tcp_v4_destroy_sock() also calling inet_put_port()
after doing a similar null check. However, I am unsure if it would
ever be called on the same socket.

Does the proposed solution of locking the bottom halves from
tcp_set_state() make any sense here? Or use some other locking mechanism
directly on the socket?

[66356.767342] Unable to handle kernel NULL pointer dereference at virtual address 00000010
[66356.767366] pgd = ffffffc0409cb000
[66356.767377] [00000010] *pgd=00000000409c9003, *pmd=0000000000000000
[66356.767397] Internal error: Oops: 96000006 [#1] PREEMPT SMP
[66356.767409] Modules linked in: ecryptfs(O) texfat(PO) mcKernelApi mcDrvModule moc_crypto_api_tmpl(O) moc_crypto(PO) moc_platform_mod(O)
[66356.767453] CPU: 0 PID: 3735 Comm: GCMReader Tainted: P        W  O 3.10.49-g0d75018 #1
[66356.767467] task: ffffffc03a790ac0 ti: ffffffc02b1d0000 task.ti: ffffffc02b1d0000
[66356.767486] PC is at inet_put_port+0x7c/0xb4
[66356.767498] LR is at inet_put_port+0x64/0xb4
[66356.767509] pc : [<ffffffc000ba3890>] lr : [<ffffffc000ba3878>] pstate: 80000145
[66356.767520] sp : ffffffc02b1d3d00
[66356.767530] x29: ffffffc02b1d3d00 x28: ffffffc02b1d0000
[66356.767544] x27: ffffffc0016cf000 x26: 0000000000000039
[66356.767557] x25: ffffffc055644030 x24: ffffffc026280f10
[66356.767570] x23: ffffffc055644030 x22: ffffffc0222fb398
[66356.767583] x21: ffffffc001b2f4c0 x20: ffffffc0222fb300
[66356.767597] x19: ffffffc0b50b7780 x18: 0000007f8399b000
[66356.767610] x17: 0000007f869e00f8 x16: ffffffc0002fb850
[66356.767624] x15: 0000007f83a4c000 x14: 0000000000000000
[66356.767637] x13: 0000000000430000 x12: 0000000000550000
[66356.767651] x11: 0000000000430000 x10: 0000000000000000
[66356.767663] x9 : b36a52a36930d612 x8 : 0008e12c614dea00
[66356.767676] x7 : 0000000000000018 x6 : 0000000034155555
[66356.767689] x5 : 0000000000000000 x4 : 0000000000000000
[66356.767702] x3 : 0000000000000200 x2 : ffffffc002c17de8
[66356.767715] x1 : 0000000000000000 x0 : 0000000000000000
[66356.767727]
[66356.767739] Process GCMReader (pid: 3735, stack limit = 0xffffffc02b1d0058)
[66356.767749] Call trace:
[66356.767762] [<ffffffc000ba3890>] inet_put_port+0x7c/0xb4
[66356.767777] [<ffffffc000ba6940>] tcp_set_state+0xbc/0x108
[66356.767790] [<ffffffc000baa78c>] tcp_close+0x374/0x420
[66356.767807] [<ffffffc000bca210>] inet_release+0x84/0x98
[66356.767821] [<ffffffc000bfd0d8>] inet6_release+0x34/0x44
[66356.767838] [<ffffffc000b22b38>] sock_release+0x34/0xac
[66356.767852] [<ffffffc000b22bbc>] sock_close+0xc/0x1c
[66356.767868] [<ffffffc0002fd718>] __fput+0x108/0x208
[66356.767882] [<ffffffc0002fd8c0>] ____fput+0x8/0x14
[66356.767898] [<ffffffc00023b8d4>] task_work_run+0xb0/0xe4
[66356.767914] [<ffffffc0002072ec>] do_notify_resume+0x44/0x54
[66356.767929] Code: f941fe81 f9000040 b4000040 f9000402 (b9401020)
[66356.767942] ---[ end trace 421040d8ca7bbe73 ]---
---
 net/ipv4/tcp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 3075723..f3b5714 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1910,9 +1910,11 @@ void tcp_set_state(struct sock *sk, int state)
 			TCP_INC_STATS(sock_net(sk), TCP_MIB_ESTABRESETS);
 
 		sk->sk_prot->unhash(sk);
+		local_bh_disable();
 		if (inet_csk(sk)->icsk_bind_hash &&
 		    !(sk->sk_userlocks & SOCK_BINDPORT_LOCK))
 			inet_put_port(sk);
+		local_bh_enable();
 		/* fall through */
 	default:
 		if (oldstate == TCP_ESTABLISHED)
-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
