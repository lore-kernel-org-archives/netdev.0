From: Jason Wang <jasowang@redhat.com>
Subject: [net-next rfc 2/3] tuntap: reduce the size of tun_struct by using flex array
Date: Wed, 19 Jun 2013 13:40:51 +0800
Message-ID: <1371620452-49349-3-git-send-email-jasowang@redhat.com>
References: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, edumazet@google.com, hkchu@google.com,
	mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371620452-49349-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch switches to use flex array to implement the flow caches, it can
brings several advantages:

- save the size of the tun_struct structure, which can allows us to increase the
  upper limit of queues in the future.
- avoid higher order memory allocation which could be used when switching to use
  pure hashing in flow cache who may demand a larger size array in the future.

After this patch, the size of tun_struct on x86_64 were reduced from 8512 to
328.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c      |   54 +++++++++++++++++++++++++++++++++++++----------
 net/openvswitch/flow.c |    2 +-
 2 files changed, 43 insertions(+), 13 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a344270..8c5c124 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -64,6 +64,7 @@
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
 #include <linux/rcupdate.h>
+#include <linux/flex_array.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
 #include <net/rtnetlink.h>
@@ -180,7 +181,7 @@ struct tun_struct {
 	int debug;
 #endif
 	spinlock_t lock;
-	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
+	struct flex_array *flows;
 	struct timer_list flow_gc_timer;
 	unsigned long ageing_time;
 	unsigned int numdisabled;
@@ -239,10 +240,11 @@ static void tun_flow_flush(struct tun_struct *tun)
 
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
@@ -254,10 +256,11 @@ static void tun_flow_delete_by_queue(struct tun_struct *tun, u16 queue_index)
 
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
@@ -277,10 +280,11 @@ static void tun_flow_cleanup(unsigned long data)
 
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
@@ -307,7 +311,7 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
 	if (!rxhash)
 		return;
 	else
-		head = &tun->flows[tun_hashfn(rxhash)];
+		head = flex_array_get(tun->flows, tun_hashfn(rxhash));
 
 	rcu_read_lock();
 
@@ -356,7 +360,8 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb)
 
 	txq = skb_get_rxhash(skb);
 	if (txq) {
-		e = tun_flow_find(&tun->flows[tun_hashfn(txq)], txq);
+		e = tun_flow_find(flex_array_get(tun->flows, tun_hashfn(txq)),
+				  txq);
 		if (e)
 			txq = e->queue_index;
 		else
@@ -841,23 +846,45 @@ static const struct net_device_ops tap_netdev_ops = {
 #endif
 };
 
-static void tun_flow_init(struct tun_struct *tun)
+static int tun_flow_init(struct tun_struct *tun, bool mq)
 {
-	int i;
+	struct flex_array *buckets;
+	int i, err;
+
+	if (!mq)
+		return 0;
+
+	buckets = flex_array_alloc(sizeof(struct hlist_head),
+				TUN_NUM_FLOW_ENTRIES, GFP_KERNEL);
+	if (!buckets)
+		return -ENOMEM;
 
+	err = flex_array_prealloc(buckets, 0, TUN_NUM_FLOW_ENTRIES, GFP_KERNEL);
+	if (err) {
+		flex_array_free(buckets);
+		return -ENOMEM;
+	}
+
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
-	del_timer_sync(&tun->flow_gc_timer);
-	tun_flow_flush(tun);
+	if (tun->flags & TUN_TAP_MQ) {
+		del_timer_sync(&tun->flow_gc_timer);
+		tun_flow_flush(tun);
+		flex_array_free(tun->flows);
+	}
 }
 
 /* Initialize net device. */
@@ -1660,7 +1687,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			goto err_free_dev;
 
 		tun_net_init(dev);
-		tun_flow_init(tun);
+
+		err = tun_flow_init(tun, queues > 1);
+		if (err < 0)
+			goto err_free_dev;
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
 			TUN_USER_FEATURES;
diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 093c191..5787acc 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -241,7 +241,7 @@ static struct flex_array *alloc_buckets(unsigned int n_buckets)
 	struct flex_array *buckets;
 	int i, err;
 
-	buckets = flex_array_alloc(sizeof(struct hlist_head *),
+	buckets = flex_array_alloc(sizeof(struct hlist_head),
 				   n_buckets, GFP_KERNEL);
 	if (!buckets)
 		return NULL;
-- 
1.7.1
