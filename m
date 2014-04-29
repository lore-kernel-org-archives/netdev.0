From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/8 v3] net: Generalize checksum_init functions
Date: Tue, 29 Apr 2014 09:18:47 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1404290900390.9354@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org, ben@decadent.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f74.google.com ([209.85.216.74]:49989 "EHLO
	mail-qa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbaD2QYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Apr 2014 12:24:10 -0400
Received: by mail-qa0-f74.google.com with SMTP id j15so25043qaq.3
        for <netdev@vger.kernel.org>; Tue, 29 Apr 2014 09:24:09 -0700 (PDT)
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
 include/linux/skbuff.h | 89 ++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 89 insertions(+)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 08074a8..27da125 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2741,6 +2741,95 @@ static inline __sum16 skb_checksum_complete(struct sk_buff *skb)
 	       0 : __skb_checksum_complete(skb);
 }
 
+/* Try to validate checksum based on unnecessary or zero checksum
+ * received.
+ *
+ * Returns true if the checksum has been validated, false otherwise
+ * (checksum complete is needed).
+ */
+static inline bool __skb_checksum_validate_unnecessary(struct sk_buff *skb,
+						       bool zero_okay,
+						       __sum16 check)
+{
+	if (skb_csum_unnecessary(skb)) {
+		return true;
+	} else if (zero_okay && !check) {
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		return true;
+	}
+
+	return false;
+}
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
+	if (!__skb_checksum_validate_unnecessary(skb, zero_okay, check))\
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
