From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] gre: fix a possible skb leak
Date: Mon, 24 Jun 2013 06:26:00 -0700
Message-ID: <1372080360.3301.61.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Pravin B Shelar <pshelar@nicira.com>,
	Daniel Borkmann <dborkman@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:45982 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750797Ab3FXNZ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Jun 2013 09:25:59 -0400
Received: by mail-ea0-f175.google.com with SMTP id z7so6069986eaf.34
        for <netdev@vger.kernel.org>; Mon, 24 Jun 2013 06:25:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

commit 68c331631143 ("v4 GRE: Add TCP segmentation offload for GRE")
added a possible skb leak, because it frees only the head of segment
list, in case a skb_linearize() call fails.

This patch adds a kfree_skb_list() helper to fix the bug.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
Cc: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/skbuff.h |    1 +
 net/core/skbuff.c      |   20 ++++++++++++--------
 net/ipv4/gre.c         |    2 +-
 3 files changed, 14 insertions(+), 9 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 9c676eae..dec1748 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -627,6 +627,7 @@ static inline struct rtable *skb_rtable(const struct sk_buff *skb)
 }
 
 extern void kfree_skb(struct sk_buff *skb);
+extern void kfree_skb_list(struct sk_buff *segs);
 extern void skb_tx_error(struct sk_buff *skb);
 extern void consume_skb(struct sk_buff *skb);
 extern void	       __kfree_skb(struct sk_buff *skb);
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index cfd777b..1c1738c 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -483,15 +483,8 @@ EXPORT_SYMBOL(skb_add_rx_frag);
 
 static void skb_drop_list(struct sk_buff **listp)
 {
-	struct sk_buff *list = *listp;
-
+	kfree_skb_list(*listp);
 	*listp = NULL;
-
-	do {
-		struct sk_buff *this = list;
-		list = list->next;
-		kfree_skb(this);
-	} while (list);
 }
 
 static inline void skb_drop_fraglist(struct sk_buff *skb)
@@ -651,6 +644,17 @@ void kfree_skb(struct sk_buff *skb)
 }
 EXPORT_SYMBOL(kfree_skb);
 
+void kfree_skb_list(struct sk_buff *segs)
+{
+	while (segs) {
+		struct sk_buff *next = segs->next;
+
+		kfree_skb(segs);
+		segs = next;
+	}
+}
+EXPORT_SYMBOL(kfree_skb_list);
+
 /**
  *	skb_tx_error - report an sk_buff xmit error
  *	@skb: buffer that triggered an error
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index b2e805a..7856d16 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -178,7 +178,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
 				err = __skb_linearize(skb);
 				if (err) {
-					kfree_skb(segs);
+					kfree_skb_list(segs);
 					segs = ERR_PTR(err);
 					goto out;
 				}
