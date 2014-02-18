From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 02/12] bonding: permit using arp_validate with non-ab modes
Date: Tue, 18 Feb 2014 07:48:37 +0100
Message-ID: <1392706127-28390-3-git-send-email-vfalico@redhat.com>
References: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9068 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250AbaBRGxH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 01:53:07 -0500
In-Reply-To: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently it's disabled because it's sometimes hard, in typical configs, to
make it work - because of the nature how the loadbalance modes work - as
it's hard to deliver valid arp replies to correct slaves by the switch.

However we still can use arp_validation in loadbalance with several other
configs, per example with arp_validate == 2 for backup with one broadcast
domain, without the switch(es) doing any balancing - this way we'd be (a
bit more) sure that the slave is up.

So, enable it to let users decide which one works/suits them best. Also
correct the mode limitation from BOND_OPT_ARP_VALIDATE.

CC: Nikolay Aleksandrov <nikolay@redhat.com>
CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 Documentation/networking/bonding.txt | 6 +++---
 drivers/net/bonding/bond_main.c      | 4 ----
 drivers/net/bonding/bond_options.c   | 3 ++-
 3 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index 5cdb229..96b4ad8 100644
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
index 3c50bec..91c0248 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4183,10 +4183,6 @@ static int bond_check_params(struct bond_params *params)
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
index f3eb44d..4d58645 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -151,7 +151,8 @@ static struct bond_option bond_opts[] = {
 		.id = BOND_OPT_ARP_VALIDATE,
 		.name = "arp_validate",
 		.desc = "validate src/dst of ARP probes",
-		.unsuppmodes = BOND_MODE_ALL_EX(BIT(BOND_MODE_ACTIVEBACKUP)),
+		.unsuppmodes = BIT(BOND_MODE_8023AD) | BIT(BOND_MODE_TLB) |
+			       BIT(BOND_MODE_ALB),
 		.values = bond_arp_validate_tbl,
 		.set = bond_option_arp_validate_set
 	},
-- 
1.8.4
