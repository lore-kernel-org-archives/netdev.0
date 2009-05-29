From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-next] tcp: fix loop in ofo handling code and reduce its
 complexity
Date: Fri, 29 May 2009 16:03:45 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0905291552240.10088@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-696208474-965172025-1243602225=:10088"
Cc: Netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:59513 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758617AbZE2NDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 09:03:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---696208474-965172025-1243602225=:10088
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: 8BIT

Somewhat luckily, I was looking into these parts with very fine
comb because I've made somewhat similar changes on the same
area (conflicts that arose weren't that lucky though). The loop
was very much overengineered recently in commit 915219441d566
(tcp: Use SKB queue and list helpers instead of doing it
by-hand), while it basically just wants to know if there are
skbs after 'skb'.

Also it got broken because skb1 = skb->next got translated into
skb1 = skb1->next (though abstracted) improperly. Note that
'skb1' is pointing to previous sk_buff than skb or NULL if at
head. Two things went wrong:
- We'll kfree 'skb' on the first iteration instead of the
  skbuff following 'skb' (it would require required SACK reneging
  to recover I think).
- The list head case where 'skb1' is NULL is checked too early
  and the loop won't execute whereas it previously did.

Conclusion, mostly revert the recent changes which makes the
cset very messy looking but using proper accessor in the
previous-like version.

The effective changes against the original can be viewed with:
  git-diff 915219441d566f1da0caa0e262be49b666159e17^ \
		net/ipv4/tcp_input.c | sed -n -e '57,70 p'

Signed-off-by: Ilpo Järvinen <ilpo.jarvinen@helsinki.fi>

---
 net/ipv4/tcp_input.c |   28 +++++++++++-----------------
 1 files changed, 11 insertions(+), 17 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index ba34a23..2bdb0da 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4481,26 +4481,20 @@ drop:
 			__skb_queue_after(&tp->out_of_order_queue, skb1, skb);
 
 		/* And clean segments covered by new one as whole. */
-		if (skb1 && !skb_queue_is_last(&tp->out_of_order_queue, skb1)) {
-			struct sk_buff *n;
+		while (!skb_queue_is_last(&tp->out_of_order_queue, skb)) {
+			skb1 = skb_queue_next(&tp->out_of_order_queue, skb);
 
-			skb1 = skb_queue_next(&tp->out_of_order_queue, skb1);
-			skb_queue_walk_from_safe(&tp->out_of_order_queue,
-						 skb1, n) {
-				if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
-					break;
-				if (before(end_seq,
-					   TCP_SKB_CB(skb1)->end_seq)) {
-					tcp_dsack_extend(sk,
-							 TCP_SKB_CB(skb1)->seq,
-							 end_seq);
-					break;
-				}
-				__skb_unlink(skb1, &tp->out_of_order_queue);
+			if (!after(end_seq, TCP_SKB_CB(skb1)->seq))
+				break;
+			if (before(end_seq, TCP_SKB_CB(skb1)->end_seq)) {
 				tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
-						 TCP_SKB_CB(skb1)->end_seq);
-				__kfree_skb(skb1);
+						 end_seq);
+				break;
 			}
+			__skb_unlink(skb1, &tp->out_of_order_queue);
+			tcp_dsack_extend(sk, TCP_SKB_CB(skb1)->seq,
+					 TCP_SKB_CB(skb1)->end_seq);
+			__kfree_skb(skb1);
 		}
 
 add_sack:
-- 
tg: (dfe9a83..) ofo/simplify-whiles (depends on: origin/master)
---696208474-965172025-1243602225=:10088--
