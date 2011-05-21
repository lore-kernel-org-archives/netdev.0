From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] garp: use kfree_rcu()
Date: Sat, 21 May 2011 06:31:30 +0200
Message-ID: <1305952290.2862.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55194 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750894Ab1EUEbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 May 2011 00:31:34 -0400
Received: by wya21 with SMTP id 21so3125260wya.19
        for <netdev@vger.kernel.org>; Fri, 20 May 2011 21:31:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use kfree_rcu() instead of call_rcu(), remove garp_cleanup_module()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/802/garp.c |   20 ++------------------
 1 file changed, 2 insertions(+), 18 deletions(-)

diff --git a/net/802/garp.c b/net/802/garp.c
index f8300a8..1610295 100644
--- a/net/802/garp.c
+++ b/net/802/garp.c
@@ -544,11 +544,6 @@ static int garp_init_port(struct net_device *dev)
 	return 0;
 }
 
-static void garp_kfree_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct garp_port, rcu));
-}
-
 static void garp_release_port(struct net_device *dev)
 {
 	struct garp_port *port = rtnl_dereference(dev->garp_port);
@@ -559,7 +554,7 @@ static void garp_release_port(struct net_device *dev)
 			return;
 	}
 	rcu_assign_pointer(dev->garp_port, NULL);
-	call_rcu(&port->rcu, garp_kfree_rcu);
+	kfree_rcu(port, rcu);
 }
 
 int garp_init_applicant(struct net_device *dev, struct garp_application *appl)
@@ -603,11 +598,6 @@ err1:
 }
 EXPORT_SYMBOL_GPL(garp_init_applicant);
 
-static void garp_app_kfree_rcu(struct rcu_head *head)
-{
-	kfree(container_of(head, struct garp_applicant, rcu));
-}
-
 void garp_uninit_applicant(struct net_device *dev, struct garp_application *appl)
 {
 	struct garp_port *port = rtnl_dereference(dev->garp_port);
@@ -625,7 +615,7 @@ void garp_uninit_applicant(struct net_device *dev, struct garp_application *appl
 	garp_queue_xmit(app);
 
 	dev_mc_del(dev, appl->proto.group_address);
-	call_rcu(&app->rcu, garp_app_kfree_rcu);
+	kfree_rcu(app, rcu);
 	garp_release_port(dev);
 }
 EXPORT_SYMBOL_GPL(garp_uninit_applicant);
@@ -643,9 +633,3 @@ void garp_unregister_application(struct garp_application *appl)
 	stp_proto_unregister(&appl->proto);
 }
 EXPORT_SYMBOL_GPL(garp_unregister_application);
-
-static void __exit garp_cleanup_module(void)
-{
-	rcu_barrier(); /* Wait for completion of call_rcu()'s */
-}
-module_exit(garp_cleanup_module);


