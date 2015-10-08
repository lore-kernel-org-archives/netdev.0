From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: fix RFS vs lockless listeners
Date: Thu, 08 Oct 2015 11:16:48 -0700
Message-ID: <1444328208.27760.35.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Willem de Bruijn <willemb@google.com>,
	Tom Herbert <tom@herbertland.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33765 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755309AbbJHSQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 14:16:50 -0400
Received: by pacex6 with SMTP id ex6so61628450pac.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 11:16:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Before recent TCP listener patches, we were updating listener
sk->sk_rxhash before the cloning of master socket.

children sk_rxhash was therefore correct after the normal 3WHS.

But with lockless listener, we no longer dirty/change listener sk_rxhash
as it would be racy.

We need to correctly update the child sk_rxhash, otherwise first data
packet wont hit correct cpu if RFS is used.

Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Willem de Bruijn <willemb@google.com>
Cc: Tom Herbert <tom@herbertland.com>
---
 net/ipv4/syncookies.c    |    1 +
 net/ipv4/tcp_minisocks.c |    1 +
 2 files changed, 2 insertions(+)

diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 8113c30ccf96..2dbb11331f6c 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -225,6 +225,7 @@ struct sock *tcp_get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 	child = icsk->icsk_af_ops->syn_recv_sock(sk, skb, req, dst);
 	if (child) {
 		atomic_set(&req->rsk_refcnt, 1);
+		sock_rps_save_rxhash(child, skb);
 		inet_csk_reqsk_queue_add(sk, req, child);
 	} else {
 		reqsk_free(req);
diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index 9adf1e2c3170..1079e6ad77fe 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -768,6 +768,7 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	if (!child)
 		goto listen_overflow;
 
+	sock_rps_save_rxhash(child, skb);
 	tcp_synack_rtt_meas(child, req);
 	inet_csk_reqsk_queue_drop(sk, req);
 	inet_csk_reqsk_queue_add(sk, req, child);
