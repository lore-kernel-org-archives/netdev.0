From: David Ahern <dsahern@gmail.com>
Subject: [PATCH v2 net-next 6/9] net: mpls: Pull common label check into helper
Date: Sat, 27 May 2017 16:19:30 -0600
Message-ID: <20170527221933.57644-7-dsahern@gmail.com>
References: <20170527221933.57644-1-dsahern@gmail.com>
Cc: roopa@cumulusnetworks.com, David Ahern <dsahern@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35434 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750854AbdE0WTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 27 May 2017 18:19:53 -0400
Received: by mail-pf0-f193.google.com with SMTP id u26so8199791pfd.2
        for <netdev@vger.kernel.org>; Sat, 27 May 2017 15:19:48 -0700 (PDT)
In-Reply-To: <20170527221933.57644-1-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

mpls_route_add and mpls_route_del have the same checks on the label.
Move to a helper. Avoid duplicate extack messages in the next patch.

Signed-off-by: David Ahern <dsahern@gmail.com>
---
 net/mpls/af_mpls.c | 32 +++++++++++++++++---------------
 1 file changed, 17 insertions(+), 15 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index f3830951fb1c..726eafecc793 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -856,6 +856,19 @@ static int mpls_nh_build_multi(struct mpls_route_config *cfg,
 	return err;
 }
 
+static bool mpls_label_ok(struct net *net, unsigned int index)
+{
+	/* Reserved labels may not be set */
+	if (index < MPLS_LABEL_FIRST_UNRESERVED)
+		return false;
+
+	/* The full 20 bit range may not be supported. */
+	if (index >= net->mpls.platform_labels)
+		return false;
+
+	return true;
+}
+
 static int mpls_route_add(struct mpls_route_config *cfg)
 {
 	struct mpls_route __rcu **platform_label;
@@ -875,12 +888,7 @@ static int mpls_route_add(struct mpls_route_config *cfg)
 		index = find_free_label(net);
 	}
 
-	/* Reserved labels may not be set */
-	if (index < MPLS_LABEL_FIRST_UNRESERVED)
-		goto errout;
-
-	/* The full 20 bit range may not be supported. */
-	if (index >= net->mpls.platform_labels)
+	if (!mpls_label_ok(net, index))
 		goto errout;
 
 	/* Append makes no sense with mpls */
@@ -952,12 +960,7 @@ static int mpls_route_del(struct mpls_route_config *cfg)
 
 	index = cfg->rc_label;
 
-	/* Reserved labels may not be removed */
-	if (index < MPLS_LABEL_FIRST_UNRESERVED)
-		goto errout;
-
-	/* The full 20 bit range may not be supported */
-	if (index >= net->mpls.platform_labels)
+	if (!mpls_label_ok(net, index))
 		goto errout;
 
 	mpls_route_update(net, index, NULL, &cfg->rc_nlinfo);
@@ -1735,10 +1738,9 @@ static int rtm_to_route_config(struct sk_buff *skb,  struct nlmsghdr *nlh,
 					   &cfg->rc_label, NULL))
 				goto errout;
 
-			/* Reserved labels may not be set */
-			if (cfg->rc_label < MPLS_LABEL_FIRST_UNRESERVED)
+			if (!mpls_label_ok(cfg->rc_nlinfo.nl_net,
+					   cfg->rc_label))
 				goto errout;
-
 			break;
 		}
 		case RTA_VIA:
-- 
2.11.0 (Apple Git-81)
