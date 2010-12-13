From: Taku Izumi <izumi.taku@jp.fujitsu.com>
Subject: Re: [PATCH 3/3] bonding: add the debugfs interface to see RLB hash
 table
Date: Mon, 13 Dec 2010 14:04:43 +0900
Message-ID: <4D05A96B.7020902@jp.fujitsu.com>
References: <4CF89A00.8030902@jp.fujitsu.com> <4CF89AC2.6030606@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, shemminger@vyatta.com
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Jay Vosburgh <fubar@us.ibm.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail7.fujitsu.co.jp ([192.51.44.37]:57131 "EHLO
	fgwmail7.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab0LMFE4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Dec 2010 00:04:56 -0500
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oBD54tld018029
	for <netdev@vger.kernel.org> (envelope-from izumi.taku@jp.fujitsu.com);
	Mon, 13 Dec 2010 14:04:55 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 07D5545DE6F
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:04:55 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id AE6C345DE6E
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:04:54 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D1081DB803C
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:04:54 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FC8D1DB8043
	for <netdev@vger.kernel.org>; Mon, 13 Dec 2010 14:04:54 +0900 (JST)
In-Reply-To: <4CF89AC2.6030606@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This patch provices the debugfs interface to see RLB hash table
like the following:

# cat /sys/kernel/debug/bonding/bond0/rlb_hash_table
SourceIP        DestinationIP   Destination MAC   DEV
10.124.196.205  10.124.196.205  ff:ff:ff:ff:ff:ff eth4
10.124.196.205  10.124.196.81   00:19:99:XX:XX:XX eth3
10.124.196.205  10.124.196.1    00:21:d8:XX:XX:XX eth0

This is helpful to check if the receive load balancing works as expected.

Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

---
 drivers/net/bonding/bond_debugfs.c |   50 +++++++++++++++++++++++++++++++++++++
 1 file changed, 50 insertions(+)

Index: net-next/drivers/net/bonding/bond_debugfs.c
===================================================================
--- net-next.orig/drivers/net/bonding/bond_debugfs.c
+++ net-next/drivers/net/bonding/bond_debugfs.c
@@ -4,6 +4,7 @@
 #include <linux/netdevice.h>

 #include "bonding.h"
+#include "bond_alb.h"

 #ifdef CONFIG_DEBUG_FS

@@ -12,6 +13,52 @@

 static struct dentry *bonding_debug_root;

+/*
+ *  Show RLB hash table
+ */
+static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
+{
+	struct bonding *bond = m->private;
+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
+	struct rlb_client_info *client_info;
+	u32 hash_index;
+
+	if (bond->params.mode != BOND_MODE_ALB)
+		return 0;
+
+	seq_printf(m, "SourceIP        DestinationIP   "
+			"Destination MAC   DEV\n");
+
+	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+
+	hash_index = bond_info->rx_hashtbl_head;
+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
+		client_info = &(bond_info->rx_hashtbl[hash_index]);
+		seq_printf(m, "%-15pI4 %-15pI4 %-17pM %s\n",
+			&client_info->ip_src,
+			&client_info->ip_dst,
+			&client_info->mac_dst,
+			client_info->slave->dev->name);
+	}
+
+	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
+
+	return 0;
+}
+
+static int bond_debug_rlb_hash_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, bond_debug_rlb_hash_show, inode->i_private);
+}
+
+static const struct file_operations bond_debug_rlb_hash_fops = {
+	.owner		= THIS_MODULE,
+	.open		= bond_debug_rlb_hash_open,
+	.read		= seq_read,
+	.llseek		= seq_lseek,
+	.release	= single_release,
+};
+
 void bond_debug_register(struct bonding *bond)
 {
 	if (!bonding_debug_root)
@@ -25,6 +72,9 @@ void bond_debug_register(struct bonding
 			bond->dev->name);
 		return;
 	}
+
+	debugfs_create_file("rlb_hash_table", 0400, bond->debug_dir,
+				bond, &bond_debug_rlb_hash_fops);
 }

 void bond_debug_unregister(struct bonding *bond)


