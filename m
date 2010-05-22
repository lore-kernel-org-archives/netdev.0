From: Julia Lawall <julia@diku.dk>
Subject: [PATCH 26/27] drivers/isdn: Use memdup_user
Date: Sat, 22 May 2010 10:26:42 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.1005221026230.13021@ask.diku.dk>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Karsten Keil <isdn@linux-pingi.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:60801 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755831Ab0EVI0s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 May 2010 04:26:48 -0400
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
 drivers/isdn/i4l/isdn_ppp.c |   11 +++--------
 drivers/isdn/pcbit/drv.c    |   10 +++-------
 drivers/isdn/sc/ioctl.c     |   23 ++++++-----------------
 3 files changed, 12 insertions(+), 32 deletions(-)

diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index f37b8f6..8c46bae 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -449,14 +449,9 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 
 	/* uprog.len is unsigned short, so no overflow here */
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
diff --git a/drivers/isdn/pcbit/drv.c b/drivers/isdn/pcbit/drv.c
index 123c1d6..1507d2e 100644
--- a/drivers/isdn/pcbit/drv.c
+++ b/drivers/isdn/pcbit/drv.c
@@ -411,14 +411,10 @@ static int pcbit_writecmd(const u_char __user *buf, int len, int driver, int cha
 			return -EINVAL;
 		}
 
-		cbuf = kmalloc(len, GFP_KERNEL);
-		if (!cbuf)
-			return -ENOMEM;
+		cbuf = memdup_user(buf, len);
+		if (IS_ERR(cbuf))
+			return PTR_ERR(cbuf);
 
-		if (copy_from_user(cbuf, buf, len)) {
-			kfree(cbuf);
-			return -EFAULT;
-		}
 		memcpy_toio(dev->sh_mem, cbuf, len);
 		kfree(cbuf);
 		return len;
diff --git a/drivers/isdn/sc/ioctl.c b/drivers/isdn/sc/ioctl.c
index 1081091..43c5dc3 100644
--- a/drivers/isdn/sc/ioctl.c
+++ b/drivers/isdn/sc/ioctl.c
@@ -215,19 +215,13 @@ int sc_ioctl(int card, scs_ioctl *data)
 		pr_debug("%s: DCBIOSETSPID: ioctl received\n",
 				sc_adapter[card]->devicename);
 
-		spid = kmalloc(SCIOC_SPIDSIZE, GFP_KERNEL);
-		if(!spid) {
-			kfree(rcvmsg);
-			return -ENOMEM;
-		}
-
 		/*
 		 * Get the spid from user space
 		 */
-		if (copy_from_user(spid, data->dataptr, SCIOC_SPIDSIZE)) {
+		spid = memdup_user(data->dataptr, SCIOC_SPIDSIZE);
+		if (IS_ERR(spid)) {
 			kfree(rcvmsg);
-			kfree(spid);
-			return -EFAULT;
+			return PTR_ERR(spid);
 		}
 
 		pr_debug("%s: SCIOCSETSPID: setting channel %d spid to %s\n", 
@@ -296,18 +290,13 @@ int sc_ioctl(int card, scs_ioctl *data)
 		pr_debug("%s: SCIOSETDN: ioctl received\n",
 				sc_adapter[card]->devicename);
 
-		dn = kmalloc(SCIOC_DNSIZE, GFP_KERNEL);
-		if (!dn) {
-			kfree(rcvmsg);
-			return -ENOMEM;
-		}
 		/*
 		 * Get the spid from user space
 		 */
-		if (copy_from_user(dn, data->dataptr, SCIOC_DNSIZE)) {
+		dn = memdup_user(data->dataptr, SCIOC_DNSIZE);
+		if (IS_ERR(dn)) {
 			kfree(rcvmsg);
-			kfree(dn);
-			return -EFAULT;
+			return PTR_ERR(dn);
 		}
 
 		pr_debug("%s: SCIOCSETDN: setting channel %d dn to %s\n", 
