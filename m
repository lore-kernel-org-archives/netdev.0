From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 3/4 v2] bonding: add rtnl protection for bonding_store_fail_over_mac
Date: Tue, 23 Jul 2013 15:25:39 +0800
Message-ID: <51EE2FF3.3000601@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:40107 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754458Ab3GWHZ4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 03:25:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need rtnl protection while reading slave_cnt and updating
the .fail_over_mac, and it also follows the logic "don't change
anything slave-related without rtnl". :)

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Jay Vosburgh <fubar@us.ibm.com>
Cc: Andy Gospodarek <andy@greyhouse.net>
---
 drivers/net/bonding/bond_sysfs.c | 15 +++++++++++----
 1 file changed, 11 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dc36a3d..8a5a6a3 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -501,20 +501,25 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 					   struct device_attribute *attr,
 					   const char *buf, size_t count)
 {
-	int new_value;
+	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	if (bond->slave_cnt != 0) {
 		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
-		return -EPERM;
+		ret = -EPERM;
+		goto out;
 	}
 
 	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
 	if (new_value < 0) {
 		pr_err("%s: Ignoring invalid fail_over_mac value %s.\n",
 		       bond->dev->name, buf);
-		return -EINVAL;
+		ret = -EINVAL;
+		goto out;
 	}
 
 	bond->params.fail_over_mac = new_value;
@@ -522,7 +527,9 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 		bond->dev->name, fail_over_mac_tbl[new_value].modename,
 		new_value);
 
-	return count;
+out:
+	rtnl_unlock();
+	return ret;
 }
 
 static DEVICE_ATTR(fail_over_mac, S_IRUGO | S_IWUSR,
-- 
1.8.0
