From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v3 net-next 1/2] net: introduce skb_postpush_rcsum() helper
Date: Wed,  8 Apr 2015 16:26:14 -0700
Message-ID: <1428535575-7736-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Thomas Graf <tgraf@suug.ch>, Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:32958 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754856AbbDHX0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 19:26:22 -0400
Received: by pdbnk13 with SMTP id nk13so131535665pdb.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 16:26:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to skb_postpull_rcsum() introduce skb_postpush_rcsum() helper

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

next patch is also using skb_postpush_rcsum()

 include/linux/skbuff.h |   13 +++++++++++++
 net/core/filter.c      |    4 ++--
 2 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 36f3f43c0117..b7a313d13d7b 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2586,6 +2586,19 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 }
 
+/**
+ *	skb_postpush_rcsum - update checksum for skb after push
+ *	@skb: buffer to update
+ *	@start: start of data after push
+ *	@len: length of data pushed
+ */
+static inline void skb_postpush_rcsum(struct sk_buff *skb,
+				      const void *start, unsigned int len)
+{
+	if (skb->ip_summed == CHECKSUM_COMPLETE)
+		skb->csum = csum_add(skb->csum, csum_partial(start, len, 0));
+}
+
 unsigned char *skb_pull_rcsum(struct sk_buff *skb, unsigned int len);
 
 /**
diff --git a/net/core/filter.c b/net/core/filter.c
index b669e75d2b36..e5872704c28b 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1213,8 +1213,8 @@ static u64 bpf_skb_store_bytes(u64 r1, u64 r2, u64 r3, u64 r4, u64 flags)
 		/* skb_store_bits cannot return -EFAULT here */
 		skb_store_bits(skb, offset, ptr, len);
 
-	if (BPF_RECOMPUTE_CSUM(flags) && skb->ip_summed == CHECKSUM_COMPLETE)
-		skb->csum = csum_add(skb->csum, csum_partial(ptr, len, 0));
+	if (BPF_RECOMPUTE_CSUM(flags))
+		skb_postpush_rcsum(skb, ptr, len);
 	return 0;
 }
 
-- 
1.7.9.5
