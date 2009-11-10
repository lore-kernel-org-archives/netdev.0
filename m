From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/10] vlan: eliminate use of dev_base_lock
Date: Tue, 10 Nov 2009 09:54:48 -0800
Message-ID: <20091110175647.268344307@vyatta.com>
References: <20091110175446.280423729@vyatta.com>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58711 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753775AbZKJSHS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 13:07:18 -0500
Content-Disposition: inline; filename=vlan-rdlock.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Do not need to use read_lock(&dev_base_lock), use RCU instead.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/net/8021q/vlanproc.c	2009-11-09 22:19:08.712481032 -0800
+++ b/net/8021q/vlanproc.c	2009-11-10 09:27:28.165378176 -0800
@@ -201,18 +201,17 @@ int vlan_proc_rem_dev(struct net_device 
 
 /* start read of /proc/net/vlan/config */
 static void *vlan_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(rcu)
 {
 	struct net_device *dev;
 	struct net *net = seq_file_net(seq);
 	loff_t i = 1;
 
-	read_lock(&dev_base_lock);
-
+	rcu_read_lock();
 	if (*pos == 0)
 		return SEQ_START_TOKEN;
 
-	for_each_netdev(net, dev) {
+	for_each_netdev_rcu(net, dev) {
 		if (!is_vlan_dev(dev))
 			continue;
 
@@ -234,7 +233,7 @@ static void *vlan_seq_next(struct seq_fi
 	if (v == SEQ_START_TOKEN)
 		dev = net_device_entry(&net->dev_base_head);
 
-	for_each_netdev_continue(net, dev) {
+	for_each_netdev_continue_rcu(net, dev) {
 		if (!is_vlan_dev(dev))
 			continue;
 
@@ -245,9 +244,9 @@ static void *vlan_seq_next(struct seq_fi
 }
 
 static void vlan_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(rcu)
 {
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int vlan_seq_show(struct seq_file *seq, void *v)

-- 

