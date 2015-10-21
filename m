From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 2/2] mISDN: fix OOM condition for sending queued I-Frames
Date: Wed, 21 Oct 2015 14:18:39 +0200
Message-ID: <1445429919-22924-3-git-send-email-keil@b1-systems.de>
References: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Cc: Karsten Keil <keil@b1-systems.de>, isdn@linux-pingi.de,
	netdev@vger.kernel.org, wuninsu@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.b1-systems.de ([84.200.69.220]:57421 "EHLO
	mx1.b1-systems.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbbJUMYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 08:24:08 -0400
In-Reply-To: <1445429919-22924-1-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old code did not check the return value of skb_clone().
The extra skb_clone() is not needed at all, if using skb_realloc_headroom()
instead, which gives us a private copy with enough headroom as well.
We need to requeue the original skb if the call failed, because we cannot
inform upper layers about the data loss. Restructure the code to minimise
rollback effort if it happens.
This fix kernel bug #86091

Thanks to Insu Yun <wuninsu@gmail.com> to remind me on this issue.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/layer2.c | 54 +++++++++++++++++----------------------------
 1 file changed, 20 insertions(+), 34 deletions(-)

diff --git a/drivers/isdn/mISDN/layer2.c b/drivers/isdn/mISDN/layer2.c
index 949cabb..5eb380a 100644
--- a/drivers/isdn/mISDN/layer2.c
+++ b/drivers/isdn/mISDN/layer2.c
@@ -1476,7 +1476,7 @@ static void
 l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 {
 	struct layer2	*l2 = fi->userdata;
-	struct sk_buff	*skb, *nskb, *oskb;
+	struct sk_buff	*skb, *nskb;
 	u_char		header[MAX_L2HEADER_LEN];
 	u_int		i, p1;
 
@@ -1486,48 +1486,34 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 	skb = skb_dequeue(&l2->i_queue);
 	if (!skb)
 		return;
-
-	if (test_bit(FLG_MOD128, &l2->flag))
-		p1 = (l2->vs - l2->va) % 128;
-	else
-		p1 = (l2->vs - l2->va) % 8;
-	p1 = (p1 + l2->sow) % l2->window;
-	if (l2->windowar[p1]) {
-		printk(KERN_WARNING "%s: l2 try overwrite ack queue entry %d\n",
-		       mISDNDevName4ch(&l2->ch), p1);
-		dev_kfree_skb(l2->windowar[p1]);
-	}
-	l2->windowar[p1] = skb;
 	i = sethdraddr(l2, header, CMD);
 	if (test_bit(FLG_MOD128, &l2->flag)) {
 		header[i++] = l2->vs << 1;
 		header[i++] = l2->vr << 1;
+	} else
+		header[i++] = (l2->vr << 5) | (l2->vs << 1);
+	nskb = skb_realloc_headroom(skb, i);
+	if (!nskb) {
+		printk(KERN_WARNING "%s: no headroom(%d) copy for IFrame\n",
+		       mISDNDevName4ch(&l2->ch), i);
+		skb_queue_head(&l2->i_queue, skb);
+		return;
+	}
+	if (test_bit(FLG_MOD128, &l2->flag)) {
+		p1 = (l2->vs - l2->va) % 128;
 		l2->vs = (l2->vs + 1) % 128;
 	} else {
-		header[i++] = (l2->vr << 5) | (l2->vs << 1);
+		p1 = (l2->vs - l2->va) % 8;
 		l2->vs = (l2->vs + 1) % 8;
 	}
-
-	nskb = skb_clone(skb, GFP_ATOMIC);
-	p1 = skb_headroom(nskb);
-	if (p1 >= i)
-		memcpy(skb_push(nskb, i), header, i);
-	else {
-		printk(KERN_WARNING
-		       "%s: L2 pull_iqueue skb header(%d/%d) too short\n",
-		       mISDNDevName4ch(&l2->ch), i, p1);
-		oskb = nskb;
-		nskb = mI_alloc_skb(oskb->len + i, GFP_ATOMIC);
-		if (!nskb) {
-			dev_kfree_skb(oskb);
-			printk(KERN_WARNING "%s: no skb mem in %s\n",
-			       mISDNDevName4ch(&l2->ch), __func__);
-			return;
-		}
-		memcpy(skb_put(nskb, i), header, i);
-		memcpy(skb_put(nskb, oskb->len), oskb->data, oskb->len);
-		dev_kfree_skb(oskb);
+	p1 = (p1 + l2->sow) % l2->window;
+	if (l2->windowar[p1]) {
+		printk(KERN_WARNING "%s: l2 try overwrite ack queue entry %d\n",
+		       mISDNDevName4ch(&l2->ch), p1);
+		dev_kfree_skb(l2->windowar[p1]);
 	}
+	l2->windowar[p1] = skb;
+	memcpy(skb_push(nskb, i), header, i);
 	l2down(l2, PH_DATA_REQ, l2_newid(l2), nskb);
 	test_and_clear_bit(FLG_ACK_PEND, &l2->flag);
 	if (!test_and_set_bit(FLG_T200_RUN, &l2->flag)) {
-- 
2.1.4
