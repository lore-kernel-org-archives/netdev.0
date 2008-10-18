From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/6] bonding: fix sparse warnings
Date: Fri, 17 Oct 2008 21:32:54 -0700
Message-ID: <20081018043323.468786924@vyatta.com>
References: <20081018043252.968940967@vyatta.com>
Cc: bonding-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Jay Vousburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:52209 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751073AbYJREfz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2008 00:35:55 -0400
Content-Disposition: inline; filename=bonding-sparse.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes sparse warnings due to normal locking, and shadowed variable.
There is still one warning but it is valid, and caused by some dubious locking
in the failover MAC assignment.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/drivers/net/bonding/bond_main.c	2008-10-17 15:45:13.000000000 -0700
+++ b/drivers/net/bonding/bond_main.c	2008-10-17 18:59:11.000000000 -0700
@@ -3173,6 +3173,7 @@ out:
 #ifdef CONFIG_PROC_FS
 
 static void *bond_info_seq_start(struct seq_file *seq, loff_t *pos)
+	__acquires(dev_base_lock) __acquires(bond->lock)
 {
 	struct bonding *bond = seq->private;
 	loff_t off = 0;
@@ -3212,6 +3213,7 @@ static void *bond_info_seq_next(struct s
 }
 
 static void bond_info_seq_stop(struct seq_file *seq, void *v)
+	__releases(dev_base_lock) __releases(bond->lock)
 {
 	struct bonding *bond = seq->private;
 
@@ -4662,7 +4664,7 @@ static void bond_free_all(void)
  */
 int bond_parse_parm(const char *buf, struct bond_parm_tbl *tbl)
 {
-	int mode = -1, i, rv;
+	int newmode = -1, i, rv;
 	char *p, modestr[BOND_MAX_MODENAME_LEN + 1] = { 0, };
 
 	for (p = (char *)buf; *p; p++)
@@ -4672,13 +4674,13 @@ int bond_parse_parm(const char *buf, str
 	if (*p)
 		rv = sscanf(buf, "%20s", modestr);
 	else
-		rv = sscanf(buf, "%d", &mode);
+		rv = sscanf(buf, "%d", &newmode);
 
 	if (!rv)
 		return -1;
 
 	for (i = 0; tbl[i].modename; i++) {
-		if (mode == tbl[i].mode)
+		if (newmode == tbl[i].mode)
 			return tbl[i].mode;
 		if (strcmp(modestr, tbl[i].modename) == 0)
 			return tbl[i].mode;
--- a/drivers/net/bonding/bonding.h	2008-10-17 15:45:13.000000000 -0700
+++ b/drivers/net/bonding/bonding.h	2008-10-17 16:48:26.000000000 -0700
@@ -336,6 +336,7 @@ void bond_register_arp(struct bonding *)
 void bond_unregister_arp(struct bonding *);
 
 /* exported from bond_main.c */
+extern struct bond_params bonding_defaults;
 extern struct list_head bond_dev_list;
 extern struct bond_parm_tbl bond_lacp_tbl[];
 extern struct bond_parm_tbl bond_mode_tbl[];

-- 

