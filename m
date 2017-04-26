From: Davide Caratti <dcaratti@redhat.com>
Subject: [PATCH net] tcp: fix access to sk->sk_state in tcp_poll()
Date: Wed, 26 Apr 2017 19:07:35 +0200
Message-ID: <0a1710138c3e55c388a52dba817b2d1b1996c899.1493226034.git.dcaratti@redhat.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, Wei Wang <weiwan@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59348 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750727AbdDZRHz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 26 Apr 2017 13:07:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

avoid direct access to sk->sk_state when tcp_poll() is called on a socket
using active TCP fastopen with deferred connect. Use local variable
'state', which stores the result of sk_state_load(), like it was done in
commit 00fd38d938db ("tcp: ensure proper barriers in lockless contexts").

Fixes: 19f6d3f3c842 ("net/tcp-fastopen: Add new API support")
Signed-off-by: Davide Caratti <dcaratti@redhat.com>
---
 net/ipv4/tcp.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 40ba424..2dc7fcf 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -533,7 +533,7 @@ unsigned int tcp_poll(struct file *file, struct socket *sock, poll_table *wait)
 
 		if (tp->urg_data & TCP_URG_VALID)
 			mask |= POLLPRI;
-	} else if (sk->sk_state == TCP_SYN_SENT && inet_sk(sk)->defer_connect) {
+	} else if (state == TCP_SYN_SENT && inet_sk(sk)->defer_connect) {
 		/* Active TCP fastopen socket with defer_connect
 		 * Return POLLOUT so application can call write()
 		 * in order for kernel to generate SYN+data
-- 
2.7.4
