From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 3/6] net: Generalize checksum_init functions
Date: Fri, 4 Apr 2014 17:27:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404041717020.20947@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:41165 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754291AbaDEA1U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2014 20:27:20 -0400
Received: by mail-ob0-f202.google.com with SMTP id wo20so726427obc.1
        for <netdev@vger.kernel.org>; Fri, 04 Apr 2014 17:27:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a general __skb_checksum_validate function to subsume the
various checksum_init functions. This function can either init
the checksums, or do the full validation (logically check_init+
skb_check_complete)-- a flag to the function sets that.

Added several stub functions for calling __skb_checksum_validate.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 35 +++++++++++++++++++++++++++++++++++
 net/core/checksum.c    | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 67 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08074a8..6cfbd52 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2741,6 +2741,41 @@ static inline __sum16 skb_checksum_complete(struct sk_buff *skb)
 	       0 : __skb_checksum_complete(skb);
 }
 
+__sum16 __skb_checksum_validate(struct sk_buff *skb, int proto, bool complete,
+		bool zero_check_okay, __sum16 check,
+		__wsum (*compute_pseudo)(struct sk_buff *skb, int proto));
+
+static inline __sum16 skb_checksum_init(struct sk_buff *skb, int proto,
+		__wsum (*compute_pseudo)(struct sk_buff *skb, int proto)) {
+	return __skb_checksum_validate(skb, proto, false, false,
+				       0, compute_pseudo);
+}
+
+static inline __sum16 skb_checksum_init_zero_check(struct sk_buff *skb,
+		int proto, __sum16 check,
+		__wsum (*compute_pseudo)(struct sk_buff *skb, int proto)) {
+	return __skb_checksum_validate(skb, proto, false, true,
+				       check, compute_pseudo);
+}
+
+static inline __sum16 skb_checksum_validate(struct sk_buff *skb, int proto,
+		__wsum (*compute_pseudo)(struct sk_buff *skb, int proto)) {
+	return __skb_checksum_validate(skb, proto, true, false,
+				       0, compute_pseudo);
+}
+
+static inline __sum16 skb_checksum_simple_validate(struct sk_buff *skb)
+{
+	return __skb_checksum_validate(skb, 0, true, false, 0, NULL);
+}
+
+static inline __sum16 skb_checksum_validate_zero_check(struct sk_buff *skb,
+	       int proto, __sum16 check,
+	       __wsum (*compute_pseudo)(struct sk_buff *skb, int proto)) {
+	return __skb_checksum_validate(skb, proto, true, true,
+				       check, compute_pseudo);
+}
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 void nf_conntrack_destroy(struct nf_conntrack *nfct);
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
diff --git a/net/core/checksum.c b/net/core/checksum.c
index 2954f86..b0df8c7 100644
--- a/net/core/checksum.c
+++ b/net/core/checksum.c
@@ -24,3 +24,35 @@ __sum16 __skb_checksum_complete(struct sk_buff *skb)
 	return __skb_checksum_complete_head(skb, skb->len);
 }
 EXPORT_SYMBOL(__skb_checksum_complete);
+
+
+__sum16 __skb_checksum_validate(struct sk_buff *skb, int proto, bool complete,
+				bool zero_check_okay, __sum16 check,
+				__wsum (*compute_pseudo)(struct sk_buff *skb,
+							 int proto))
+{
+	__wsum psum;
+
+	if (skb_csum_unnecessary(skb)) {
+		return 0;
+	} else if (zero_check_okay && !check) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return 0;
+	}
+
+	psum = compute_pseudo ? compute_pseudo(skb, proto) : 0;
+
+	if (skb->ip_summed == CHECKSUM_COMPLETE) {
+		if (!csum_fold(csum_add(psum, skb->csum))) {
+			skb->ip_summed = CHECKSUM_UNNECESSARY;
+			return 0;
+		}
+	}
+
+	skb->csum = psum;
+
+	if (complete || skb->len <= 76)
+		return __skb_checksum_complete(skb);
+
+	return 0;
+}
-- 
1.9.1.423.g4596e3a
