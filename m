From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: setsockopt congestion control autoload
Date: Fri, 27 Oct 2006 11:14:01 -0700
Message-ID: <20061027111401.4795b5ba@freekitty>
References: <20061025110843.0cbd18a7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:39562 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1750724AbWJ0SOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 14:14:05 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20061025110843.0cbd18a7@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If application asks for a congestion control type with setsockopt() 
then it may be available as a module not included in the kernel already. 
If it has permission to load modules then the tcp congestion
module should be autoloaded if needed.  This is done already when
the default selection is change with sysctl, but not when application
requests via sysctl.
 
Add a similar additional check to the sysctl path as well.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
 
---
 net/ipv4/tcp_cong.c |   12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

--- a/net/ipv4/tcp_cong.c	2006-10-27 10:56:36.000000000 -0700
+++ b/net/ipv4/tcp_cong.c	2006-10-27 11:09:36.000000000 -0700
@@ -114,7 +114,7 @@
 	spin_lock(&tcp_cong_list_lock);
 	ca = tcp_ca_find(name);
 #ifdef CONFIG_KMOD
-	if (!ca) {
+	if (!ca && capable(CAP_SYS_MODULE)) {
 		spin_unlock(&tcp_cong_list_lock);
 
 		request_module("tcp_%s", name);
@@ -154,9 +154,19 @@
 
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
 

Stephen Hemminger <shemminger@osdl.org>
