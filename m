From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: output path optimizations
Date: Tue, 07 Aug 2012 14:19:56 +0200
Message-ID: <1344341996.28967.87.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40574 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752548Ab2HGMUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2012 08:20:02 -0400
Received: by bkwj10 with SMTP id j10so1419029bkw.19
        for <netdev@vger.kernel.org>; Tue, 07 Aug 2012 05:20:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

1) Avoid dirtying neighbour's confirmed field.

  TCP workloads hits this cache line for each incoming ACK.
  Lets write n->confirmed only if there is a jiffie change.

2) Optimize neigh_hh_output() for the common Ethernet case, were
   hh_len is less than 16 bytes. Replace the memcpy() call
   by two inlined 64bit load/stores on x86_64.

Bench results using udpflood test, with -C option (MSG_CONFIRM flag
added to sendto(), to reproduce the n->confirmed dirtying on UDP)

24 threads doing 1.000.000 UDP sendto() on dummy device, 4 runs.

before : 2.247s, 2.235s, 2.247s, 2.318s
after  : 1.884s, 1.905s, 1.891s, 1.895s

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/dst.h       |   10 +++++++---
 include/net/neighbour.h |   14 +++++++++-----
 2 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/include/net/dst.h b/include/net/dst.h
index baf5978..77f52f7 100644
--- a/include/net/dst.h
+++ b/include/net/dst.h
@@ -396,11 +396,15 @@ static inline void dst_confirm(struct dst_entry *dst)
 static inline int dst_neigh_output(struct dst_entry *dst, struct neighbour *n,
 				   struct sk_buff *skb)
 {
-	struct hh_cache *hh;
+	const struct hh_cache *hh;
+
+	if (dst->pending_confirm) {
+		unsigned long now = jiffies;
 
-	if (unlikely(dst->pending_confirm)) {
-		n->confirmed = jiffies;
 		dst->pending_confirm = 0;
+		/* avoid dirtying neighbour */
+		if (n->confirmed != now)
+			n->confirmed = now;
 	}
 
 	hh = &n->hh;
diff --git a/include/net/neighbour.h b/include/net/neighbour.h
index 344d898..0dab173 100644
--- a/include/net/neighbour.h
+++ b/include/net/neighbour.h
@@ -334,18 +334,22 @@ static inline int neigh_hh_bridge(struct hh_cache *hh, struct sk_buff *skb)
 }
 #endif
 
-static inline int neigh_hh_output(struct hh_cache *hh, struct sk_buff *skb)
+static inline int neigh_hh_output(const struct hh_cache *hh, struct sk_buff *skb)
 {
 	unsigned int seq;
 	int hh_len;
 
 	do {
-		int hh_alen;
-
 		seq = read_seqbegin(&hh->hh_lock);
 		hh_len = hh->hh_len;
-		hh_alen = HH_DATA_ALIGN(hh_len);
-		memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
+		if (likely(hh_len <= HH_DATA_MOD)) {
+			/* this is inlined by gcc */
+			memcpy(skb->data - HH_DATA_MOD, hh->hh_data, HH_DATA_MOD);
+		} else {
+			int hh_alen = HH_DATA_ALIGN(hh_len);
+
+			memcpy(skb->data - hh_alen, hh->hh_data, hh_alen);
+		}
 	} while (read_seqretry(&hh->hh_lock, seq));
 
 	skb_push(skb, hh_len);
