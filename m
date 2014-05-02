From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/8 v4] net: Generalize checksum_init functions
Date: Fri, 2 May 2014 16:29:18 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405021528510.19956@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:45188 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752109AbaEBX3T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 19:29:19 -0400
Received: by mail-ob0-f202.google.com with SMTP id gq1so1145709obb.5
        for <netdev@vger.kernel.org>; Fri, 02 May 2014 16:29:19 -0700 (PDT)
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
 include/linux/skbuff.h | 93 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 93 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08074a8..3ca0dda 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2741,6 +2741,99 @@ static inline __sum16 skb_checksum_complete(struct sk_buff *skb)
 	       0 : __skb_checksum_complete(skb);
 }
 
+/* Check if we need to perform checksum complete validation.
+ *
+ * Returns true if checksum complete is needed, false otherwise
+ * (either checksum is unnecessary or zero checksum is allowed).
+ */
+static inline bool __skb_checksum_validate_needed(struct sk_buff *skb,
+						  bool zero_okay,
+						  __sum16 check)
+{
+	if (skb_csum_unnecessary(skb)) {
+		return false;
+	} else if (zero_okay && !check) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return false;
+	}
+
+	return true;
+}
+
+/* For small packets <= CHECKSUM_BREAK peform checksum complete directly
+ * in checksum_init.
+ */
+#define CHECKSUM_BREAK 76
+
+/* Validate (init) checksum based on checksum complete.
+ *
+ * Return values:
+ *   0: checksum is validated or try to in skb_checksum_complete. In the latter
+ *	case the ip_summed will not be CHECKSUM_UNNECESSARY and the pseudo
+ *	checksum is stored in skb->csum for use in __skb_checksum_complete
+ *   non-zero: value of invalid checksum
+ *
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
+	if (complete || skb->len <= CHECKSUM_BREAK)
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
+/* Perform checksum validate (init). Note that this is a macro since we only
+ * want to calculate the pseudo header which is an input function if necessary.
+ * First we try to validate without any computation (checksum unnecessary) and
+ * then calculate based on checksum complete calling the function to compute
+ * pseudo header.
+ *
+ * Return values:
+ *   0: checksum is validated or try to in skb_checksum_complete
+ *   non-zero: value of invalid checksum
+ */
+#define __skb_checksum_validate(skb, proto, complete,			\
+				zero_okay, check, compute_pseudo)	\
+({									\
+	__sum16 __ret = 0;						\
+	if (__skb_checksum_validate_needed(skb, zero_okay, check))	\
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
