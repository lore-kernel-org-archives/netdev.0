From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 06/10] s390: use RCU to walk list of network devices
Date: Tue, 10 Nov 2009 09:54:52 -0800
Message-ID: <20091110175647.547660685@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org, linux390@de.ibm.com
To: David Miller <davem@davemloft.net>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58732 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260AbZKJSIA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:08:00 -0500
Content-Disposition: inline; filename=s390-readlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is similar to other cases where for_each_netdev_rcu
can be used when gathering information.

By inspection, don't have platform or cross-build environment
to validate.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/arch/s390/appldata/appldata_net_sum.c	2009-11-09 22:19:05.593480476 -0800
+++ b/arch/s390/appldata/appldata_net_sum.c	2009-11-10 09:28:38.335438652 -0800
@@ -83,8 +83,9 @@ static void appldata_get_net_sum_data(vo
 	rx_dropped = 0;
 	tx_dropped = 0;
 	collisions = 0;
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		const struct net_device_stats *stats = dev_get_stats(dev);
 
 		rx_packets += stats->rx_packets;
@@ -98,7 +99,8 @@ static void appldata_get_net_sum_data(vo
 		collisions += stats->collisions;
 		i++;
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
+
 	net_data->nr_interfaces = i;
 	net_data->rx_packets = rx_packets;
 	net_data->tx_packets = tx_packets;

-- 

