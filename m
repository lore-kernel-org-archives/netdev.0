From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] Fix race condition about network device name allocation
Date: Mon, 14 May 2007 08:58:40 -0700
Message-ID: <20070514085840.17a343f7@freepuppy>
References: <1178862045.3979.33.camel@kane-linux>
	<20070511092519.1f34ab34@freepuppy>
	<1179130660.3881.23.camel@kane-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Kenji Kaneshige <kaneshige.kenji@jp.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.linux-foundation.org ([207.189.120.12]:58099 "EHLO
	smtp.osdl.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754286AbXENP7A (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 11:59:00 -0400
In-Reply-To: <1179130660.3881.23.camel@kane-linux>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kenji Kaneshige found this race between device removal and
registration.  On unregister it is possible for the old device to
exist, because sysfs file is still open.  A new device with 'eth%d'
will select the same name, but sysfs kobject register will fial.

The following changes the shutdown order slightly. It hold a removes the sysfs
entries earlier (on unregister_netdevice), but holds a kobject reference.
Then when todo runs the actual last put free happens.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

---
 net/core/dev.c       |   10 ++++++----
 net/core/net-sysfs.c |    8 +++++++-
 2 files changed, 13 insertions(+), 5 deletions(-)

--- 2.6.21-rc1.orig/net/core/dev.c	2007-05-11 11:02:55.000000000 -0700
+++ 2.6.21-rc1/net/core/dev.c	2007-05-14 08:44:52.000000000 -0700
@@ -3245,7 +3245,6 @@ void netdev_run_todo(void)
 			continue;
 		}
 
-		netdev_unregister_sysfs(dev);
 		dev->reg_state = NETREG_UNREGISTERED;
 
 		netdev_wait_allrefs(dev);
@@ -3256,11 +3255,11 @@ void netdev_run_todo(void)
 		BUG_TRAP(!dev->ip6_ptr);
 		BUG_TRAP(!dev->dn_ptr);
 
-		/* It must be the very last action,
-		 * after this 'dev' may point to freed up memory.
-		 */
 		if (dev->destructor)
 			dev->destructor(dev);
+
+		/* Free network device */
+		kobject_put(&dev->dev.kobj);
 	}
 
 out:
@@ -3411,6 +3410,9 @@ void unregister_netdevice(struct net_dev
 	/* Notifier chain MUST detach us from master device. */
 	BUG_TRAP(!dev->master);
 
+	/* Remove entries from sysfs */
+	netdev_unregister_sysfs(dev);
+
 	/* Finish processing unregister after unlock */
 	net_set_todo(dev);
 
--- 2.6.21-rc1.orig/net/core/net-sysfs.c	2007-05-11 11:02:55.000000000 -0700
+++ 2.6.21-rc1/net/core/net-sysfs.c	2007-05-14 08:44:52.000000000 -0700
@@ -456,9 +456,15 @@ static struct class net_class = {
 #endif
 };
 
+/* Delete sysfs entries but hold kobject reference until after all
+ * netdev references are gone.
+ */
 void netdev_unregister_sysfs(struct net_device * net)
 {
-	device_del(&(net->dev));
+	struct device *dev = &(net->dev);
+
+	kobject_get(&dev->kobj);
+	device_del(dev);
 }
 
 /* Create sysfs entries for network device. */
