From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] net_sched: fix mirrored packets checksum
Date: Thu, 30 Jun 2016 10:15:22 -0700
Message-ID: <1467306922-7086-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Tom Herbert <tom@herbertland.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:33190 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751536AbcF3RaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 13:30:13 -0400
Received: by mail-pa0-f66.google.com with SMTP id ts6so7679400pac.0
        for <netdev@vger.kernel.org>; Thu, 30 Jun 2016 10:30:00 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to commit 9b368814b336 ("net: fix bridge multicast packet checksum validation")
we need to fixup the checksum for CHECKSUM_COMPLETE when
pushing skb on RX path. Otherwise we get similar splats.

Cc: Jamal Hadi Salim <jhs@mojatatu.com>
Cc: Tom Herbert <tom@herbertland.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 include/linux/skbuff.h | 19 +++++++++++++++++++
 net/core/skbuff.c      | 18 ------------------
 net/sched/act_mirred.c |  2 +-
 3 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index ee38a41..61ab566 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2870,6 +2870,25 @@ static inline void skb_postpush_rcsum(struct sk_buff *skb,
 }
 
 /**
+ *	skb_push_rcsum - push skb and update receive checksum
+ *	@skb: buffer to update
+ *	@len: length of data pulled
+ *
+ *	This function performs an skb_push on the packet and updates
+ *	the CHECKSUM_COMPLETE checksum.  It should be used on
+ *	receive path processing instead of skb_push unless you know
+ *	that the checksum difference is zero (e.g., a valid IP header)
+ *	or you are setting ip_summed to CHECKSUM_NONE.
+ */
+static inline unsigned char *skb_push_rcsum(struct sk_buff *skb,
+					    unsigned int len)
+{
+	skb_push(skb, len);
+	skb_postpush_rcsum(skb, skb->data, len);
+	return skb->data;
+}
+
+/**
  *	pskb_trim_rcsum - trim received skb and update checksum
  *	@skb: buffer to trim
  *	@len: new length
diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index f2b77e5..eb12d21 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -3016,24 +3016,6 @@ int skb_append_pagefrags(struct sk_buff *skb, struct page *page,
 EXPORT_SYMBOL_GPL(skb_append_pagefrags);
 
 /**
- *	skb_push_rcsum - push skb and update receive checksum
- *	@skb: buffer to update
- *	@len: length of data pulled
- *
- *	This function performs an skb_push on the packet and updates
- *	the CHECKSUM_COMPLETE checksum.  It should be used on
- *	receive path processing instead of skb_push unless you know
- *	that the checksum difference is zero (e.g., a valid IP header)
- *	or you are setting ip_summed to CHECKSUM_NONE.
- */
-static unsigned char *skb_push_rcsum(struct sk_buff *skb, unsigned len)
-{
-	skb_push(skb, len);
-	skb_postpush_rcsum(skb, skb->data, len);
-	return skb->data;
-}
-
-/**
  *	skb_pull_rcsum - pull skb and update receive checksum
  *	@skb: buffer to update
  *	@len: length of data pulled
diff --git a/net/sched/act_mirred.c b/net/sched/act_mirred.c
index 128942b..1f5bd6c 100644
--- a/net/sched/act_mirred.c
+++ b/net/sched/act_mirred.c
@@ -181,7 +181,7 @@ static int tcf_mirred(struct sk_buff *skb, const struct tc_action *a,
 
 	if (!(at & AT_EGRESS)) {
 		if (m->tcfm_ok_push)
-			skb_push(skb2, skb->mac_len);
+			skb_push_rcsum(skb2, skb->mac_len);
 	}
 
 	/* mirror is always swallowed */
-- 
2.1.0
