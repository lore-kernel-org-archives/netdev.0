From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net] tcp: zero ca_priv area when switching cc algorithms
Date: Mon, 21 Nov 2016 10:08:37 +0100
Message-ID: <1479719317-22437-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:37094 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753251AbcKUJIT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Nov 2016 04:08:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to zero out the private data area when application switches
connection to different algorithm (TCP_CONGESTION setsockopt).

When congestion ops get assigned at connect time everything is already
zeroed because sk_alloc uses GFP_ZERO flag.  But in the setsockopt case
this contains whatever previous cc placed there.

Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp_cong.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_cong.c b/net/ipv4/tcp_cong.c
index 1294af4e0127..f9038d6b109e 100644
--- a/net/ipv4/tcp_cong.c
+++ b/net/ipv4/tcp_cong.c
@@ -200,8 +200,10 @@ static void tcp_reinit_congestion_control(struct sock *sk,
 	icsk->icsk_ca_ops = ca;
 	icsk->icsk_ca_setsockopt = 1;
 
-	if (sk->sk_state != TCP_CLOSE)
+	if (sk->sk_state != TCP_CLOSE) {
+		memset(icsk->icsk_ca_priv, 0, sizeof(icsk->icsk_ca_priv));
 		tcp_init_congestion_control(sk);
+	}
 }
 
 /* Manage refcounts on socket close. */
-- 
2.7.3
