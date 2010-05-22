From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 24/27] drivers/net/wan: Use memdup_user
Date: Sat, 22 May 2010 10:26:04 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221025450.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Kevin Curtis <kevin.curtis@farsite.co.uk>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:60785 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753088Ab0EVI0J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 04:26:09 -0400
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
 drivers/net/wan/farsync.c |   14 ++++----------
 1 file changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/wan/farsync.c b/drivers/net/wan/farsync.c
index e087b9a..43b7727 100644
--- a/drivers/net/wan/farsync.c
+++ b/drivers/net/wan/farsync.c
@@ -2038,16 +2038,10 @@ fst_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 
 		/* Now copy the data to the card. */
 
-		buf = kmalloc(wrthdr.size, GFP_KERNEL);
-		if (!buf)
-			return -ENOMEM;
-
-		if (copy_from_user(buf,
-				   ifr->ifr_data + sizeof (struct fstioc_write),
-				   wrthdr.size)) {
-			kfree(buf);
-			return -EFAULT;
-		}
+		buf = memdup_user(ifr->ifr_data + sizeof(struct fstioc_write),
+				  wrthdr.size);
+		if (IS_ERR(buf))
+			return PTR_ERR(buf);
 
 		memcpy_toio(card->mem + wrthdr.offset, buf, wrthdr.size);
 		kfree(buf);
