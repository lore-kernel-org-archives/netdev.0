From: Bruce Allan <bruce.w.allan@intel.com>
Subject: [net-next-2.6 RFC PATCH] ethtool: allow custom interval for physical
	identification
Date: Mon, 11 Apr 2011 16:16:35 -0700
Message-ID: <20110411231635.9339.36369.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:62228 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753012Ab1DKXQh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 19:16:37 -0400
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id p3BNGZfS009368
	for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 16:16:35 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When physical identification of an adapter is done by toggling the
mechanism on and off through software utilizing the .set_phys_id operation,
it is done with a fixed duration for both on and off states.  Some drivers
may want to set a custom duration for the on/off intervals.  This patch
changes the API so the return code from the driver's entry point can
specify the interval duration as a positive number; -EINVAL is still
allowed in order to use the default single on/off interval per second.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
---

 net/core/ethtool.c |   11 +++++++----
 1 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 43ef09f..02db945 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1640,7 +1640,7 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 		return dev->ethtool_ops->phys_id(dev, id.data);
 
 	rc = dev->ethtool_ops->set_phys_id(dev, ETHTOOL_ID_ACTIVE);
-	if (rc && rc != -EINVAL)
+	if (rc < 0 && rc != -EINVAL)
 		return rc;
 
 	/* Drop the RTNL lock while waiting, but prevent reentry or
@@ -1656,22 +1656,25 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
 			id.data ? (id.data * HZ) : MAX_SCHEDULE_TIMEOUT);
 	} else {
 		/* Driver expects to be called periodically */
+		int i = 0, interval = ((rc > 0) ? rc : (HZ / 2));
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

