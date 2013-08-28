From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH 3/5] bonding: add rtnl lock for bonding_store_xmit_hash
Date: Wed, 28 Aug 2013 12:21:18 +0800
Message-ID: <521D7ABE.5080700@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:13899 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752607Ab3H1EVp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Aug 2013 00:21:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bonding_store_xmit_hash() call bond_set_mode_ops() to set bond xmit_policy,
the xmit_policy is used in xmit path for xor mode, so any changes may occur
problem without protection, add rtnl lock is fit here.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_sysfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/bonding/bond_sysfs.c b/drivers/net/bonding/bond_sysfs.c
index 0f539de..deb1d8e 100644
--- a/drivers/net/bonding/bond_sysfs.c
+++ b/drivers/net/bonding/bond_sysfs.c
@@ -382,6 +382,9 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 	int new_value, ret = count;
 	struct bonding *bond = to_bond(d);
 
+	if (!rtnl_trylock())
+		return restart_syscall();
+
 	new_value = bond_parse_parm(buf, xmit_hashtype_tbl);
 	if (new_value < 0)  {
 		pr_err("%s: Ignoring invalid xmit hash policy value %.*s.\n",
@@ -396,6 +399,7 @@ static ssize_t bonding_store_xmit_hash(struct device *d,
 			xmit_hashtype_tbl[new_value].modename, new_value);
 	}
 
+	rtnl_unlock();
 	return ret;
 }
 static DEVICE_ATTR(xmit_hash_policy, S_IRUGO | S_IWUSR,
-- 
1.8.2.1
