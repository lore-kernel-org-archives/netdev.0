From: Jiri Benc <jbenc@suse.cz>
Subject: [PATCH v2] bridge: fix locking and memory leak in br_add_bridge
Date: Thu, 25 May 2006 16:14:32 +0200
Message-ID: <20060525161432.4cbc11ee@griffin.suse.cz>
References: <20060525153124.478bea57@griffin.suse.cz>
	<20060525160735.3c2aa9a5@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:65154 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1030193AbWEYOOe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 10:14:34 -0400
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20060525160735.3c2aa9a5@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are several bugs in error handling in br_add_bridge:
- when dev_alloc_name fails, allocated net_device is not freed
- unregister_netdev is called when rtnl lock is held
- free_netdev is called before netdev_run_todo has a chance to be run after
  unregistering net_device

This patch should fix these issues.

Signed-off-by: Jiri Benc <jbenc@suse.cz>

---

 net/bridge/br_if.c |   15 ++++++---------
 1 files changed, 6 insertions(+), 9 deletions(-)

--- dscape.orig/net/bridge/br_if.c
+++ dscape/net/bridge/br_if.c
@@ -301,25 +301,22 @@ int br_add_bridge(const char *name)
 	if (strchr(dev->name, '%')) {
 		ret = dev_alloc_name(dev, dev->name);
 		if (ret < 0)
-			goto err1;
+			goto err;
 	}
 
 	ret = register_netdevice(dev);
 	if (ret)
-		goto err2;
+		goto err;
 
 	ret = br_sysfs_addbr(dev);
 	if (ret)
-		goto err3;
+		unregister_netdevice(dev);
 	rtnl_unlock();
-	return 0;
+	return ret;
 
- err3:
-	unregister_netdev(dev);
- err2:
-	free_netdev(dev);
- err1:
+ err:
 	rtnl_unlock();
+	free_netdev(dev);
 	return ret;
 }
 

-- 
Jiri Benc
SUSE Labs
