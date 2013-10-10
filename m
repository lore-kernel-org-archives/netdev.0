From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next v2 1/3] bonding: use RCU protection for 3ad xmit
 path
Date: Thu, 10 Oct 2013 19:50:57 +0800
Message-ID: <525694A1.3050108@huawei.com>
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
Received: from szxga01-in.huawei.com ([119.145.14.64]:25620 "EHLO
	szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753748Ab3JJLvZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Oct 2013 07:51:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The commit 278b20837511776dc9d5f6ee1c7fabd5479838bb
(bonding: initial RCU conversion) has convert the roundrobin,
active-backup, broadcast and xor xmit path to rcu protection,
the performance will be better for these mode, so this time,
convert xmit path for 3ad mode.

Suggested-by: Nikolay Aleksandrov <nikolay@redhat.com>
Suggested-by: Veaceslav Falico <vfalico@redhat.com>
Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
Signed-off-by: Wang Yufen <wangyufen@huawei.com>
Cc: Nikolay Aleksandrov <nikolay@redhat.com>
Cc: Veaceslav Falico <vfalico@redhat.com>
---
 drivers/net/bonding/bond_3ad.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index ea3e64e..187b1b7 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2344,7 +2344,7 @@ int __bond_3ad_get_active_agg_info(struct bonding *bond,
 	struct slave *slave;
 	struct port *port;
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		port = &(SLAVE_AD_INFO(slave).port);
 		if (port->aggregator && port->aggregator->is_active) {
 			aggregator = port->aggregator;
@@ -2369,9 +2369,9 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 {
 	int ret;
 
-	read_lock(&bond->lock);
+	rcu_read_lock();
 	ret = __bond_3ad_get_active_agg_info(bond, ad_info);
-	read_unlock(&bond->lock);
+	rcu_read_unlock();
 
 	return ret;
 }
@@ -2388,7 +2388,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	int res = 1;
 	int agg_id;
 
-	read_lock(&bond->lock);
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
@@ -2406,7 +2405,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	slave_agg_no = bond_xmit_hash(bond, skb, slaves_in_agg);
 	first_ok_slave = NULL;
 
-	bond_for_each_slave(bond, slave, iter) {
+	bond_for_each_slave_rcu(bond, slave, iter) {
 		agg = SLAVE_AD_INFO(slave).port.aggregator;
 		if (!agg || agg->aggregator_identifier != agg_id)
 			continue;
@@ -2436,7 +2435,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		res = bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
 
 out:
-	read_unlock(&bond->lock);
 	if (res) {
 		/* no suitable interface, frame not sent */
 		kfree_skb(skb);
-- 
1.8.2.1
