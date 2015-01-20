From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 1/3] skbuff: Add skb_list_linearize()
Date: Tue, 20 Jan 2015 12:25:43 -0800
Message-ID: <1421785543-19823-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog115.obsmtp.com ([74.125.149.238]:37968 "HELO
	na3sys009aog115.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752289AbbATVI4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2015 16:08:56 -0500
Received: by mail-pa0-f45.google.com with SMTP id lf10so48108450pab.4
        for <netdev@vger.kernel.org>; Tue, 20 Jan 2015 13:08:55 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to skb_linearize(), this API takes skb list as arg and
linearize it into one big skb. STT driver patch will use this.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d7..c9194c1 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2532,6 +2532,8 @@ static inline int skb_linearize(struct sk_buff *skb)
 	return skb_is_nonlinear(skb) ? __skb_linearize(skb) : 0;
 }
 
+int skb_list_linearize(struct sk_buff *head, gfp_t gfp_mask);
+
 /**
  * skb_has_shared_frag - can any frag be overwritten
  * @skb: buffer to test
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 56db472..9ef2881 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2329,6 +2329,41 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
 }
 EXPORT_SYMBOL(skb_copy_and_csum_dev);
 
+int skb_list_linearize(struct sk_buff *head, gfp_t gfp_mask)
+{
+	struct sk_buff *skb;
+	int tlen = 0;
+	int err;
+
+	err = skb_linearize(head);
+	if (err)
+		return err;
+
+	skb = head->next;
+	while (skb) {
+		tlen += skb->len;
+		skb = skb->next;
+	}
+	err = pskb_expand_head(head, 0, tlen, gfp_mask);
+	if (err)
+		return err;
+
+	skb = head->next;
+	while (skb) {
+		err = skb_copy_bits(skb, 0, skb_tail_pointer(head), skb->len);
+		if (err)
+			return err;
+		head->tail += skb->len;
+		skb = skb->next;
+	}
+	kfree_skb_list(head->next);
+	head->next = NULL;
+	head->len += tlen;
+	head->truesize = SKB_TRUESIZE(skb_end_offset(head));
+	return 0;
+}
+EXPORT_SYMBOL(skb_list_linearize);
+
 /**
  *	skb_dequeue - remove from the head of the queue
  *	@list: list to dequeue from
-- 
1.9.1
