From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 2/27] drivers/net: Use memdup_user
Date: Sat, 22 May 2010 10:18:59 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221018350.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:60205 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752481Ab0EVITE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 04:19:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia@diku.dk>

Use memdup_user when user data is immediately copied into the
allocated region.

The semantic patch that makes this change is as follows:
(http://coccinelle.lip6.fr/)

// <smpl>
@@
expression from,to,size,flag;
position p;
identifier l1,l2;
@@

-  to = \(kmalloc@p\|kzalloc@p\)(size,flag);
+  to = memdup_user(from,size);
   if (
-      to==NULL
+      IS_ERR(to)
                 || ...) {
   <+... when != goto l1;
-  -ENOMEM
+  PTR_ERR(to)
   ...+>
   }
-  if (copy_from_user(to, from, size) != 0) {
-    <+... when != goto l2;
-    -EFAULT
-    ...+>
-  }
// </smpl>

Signed-off-by: Julia Lawall <julia@diku.dk>

---
 drivers/net/ppp_generic.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ppp_generic.c b/drivers/net/ppp_generic.c
index 5441688..da7943d 100644
--- a/drivers/net/ppp_generic.c
+++ b/drivers/net/ppp_generic.c
@@ -539,14 +539,9 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 	}
 
 	len = uprog.len * sizeof(struct sock_filter);
-	code = kmalloc(len, GFP_KERNEL);
-	if (code == NULL)
-		return -ENOMEM;
-
-	if (copy_from_user(code, uprog.filter, len)) {
-		kfree(code);
-		return -EFAULT;
-	}
+	code = memdup_user(uprog.filter, len);
+	if (IS_ERR(code))
+		return PTR_ERR(code);
 
 	err = sk_chk_filter(code, uprog.len);
 	if (err) {
