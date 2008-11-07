From: Benjamin Thery <benjamin.thery@bull.net>
Subject: [PATCH] ipv6: fix ip6_mr_init error path
Date: Fri, 07 Nov 2008 15:20:26 +0100
Message-ID: <20081107142027.249107446@nptl.frec.bull.fr>
References: <20081107142025.563493104@nptl.frec.bull.fr>
Cc: netdev <netdev@vger.kernel.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Dave Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:58706 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751543AbYKGOi0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 09:38:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The order of cleanup operations in the error/exit section of ip6_mr_init()
is completely inversed. It should be the other way around.
Also a del_timer() is missing in the error path.

Signed-off-by: Benjamin Thery <benjamin.thery@bull.net>
---
 net/ipv6/ip6mr.c |    9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

Index: net-2.6/net/ipv6/ip6mr.c
===================================================================
--- net-2.6.orig/net/ipv6/ip6mr.c
+++ net-2.6/net/ipv6/ip6mr.c
@@ -981,14 +981,15 @@ int __init ip6_mr_init(void)
 		goto proc_cache_fail;
 #endif
 	return 0;
-reg_notif_fail:
-	kmem_cache_destroy(mrt_cachep);
 #ifdef CONFIG_PROC_FS
-proc_vif_fail:
-	unregister_netdevice_notifier(&ip6_mr_notifier);
 proc_cache_fail:
 	proc_net_remove(&init_net, "ip6_mr_vif");
+proc_vif_fail:
+	unregister_netdevice_notifier(&ip6_mr_notifier);
 #endif
+reg_notif_fail:
+	del_timer(&ipmr_expire_timer);
+	kmem_cache_destroy(mrt_cachep);
 	return err;
 }
 

-- 
