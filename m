From: Cong Wang <amwang@redhat.com>
Subject: [Patch] bonding: show all the link status of slaves
Date: Fri, 15 Jun 2012 16:39:27 +0800
Message-ID: <1339749567-20393-1-git-send-email-amwang@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:6458 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753394Ab2FOIjx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Jun 2012 04:39:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are four link statuses of a bonding slave, the procfs
code shows a wrong status when using downdelay/updelay:

	(slave->link == BOND_LINK_UP) ?  "up" : "down"

It doesn't respect the rest two statuses. This patch fixes it.

Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
diff --git a/drivers/net/bonding/bond_procfs.c b/drivers/net/bonding/bond_procfs.c
index ad284ba..3cea38d 100644
--- a/drivers/net/bonding/bond_procfs.c
+++ b/drivers/net/bonding/bond_procfs.c
@@ -150,14 +150,25 @@ static void bond_info_show_master(struct seq_file *seq)
 	}
 }
 
+static const char *bond_slave_link_status(s8 link)
+{
+	static const char * const status[] = {
+		[BOND_LINK_UP] = "up",
+		[BOND_LINK_FAIL] = "going down",
+		[BOND_LINK_DOWN] = "down",
+		[BOND_LINK_BACK] = "going back",
+	};
+
+	return status[link];
+}
+
 static void bond_info_show_slave(struct seq_file *seq,
 				 const struct slave *slave)
 {
 	struct bonding *bond = seq->private;
 
 	seq_printf(seq, "\nSlave Interface: %s\n", slave->dev->name);
-	seq_printf(seq, "MII Status: %s\n",
-		   (slave->link == BOND_LINK_UP) ?  "up" : "down");
+	seq_printf(seq, "MII Status: %s\n", bond_slave_link_status(slave->link));
 	if (slave->speed == SPEED_UNKNOWN)
 		seq_printf(seq, "Speed: %s\n", "Unknown");
 	else
