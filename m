From: Ding Tianhong <dingtianhong@huawei.com>
Subject: [PATCH RESEND net-next 2/7] bonding: slight optimization for bond_3ad_xmit_xor()
Date: Thu, 2 Jan 2014 09:12:59 +0800
Message-ID: <52C4BD1B.2060405@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Jay Vosburgh <fubar@us.ibm.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Julia Lawall <julia.lawall@lip6.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:57437 "EHLO
	szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbaABBN0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 20:13:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bond_dev_queue_xmit() will always return 0, and as a fast path,
it is inappropriate to check the res value when xmit every package,
so remove the res check and avoid once judgement for xmit.

Signed-off-by: Ding Tianhong <dingtianhong@huawei.com>
---
 drivers/net/bonding/bond_3ad.c | 22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
index 5393e1e..8d7483d 100644
--- a/drivers/net/bonding/bond_3ad.c
+++ b/drivers/net/bonding/bond_3ad.c
@@ -2401,13 +2401,12 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	struct list_head *iter;
 	int slaves_in_agg;
 	int slave_agg_no;
-	int res = 1;
 	int agg_id;
 
 	if (__bond_3ad_get_active_agg_info(bond, &ad_info)) {
 		pr_debug("%s: Error: __bond_3ad_get_active_agg_info failed\n",
 			 dev->name);
-		goto out;
+		goto err_free;
 	}
 
 	slaves_in_agg = ad_info.ports;
@@ -2415,7 +2414,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 
 	if (slaves_in_agg == 0) {
 		pr_debug("%s: Error: active aggregator is empty\n", dev->name);
-		goto out;
+		goto err_free;
 	}
 
 	slave_agg_no = bond_xmit_hash(bond, skb, slaves_in_agg);
@@ -2434,7 +2433,7 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 		}
 
 		if (SLAVE_IS_OK(slave)) {
-			res = bond_dev_queue_xmit(bond, skb, slave->dev);
+			bond_dev_queue_xmit(bond, skb, slave->dev);
 			goto out;
 		}
 	}
@@ -2442,21 +2441,22 @@ int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev)
 	if (slave_agg_no >= 0) {
 		pr_err("%s: Error: Couldn't find a slave to tx on for aggregator ID %d\n",
 		       dev->name, agg_id);
-		goto out;
+		goto err_free;
 	}
 
 	/* we couldn't find any suitable slave after the agg_no, so use the
 	 * first suitable found, if found. */
 	if (first_ok_slave)
-		res = bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
+		bond_dev_queue_xmit(bond, skb, first_ok_slave->dev);
+	else
+		goto err_free;
 
 out:
-	if (res) {
-		/* no suitable interface, frame not sent */
-		kfree_skb(skb);
-	}
-
 	return NETDEV_TX_OK;
+err_free:
+	/* no suitable interface, frame not sent */
+	kfree_skb(skb);
+	goto out;
 }
 
 int bond_3ad_lacpdu_recv(const struct sk_buff *skb, struct bonding *bond,
-- 
1.8.0
