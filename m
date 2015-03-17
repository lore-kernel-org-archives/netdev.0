From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/6] netfilter: tproxy: prepare TCP_NEW_SYN_RECV support
Date: Mon, 16 Mar 2015 21:06:16 -0700
Message-ID: <1426565180-26844-3-git-send-email-edumazet@google.com>
References: <1426565180-26844-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:34607 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750713AbbCQEGj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 00:06:39 -0400
Received: by padet14 with SMTP id et14so12448139pad.1
        for <netdev@vger.kernel.org>; Mon, 16 Mar 2015 21:06:39 -0700 (PDT)
In-Reply-To: <1426565180-26844-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

TCP request socks soon will be visible in ehash table.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/netfilter/xt_TPROXY.c | 18 ++++++++++++------
 1 file changed, 12 insertions(+), 6 deletions(-)

diff --git a/net/netfilter/xt_TPROXY.c b/net/netfilter/xt_TPROXY.c
index ef8a926752a9..165b77ce9aa9 100644
--- a/net/netfilter/xt_TPROXY.c
+++ b/net/netfilter/xt_TPROXY.c
@@ -42,15 +42,21 @@ enum nf_tproxy_lookup_t {
 
 static bool tproxy_sk_is_transparent(struct sock *sk)
 {
-	if (sk->sk_state != TCP_TIME_WAIT) {
-		if (inet_sk(sk)->transparent)
-			return true;
-		sock_put(sk);
-	} else {
+	switch (sk->sk_state) {
+	case TCP_TIME_WAIT:
 		if (inet_twsk(sk)->tw_transparent)
 			return true;
-		inet_twsk_put(inet_twsk(sk));
+		break;
+	case TCP_NEW_SYN_RECV:
+		if (inet_rsk(inet_reqsk(sk))->no_srccheck)
+			return true;
+		break;
+	default:
+		if (inet_sk(sk)->transparent)
+			return true;
 	}
+
+	sock_gen_put(sk);
 	return false;
 }
 
-- 
2.2.0.rc0.207.ga3a616c
