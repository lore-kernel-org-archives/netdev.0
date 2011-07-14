From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH net-next] bonding: fix strlen errors in sysfs
Date: Wed, 13 Jul 2011 21:57:45 -0400
Message-ID: <1310608665-12216-1-git-send-email-andy@greyhouse.net>
Cc: Takuma Umeya <tumeya@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20686 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752069Ab1GNBz0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2011 21:55:26 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6E1tQCX008622
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 21:55:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a bond contains a device where one name is the subset of another
(eth1 and eth10, for example), one cannot properly set the primary
device or the currently active device.

This was reported and based on work by Takuma Umeya.  I also verified
the problem and tested that this fix resolves it.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
Reported-by: Takuma Umeya <tumeya@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index b60835f..50e859c 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1037,9 +1037,9 @@ static ssize_t bonding_store_primary(struct device *d,
 			bond->dev->name, bond->dev->name, bond->params.mode);
 	} else {
 		bond_for_each_slave(bond, slave, i) {
-			if (strnicmp
-			    (slave->dev->name, buf,
-			     strlen(slave->dev->name)) == 0) {
+			int max_len = max(strlen(slave->dev->name),
+					  strlen(buf) - 1);
+			if (strnicmp(slave->dev->name, buf, max_len) == 0) {
 				pr_info("%s: Setting %s as primary slave.\n",
 					bond->dev->name, slave->dev->name);
 				bond->primary_slave = slave;
@@ -1208,9 +1208,9 @@ static ssize_t bonding_store_active_slave(struct device *d,
 			bond->dev->name, bond->dev->name, bond->params.mode);
 	else {
 		bond_for_each_slave(bond, slave, i) {
-			if (strnicmp
-			    (slave->dev->name, buf,
-			     strlen(slave->dev->name)) == 0) {
+			int max_len = max(strlen(slave->dev->name),
+					  strlen(buf) - 1);
+			if (strnicmp(slave->dev->name, buf, max_len) == 0) {
         			old_active = bond->curr_active_slave;
         			new_active = slave;
         			if (new_active == old_active) {
-- 
1.7.4.4

