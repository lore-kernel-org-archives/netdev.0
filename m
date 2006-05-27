From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH v3] bridge: fix locking and memory leak in br_add_bridge
Date: Sat, 27 May 2006 09:45:28 -0700
Message-ID: <20060527094528.0c330d9f@localhost.localdomain>
References: <20060525161432.4cbc11ee@griffin.suse.cz>
	<20060525092331.54f14a57@dxpl.pdx.osdl.net>
	<20060526110806.1fa49fe1@griffin.suse.cz>
	<20060526.192611.109883073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jbenc@suse.cz, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:28872 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S964914AbWE0Qpg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 May 2006 12:45:36 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060526.192611.109883073.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are several bugs in error handling in br_add_bridge:
- when dev_alloc_name fails, allocated net_device is not freed
- unregister_netdev is called when rtnl lock is held
- free_netdev is called before netdev_run_todo has a chance to be run after
  unregistering net_device

Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
--- br.orig/net/bridge/br_if.c
+++ br/net/bridge/br_if.c
@@ -300,25 +300,20 @@ int br_add_bridge(const char *name)
 	rtnl_lock();
 	if (strchr(dev->name, '%')) {
 		ret = dev_alloc_name(dev, dev->name);
-		if (ret < 0)
-			goto err1;
+		if (ret < 0) {
+			free_netdev(dev);
+			goto out;
+		}
 	}
 
 	ret = register_netdevice(dev);
 	if (ret)
-		goto err2;
+		goto out;
 
 	ret = br_sysfs_addbr(dev);
 	if (ret)
-		goto err3;
-	rtnl_unlock();
-	return 0;
-
- err3:
-	unregister_netdev(dev);
- err2:
-	free_netdev(dev);
- err1:
+		unregister_netdevice(dev);
+ out:
 	rtnl_unlock();
 	return ret;
 }
