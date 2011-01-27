From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] drivers/net: remove some rcu sparse warnings
Date: Thu, 27 Jan 2011 06:28:23 +0100
Message-ID: <1296106103.1783.114.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Arnd Bergmann <arnd@arndb.de>,
	Eilon Greenstein <eilong@broadcom.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63311 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750921Ab1A0F22 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Jan 2011 00:28:28 -0500
Received: by wwa36 with SMTP id 36so1791234wwa.1
        for <netdev@vger.kernel.org>; Wed, 26 Jan 2011 21:28:27 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add missing __rcu annotations and helpers.
minor : Fix some rcu_dereference() calls in macvtap

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Michael Chan <mchan@broadcom.com>
CC: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2.c              |    6 ++++--
 drivers/net/bnx2.h              |    2 +-
 drivers/net/bnx2x/bnx2x.h       |    2 +-
 drivers/net/bnx2x/bnx2x_main.c  |    3 ++-
 drivers/net/cnic.c              |   27 ++++++++++++++++++---------
 drivers/net/cnic.h              |    2 +-
 drivers/net/hamradio/bpqether.c |    5 +++--
 drivers/net/macvtap.c           |   18 ++++++++++--------
 8 files changed, 40 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 231aa97..2c3d747 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -435,7 +435,8 @@ bnx2_cnic_stop(struct bnx2 *bp)
 	struct cnic_ctl_info info;
 
 	mutex_lock(&bp->cnic_lock);
-	c_ops = bp->cnic_ops;
+	c_ops = rcu_dereference_protected(bp->cnic_ops,
+					  lockdep_is_held(&bp->cnic_lock));
 	if (c_ops) {
 		info.cmd = CNIC_CTL_STOP_CMD;
 		c_ops->cnic_ctl(bp->cnic_data, &info);
@@ -450,7 +451,8 @@ bnx2_cnic_start(struct bnx2 *bp)
 	struct cnic_ctl_info info;
 
 	mutex_lock(&bp->cnic_lock);
-	c_ops = bp->cnic_ops;
+	c_ops = rcu_dereference_protected(bp->cnic_ops,
+					  lockdep_is_held(&bp->cnic_lock));
 	if (c_ops) {
 		if (!(bp->flags & BNX2_FLAG_USING_MSIX)) {
 			struct bnx2_napi *bnapi = &bp->bnx2_napi[0];
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 5488a2e..6824eba 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6758,7 +6758,7 @@ struct bnx2 {
 	u32		tx_wake_thresh;
 
 #ifdef BCM_CNIC
-	struct cnic_ops		*cnic_ops;
+	struct cnic_ops	__rcu	*cnic_ops;
 	void			*cnic_data;
 #endif
 
diff --git a/drivers/net/bnx2x/bnx2x.h b/drivers/net/bnx2x/bnx2x.h
index 8e41837..dfdb9b5 100644
--- a/drivers/net/bnx2x/bnx2x.h
+++ b/drivers/net/bnx2x/bnx2x.h
@@ -1110,7 +1110,7 @@ struct bnx2x {
 #define BNX2X_CNIC_FLAG_MAC_SET		1
 	void			*t2;
 	dma_addr_t		t2_mapping;
-	struct cnic_ops		*cnic_ops;
+	struct cnic_ops	__rcu	*cnic_ops;
 	void			*cnic_data;
 	u32			cnic_tag;
 	struct cnic_eth_dev	cnic_eth_dev;
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 8cdcf5b..a2a1bc4 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -9862,7 +9862,8 @@ static int bnx2x_cnic_ctl_send(struct bnx2x *bp, struct cnic_ctl_info *ctl)
 	int rc = 0;
 
 	mutex_lock(&bp->cnic_mutex);
-	c_ops = bp->cnic_ops;
+	c_ops = rcu_dereference_protected(bp->cnic_ops,
+					  lockdep_is_held(&bp->cnic_mutex));
 	if (c_ops)
 		rc = c_ops->cnic_ctl(bp->cnic_data, ctl);
 	mutex_unlock(&bp->cnic_mutex);
diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 263a294..e12049e 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -65,7 +65,14 @@ static LIST_HEAD(cnic_udev_list);
 static DEFINE_RWLOCK(cnic_dev_lock);
 static DEFINE_MUTEX(cnic_lock);
 
-static struct cnic_ulp_ops *cnic_ulp_tbl[MAX_CNIC_ULP_TYPE];
+static struct cnic_ulp_ops __rcu *cnic_ulp_tbl[MAX_CNIC_ULP_TYPE];
+
+/* helper function, assuming cnic_lock is held */
+static inline struct cnic_ulp_ops *cnic_ulp_tbl_prot(int type)
+{
+	return rcu_dereference_protected(cnic_ulp_tbl[type],
+					 lockdep_is_held(&cnic_lock));
+}
 
 static int cnic_service_bnx2(void *, void *);
 static int cnic_service_bnx2x(void *, void *);
@@ -435,7 +442,7 @@ int cnic_register_driver(int ulp_type, struct cnic_ulp_ops *ulp_ops)
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
-	if (cnic_ulp_tbl[ulp_type]) {
+	if (cnic_ulp_tbl_prot(ulp_type)) {
 		pr_err("%s: Type %d has already been registered\n",
 		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
@@ -478,7 +485,7 @@ int cnic_unregister_driver(int ulp_type)
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
-	ulp_ops = cnic_ulp_tbl[ulp_type];
+	ulp_ops = cnic_ulp_tbl_prot(ulp_type);
 	if (!ulp_ops) {
 		pr_err("%s: Type %d has not been registered\n",
 		       __func__, ulp_type);
@@ -529,7 +536,7 @@ static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
 		return -EINVAL;
 	}
 	mutex_lock(&cnic_lock);
-	if (cnic_ulp_tbl[ulp_type] == NULL) {
+	if (cnic_ulp_tbl_prot(ulp_type) == NULL) {
 		pr_err("%s: Driver with type %d has not been registered\n",
 		       __func__, ulp_type);
 		mutex_unlock(&cnic_lock);
@@ -544,7 +551,7 @@ static int cnic_register_device(struct cnic_dev *dev, int ulp_type,
 
 	clear_bit(ULP_F_START, &cp->ulp_flags[ulp_type]);
 	cp->ulp_handle[ulp_type] = ulp_ctx;
-	ulp_ops = cnic_ulp_tbl[ulp_type];
+	ulp_ops = cnic_ulp_tbl_prot(ulp_type);
 	rcu_assign_pointer(cp->ulp_ops[ulp_type], ulp_ops);
 	cnic_hold(dev);
 
@@ -2953,7 +2960,8 @@ static void cnic_ulp_stop(struct cnic_dev *dev)
 		struct cnic_ulp_ops *ulp_ops;
 
 		mutex_lock(&cnic_lock);
-		ulp_ops = cp->ulp_ops[if_type];
+		ulp_ops = rcu_dereference_protected(cp->ulp_ops[if_type],
+						    lockdep_is_held(&cnic_lock));
 		if (!ulp_ops) {
 			mutex_unlock(&cnic_lock);
 			continue;
@@ -2977,7 +2985,8 @@ static void cnic_ulp_start(struct cnic_dev *dev)
 		struct cnic_ulp_ops *ulp_ops;
 
 		mutex_lock(&cnic_lock);
-		ulp_ops = cp->ulp_ops[if_type];
+		ulp_ops = rcu_dereference_protected(cp->ulp_ops[if_type],
+						    lockdep_is_held(&cnic_lock));
 		if (!ulp_ops || !ulp_ops->cnic_start) {
 			mutex_unlock(&cnic_lock);
 			continue;
@@ -3041,7 +3050,7 @@ static void cnic_ulp_init(struct cnic_dev *dev)
 		struct cnic_ulp_ops *ulp_ops;
 
 		mutex_lock(&cnic_lock);
-		ulp_ops = cnic_ulp_tbl[i];
+		ulp_ops = cnic_ulp_tbl_prot(i);
 		if (!ulp_ops || !ulp_ops->cnic_init) {
 			mutex_unlock(&cnic_lock);
 			continue;
@@ -3065,7 +3074,7 @@ static void cnic_ulp_exit(struct cnic_dev *dev)
 		struct cnic_ulp_ops *ulp_ops;
 
 		mutex_lock(&cnic_lock);
-		ulp_ops = cnic_ulp_tbl[i];
+		ulp_ops = cnic_ulp_tbl_prot(i);
 		if (!ulp_ops || !ulp_ops->cnic_exit) {
 			mutex_unlock(&cnic_lock);
 			continue;
diff --git a/drivers/net/cnic.h b/drivers/net/cnic.h
index b328f6c..4456260 100644
--- a/drivers/net/cnic.h
+++ b/drivers/net/cnic.h
@@ -220,7 +220,7 @@ struct cnic_local {
 #define ULP_F_INIT	0
 #define ULP_F_START	1
 #define ULP_F_CALL_PENDING	2
-	struct cnic_ulp_ops *ulp_ops[MAX_CNIC_ULP_TYPE];
+	struct cnic_ulp_ops __rcu *ulp_ops[MAX_CNIC_ULP_TYPE];
 
 	unsigned long cnic_local_flags;
 #define	CNIC_LCL_FL_KWQ_INIT		0x0
diff --git a/drivers/net/hamradio/bpqether.c b/drivers/net/hamradio/bpqether.c
index ac1d323..8931168 100644
--- a/drivers/net/hamradio/bpqether.c
+++ b/drivers/net/hamradio/bpqether.c
@@ -400,13 +400,14 @@ static void *bpq_seq_start(struct seq_file *seq, loff_t *pos)
 static void *bpq_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
 	struct list_head *p;
+	struct bpqdev *bpqdev = v;
 
 	++*pos;
 
 	if (v == SEQ_START_TOKEN)
-		p = rcu_dereference(bpq_devices.next);
+		p = rcu_dereference(list_next_rcu(&bpq_devices));
 	else
-		p = rcu_dereference(((struct bpqdev *)v)->bpq_list.next);
+		p = rcu_dereference(list_next_rcu(&bpqdev->bpq_list));
 
 	return (p == &bpq_devices) ? NULL 
 		: list_entry(p, struct bpqdev, bpq_list);
diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 5933621..2300e45 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -39,7 +39,7 @@ struct macvtap_queue {
 	struct socket sock;
 	struct socket_wq wq;
 	int vnet_hdr_sz;
-	struct macvlan_dev *vlan;
+	struct macvlan_dev __rcu *vlan;
 	struct file *file;
 	unsigned int flags;
 };
@@ -141,7 +141,8 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 	struct macvlan_dev *vlan;
 
 	spin_lock(&macvtap_lock);
-	vlan = rcu_dereference(q->vlan);
+	vlan = rcu_dereference_protected(q->vlan,
+					 lockdep_is_held(&macvtap_lock));
 	if (vlan) {
 		int index = get_slot(vlan, q);
 
@@ -219,7 +220,8 @@ static void macvtap_del_queues(struct net_device *dev)
 	/* macvtap_put_queue can free some slots, so go through all slots */
 	spin_lock(&macvtap_lock);
 	for (i = 0; i < MAX_MACVTAP_QUEUES && vlan->numvtaps; i++) {
-		q = rcu_dereference(vlan->taps[i]);
+		q = rcu_dereference_protected(vlan->taps[i],
+					      lockdep_is_held(&macvtap_lock));
 		if (q) {
 			qlist[j++] = q;
 			rcu_assign_pointer(vlan->taps[i], NULL);
@@ -569,7 +571,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q,
 	}
 
 	rcu_read_lock_bh();
-	vlan = rcu_dereference(q->vlan);
+	vlan = rcu_dereference_bh(q->vlan);
 	if (vlan)
 		macvlan_start_xmit(skb, vlan->dev);
 	else
@@ -583,7 +585,7 @@ err_kfree:
 
 err:
 	rcu_read_lock_bh();
-	vlan = rcu_dereference(q->vlan);
+	vlan = rcu_dereference_bh(q->vlan);
 	if (vlan)
 		vlan->dev->stats.tx_dropped++;
 	rcu_read_unlock_bh();
@@ -631,7 +633,7 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	ret = skb_copy_datagram_const_iovec(skb, 0, iv, vnet_hdr_len, len);
 
 	rcu_read_lock_bh();
-	vlan = rcu_dereference(q->vlan);
+	vlan = rcu_dereference_bh(q->vlan);
 	if (vlan)
 		macvlan_count_rx(vlan, len, ret == 0, 0);
 	rcu_read_unlock_bh();
@@ -727,7 +729,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 
 	case TUNGETIFF:
 		rcu_read_lock_bh();
-		vlan = rcu_dereference(q->vlan);
+		vlan = rcu_dereference_bh(q->vlan);
 		if (vlan)
 			dev_hold(vlan->dev);
 		rcu_read_unlock_bh();
@@ -736,7 +738,7 @@ static long macvtap_ioctl(struct file *file, unsigned int cmd,
 			return -ENOLINK;
 
 		ret = 0;
-		if (copy_to_user(&ifr->ifr_name, q->vlan->dev->name, IFNAMSIZ) ||
+		if (copy_to_user(&ifr->ifr_name, vlan->dev->name, IFNAMSIZ) ||
 		    put_user(q->flags, &ifr->ifr_flags))
 			ret = -EFAULT;
 		dev_put(vlan->dev);


