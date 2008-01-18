From: Jay Vosburgh <fubar@us.ibm.com>
Subject: [PATCH 5/7] bonding: Fix up parameter parsing
Date: Thu, 17 Jan 2008 16:25:01 -0800
Message-ID: <12006159111680-git-send-email-fubar@us.ibm.com>
References: <12006159033257-git-send-email-fubar@us.ibm.com>
 <12006159063217-git-send-email-fubar@us.ibm.com>
 <12006159071917-git-send-email-fubar@us.ibm.com>
 <12006159081875-git-send-email-fubar@us.ibm.com>
 <12006159102124-git-send-email-fubar@us.ibm.com>
Cc: Jeff Garzik <jgarzik@pobox.com>,
	David Miller <davem@davemloft.net>,
	Andy Gospodarek <andy@greyhouse.net>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jay Vosburgh <fubar@us.ibm.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:43859 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756810AbYARAZP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jan 2008 19:25:15 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0I0PEuG021328
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:14 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0I0PDI81080336
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:13 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0I0PClZ022585
	for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 19:25:13 -0500
In-Reply-To: <12006159102124-git-send-email-fubar@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

	A recent change to add an additional hash policy modified
bond_parse_parm, but it now does not correctly match parameters passed in
via sysfs.

	Rewrote bond_parse_parm to handle (a) parameter matches that
are substrings of one another and (b) user input with whitespace (e.g.,
sysfs input often has a trailing newline).

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_main.c  |   23 ++++++++++++++++-------
 drivers/net/bonding/bond_sysfs.c |    8 ++++----
 drivers/net/bonding/bonding.h    |    4 +++-
 3 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 3ede0a2..379c5d8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4540,18 +4540,27 @@ static void bond_free_all(void)
 
 /*
  * Convert string input module parms.  Accept either the
- * number of the mode or its string name.
+ * number of the mode or its string name.  A bit complicated because
+ * some mode names are substrings of other names, and calls from sysfs
+ * may have whitespace in the name (trailing newlines, for example).
  */
-int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl)
+int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 {
-	int i;
+	int mode = -1, i, rv;
+	char modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
+
+	rv = sscanf(buf, "%d", &mode);
+	if (!rv) {
+		rv = sscanf(buf, "%20s", modestr);
+		if (!rv)
+			return -1;
+	}
 
 	for (i = 0; tbl[i].modename; i++) {
-		if ((isdigit(*mode_arg) &&
-		     tbl[i].mode == simple_strtol(mode_arg, NULL, 0)) ||
-		    (strcmp(mode_arg, tbl[i].modename) == 0)) {
+		if (mode == tbl[i].mode)
+			return tbl[i].mode;
+		if (strcmp(modestr, tbl[i].modename) == 0)
 			return tbl[i].mode;
-		}
 	}
 
 	return -1;
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 28a2d80..bff4f2b 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -423,7 +423,7 @@ static ssize_t bonding_store_mode(struct device *d,
 		goto out;
 	}
 
-	new_value = bond_parse_parm((char *)buf, bond_mode_tbl);
+	new_value = bond_parse_parm(buf, bond_mode_tbl);
 	if (new_value < 0)  {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Ignoring invalid mode value %.*s.\n",
@@ -478,7 +478,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 		goto out;
 	}
 
-	new_value = bond_parse_parm((char *)buf, xmit_hashtype_tbl);
+	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Ignoring invalid xmit hash policy value %.*s.\n",
@@ -518,7 +518,7 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 	int new_value;
 	struct bonding *bond = to_bond(d);
 
-	new_value = bond_parse_parm((char *)buf, arp_validate_tbl);
+	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
 		printk(KERN_ERR DRV_NAME
 		       ": %s: Ignoring invalid arp_validate value %s\n",
@@ -941,7 +941,7 @@ static ssize_t bonding_store_lacp(struct device *d,
 		goto out;
 	}
 
-	new_value = bond_parse_parm((char *)buf, bond_lacp_tbl);
+	new_value = bond_parse_parm(buf, bond_lacp_tbl);
 
 	if ((new_value == 1) || (new_value == 0)) {
 		bond->params.lacp_fast = new_value;
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index e1e4734..6d83be4 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -141,6 +141,8 @@ struct bond_parm_tbl {
 	int mode;
 };
 
+#define BOND_MAX_MODENAME_LEN 20
+
 struct vlan_entry {
 	struct list_head vlan_list;
 	__be32 vlan_ip;
@@ -314,7 +316,7 @@ void bond_mii_monitor(struct work_struct *);
 void bond_loadbalance_arp_mon(struct work_struct *);
 void bond_activebackup_arp_mon(struct work_struct *);
 void bond_set_mode_ops(struct bonding *bond, int mode);
-int bond_parse_parm(char *mode_arg, struct bond_parm_tbl *tbl);
+int bond_parse_parm(const char *mode_arg, struct bond_parm_tbl *tbl);
 void bond_select_active_slave(struct bonding *bond);
 void bond_change_active_slave(struct bonding *bond, struct slave *new_active);
 void bond_register_arp(struct bonding *);
-- 
1.5.3.4.206.g58ba4-dirty

