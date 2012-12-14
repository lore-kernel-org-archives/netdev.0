From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH] tuntap: fix ambigious multiqueue API
Date: Fri, 14 Dec 2012 17:53:30 +0800
Message-ID: <1355478810-10144-1-git-send-email-jasowang@redhat.com>
Cc: mprivozn@redhat.com, wkevils@gmail.com,
	Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, pmoore@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The current multiqueue API is ambigious which may confuse both user and LSM to
do things correctly:

- Both TUNSETIFF and TUNSETQUEUE could be used to create the queues of a tuntap
  device.
- TUNSETQUEUE were used to disable and enable a specific queue of the
  device. But since the state of tuntap were completely removed from the queue,
  it could be used to attach to another device (there's no such kind of
  requirement currently, and it needs new kind of LSM policy.
- TUNSETQUEUE could be used to attach to a persistent device without any
  queues. This kind of attching bypass the necessary checking during TUNSETIFF
  and may lead unexpected result.

So this patch tries to make a cleaner and simpler API by:

- Only allow TUNSETIFF to create queues.
- TUNSETQUEUE could be only used to disable and enabled the queues of a device,
  and the state of the tuntap device were not detachd from the queues when it
  was disabled, so TUNSETQUEUE could be only used after TUNSETIFF and with the
   same device.

This is done by introducing a list which keeps track of all queues which were
disabled. The queue would be moved between this list and tfiles[] array when it
was enabled/disabled. A pointer of the tun_struct were also introdued to track
the device it belongs to when it was disabled.

After the change, the isolation between management and application could be done
through: TUNSETIFF were only called by management software and TUNSETQUEUE were
only called by application.For LSM/SELinux, the things left is to do proper
check during tun_set_queue() if needed.

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   86 ++++++++++++++++++++++++++++++++++++++--------------
 1 files changed, 63 insertions(+), 23 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2ac2164..6f2053d 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -138,6 +138,8 @@ struct tun_file {
 	/* only used for fasnyc */
 	unsigned int flags;
 	u16 queue_index;
+	struct list_head next;
+	struct tun_struct *detached;
 };
 
 struct tun_flow_entry {
@@ -182,6 +184,8 @@ struct tun_struct {
 	struct hlist_head flows[TUN_NUM_FLOW_ENTRIES];
 	struct timer_list flow_gc_timer;
 	unsigned long ageing_time;
+	unsigned int numdisabled;
+	struct list_head disabled;
 };
 
 static inline u32 tun_hashfn(u32 rxhash)
@@ -386,6 +390,23 @@ static void tun_set_real_num_queues(struct tun_struct *tun)
 	netif_set_real_num_rx_queues(tun->dev, tun->numqueues);
 }
 
+static void tun_disable_queue(struct tun_struct *tun, struct tun_file *tfile)
+{
+	tfile->detached = tun;
+	list_add_tail(&tfile->next, &tun->disabled);
+	++tun->numdisabled;
+}
+
+struct tun_struct *tun_enable_queue(struct tun_file *tfile)
+{
+	struct tun_struct *tun = tfile->detached;
+
+	tfile->detached = NULL;
+	list_del_init(&tfile->next);
+	--tun->numdisabled;
+	return tun;
+}
+
 static void __tun_detach(struct tun_file *tfile, bool clean)
 {
 	struct tun_file *ntfile;
@@ -407,20 +428,25 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		ntfile->queue_index = index;
 
 		--tun->numqueues;
-		sock_put(&tfile->sk);
+		if (clean)
+			sock_put(&tfile->sk);
+		else
+			tun_disable_queue(tun, tfile);
 
 		synchronize_net();
 		tun_flow_delete_by_queue(tun, tun->numqueues + 1);
 		/* Drop read queue */
 		skb_queue_purge(&tfile->sk.sk_receive_queue);
 		tun_set_real_num_queues(tun);
-
-		if (tun->numqueues == 0 && !(tun->flags & TUN_PERSIST))
-			if (dev->reg_state == NETREG_REGISTERED)
-				unregister_netdevice(dev);
-	}
+	} else if (tfile->detached && clean)
+		tun = tun_enable_queue(tfile);
 
 	if (clean) {
+		if (tun && tun->numqueues == 0 && tun->numdisabled == 0 &&
+		    !(tun->flags & TUN_PERSIST))
+			if (tun->dev->reg_state == NETREG_REGISTERED)
+				unregister_netdevice(tun->dev);
+
 		BUG_ON(!test_bit(SOCK_EXTERNALLY_ALLOCATED,
 				 &tfile->socket.flags));
 		sk_release_kernel(&tfile->sk);
@@ -437,7 +463,7 @@ static void tun_detach(struct tun_file *tfile, bool clean)
 static void tun_detach_all(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
-	struct tun_file *tfile;
+	struct tun_file *tfile, *tmp;
 	int i, n = tun->numqueues;
 
 	for (i = 0; i < n; i++) {
@@ -458,6 +484,12 @@ static void tun_detach_all(struct net_device *dev)
 		skb_queue_purge(&tfile->sk.sk_receive_queue);
 		sock_put(&tfile->sk);
 	}
+	list_for_each_entry_safe(tfile, tmp, &tun->disabled, next) {
+		tun_enable_queue(tfile);
+		skb_queue_purge(&tfile->sk.sk_receive_queue);
+		sock_put(&tfile->sk);
+	}
+	BUG_ON(tun->numdisabled != 0);
 }
 
 static int tun_attach(struct tun_struct *tun, struct file *file)
@@ -474,7 +506,8 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 		goto out;
 
 	err = -E2BIG;
-	if (tun->numqueues == MAX_TAP_QUEUES)
+	if (!tfile->detached &&
+	    tun->numqueues + tun->numdisabled == MAX_TAP_QUEUES)
 		goto out;
 
 	err = 0;
@@ -488,9 +521,13 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	tfile->queue_index = tun->numqueues;
 	rcu_assign_pointer(tfile->tun, tun);
 	rcu_assign_pointer(tun->tfiles[tun->numqueues], tfile);
-	sock_hold(&tfile->sk);
 	tun->numqueues++;
 
+	if (tfile->detached)
+		tun_enable_queue(tfile);
+	else
+		sock_hold(&tfile->sk);
+
 	tun_set_real_num_queues(tun);
 
 	/* device is allowed to go away first, so no need to hold extra
@@ -1348,6 +1385,7 @@ static void tun_free_netdev(struct net_device *dev)
 {
 	struct tun_struct *tun = netdev_priv(dev);
 
+	BUG_ON(!(list_empty(&tun->disabled)));
 	tun_flow_uninit(tun);
 	free_netdev(dev);
 }
@@ -1542,6 +1580,10 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		err = tun_attach(tun, file);
 		if (err < 0)
 			return err;
+
+		if (tun->flags & TUN_TAP_MQ &&
+		    (tun->numqueues + tun->numdisabled > 1))
+			return err;
 	}
 	else {
 		char *name;
@@ -1600,6 +1642,7 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 			TUN_USER_FEATURES;
 		dev->features = dev->hw_features;
 
+		INIT_LIST_HEAD(&tun->disabled);
 		err = tun_attach(tun, file);
 		if (err < 0)
 			goto err_free_dev;
@@ -1754,32 +1797,28 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 {
 	struct tun_file *tfile = file->private_data;
 	struct tun_struct *tun;
-	struct net_device *dev;
 	int ret = 0;
 
 	rtnl_lock();
 
 	if (ifr->ifr_flags & IFF_ATTACH_QUEUE) {
-		dev = __dev_get_by_name(tfile->net, ifr->ifr_name);
-		if (!dev) {
-			ret = -EINVAL;
-			goto unlock;
-		}
-
-		tun = netdev_priv(dev);
-		if (dev->netdev_ops != &tap_netdev_ops &&
-			dev->netdev_ops != &tun_netdev_ops)
+		tun = tfile->detached;
+		if (!tun)
 			ret = -EINVAL;
 		else if (tun_not_capable(tun))
 			ret = -EPERM;
 		else
 			ret = tun_attach(tun, file);
-	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE)
-		__tun_detach(tfile, false);
-	else
+	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
+		tun = rcu_dereference_protected(tfile->tun,
+						lockdep_rtnl_is_held());
+		if (!tun || !(tun->flags & TUN_TAP_MQ))
+			ret = -EINVAL;
+		else
+			__tun_detach(tfile, false);
+	} else
 		ret = -EINVAL;
 
-unlock:
 	rtnl_unlock();
 	return ret;
 }
@@ -2091,6 +2130,7 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 
 	file->private_data = tfile;
 	set_bit(SOCK_EXTERNALLY_ALLOCATED, &tfile->socket.flags);
+	INIT_LIST_HEAD(&tfile->next);
 
 	return 0;
 }
-- 
1.7.1
