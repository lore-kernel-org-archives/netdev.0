From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 01/10] net: don't decrement kobj reference count on init failure
Date: Fri, 18 Aug 2017 13:46:19 -0700
Message-ID: <20170818204628.17147-2-sthemmin@microsoft.com>
References: <20170818204628.17147-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f44.google.com ([74.125.83.44]:34798 "EHLO
        mail-pg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751126AbdHRUqh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 16:46:37 -0400
Received: by mail-pg0-f44.google.com with SMTP id n4so7419501pgn.1
        for <netdev@vger.kernel.org>; Fri, 18 Aug 2017 13:46:37 -0700 (PDT)
In-Reply-To: <20170818204628.17147-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If kobject_init_and_add failed, then the failure path would
decrement the reference count of the queue kobject whose reference
count was already zero.

Fixes: 114cf5802165 ("bql: Byte queue limits")
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 net/core/net-sysfs.c | 22 ++++++++++------------
 1 file changed, 10 insertions(+), 12 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index b4f9922b6f23..46ff41bf0210 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -917,21 +917,20 @@ static int rx_queue_add_kobject(struct net_device *dev, int index)
 	error = kobject_init_and_add(kobj, &rx_queue_ktype, NULL,
 	    "rx-%u", index);
 	if (error)
-		goto exit;
+		return error;
 
 	if (dev->sysfs_rx_queue_group) {
 		error = sysfs_create_group(kobj, dev->sysfs_rx_queue_group);
-		if (error)
-			goto exit;
+		if (error) {
+			kobject_put(kobj);
+			return error;
+		}
 	}
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
 	return error;
-exit:
-	kobject_put(kobj);
-	return error;
 }
 #endif /* CONFIG_SYSFS */
 
@@ -1339,21 +1338,20 @@ static int netdev_queue_add_kobject(struct net_device *dev, int index)
 	error = kobject_init_and_add(kobj, &netdev_queue_ktype, NULL,
 	    "tx-%u", index);
 	if (error)
-		goto exit;
+		return error;
 
 #ifdef CONFIG_BQL
 	error = sysfs_create_group(kobj, &dql_group);
-	if (error)
-		goto exit;
+	if (error) {
+		kobject_put(kobj);
+		return error;
+	}
 #endif
 
 	kobject_uevent(kobj, KOBJ_ADD);
 	dev_hold(queue->dev);
 
 	return 0;
-exit:
-	kobject_put(kobj);
-	return error;
 }
 #endif /* CONFIG_SYSFS */
 
-- 
2.11.0
