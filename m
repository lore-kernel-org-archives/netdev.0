From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] tun: use symmetric hash
Date: Tue,  6 Jun 2017 14:09:49 +0800
Message-ID: <1496729389-15221-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tun actually expects a symmetric hash for queue selecting to work
correctly, otherwise packets belongs to a single flow may be
redirected to the wrong queue. So this patch switch to use
__skb_get_hash_symmetric().

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f8041f9c..fe660e5 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -465,7 +465,7 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
 	rcu_read_lock();
 	numqueues = ACCESS_ONCE(tun->numqueues);
 
-	txq = skb_get_hash(skb);
+	txq = __skb_get_hash_symmetric(skb);
 	if (txq) {
 		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
 		if (e) {
@@ -867,7 +867,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		 */
 		__u32 rxhash;
 
-		rxhash = skb_get_hash(skb);
+		rxhash = __skb_get_hash_symmetric(skb);
 		if (rxhash) {
 			struct tun_flow_entry *e;
 			e = tun_flow_find(&tun->flows[tun_hashfn(rxhash)],
@@ -1334,7 +1334,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_reset_network_header(skb);
 	skb_probe_transport_header(skb, 0);
 
-	rxhash = skb_get_hash(skb);
+	rxhash = __skb_get_hash_symmetric(skb);
 #ifndef CONFIG_4KSTACKS
 	tun_rx_batched(tun, tfile, skb, more);
 #else
-- 
2.7.4
