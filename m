From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCHv2 net-next-2.6 6/7] ethtool: Change ETHTOOL_PHYS_ID
 implementation to allow dropping RTNL
Date: Tue, 05 Apr 2011 19:05:56 +0100
Message-ID: <1302026756.2932.63.camel@bwh-desktop>
References: <1302026446.2932.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Stephen Hemminger <shemminger@vyatta.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:15699 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab1DESF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 14:05:59 -0400
In-Reply-To: <1302026446.2932.56.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The ethtool ETHTOOL_PHYS_ID command runs for an arbitrarily long
period of time, holding the RTNL lock.  This blocks routing updates,
device enumeration, and various important operations that one might
want to keep running while hunting for the flashing LED.

We need to drop the RTNL lock during this operation, but currently the
core implementation is a thin wrapper around a driver operation and
drivers may well depend upon holding the lock.

Define a new driver operation 'set_phys_id' with an argument that sets
the ID indicator on/off/inactive/active (the last optional, for any
driver or firmware that prefers to handle blinking asynchronously).
When this is defined, the ethtool core drops the lock while waiting
and only acquires it around calls to this operation.

Deprecate the 'phys_id' operation in favour of this.  It can be
removed once all in-tree drivers are converted.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
 include/linux/ethtool.h |   30 ++++++++++++++++++++++++-
 net/core/ethtool.c      |   55 +++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 82 insertions(+), 3 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index ead7dcb..c04d131 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -663,6 +663,22 @@ struct ethtool_rx_ntuple_list {
 	unsigned int		count;
 };
 
+/**
+ * enum ethtool_phys_id_state - indicator state for physical identification
+ * @ETHTOOL_ID_INACTIVE: Physical ID indicator should be deactivated
+ * @ETHTOOL_ID_ACTIVE: Physical ID indicator should be activated
+ * @ETHTOOL_ID_ON: LED should be turned on (used iff %ETHTOOL_ID_ACTIVE
+ *	is not supported)
+ * @ETHTOOL_ID_OFF: LED should be turned off (used iff %ETHTOOL_ID_ACTIVE
+ *	is not supported)
+ */
+enum ethtool_phys_id_state {
+	ETHTOOL_ID_INACTIVE,
+	ETHTOOL_ID_ACTIVE,
+	ETHTOOL_ID_ON,
+	ETHTOOL_ID_OFF
+};
+
 struct net_device;
 
 /* Some generic methods drivers may use in their ethtool_ops */
@@ -741,7 +757,18 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  *	segmentation offload on or off.  Returns a negative error code or zero.
  * @self_test: Run specified self-tests
  * @get_strings: Return a set of strings that describe the requested objects
- * @phys_id: Identify the physical device, e.g. by flashing an LED
+ * @set_phys_id: Identify the physical devices, e.g. by flashing an LED
+ *	attached to it.  The implementation may update the indicator
+ *	asynchronously or synchronously, but in either case it must return
+ *	quickly.  It is initially called with the argument %ETHTOOL_ID_ACTIVE,
+ *	and must either activate asynchronous updates or return -%EINVAL.
+ *	If it returns -%EINVAL then it will be called again at intervals with
+ *	argument %ETHTOOL_ID_ON or %ETHTOOL_ID_OFF and should set the state of
+ *	the indicator accordingly.  Finally, it is called with the argument
+ *	%ETHTOOL_ID_INACTIVE and must deactivate the indicator.  Returns a
+ *	negative error code or zero.
+ * @phys_id: Deprecated in favour of @set_phys_id.
+ *	Identify the physical device, e.g. by flashing an LED
  *	attached to it until interrupted by a signal or the given time
  *	(in seconds) elapses.  If the given time is zero, use a default
  *	time limit.  Returns a negative error code or zero.  Being
@@ -830,6 +857,7 @@ struct ethtool_ops {
 	int	(*set_tso)(struct net_device *, u32);
 	void	(*self_test)(struct net_device *, struct ethtool_test *, u64 *);
 	void	(*get_strings)(struct net_device *, u32 stringset, u8 *);
+	int	(*set_phys_id)(struct net_device *, enum ethtool_phys_id_state);
 	int	(*phys_id)(struct net_device *, u32);
 	void	(*get_ethtool_stats)(struct net_device *,
 				     struct ethtool_stats *, u64 *);
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 74ead9e..1c95f0f 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -21,6 +21,8 @@
 #include <linux/uaccess.h>
 #include <linux/vmalloc.h>
 #include <linux/slab.h>
+#include <linux/rtnetlink.h>
+#include <linux/sched.h>
 
 /*
  * Some useful ethtool_ops methods that're device independent.
@@ -1618,14 +1620,63 @@ out:
 static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 {
 	struct ethtool_value id;
+	static bool busy;
+	int rc;
 
-	if (!dev->ethtool_ops->phys_id)
+	if (!dev->ethtool_ops->set_phys_id && !dev->ethtool_ops->phys_id)
 		return -EOPNOTSUPP;
 
+	if (busy)
+		return -EBUSY;
+
 	if (copy_from_user(&id, useraddr, sizeof(id)))
 		return -EFAULT;
 
-	return dev->ethtool_ops->phys_id(dev, id.data);
+	if (!dev->ethtool_ops->set_phys_id)
+		/* Do it the old way */
+		return dev->ethtool_ops->phys_id(dev, id.data);
+
+	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
+	if (rc && rc != -EINVAL)
+		return rc;
+
+	/* Drop the RTNL lock while waiting, but prevent reentry or
+	 * removal of the device.
+	 */
+	busy = true;
+	dev_hold(dev);
+	rtnl_unlock();
+
+	if (rc == 0) {
+		/* Driver will handle this itself */
+		schedule_timeout_interruptible(
+			id.data ? id.data : MAX_SCHEDULE_TIMEOUT);
+	} else {
+		/* Driver expects to be called periodically */
+		do {
+			rtnl_lock();
+			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ON);
+			rtnl_unlock();
+			if (rc)
+				break;
+			schedule_timeout_interruptible(HZ / 2);
+
+			rtnl_lock();
+			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_OFF);
+			rtnl_unlock();
+			if (rc)
+				break;
+			schedule_timeout_interruptible(HZ / 2);
+		} while (!signal_pending(current) &&
+			 (id.data == 0 || --id.data != 0));
+	}
+
+	rtnl_lock();
+	dev_put(dev);
+	busy = false;
+
+	(void)dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_INACTIVE);
+	return rc;
 }
 
 static int ethtool_get_stats(struct net_device *dev, void __user *useraddr)
-- 
1.7.4



-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

