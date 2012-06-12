From: Weiping Pan <wpan@redhat.com>
Subject: [PATCH net V2] bonding:force to use primary slave
Date: Tue, 12 Jun 2012 11:35:06 +0800
Message-ID: <0d639c5449aad0222c7e88cf8a61013c1cdf98e2.1339472044.git.wpan@redhat.com>
References: <32118.1339449441@death.nxdomain>
Cc: nicolas.2p.debian@gmail.com, fubar@us.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59246 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751175Ab2FLDa1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jun 2012 23:30:27 -0400
In-Reply-To: <32118.1339449441@death.nxdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When we set primary slave with module parameters, bond will always use this
primary slave as active slave.

But when we modify primary slave via sysfs, it will call
bond_should_change_active() and take into account primary_reselect.

And I think we should use the new primary slave as the new active slave
regardless of the value of primary_reselect, since primary slave really should
have priority than other slaves.
primary_reselect is introduced to handle the failure or recovery of primary
slave, but when we modify primary slave via sysfs, we want to give it higher
priority, and it may or may not be a failure or recovery slave.

Thus the behavior is the same with module parameters and meets the
administrator's expectation.

Changelog:
V2:modify document

Signed-off-by: Weiping Pan <wpan@redhat.com>
---
 Documentation/networking/bonding.txt |    8 ++++++--
 drivers/net/bonding/bond_sysfs.c     |    1 +
 2 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/Documentation/networking/bonding.txt b/Documentation/networking/bonding.txt
index bfea8a3..9130050 100644
--- a/Documentation/networking/bonding.txt
+++ b/Documentation/networking/bonding.txt
@@ -652,7 +652,8 @@ primary
 
 	A string (eth0, eth2, etc) specifying which slave is the
 	primary device.  The specified device will always be the
-	active slave while it is available.  Only when the primary is
+	active slave while it is available.  Changing it via sysfs will make
+	it to be used as active slave immediately.  Only when the primary is
 	off-line will alternate devices be used.  This is useful when
 	one slave is preferred over another, e.g., when one slave has
 	higher throughput than another.
@@ -684,7 +685,7 @@ primary_reselect
 		The primary slave becomes the active slave only if the
 		current active slave fails and the primary slave is up.
 
-	The primary_reselect setting is ignored in two cases:
+	The primary_reselect setting is ignored in three cases:
 
 		If no slaves are active, the first slave to recover is
 		made the active slave.
@@ -692,6 +693,9 @@ primary_reselect
 		When initially enslaved, the primary slave is always made
 		the active slave.
 
+		When changing primary slave via sysfs, and if the primary
+		slave is up, bonding will use it as active slave immediately.
+
 	Changing the primary_reselect policy via sysfs will cause an
 	immediate selection of the best active slave according to the new
 	policy.  This may or may not result in a change of the active
diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 1b0f3cd..7256ae4 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -1077,6 +1077,7 @@ static ssize_t bonding_store_primary(struct device *d,
 				bond->dev->name, slave->dev->name);
 			bond->primary_slave = slave;
 			strcpy(bond->params.primary, slave->dev->name);
+			bond->force_primary = true;
 			bond_select_active_slave(bond);
 			goto out;
 		}
-- 
1.7.4
