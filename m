From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 3/4] bonding: the calling of bond->slave_cnt need protection
Date: Sat, 20 Jul 2013 15:23:57 +0800
Message-ID: <51EA3B0D.7020501@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:25410 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753774Ab3GTHYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jul 2013 03:24:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding_store_mode has rtnl protection, so no need to get read lock
for bond->slave_cnt, but the bonding_store_fail_over_mac need to protect
the bond->slave_cnt, so add read_lock().

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index dc36a3d..d01a189 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -504,11 +504,14 @@ static ssize_t bonding_store_fail_over_mac(struct device *d,
 	int new_value;
 	struct bonding *bond = to_bond(d);
 
+	read_lock(&bond->lock);
 	if (bond->slave_cnt != 0) {
 		pr_err("%s: Can't alter fail_over_mac with slaves in bond.\n",
 		       bond->dev->name);
+		read_unlock(&bond->lock);
 		return -EPERM;
 	}
+	read_unlock(&bond->lock);
 
 	new_value = bond_parse_parm(buf, fail_over_mac_tbl);
 	if (new_value < 0) {
-- 
1.8.0
