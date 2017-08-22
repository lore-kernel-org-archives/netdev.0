From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next] udp: remove unreachable ufo branches
Date: Tue, 22 Aug 2017 11:39:57 -0400
Message-ID: <20170822153957.99341-1-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33024 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933001AbdHVPkB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 11:40:01 -0400
Received: by mail-qt0-f193.google.com with SMTP id 57so7628075qtu.0
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 08:40:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Remove two references to ufo in the udp send path that are no longer
reachable now that ufo has been removed.

Commit 85f1bd9a7b5a ("udp: consistently apply ufo or fragmentation")
is a fix to ufo. It is safe to revert what remains of it.

Also, no skb can enter ip_append_page with skb_is_gso true now that
skb_shinfo(skb)->gso_type is no longer set in ip_append_page/_data.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/ipv4/ip_output.c | 12 ++++--------
 net/ipv4/udp.c       |  2 +-
 2 files changed, 5 insertions(+), 9 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index 73b0b15245b6..e8e675be60ec 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -1223,15 +1223,11 @@ ssize_t	ip_append_page(struct sock *sk, struct flowi4 *fl4, struct page *page,
 	cork->length += size;
 
 	while (size > 0) {
-		if (skb_is_gso(skb)) {
-			len = size;
-		} else {
+		/* Check if the remaining data fits into current packet. */
+		len = mtu - skb->len;
+		if (len < size)
+			len = maxfraglen - skb->len;
 
-			/* Check if the remaining data fits into current packet. */
-			len = mtu - skb->len;
-			if (len < size)
-				len = maxfraglen - skb->len;
-		}
 		if (len <= 0) {
 			struct sk_buff *skb_prev;
 			int alloclen;
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 25fb14490d6a..bf6c406bf5e7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -809,7 +809,7 @@ static int udp_send_skb(struct sk_buff *skb, struct flowi4 *fl4)
 	if (is_udplite)  				 /*     UDP-Lite      */
 		csum = udplite_csum(skb);
 
-	else if (sk->sk_no_check_tx && !skb_is_gso(skb)) {   /* UDP csum off */
+	else if (sk->sk_no_check_tx) {			 /* UDP csum off */
 
 		skb->ip_summed = CHECKSUM_NONE;
 		goto send;
-- 
2.14.1.480.gb18f417b89-goog
