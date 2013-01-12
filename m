From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 1/3] tuntap: switch to use rtnl_dereference()
Date: Sat, 12 Jan 2013 10:59:32 +0800
Message-ID: <1357959574-13113-2-git-send-email-jasowang@redhat.com>
References: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Cc: edumazet@google.com, stefanha@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1357959574-13113-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Switch to use rtnl_dereference() instead of the open code, suggested by Eric.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   27 ++++++++++-----------------
 1 files changed, 10 insertions(+), 17 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 99b58d8..aa963c4 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -404,8 +404,8 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 	struct tun_struct *tun;
 	struct net_device *dev;
 
-	tun = rcu_dereference_protected(tfile->tun,
-					lockdep_rtnl_is_held());
+	tun = rtnl_dereference(tfile->tun);
+
 	if (tun) {
 		u16 index = tfile->queue_index;
 		BUG_ON(index >= tun->numqueues);
@@ -414,8 +414,7 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		rcu_assign_pointer(tun->tfiles[index],
 				   tun->tfiles[tun->numqueues - 1]);
 		rcu_assign_pointer(tfile->tun, NULL);
-		ntfile = rcu_dereference_protected(tun->tfiles[index],
-						   lockdep_rtnl_is_held());
+		ntfile = rtnl_dereference(tun->tfiles[index]);
 		ntfile->queue_index = index;
 
 		--tun->numqueues;
@@ -458,8 +457,7 @@ static void tun_detach_all(struct net_device *dev)
 	int i, n = tun->numqueues;
 
 	for (i = 0; i < n; i++) {
-		tfile = rcu_dereference_protected(tun->tfiles[i],
-						  lockdep_rtnl_is_held());
+		tfile = rtnl_dereference(tun->tfiles[i]);
 		BUG_ON(!tfile);
 		wake_up_all(&tfile->wq.wait);
 		rcu_assign_pointer(tfile->tun, NULL);
@@ -469,8 +467,7 @@ static void tun_detach_all(struct net_device *dev)
 
 	synchronize_net();
 	for (i = 0; i < n; i++) {
-		tfile = rcu_dereference_protected(tun->tfiles[i],
-						  lockdep_rtnl_is_held());
+		tfile = rtnl_dereference(tun->tfiles[i]);
 		/* Drop read queue */
 		skb_queue_purge(&tfile->sk.sk_receive_queue);
 		sock_put(&tfile->sk);
@@ -489,7 +486,7 @@ static int tun_attach(struct tun_struct *tun, struct file *file)
 	int err;
 
 	err = -EINVAL;
-	if (rcu_dereference_protected(tfile->tun, lockdep_rtnl_is_held()))
+	if (rtnl_dereference(tfile->tun))
 		goto out;
 	if (tfile->detached && tun != tfile->detached)
 		goto out;
@@ -1740,8 +1737,7 @@ static void tun_detach_filter(struct tun_struct *tun, int n)
 	struct tun_file *tfile;
 
 	for (i = 0; i < n; i++) {
-		tfile = rcu_dereference_protected(tun->tfiles[i],
-						  lockdep_rtnl_is_held());
+		tfile = rtnl_dereference(tun->tfiles[i]);
 		sk_detach_filter(tfile->socket.sk);
 	}
 
@@ -1754,8 +1750,7 @@ static int tun_attach_filter(struct tun_struct *tun)
 	struct tun_file *tfile;
 
 	for (i = 0; i < tun->numqueues; i++) {
-		tfile = rcu_dereference_protected(tun->tfiles[i],
-						  lockdep_rtnl_is_held());
+		tfile = rtnl_dereference(tun->tfiles[i]);
 		ret = sk_attach_filter(&tun->fprog, tfile->socket.sk);
 		if (ret) {
 			tun_detach_filter(tun, i);
@@ -1773,8 +1768,7 @@ static void tun_set_sndbuf(struct tun_struct *tun)
 	int i;
 
 	for (i = 0; i < tun->numqueues; i++) {
-		tfile = rcu_dereference_protected(tun->tfiles[i],
-						lockdep_rtnl_is_held());
+		tfile = rtnl_dereference(tun->tfiles[i]);
 		tfile->socket.sk->sk_sndbuf = tun->sndbuf;
 	}
 }
@@ -1794,8 +1788,7 @@ static int tun_set_queue(struct file *file, struct ifreq *ifr)
 		else
 			ret = tun_attach(tun, file);
 	} else if (ifr->ifr_flags & IFF_DETACH_QUEUE) {
-		tun = rcu_dereference_protected(tfile->tun,
-						lockdep_rtnl_is_held());
+		tun = rtnl_dereference(tfile->tun);
 		if (!tun || !(tun->flags & TUN_TAP_MQ))
 			ret = -EINVAL;
 		else
-- 
1.7.1
