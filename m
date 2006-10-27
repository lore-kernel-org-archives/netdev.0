From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] tcp: allow restricting congestion control choices
Date: Fri, 27 Oct 2006 10:59:00 -0700
Message-ID: <20061027105900.758e78b9@freekitty>
References: <4540F076.70801@psc.edu>
	<20061026224407.GA2018@c3po.0xdef.net>
	<20061026235256.GB2018@c3po.0xdef.net>
	<20061026.170221.99202188.davem@davemloft.net>
	<20061027104311.GB3967@c3po.0xdef.net>
	<20061027074102.2a6fef4b@localhost.localdomain>
	<20061027152157.GB4632@c3po.0xdef.net>
	<45422A31.7070806@osdl.org>
	<20061027103016.3e8514d7@freekitty>
	<4542452C.6050209@psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Hagen Paul Pfeifer <hagen@jauu.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:14212 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1752370AbWJ0R7p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 13:59:45 -0400
To: John Heffner <jheffner@psc.edu>,
	"David S. Miller" <davem@davemloft.net>
In-Reply-To: <4542452C.6050209@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is an alternative that allows runtime based restriction on some
TCP congestion control choices. 

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

---
 include/net/tcp.h   |    1 +
 net/ipv4/tcp_cong.c |    4 ++++
 2 files changed, 5 insertions(+)

--- sky2.orig/include/net/tcp.h	2006-10-27 10:46:19.000000000 -0700
+++ sky2/include/net/tcp.h	2006-10-27 10:46:55.000000000 -0700
@@ -651,6 +651,7 @@
 
 	char 		name[TCP_CA_NAME_MAX];
 	struct module 	*owner;
+	int		restricted;	/* NET_ADMIN only */
 };
 
 extern int tcp_register_congestion_control(struct tcp_congestion_ops *type);
--- sky2.orig/net/ipv4/tcp_cong.c	2006-10-27 10:51:47.000000000 -0700
+++ sky2/net/ipv4/tcp_cong.c	2006-10-27 10:56:36.000000000 -0700
@@ -10,6 +10,7 @@
 #include <linux/mm.h>
 #include <linux/types.h>
 #include <linux/list.h>
+#include <linux/capability.h>
 #include <net/tcp.h>
 
 static DEFINE_SPINLOCK(tcp_cong_list_lock);
@@ -159,6 +160,9 @@
 	if (!ca)
 		err = -ENOENT;
 
+	else if (ca->restricted && !capable(CAP_NET_ADMIN))
+		err = -EPERM;
+
 	else if (!try_module_get(ca->owner))
 		err = -EBUSY;
 
