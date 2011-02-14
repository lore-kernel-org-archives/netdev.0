From: David Miller <davem@davemloft.net>
Subject: Re: potential null pointer dereference in
 drivers/isdn/hisax/isdnl2.c
Date: Sun, 13 Feb 2011 16:53:09 -0800 (PST)
Message-ID: <20110213.165309.123985803.davem@davemloft.net>
References: <alpine.LNX.2.00.1102032121180.15101@swampdragon.chaosbits.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	tj@kernel.org, isdn@linux-pingi.de
To: jj@chaosbits.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42111
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755316Ab1BNAwd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 19:52:33 -0500
In-Reply-To: <alpine.LNX.2.00.1102032121180.15101@swampdragon.chaosbits.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesper Juhl <jj@chaosbits.net>
Date: Thu, 3 Feb 2011 21:27:56 +0100 (CET)

> In drivers/isdn/hisax/isdnl2.c:l2_pull_iqueue() we have this:
> 
> 	...
> 		skb = alloc_skb(oskb->len + i, GFP_ATOMIC);
> 		memcpy(skb_put(skb, i), header, i);
> 	...
> 
> If alloc_skb() fails and returns NULL then the second line will cause a 
> NULL pointer dereference - skb_put() gives the pointer to 
> skb_tail_pointer() which dereferences it.
> 
> I'm not quite sure how this should be dealt with, so I'll just report it 
> rather than submit a patch. Happy bug fixing :-)

Thanks Jesper, I'll fix this like so:

--------------------
hisax: Fix unchecked alloc_skb() return.

Jesper Juhl noticed that l2_pull_iqueue() does not
check to see if alloc_skb() fails.

Fix this by first trying to reallocate the headroom
if necessary, rather than later after we've made hard
to undo state changes.

Reported-by: Jesper Juhl <jj@chaosbits.net>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/isdn/hisax/isdnl2.c |   35 ++++++++++++++++++++---------------
 1 files changed, 20 insertions(+), 15 deletions(-)

diff --git a/drivers/isdn/hisax/isdnl2.c b/drivers/isdn/hisax/isdnl2.c
index 0858791..98ac835 100644
--- a/drivers/isdn/hisax/isdnl2.c
+++ b/drivers/isdn/hisax/isdnl2.c
@@ -1243,14 +1243,21 @@ l2_st7_tout_203(struct FsmInst *fi, int event, void *arg)
 	st->l2.rc = 0;
 }
 
+static int l2_hdr_space_needed(struct Layer2 *l2)
+{
+	int len = test_bit(FLG_LAPD, &l2->flag) ? 2 : 1;
+
+	return len + (test_bit(FLG_LAPD, &l2->flag) ? 2 : 1);
+}
+
 static void
 l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 {
 	struct PStack *st = fi->userdata;
-	struct sk_buff *skb, *oskb;
+	struct sk_buff *skb;
 	struct Layer2 *l2 = &st->l2;
 	u_char header[MAX_HEADER_LEN];
-	int i;
+	int i, hdr_space_needed;
 	int unsigned p1;
 	u_long flags;
 
@@ -1261,6 +1268,16 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 	if (!skb)
 		return;
 
+	hdr_space_needed = l2_hdr_space_needed(l2);
+	if (hdr_space_needed > skb_headroom(skb)) {
+		struct sk_buff *orig_skb = skb;
+
+		skb = skb_realloc_headroom(skb, hdr_space_needed);
+		if (!skb) {
+			dev_kfree_skb(orig_skb);
+			return;
+		}
+	}
 	spin_lock_irqsave(&l2->lock, flags);
 	if(test_bit(FLG_MOD128, &l2->flag))
 		p1 = (l2->vs - l2->va) % 128;
@@ -1285,19 +1302,7 @@ l2_pull_iqueue(struct FsmInst *fi, int event, void *arg)
 		l2->vs = (l2->vs + 1) % 8;
 	}
 	spin_unlock_irqrestore(&l2->lock, flags);
-	p1 = skb->data - skb->head;
-	if (p1 >= i)
-		memcpy(skb_push(skb, i), header, i);
-	else {
-		printk(KERN_WARNING
-		"isdl2 pull_iqueue skb header(%d/%d) too short\n", i, p1);
-		oskb = skb;
-		skb = alloc_skb(oskb->len + i, GFP_ATOMIC);
-		memcpy(skb_put(skb, i), header, i);
-		skb_copy_from_linear_data(oskb,
-					  skb_put(skb, oskb->len), oskb->len);
-		dev_kfree_skb(oskb);
-	}
+	memcpy(skb_push(skb, i), header, i);
 	st->l2.l2l1(st, PH_PULL | INDICATION, skb);
 	test_and_clear_bit(FLG_ACK_PEND, &st->l2.flag);
 	if (!test_and_set_bit(FLG_T200_RUN, &st->l2.flag)) {
-- 
1.7.4.1

