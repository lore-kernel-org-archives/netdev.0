From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/9 v2] net: Generalize checksum_init functions
Date: Sat, 26 Apr 2014 14:25:30 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404261400430.26913@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f201.google.com ([209.85.220.201]:60809 "EHLO
	mail-vc0-f201.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbaDZVZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Apr 2014 17:25:33 -0400
Received: by mail-vc0-f201.google.com with SMTP id ij19so248819vcb.2
        for <netdev@vger.kernel.org>; Sat, 26 Apr 2014 14:25:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Create a general __skb_checksum_validate function (actually a
macro) to subsume the various checksum_init functions. This
function can either init the checksum, or do the full validation
(logically checksum_init+skb_check_complete)-- a flag specifies
if full vaidation is performed. Also, there is a flag to the function
to indicate that zero checksums are allowed (to support optional
UDP checksums).

Added several stub functions for calling __skb_checksum_validate.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/linux/skbuff.h | 87 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 87 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08074a8..3b14acc 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2741,6 +2741,93 @@ static inline __sum16 skb_checksum_complete(struct sk_buff *skb)
 	       0 : __skb_checksum_complete(skb);
 }
 
+/*
+ * Try to validate checksum based on unnecessary or zero checksum
+ * received.
+ *
+ * Return values:
+ * 0: checksum unnecessary validated, no further checks needed
+ * 1: checksum complete needed
+ */
+static inline __sum16 __skb_checksum_validate_unnecessary(struct sk_buff *skb,
+							  bool zero_okay,
+							  __sum16 check)
+{
+	if (skb_csum_unnecessary(skb)) {
+		return 0;
+	} else if (zero_okay && !check) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return 0;
+	}
+
+	return 1;
+}
+
+/*
+ * Validate (init) checksum based on checksum complete.
+ *
+ * Return values:
+ * 0: checksum is validated or try to in skb_checksum_complete
+ * non-zero: value of invalid computed checksum
+ */
+static inline __sum16 __skb_checksum_validate_complete(struct sk_buff *skb,
+						       bool complete,
+						       __wsum psum)
+{
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
+
+static inline __wsum null_compute_pseudo(struct sk_buff *skb, int proto)
+{
+	return 0;
+}
+
+/*
+ * Perform checksum validate (init). Note that this is a macro since we only
+ * want to calculate the pseudo header which is an input function if necessary.
+ * First we try to validate without any computation (checksum unnecessary) and
+ * then calculate based on checksum complete calling the function to compute
+ * pseudo header.
+ */
+#define __skb_checksum_validate(skb, proto, complete,			\
+				zero_okay, check, compute_pseudo)	\
+({									\
+	__sum16 __ret = __skb_checksum_validate_unnecessary(skb,	\
+				zero_okay, check);			\
+	if (__ret)							\
+		__ret = __skb_checksum_validate_complete(skb,		\
+				complete, compute_pseudo(skb, proto));	\
+	__ret;								\
+})
+
+#define skb_checksum_init(skb, proto, compute_pseudo)			\
+	__skb_checksum_validate(skb, proto, false, false, 0, compute_pseudo)
+
+#define skb_checksum_init_zero_check(skb, proto, check, compute_pseudo)	\
+	__skb_checksum_validate(skb, proto, false, true, check, compute_pseudo)
+
+#define skb_checksum_validate(skb, proto, compute_pseudo)		\
+	__skb_checksum_validate(skb, proto, true, false, 0, compute_pseudo)
+
+#define skb_checksum_validate_zero_check(skb, proto, check,		\
+					 compute_pseudo)		\
+	__skb_checksum_validate_(skb, proto, true, true, check, compute_pseudo)
+
+#define skb_checksum_simple_validate(skb)				\
+	__skb_checksum_validate(skb, 0, true, false, 0, null_compute_pseudo)
+
 #if defined(CONFIG_NF_CONNTRACK) || defined(CONFIG_NF_CONNTRACK_MODULE)
 void nf_conntrack_destroy(struct nf_conntrack *nfct);
 static inline void nf_conntrack_put(struct nf_conntrack *nfct)
-- 
1.9.1.423.g4596e3a
