From: Jason Uhlenkott <juhlenko@akamai.com>
Subject: [RFC 1/4] net core: move timestamp functions
Date: Sun, 20 Apr 2008 22:34:47 -0700
Message-ID: <20080421053447.GA31778@48M1231.sanmateo.corp.akamai.com>
References: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:55284 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750976AbYDUFkD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Apr 2008 01:40:03 -0400
Content-Disposition: inline
In-Reply-To: <20080421053402.GB23476@48M1231.sanmateo.corp.akamai.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reorganize some timestamp related functions which were scattered
around sock.c.

This is pure code motion with no changes.

Signed-off-by: Jason Uhlenkott <juhlenko@akamai.com>


---
 net/core/sock.c |   80 ++++++++++++++++++++++++++++----------------------------
 1 file changed, 40 insertions(+), 40 deletions(-)

Index: linux/net/core/sock.c
===================================================================
--- linux.orig/net/core/sock.c	2008-04-18 17:18:11.000000000 -0700
+++ linux/net/core/sock.c	2008-04-20 21:03:54.000000000 -0700
@@ -255,6 +255,46 @@
 	}
 }
 
+int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
+{
+	struct timeval tv;
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	tv = ktime_to_timeval(sk->sk_stamp);
+	if (tv.tv_sec == -1)
+		return -ENOENT;
+	if (tv.tv_sec == 0) {
+		sk->sk_stamp = ktime_get_real();
+		tv = ktime_to_timeval(sk->sk_stamp);
+	}
+	return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
+}
+EXPORT_SYMBOL(sock_get_timestamp);
+
+int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
+{
+	struct timespec ts;
+	if (!sock_flag(sk, SOCK_TIMESTAMP))
+		sock_enable_timestamp(sk);
+	ts = ktime_to_timespec(sk->sk_stamp);
+	if (ts.tv_sec == -1)
+		return -ENOENT;
+	if (ts.tv_sec == 0) {
+		sk->sk_stamp = ktime_get_real();
+		ts = ktime_to_timespec(sk->sk_stamp);
+	}
+	return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
+}
+EXPORT_SYMBOL(sock_get_timestampns);
+
+void sock_enable_timestamp(struct sock *sk)
+{
+	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
+		sock_set_flag(sk, SOCK_TIMESTAMP);
+		net_enable_timestamp();
+	}
+}
+
 static void sock_disable_timestamp(struct sock *sk)
 {
 	if (sock_flag(sk, SOCK_TIMESTAMP)) {
@@ -1765,46 +1805,6 @@
 }
 EXPORT_SYMBOL(release_sock);
 
-int sock_get_timestamp(struct sock *sk, struct timeval __user *userstamp)
-{
-	struct timeval tv;
-	if (!sock_flag(sk, SOCK_TIMESTAMP))
-		sock_enable_timestamp(sk);
-	tv = ktime_to_timeval(sk->sk_stamp);
-	if (tv.tv_sec == -1)
-		return -ENOENT;
-	if (tv.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		tv = ktime_to_timeval(sk->sk_stamp);
-	}
-	return copy_to_user(userstamp, &tv, sizeof(tv)) ? -EFAULT : 0;
-}
-EXPORT_SYMBOL(sock_get_timestamp);
-
-int sock_get_timestampns(struct sock *sk, struct timespec __user *userstamp)
-{
-	struct timespec ts;
-	if (!sock_flag(sk, SOCK_TIMESTAMP))
-		sock_enable_timestamp(sk);
-	ts = ktime_to_timespec(sk->sk_stamp);
-	if (ts.tv_sec == -1)
-		return -ENOENT;
-	if (ts.tv_sec == 0) {
-		sk->sk_stamp = ktime_get_real();
-		ts = ktime_to_timespec(sk->sk_stamp);
-	}
-	return copy_to_user(userstamp, &ts, sizeof(ts)) ? -EFAULT : 0;
-}
-EXPORT_SYMBOL(sock_get_timestampns);
-
-void sock_enable_timestamp(struct sock *sk)
-{
-	if (!sock_flag(sk, SOCK_TIMESTAMP)) {
-		sock_set_flag(sk, SOCK_TIMESTAMP);
-		net_enable_timestamp();
-	}
-}
-
 /*
  *	Get a socket option on an socket.
  *
