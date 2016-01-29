From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [PATCH net] irda: fix a potential use-after-free in ircomm_param_request
Date: Fri, 29 Jan 2016 11:58:03 -0800
Message-ID: <1454097483-29308-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: dvyukov@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Samuel Ortiz <samuel@sortiz.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f175.google.com ([209.85.192.175]:36008 "EHLO
	mail-pf0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753640AbcA2T6k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:58:40 -0500
Received: by mail-pf0-f175.google.com with SMTP id n128so46801477pfn.3
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 11:58:40 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

self->ctrl_skb is protected by self->spinlock, we should not
access it out of the lock. Move the debugging printk inside.

Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Samuel Ortiz <samuel@sortiz.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/irda/ircomm/ircomm_param.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/net/irda/ircomm/ircomm_param.c b/net/irda/ircomm/ircomm_param.c
index 3c4caa6..5728e76 100644
--- a/net/irda/ircomm/ircomm_param.c
+++ b/net/irda/ircomm/ircomm_param.c
@@ -134,11 +134,10 @@ int ircomm_param_request(struct ircomm_tty_cb *self, __u8 pi, int flush)
 		return -1;
 	}
 	skb_put(skb, count);
+	pr_debug("%s(), skb->len=%d\n", __func__, skb->len);
 
 	spin_unlock_irqrestore(&self->spinlock, flags);
 
-	pr_debug("%s(), skb->len=%d\n", __func__ , skb->len);
-
 	if (flush) {
 		/* ircomm_tty_do_softint will take care of the rest */
 		schedule_work(&self->tqueue);
-- 
1.8.3.1
