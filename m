From: Benjamin LaHaise <bcrl@kvack.org>
Subject: [PATCH/RFC] make unregister_netdev() delete more than 4 interfaces per second
Date: Sat, 17 Oct 2009 18:18:57 -0400
Message-ID: <20091017221857.GG1925@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from kanga.kvack.org ([205.233.56.17]:49293 "EHLO kanga.kvack.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752362AbZJQWpe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Oct 2009 18:45:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

Below is a patch that changes the interaction between netdev_wait_allrefs() 
and dev_put() to replace an msleep(250) with a wait_event() on the final 
dev_put().  This change reduces the time spent sleeping during an 
unregister_netdev(), causing the system to go from <1% CPU time to something 
more CPU bound (50+% in a test vm).  This increases the speed of a bulk 
unregister_netdev() from 4 interfaces per second to over 500 per second on 
my test system.  The requirement comes from handling thousands of L2TP 
sessions where a tunnel flap results in all interfaces being torn down at 
one time.

Note that there is still more work to be done in this area.

		-ben

Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 812a5f3..e20d4a4 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1514,10 +1514,7 @@ extern void netdev_run_todo(void);
  *
  * Release reference to device to allow it to be freed.
  */
-static inline void dev_put(struct net_device *dev)
-{
-	atomic_dec(&dev->refcnt);
-}
+void dev_put(struct net_device *dev);
 
 /**
  *	dev_hold - get reference to device
diff --git a/net/core/dev.c b/net/core/dev.c
index b8f74cf..155217f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4945,6 +4945,16 @@ out:
 }
 EXPORT_SYMBOL(register_netdev);
 
+DECLARE_WAIT_QUEUE_HEAD(netdev_refcnt_wait);
+
+void dev_put(struct net_device *dev)
+{
+        if (atomic_dec_and_test(&dev->refcnt))
+		wake_up(&netdev_refcnt_wait);
+}
+EXPORT_SYMBOL(dev_put);
+
+
 /*
  * netdev_wait_allrefs - wait until all references are gone.
  *
@@ -4984,7 +4994,8 @@ static void netdev_wait_allrefs(struct net_device *dev)
 			rebroadcast_time = jiffies;
 		}
 
-		msleep(250);
+		wait_event_timeout(netdev_refcnt_wait,
+				   !atomic_read(&dev->refcnt), HZ/4);
 
 		if (time_after(jiffies, warning_time + 10 * HZ)) {
 			printk(KERN_EMERG "unregister_netdevice: "
