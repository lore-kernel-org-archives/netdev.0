From: Tao Ma <tm@tao.ma>
Subject: [PATCH] bond: Don't set skb->queue_mapping in netpoll.
Date: Thu, 15 Aug 2013 16:36:48 +0800
Message-ID: <1376555808-6531-1-git-send-email-tm@tao.ma>
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tao Ma <boyu.mt@taobao.com>

When we are using netpoll, we don't go through the normal
transmit process. In this case, bond_select_queue is not called
and qdisc_skb_cb(skb)->slave_dev_queue_mapping isn't set.

So when netpoll_send_skb_on_dev calls ndo_start_xmit and we
enter bond_dev_queue_xmit, we will set skb->queue_mapping to
an invalid value and in some cases cause the driver panic the
kernel(We meet with bnx2 panic because of a very large queue_mapping).

This patch skip skb->queue_mapping if we find we are in netpoll.

CC: "David S. Miller" <davem@davemloft.net>
CC: Cong Wang <amwang@redhat.com>
CC: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Tao Ma <boyu.mt@taobao.com>
---
 drivers/net/bonding/bond_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 07f257d..97b2f52 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -405,12 +405,13 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
 
 	BUILD_BUG_ON(sizeof(skb->queue_mapping) !=
 		     sizeof(qdisc_skb_cb(skb)->slave_dev_queue_mapping));
-	skb->queue_mapping = qdisc_skb_cb(skb)->slave_dev_queue_mapping;
 
 	if (unlikely(netpoll_tx_running(bond->dev)))
 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
-	else
+	else {
+		skb->queue_mapping = qdisc_skb_cb(skb)->slave_dev_queue_mapping;
 		dev_queue_xmit(skb);
+	}
 
 	return 0;
 }
-- 
1.7.0.4
