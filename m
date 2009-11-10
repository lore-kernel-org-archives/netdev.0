From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 03/10] net: use rcu for network scheduler API
Date: Tue, 10 Nov 2009 09:54:49 -0800
Message-ID: <20091110175647.339425269@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58714 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755546AbZKJSHT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:07:19 -0500
Content-Disposition: inline; filename=sched-rcu.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use RCU to walk list of network devices in qdisc dump.
This could be optimized for large number of devices.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/sched/sch_api.c	2009-11-09 22:19:09.002480816 -0800
+++ b/net/sched/sch_api.c	2009-11-10 09:28:38.166439067 -0800
@@ -1279,9 +1279,10 @@ static int tc_dump_qdisc(struct sk_buff 
 
 	s_idx = cb->args[0];
 	s_q_idx = q_idx = cb->args[1];
-	read_lock(&dev_base_lock);
+
+	rcu_read_lock();
 	idx = 0;
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev_rcu(&init_net, dev) {
 		struct netdev_queue *dev_queue;
 
 		if (idx < s_idx)
@@ -1302,7 +1303,7 @@ cont:
 	}
 
 done:
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 
 	cb->args[0] = idx;
 	cb->args[1] = q_idx;

-- 

