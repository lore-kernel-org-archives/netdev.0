From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 2/2] bonding: add the debugfs interface to see RLB hash table
Date: Thu, 02 Dec 2010 19:50:35 -0800
Message-ID: <14624.1291348235@death>
References: <4CF85B43.2030407@jp.fujitsu.com> <4CF85C14.5010909@jp.fujitsu.com>
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	eric.dumazet@gmail.com, shemminger@vyatta.com
To: Taku Izumi <izumi.taku@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:53406 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932199Ab0LCDuj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Dec 2010 22:50:39 -0500
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e1.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id oB33gZ9E009651
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 22:42:35 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 8268A4DE803B
	for <netdev@vger.kernel.org>; Thu,  2 Dec 2010 22:48:56 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB33obcK174682
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 22:50:37 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB33oaum006699
	for <netdev@vger.kernel.org>; Thu, 2 Dec 2010 20:50:37 -0700
In-reply-to: <4CF85C14.5010909@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Taku Izumi <izumi.taku@jp.fujitsu.com> wrote:

>
>This patch provices the debugfs interface to see RLB hash table
>like the following:
>
># cat /sys/kernel/debug/bonding/bond0/rlb_hash_table
>SourceIP        DestinationIP   Destination MAC   DEV
>10.124.196.205  10.124.196.205  ff:ff:ff:ff:ff:ff eth4
>10.124.196.205  10.124.196.81   00:19:99:XX:XX:XX eth3
>10.124.196.205  10.124.196.1    00:21:d8:XX:XX:XX eth0
>
>This is helpful to check if the receive load balancing works as expected.
>
>Signed-off-by: Taku Izumi <izumi.taku@jp.fujitsu.com>
>
>---
> drivers/net/bonding/bond_debugfs.c |   51 +++++++++++++++++++++++++++++++++++++
> 1 file changed, 51 insertions(+)
>
>Index: net-next/drivers/net/bonding/bond_debugfs.c
>===================================================================
>--- net-next.orig/drivers/net/bonding/bond_debugfs.c
>+++ net-next/drivers/net/bonding/bond_debugfs.c
>@@ -4,6 +4,7 @@
> #include <linux/netdevice.h>
>
> #include "bonding.h"
>+#include "bond_alb.h"
>
> #ifdef CONFIG_DEBUG_FS
>
>@@ -12,6 +13,53 @@
>
> static struct dentry *bonding_debug_root;
>
>+/*
>+ *  Show RLB hash table
>+ */
>+#define RLB_NULL_INDEX  0xffffffff

	Instead of copying this constant from bond_alb.c, move it into
bond_alb.h.

>+static int bond_debug_rlb_hash_show(struct seq_file *m, void *v)
>+{
>+	struct bonding *bond = m->private;
>+	struct alb_bond_info *bond_info = &(BOND_ALB_INFO(bond));
>+	struct rlb_client_info *client_info;
>+	u32 hash_index;
>+
>+	if (bond->params.mode != BOND_MODE_ALB)
>+		return 0;
>+
>+	seq_printf(m, "SourceIP        DestinationIP   "
>+			"Destination MAC   DEV\n");
>+
>+	spin_lock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>+
>+	hash_index = bond_info->rx_hashtbl_head;
>+	for (; hash_index != RLB_NULL_INDEX; hash_index = client_info->next) {
>+		client_info = &(bond_info->rx_hashtbl[hash_index]);
>+		seq_printf(m, "%-15pI4 %-15pI4 %-17pM %s\n",
>+			&client_info->ip_src,
>+			&client_info->ip_dst,
>+			&client_info->mac_dst,
>+			client_info->slave->dev->name);
>+	}

	I think this is going to run up against the PAGE_SIZE limit for
writing to the seq_file if the rlb table is sufficiently populated (for
systems with a 4K PAGE_SIZE).  It looks like seq_printf won't do
anything bad (other than not print any more) when it runs out of space,
and the above won't use up 4K until there are around 65 or 70 entries in
the table, so this may not be worth worrying about now.

	-J

>+
>+	spin_unlock_bh(&(BOND_ALB_INFO(bond).rx_hashtbl_lock));
>+
>+	return 0;
>+}
>+
>+static int bond_debug_rlb_hash_open(struct inode *inode, struct file *file)
>+{
>+	return single_open(file, bond_debug_rlb_hash_show, inode->i_private);
>+}
>+
>+static const struct file_operations bond_debug_rlb_hash_fops = {
>+	.owner		= THIS_MODULE,
>+	.open		= bond_debug_rlb_hash_open,
>+	.read		= seq_read,
>+	.llseek		= seq_lseek,
>+	.release	= single_release,
>+};
>+
> void bond_debug_register(struct bonding *bond)
> {
> 	if (!bonding_debug_root)
>@@ -25,6 +73,9 @@ void bond_debug_register(struct bonding
> 			bond->dev->name);
> 		return;
> 	}
>+
>+	debugfs_create_file("rlb_hash_table", 0400, bond->debug_dir,
>+				bond, &bond_debug_rlb_hash_fops);
> }
>
> void bond_debug_unregister(struct bonding *bond)
>
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
