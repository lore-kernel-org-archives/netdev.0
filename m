From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH net-next] bonding: add option to specify the number of queues per bond device
Date: Tue,  5 Nov 2013 16:41:32 +0100
Message-ID: <1383666093-4115-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, vfalico@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42961 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750775Ab3KEPo5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 10:44:57 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before this patch the only way to specify the number of queues of a bond
device was to use the tx_queues module parameter on module load. Since
we can have different setups with different requirements, it's
beneficial to be able to specify the number of queues per bond device
creation. This patch adds this ability and uses tx_queues as a default
and as a fallback in case of an invalid "queues" value.
The queues are specified when creating a new bond device through sysfs
by using the ":" as a delimiter between the name and the value, e.g.:
echo +bond1:8 > bonding_masters
will create bond1 device with 8 queues. The value 0 is reserved for
using the default number of queues (global tx_queues set on module
loading).
Add an example in the documentation, and also trim a few extra spaces
and tabs while at it.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 Documentation/networking/bonding.txt | 17 ++++++++++-------
 drivers/net/bonding/bond_main.c      |  8 ++++----
 drivers/net/bonding/bond_sysfs.c     | 17 ++++++++++++++---
 drivers/net/bonding/bonding.h        |  2 +-
 4 files changed, 29 insertions(+), 15 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 3856ed2..b51e852 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -23,7 +23,7 @@ multiple network interfaces into a single logical "bonded" interface.
 The behavior of the bonded interfaces depends upon the mode; generally
 speaking, modes provide either hot standby or load balancing services.
 Additionally, link integrity monitoring may be performed.
-	
+
 	The bonding driver originally came from Donald Becker's
 beowulf patches for kernel 2.0. It has changed quite a bit since, and
 the original tools from extreme-linux and beowulf sites will not work
@@ -1299,6 +1299,9 @@ Creating and Destroying Bonds
 To add a new bond foo:
 # echo +foo > /sys/class/net/bonding_masters
 
+To add a new bond foo with 10 queues instead of the default tx_queues:
+# echo +foo:10 > /sys/class/net/bonding_masters
+
 To remove an existing bond bar:
 # echo -bar > /sys/class/net/bonding_masters
 
@@ -1533,7 +1536,7 @@ that normal output policy selection should take place.  One benefit to simply
 leaving the qid for a slave to 0 is the multiqueue awareness in the bonding
 driver that is now present.  This awareness allows tc filters to be placed on
 slave devices as well as bond devices and the bonding driver will simply act as
-a pass-through for selecting output queues on the slave device rather than 
+a pass-through for selecting output queues on the slave device rather than
 output port selection.
 
 This feature first appeared in bonding driver version 3.7.0 and support for
@@ -2216,7 +2219,7 @@ broadcast: Like active-backup, there is not much advantage to this
 	the same speed and duplex.  Also, as with all bonding load
 	balance modes other than balance-rr, no single connection will
 	be able to utilize more than a single interface's worth of
-	bandwidth.  
+	bandwidth.
 
 	Additionally, the linux bonding 802.3ad implementation
 	distributes traffic by peer (using an XOR of MAC addresses),
@@ -2275,7 +2278,7 @@ when they are configured in parallel as part of an isolated network
 between two or more systems, for example:
 
                        +-----------+
-                       |  Host A   | 
+                       |  Host A   |
                        +-+---+---+-+
                          |   |   |
                 +--------+   |   +---------+
@@ -2287,7 +2290,7 @@ between two or more systems, for example:
                 +--------+   |   +---------+
                          |   |   |
                        +-+---+---+-+
-                       |  Host B   | 
+                       |  Host B   |
                        +-----------+
 
 	In this configuration, the switches are isolated from one
@@ -2515,7 +2518,7 @@ bonding driver.
 (either the internal Ethernet Switch Module, or an external switch) to
 avoid fail-over delay issues when using bonding.
 
-	
+
 15. Frequently Asked Questions
 ==============================
 
@@ -2552,7 +2555,7 @@ monitored, and should it recover, it will rejoin the bond (in whatever
 manner is appropriate for the mode). See the sections on High
 Availability and the documentation for each mode for additional
 information.
-	
+
 	Link monitoring can be enabled via either the miimon or
 arp_interval parameters (described in the module parameters section,
 above).  In general, miimon monitors the carrier state as sensed by
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index a141f40..2ad43f0 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4367,9 +4367,9 @@ unsigned int bond_get_num_tx_queues(void)
 /* Create a new bond based on the specified name and bonding parameters.
  * If name is NULL, obtain a suitable "bond%d" name for us.
  * Caller must NOT hold rtnl_lock; we need to release it here before we
- * set up our sysfs entries.
+ * set up our sysfs entries. If queues is 0 then use the global tx_queues.
  */
-int bond_create(struct net *net, const char *name)
+int bond_create(struct net *net, const char *name, int queues)
 {
 	struct net_device *bond_dev;
 	int res;
@@ -4378,7 +4378,7 @@ int bond_create(struct net *net, const char *name)
 
 	bond_dev = alloc_netdev_mq(sizeof(struct bonding),
 				   name ? name : "bond%d",
-				   bond_setup, tx_queues);
+				   bond_setup, queues ? queues : tx_queues);
 	if (!bond_dev) {
 		pr_err("%s: eek! can't alloc netdev!\n", name);
 		rtnl_unlock();
@@ -4457,7 +4457,7 @@ static int __init bonding_init(void)
 	bond_create_debugfs();
 
 	for (i = 0; i < max_bonds; i++) {
-		res = bond_create(&init_net, NULL);
+		res = bond_create(&init_net, NULL, tx_queues);
 		if (res)
 			goto err;
 	}
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 47749c9..22c86d3 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -104,9 +104,15 @@ static ssize_t bonding_store_bonds(struct class *cls,
 	struct bond_net *bn =
 		container_of(attr, struct bond_net, class_attr_bonding_masters);
 	char command[IFNAMSIZ + 1] = {0, };
-	char *ifname;
-	int rv, res = count;
+	int rv, res = count, queues = 0;
+	char *ifname, *delim;
 
+	delim = strchr(buffer, ':');
+	if (delim) {
+		*delim = '\0';
+		if (sscanf(++delim, "%d", &queues) != 1)
+			queues = 0;
+	}
 	sscanf(buffer, "%16s", command); /* IFNAMSIZ*/
 	ifname = command + 1;
 	if ((strlen(command) <= 1) ||
@@ -114,8 +120,13 @@ static ssize_t bonding_store_bonds(struct class *cls,
 		goto err_no_cmd;
 
 	if (command[0] == '+') {
+		if (queues < 0 || queues > 255) {
+			pr_warn("%s: Invalid number of queues (%d) specified, resetting to default.\n",
+				ifname, queues);
+			queues = 0;
+		}
 		pr_info("%s is being created...\n", ifname);
-		rv = bond_create(bn->net, ifname);
+		rv = bond_create(bn->net, ifname, queues);
 		if (rv) {
 			if (rv == -EEXIST)
 				pr_info("%s already exists.\n", ifname);
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 046a605..31ae6da 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -403,7 +403,7 @@ struct bond_net;
 int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond, struct slave *slave);
 int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb, struct net_device *slave_dev);
 void bond_xmit_slave_id(struct bonding *bond, struct sk_buff *skb, int slave_id);
-int bond_create(struct net *net, const char *name);
+int bond_create(struct net *net, const char *name, int queues);
 int bond_create_sysfs(struct bond_net *net);
 void bond_destroy_sysfs(struct bond_net *net);
 void bond_prepare_sysfs_group(struct bonding *bond);
-- 
1.8.1.4
