From: David Ward <david.ward@ll.mit.edu>
Subject: [PATCH] net/garp: fix GID rbtree ordering
Date: Mon, 9 Apr 2012 10:13:53 -0400
Message-ID: <1333980833-12355-1-git-send-email-david.ward@ll.mit.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: "Jorge Boncompte [DTI2]" <jorge@dti2.net>,
	David Ward <david.ward@ll.mit.edu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from MX2.LL.MIT.EDU ([129.55.12.46]:52664 "EHLO mx2.ll.mit.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755403Ab2DIOOA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 9 Apr 2012 10:14:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The comparison operators were backwards in both garp_attr_lookup and
garp_attr_create, so the entire GID rbtree was in reverse order.
(There was no practical side effect to this though, except that PDUs
were sent with attributes listed in reverse order, which is still
valid by the protocol. This change is only for clarity.)

Signed-off-by: David Ward <david.ward@ll.mit.edu>
---
 net/802/garp.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index a5c2248..8456f5d 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -157,9 +157,9 @@ static struct garp_attr *garp_attr_lookup(const struct garp_applicant *app,
 	while (parent) {
 		attr = rb_entry(parent, struct garp_attr, node);
 		d = garp_attr_cmp(attr, data, len, type);
-		if (d < 0)
+		if (d > 0)
 			parent = parent->rb_left;
-		else if (d > 0)
+		else if (d < 0)
 			parent = parent->rb_right;
 		else
 			return attr;
@@ -178,9 +178,9 @@ static struct garp_attr *garp_attr_create(struct garp_applicant *app,
 		parent = *p;
 		attr = rb_entry(parent, struct garp_attr, node);
 		d = garp_attr_cmp(attr, data, len, type);
-		if (d < 0)
+		if (d > 0)
 			p = &parent->rb_left;
-		else if (d > 0)
+		else if (d < 0)
 			p = &parent->rb_right;
 		else {
 			/* The attribute already exists; re-use it. */
-- 
1.7.4.1
