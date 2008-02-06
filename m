From: urs.thuermann@gmx.de
Subject: [patch 1/3] CAN: Clean up module auto loading
Date: Wed,  6 Feb 2008 23:07:50 +0100
Message-ID: <20080206220825.20500.1@janus.isnogud.escape.de>
References: <20080206220749.20500.0@janus.isnogud.escape.de>
Cc: Urs Thuermann <urs.thuermann@volkswagen.de>,
	Oliver Hartkopp <oliver.hartkopp@volkswagen.de>,
	Oliver Hartkopp <oliver@hartkopp.net>
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from oker.escape.de ([194.120.234.254]:54363 "EHLO oker.escape.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762882AbYBFXHV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Feb 2008 18:07:21 -0500
Content-Disposition: inline; filename=module-load
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove local char array to construct module name.
Don't call request_module() when CONFIG_KMOD is not set.

Signed-off-by: Urs Thuermann <urs.thuermann@volkswagen.de>
Signed-off-by: Oliver Hartkopp <oliver.hartkopp@volkswagen.de>

---
 net/can/af_can.c |   18 ++++++------------
 1 file changed, 6 insertions(+), 12 deletions(-)

Index: net-2.6/net/can/af_can.c
===================================================================
--- net-2.6.orig/net/can/af_can.c	2008-02-06 22:17:58.000000000 +0100
+++ net-2.6/net/can/af_can.c	2008-02-06 22:20:46.000000000 +0100
@@ -118,7 +118,6 @@
 {
 	struct sock *sk;
 	struct can_proto *cp;
-	char module_name[sizeof("can-proto-000")];
 	int err = 0;
 
 	sock->state = SS_UNCONNECTED;
@@ -129,26 +128,21 @@
 	if (net != &init_net)
 		return -EAFNOSUPPORT;
 
+#ifdef CONFIG_KMOD
 	/* try to load protocol module, when CONFIG_KMOD is defined */
 	if (!proto_tab[protocol]) {
-		sprintf(module_name, "can-proto-%d", protocol);
-		err = request_module(module_name);
+		err = request_module("can-proto-%d", protocol);
 
 		/*
 		 * In case of error we only print a message but don't
 		 * return the error code immediately.  Below we will
 		 * return -EPROTONOSUPPORT
 		 */
-		if (err == -ENOSYS) {
-			if (printk_ratelimit())
-				printk(KERN_INFO "can: request_module(%s)"
-				       " not implemented.\n", module_name);
-		} else if (err) {
-			if (printk_ratelimit())
-				printk(KERN_ERR "can: request_module(%s)"
-				       " failed.\n", module_name);
-		}
+		if (err && printk_ratelimit())
+			printk(KERN_ERR "can: request_module "
+			       "(can-proto-%d) failed.\n", protocol);
 	}
+#endif
 
 	spin_lock(&proto_tab_lock);
 	cp = proto_tab[protocol];

--
