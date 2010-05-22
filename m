From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 1/27] net/can: Use memdup_user
Date: Sat, 22 May 2010 10:18:34 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221018130.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	Urs Thuermann <urs.thuermann@volkswagen.de>,
	"David S. Miller" <davem@davemloft.net>,
	socketcan-core@lists.berlios.de, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw1.diku.dk ([130.225.96.91]:60181 "EHLO mgw1.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752334Ab0EVISk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 04:18:40 -0400
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
 net/can/raw.c |   11 +++--------
 1 file changed, 3 insertions(+), 8 deletions(-)

diff --git a/net/can/raw.c b/net/can/raw.c
index da99cf1..ccfe633 100644
--- a/net/can/raw.c
+++ b/net/can/raw.c
@@ -436,14 +436,9 @@ static int raw_setsockopt(struct socket *sock, int level, int optname,
 
 		if (count > 1) {
 			/* filter does not fit into dfilter => alloc space */
-			filter = kmalloc(optlen, GFP_KERNEL);
-			if (!filter)
-				return -ENOMEM;
-
-			if (copy_from_user(filter, optval, optlen)) {
-				kfree(filter);
-				return -EFAULT;
-			}
+			filter = memdup_user(optval, optlen);
+			if (IS_ERR(filter))
+				return PTR_ERR(filter);
 		} else if (count == 1) {
 			if (copy_from_user(&sfilter, optval, sizeof(sfilter)))
 				return -EFAULT;
