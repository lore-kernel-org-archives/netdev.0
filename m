From: John Dykstra <john.dykstra1@gmail.com>
Subject: [PATCH net-next-2.6] tcp: Remove redundant copy of MD5
	authentication key
Date: Wed, 19 Aug 2009 19:47:41 +0000
Message-ID: <1250711261.7166.8.camel@Maple>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.233]:53307 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752853AbZHSTrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2009 15:47:43 -0400
Received: by rv-out-0506.google.com with SMTP id f6so1364698rvb.1
        for <netdev@vger.kernel.org>; Wed, 19 Aug 2009 12:47:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen, you might want to review this, since you use MD5
authentication. 

---
Remove the copy of the MD5 authentication key from tcp_check_req().
This key has already been copied by tcp_v4_syn_recv_sock() or
tcp_v6_syn_recv_sock().

Signed-off-by: John Dykstra <john.dykstra1@gmail.com>
---
 net/ipv4/tcp_minisocks.c |   23 -----------------------
 1 files changed, 0 insertions(+), 23 deletions(-)

diff --git a/net/ipv4/tcp_minisocks.c b/net/ipv4/tcp_minisocks.c
index f8d67cc..6c8b422 100644
--- a/net/ipv4/tcp_minisocks.c
+++ b/net/ipv4/tcp_minisocks.c
@@ -657,29 +657,6 @@ struct sock *tcp_check_req(struct sock *sk, struct sk_buff *skb,
 	child = inet_csk(sk)->icsk_af_ops->syn_recv_sock(sk, skb, req, NULL);
 	if (child == NULL)
 		goto listen_overflow;
-#ifdef CONFIG_TCP_MD5SIG
-	else {
-		/* Copy over the MD5 key from the original socket */
-		struct tcp_md5sig_key *key;
-		struct tcp_sock *tp = tcp_sk(sk);
-		key = tp->af_specific->md5_lookup(sk, child);
-		if (key != NULL) {
-			/*
-			 * We're using one, so create a matching key on the
-			 * newsk structure. If we fail to get memory then we
-			 * end up not copying the key across. Shucks.
-			 */
-			char *newkey = kmemdup(key->key, key->keylen,
-					       GFP_ATOMIC);
-			if (newkey) {
-				if (!tcp_alloc_md5sig_pool())
-					BUG();
-				tp->af_specific->md5_add(child, child, newkey,
-							 key->keylen);
-			}
-		}
-	}
-#endif
 
 	inet_csk_reqsk_queue_unlink(sk, req, prev);
 	inet_csk_reqsk_queue_removed(sk, req);
-- 
1.5.4.3



