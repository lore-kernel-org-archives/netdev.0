From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH v2] bridge: fix locking and memory leak in br_add_bridge
Date: Thu, 25 May 2006 09:23:31 -0700
Message-ID: <20060525092331.54f14a57@dxpl.pdx.osdl.net>
References: <20060525153124.478bea57@griffin.suse.cz>
	<20060525160735.3c2aa9a5@griffin.suse.cz>
	<20060525161432.4cbc11ee@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:55180 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030246AbWEYQXm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 May 2006 12:23:42 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060525161432.4cbc11ee@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are several bugs in error handling in br_add_bridge:
- when dev_alloc_name fails, allocated net_device is not freed
- unregister_netdev is called when rtnl lock is held
- free_netdev is called before netdev_run_todo has a chance to be run after
  unregistering net_device

This patch should fix these issues.
Minor rearrangement of to use common path of earlier patch. Dave please apply.

Signed-off-by: Jiri Benc <jbenc@suse.cz>
Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

--- br.orig/net/bridge/br_if.c
+++ br/net/bridge/br_if.c
@@ -301,25 +301,20 @@ int br_add_bridge(const char *name)
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
-	rtnl_unlock();
-	return 0;
-
- err3:
-	unregister_netdev(dev);
- err2:
-	free_netdev(dev);
- err1:
+		unregister_netdevice(dev);
+ err:
 	rtnl_unlock();
+	if (ret)
+		free_netdev(dev);
 	return ret;
 }
 
