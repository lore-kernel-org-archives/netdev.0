From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 4/5] tcp: allow autoloading of congestion control via setsockopt
Date: Tue, 31 Oct 2006 15:01:44 -0800
Message-ID: <20061031230214.056079805@osdl.org>
References: <20061031230140.191929094@osdl.org>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:25530 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1423860AbWJaXEO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 18:04:14 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=tcp-setsocktopt-autoload.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If user has permision to load modules, then autoload then attempt
autoload of TCP congestion module.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 net/ipv4/tcp_cong.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

--- tcp.orig/net/ipv4/tcp_cong.c	2006-10-31 15:00:26.000000000 -0800
+++ tcp/net/ipv4/tcp_cong.c	2006-10-31 15:00:54.000000000 -0800
@@ -113,7 +113,7 @@
 	spin_lock(&tcp_cong_list_lock);
 	ca = tcp_ca_find(name);
 #ifdef CONFIG_KMOD
-	if (!ca) {
+	if (!ca && capable(CAP_SYS_MODULE)) {
 		spin_unlock(&tcp_cong_list_lock);
 
 		request_module("tcp_%s", name);
@@ -236,9 +236,19 @@
 
 	rcu_read_lock();
 	ca = tcp_ca_find(name);
+	/* no change asking for existing value */
 	if (ca == icsk->icsk_ca_ops)
 		goto out;
 
+#ifdef CONFIG_KMOD
+	/* not found attempt to autoload module */
+	if (!ca && capable(CAP_SYS_MODULE)) {
+		rcu_read_unlock();
+		request_module("tcp_%s", name);
+		rcu_read_lock();
+		ca = tcp_ca_find(name);
+	}
+#endif
 	if (!ca)
 		err = -ENOENT;
 

--
Stephen Hemminger <shemminger@osdl.org>

