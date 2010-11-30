From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: [PATCH] bonding: add the sysfs interface to see RLB hash table
Date: Tue, 30 Nov 2010 19:01:41 +0900
Message-ID: <4CF4CB85.4010708@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:45835 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755235Ab0K3KCA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 05:02:00 -0500
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAUA1uka006277
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Tue, 30 Nov 2010 19:01:57 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id CB41345DE5B
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 19:01:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id AAE6F45DE59
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 19:01:56 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9F5D4E08002
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 19:01:56 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 5EE3E1DB8038
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 19:01:56 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch provides the sysfs interface to see RLB hash table
like the following:

# cat /sys/class/net/bond0/bonding/rlb_hash_table

SourceIP        DestinationIP   Destination MAC   DEV
 10.124.196.205  10.124.196. 81 00:19:99:XX:XX:XX eth3
 10.124.196.205  10.124.196.222 00:0a:79:XX:XX:XX eth0
 10.124.196.205  10.124.196. 75 00:15:17:XX:XX:XX eth4
 10.124.196.205  10.124.196.  1 00:21:d8:XX:XX:XX eth3
 10.124.196.205  10.124.196.205 ff:ff:ff:ff:ff:ff eth0


This is helpful to check if the receive load balancing works as expected.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>

---
 drivers/net/bonding/bond_sysfs.c |   56 +++++++++++++++++++++++++++++++++++++++
 1 file changed, 56 insertions(+)

Index: net-next/drivers/net/bonding/bond_sysfs.c
===================================================================
--- net-next.orig/drivers/net/bonding/bond_sysfs.c
+++ net-next/drivers/net/bonding/bond_sysfs.c
@@ -43,6 +43,7 @@
 #include <linux/nsproxy.h>

 #include "bonding.h"
+#include "bond_alb.h"

 #define to_dev(obj)	container_of(obj, struct device, kobj)
 #define to_bond(cd)	((struct bonding *)(netdev_priv(to_net_dev(cd))))
@@ -1643,6 +1644,60 @@ out:
 static DEVICE_ATTR(resend_igmp, S_IRUGO | S_IWUSR,
 		   bonding_show_resend_igmp, bonding_store_resend_igmp);

+/*
+ *  Show RLB hash table
+ */
+#define RLB_NULL_INDEX  0xffffffff
+static ssize_t bonding_show_rlb_hashtable(struct device *d,
+					  struct device_attribute *attr,
+					  char *buf)
+{
+	int count = 0;
+	struct bonding *bond = to_bond(d);
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct rlb_client_info *client_info;
+	u32 hash_index;
+
+	if (bond->params.mode != BOND_MODE_ALB)
+		return count;
+
+	count += sprintf(buf + count, "SourceIP        "
+		"DestinationIP   Destination MAC   DEV\n");
+
+	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+
+	hash_index = bond_info->rx_hashtbl_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+		client_info = &(bond_info->rx_hashtbl[hash_index]);
+
+		count += sprintf(buf + count,
+			"%3d.%3d.%3d.%3d %3d.%3d.%3d.%3d "
+			"%02x:%02x:%02x:%02x:%02x:%02x %s\n",
+			client_info->ip_src & 0xff,
+			(client_info->ip_src >> 8) & 0xff,
+			(client_info->ip_src >> 16) & 0xff,
+			(client_info->ip_src >> 24) & 0xff,
+			client_info->ip_dst & 0xff,
+			(client_info->ip_dst >> 8) & 0xff,
+			(client_info->ip_dst >> 16) & 0xff,
+			(client_info->ip_dst >> 24) & 0xff,
+			client_info->mac_dst[0],
+			client_info->mac_dst[1],
+			client_info->mac_dst[2],
+			client_info->mac_dst[3],
+			client_info->mac_dst[4],
+			client_info->mac_dst[5],
+			client_info->slave->dev->name);
+	}
+
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+
+	return count;
+
+}
+static DEVICE_ATTR(rlb_hash_table, S_IRUGO, bonding_show_rlb_hashtable, NULL);
+
+
 static struct attribute *per_bond_attrs[] = {
 	&dev_attr_slaves.attr,
 	&dev_attr_mode.attr,
@@ -1671,6 +1726,7 @@ static struct attribute *per_bond_attrs[
 	&dev_attr_queue_id.attr,
 	&dev_attr_all_slaves_active.attr,
 	&dev_attr_resend_igmp.attr,
+	&dev_attr_rlb_hash_table.attr,
 	NULL,
 };


