From: Stephen Hemminger <shemminger@osdl.org>
Subject: [RFC] tcp: setsockopt congestion control autoload
Date: Wed, 25 Oct 2006 11:08:43 -0700
Message-ID: <20061025110843.0cbd18a7@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:27600 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964897AbWJYWTM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 18:19:12 -0400
To: "David S. Miller" <davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If user asks for a congestion control type with setsockopt() then it
may be available as a module not included in the kernel already. 
It should be autoloaded if needed.  This is done already when
the default selection is change with sysctl, but not when application
requests via sysctl.

Only reservation is are there any bad security implications from this?

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- orig/net/ipv4/tcp_cong.c	2006-10-25 13:55:34.000000000 -0700
+++ new/net/ipv4/tcp_cong.c	2006-10-25 13:58:39.000000000 -0700
@@ -153,9 +153,19 @@
 
 	rcu_read_lock();
 	ca = tcp_ca_find(name);
+	/* no change asking for existing value */
 	if (ca == icsk->icsk_ca_ops)
 		goto out;
 
+#ifdef CONFIG_KMOD
+	/* not found attempt to autoload module */
+	if (!ca) {
+		rcu_read_unlock();
+		request_module("tcp_%s", name);
+		rcu_read_lock();
+		ca = tcp_ca_find(name);
+	}
+#endif
 	if (!ca)
 		err = -ENOENT;
 
