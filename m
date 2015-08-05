From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] net: Fix race condition in store_rps_map
Date: Wed, 5 Aug 2015 09:39:27 -0700
Message-ID: <1438792767-76704-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:25510 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752202AbbHEQjc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Aug 2015 12:39:32 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t75Gauev021340
	for <netdev@vger.kernel.org>; Wed, 5 Aug 2015 09:39:32 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1w3ns182vm-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 05 Aug 2015 09:39:32 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.103.99.97) with ESMTP	id
 8bbef1b63b9011e5b7210002c9931860-dfc8d6b0 for <netdev@vger.kernel.org>;	Wed,
 05 Aug 2015 09:39:31 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a race condition in store_rps_map that allows jump label
count in rps_needed to go below zero. This can happen when
concurrently attempting to set and a clear map.

Scenario:

1. rps_needed count is zero
2. New map is assigned by setting thread, but rps_needed count _not_ yet
   incremented (rps_needed count still zero)
2. Map is cleared by second thread, old_map set to that just assigned
3. Second thread performs static_key_slow_dec, rps_needed count now goes
   negative

Fix is to increment or decrement rps_needed under the spinlock.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/net-sysfs.c | 11 +++++++----
 1 file changed, 7 insertions(+), 4 deletions(-)

diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 194c1d0..39ec694 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -726,14 +726,17 @@ static ssize_t store_rps_map(struct netdev_rx_queue *queue,
 	old_map = rcu_dereference_protected(queue->rps_map,
 					    lockdep_is_held(&rps_map_lock));
 	rcu_assign_pointer(queue->rps_map, map);
-	spin_unlock(&rps_map_lock);
 
 	if (map)
 		static_key_slow_inc(&rps_needed);
-	if (old_map) {
-		kfree_rcu(old_map, rcu);
+	if (old_map)
 		static_key_slow_dec(&rps_needed);
-	}
+
+	spin_unlock(&rps_map_lock);
+
+	if (old_map)
+		kfree_rcu(old_map, rcu);
+
 	free_cpumask_var(mask);
 	return len;
 }
-- 
1.8.5.6
