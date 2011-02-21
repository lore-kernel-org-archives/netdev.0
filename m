From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next-2.6] bonding: fix user-controlled queuing issues
Date: Mon, 21 Feb 2011 17:53:03 -0500
Message-ID: <1298328783-10073-1-git-send-email-andy@greyhouse.net>
To: netdev@vger.kernel.org, Ben Hutchings <bhutchings@solarflare.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43317 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751693Ab1BUWxW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 17:53:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Users noticed the following messages were filling their logs when using
queue 16 for user-mode bonding:

kernel: bond0 selects TX queue 16, but real number of TX queues is 16

These messages were showing up since the code for setting queues
presumed that queues 1-16 were usable and queue 0 was reserved, but
parts of the code didn't account for this correctly.  This update now
allows 16 queues (numbered 0-15) to be used (in the nominal case) and
queue awareness can be completely and clearly disabled rather than by
simply setting the queue for a device to 0.

Configuration syntax has changed a little, but is similar to the
existing method.  To associate a queue with an output device, you can do
this:

# echo "+eth1:2" > /sys/class/net/bond0/bonding/queue_id

and to clear it this:

# echo "-eth1:2" > /sys/class/net/bond0/bonding/queue_id

The orginal report that prompted this patch changed bond_select_queue to
return a value different than sinply skb->queue_mapping.  This should
now be a proper return value since the interal queues were remapped
internally and queues 0-15 are the usable queues.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Reported-by: Phil Oester <kernel@linuxace.com>

---

My tests all seem to work well, but more testing/feedback is obviously
appreciated.

---
 Documentation/networking/bonding.txt |   20 ++++++----
 drivers/net/bonding/bond_main.c      |   16 ++++---
 drivers/net/bonding/bond_sysfs.c     |   71 +++++++++++++++++++++------------
 drivers/net/bonding/bonding.h        |   20 +++++++++
 4 files changed, 86 insertions(+), 41 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 25d2f41..8a27f0f 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1404,10 +1404,11 @@ By default the bonding driver is multiqueue aware and 16 queues are created
 when the driver initializes (see Documentation/networking/multiqueue.txt
 for details).  If more or less queues are desired the module parameter
 tx_queues can be used to change this value.  There is no sysfs parameter
-available as the allocation is done at module init time.
+available as the allocation is done at module init time.  Currently only one
+queue per device can be set.
 
 The output of the file /proc/net/bonding/bondX has changed so the output Queue
-ID is now printed for each slave:
+ID is now printed for each slave that has a queue configured:
 
 Bonding Mode: fault-tolerance (active-backup)
 Primary Slave: None
@@ -1421,7 +1422,6 @@ Slave Interface: eth0
 MII Status: up
 Link Failure Count: 0
 Permanent HW addr: 00:1a:a0:12:8f:cb
-Slave queue ID: 0
 
 Slave Interface: eth1
 MII Status: up
@@ -1431,12 +1431,16 @@ Slave queue ID: 2
 
 The queue_id for a slave can be set using the command:
 
-# echo "eth1:2" > /sys/class/net/bond0/bonding/queue_id
+# echo "+eth1:2" > /sys/class/net/bond0/bonding/queue_id
 
-Any interface that needs a queue_id set should set it with multiple calls
-like the one above until proper priorities are set for all interfaces.  On
-distributions that allow configuration via initscripts, multiple 'queue_id'
-arguments can be added to BONDING_OPTS to set all needed slave queues.
+and removed using the command:
+
+# echo "-eth1:2" > /sys/class/net/bond0/bonding/queue_id
+
+Any interface that needs a queue_id set should set it with multiple calls until
+proper priorities are set or cleared for all interfaces.  On distributions that
+allow configuration via initscripts, multiple 'queue_id' arguments can be added
+to BONDING_OPTS to set all needed slave queues.
 
 These queue id's can be used in conjunction with the tc utility to configure
 a multiqueue qdisc and filters to bias certain traffic to transmit on certain
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77e3c6a..c9723d6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1560,8 +1560,8 @@ int bond_enslave(struct net_device *bond_dev, struct net_device *slave_dev)
 	}
 
 	/*
-	 * Set the new_slave's queue_id to be zero.  Queue ID mapping
-	 * is set via sysfs or module option if desired.
+	 * Set the new_slave's queue_id to be zero to disable.  Queue ID
+	 * mapping is set via sysfs.
 	 */
 	new_slave->queue_id = 0;
 
@@ -3355,7 +3355,8 @@ static void bond_info_show_slave(struct seq_file *seq,
 		else
 			seq_puts(seq, "Aggregator ID: N/A\n");
 	}
-	seq_printf(seq, "Slave queue ID: %d\n", slave->queue_id);
+	if (slave_tx_queue_recorded(slave))
+		seq_printf(seq, "Slave queue ID: %d\n", slave_get_tx_queue(slave));
 }
 
 static int bond_info_seq_show(struct seq_file *seq, void *v)
@@ -4516,15 +4517,16 @@ static inline int bond_slave_override(struct bonding *bond,
 
 	/* Find out if any slaves have the same mapping as this skb. */
 	bond_for_each_slave(bond, check_slave, i) {
-		if (check_slave->queue_id == skb->queue_mapping) {
+		if (slave_tx_queue_recorded(check_slave) &&
+		    slave_get_tx_queue(check_slave) == skb->queue_mapping) {
 			slave = check_slave;
 			break;
 		}
 	}
 
 	/* If the slave isn't UP, use default transmit policy. */
-	if (slave && slave->queue_id && IS_UP(slave->dev) &&
-	    (slave->link == BOND_LINK_UP)) {
+	if (slave && slave_tx_queue_recorded(slave) &&
+	    IS_UP(slave->dev) && (slave->link == BOND_LINK_UP)) {
 		res = bond_dev_queue_xmit(bond, skb, slave->dev);
 	}
 
@@ -4537,7 +4539,7 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
 	/*
 	 * This helper function exists to help dev_pick_tx get the correct
-	 * destination queue.  Using a helper function skips the a call to
+	 * destination queue.  Using a helper function skips the call to
 	 * skb_tx_hash and will put the skbs in the queue we expect on their
 	 * way down to the bonding driver.
 	 */
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 72bb0f6..d09701f 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1448,15 +1448,18 @@ static ssize_t bonding_show_queue_id(struct device *d,
 
 	read_lock(&bond->lock);
 	bond_for_each_slave(bond, slave, i) {
-		if (res > (PAGE_SIZE - IFNAMSIZ - 6)) {
-			/* not enough space for another interface_name:queue_id pair */
-			if ((PAGE_SIZE - res) > 10)
-				res = PAGE_SIZE - 10;
-			res += sprintf(buf + res, "++more++ ");
-			break;
+		if (slave_tx_queue_recorded(slave)) {
+			if (res > (PAGE_SIZE - IFNAMSIZ - 6)) {
+				/* Not enough space for another
+				 * interface_name:queue_id pair. */
+				if ((PAGE_SIZE - res) > 10)
+					res = PAGE_SIZE - 10;
+				res += sprintf(buf + res, "++more++ ");
+				break;
+			}
+			res += sprintf(buf + res, "%s:%d ", slave->dev->name,
+				       slave_get_tx_queue(slave));
 		}
-		res += sprintf(buf + res, "%s:%d ",
-			       slave->dev->name, slave->queue_id);
 	}
 	read_unlock(&bond->lock);
 	if (res)
@@ -1479,55 +1482,71 @@ static ssize_t bonding_store_queue_id(struct device *d,
 	int i, ret = count;
 	char *delim;
 	struct net_device *sdev = NULL;
+	char command[IFNAMSIZ + 7] = {0, };
+	char *ifname;
 
 	if (!rtnl_trylock())
 		return restart_syscall();
 
+	sscanf(buffer, "%22s", command); /* IFNAMSIZ*/
+
 	/* delim will point to queue id if successful */
-	delim = strchr(buffer, ':');
+	delim = strchr(command + 1, ':');
 	if (!delim)
 		goto err_no_cmd;
-
 	/*
 	 * Terminate string that points to device name and bump it
 	 * up one, so we can read the queue id there.
 	 */
 	*delim = '\0';
-	if (sscanf(++delim, "%hd\n", &qid) != 1)
+	if (sscanf(++delim, "%hd\n", &qid) != 1) {
 		goto err_no_cmd;
+	}
 
-	/* Check buffer length, valid ifname and queue id */
-	if (strlen(buffer) > IFNAMSIZ ||
-	    !dev_valid_name(buffer) ||
-	    qid > bond->params.tx_queues)
+	/* ifname will now be command + 1 */
+	ifname = command + 1;
+	if ((strlen(command) <= 1) ||
+	    !dev_valid_name(ifname) ||
+	    qid >= bond->params.tx_queues)
 		goto err_no_cmd;
 
 	/* Get the pointer to that interface if it exists */
-	sdev = __dev_get_by_name(dev_net(bond->dev), buffer);
+	sdev = __dev_get_by_name(dev_net(bond->dev), ifname);
 	if (!sdev)
 		goto err_no_cmd;
 
 	read_lock(&bond->lock);
 
-	/* Search for thes slave and check for duplicate qids */
+	/* Search for the slave needing the change */
 	update_slave = NULL;
 	bond_for_each_slave(bond, slave, i) {
 		if (sdev == slave->dev)
-			/*
-			 * We don't need to check the matching
-			 * slave for dups, since we're overwriting it
-			 */
 			update_slave = slave;
-		else if (qid && qid == slave->queue_id) {
+		else if (slave_tx_queue_recorded(slave) &&
+			 qid == slave_get_tx_queue(slave)) {
 			goto err_no_cmd_unlock;
 		}
 	}
-
 	if (!update_slave)
 		goto err_no_cmd_unlock;
 
-	/* Actually set the qids for the slave */
-	update_slave->queue_id = qid;
+	/* at this point we have a valid slave */
+	switch (command[0]) {
+	case '+':
+		if (slave_tx_queue_recorded(update_slave))
+			goto err_no_cmd_unlock;
+		slave_record_tx_queue(update_slave, qid);
+		break;
+	case '-':
+		if (!slave_tx_queue_recorded(update_slave) ||
+		    slave_get_tx_queue(update_slave) != qid)
+			goto err_no_cmd_unlock;
+		slave_clear_tx_queue(update_slave);
+		break;
+
+	default:
+		goto err_no_cmd;
+	}
 
 	read_unlock(&bond->lock);
 out:
@@ -1537,7 +1556,7 @@ out:
 err_no_cmd_unlock:
 	read_unlock(&bond->lock);
 err_no_cmd:
-	pr_info("invalid input for queue_id set for %s.\n",
+	pr_info("cannot modify queue_id for %s.\n",
 		bond->dev->name);
 	ret = -EPERM;
 	goto out;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 31fe980..c9059f4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -422,4 +422,24 @@ static inline void bond_unregister_ipv6_notifier(void)
 }
 #endif
 
+static inline void slave_record_tx_queue(struct slave *slave, u16 tx_queue)
+{
+	slave->queue_id = tx_queue + 1;
+}
+
+static inline u16 slave_get_tx_queue(const struct slave *slave)
+{
+	return slave->queue_id - 1;
+}
+
+static inline bool slave_tx_queue_recorded(const struct slave *slave)
+{
+	return slave->queue_id != 0;
+}
+
+static inline void slave_clear_tx_queue(struct slave *slave)
+{
+	slave->queue_id = 0;
+}
+
 #endif /* _LINUX_BONDING_H */
