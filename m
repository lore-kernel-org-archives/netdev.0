From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] tap: convert a mutex to a spinlock
Date: Wed,  5 Jul 2017 13:50:00 -0700
Message-ID: <1499287800-10634-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: borntraeger@de.ibm.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Sainath Grandhi <sainath.grandhi@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35066 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752470AbdGEUud (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Jul 2017 16:50:33 -0400
Received: by mail-pg0-f65.google.com with SMTP id d193so67760pgc.2
        for <netdev@vger.kernel.org>; Wed, 05 Jul 2017 13:50:33 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We are not allowed to block on the RCU reader side, so can't
just hold the mutex as before. As a quick fix, convert it to
a spinlock.

Fixes: d9f1f61c0801 ("tap: Extending tap device create/destroy APIs")
Reported-by: Christian Borntraeger <borntraeger@de.ibm.com>
Cc: Sainath Grandhi <sainath.grandhi@intel.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 drivers/net/tap.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 4d4173d..d88ae3c 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -106,7 +106,7 @@ struct major_info {
 	struct rcu_head rcu;
 	dev_t major;
 	struct idr minor_idr;
-	struct mutex minor_lock;
+	spinlock_t minor_lock;
 	const char *device_name;
 	struct list_head next;
 };
@@ -416,15 +416,15 @@ int tap_get_minor(dev_t major, struct tap_dev *tap)
 		goto unlock;
 	}
 
-	mutex_lock(&tap_major->minor_lock);
-	retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_KERNEL);
+	spin_lock(&tap_major->minor_lock);
+	retval = idr_alloc(&tap_major->minor_idr, tap, 1, TAP_NUM_DEVS, GFP_ATOMIC);
 	if (retval >= 0) {
 		tap->minor = retval;
 	} else if (retval == -ENOSPC) {
 		netdev_err(tap->dev, "Too many tap devices\n");
 		retval = -EINVAL;
 	}
-	mutex_unlock(&tap_major->minor_lock);
+	spin_unlock(&tap_major->minor_lock);
 
 unlock:
 	rcu_read_unlock();
@@ -442,12 +442,12 @@ void tap_free_minor(dev_t major, struct tap_dev *tap)
 		goto unlock;
 	}
 
-	mutex_lock(&tap_major->minor_lock);
+	spin_lock(&tap_major->minor_lock);
 	if (tap->minor) {
 		idr_remove(&tap_major->minor_idr, tap->minor);
 		tap->minor = 0;
 	}
-	mutex_unlock(&tap_major->minor_lock);
+	spin_unlock(&tap_major->minor_lock);
 
 unlock:
 	rcu_read_unlock();
@@ -467,13 +467,13 @@ static struct tap_dev *dev_get_by_tap_file(int major, int minor)
 		goto unlock;
 	}
 
-	mutex_lock(&tap_major->minor_lock);
+	spin_lock(&tap_major->minor_lock);
 	tap = idr_find(&tap_major->minor_idr, minor);
 	if (tap) {
 		dev = tap->dev;
 		dev_hold(dev);
 	}
-	mutex_unlock(&tap_major->minor_lock);
+	spin_unlock(&tap_major->minor_lock);
 
 unlock:
 	rcu_read_unlock();
@@ -1227,7 +1227,7 @@ static int tap_list_add(dev_t major, const char *device_name)
 	tap_major->major = MAJOR(major);
 
 	idr_init(&tap_major->minor_idr);
-	mutex_init(&tap_major->minor_lock);
+	spin_lock_init(&tap_major->minor_lock);
 
 	tap_major->device_name = device_name;
 
-- 
2.5.5
