From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] tcp: reset sk_rx_dst in tcp_disconnect()
Date: Sat, 24 Jun 2017 23:50:30 -0700
Message-ID: <1498373430-24807-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: avagin@gmail.com, kaiwen.xu@hulu.com,
        Cong Wang <xiyou.wangcong@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36790 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751197AbdFYGul (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 02:50:41 -0400
Received: by mail-pg0-f65.google.com with SMTP id e187so11392554pgc.3
        for <netdev@vger.kernel.org>; Sat, 24 Jun 2017 23:50:40 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We have to reset the sk->sk_rx_dst when we disconnect a TCP
connection, because otherwise when we re-connect it this
dst reference is simply overridden in tcp_finish_connect().

This fixes a dst leak which leads to a loopback dev refcnt
leak. It is a long-standing bug, Kevin reported a very similar
(if not same) bug before. Thanks to Andrei for providing such
a reliable reproducer which greatly narrows down the problem.

Fixes: 41063e9dd119 ("ipv4: Early TCP socket demux.")
Reported-by: Andrei Vagin <avagin@gmail.com>
Reported-by: Kevin Xu <kaiwen.xu@hulu.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/tcp.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index b5ea036..40aca78 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2330,6 +2330,8 @@ int tcp_disconnect(struct sock *sk, int flags)
 	tcp_init_send_head(sk);
 	memset(&tp->rx_opt, 0, sizeof(tp->rx_opt));
 	__sk_dst_reset(sk);
+	dst_release(sk->sk_rx_dst);
+	sk->sk_rx_dst = NULL;
 	tcp_saved_syn_free(tp);
 
 	/* Clean up fastopen related fields */
-- 
2.5.5
