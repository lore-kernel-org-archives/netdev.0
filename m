From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 3/4] Cleanup the error path in sk_attach_filter
Date: Wed, 17 Oct 2007 13:51:11 +0400
Message-ID: <4715DB0F.4050009@openvz.org>
References: <4715D9D2.8070102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52525 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757273AbXJQJxm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 05:53:42 -0400
In-Reply-To: <4715D9D2.8070102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The sk_filter_uncharge is called for error handling and
for releasing the former filter, but this will have to
be done in a bit different manner, so cleanup the error
path a bit.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/net/core/filter.c b/net/core/filter.c
index 2be1830..54dddc9 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -398,7 +398,7 @@ int sk_chk_filter(struct sock_filter *filter, int flen)
  */
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 {
-	struct sk_filter *fp;
+	struct sk_filter *fp, *old_fp;
 	unsigned int fsize = sizeof(struct sock_filter) * fprog->len;
 	int err;
 
@@ -418,19 +418,18 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	fp->len = fprog->len;
 
 	err = sk_chk_filter(fp->insns, fp->len);
-	if (!err) {
-		struct sk_filter *old_fp;
-
-		rcu_read_lock_bh();
-		old_fp = rcu_dereference(sk->sk_filter);
-		rcu_assign_pointer(sk->sk_filter, fp);
-		rcu_read_unlock_bh();
-		fp = old_fp;
+	if (err) {
+		sk_filter_uncharge(sk, fp);
+		return err;
 	}
 
-	if (fp)
-		sk_filter_uncharge(sk, fp);
-	return err;
+	rcu_read_lock_bh();
+	old_fp = rcu_dereference(sk->sk_filter);
+	rcu_assign_pointer(sk->sk_filter, fp);
+	rcu_read_unlock_bh();
+
+	sk_filter_uncharge(sk, old_fp);
+	return 0;
 }
 
 int sk_detach_filter(struct sock *sk)
-- 
1.5.3.4

