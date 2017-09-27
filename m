From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 1/3] tun: abstract flow steering logic
Date: Wed, 27 Sep 2017 16:23:55 +0800
Message-ID: <1506500637-13881-2-git-send-email-jasowang@redhat.com>
References: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1506500637-13881-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

tun now use flow caches based automatic queue steering method. This
may not suffice all user cases. To extend it to be able to use more
flow steering policy, this patch abstracts flow steering logic into
tun_steering_ops, then we can declare and use different methods in
the future.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c | 85 +++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 63 insertions(+), 22 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2c36f6e..de83e72 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -181,6 +181,14 @@ struct tun_file {
 	struct skb_array tx_array;
 };
 
+struct tun_steering_ops {
+	u16 (*select_queue) (struct tun_struct *tun, struct sk_buff *skb);
+	void (*xmit) (struct tun_struct *tun, struct sk_buff *skb);
+	u32 (*pre_rx) (struct tun_struct *tun, struct sk_buff *skb);
+	void (*post_rx) (struct tun_struct *tun, struct tun_file *tfile,
+			 u32 data);
+};
+
 struct tun_flow_entry {
 	struct hlist_node hash_link;
 	struct rcu_head rcu;
@@ -231,6 +239,7 @@ struct tun_struct {
 	u32 rx_batched;
 	struct tun_pcpu_stats __percpu *pcpu_stats;
 	struct bpf_prog __rcu *xdp_prog;
+	struct tun_steering_ops *steering_ops;
 };
 
 static int tun_napi_receive(struct napi_struct *napi, int budget)
@@ -532,10 +541,8 @@ static inline void tun_flow_save_rps_rxhash(struct tun_flow_entry *e, u32 hash)
  * different rxq no. here. If we could not get rxhash, then we would
  * hope the rxq no. may help here.
  */
-static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
-			    void *accel_priv, select_queue_fallback_t fallback)
+static u16 tun_automq_select_queue(struct tun_struct *tun, struct sk_buff *skb)
 {
-	struct tun_struct *tun = netdev_priv(dev);
 	struct tun_flow_entry *e;
 	u32 txq = 0;
 	u32 numqueues = 0;
@@ -559,9 +566,18 @@ static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
 	}
 
 	rcu_read_unlock();
+
 	return txq;
 }
 
+static u16 tun_select_queue(struct net_device *dev, struct sk_buff *skb,
+			    void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+
+	return tun->steering_ops->select_queue(tun, skb);
+}
+
 static inline bool tun_not_capable(struct tun_struct *tun)
 {
 	const struct cred *cred = current_cred();
@@ -931,24 +947,10 @@ static int tun_net_close(struct net_device *dev)
 	return 0;
 }
 
-/* Net device start xmit */
-static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
+static void tun_automq_xmit(struct tun_struct *tun, struct sk_buff *skb)
 {
-	struct tun_struct *tun = netdev_priv(dev);
-	int txq = skb->queue_mapping;
-	struct tun_file *tfile;
-	u32 numqueues = 0;
-
-	rcu_read_lock();
-	tfile = rcu_dereference(tun->tfiles[txq]);
-	numqueues = ACCESS_ONCE(tun->numqueues);
-
-	/* Drop packet if interface is not attached */
-	if (txq >= numqueues)
-		goto drop;
-
 #ifdef CONFIG_RPS
-	if (numqueues == 1 && static_key_false(&rps_needed)) {
+	if (ACCESS_ONCE(tun->numqueues) == 1 && static_key_false(&rps_needed)) {
 		/* Select queue was not called for the skbuff, so we extract the
 		 * RPS hash and save it into the flow_table here.
 		 */
@@ -964,6 +966,25 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 		}
 	}
 #endif
+}
+
+/* Net device start xmit */
+static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct tun_struct *tun = netdev_priv(dev);
+	int txq = skb->queue_mapping;
+	struct tun_file *tfile;
+	u32 numqueues = 0;
+
+	rcu_read_lock();
+	tfile = rcu_dereference(tun->tfiles[txq]);
+	numqueues = ACCESS_ONCE(tun->numqueues);
+
+	/* Drop packet if interface is not attached */
+	if (txq >= numqueues)
+		goto drop;
+
+	tun->steering_ops->xmit(tun, skb);
 
 	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
 
@@ -1527,6 +1548,17 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 	return NULL;
 }
 
+u32 tun_automq_pre_rx(struct tun_struct *tun, struct sk_buff *skb)
+{
+	return __skb_get_hash_symmetric(skb);
+}
+
+void tun_automq_post_rx(struct tun_struct *tun, struct tun_file *tfile,
+			u32 rxhash)
+{
+	tun_flow_update(tun, rxhash, tfile);
+}
+
 /* Get packet from user space buffer */
 static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 			    void *msg_control, struct iov_iter *from,
@@ -1542,7 +1574,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	int copylen;
 	bool zerocopy = false;
 	int err;
-	u32 rxhash;
+	u32 data;
 	int skb_xdp = 1;
 	bool frags = tun_napi_frags_enabled(tun);
 
@@ -1728,7 +1760,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 		rcu_read_unlock();
 	}
 
-	rxhash = __skb_get_hash_symmetric(skb);
+	data = tun->steering_ops->pre_rx(tun, skb);
 
 	if (frags) {
 		/* Exercise flow dissector code path. */
@@ -1772,7 +1804,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	u64_stats_update_end(&stats->syncp);
 	put_cpu_ptr(stats);
 
-	tun_flow_update(tun, rxhash, tfile);
+	tun->steering_ops->post_rx(tun, tfile, data);
 	return total_len;
 }
 
@@ -2112,6 +2144,13 @@ static struct proto tun_proto = {
 	.obj_size	= sizeof(struct tun_file),
 };
 
+static struct tun_steering_ops tun_automq_ops = {
+	.select_queue = tun_automq_select_queue,
+	.xmit = tun_automq_xmit,
+	.pre_rx = tun_automq_pre_rx,
+	.post_rx = tun_automq_post_rx,
+};
+
 static int tun_flags(struct tun_struct *tun)
 {
 	return tun->flags & (TUN_FEATURES | IFF_PERSIST | IFF_TUN | IFF_TAP);
@@ -2268,6 +2307,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			goto err_free_dev;
 		}
 
+		tun->steering_ops = &tun_automq_ops;
+
 		spin_lock_init(&tun->lock);
 
 		err = security_tun_dev_alloc_security(&tun->security);
-- 
2.7.4
