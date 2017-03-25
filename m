From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next 4/4] net: mpls: Increase max number of labels for lwt encap
Date: Sat, 25 Mar 2017 10:03:28 -0700
Message-ID: <1490461408-9551-5-git-send-email-dsa@cumulusnetworks.com>
References: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:34666 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751644AbdCYRD7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 25 Mar 2017 13:03:59 -0400
Received: by mail-pg0-f50.google.com with SMTP id 21so9499671pgg.1
        for <netdev@vger.kernel.org>; Sat, 25 Mar 2017 10:03:44 -0700 (PDT)
In-Reply-To: <1490461408-9551-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alow users to push down more labels per MPLS encap. Same logic as LSR
use case, so re-use the maximum number of labels.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 include/net/mpls_iptunnel.h |  4 +---
 net/mpls/af_mpls.c          |  5 -----
 net/mpls/internal.h         |  5 +++++
 net/mpls/mpls_iptunnel.c    | 13 ++++++++++---
 4 files changed, 16 insertions(+), 11 deletions(-)

diff --git a/include/net/mpls_iptunnel.h b/include/net/mpls_iptunnel.h
index a18af6a16eb5..038fa9985521 100644
--- a/include/net/mpls_iptunnel.h
+++ b/include/net/mpls_iptunnel.h
@@ -14,13 +14,11 @@
 #ifndef _NET_MPLS_IPTUNNEL_H
 #define _NET_MPLS_IPTUNNEL_H 1
 
-#define MAX_NEW_LABELS 2
-
 struct mpls_iptunnel_encap {
-	u32	label[MAX_NEW_LABELS];
 	u8	labels;
 	u8	ttl_propagate;
 	u8	default_ttl;
+	u32	label[0];
 };
 
 static inline struct mpls_iptunnel_encap *mpls_lwtunnel_encap(struct lwtunnel_state *lwtstate)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 3023c261a04b..0ced87a51326 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -24,11 +24,6 @@
 #include <net/nexthop.h>
 #include "internal.h"
 
-/* put a reasonable limit on the number of labels
- * we will accept from userspace
- */
-#define MAX_NEW_LABELS 12
-
 /* Maximum number of labels to look ahead at when selecting a path of
  * a multipath route
  */
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index 302d48f54b57..d43f8bc52653 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -2,6 +2,11 @@
 #define MPLS_INTERNAL_H
 #include <net/mpls.h>
 
+/* put a reasonable limit on the number of labels
+ * we will accept from userspace
+ */
+#define MAX_NEW_LABELS 12
+
 struct mpls_entry_decoded {
 	u32 label;
 	u8 ttl;
diff --git a/net/mpls/mpls_iptunnel.c b/net/mpls/mpls_iptunnel.c
index 22f71fce0bfb..fe00e98667cf 100644
--- a/net/mpls/mpls_iptunnel.c
+++ b/net/mpls/mpls_iptunnel.c
@@ -164,6 +164,7 @@ static int mpls_build_state(struct nlattr *nla,
 	struct mpls_iptunnel_encap *tun_encap_info;
 	struct nlattr *tb[MPLS_IPTUNNEL_MAX + 1];
 	struct lwtunnel_state *newts;
+	u8 n_labels;
 	int ret;
 
 	ret = nla_parse_nested(tb, MPLS_IPTUNNEL_MAX, nla,
@@ -175,12 +176,18 @@ static int mpls_build_state(struct nlattr *nla,
 		return -EINVAL;
 
 
-	newts = lwtunnel_state_alloc(sizeof(*tun_encap_info));
+	/* determine number of labels */
+	if (nla_get_labels(tb[MPLS_IPTUNNEL_DST],
+			   MAX_NEW_LABELS, &n_labels, NULL))
+		return -EINVAL;
+
+	newts = lwtunnel_state_alloc(sizeof(*tun_encap_info) +
+				     n_labels * sizeof(u32));
 	if (!newts)
 		return -ENOMEM;
 
 	tun_encap_info = mpls_lwtunnel_encap(newts);
-	ret = nla_get_labels(tb[MPLS_IPTUNNEL_DST], MAX_NEW_LABELS,
+	ret = nla_get_labels(tb[MPLS_IPTUNNEL_DST], n_labels,
 			     &tun_encap_info->labels, tun_encap_info->label);
 	if (ret)
 		goto errout;
@@ -257,7 +264,7 @@ static int mpls_encap_cmp(struct lwtunnel_state *a, struct lwtunnel_state *b)
 	    a_hdr->default_ttl != b_hdr->default_ttl)
 		return 1;
 
-	for (l = 0; l < MAX_NEW_LABELS; l++)
+	for (l = 0; l < a_hdr->labels; l++)
 		if (a_hdr->label[l] != b_hdr->label[l])
 			return 1;
 	return 0;
-- 
2.1.4
