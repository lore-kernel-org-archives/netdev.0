From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/2] macvtap: avoid hash calculating for single queue
Date: Fri, 15 Jul 2016 03:46:30 -0400
Message-ID: <1468568791-30024-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We decide the rxq through calculating its hash which is not necessary
if we only have one rx queue. So this patch skip this and just return
queue 0. Test shows 22% improving on guest rx pps.

Before: 1201504 pkts/s
After:  1472731 pkts/s

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 95a1332..2476923 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -299,6 +299,9 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 	if (!numvtaps)
 		goto out;
 
+	if (numvtaps == 1)
+		goto single;
+
 	/* Check if we can use flow to select a queue */
 	rxq = skb_get_hash(skb);
 	if (rxq) {
@@ -316,6 +319,7 @@ static struct macvtap_queue *macvtap_get_queue(struct net_device *dev,
 		goto out;
 	}
 
+single:
 	tap = rcu_dereference(vlan->taps[0]);
 out:
 	return tap;
-- 
1.8.3.1
