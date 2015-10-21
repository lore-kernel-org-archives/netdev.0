From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 1/2] ISDN: fix OOM condition for sending queued I-Frames
Date: Wed, 21 Oct 2015 14:18:38 +0200
Message-ID: <1445429919-22924-2-git-send-email-keil@b1-systems.de>
References: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Cc: Karsten Keil <keil@b1-systems.de>, isdn@linux-pingi.de,
	netdev@vger.kernel.org, wuninsu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([84.200.69.220]:57423 "EHLO
	mx1.b1-systems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbbJUMYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 08:24:08 -0400
In-Reply-To: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The skb_clone() return value was not checked and the skb_realloc_headroom()
usage was wrong, the old skb was not freed. It turned out, that the
skb_clone is not needed at all, the skb_realloc_headroom() will create a
private copy with enough headroom and the original SKB can be used for the
ACK queue.
We need to requeue the original skb if the call failed, since the upper
layer cannot be informed about memory shortage.

Thanks to Insu Yun <wuninsu@gmail.com> to remind me on this issue.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/hisax/isdnl2.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
index 18accb0..c53a53f 100644
--- a/drivers/isdn/hisax/isdnl2.c
+++ b/drivers/isdn/hisax/isdnl2.c
@@ -1247,7 +1247,7 @@ static void
 l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 {
 	struct PStack *st = fi->userdata;
-	struct sk_buff *skb;
+	struct sk_buff *skb, *nskb;
 	struct Layer2 *l2 = &st->l2;
 	u_char header[MAX_HEADER_LEN];
 	int i, hdr_space_needed;
@@ -1262,14 +1262,10 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		return;
 
 	hdr_space_needed = l2headersize(l2, 0);
-	if (hdr_space_needed > skb_headroom(skb)) {
-		struct sk_buff *orig_skb = skb;
-
-		skb = skb_realloc_headroom(skb, hdr_space_needed);
-		if (!skb) {
-			dev_kfree_skb(orig_skb);
-			return;
-		}
+	nskb = skb_realloc_headroom(skb, hdr_space_needed);
+	if (!nskb) {
+		skb_queue_head(&l2->i_queue, skb);
+		return;
 	}
 	spin_lock_irqsave(&l2->lock, flags);
 	if (test_bit(FLG_MOD128, &l2->flag))
@@ -1282,7 +1278,7 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		       p1);
 		dev_kfree_skb(l2->windowar[p1]);
 	}
-	l2->windowar[p1] = skb_clone(skb, GFP_ATOMIC);
+	l2->windowar[p1] = skb;
 
 	i = sethdraddr(&st->l2, header, CMD);
 
@@ -1295,8 +1291,8 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		l2->vs = (l2->vs + 1) % 8;
 	}
 	spin_unlock_irqrestore(&l2->lock, flags);
-	memcpy(skb_push(skb, i), header, i);
-	st->l2.l2l1(st, PH_PULL | INDICATION, skb);
+	memcpy(skb_push(nskb, i), header, i);
+	st->l2.l2l1(st, PH_PULL | INDICATION, nskb);
 	test_and_clear_bit(FLG_ACK_PEND, &st->l2.flag);
 	if (!test_and_set_bit(FLG_T200_RUN, &st->l2.flag)) {
 		FsmDelTimer(&st->l2.t203, 13);
-- 
2.1.4
