From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: [PATCH -net v2 1/2] bonding: fix store_arp_validate race with mode change
Date: Sat,  7 Sep 2013 00:00:25 +0200
Message-ID: <1378504826-18855-2-git-send-email-nikolay@redhat.com>
References: <1378504826-18855-1-git-send-email-nikolay@redhat.com>
Cc: fubar@us.ibm.com, andy@greyhouse.net, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:16705 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751016Ab3IFWEJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Sep 2013 18:04:09 -0400
In-Reply-To: <1378504826-18855-1-git-send-email-nikolay@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to protect store_arp_validate via rtnl because it can race with
mode changing and we can end up having arp_validate set in a mode
different from active-backup.

Signed-off-by: Nikolay Aleksandrov <nikolay@redhat.com>
---
v2: no change

 drivers/net/bonding/bond_sysfs.c | 14 ++++++++++----
 1 file changed, 10 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index ce46776..4e38683 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -419,27 +419,33 @@ static ssize_t bonding_store_arp_validate(struct device *d,
 					  struct device_attribute *attr,
 					  const char *buf, size_t count)
 {
-	int new_value;
+	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
 	new_value = bond_parse_parm(buf, arp_validate_tbl);
 	if (new_value < 0) {
 		pr_err("%s: Ignoring invalid arp_validate value %s\n",
 		       bond->dev->name, buf);
-		return -EINVAL;
+		ret = -EINVAL;
+		goto out;
 	}
 	if (new_value && (bond->params.mode != BOND_MODE_ACTIVEBACKUP)) {
 		pr_err("%s: arp_validate only supported in active-backup mode.\n",
 		       bond->dev->name);
-		return -EINVAL;
+		ret = -EINVAL;
+		goto out;
 	}
 	pr_info("%s: setting arp_validate to %s (%d).\n",
 		bond->dev->name, arp_validate_tbl[new_value].modename,
 		new_value);
 
 	bond->params.arp_validate = new_value;
+out:
+	rtnl_unlock();
 
-	return count;
+	return ret;
 }
 
 static DEVICE_ATTR(arp_validate, S_IRUGO | S_IWUSR, bonding_show_arp_validate,
-- 
1.8.1.4
