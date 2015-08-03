From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next] mpls: Use definition for reserved label checks
Date: Mon, 3 Aug 2015 17:50:04 +0100
Message-ID: <1438620604-18746-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Thomas Graf <tgraf@suug.ch>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	"Robert Shearman" <rshearma@brocade.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:49830 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752323AbbHCQvN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Aug 2015 12:51:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In multiple locations there are checks for whether the label in hand
is a reserved label or not using the arbritray value of 16. Factor
this out into a #define for better maintainability and for
documentation.

Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
Resend of an earlier version of this patch that was included as part
of a larger series. Changes since that version:
  - Move new #define into userspace header file in line with other
    well-defined label values. Rename to match.

 include/uapi/linux/mpls.h |  2 ++
 net/mpls/af_mpls.c        | 21 +++++++++++----------
 2 files changed, 13 insertions(+), 10 deletions(-)

diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
index 139d4dd1cab8..24a6cb1aec86 100644
--- a/include/uapi/linux/mpls.h
+++ b/include/uapi/linux/mpls.h
@@ -41,4 +41,6 @@ struct mpls_label {
 #define MPLS_LABEL_OAMALERT		14 /* RFC3429 */
 #define MPLS_LABEL_EXTENSION		15 /* RFC7274 */
 
+#define MPLS_LABEL_FIRST_UNRESERVED	16 /* RFC3032 */
+
 #endif /* _UAPI_MPLS_H */
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 88cfaa241c07..b6b9a6c4e784 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -293,7 +293,7 @@ static void mpls_notify_route(struct net *net, unsigned index,
 	struct mpls_route *rt = new ? new : old;
 	unsigned nlm_flags = (old && new) ? NLM_F_REPLACE : 0;
 	/* Ignore reserved labels for now */
-	if (rt && (index >= 16))
+	if (rt && (index >= MPLS_LABEL_FIRST_UNRESERVED))
 		rtmsg_lfib(event, index, rt, nlh, net, portid, nlm_flags);
 }
 
@@ -327,7 +327,8 @@ static unsigned find_free_label(struct net *net)
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	platform_labels = net->mpls.platform_labels;
-	for (index = 16; index < platform_labels; index++) {
+	for (index = MPLS_LABEL_FIRST_UNRESERVED; index < platform_labels;
+	     index++) {
 		if (!rtnl_dereference(platform_label[index]))
 			return index;
 	}
@@ -436,8 +437,8 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		index = find_free_label(net);
 	}
 
-	/* The first 16 labels are reserved, and may not be set */
-	if (index < 16)
+	/* Reserved labels may not be set */
+	if (index < MPLS_LABEL_FIRST_UNRESERVED)
 		goto errout;
 
 	/* The full 20 bit range may not be supported. */
@@ -516,8 +517,8 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 
 	index = cfg->rc_label;
 
-	/* The first 16 labels are reserved, and may not be removed */
-	if (index < 16)
+	/* Reserved labels may not be removed */
+	if (index < MPLS_LABEL_FIRST_UNRESERVED)
 		goto errout;
 
 	/* The full 20 bit range may not be supported */
@@ -835,8 +836,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 					   &cfg->rc_label))
 				goto errout;
 
-			/* The first 16 labels are reserved, and may not be set */
-			if (cfg->rc_label < 16)
+			/* Reserved labels may not be set */
+			if (cfg->rc_label < MPLS_LABEL_FIRST_UNRESERVED)
 				goto errout;
 
 			break;
@@ -961,8 +962,8 @@ static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 	ASSERT_RTNL();
 
 	index = cb->args[0];
-	if (index < 16)
-		index = 16;
+	if (index < MPLS_LABEL_FIRST_UNRESERVED)
+		index = MPLS_LABEL_FIRST_UNRESERVED;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	platform_labels = net->mpls.platform_labels;
-- 
2.1.4
