From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next v2 10/15] qeth: ensure that __vlan_find_dev_deep() is called with rcu_read_lock
Date: Tue, 14 Aug 2012 17:05:43 +0200
Message-ID: <1344956748-2099-11-git-send-email-jiri@resnulli.us>
References: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, edumazet@google.com, faisal.latif@intel.com,
	roland@kernel.org, sean.hefty@intel.com, hal.rosenstock@gmail.com,
	fubar@us.ibm.com, andy@greyhouse.net, divy@chelsio.com,
	jitendra.kalsaria@qlogic.com, sony.chacko@qlogic.com,
	linux-driver@qlogic.com, kaber@trash.net, ursula.braun@de.ibm.com,
	blaschka@linux.vnet.ibm.com, linux390@de.ibm.com,
	shemminger@vyatta.com, bhutchings@solarflare.com,
	therbert@google.com, xiyou.wangcong@gmail.com, joe@perches.com,
	gregory.v.rose@intel.com, john.r.fastabend@intel.com,
	linux-rdma@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-s390@vger.kernel.org, bridge@lists.linux-foundation.org,
	fbl@redhat.com
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344956748-2099-1-git-send-email-jiri@resnulli.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Also benefit from rcu_read_lock held and use __in_dev_get_rcu() in ipv4 case.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/s390/net/qeth_l3_main.c |   21 +++++++++++----------
 1 file changed, 11 insertions(+), 10 deletions(-)

diff --git a/drivers/s390/net/qeth_l3_main.c b/drivers/s390/net/qeth_l3_main.c
index c5f03fa..6b3988b 100644
--- a/drivers/s390/net/qeth_l3_main.c
+++ b/drivers/s390/net/qeth_l3_main.c
@@ -1638,6 +1638,7 @@ static void qeth_l3_add_mc(struct qeth_card *card, struct in_device *in4_dev)
 	}
 }
 
+/* called with rcu_read_lock */
 static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 {
 	struct in_device *in_dev;
@@ -1650,19 +1651,14 @@ static void qeth_l3_add_vlan_mc(struct qeth_card *card)
 	for_each_set_bit(vid, card->active_vlans, VLAN_N_VID) {
 		struct net_device *netdev;
 
-		rcu_read_lock();
 		netdev = __vlan_find_dev_deep(card->dev, vid);
-		rcu_read_unlock();
 		if (netdev == NULL ||
 		    !(netdev->flags & IFF_UP))
 			continue;
-		in_dev = in_dev_get(netdev);
+		in_dev = __in_dev_get_rcu(netdev);
 		if (!in_dev)
 			continue;
-		rcu_read_lock();
 		qeth_l3_add_mc(card, in_dev);
-		rcu_read_unlock();
-		in_dev_put(in_dev);
 	}
 }
 
@@ -1671,14 +1667,14 @@ static void qeth_l3_add_multicast_ipv4(struct qeth_card *card)
 	struct in_device *in4_dev;
 
 	QETH_CARD_TEXT(card, 4, "chkmcv4");
-	in4_dev = in_dev_get(card->dev);
-	if (in4_dev == NULL)
-		return;
 	rcu_read_lock();
+	in4_dev = __in_dev_get_rcu(card->dev);
+	if (in4_dev == NULL)
+		goto unlock;
 	qeth_l3_add_mc(card, in4_dev);
 	qeth_l3_add_vlan_mc(card);
+unlock:
 	rcu_read_unlock();
-	in_dev_put(in4_dev);
 }
 
 #ifdef CONFIG_QETH_IPV6
@@ -1703,6 +1699,7 @@ static void qeth_l3_add_mc6(struct qeth_card *card, struct inet6_dev *in6_dev)
 	}
 }
 
+/* called with rcu_read_lock */
 static void qeth_l3_add_vlan_mc6(struct qeth_card *card)
 {
 	struct inet6_dev *in_dev;
@@ -1739,10 +1736,12 @@ static void qeth_l3_add_multicast_ipv6(struct qeth_card *card)
 	in6_dev = in6_dev_get(card->dev);
 	if (in6_dev == NULL)
 		return;
+	rcu_read_lock();
 	read_lock_bh(&in6_dev->lock);
 	qeth_l3_add_mc6(card, in6_dev);
 	qeth_l3_add_vlan_mc6(card);
 	read_unlock_bh(&in6_dev->lock);
+	rcu_read_unlock();
 	in6_dev_put(in6_dev);
 }
 #endif /* CONFIG_QETH_IPV6 */
@@ -1811,8 +1810,10 @@ static void qeth_l3_free_vlan_addresses6(struct qeth_card *card,
 static void qeth_l3_free_vlan_addresses(struct qeth_card *card,
 			unsigned short vid)
 {
+	rcu_read_lock();
 	qeth_l3_free_vlan_addresses4(card, vid);
 	qeth_l3_free_vlan_addresses6(card, vid);
+	rcu_read_unlock();
 }
 
 static int qeth_l3_vlan_rx_add_vid(struct net_device *dev, unsigned short vid)
-- 
1.7.10.4
