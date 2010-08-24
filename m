From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/5] drivers/net/irda: Eliminate memory leak
Date: Tue, 24 Aug 2010 16:38:33 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1008241638130.15172@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Samuel Ortiz <samuel@sortiz.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <julia@diku.dk>

dev_alloc_skb allocates some memory, so that memory should be freed before
leaving the function in an error case.

Corrected some typos in a nearby comment as well.

A simplified version of the semantic match that finds this problem is:
(http://coccinelle.lip6.fr/)

// <smpl>
@r exists@
local idexpression x;
expression E;
identifier f1;
iterator I;
@@

x = dev_alloc_skb(...);
<... when != x
     when != true (x == NULL || ...)
     when != if (...) { <+...x...+> }
     when != I (...) { <+...x...+> }
(
 x == NULL
|
 x == E
|
 x->f1
)
...>
* return ...;
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/irda/via-ircc.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/irda/via-ircc.c b/drivers/net/irda/via-ircc.c
index b0a6cd8..67c0ad4 100644
--- a/drivers/net/irda/via-ircc.c
+++ b/drivers/net/irda/via-ircc.c
@@ -1182,12 +1182,13 @@ F01_E */
 
 		skb = dev_alloc_skb(len + 1 - 4);
 		/*
-		 * if frame size,data ptr,or skb ptr are wrong ,the get next
+		 * if frame size, data ptr, or skb ptr are wrong, then get next
 		 * entry.
 		 */
 		if ((skb == NULL) || (skb->data == NULL) ||
 		    (self->rx_buff.data == NULL) || (len < 6)) {
 			self->netdev->stats.rx_dropped++;
+			kfree_skb(skb);
 			return TRUE;
 		}
 		skb_reserve(skb, 1);
