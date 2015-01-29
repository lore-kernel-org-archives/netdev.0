From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next v2 1/6] skbuff: Add skb_list_linearize()
Date: Thu, 29 Jan 2015 15:29:24 -0800
Message-ID: <1422574164-1860-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog124.obsmtp.com ([74.125.149.151]:56884 "HELO
	na3sys009aog124.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1758806AbbA2X31 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jan 2015 18:29:27 -0500
Received: by mail-pa0-f43.google.com with SMTP id eu11so44470764pac.2
        for <netdev@vger.kernel.org>; Thu, 29 Jan 2015 15:29:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to skb_linearize(), this API takes skb list as arg and
linearize it into one big skb. STT driver patch will use this.

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
Fixed according to comments from Eric.
---
 include/linux/skbuff.h |  2 ++
 net/core/skbuff.c      | 34 ++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

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
index 56db472..d6358a7 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -2329,6 +2329,40 @@ void skb_copy_and_csum_dev(const struct sk_buff *skb, u8 *to)
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
+	return 0;
+}
+EXPORT_SYMBOL(skb_list_linearize);
+
 /**
  *	skb_dequeue - remove from the head of the queue
  *	@list: list to dequeue from
-- 
1.9.1
