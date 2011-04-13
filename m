From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH v2 01/13] ethtool: allow custom interval for
	physical identification
Date: Wed, 13 Apr 2011 12:58:51 -0700
Message-ID: <20110413195851.25901.8139.stgit@gitlad.jf.intel.com>
References: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Allan <bruce.w.allan@intel.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:42229 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758485Ab1DMT6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Apr 2011 15:58:52 -0400
In-Reply-To: <20110413195146.25901.72193.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When physical identification of an adapter is done by toggling the
mechanism on and off through software utilizing the set_phys_id operation,
it is done with a fixed duration for both on and off states.  Some drivers
may want to set a custom duration for the on/off intervals.  This patch
changes the API so the return code from the driver's entry point when it
is called with ETHTOOL_ID_ACTIVE can specify the frequency at which to
cycle the on/off states.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
---

 include/linux/ethtool.h |    6 ++++--
 net/core/ethtool.c      |   13 ++++++++-----
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 12cfbd0..6191a84 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -770,8 +770,10 @@ bool ethtool_invalid_flags(struct net_device *dev, u32 data, u32 supported);
  *	attached to it.  The implementation may update the indicator
  *	asynchronously or synchronously, but in either case it must return
  *	quickly.  It is initially called with the argument %ETHTOOL_ID_ACTIVE,
- *	and must either activate asynchronous updates or return -%EINVAL.
- *	If it returns -%EINVAL then it will be called again at intervals with
+ *	and must either activate asynchronous updates and return zero, return
+ *	a negative error or return a positive frequency for synchronous
+ *	indication (e.g. 1 for one on/off cycle per second).  If it returns
+ *	a frequency then it will be called again at intervals with the
  *	argument %ETHTOOL_ID_ON or %ETHTOOL_ID_OFF and should set the state of
  *	the indicator accordingly.  Finally, it is called with the argument
  *	%ETHTOOL_ID_INACTIVE and must deactivate the indicator.  Returns a
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 43ef09f..2dd7bde 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1640,7 +1640,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 		return dev->ethtool_ops->phys_id(dev, id.data);
 
 	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
-	if (rc && rc != -EINVAL)
+	if (rc < 0)
 		return rc;
 
 	/* Drop the RTNL lock while waiting, but prevent reentry or
@@ -1655,23 +1655,26 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 		schedule_timeout_interruptible(
 			id.data ? (id.data * HZ) : MAX_SCHEDULE_TIMEOUT);
 	} else {
-		/* Driver expects to be called periodically */
+		/* Driver expects to be called using the frequency in rc */
+		int i = 0, interval = (HZ / (rc * 2));
+
 		do {
 			rtnl_lock();
 			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ON);
 			rtnl_unlock();
 			if (rc)
 				break;
-			schedule_timeout_interruptible(HZ / 2);
+			schedule_timeout_interruptible(interval);
 
 			rtnl_lock();
 			rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_OFF);
 			rtnl_unlock();
 			if (rc)
 				break;
-			schedule_timeout_interruptible(HZ / 2);
+			schedule_timeout_interruptible(interval);
 		} while (!signal_pending(current) &&
-			 (id.data == 0 || --id.data != 0));
+			 (id.data == 0 ||
+			  (++i * 2 * interval) < (id.data * HZ)));
 	}
 
 	rtnl_lock();

