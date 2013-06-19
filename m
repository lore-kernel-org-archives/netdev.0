From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH net-next 2/6] bonding: add helper function bond_get_targets_ip(targets, ip)
Date: Wed, 19 Jun 2013 19:34:42 +0200
Message-ID: <1371663286-12518-3-git-send-email-vfalico@redhat.com>
Cc: vfalico@redhat.com, fubar@us.ibm.com, andy@greyhouse.net,
	davem@davemloft.net, linux@8192.net, nicolas.2p.debian@free.fr,
	rick.jones2@hp.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33504 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756708Ab3FSRja (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jun 2013 13:39:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add function bond_get_targets_ip(targets, ip) which searches through
targets array of ips (arp_targets) and returns the position of first
match. If ip == 0, returns the first free slot. On failure to find the
ip or free slot, return -1.

Use it to verify if the arp we've received is valid and in sysfs.

Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_main.c  |   17 ++++-------
 drivers/net/bonding/bond_sysfs.c |   56 +++++++++++++++----------------------
 drivers/net/bonding/bonding.h    |   16 +++++++++++
 3 files changed, 45 insertions(+), 44 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3d8b5ba..09a79eb 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -2599,22 +2599,17 @@ static void bond_arp_send_all(struct bonding *bond, struct slave *slave)
 
 static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32 sip, __be32 tip)
 {
-	int i;
-	__be32 *targets = bond->params.arp_targets;
-
 	if (!bond_has_this_ip(bond, tip)) {
 		pr_debug("bva: tip %pI4 not found\n", &tip);
 		return;
 	}
 
-	for (i = 0; (i < BOND_MAX_ARP_TARGETS) && targets[i]; i++) {
-		pr_debug("bva: sip %pI4 tip %pI4 t[%d] %pI4 bhti(tip)\n",
-			 &sip, &tip, i, &targets[i]);
-		if (sip == targets[i]) {
-			slave->last_arp_rx = jiffies;
-			return;
-		}
+	if (bond_get_targets_ip(bond->params.arp_targets, sip) == -1) {
+		pr_debug("bva: sip %pI4 not found in targets\n", &sip);
+		return;
 	}
+
+	slave->last_arp_rx = jiffies;
 }
 
 static int bond_arp_rcv(const struct sk_buff *skb, struct bonding *bond,
@@ -4831,7 +4826,7 @@ static int __net_init bond_net_init(struct net *net)
 
 	bond_create_proc_dir(bn);
 	bond_create_sysfs(bn);
-	
+
 	return 0;
 }
 
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index f8bee4c..e680151 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -591,7 +591,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 					 const char *buf, size_t count)
 {
 	__be32 newtarget;
-	int i = 0, done = 0, ret = count;
+	int i = 0, ret = -EINVAL;
 	struct bonding *bond = to_bond(d);
 	__be32 *targets;
 
@@ -602,57 +602,46 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
 			pr_err("%s: invalid ARP target %pI4 specified for addition\n",
 			       bond->dev->name, &newtarget);
-			ret = -EINVAL;
 			goto out;
 		}
-		/* look for an empty slot to put the target in, and check for dupes */
-		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
-			if (targets[i] == newtarget) { /* duplicate */
-				pr_err("%s: ARP target %pI4 is already present\n",
-				       bond->dev->name, &newtarget);
-				ret = -EINVAL;
-				goto out;
-			}
-			if (targets[i] == 0) {
-				pr_info("%s: adding ARP target %pI4.\n",
-					bond->dev->name, &newtarget);
-				done = 1;
-				targets[i] = newtarget;
-			}
+
+		if (bond_get_targets_ip(targets, newtarget) != -1) { /* dup */
+			pr_err("%s: ARP target %pI4 is already present\n",
+			       bond->dev->name, &newtarget);
+			goto out;
 		}
-		if (!done) {
+
+		i = bond_get_targets_ip(targets, 0); /* first free slot */
+		if (i == -1) {
 			pr_err("%s: ARP target table is full!\n",
 			       bond->dev->name);
-			ret = -EINVAL;
 			goto out;
 		}
 
+		pr_info("%s: adding ARP target %pI4.\n", bond->dev->name,
+			 &newtarget);
+		targets[i] = newtarget;
+
 	} else if (buf[0] == '-')	{
 		if ((newtarget == 0) || (newtarget == htonl(INADDR_BROADCAST))) {
 			pr_err("%s: invalid ARP target %pI4 specified for removal\n",
 			       bond->dev->name, &newtarget);
-			ret = -EINVAL;
 			goto out;
 		}
 
-		for (i = 0; (i < BOND_MAX_ARP_TARGETS) && !done; i++) {
-			if (targets[i] == newtarget) {
-				int j;
-				pr_info("%s: removing ARP target %pI4.\n",
-					bond->dev->name, &newtarget);
-				for (j = i; (j < (BOND_MAX_ARP_TARGETS-1)) && targets[j+1]; j++)
-					targets[j] = targets[j+1];
-
-				targets[j] = 0;
-				done = 1;
-			}
-		}
-		if (!done) {
+		i = bond_get_targets_ip(targets, newtarget);
+		if (i == -1) {
 			pr_info("%s: unable to remove nonexistent ARP target %pI4.\n",
 				bond->dev->name, &newtarget);
-			ret = -EINVAL;
 			goto out;
 		}
+
+		pr_info("%s: removing ARP target %pI4.\n", bond->dev->name,
+			&newtarget);
+		for (; (i < BOND_MAX_ARP_TARGETS-1) && targets[i+1]; i++)
+			targets[i] = targets[i+1];
+		targets[i] = 0;
+
 	} else {
 		pr_err("no command found in arp_ip_targets file for bond %s. Use +<addr> or -<addr>.\n",
 		       bond->dev->name);
@@ -660,6 +649,7 @@ static ssize_t bonding_store_arp_targets(struct device *d,
 		goto out;
 	}
 
+	ret = count;
 out:
 	return ret;
 }
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index b38609b..7feab6c 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -464,6 +464,22 @@ static inline struct slave *bond_slave_has_mac(struct bonding *bond,
 	return NULL;
 }
 
+/* Check if the ip is present in arp ip list, or first free slot if ip == 0
+ * Returns -1 if not found, index if found
+ */
+static inline int bond_get_targets_ip(__be32 *targets, __be32 ip)
+{
+	int i;
+
+	for (i = 0; i < BOND_MAX_ARP_TARGETS; i++)
+		if (targets[i] == ip)
+			return i;
+		else if (targets[i] == 0)
+			break;
+
+	return -1;
+}
+
 /* exported from bond_main.c */
 extern int bond_net_id;
 extern const struct bond_parm_tbl bond_lacp_tbl[];
-- 
1.7.1
