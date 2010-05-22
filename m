From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 6/27] drivers/net/cxgb3: Use memdup_user
Date: Sat, 22 May 2010 10:20:10 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221019530.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Divy Le Ray <divy@chelsio.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:44693 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753580Ab0EVIUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 04:20:15 -0400
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
 drivers/net/cxgb3/cxgb3_main.c |   12 +++---------
 1 file changed, 3 insertions(+), 9 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index e3f1b85..066fd5b 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2311,15 +2311,9 @@ static int cxgb_extension_ioctl(struct net_device *dev, void __user *useraddr)
 		if (copy_from_user(&t, useraddr, sizeof(t)))
 			return -EFAULT;
 		/* Check t.len sanity ? */
-		fw_data = kmalloc(t.len, GFP_KERNEL);
-		if (!fw_data)
-			return -ENOMEM;
-
-		if (copy_from_user
-			(fw_data, useraddr + sizeof(t), t.len)) {
-			kfree(fw_data);
-			return -EFAULT;
-		}
+		fw_data = memdup_user(useraddr + sizeof(t), t.len);
+		if (IS_ERR(fw_data))
+			return PTR_ERR(fw_data);
 
 		ret = t3_load_fw(adapter, fw_data, t.len);
 		kfree(fw_data);
