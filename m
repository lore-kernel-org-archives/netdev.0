From: Robert Shearman <rshearma@brocade.com>
Subject: [PATCH net-next v2 1/5] mpls: Use definition for reserved label checks
Date: Fri, 20 Mar 2015 15:42:46 +0000
Message-ID: <1426866170-28739-2-git-send-email-rshearma@brocade.com>
References: <1426800772-22378-1-git-send-email-rshearma@brocade.com>
 <1426866170-28739-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Robert Shearman <rshearma@brocade.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:62743 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751033AbbCTPnx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2015 11:43:53 -0400
In-Reply-To: <1426866170-28739-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In multiple locations there are checks for whether the label in hand
is a reserved label or not using the arbritray value of 16. Factor
this out into a #define for better maintainability and for
documentation.

Cc: "Eric W. Biederman" <ebiederm@xmission.com>
Signed-off-by: Robert Shearman <rshearma@brocade.com>
---
 net/mpls/af_mpls.c  | 20 ++++++++++----------
 net/mpls/internal.h |  1 +
 2 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index db8a2ea..0d6763a 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -276,7 +276,7 @@ static void mpls_notify_route(struct net *net, unsigned index,
 	struct mpls_route *rt = new ? new : old;
 	unsigned nlm_flags = (old && new) ? NLM_F_REPLACE : 0;
 	/* Ignore reserved labels for now */
-	if (rt && (index >= 16))
+	if (rt && (index >= LABEL_FIRST_UNRESERVED))
 		rtmsg_lfib(event, index, rt, nlh, net, portid, nlm_flags);
 }
 
@@ -310,7 +310,7 @@ static unsigned find_free_label(struct net *net)
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	platform_labels = net->mpls.platform_labels;
-	for (index = 16; index < platform_labels; index++) {
+	for (index = LABEL_FIRST_UNRESERVED; index < platform_labels; index++) {
 		if (!rtnl_dereference(platform_label[index]))
 			return index;
 	}
@@ -335,8 +335,8 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		index = find_free_label(net);
 	}
 
-	/* The first 16 labels are reserved, and may not be set */
-	if (index < 16)
+	/* Reserved labels may not be set */
+	if (index < LABEL_FIRST_UNRESERVED)
 		goto errout;
 
 	/* The full 20 bit range may not be supported. */
@@ -413,8 +413,8 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 
 	index = cfg->rc_label;
 
-	/* The first 16 labels are reserved, and may not be removed */
-	if (index < 16)
+	/* Reserved labels may not be removed */
+	if (index < LABEL_FIRST_UNRESERVED)
 		goto errout;
 
 	/* The full 20 bit range may not be supported */
@@ -610,8 +610,8 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 					   &cfg->rc_label))
 				goto errout;
 
-			/* The first 16 labels are reserved, and may not be set */
-			if (cfg->rc_label < 16)
+			/* Reserved labels may not be set */
+			if (cfg->rc_label < LABEL_FIRST_UNRESERVED)
 				goto errout;
 
 			break;
@@ -736,8 +736,8 @@ static int mpls_dump_routes(struct sk_buff *skb, struct netlink_callback *cb)
 	ASSERT_RTNL();
 
 	index = cb->args[0];
-	if (index < 16)
-		index = 16;
+	if (index < LABEL_FIRST_UNRESERVED)
+		index = LABEL_FIRST_UNRESERVED;
 
 	platform_label = rtnl_dereference(net->mpls.platform_label);
 	platform_labels = net->mpls.platform_labels;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index fb6de92..5732283 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -9,6 +9,7 @@
 #define LABEL_GAL			13 /* RFC5586 */
 #define LABEL_OAM_ALERT			14 /* RFC3429 */
 #define LABEL_EXTENSION			15 /* RFC7274 */
+#define LABEL_FIRST_UNRESERVED		16 /* RFC3032 */
 
 
 struct mpls_shim_hdr {
-- 
2.1.4
