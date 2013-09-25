From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v5 4/6] bonding: add rtnl lock for bonding_store_xmit_hash
Date: Wed, 25 Sep 2013 17:52:25 +0800
Message-ID: <5242B259.2080603@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:27010 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035Ab3IYJxK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 05:53:10 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

the bonding_store_xmit_hash() could update bond's xmit_policy, and
the xmit_policy is used in xmit path for xor mode, maybe it is hard
to occur any problem, but just follow the logic "don't change anything
slave-related without rtnl", so I think the rntl lock is fit here. :)

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
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
