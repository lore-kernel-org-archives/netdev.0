From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp/dccp: fix ireq->pktopts race
Date: Fri, 30 Oct 2015 09:46:12 -0700
Message-ID: <1446223572.6254.19.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:33299 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599AbbJ3QqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Oct 2015 12:46:14 -0400
Received: by padhy1 with SMTP id hy1so73117145pad.0
        for <netdev@vger.kernel.org>; Fri, 30 Oct 2015 09:46:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

IPv6 request sockets store a pointer to skb containing the SYN packet
to be able to transfer it to full blown socket when 3WHS is done
(ireq->pktopts -> np->pktoptions)

As explained in commit 5e0724d027f0 ("tcp/dccp: fix hashdance race for
passive sessions"), we must transfer the skb only if we won the
hashdance race, if multiple cpus receive the 'ack' packet completing
3WHS at the same time.

Fixes: e994b2f0fb92 ("tcp: do not lock listener to process SYN packets")
Fixes: 079096f103fa ("tcp/dccp: install syn_recv requests into ehash table")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/ipv6.c     |   16 ++++++++--------
 net/ipv6/tcp_ipv6.c |   18 +++++++++---------
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index ef4e48ce9143..db5fc2440a23 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -477,15 +477,7 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 	/* Clone RX bits */
 	newnp->rxopt.all = np->rxopt.all;
 
-	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
-	if (ireq->pktopts != NULL) {
-		newnp->pktoptions = skb_clone(ireq->pktopts, GFP_ATOMIC);
-		consume_skb(ireq->pktopts);
-		ireq->pktopts = NULL;
-		if (newnp->pktoptions)
-			skb_set_owner_r(newnp->pktoptions, newsk);
-	}
 	newnp->opt	  = NULL;
 	newnp->mcast_oif  = inet6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
@@ -515,6 +507,14 @@ static struct sock *dccp_v6_request_recv_sock(const struct sock *sk,
 		goto out;
 	}
 	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
+	/* Clone pktoptions received with SYN, if we own the req */
+	if (*own_req && ireq->pktopts) {
+		newnp->pktoptions = skb_clone(ireq->pktopts, GFP_ATOMIC);
+		consume_skb(ireq->pktopts);
+		ireq->pktopts = NULL;
+		if (newnp->pktoptions)
+			skb_set_owner_r(newnp->pktoptions, newsk);
+	}
 
 	return newsk;
 
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index 714bc5ad096e..ea2f4d5440b5 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1084,16 +1084,7 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 	/* Clone RX bits */
 	newnp->rxopt.all = np->rxopt.all;
 
-	/* Clone pktoptions received with SYN */
 	newnp->pktoptions = NULL;
-	if (ireq->pktopts) {
-		newnp->pktoptions = skb_clone(ireq->pktopts,
-					      sk_gfp_atomic(sk, GFP_ATOMIC));
-		consume_skb(ireq->pktopts);
-		ireq->pktopts = NULL;
-		if (newnp->pktoptions)
-			skb_set_owner_r(newnp->pktoptions, newsk);
-	}
 	newnp->opt	  = NULL;
 	newnp->mcast_oif  = tcp_v6_iif(skb);
 	newnp->mcast_hops = ipv6_hdr(skb)->hop_limit;
@@ -1149,6 +1140,15 @@ static struct sock *tcp_v6_syn_recv_sock(const struct sock *sk, struct sk_buff *
 		goto out;
 	}
 	*own_req = inet_ehash_nolisten(newsk, req_to_sk(req_unhash));
+	/* Clone pktoptions received with SYN, if we own the req */
+	if (*own_req && ireq->pktopts) {
+		newnp->pktoptions = skb_clone(ireq->pktopts,
+					      sk_gfp_atomic(sk, GFP_ATOMIC));
+		consume_skb(ireq->pktopts);
+		ireq->pktopts = NULL;
+		if (newnp->pktoptions)
+			skb_set_owner_r(newnp->pktoptions, newsk);
+	}
 
 	return newsk;
 
