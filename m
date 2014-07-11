From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH net-next] net: ppp: don't call sk_chk_filter twice
Date: Fri, 11 Jul 2014 09:10:36 +0200
Message-ID: <53BF8DEC.4000307@kristov.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: linux-ppp@vger.kernel.org, paulus@samba.org, isdn@linux-pingi.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from server721-han.de-nserver.de ([85.158.180.102]:59079 "EHLO
	server721-han.de-nserver.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751154AbaGKHQG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jul 2014 03:16:06 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Schulz <develop@kristov.de>

Commit 568f194e8bd16c353ad50f9ab95d98b20578a39d ("net: ppp: use
sk_unattached_filter api") causes sk_chk_filter() to be called twice when
setting a pass or active filter. The first call is from within get_filter().
The second one is through the call chain

  ppp_ioctl() --> sk_unattached_filter_create()
              --> __sk_prepare_filter()
              --> sk_chk_filter()

However, sk_chk_filter() is not idempotent as it sometimes replaces filter
codes. So running it a second time over the same filter does not work and
yields EINVAL. The net effect is that setting pass and/or active PPP filters
does not work anymore, since sk_unattached_filter_create() always returns
EINVAL due to the second (and erroneous) call to sk_chk_filter(), regardless
whether the filter was sane or not. So this patch simply removes the call to
sk_chk_filter() from within get_filter(). This is safe as the filter will
be checked by sk_chk_filter() later anyway.

This error is found in exactly the same way in the isdn4linux PPP driver, so
it is fixed there the same way.

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
diff --git a/drivers/isdn/i4l/isdn_ppp.c b/drivers/isdn/i4l/isdn_ppp.c
index 61ac632..a333b7f 100644
--- a/drivers/isdn/i4l/isdn_ppp.c
+++ b/drivers/isdn/i4l/isdn_ppp.c
@@ -442,7 +442,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 {
 	struct sock_fprog uprog;
 	struct sock_filter *code = NULL;
-	int len, err;
+	int len;
 
 	if (copy_from_user(&uprog, arg, sizeof(uprog)))
 		return -EFAULT;
@@ -458,12 +458,6 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 	if (IS_ERR(code))
 		return PTR_ERR(code);
 
-	err = sk_chk_filter(code, uprog.len);
-	if (err) {
-		kfree(code);
-		return err;
-	}
-
 	*p = code;
 	return uprog.len;
 }
diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
index 91d6c12..e2f20f8 100644
--- a/drivers/net/ppp/ppp_generic.c
+++ b/drivers/net/ppp/ppp_generic.c
@@ -539,7 +539,7 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 {
 	struct sock_fprog uprog;
 	struct sock_filter *code = NULL;
-	int len, err;
+	int len;
 
 	if (copy_from_user(&uprog, arg, sizeof(uprog)))
 		return -EFAULT;
@@ -554,12 +554,6 @@ static int get_filter(void __user *arg, struct sock_filter **p)
 	if (IS_ERR(code))
 		return PTR_ERR(code);
 
-	err = sk_chk_filter(code, uprog.len);
-	if (err) {
-		kfree(code);
-		return err;
-	}
-
 	*p = code;
 	return uprog.len;
 }
