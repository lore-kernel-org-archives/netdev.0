From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH v2] net/garp: avoid infinite loop if attribute already exists
Date: Tue, 27 Mar 2012 15:01:52 -0400
Message-ID: <1332874912-1979-1-git-send-email-david.ward@ll.mit.edu>
References: <4F70942B.5000102@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <jorge@dti2.net>, <kaber@trash.net>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:49543 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751003Ab2C0TF5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 15:05:57 -0400
In-Reply-To: <4F70942B.5000102@ll.mit.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

An infinite loop occurred if garp_attr_create was called with the values
of an existing attribute. This might happen if a previous leave request
for the attribute has not yet been followed by a PDU transmission (or,
if the application previously issued a join request for the attribute
and is now issuing another one, without having issued a leave request).

If garp_attr_create finds an existing attribute having the same values,
return the address to it. Its state will then get updated (i.e., if it
was in a leaving state, it will move into a non-leaving state and not
get deleted during the next PDU transmission).

To accomplish this fix, collapse garp_attr_insert into garp_attr_create
(which is its only caller).

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/802/garp.c |   22 ++++++++++------------
 1 files changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index 8e21b6d..a5c2248 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -167,7 +167,8 @@ static struct garp_attr *garp_attr_lookup(const struct garp_applicant *app,
 	return NULL;
 }
 
-static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
+static struct garp_attr *garp_attr_create(struct garp_applicant *app,
+					  const void *data, u8 len, u8 type)
 {
 	struct rb_node *parent = NULL, **p = &app->gid.rb_node;
 	struct garp_attr *attr;
@@ -176,21 +177,16 @@ static void garp_attr_insert(struct garp_applicant *app, struct garp_attr *new)
 	while (*p) {
 		parent = *p;
 		attr = rb_entry(parent, struct garp_attr, node);
-		d = garp_attr_cmp(attr, new->data, new->dlen, new->type);
+		d = garp_attr_cmp(attr, data, len, type);
 		if (d < 0)
 			p = &parent->rb_left;
 		else if (d > 0)
 			p = &parent->rb_right;
+		else {
+			/* The attribute already exists; re-use it. */
+			return attr;
+		}
 	}
-	rb_link_node(&new->node, parent, p);
-	rb_insert_color(&new->node, &app->gid);
-}
-
-static struct garp_attr *garp_attr_create(struct garp_applicant *app,
-					  const void *data, u8 len, u8 type)
-{
-	struct garp_attr *attr;
-
 	attr = kmalloc(sizeof(*attr) + len, GFP_ATOMIC);
 	if (!attr)
 		return attr;
@@ -198,7 +194,9 @@ static struct garp_attr *garp_attr_create(struct garp_applicant *app,
 	attr->type  = type;
 	attr->dlen  = len;
 	memcpy(attr->data, data, len);
-	garp_attr_insert(app, attr);
+
+	rb_link_node(&attr->node, parent, p);
+	rb_insert_color(&attr->node, &app->gid);
 	return attr;
 }
 
-- 
1.7.4.1
