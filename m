From: Pankaj Gupta <pagupta@redhat.com>
Subject: [RFC 3/4] tuntap: reduce the size of tun_struct by using flex array
Date: Mon, 18 Aug 2014 19:07:19 +0530
Message-ID: <1408369040-1216-4-git-send-email-pagupta@redhat.com>
References: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Cc: davem@davemloft.net, jasowang@redhat.com, mst@redhat.com,
	dgibson@redhat.com, vfalico@gmail.com, edumazet@google.com,
	vyasevic@redhat.com, hkchu@google.com, wuzhy@linux.vnet.ibm.com,
	xemul@parallels.com, therbert@google.com,
	bhutchings@solarflare.com, xii@google.com,
	stephen@networkplumber.org, Pankaj Gupta <pagupta@redhat.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408369040-1216-1-git-send-email-pagupta@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch switches to flex array to implement the flow caches, it brings
several advantages:

- Reduce the size of the tun_struct structure, which allows us to increase the
  upper limit of queues in future.
- Avoid higher order memory allocation. It will be useful when switching to
  pure hashing in flow cache which may demand a larger size array in future.

After this patch, the size of tun_struct on x86_64 reduced from 8512 to
328

Signed-off-by: Jason Wang <jasowang@redhat.com>
Signed-off-by: Pankaj Gupta <pagupta@redhat.com>
---
 drivers/net/tun.c |   49 +++++++++++++++++++++++++++++++++++++------------
 1 files changed, 37 insertions(+), 12 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index acaaf67..7dd495f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -65,6 +65,7 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <linux/flex_array.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -186,7 +187,7 @@ struct tun_struct {
 	int debug;
 #endif
 	spinlock_t lock;
-	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
+	struct flex_array *flows;
 	struct timer_list flow_gc_timer;
 	unsigned long ageing_time;
 	unsigned int numdisabled;
@@ -247,10 +248,11 @@ static void tun_flow_flush(struct tun_struct *tun)
 
 	spin_lock_bh(&tun->lock);
 	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
+		struct hlist_head *h = flex_array_get(tun->flows, i);
 		struct tun_flow_entry *e;
 		struct hlist_node *n;
 
-		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link)
+		hlist_for_each_entry_safe(e, n, h, hash_link)
 			tun_flow_delete(tun, e);
 	}
 	spin_unlock_bh(&tun->lock);
@@ -262,10 +264,11 @@ static void tun_flow_delete_by_queue(struct tun_struct *tun, u16 queue_index)
 
 	spin_lock_bh(&tun->lock);
 	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
+		struct hlist_head *h = flex_array_get(tun->flows, i);
 		struct tun_flow_entry *e;
 		struct hlist_node *n;
 
-		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link) {
+		hlist_for_each_entry_safe(e, n, h, hash_link) {
 			if (e->queue_index == queue_index)
 				tun_flow_delete(tun, e);
 		}
@@ -285,10 +288,11 @@ static void tun_flow_cleanup(unsigned long data)
 
 	spin_lock_bh(&tun->lock);
 	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++) {
+		struct hlist_head *h = flex_array_get(tun->flows, i);
 		struct tun_flow_entry *e;
 		struct hlist_node *n;
 
-		hlist_for_each_entry_safe(e, n, &tun->flows[i], hash_link) {
+		hlist_for_each_entry_safe(e, n, h, hash_link) {
 			unsigned long this_timer;
 			count++;
 			this_timer = e->updated + delay;
@@ -315,7 +319,7 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
 	if (!rxhash)
 		return;
 	else
-		head = &tun->flows[tun_hashfn(rxhash)];
+		head = flex_array_get(tun->flows, tun_hashfn(rxhash));
 
 	rcu_read_lock();
 
@@ -378,7 +382,8 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
 
 	txq = skb_get_hash(skb);
 	if (txq) {
-		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
+		e = tun_flow_find(flex_array_get(tun->flows,
+						 tun_hashfn(txq)), txq);
 		if (e) {
 			tun_flow_save_rps_rxhash(e, txq);
 			txq = e->queue_index;
@@ -758,8 +763,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		rxhash = skb_get_hash(skb);
 		if (rxhash) {
 			struct tun_flow_entry *e;
-			e = tun_flow_find(&tun->flows[tun_hashfn(rxhash)],
-					rxhash);
+			e = tun_flow_find(flex_array_get(tun->flows,
+							 tun_hashfn(rxhash)), rxhash);
 			if (e)
 				tun_flow_save_rps_rxhash(e, rxhash);
 		}
@@ -894,23 +899,40 @@ static const struct net_device_ops tap_netdev_ops = {
 #endif
 };
 
-static void tun_flow_init(struct tun_struct *tun)
+static int tun_flow_init(struct tun_struct *tun)
 {
-	int i;
+	struct flex_array *buckets;
+	int i, err;
+
+	buckets = flex_array_alloc(sizeof(struct hlist_head),
+				   TUN_NUM_FLOW_ENTRIES, GFP_KERNEL);
+	if (!buckets)
+		return -ENOMEM;
+
+	err = flex_array_prealloc(buckets, 0, TUN_NUM_FLOW_ENTRIES, GFP_KERNEL);
+	if (err) {
+		flex_array_free(buckets);
+		return -ENOMEM;
+	}
 
+	tun->flows = buckets;
 	for (i = 0; i < TUN_NUM_FLOW_ENTRIES; i++)
-		INIT_HLIST_HEAD(&tun->flows[i]);
+		INIT_HLIST_HEAD((struct hlist_head *)
+				flex_array_get(buckets, i));
 
 	tun->ageing_time = TUN_FLOW_EXPIRE;
 	setup_timer(&tun->flow_gc_timer, tun_flow_cleanup, (unsigned long)tun);
 	mod_timer(&tun->flow_gc_timer,
 		  round_jiffies_up(jiffies + tun->ageing_time));
+
+	return 0;
 }
 
 static void tun_flow_uninit(struct tun_struct *tun)
 {
 	del_timer_sync(&tun->flow_gc_timer);
 	tun_flow_flush(tun);
+	flex_array_free(tun->flows);
 }
 
 /* Initialize net device. */
@@ -1659,7 +1681,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			goto err_free_dev;
 
 		tun_net_init(dev);
-		tun_flow_init(tun);
+
+		err = tun_flow_init(tun);
+		if (err < 0)
+			goto err_free_dev;
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
 				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
-- 
1.7.1
