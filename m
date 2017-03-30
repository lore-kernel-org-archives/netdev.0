From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2 6/6] net: mpls: Increase max number of labels for lwt encap
Date: Thu, 30 Mar 2017 09:18:24 -0700
Message-ID: <1490890704-8075-7-git-send-email-dsa@cumulusnetworks.com>
References: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35143 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933964AbdC3QSh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 30 Mar 2017 12:18:37 -0400
Received: by mail-pg0-f45.google.com with SMTP id 81so44444192pgh.2
        for <netdev@vger.kernel.org>; Thu, 30 Mar 2017 09:18:36 -0700 (PDT)
In-Reply-To: <1490890704-8075-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alow users to push down more labels per MPLS encap. Similar to LSR case,
move label array to the end of mpls_iptunnel_encap and allocate based on
the number of labels for the route.

For consistency with the LSR case, re-use the same maximum number of
labels.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- marked hole in mpls_iptunnel_encap as reserved1

 include/net/mpls_iptunnel.h |  5 ++---
 net/mpls/af_mpls.c          |  5 -----
 net/mpls/internal.h         |  5 +++++
 net/mpls/mpls_iptunnel.c    | 13 ++++++++++---
 4 files changed, 17 insertions(+), 11 deletions(-)

diff --git a/include/net/mpls_iptunnel.h b/include/net/mpls_iptunnel.h
index a18af6a16eb5..9d22bf67ac86 100644
--- a/include/net/mpls_iptunnel.h
+++ b/include/net/mpls_iptunnel.h
@@ -14,13 +14,12 @@
 #ifndef _NET_MPLS_IPTUNNEL_H
 #define _NET_MPLS_IPTUNNEL_H 1
 
-#define MAX_NEW_LABELS 2
-
 struct mpls_iptunnel_encap {
-	u32	label[MAX_NEW_LABELS];
 	u8	labels;
 	u8	ttl_propagate;
 	u8	default_ttl;
+	u8	reserved1;
+	u32	label[0];
 };
 
 static inline struct mpls_iptunnel_encap *mpls_lwtunnel_encap(struct lwtunnel_state *lwtstate)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 2458d7ed2ab5..2da15dcb2675 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -24,11 +24,6 @@
 #include <net/nexthop.h>
 #include "internal.h"
 
-/* put a reasonable limit on the number of labels
- * we will accept from userspace
- */
-#define MAX_NEW_LABELS	30
-
 /* max memory we will use for mpls_route */
 #define MAX_MPLS_ROUTE_MEM	4096
 
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index c5d2f5bc37ec..4db6a5971322 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -2,6 +2,11 @@
 #define MPLS_INTERNAL_H
 #include <net/mpls.h>
 
+/* put a reasonable limit on the number of labels
+ * we will accept from userspace
+ */
+#define MAX_NEW_LABELS 30
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
