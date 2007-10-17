From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 2/4] Move the filter releasing into a separate call
Date: Wed, 17 Oct 2007 13:49:38 +0400
Message-ID: <4715DAB2.3030704@openvz.org>
References: <4715D9D2.8070102@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:52520 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751297AbXJQJxc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 05:53:32 -0400
In-Reply-To: <4715D9D2.8070102@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is done merely as a preparation for the fix.

The sk_filter_uncharge() unaccounts the filter memory and calls
the sk_filter_release(), which in turn decrements the refcount
anf frees the filter.

The latter function will be required separately.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/include/net/sock.h b/include/net/sock.h
index 453c79d..b9cfe12 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -922,14 +922,18 @@ static inline void sk_filter_rcu_free(struct rcu_head *rcu)
  *	Remove a filter from a socket and release its resources.
  */
 
-static inline void sk_filter_release(struct sock *sk, struct sk_filter *fp)
+static inline void sk_filter_release(struct sk_filter *fp)
+{
+	if (atomic_dec_and_test(&fp->refcnt))
+		call_rcu_bh(&fp->rcu, sk_filter_rcu_free);
+}
+
+static inline void sk_filter_uncharge(struct sock *sk, struct sk_filter *fp)
 {
 	unsigned int size = sk_filter_len(fp);
 
 	atomic_sub(size, &sk->sk_omem_alloc);
-
-	if (atomic_dec_and_test(&fp->refcnt))
-		call_rcu_bh(&fp->rcu, sk_filter_rcu_free);
+	sk_filter_release(fp);
 }
 
 static inline void sk_filter_charge(struct sock *sk, struct sk_filter *fp)
diff --git a/net/core/filter.c b/net/core/filter.c
index fd60758..2be1830 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -429,7 +429,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	}
 
 	if (fp)
-		sk_filter_release(sk, fp);
+		sk_filter_uncharge(sk, fp);
 	return err;
 }
 
@@ -442,7 +442,7 @@ int sk_detach_filter(struct sock *sk)
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
 		rcu_assign_pointer(sk->sk_filter, NULL);
-		sk_filter_release(sk, filter);
+		sk_filter_uncharge(sk, filter);
 		ret = 0;
 	}
 	rcu_read_unlock_bh();
diff --git a/net/core/sock.c b/net/core/sock.c
index 0710138..d292b41 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -915,7 +915,7 @@ void sk_free(struct sock *sk)
 
 	filter = rcu_dereference(sk->sk_filter);
 	if (filter) {
-		sk_filter_release(sk, filter);
+		sk_filter_uncharge(sk, filter);
 		rcu_assign_pointer(sk->sk_filter, NULL);
 	}
 
-- 
1.5.3.4

