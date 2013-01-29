From: Milos Vyletel <milos.vyletel@sde.cz>
Subject: [PATCH v2] bonding: unset primary slave via sysfs
Date: Tue, 29 Jan 2013 14:59:00 -0500
Message-ID: <1359489540-14620-1-git-send-email-milos.vyletel@sde.cz>
References: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Cc: fubar@us.ibm.com, andy@greyhouse.net,
	Milos Vyletel <milos.vyletel@sde.cz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.sde.cz ([85.93.125.197]:44610 "EHLO sde.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751067Ab3A2T7v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jan 2013 14:59:51 -0500
In-Reply-To: <1359393652-2804-1-git-send-email-milos.vyletel@sde.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When bonding module is loaded with primary parameter and one decides to unset
primary slave using sysfs these settings are not preserved during bond device
restart. Primary slave is only unset once and it's not remembered in
bond->params structure. Below is example of recreation.

 grep OPTS /etc/sysconfig/network-scripts/ifcfg-bond0
BONDING_OPTS="mode=active-backup miimon=100 primary=eth01"
 grep "Primary Slave" /proc/net/bonding/bond0
Primary Slave: eth01 (primary_reselect always)

 echo "" > /sys/class/net/bond0/bonding/primary
 grep "Primary Slave" /proc/net/bonding/bond0
Primary Slave: None

 sed -i -e 's/primary=eth01//' /etc/sysconfig/network-scripts/ifcfg-bond0
 grep OPTS /etc/sysconfig/network-scripts/ifcfg-bond
BONDING_OPTS="mode=active-backup miimon=100 "
 ifdown bond0 && ifup bond0

without patch:
 grep "Primary Slave" /proc/net/bonding/bond0
Primary Slave: eth01 (primary_reselect always)

with patch:
 grep "Primary Slave" /proc/net/bonding/bond0
Primary Slave: None

Reviewed-by: Jiri Pirko <jiri@resnulli.us>
Signed-off-by: Milos Vyletel <milos.vyletel@sde.cz>
Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>
---
 drivers/net/bonding/bond_sysfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ef8d2a0..155f3b4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1067,6 +1067,7 @@ static ssize_t bonding_store_primary(struct device *d,
 		pr_info("%s: Setting primary slave to None.\n",
 			bond->dev->name);
 		bond->primary_slave = NULL;
+		memset(bond->params.primary, 0, sizeof(bond->params.primary));
 		bond_select_active_slave(bond);
 		goto out;
 	}
-- 
1.7.1
