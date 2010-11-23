From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: [PATCH net-2.6] net, ppp: Report correct error code if unit
	allocation failed
Date: Wed, 24 Nov 2010 00:43:44 +0300
Message-ID: <20101123214344.GB1839@lenovo>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Paul Mackerras <paulus@samba.org>,
	David Miller <davem@davemloft.net>, linux-ppp@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: LNML <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:64691 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751700Ab0KWVnt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 16:43:49 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocating unit from ird might return several error codes
not only -EAGAIN, so it should not be changed and returned
precisely. Same time unit release procedure should be invoked
only if device is unregistering.

Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
CC: Paul Mackerras <paulus@samba.org>
---
Please review, thanks! (I've tested it a bit but more tests would
be really appreciated as well as comments)

 drivers/net/ppp_generic.c |   43 ++++++++++++++++++++++---------------------
 1 file changed, 22 insertions(+), 21 deletions(-)

Index: linux-2.6.git/drivers/net/ppp_generic.c
=====================================================================
--- linux-2.6.git.orig/drivers/net/ppp_generic.c
+++ linux-2.6.git/drivers/net/ppp_generic.c
@@ -2584,16 +2584,16 @@ ppp_create_interface(struct net *net, in
 	 */
 	dev_net_set(dev, net);
 
-	ret = -EEXIST;
 	mutex_lock(&pn->all_ppp_mutex);
 
 	if (unit < 0) {
 		unit = unit_get(&pn->units_idr, ppp);
 		if (unit < 0) {
-			*retp = unit;
+			ret = unit;
 			goto out2;
 		}
 	} else {
+		ret = -EEXIST;
 		if (unit_find(&pn->units_idr, unit))
 			goto out2; /* unit already exists */
 		/*
@@ -2668,10 +2668,10 @@ static void ppp_shutdown_interface(struc
 		ppp->closing = 1;
 		ppp_unlock(ppp);
 		unregister_netdev(ppp->dev);
+		unit_put(&pn->units_idr, ppp->file.index);
 	} else
 		ppp_unlock(ppp);
 
-	unit_put(&pn->units_idr, ppp->file.index);
 	ppp->file.dead = 1;
 	ppp->owner = NULL;
 	wake_up_interruptible(&ppp->file.rwait);
@@ -2859,8 +2859,7 @@ static void __exit ppp_cleanup(void)
  * by holding all_ppp_mutex
  */
 
-/* associate pointer with specified number */
-static int unit_set(struct idr *p, void *ptr, int n)
+static int __unit_alloc(struct idr *p, void *ptr, int n)
 {
 	int unit, err;
 
@@ -2871,10 +2870,24 @@ again:
 	}
 
 	err = idr_get_new_above(p, ptr, n, &unit);
-	if (err == -EAGAIN)
-		goto again;
+	if (err < 0) {
+		if (err == -EAGAIN)
+			goto again;
+		return err;
+	}
+
+	return unit;
+}
+
+/* associate pointer with specified number */
+static int unit_set(struct idr *p, void *ptr, int n)
+{
+	int unit;
 
-	if (unit != n) {
+	unit = __unit_alloc(p, ptr, n);
+	if (unit < 0)
+		return unit;
+	else if (unit != n) {
 		idr_remove(p, unit);
 		return -EINVAL;
 	}
@@ -2885,19 +2898,7 @@ again:
 /* get new free unit number and associate pointer with it */
 static int unit_get(struct idr *p, void *ptr)
 {
-	int unit, err;
-
-again:
-	if (!idr_pre_get(p, GFP_KERNEL)) {
-		printk(KERN_ERR "PPP: No free memory for idr\n");
-		return -ENOMEM;
-	}
-
-	err = idr_get_new_above(p, ptr, 0, &unit);
-	if (err == -EAGAIN)
-		goto again;
-
-	return unit;
+	return __unit_alloc(p, ptr, 0);
 }
 
 /* put unit number back to a pool */
