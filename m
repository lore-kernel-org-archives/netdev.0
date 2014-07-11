From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH net-next] net: ppp: fix creating PPP pass and active filters
Date: Fri, 11 Jul 2014 09:10:40 +0200
Message-ID: <53BF8DF0.6030003@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: netdev@vger.kernel.org
Return-path: <linux-ppp-owner@vger.kernel.org>
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Schulz <develop@kristov.de>

Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
sk_unattached_filter api") inadvertently changed the logic when setting
pass and active PPP filters. The original ppp_ioctl() code handling PPPIOCSPASS
and PPPIOCSACTIVE allowed to remove a pass/active filter previously set by
using a filter of length zero. However, with the new code this is not possible
anymore as this case is not explicitly checked for, which leads to passing NULL
as a filter to sk_unattached_filter_create(). This results in returning EINVAL
to the caller. Additionally, ppp->pass_filter and ppp->active_filter are not
reset by sk_unattached_filter_create() in this EINVAL case, so dangling
pointers may be left behind. This patch corrects both problems by checking
whether the filter passed is empty or not, and so prevents
sk_unattached_filter_create() from being called for empty filters.

This error is found in exactly the same way in the isdn4linux PPP driver, so
it is fixed there the same way.

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 61ac632..cd2f4c3 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -644,9 +644,15 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 		fprog.len = len;
 		fprog.filter = code;
 
-		if (is->pass_filter)
+		if (is->pass_filter) {
 			sk_unattached_filter_destroy(is->pass_filter);
-		err = sk_unattached_filter_create(&is->pass_filter, &fprog);
+			is->pass_filter = NULL;
+		}
+		if (fprog.filter != NULL)
+			err = sk_unattached_filter_create(&is->pass_filter,
+							  &fprog);
+		else
+			err = 0;
 		kfree(code);
 
 		return err;
@@ -663,9 +669,15 @@ isdn_ppp_ioctl(int min, struct file *file, unsigned int cmd, unsigned long arg)
 		fprog.len = len;
 		fprog.filter = code;
 
-		if (is->active_filter)
+		if (is->active_filter) {
 			sk_unattached_filter_destroy(is->active_filter);
-		err = sk_unattached_filter_create(&is->active_filter, &fprog);
+			is->active_filter = NULL;
+		}
+		if (fprog.filter != NULL)
+			err = sk_unattached_filter_create(&is->active_filter,
+							  &fprog);
+		else
+			err = 0;
 		kfree(code);
 
 		return err;
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 91d6c12..d0f6f93 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -763,10 +763,15 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			};
 
 			ppp_lock(ppp);
-			if (ppp->pass_filter)
+			if (ppp->pass_filter) {
 				sk_unattached_filter_destroy(ppp->pass_filter);
-			err = sk_unattached_filter_create(&ppp->pass_filter,
-							  &fprog);
+				ppp->pass_filter = NULL;
+			}
+			if (fprog.filter != NULL)
+				err = sk_unattached_filter_create(&ppp->pass_filter,
+								  &fprog);
+			else
+				err = 0;
 			kfree(code);
 			ppp_unlock(ppp);
 		}
@@ -784,10 +789,15 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
 			};
 
 			ppp_lock(ppp);
-			if (ppp->active_filter)
+			if (ppp->active_filter) {
 				sk_unattached_filter_destroy(ppp->active_filter);
-			err = sk_unattached_filter_create(&ppp->active_filter,
-							  &fprog);
+				ppp->active_filter = NULL;
+			}
+			if (fprog.filter != NULL)
+				err = sk_unattached_filter_create(&ppp->active_filter,
+								  &fprog);
+			else
+				err = 0;
 			kfree(code);
 			ppp_unlock(ppp);
 		}
