From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH net-next 1/4] bonding: use RCU protection for 3ad xmit path
Date: Sun, 29 Sep 2013 19:44:44 +0800
Message-ID: <524812AC.3040805@huawei.com>
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
Received: from szxga03-in.huawei.com ([119.145.14.66]:29514 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2LpR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 29 Sep 2013 07:45:17 -0400
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
 drivers/net/bonding/bond_3ad.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index c62606a..971a7dc 100644
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
@@ -2388,7 +2388,6 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	int res = 1;
 	int agg_id;
 
-	read_lock(&bond->lock);
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
@@ -2406,7 +2405,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
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
