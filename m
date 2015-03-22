From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 8/8] ipv6: dccp: handle ICMP messages on DCCP_NEW_SYN_RECV request sockets
Date: Sun, 22 Mar 2015 10:22:25 -0700
Message-ID: <1427044945-32608-9-git-send-email-edumazet@google.com>
References: <1427044945-32608-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f73.google.com ([209.85.192.73]:34133 "EHLO
	mail-qg0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751762AbbCVRXd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 13:23:33 -0400
Received: by qgdq107 with SMTP id q107so6098486qgd.1
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 10:23:32 -0700 (PDT)
In-Reply-To: <1427044945-32608-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

dccp_v6_err() can restrict lookups to ehash table, and not to listeners.

Note this patch creates the infrastructure, but this means that ICMP
messages for request sockets are ignored until complete conversion.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv6.c | 41 ++++++++---------------------------------
 1 file changed, 8 insertions(+), 33 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index 69d8f13895ba..9d0551092c6c 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -85,11 +85,12 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		return;
 	}
 
-	sk = inet6_lookup(net, &dccp_hashinfo,
-			&hdr->daddr, dh->dccph_dport,
-			&hdr->saddr, dh->dccph_sport, inet6_iif(skb));
+	sk = __inet6_lookup_established(net, &dccp_hashinfo,
+					&hdr->daddr, dh->dccph_dport,
+					&hdr->saddr, ntohs(dh->dccph_sport),
+					inet6_iif(skb));
 
-	if (sk == NULL) {
+	if (!sk) {
 		ICMP6_INC_STATS_BH(net, __in6_dev_get(skb->dev),
 				   ICMP6_MIB_INERRORS);
 		return;
@@ -99,6 +100,9 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		inet_twsk_put(inet_twsk(sk));
 		return;
 	}
+	seq = dccp_hdr_seq(dh);
+	if (sk->sk_state == DCCP_NEW_SYN_RECV)
+		return dccp_req_err(sk, seq);
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk))
@@ -108,7 +112,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 		goto out;
 
 	dp = dccp_sk(sk);
-	seq = dccp_hdr_seq(dh);
 	if ((1 << sk->sk_state) & ~(DCCPF_REQUESTING | DCCPF_LISTEN) &&
 	    !between48(seq, dp->dccps_awl, dp->dccps_awh)) {
 		NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
@@ -149,34 +152,6 @@ static void dccp_v6_err(struct sk_buff *skb, struct inet6_skb_parm *opt,
 
 	/* Might be for an request_sock */
 	switch (sk->sk_state) {
-		struct request_sock *req;
-	case DCCP_LISTEN:
-		if (sock_owned_by_user(sk))
-			goto out;
-
-		req = inet6_csk_search_req(sk, dh->dccph_dport,
-					   &hdr->daddr, &hdr->saddr,
-					   inet6_iif(skb));
-		if (!req)
-			goto out;
-
-		/*
-		 * ICMPs are not backlogged, hence we cannot get an established
-		 * socket here.
-		 */
-		WARN_ON(req->sk != NULL);
-
-		if (!between48(seq, dccp_rsk(req)->dreq_iss,
-				    dccp_rsk(req)->dreq_gss)) {
-			NET_INC_STATS_BH(net, LINUX_MIB_OUTOFWINDOWICMPS);
-			reqsk_put(req);
-			goto out;
-		}
-
-		inet_csk_reqsk_queue_drop(sk, req);
-		reqsk_put(req);
-		goto out;
-
 	case DCCP_REQUESTING:
 	case DCCP_RESPOND:  /* Cannot happen.
 			       It can, it SYNs are crossed. --ANK */
-- 
2.2.0.rc0.207.ga3a616c
