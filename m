From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH] bridge: fix locking and memory leak in br_add_bridge
Date: Thu, 25 May 2006 15:31:24 +0200
Message-ID: <20060525153124.478bea57@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:63872 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S965176AbWEYNb2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 09:31:28 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are several problems in error handling in br_add_bridge:
- when dev_alloc_name fails, allocated net_device is not freed
- unregister_netdev is called when rtnl lock is held
- free_netdev is called before netdev_run_todo has a chance to be run after
  unregistering net_device

This patch should fix these issues.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/bridge/br_if.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

--- dscape.orig/net/bridge/br_if.c
+++ dscape/net/bridge/br_if.c
@@ -306,20 +306,19 @@ int br_add_bridge(const char *name)
 
 	ret = register_netdevice(dev);
 	if (ret)
-		goto err2;
+		goto err1;
 
 	ret = br_sysfs_addbr(dev);
 	if (ret)
-		goto err3;
+		goto err2;
 	rtnl_unlock();
 	return 0;
 
- err3:
-	unregister_netdev(dev);
  err2:
-	free_netdev(dev);
+	unregister_netdevice(dev);
  err1:
 	rtnl_unlock();
+	free_netdev(dev);
 	return ret;
 }
 


-- 
Jiri Benc
SUSE Labs
