From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net-next 1/2] tcp: move sk_mark_napi_id() at the right place
Date: Tue, 11 Nov 2014 05:54:27 -0800
Message-ID: <1415714068-21028-2-git-send-email-edumazet@google.com>
References: <1415714068-21028-1-git-send-email-edumazet@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Willem de Bruijn <willemb@google.com>,
	Ying Cai <ycai@google.com>, Eric Dumazet <edumazet@google.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:54371 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750829AbaKKNzB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 08:55:01 -0500
Received: by mail-qc0-f202.google.com with SMTP id m20so740810qcx.5
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 05:55:00 -0800 (PST)
In-Reply-To: <1415714068-21028-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sk_mark_napi_id() is used to record for a flow napi id of incoming
packets for busypoll sake.
We should do this only on established flows, not on listeners.

This was 'working' by virtue of the socket cloning, but doing
this on SYN packets in unecessary cache line dirtying.

Even if we move sk_napi_id in the same cache line than sk_lock,
we are working to make SYN processing lockless, so it is desirable
to set sk_napi_id only for established flows.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c | 3 ++-
 net/ipv6/tcp_ipv6.c | 3 ++-
 2 files changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9c7d7621466b..8893598a4124 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1429,6 +1429,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		struct dst_entry *dst = sk->sk_rx_dst;
 
 		sock_rps_save_rxhash(sk, skb);
+		sk_mark_napi_id(sk, skb);
 		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, 0) == NULL) {
@@ -1450,6 +1451,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
+			sk_mark_napi_id(sk, skb);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk = nsk;
 				goto reset;
@@ -1661,7 +1663,6 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_mark_napi_id(sk, skb);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ace29b60813c..fd8e50b380e7 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1293,6 +1293,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		struct dst_entry *dst = sk->sk_rx_dst;
 
 		sock_rps_save_rxhash(sk, skb);
+		sk_mark_napi_id(sk, skb);
 		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, np->rx_dst_cookie) == NULL) {
@@ -1322,6 +1323,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
+			sk_mark_napi_id(sk, skb);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb)
@@ -1454,7 +1456,6 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_mark_napi_id(sk, skb);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
-- 
2.1.0.rc2.206.gedb03e5
