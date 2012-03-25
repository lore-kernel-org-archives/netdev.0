From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/garp: avoid infinite loop if attribute already exists
Date: Sun, 25 Mar 2012 18:43:56 -0400
Message-ID: <1332715437-16278-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:47322 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932286Ab2CYXJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 25 Mar 2012 19:09:57 -0400
Received: from LLE2K7-HUB02.mitll.ad.local (LLE2K7-HUB02.mitll.ad.local) by mx2.ll.mit.edu (unknown) with ESMTP id q2PMi4Sh006660 for <netdev@vger.kernel.org>; Sun, 25 Mar 2012 18:44:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An infinite loop occurred if garp_attr_create was called with the
values of an existing attribute. Return -EEXIST instead.

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/802/garp.c |   18 +++++++++++++-----
 1 files changed, 13 insertions(+), 5 deletions(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index 8e21b6d..bb5015e 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -167,7 +167,7 @@ static struct garp_attr *garp_attr_lookup(const struct garp_applicant *app,
 	return NULL;
 }
 
-static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
+static int garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
 {
 	struct rb_node *parent = NULL, **p = &app->gid.rb_node;
 	struct garp_attr *attr;
@@ -181,24 +181,32 @@ static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
 			p = &parent->rb_left;
 		else if (d > 0)
 			p = &parent->rb_right;
+		else
+			return -EEXIST;
 	}
 	rb_link_node(&new->node, parent, p);
 	rb_insert_color(&new->node, &app->gid);
+	return 0;
 }
 
 static struct garp_attr *garp_attr_create(struct garp_applicant *app,
 					  const void *data, u8 len, u8 type)
 {
 	struct garp_attr *attr;
+	int err;
 
 	attr = kmalloc(sizeof(*attr) + len, GFP_ATOMIC);
 	if (!attr)
-		return attr;
+		return PTR_ERR(-ENOMEM);
 	attr->state = GARP_APPLICANT_VO;
 	attr->type  = type;
 	attr->dlen  = len;
 	memcpy(attr->data, data, len);
-	garp_attr_insert(app, attr);
+	err = garp_attr_insert(app, attr);
+	if (err < 0) {
+		kfree(attr);
+		return PTR_ERR(err);
+	}
 	return attr;
 }
 
@@ -353,9 +361,9 @@ int garp_request_join(const struct net_device *dev,
 
 	spin_lock_bh(&app->lock);
 	attr = garp_attr_create(app, data, len, type);
-	if (!attr) {
+	if (IS_ERR(attr)) {
 		spin_unlock_bh(&app->lock);
-		return -ENOMEM;
+		return ERR_PTR(attr);
 	}
 	garp_attr_event(app, attr, GARP_EVENT_REQ_JOIN);
 	spin_unlock_bh(&app->lock);
-- 
1.7.1
