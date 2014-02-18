From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v5 net-next 05/12] bonding: extend arp_validate to be able to receive unvalidated arp-only traffic
Date: Tue, 18 Feb 2014 07:48:40 +0100
Message-ID: <1392706127-28390-6-git-send-email-vfalico@redhat.com>
References: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43936 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753314AbaBRGxL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Feb 2014 01:53:11 -0500
In-Reply-To: <1392706127-28390-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently we can either receive any traffic as a proff of slave being up,
or only *validated* arp traffic (i.e. with src/dst ip checked).

Add an option to be able to specify if we want to receive non-validated arp
traffic only.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_options.c | 13 ++++++++-----
 drivers/net/bonding/bonding.h      | 11 +++++++++++
 2 files changed, 19 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bonding/bond_options.c b/drivers/net/bonding/bond_options.c
index ad20c8c..5f997b9 100644
--- a/drivers/net/bonding/bond_options.c
+++ b/drivers/net/bonding/bond_options.c
@@ -47,11 +47,14 @@ static struct bond_opt_value bond_xmit_hashtype_tbl[] = {
 };
 
 static struct bond_opt_value bond_arp_validate_tbl[] = {
-	{ "none",   BOND_ARP_VALIDATE_NONE,   BOND_VALFLAG_DEFAULT},
-	{ "active", BOND_ARP_VALIDATE_ACTIVE, 0},
-	{ "backup", BOND_ARP_VALIDATE_BACKUP, 0},
-	{ "all",    BOND_ARP_VALIDATE_ALL,    0},
-	{ NULL,     -1,                       0},
+	{ "none",		BOND_ARP_VALIDATE_NONE,		BOND_VALFLAG_DEFAULT},
+	{ "active",		BOND_ARP_VALIDATE_ACTIVE,	0},
+	{ "backup",		BOND_ARP_VALIDATE_BACKUP,	0},
+	{ "all",		BOND_ARP_VALIDATE_ALL,		0},
+	{ "filter",		BOND_ARP_FILTER,		0},
+	{ "filter_active",	BOND_ARP_FILTER_ACTIVE,		0},
+	{ "filter_backup",	BOND_ARP_FILTER_BACKUP,		0},
+	{ NULL,			-1,				0},
 };
 
 static struct bond_opt_value bond_arp_all_targets_tbl[] = {
diff --git a/drivers/net/bonding/bonding.h b/drivers/net/bonding/bonding.h
index 86ccfb9..ab2e651 100644
--- a/drivers/net/bonding/bonding.h
+++ b/drivers/net/bonding/bonding.h
@@ -342,6 +342,11 @@ static inline bool bond_is_active_slave(struct slave *slave)
 #define BOND_ARP_VALIDATE_BACKUP	(1 << BOND_STATE_BACKUP)
 #define BOND_ARP_VALIDATE_ALL		(BOND_ARP_VALIDATE_ACTIVE | \
 					 BOND_ARP_VALIDATE_BACKUP)
+#define BOND_ARP_FILTER			(BOND_ARP_VALIDATE_ALL + 1)
+#define BOND_ARP_FILTER_ACTIVE		(BOND_ARP_VALIDATE_ACTIVE | \
+					 BOND_ARP_FILTER)
+#define BOND_ARP_FILTER_BACKUP		(BOND_ARP_VALIDATE_BACKUP | \
+					 BOND_ARP_FILTER)
 
 static inline int slave_do_arp_validate(struct bonding *bond,
 					struct slave *slave)
@@ -349,6 +354,12 @@ static inline int slave_do_arp_validate(struct bonding *bond,
 	return bond->params.arp_validate & (1 << bond_slave_state(slave));
 }
 
+static inline int slave_do_arp_validate_only(struct bonding *bond,
+					     struct slave *slave)
+{
+	return bond->params.arp_validate & BOND_ARP_FILTER;
+}
+
 /* Get the oldest arp which we've received on this slave for bond's
  * arp_targets.
  */
-- 
1.8.4
