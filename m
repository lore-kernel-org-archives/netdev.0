From: Christoph Schulz <develop@kristov.de>
Subject: [PATCH net 1/1] net: ppp: don't call sk_chk_filter twice
Date: Sun, 13 Jul 2014 15:01:41 +0200
Message-ID: <53C28335.9090902@kristov.de>
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
sk_unattached_filter api") causes sk_chk_filter() to be called twice when
setting a PPP pass or active filter. This applies to both the generic PPP
subsystem implemented by drivers/net/ppp/ppp_generic.c and the ISDN PPP
subsystem implemented by drivers/isdn/i4l/isdn_ppp.c. The first call is from
within get_filter(). The second one is through the call chain

  ppp_ioctl() or isdn_ppp_ioctl()
  --> sk_unattached_filter_create()
      --> __sk_prepare_filter()
          --> sk_chk_filter()

The first call from within get_filter() should be deleted as get_filter() is
called just before calling sk_unattached_filter_create() later on, which
eventually calls sk_chk_filter() anyway.

For 3.15.x, this proposed change is a bugfix rather than a pure optimization as
in that branch, sk_chk_filter() may replace filter codes by other codes which
are not recognized when executing sk_chk_filter() a second time. So with
3.15.x, if sk_chk_filter() is called twice, the second invocation may yield
EINVAL (this depends on the filter codes found in the filter to be set, but
because the replacement is done for frequently used codes, this is almost
always the case). The net effect is that setting pass and/or active PPP filters
does not work anymore, since sk_unattached_filter_create() always returns
EINVAL due to the second call to sk_chk_filter(), regardless whether the filter
was originally sane or not.

Signed-off-by: Christoph Schulz <develop@kristov.de>
---
Sorry for the resend, I forgot to add netdev@vger.kernel.org to the recipient
list...

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
