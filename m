From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH] tcp: skb_shift cannot cache frag ptrs past pskb_expand_head
Date: Tue, 25 Nov 2008 22:08:06 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0811252202550.14851@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-1386406584-1227643686=:14851"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:43121 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbYKYUII (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 15:08:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-1386406584-1227643686=:14851
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT


Since pskb_expand_head creates copy of the shared area we
cannot keep any frag ptr past de-cloning. This fixes the
tcpdump recvfrom -EFAULT problem.

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>
---
 net/core/skbuff.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 57555a4..133ecd6 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2018,7 +2018,10 @@ void skb_split(struct sk_buff *skb, struct sk_buff *skb1, const u32 len)
 		skb_split_no_header(skb, skb1, len, pos);
 }
 
-/* Shifting from/to a cloned skb is a no-go. */
+/* Shifting from/to a cloned skb is a no-go.
+ *
+ * Caller cannot keep skb_shinfo related pointers past calling here!
+ */
 static int skb_prepare_for_shift(struct sk_buff *skb)
 {
 	return skb_cloned(skb) && pskb_expand_head(skb, 0, 0, GFP_ATOMIC);
@@ -2070,6 +2073,8 @@ int skb_shift(struct sk_buff *tgt, struct sk_buff *skb, int shiftlen)
 			    skb_prepare_for_shift(tgt))
 				return 0;
 
+			/* All previous frag pointers might be stale! */
+			fragfrom = &skb_shinfo(skb)->frags[from];
 			fragto = &skb_shinfo(tgt)->frags[merge];
 
 			fragto->size += shiftlen;
-- 
1.5.6.5

---696208474-1386406584-1227643686=:14851--
