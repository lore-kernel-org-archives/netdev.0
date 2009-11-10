From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 05/10] parisc: use RCU to find network device
Date: Tue, 10 Nov 2009 09:54:51 -0800
Message-ID: <20091110175647.480041042@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org, linux-parisc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Kyle McMartin <kyle@mcmartin.ca>, Helge Deller <deller@gmx.de>,
	Alexander Beregalov <a.beregalov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:49510 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755568AbZKJSNy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:13:54 -0500
Content-Disposition: inline; filename=parisc-rdlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Another place where RCU can be used instead of read_lock(&dev_base_lock)
This is by inspection, don't have platform or cross-build environment
to validate.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/parisc/led.c	2009-11-09 22:19:07.223480872 -0800
+++ b/drivers/parisc/led.c	2009-11-10 09:28:38.279438787 -0800
@@ -354,9 +354,8 @@ static __inline__ int led_get_net_activi
 	
 	/* we are running as a workqueue task, so locking dev_base 
 	 * for reading should be OK */
-	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev_rcu(&init_net, dev) {
 	    const struct net_device_stats *stats;
 	    struct in_device *in_dev = __in_dev_get_rcu(dev);
 	    if (!in_dev || !in_dev->ifa_list)
@@ -368,7 +367,6 @@ static __inline__ int led_get_net_activi
 	    tx_total += stats->tx_packets;
 	}
 	rcu_read_unlock();
-	read_unlock(&dev_base_lock);
 
 	retval = 0;
 

-- 

