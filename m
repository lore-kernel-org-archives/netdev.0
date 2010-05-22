From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 7/27] drivers/net/wan: Use memdup_user
Date: Sat, 22 May 2010 10:20:26 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221020110.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Mike McLagan <mike.mclagan@linux.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:60263 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753652Ab0EVIUb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 04:20:31 -0400
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
 drivers/net/wan/sdla.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/drivers/net/wan/sdla.c b/drivers/net/wan/sdla.c
index 43ae6f4..258efc2 100644
--- a/drivers/net/wan/sdla.c
+++ b/drivers/net/wan/sdla.c
@@ -1211,14 +1211,9 @@ static int sdla_xfer(struct net_device *dev, struct sdla_mem __user *info, int r
 	}
 	else
 	{
-		temp = kmalloc(mem.len, GFP_KERNEL);
-		if (!temp)
-			return(-ENOMEM);
-		if(copy_from_user(temp, mem.data, mem.len))
-		{
-			kfree(temp);
-			return -EFAULT;
-		}
+		temp = memdup_user(mem.data, mem.len);
+		if (IS_ERR(temp))
+			return PTR_ERR(temp);
 		sdla_write(dev, mem.addr, temp, mem.len);
 		kfree(temp);
 	}
