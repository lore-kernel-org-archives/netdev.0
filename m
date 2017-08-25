From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix hang in tcp_sendpage_locked()
Date: Fri, 25 Aug 2017 06:27:05 -0700
Message-ID: <1503667625.18816.9.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <tom@quantonium.net>,
        Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:38284 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932201AbdHYN1H (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2017 09:27:07 -0400
Received: by mail-pg0-f67.google.com with SMTP id t3so3875682pgt.5
        for <netdev@vger.kernel.org>; Fri, 25 Aug 2017 06:27:07 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syszkaller got a hang in tcp stack, related to a bug in
tcp_sendpage_locked()

root@syzkaller:~# cat /proc/3059/stack
[<ffffffff83de926c>] __lock_sock+0x1dc/0x2f0
[<ffffffff83de9473>] lock_sock_nested+0xf3/0x110
[<ffffffff8408ce01>] tcp_sendmsg+0x21/0x50
[<ffffffff84163b6f>] inet_sendmsg+0x11f/0x5e0
[<ffffffff83dd8eea>] sock_sendmsg+0xca/0x110
[<ffffffff83dd9547>] kernel_sendmsg+0x47/0x60
[<ffffffff83de35dc>] sock_no_sendpage+0x1cc/0x280
[<ffffffff8408916b>] tcp_sendpage_locked+0x10b/0x160
[<ffffffff84089203>] tcp_sendpage+0x43/0x60
[<ffffffff841641da>] inet_sendpage+0x1aa/0x660
[<ffffffff83dd4fcd>] kernel_sendpage+0x8d/0xe0
[<ffffffff83dd50ac>] sock_sendpage+0x8c/0xc0
[<ffffffff81b63300>] pipe_to_sendpage+0x290/0x3b0
[<ffffffff81b67243>] __splice_from_pipe+0x343/0x750
[<ffffffff81b6a459>] splice_from_pipe+0x1e9/0x330
[<ffffffff81b6a5e0>] generic_splice_sendpage+0x40/0x50
[<ffffffff81b6b1d7>] SyS_splice+0x7b7/0x1610
[<ffffffff84d77a01>] entry_SYSCALL_64_fastpath+0x1f/0xbe

Fixes: 306b13eb3cf9 ("proto_ops: Add locked held versions of sendmsg and sendpage")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Tom Herbert <tom@quantonium.net>
---
 net/ipv4/tcp.c |    3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0cce4472b4a1b0e3c110692571ac2a5c51467c42..566083ee2654c25410d80ff56ce5adb49bb28ae7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -1052,8 +1052,7 @@ int tcp_sendpage_locked(struct sock *sk, struct page *page, int offset,
 {
 	if (!(sk->sk_route_caps & NETIF_F_SG) ||
 	    !sk_check_csum_caps(sk))
-		return sock_no_sendpage(sk->sk_socket, page, offset, size,
-					flags);
+		return sock_no_sendpage_locked(sk, page, offset, size, flags);
 
 	tcp_rate_check_app_limited(sk);  /* is sending application-limited? */
 
