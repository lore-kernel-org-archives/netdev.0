From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] net: fix ip_mr_init() error path
Date: Mon, 17 Nov 2008 09:41:55 +0100
Message-ID: <20081117084157.953413470@nptl.frec.bull.fr>
References: <20081117084154.369686935@nptl.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58572 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754649AbYKQJDe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 04:03:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similarly to IPv6 ip6_mr_init() (fixed last week), the order of cleanup
operations in the error/exit section of ip_mr_init() is completely 
inversed. It should be the other way around.
Also a del_timer() is missing in the error path.

I should have guessed last week that this same error existed in ipmr.c
too, as ip6mr.c is largely inspired by ipmr.c.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv4/ipmr.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: net-2.6/net/ipv4/ipmr.c
===================================================================
--- net-2.6.orig/net/ipv4/ipmr.c
+++ net-2.6/net/ipv4/ipmr.c
@@ -1945,13 +1945,14 @@ int __init ip_mr_init(void)
 		goto proc_cache_fail;
 #endif
 	return 0;
-reg_notif_fail:
-	kmem_cache_destroy(mrt_cachep);
 #ifdef CONFIG_PROC_FS
-proc_vif_fail:
-	unregister_netdevice_notifier(&ip_mr_notifier);
 proc_cache_fail:
 	proc_net_remove(&init_net, "ip_mr_vif");
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip_mr_notifier);
 #endif
+reg_notif_fail:
+	del_timer(&ipmr_expire_timer);
+	kmem_cache_destroy(mrt_cachep);
 	return err;
 }

-- 
