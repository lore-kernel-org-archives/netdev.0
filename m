From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH 1/4] bonding: fix set mode race conditions
Date: Wed, 15 May 2013 14:32:39 +0200
Message-ID: <1368621162-6807-2-git-send-email-nikolay@redhat.com>
References: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Cc: andy@greyhouse.net, fubar@us.ibm.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1892 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758125Ab3EOMf7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 May 2013 08:35:59 -0400
In-Reply-To: <1368621162-6807-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changing the mode without any locking can result in multiple races (e.g.
upping a bond, enslaving/releasing). Depending on which race is hit the
impact can vary from incosistent bond state to kernel crash.
Use RTNL to synchronize the mode setting with the dangerous races.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
 drivers/net/bonding/bond_sysfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ea7a388..77ea237 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -316,6 +316,9 @@ static ssize_t bonding_store_mode(struct device *d,
 	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	if (bond->dev->flags & IFF_UP) {
 		pr_err("unable to update mode of %s because interface is up.\n",
 		       bond->dev->name);
@@ -352,6 +355,7 @@ static ssize_t bonding_store_mode(struct device *d,
 		bond->dev->name, bond_mode_tbl[new_value].modename,
 		new_value);
 out:
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(mode, S_IRUGO | S_IWUSR,
-- 
1.8.1.4
