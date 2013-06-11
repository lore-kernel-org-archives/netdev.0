From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH v3 net 3/5] vxlan: fix crash on module removal
Date: Mon, 10 Jun 2013 17:37:22 -0700
Message-ID: <20130610173722.484fd2e3@nehalam.linuxnetplumber.net>
References: <20130611002547.346603375@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:40216 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474Ab3FKAho (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jun 2013 20:37:44 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf11so2272212pab.38
        for <netdev@vger.kernel.org>; Mon, 10 Jun 2013 17:37:44 -0700 (PDT)
In-Reply-To: <20130611002547.346603375@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If vxlan is removed with active vxlan's it would crash because
rtnl_link_unregister (which calls vxlan_dellink), was invoked
before unregister_pernet_device (which calls vxlan_stop).

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
v3 - get rid of destroy_workqueue that snuck in from later patch

Should go to stable as well

--- a/drivers/net/vxlan.c	2013-06-10 15:06:15.186973784 -0700
+++ b/drivers/net/vxlan.c	2013-06-10 15:10:11.603785773 -0700
@@ -1785,8 +1785,8 @@ late_initcall(vxlan_init_module);
 
 static void __exit vxlan_cleanup_module(void)
 {
-	rtnl_link_unregister(&vxlan_link_ops);
 	unregister_pernet_device(&vxlan_net_ops);
+	rtnl_link_unregister(&vxlan_link_ops);
 	rcu_barrier();
 }
 module_exit(vxlan_cleanup_module);
