From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH 2/2] bridge: do sysfs registration inside rtnl
Date: Wed, 10 May 2006 10:14:54 -0700
Message-ID: <20060510171623.897951000@localhost.localdomain>
References: <20060510171452.619146000@localhost.localdomain>
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:65177 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S965001AbWEJRR1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 May 2006 13:17:27 -0400
To: David Miller <davem@davemloft.net>
Content-Disposition: inline; filename=bridge-register.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Now that netdevice sysfs registration is done as part of register_netdevice;
bridge code no longer has to be tricky when adding it's kobjects to bridges.

Signed-off-by: Stephen Hemminger <shemminger@osdl.org>


--- bridge.orig/net/bridge/br_if.c	2006-05-04 16:22:29.000000000 -0700
+++ bridge/net/bridge/br_if.c	2006-05-09 11:27:16.000000000 -0700
@@ -308,26 +308,19 @@
 	if (ret)
 		goto err2;
 
-	/* network device kobject is not setup until
-	 * after rtnl_unlock does it's hotplug magic.
-	 * so hold reference to avoid race.
-	 */
-	dev_hold(dev);
-	rtnl_unlock();
-
 	ret = br_sysfs_addbr(dev);
-	dev_put(dev);
-
-	if (ret) 
-		unregister_netdev(dev);
- out:
-	return ret;
+	if (ret)
+		goto err3;
+	rtnl_unlock();
+	return 0;
 
+ err3:
+	unregister_netdev(dev);
  err2:
 	free_netdev(dev);
  err1:
 	rtnl_unlock();
-	goto out;
+	return ret;
 }
 
 int br_del_bridge(const char *name)

--

