From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-timestamp: SOCK_RAW and PING timestamping
Date: Mon, 14 Jul 2014 17:55:06 -0400
Message-ID: <1405374906-4657-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, stephen@networkplumber.org,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:36328 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756387AbaGNVzP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jul 2014 17:55:15 -0400
Received: by mail-pa0-f74.google.com with SMTP id rd3so394878pab.3
        for <netdev@vger.kernel.org>; Mon, 14 Jul 2014 14:55:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add SO_TIMESTAMPING to sockets of type PF_INET[6]/SOCK_RAW:

Add the necessary sock_tx_timestamp calls to the datapath for RAW
sockets (ping sockets already had these calls).

Fix the IP output path to pass the timestamp flags on the first
fragment also for these sockets. The existing code relies on
transhdrlen != 0 to indicate a first fragment. For these sockets,
that assumption does not hold.

This fixes http://bugzilla.kernel.org/show_bug.cgi?id=77221

Tested SOCK_RAW on IPv4 and IPv6, not PING.

Signed-off-by: Willem de Bruijn <willemb@google.com>

--

I previously submitted this as part of a new feature set. It
makes more sense to send it as a separate fix.

v1->v2:
- added IPv6
- moved tx_flags write to initial read to hit warm cache
---
 net/ipv4/ip_output.c  |  7 +++----
 net/ipv4/raw.c        |  4 ++++
 net/ipv6/ip6_output.c | 13 ++++---------
 3 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 8d3b6b0..b165568 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -962,10 +962,6 @@ alloc_new_skb:
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
-				else
-					/* only the initial fragment is
-					   time stamped */
-					cork->tx_flags = 0;
 			}
 			if (skb == NULL)
 				goto error;
@@ -976,7 +972,10 @@ alloc_new_skb:
 			skb->ip_summed = csummode;
 			skb->csum = 0;
 			skb_reserve(skb, hh_len);
+
+			/* only the initial fragment is time stamped */
 			skb_shinfo(skb)->tx_flags = cork->tx_flags;
+			cork->tx_flags = 0;
 
 			/*
 			 *	Find where to start putting bytes.
diff --git a/net/ipv4/raw.c b/net/ipv4/raw.c
index 2c65160..2054d71 100644
--- a/net/ipv4/raw.c
+++ b/net/ipv4/raw.c
@@ -365,6 +365,8 @@ static int raw_send_hdrinc(struct sock *sk, struct flowi4 *fl4,
 
 	skb->ip_summed = CHECKSUM_NONE;
 
+	sock_tx_timestamp(sk, &skb_shinfo(skb)->tx_flags);
+
 	skb->transport_header = skb->network_header;
 	err = -EFAULT;
 	if (memcpy_fromiovecend((void *)iph, from, 0, length))
@@ -606,6 +608,8 @@ back_from_confirm:
 				      &rt, msg->msg_flags);
 
 	 else {
+		sock_tx_timestamp(sk, &ipc.tx_flags);
+
 		if (!ipc.addr)
 			ipc.addr = fl4.daddr;
 		lock_sock(sk);
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9b395c6..759456f 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -1271,7 +1271,7 @@ emsgsize:
 	}
 
 	/* For UDP, check if TX timestamp is enabled */
-	if (sk->sk_type == SOCK_DGRAM)
+	if (sk->sk_type == SOCK_DGRAM || sk->sk_type == SOCK_RAW)
 		sock_tx_timestamp(sk, &tx_flags);
 
 	/*
@@ -1380,12 +1380,6 @@ alloc_new_skb:
 							   sk->sk_allocation);
 				if (unlikely(skb == NULL))
 					err = -ENOBUFS;
-				else {
-					/* Only the initial fragment
-					 * is time stamped.
-					 */
-					tx_flags = 0;
-				}
 			}
 			if (skb == NULL)
 				goto error;
@@ -1399,8 +1393,9 @@ alloc_new_skb:
 			skb_reserve(skb, hh_len + sizeof(struct frag_hdr) +
 				    dst_exthdrlen);
 
-			if (sk->sk_type == SOCK_DGRAM)
-				skb_shinfo(skb)->tx_flags = tx_flags;
+			/* Only the initial fragment is time stamped */
+			skb_shinfo(skb)->tx_flags = tx_flags;
+			tx_flags = 0;
 
 			/*
 			 *	Find where to start putting bytes
-- 
2.0.0.526.g5318336
