From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix 0 divide in __tcp_select_window()
Date: Wed, 01 Feb 2017 08:33:53 -0800
Message-ID: <1485966833.6360.149.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:34934 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdBAQdz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 1 Feb 2017 11:33:55 -0500
Received: by mail-pg0-f68.google.com with SMTP id 204so34590770pge.2
        for <netdev@vger.kernel.org>; Wed, 01 Feb 2017 08:33:54 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

syszkaller fuzzer was able to trigger a divide by zero, when
TCP window scaling is not enabled.

SO_RCVBUF can be used not only to increase sk_rcvbuf, also
to decrease it below current receive buffers utilization.

If mss is negative or 0, just return a zero TCP window.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov  <dvyukov@google.com>
---
No Fixes: tag, this is a day-0 bug.

 net/ipv4/tcp_output.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 1d5331a1b1dc2677316148ba9852c191e7ed0fd4..8ce50dc3ab8cac821b8a2c3e0d31f0aa42f5c9d5 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2518,9 +2518,11 @@ u32 __tcp_select_window(struct sock *sk)
 	int full_space = min_t(int, tp->window_clamp, allowed_space);
 	int window;
 
-	if (mss > full_space)
+	if (unlikely(mss > full_space)) {
 		mss = full_space;
-
+		if (mss <= 0)
+			return 0;
+	}
 	if (free_space < (full_space >> 1)) {
 		icsk->icsk_ack.quick = 0;
 
