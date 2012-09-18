From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] tcp: Fixed a TFO server bug that crashed kernel by raw sockets
Date: Tue, 18 Sep 2012 16:35:51 -0700
Message-ID: <1348011351-13882-1-git-send-email-hkchu@google.com>
Cc: ncardwell@google.com, edumazet@google.com,
	Jerry Chu <hkchu@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:64150 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751044Ab2IRXgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 19:36:05 -0400
Received: by ggnu1 with SMTP id u1so63659ggn.1
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 16:36:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

Crash dump msg looks like this:

<1>[34468.419809] BUG: unable to handle kernel paging request at ffffeb57000dc058
<1>[34468.426770] IP: [<ffffffff80383f9c>] kfree+0x4c/0x2d0
...
<4>[34468.603362] Call Trace:
<4>[34468.605802]  [<ffffffff807542a4>] inet_sock_destruct+0x174/0x1f0
<4>[34468.611786]  [<ffffffff806ced53>] __sk_free+0x23/0x170
<4>[34468.616907]  [<ffffffff806ceec5>] sk_free+0x25/0x30
<4>[34468.621762]  [<ffffffff806d066a>] sk_common_release+0x7a/0x80
<4>[34468.627481]  [<ffffffff80746782>] raw_close+0x22/0x30
<4>[34468.632515]  [<ffffffff80753038>] inet_release+0x58/0x90
<4>[34468.637802]  [<ffffffff806c9dd8>] sock_release+0x28/0x90
<4>[34468.643087]  [<ffffffff806c9f07>] sock_close+0x17/0x30
<4>[34468.648203]  [<ffffffff8039d60a>] fput+0xda/0x210
<4>[34468.652894]  [<ffffffff80398e06>] filp_close+0x66/0x90
<4>[34468.658016]  [<ffffffff802822cd>] put_files_struct+0x9d/0x120
<4>[34468.663743]  [<ffffffff802823fa>] exit_files+0x4a/0x60
<4>[34468.668857]  [<ffffffff802828e4>] do_exit+0x1a4/0x8c0
<4>[34468.673886]  [<ffffffff803697db>] ? do_munmap+0x2ab/0x390
<4>[34468.679256]  [<ffffffff80283384>] do_group_exit+0x44/0xa0
<4>[34468.684632]  [<ffffffff8028341f>] sys_exit_group+0x3f/0x50
<4>[34468.690094]  [<ffffffff807a5730>] sysenter_dispatch+0x7/0x1a

This bug was introduced as part of patch
7ab4551f3b391818e29263279031dca1e26417c6

It turns out the call "socket(PF_INET/PF_INET6, SOCK_RAW, IPPROTO_TCP)"
will cause a raw socket to be created with protocol == IPPROTO_TCP
so checking against the protocol field in sk alone is not sufficient
to guarantee a TCP socket. One must also check type == SOCK_STREAM.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
Cc: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/af_inet.c |   28 +++++++++++++++++-----------
 1 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 845372b..c9f0ea8 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -140,17 +140,22 @@ void inet_sock_destruct(struct sock *sk)
 
 	sk_mem_reclaim(sk);
 
-	if (sk->sk_type == SOCK_STREAM && sk->sk_state != TCP_CLOSE) {
-		pr_err("Attempt to release TCP socket in state %d %p\n",
-		       sk->sk_state, sk);
-		return;
-	}
 	if (!sock_flag(sk, SOCK_DEAD)) {
 		pr_err("Attempt to release alive inet socket %p\n", sk);
 		return;
 	}
-	if (sk->sk_protocol == IPPROTO_TCP)
-		kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
+	if (sk->sk_type == SOCK_STREAM) {
+		if (sk->sk_state != TCP_CLOSE) {
+			pr_err("Attempt to release TCP socket in state %d %p\n",
+				sk->sk_state, sk);
+			return;
+		}
+		/* Only TCP sockets (either v4 or v6) may have a valid
+		 * icsk_accept_queue.fastopenq that must be freed.
+		 */
+		if (sk->sk_protocol == IPPROTO_TCP)
+			kfree(inet_csk(sk)->icsk_accept_queue.fastopenq);
+	}
 
 	WARN_ON(atomic_read(&sk->sk_rmem_alloc));
 	WARN_ON(atomic_read(&sk->sk_wmem_alloc));
@@ -216,10 +221,11 @@ int inet_listen(struct socket *sock, int backlog)
 	if (old_state != TCP_LISTEN) {
 		/* Check special setups for testing purpose to enable TFO w/o
 		 * requiring TCP_FASTOPEN sockopt.
-		 * Note that only TCP sockets (SOCK_STREAM) will reach here.
-		 * Also fastopenq may already been allocated because this
-		 * socket was in TCP_LISTEN state previously but was
-		 * shutdown() (rather than close()).
+		 *
+		 * Note that only TCP sockets will reach here. Also fastopenq
+		 * may already been allocated because this socket was in
+		 * TCP_LISTEN state previously but was shutdown() (rather
+		 * than close()).
 		 */
 		if ((sysctl_tcp_fastopen & TFO_SERVER_ENABLE) != 0 &&
 		    inet_csk(sk)->icsk_accept_queue.fastopenq == NULL) {
-- 
1.7.7.3
