From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net-timestamp: cumulative tcp timestamping fixes
Date: Wed,  6 Aug 2014 15:09:44 -0400
Message-ID: <1407352184-26058-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	richardcochran@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f73.google.com ([209.85.213.73]:39925 "EHLO
	mail-yh0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737AbaHFTJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Aug 2014 15:09:52 -0400
Received: by mail-yh0-f73.google.com with SMTP id f73so395702yha.0
        for <netdev@vger.kernel.org>; Wed, 06 Aug 2014 12:09:51 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A set of small fixes pointed out just after the merge:
- make tcp_tx_timestamp static
- make tcp_gso_tstamp static
- use before() to compare TCP seqno, instead of cast to u64
- add tstamp to tx_flags in GSO, instead of overwrite tx_flags
- record skb_shinfo(skb)->tskey for all timestamps, also HW.
- optimization in tcp_tx_timestamp:
  call sock_tx_timestamp only if a tstamp option is set.

Signed-off-by: Willem de Bruijn <willemb@google.com>
Fixes: 4ed2d765dfac ("net-timestamp: TCP timestamping")

---

The sock_tx_timestamp optimization can also apply to others callers.
Basically, the following and related changes to net/socket.c

-void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);
+void sock_tx_timestamp(struct sock *sk, __u8 *tx_flags) {
+       if (sk->sk_tsflags)
+               __sock_tx_timestamp(sk, tx_flags);
+}
+
+void __sock_tx_timestamp(struct sock *sk, __u8 *tx_flags);

But that is less critical and this patch combines enough items
already. I plan to send it as a separate patch once net-next
reopens, unless you prefer me to squash it into this one.
---
 net/ipv4/tcp.c         | 12 +++++++-----
 net/ipv4/tcp_offload.c |  8 ++++----
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 744af67..181b70e 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -426,13 +426,15 @@ void tcp_init_sock(struct sock *sk)
 }
 EXPORT_SYMBOL(tcp_init_sock);
 
-void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
+static void tcp_tx_timestamp(struct sock *sk, struct sk_buff *skb)
 {
-	struct skb_shared_info *shinfo = skb_shinfo(skb);
+	if (sk->sk_tsflags) {
+		struct skb_shared_info *shinfo = skb_shinfo(skb);
 
-	sock_tx_timestamp(sk, &shinfo->tx_flags);
-	if (shinfo->tx_flags & SKBTX_ANY_SW_TSTAMP)
-		shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
+		sock_tx_timestamp(sk, &shinfo->tx_flags);
+		if (shinfo->tx_flags & SKBTX_ANY_TSTAMP)
+			shinfo->tskey = TCP_SKB_CB(skb)->seq + skb->len - 1;
+	}
 }
 
 /*
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index f597119..bc1b83c 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -14,12 +14,12 @@
 #include <net/tcp.h>
 #include <net/protocol.h>
 
-void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq, unsigned int seq,
-		    unsigned int mss)
+static void tcp_gso_tstamp(struct sk_buff *skb, unsigned int ts_seq,
+			   unsigned int seq, unsigned int mss)
 {
 	while (skb) {
-		if (ts_seq < (__u64) seq + mss) {
-			skb_shinfo(skb)->tx_flags = SKBTX_SW_TSTAMP;
+		if (before(ts_seq, seq + mss)) {
+			skb_shinfo(skb)->tx_flags |= SKBTX_SW_TSTAMP;
 			skb_shinfo(skb)->tskey = ts_seq;
 			return;
 		}
-- 
2.0.0.526.g5318336
