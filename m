From: Veaceslav Falico <vfalico@redhat.com>
Subject: [PATCH v3 net-next 11/27] bonding: rework bond_3ad_xmit_xor() to use bond_for_each_slave() only
Date: Tue, 17 Sep 2013 02:46:36 +0200
Message-ID: <1379378812-18346-12-git-send-email-vfalico@redhat.com>
References: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Cc: jiri@resnulli.us, Veaceslav Falico <vfalico@redhat.com>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41601 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752019Ab3IQArJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Sep 2013 20:47:09 -0400
In-Reply-To: <1379378812-18346-1-git-send-email-vfalico@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, there are two loops - first we find the first slave in an
aggregator after the xmit_hash_policy() returned number, and after that we
loop from that slave, over bonding head, and till that slave to find any
suitable slave to send the packet through.

Replace it by just one bond_for_each_slave() loop, which first loops
through the requested number of slaves, saving the first suitable one, and
after that we've hit the requested number of slaves to skip - search for
any up slave to send the packet through. If we don't find such kind of
slave - then just send the packet through the first suitable slave found.

Logic remains unchainged, and we skip two loops. Also, refactor it a bit
for readability.

CC: Jay Vosburgh <fubar@us.ibm.com>
CC: Andy Gospodarek <andy@greyhouse.net>
Signed-off-by: Veaceslav Falico <vfalico@redhat.com>
---

Notes:
    v2  -> v3:
    No change.
    
    v1  -> v2:
    No changes.
    
    RFC -> v1:
    New patch.

 drivers/net/bonding/bond_3ad.c | 46 ++++++++++++++++++++----------------------
 1 file changed, 22 insertions(+), 24 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 3847aee..c861ee7 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2417,15 +2417,15 @@ int bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info)
 
 int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 {
-	struct slave *slave, *start_at;
 	struct bonding *bond = netdev_priv(dev);
+	struct slave *slave, *first_ok_slave;
+	struct aggregator *agg;
+	struct ad_info ad_info;
 	struct list_head *iter;
-	int slave_agg_no;
 	int slaves_in_agg;
-	int agg_id;
-	int i;
-	struct ad_info ad_info;
+	int slave_agg_no;
 	int res = 1;
+	int agg_id;
 
 	read_lock(&bond->lock);
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
@@ -2438,20 +2438,28 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	agg_id = ad_info.aggregator_id;
 
 	if (slaves_in_agg == 0) {
-		/*the aggregator is empty*/
 		pr_debug("%s: Error: active aggregator is empty\n", dev->name);
 		goto out;
 	}
 
 	slave_agg_no = bond->xmit_hash_policy(skb, slaves_in_agg);
+	first_ok_slave = NULL;
 
 	bond_for_each_slave(bond, slave, iter) {
-		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
+		agg = SLAVE_AD_INFO(slave).port.aggregator;
+		if (!agg || agg->aggregator_identifier != agg_id)
+			continue;
 
-		if (agg && (agg->aggregator_identifier == agg_id)) {
+		if (slave_agg_no >= 0) {
+			if (!first_ok_slave && SLAVE_IS_OK(slave))
+				first_ok_slave = slave;
 			slave_agg_no--;
-			if (slave_agg_no < 0)
-				break;
+			continue;
+		}
+
+		if (SLAVE_IS_OK(slave)) {
+			res = bond_dev_queue_xmit(bond, skb, slave->dev);
+			goto out;
 		}
 	}
 
@@ -2461,20 +2469,10 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		goto out;
 	}
 
-	start_at = slave;
-
-	bond_for_each_slave_from(bond, slave, i, start_at) {
-		int slave_agg_id = 0;
-		struct aggregator *agg = SLAVE_AD_INFO(slave).port.aggregator;
-
-		if (agg)
-			slave_agg_id = agg->aggregator_identifier;
-
-		if (SLAVE_IS_OK(slave) && agg && (slave_agg_id == agg_id)) {
-			res = bond_dev_queue_xmit(bond, skb, slave->dev);
-			break;
-		}
-	}
+	/* we couldn't find any suitable slave after the agg_no, so use the
+	 * first suitable found, if found. */
+	if (first_ok_slave)
+		res = bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
 
 out:
 	read_unlock(&bond->lock);
-- 
1.8.4
