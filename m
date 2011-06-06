From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sch_generic unused variable warning
Date: Mon, 06 Jun 2011 14:58:18 -0700 (PDT)
Message-ID: <20110606.145818.802224963792889208.davem@davemloft.net>
References: <1307143106-14523-1-git-send-email-cmdkhh@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: cmdkhh@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1307143106-14523-1-git-send-email-cmdkhh@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Connor Hansen <cmdkhh@gmail.com>
Date: Fri,  3 Jun 2011 16:18:26 -0700

> during randconfig testing net/sched/sch_generic produced
> net/sched/sch_generic.c: In function dev_watchdog
> net/sched/sch_generic.c:254:10: warning: unused variable drivername
> 
> drivername is only used in the scope of the WARN_ONCE
> 
> Signed-off-by: Connor Hansen <cmdkhh@gmail.com>

I think this warning is telling us to fix the netdev_drivername()
helper instead.

I'll commit the following:

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index ca333e7..54b8b4d 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2555,7 +2555,7 @@ extern void netdev_class_remove_file(struct class_attribute *class_attr);
 
 extern struct kobj_ns_type_operations net_ns_type_operations;
 
-extern char *netdev_drivername(const struct net_device *dev, char *buffer, int len);
+extern const char *netdev_drivername(const struct net_device *dev);
 
 extern void linkwatch_run_queue(void);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index 9393078..1af6cb2 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6264,29 +6264,23 @@ err_name:
 /**
  *	netdev_drivername - network driver for the device
  *	@dev: network device
- *	@buffer: buffer for resulting name
- *	@len: size of buffer
  *
  *	Determine network driver for device.
  */
-char *netdev_drivername(const struct net_device *dev, char *buffer, int len)
+const char *netdev_drivername(const struct net_device *dev)
 {
 	const struct device_driver *driver;
 	const struct device *parent;
-
-	if (len <= 0 || !buffer)
-		return buffer;
-	buffer[0] = 0;
+	const char *empty = "";
 
 	parent = dev->dev.parent;
-
 	if (!parent)
-		return buffer;
+		return empty;
 
 	driver = parent->driver;
 	if (driver && driver->name)
-		strlcpy(buffer, driver->name, len);
-	return buffer;
+		return driver->name;
+	return empty;
 }
 
 static int __netdev_printk(const char *level, const struct net_device *dev,
diff --git a/net/sched/sch_generic.c b/net/sched/sch_generic.c
index b1721d7..b4c6809 100644
--- a/net/sched/sch_generic.c
+++ b/net/sched/sch_generic.c
@@ -251,9 +251,8 @@ static void dev_watchdog(unsigned long arg)
 			}
 
 			if (some_queue_timedout) {
-				char drivername[64];
 				WARN_ONCE(1, KERN_INFO "NETDEV WATCHDOG: %s (%s): transmit queue %u timed out\n",
-				       dev->name, netdev_drivername(dev, drivername, 64), i);
+				       dev->name, netdev_drivername(dev), i);
 				dev->netdev_ops->ndo_tx_timeout(dev);
 			}
 			if (!mod_timer(&dev->watchdog_timer,
