From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 07/10] decnet: use RCU to find network devices
Date: Tue, 10 Nov 2009 09:54:53 -0800
Message-ID: <20091110175647.615305929@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org, linux-decnet-users@lists.sourceforge.net
To: David Miller <davem@davemloft.net>,
	Christine Caulfield <christine.caulfield@googlemail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Hannes Eder <hannes@hanneseder.net>,
	Alexey Dob
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58742 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756633AbZKJSIM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:08:12 -0500
Content-Disposition: inline; filename=decnet-readlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When showing device statistics use RCU rather than read_lock(&dev_base_lock)
Compile tested only.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/decnet/dn_dev.c	2009-11-10 09:30:55.557376454 -0800
+++ b/net/decnet/dn_dev.c	2009-11-10 09:40:03.847005394 -0800
@@ -856,9 +856,7 @@ int dn_dev_bind_default(__le16 *addr)
 	dev = dn_dev_get_default();
 last_chance:
 	if (dev) {
-		read_lock(&dev_base_lock);
 		rv = dn_dev_get_first(dev, addr);
-		read_unlock(&dev_base_lock);
 		dev_put(dev);
 		if (rv == 0 || dev == init_net.loopback_dev)
 			return rv;
@@ -1323,18 +1321,18 @@ static inline int is_dn_dev(struct net_d
 }
 
 static void *dn_dev_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(&dev_base_lock)
+	__acquires(rcu)
 {
 	int i;
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
 	i = 1;
-	for_each_netdev(&init_net, dev) {
+	for_each_netdev_rcu(&init_net, dev) {
 		if (!is_dn_dev(dev))
 			continue;
 
@@ -1355,7 +1353,7 @@ static void *dn_dev_seq_next(struct seq_
 	if (v == SEQ_START_TOKEN)
 		dev = net_device_entry(&init_net.dev_base_head);
 
-	for_each_netdev_continue(&init_net, dev) {
+	for_each_netdev_continue_rcu(&init_net, dev) {
 		if (!is_dn_dev(dev))
 			continue;
 
@@ -1366,9 +1364,9 @@ static void *dn_dev_seq_next(struct seq_
 }
 
 static void dn_dev_seq_stop(struct seq_file *seq, void *v)
-	__releases(&dev_base_lock)
+	__releases(rcu)
 {
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static char *dn_type2asc(char type)

-- 

