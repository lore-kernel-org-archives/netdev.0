From: gfree.wind@vip.163.com
Subject: [PATCH net-next] ppp: remove unnecessary bh disable in xmit path
Date: Thu,  1 Jun 2017 17:58:39 +0800
Message-ID: <1496311119-59204-1-git-send-email-gfree.wind@vip.163.com>
Cc: Gao Feng <gfree.wind@vip.163.com>
To: paulus@samba.org, linux-ppp@vger.kernel.org, g.nault@alphalink.fr,
        netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gao Feng <gfree.wind@vip.163.com>

Since the commit 55454a565836 ("ppp: avoid dealock on recursive xmit"),
the PPP xmit path is protected by wrapper functions which disable the
bh already. So it is unnecessary to disable the bh again in the real
xmit path.

Signed-off-by: Gao Feng <gfree.wind@vip.163.com>
---
 drivers/net/ppp/ppp_generic.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index f9c0e62..bbded33 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -1618,7 +1618,7 @@ static void ppp_xmit_process(struct ppp *ppp)
 		list = list->next;
 		pch = list_entry(list, struct channel, clist);
 
-		spin_lock_bh(&pch->downl);
+		spin_lock(&pch->downl);
 		if (pch->chan) {
 			if (pch->chan->ops->start_xmit(pch->chan, skb))
 				ppp->xmit_pending = NULL;
@@ -1627,7 +1627,7 @@ static void ppp_xmit_process(struct ppp *ppp)
 			kfree_skb(skb);
 			ppp->xmit_pending = NULL;
 		}
-		spin_unlock_bh(&pch->downl);
+		spin_unlock(&pch->downl);
 		return;
 	}
 
@@ -1757,7 +1757,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		}
 
 		/* check the channel's mtu and whether it is still attached. */
-		spin_lock_bh(&pch->downl);
+		spin_lock(&pch->downl);
 		if (pch->chan == NULL) {
 			/* can't use this channel, it's being deregistered */
 			if (pch->speed == 0)
@@ -1765,7 +1765,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 			else
 				totspeed -= pch->speed;
 
-			spin_unlock_bh(&pch->downl);
+			spin_unlock(&pch->downl);
 			pch->avail = 0;
 			totlen = len;
 			totfree--;
@@ -1816,7 +1816,7 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		 */
 		if (flen <= 0) {
 			pch->avail = 2;
-			spin_unlock_bh(&pch->downl);
+			spin_unlock(&pch->downl);
 			continue;
 		}
 
@@ -1861,14 +1861,14 @@ static int ppp_mp_explode(struct ppp *ppp, struct sk_buff *skb)
 		len -= flen;
 		++ppp->nxseq;
 		bits = 0;
-		spin_unlock_bh(&pch->downl);
+		spin_unlock(&pch->downl);
 	}
 	ppp->nxchan = i;
 
 	return 1;
 
  noskb:
-	spin_unlock_bh(&pch->downl);
+	spin_unlock(&pch->downl);
 	if (ppp->debug & 1)
 		netdev_err(ppp->dev, "PPP: no memory (fragment)\n");
 	++ppp->dev->stats.tx_errors;
@@ -1883,7 +1883,7 @@ static void __ppp_channel_push(struct channel *pch)
 	struct sk_buff *skb;
 	struct ppp *ppp;
 
-	spin_lock_bh(&pch->downl);
+	spin_lock(&pch->downl);
 	if (pch->chan) {
 		while (!skb_queue_empty(&pch->file.xq)) {
 			skb = skb_dequeue(&pch->file.xq);
@@ -1897,14 +1897,14 @@ static void __ppp_channel_push(struct channel *pch)
 		/* channel got deregistered */
 		skb_queue_purge(&pch->file.xq);
 	}
-	spin_unlock_bh(&pch->downl);
+	spin_unlock(&pch->downl);
 	/* see if there is anything from the attached unit to be sent */
 	if (skb_queue_empty(&pch->file.xq)) {
-		read_lock_bh(&pch->upl);
+		read_lock(&pch->upl);
 		ppp = pch->ppp;
 		if (ppp)
 			__ppp_xmit_process(ppp);
-		read_unlock_bh(&pch->upl);
+		read_unlock(&pch->upl);
 	}
 }
 
-- 
1.9.1


