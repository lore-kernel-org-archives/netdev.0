From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 1/2] net: introduce skb_postpush_rcsum() helper
Date: Tue,  7 Apr 2015 18:03:44 -0700
Message-ID: <1428455025-5945-1-git-send-email-ast@plumgrid.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f182.google.com ([209.85.192.182]:34532 "EHLO
	mail-pd0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752909AbbDHBDz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2015 21:03:55 -0400
Received: by pdbqa5 with SMTP id qa5so39648740pdb.1
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2015 18:03:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

similar to skb_postpull_rcsum() introduce skb_postpush_rcsum() helper

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---

skb_postpush_rcsum() is also used in the next patch.

 include/linux/skbuff.h |    7 +++++++
 net/core/filter.c      |    4 ++--
 2 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 36f3f43c0117..3c5b191869bb 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2586,6 +2586,13 @@ static inline void skb_postpull_rcsum(struct sk_buff *skb,
 		skb->csum = csum_sub(skb->csum, csum_partial(start, len, 0));
 }
 
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
