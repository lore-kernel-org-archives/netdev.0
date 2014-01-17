From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v2 net-next 02/12] bonding: permit using arp_validate with non-ab modes
Date: Fri, 17 Jan 2014 17:58:50 +0100
Message-ID: <1389977940-17084-3-git-send-email-vfalico@redhat.com>
References: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23955 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752394AbaAQREO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jan 2014 12:04:14 -0500
In-Reply-To: <1389977940-17084-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's diabled because it's sometimes hard, in typical configs, to
make it work - because of the nature how the loadbalance modes work - as
it's hard to deliver valid arp replies to correct slaves by the switch.

However we still can use arp_validation in loadbalance in several other
configs, per example with arp_validate == 2 for backup with one broadcast
domain, without the switch(es) doing any balancing - this way we'd be (a
bit more) sure that the slave is up.

So, enable it to let users decide which one works/suits them best.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 Documentation/networking/bonding.txt | 6 +++---
 drivers/net/bonding/bond_main.c      | 4 ----
 drivers/net/bonding/bond_options.c   | 6 ------
 3 files changed, 3 insertions(+), 13 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index a4d925e..3620690 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -270,9 +270,9 @@ arp_ip_target
 arp_validate
 
 	Specifies whether or not ARP probes and replies should be
-	validated in the active-backup mode.  This causes the ARP
-	monitor to examine the incoming ARP requests and replies, and
-	only consider a slave to be up if it is receiving the
+	validated in any mode that supports arp monitoring.  This causes
+	the ARP monitor to examine the incoming ARP requests and replies,
+	and only consider a slave to be up if it is receiving the
 	appropriate ARP traffic.
 
 	Possible values are:
diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 479ca56..cc30618 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4198,10 +4198,6 @@ static int bond_check_params(struct bond_params *params)
 	}
 
 	if (arp_validate) {
-		if (bond_mode != BOND_MODE_ACTIVEBACKUP) {
-			pr_err("arp_validate only supported in active-backup mode\n");
-			return -EINVAL;
-		}
 		if (!arp_interval) {
 			pr_err("arp_validate requires arp_interval\n");
 			return -EINVAL;
diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index 945a666..f1c4fba 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -436,12 +436,6 @@ int bond_option_arp_validate_set(struct bonding *bond, int arp_validate)
 		return -EINVAL;
 	}
 
-	if (bond->params.mode != BOND_MODE_ACTIVEBACKUP) {
-		pr_err("%s: arp_validate only supported in active-backup mode.\n",
-		       bond->dev->name);
-		return -EINVAL;
-	}
-
 	pr_info("%s: setting arp_validate to %s (%d).\n",
 		bond->dev->name, arp_validate_tbl[arp_validate].modename,
 		arp_validate);
-- 
1.8.4
