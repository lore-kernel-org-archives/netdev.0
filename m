From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH] Bonding: fix zero address hole bug in arp_ip_target list
Date: Fri, 10 Apr 2009 22:41:14 -0400
Message-ID: <1239417674-8374-1-git-send-email-brian.haley@hp.com>
References: <bug-13006-10286@http.bugzilla.kernel.org/>
Cc: netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	akpm@linux-foundation.org
To: fubar@us.ibm.com, steve@astutenetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:48448 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755230AbZDKClR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Apr 2009 22:41:17 -0400
In-Reply-To: <bug-13006-10286@http.bugzilla.kernel.org/>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix a zero address hole bug in the bonding arp_ip_target list
that was causing the bond to ignore ARP replies (bugz 13006).
Instead of just setting the array entry to zero, we now
copy any additional entries down one slot, putting the
zero entry at the end.  With this change we can now have
all the loops that walk the array stop when they hit a zero
since there will be no addresses after it.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---
 Documentation/networking/bonding.txt |    2 +-
 drivers/net/bonding/bond_main.c      |    5 ++---
 drivers/net/bonding/bond_sysfs.c     |   14 ++++++++------
 3 files changed, 11 insertions(+), 10 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 5ede747..0876275 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -1242,7 +1242,7 @@ monitoring is enabled, and vice-versa.
 To add ARP targets:
 # echo +192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
 # echo +192.168.0.101 > /sys/class/net/bond0/bonding/arp_ip_target
-	NOTE:  up to 10 target addresses may be specified.
+	NOTE:  up to 16 target addresses may be specified.
 
 To remove an ARP target:
 # echo -192.168.0.100 > /sys/class/net/bond0/bonding/arp_ip_target
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 99610f3..63369b6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2570,7 +2570,7 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
 		if (!targets[i])
-			continue;
+			break;
 		pr_debug("basa: target %x\n", targets[i]);
 		if (list_empty(&bond->vlan_list)) {
 			pr_debug("basa: empty vlan: arp_send\n");
@@ -2677,7 +2677,6 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
 	int i;
 	__be32 *targets = bond->params.arp_targets;
 
-	targets = bond->params.arp_targets;
 	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
 		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip) %d\n",
 			&sip, &tip, i, &targets[i], bond_has_this_ip(bond, tip));
@@ -3303,7 +3302,7 @@ static void bond_info_show_master(struct seq_file *seq)
 
 		for(i = 0; (i < BOND_MAX_ARP_TARGETS) ;i++) {
 			if (!bond->params.arp_targets[i])
-				continue;
+				break;
 			if (printed)
 				seq_printf(seq, ",");
 			seq_printf(seq, " %pI4", &bond->params.arp_targets[i]);
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 18cf478..d287315 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -684,17 +684,15 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			goto out;
 		}
 		/* look for an empty slot to put the target in, and check for dupes */
-		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
+		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
 			if (targets[i] == newtarget) { /* duplicate */
 				printk(KERN_ERR DRV_NAME
 				       ": %s: ARP target %pI4 is already present\n",
 				       bond->dev->name, &newtarget);
-				if (done)
-					targets[i] = 0;
 				ret = -EINVAL;
 				goto out;
 			}
-			if (targets[i] == 0 && !done) {
+			if (targets[i] == 0) {
 				printk(KERN_INFO DRV_NAME
 				       ": %s: adding ARP target %pI4.\n",
 				       bond->dev->name, &newtarget);
@@ -720,12 +718,16 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 			goto out;
 		}
 
-		for (i = 0; (i < BOND_MAX_ARP_TARGETS); i++) {
+		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
 			if (targets[i] == newtarget) {
+				int j;
 				printk(KERN_INFO DRV_NAME
 				       ": %s: removing ARP target %pI4.\n",
 				       bond->dev->name, &newtarget);
-				targets[i] = 0;
+				for (j = i; (j < (BOND_MAX_ARP_TARGETS-1)) && targets[j+1]; j++)
+					targets[j] = targets[j+1];
+
+				targets[j] = 0;
 				done = 1;
 			}
 		}
-- 
1.5.4.3

