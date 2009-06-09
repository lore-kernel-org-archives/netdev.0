From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 5/6] mISDN: Do not disable IRQ in ph_data_ind()
Date: Tue, 9 Jun 2009 14:38:39 +0200
Message-ID: <8164491dd628ffcac5d61267f747997689ee256c.1244739994.git.keil@b1-systems.de>
References: <cover.1244739994.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755871AbZFKR3p@vger.kernel.org>
In-Reply-To: <cover.1244739994.git.keil@b1-systems.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fix triggering the WARN_ON_ONCE(in_irq() || irqs_disabled()); in
local_bh_enable().

Here is no need to grab this lock, this was wrong at all and may
cause a deadlock and access to freed memory, since on a TEI remove
the current listelement can be deleted under us. So this is clearly
a case for list_for_each_entry_safe.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/tei.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index bfcdd97..e04bad6 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -862,8 +862,7 @@ static int
 ph_data_ind(struct manager *mgr, struct sk_buff *skb)
 {
 	int		ret = -EINVAL;
-	struct layer2	*l2;
-	u_long		flags;
+	struct layer2	*l2, *nl2;
 	u_char		mt;
 
 	if (skb->len < 8) {
@@ -908,11 +907,9 @@ ph_data_ind(struct manager *mgr, struct sk_buff *skb)
 		new_tei_req(mgr, &skb->data[4]);
 		goto done;
 	}
-	read_lock_irqsave(&mgr->lock, flags);
-	list_for_each_entry(l2, &mgr->layer2, list) {
+	list_for_each_entry_safe(l2, nl2, &mgr->layer2, list) {
 		tei_ph_data_ind(l2->tm, mt, &skb->data[4], skb->len - 4);
 	}
-	read_unlock_irqrestore(&mgr->lock, flags);
 done:
 	return ret;
 }
-- 
1.6.0.2
