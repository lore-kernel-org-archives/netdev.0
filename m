From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 3/3] tuntap: allow polling/writing/reading when detached
Date: Tue, 15 Jan 2013 18:28:46 +0800
Message-ID: <1358245726-16250-4-git-send-email-jasowang@redhat.com>
References: <1358245726-16250-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>
To: mst@redhat.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358245726-16250-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We forbid polling, writing and reading when the file were detached, this may
complex the user in several cases:

- when guest pass some buffers to vhost/qemu and then disable some queues,
  vhost/qemu needs to to its own cleanup which is complex. We can do this simply
  by allowing a user can still write to an disabled queue to handle this. And
  user can still do read but just nothing returned.
- align the polling behavior with macvtap which never fails when the queue is
  created. this can simplify the polling errors handling of its user (e.g vhost)

Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   18 +++++++++++-------
 1 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index af372d0..eb68937 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -307,7 +307,7 @@ static void tun_flow_update(struct tun_struct *tun, u32 rxhash,
 
 	rcu_read_lock();
 
-	if (tun->numqueues == 1)
+	if (tun->numqueues == 1 || queue_index >= tun->numqueues)
 		goto unlock;
 
 	e = tun_flow_find(head, rxhash);
@@ -406,21 +406,21 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 
 	tun = rtnl_dereference(tfile->tun);
 
-	if (tun) {
+	if (tun && !tfile->detached) {
 		u16 index = tfile->queue_index;
 		BUG_ON(index >= tun->numqueues);
 		dev = tun->dev;
 
 		rcu_assign_pointer(tun->tfiles[index],
 				   tun->tfiles[tun->numqueues - 1]);
-		rcu_assign_pointer(tfile->tun, NULL);
 		ntfile = rtnl_dereference(tun->tfiles[index]);
 		ntfile->queue_index = index;
 
 		--tun->numqueues;
-		if (clean)
+		if (clean) {
+			rcu_assign_pointer(tfile->tun, NULL);
 			sock_put(&tfile->sk);
-		else
+		} else
 			tun_disable_queue(tun, tfile);
 
 		synchronize_net();
@@ -465,6 +465,10 @@ static void tun_detach_all(struct net_device *dev)
 		rcu_assign_pointer(tfile->tun, NULL);
 		--tun->numqueues;
 	}
+	list_for_each_entry(tfile, &tun->disabled, next) {
+		wake_up_all(&tfile->wq.wait);
+		rcu_assign_pointer(tfile->tun, NULL);
+	}
 	BUG_ON(tun->numqueues != 0);
 
 	synchronize_net();
@@ -491,7 +495,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	int err;
 
 	err = -EINVAL;
-	if (rtnl_dereference(tfile->tun))
+	if (rtnl_dereference(tfile->tun) && !tfile->detached)
 		goto out;
 
 	err = -EBUSY;
@@ -1795,7 +1799,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 			ret = tun_attach(tun, file);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
 		tun = rtnl_dereference(tfile->tun);
-		if (!tun || !(tun->flags & TUN_TAP_MQ))
+		if (!tun || !(tun->flags & TUN_TAP_MQ) || tfile->detached)
 			ret = -EINVAL;
 		else
 			__tun_detach(tfile, false);
-- 
1.7.1
