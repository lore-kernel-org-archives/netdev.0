From: Pavel Emelyanov <xemul@parallels.com>
Subject: [PATCH 5/5] unix_diag: Report ack backlog info for listen sockets
Date: Wed, 28 Dec 2011 17:40:24 +0400
Message-ID: <4EFB1C48.7060407@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18041 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844Ab1L1Nk3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Dec 2011 08:40:29 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I propose to reuse the MEMINFO bit and message for this, since it's

a) also 2 values
b) symmetrical to how inet diag reports the length

Is it OK, or is it better to introduce separate bit and message?

Signed-off-by: Pavel Emelyanov <xemul@parallels.com>

---
 net/unix/diag.c |   10 ++++++++--
 1 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/net/unix/diag.c b/net/unix/diag.c
index dbae8a4..ebec5fc 100644
--- a/net/unix/diag.c
+++ b/net/unix/diag.c
@@ -113,8 +113,14 @@ static int sk_diag_show_meminfo(struct sock *sk, struct sk_buff *nlskb)
 	struct unix_diag_meminfo *mi;
 
 	mi = UNIX_DIAG_PUT(nlskb, UNIX_DIAG_MEMINFO, sizeof(*mi));
-	mi->udiag_len = sk_wmem_alloc_get(sk);
-	mi->udiag_limit = sk->sk_sndbuf;
+
+	if (sk->sk_state == TCP_LISTEN) {
+		mi->udiag_len = sk->sk_receive_queue.qlen;
+		mi->udiag_limit = sk->sk_max_ack_backlog;
+	} else {
+		mi->udiag_len = sk_wmem_alloc_get(sk);
+		mi->udiag_limit = sk->sk_sndbuf;
+	}
 
 	return 0;
 
-- 
1.5.5.6
