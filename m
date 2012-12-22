From: David Miller <davem@davemloft.net>
Subject: Re: Regression in 3.8-rc1: "BUG: sleeping function called from
 invalid context"
Date: Sat, 22 Dec 2012 13:34:01 -0800 (PST)
Message-ID: <20121222.133401.716969975666083092.davem@davemloft.net>
References: <50D5E9D9.3070904@lwfinger.net>
	<20121222180247.GA10250@liondog.tnic>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Larry.Finger@lwfinger.net, linux-kernel@vger.kernel.org,
	cl@linux-foundation.org, penberg@kernel.org, netdev@vger.kernel.org
To: bp@alien8.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55022 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752071Ab2LVVeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Dec 2012 16:34:05 -0500
In-Reply-To: <20121222180247.GA10250@liondog.tnic>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Borislav Petkov <bp@alien8.de>
Date: Sat, 22 Dec 2012 19:02:47 +0100

> Top-posting so that the rest can remain untouched.

This bug is fixed in the 'net' tree already by commit:

>From 30e6c9fa93cf3dbc7cc6df1d748ad25e4264545a Mon Sep 17 00:00:00 2001
From: Eric Dumazet <edumazet@google.com>
Date: Thu, 20 Dec 2012 17:25:08 +0000
Subject: [PATCH 04/10] net: devnet_rename_seq should be a seqcount

Using a seqlock for devnet_rename_seq is not a good idea,
as device_rename() can sleep.

As we hold RTNL, we dont need a protection for writers,
and only need a seqcount so that readers can catch a change done
by a writer.

Bug added in commit c91f6df2db4972d3 (sockopt: Change getsockopt() of
SO_BINDTODEVICE to return an interface name)

Reported-by: Dave Jones <davej@redhat.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Brian Haley <brian.haley@hp.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h |  2 +-
 net/core/dev.c            | 18 +++++++++---------
 net/core/sock.c           |  4 ++--
 3 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 02e0f6b..c599e47 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1576,7 +1576,7 @@ extern int call_netdevice_notifiers(unsigned long val, struct net_device *dev);
 
 extern rwlock_t				dev_base_lock;		/* Device list lock */
 
-extern seqlock_t	devnet_rename_seq;	/* Device rename lock */
+extern seqcount_t	devnet_rename_seq;	/* Device rename seq */
 
 
 #define for_each_netdev(net, d)		\
diff --git a/net/core/dev.c b/net/core/dev.c
index d0cbc93..515473e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -203,7 +203,7 @@ static struct list_head offload_base __read_mostly;
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);
 
-DEFINE_SEQLOCK(devnet_rename_seq);
+seqcount_t devnet_rename_seq;
 
 static inline void dev_base_seq_inc(struct net *net)
 {
@@ -1093,10 +1093,10 @@ int dev_change_name(struct net_device *dev, const char *newname)
 	if (dev->flags & IFF_UP)
 		return -EBUSY;
 
-	write_seqlock(&devnet_rename_seq);
+	write_seqcount_begin(&devnet_rename_seq);
 
 	if (strncmp(newname, dev->name, IFNAMSIZ) == 0) {
-		write_sequnlock(&devnet_rename_seq);
+		write_seqcount_end(&devnet_rename_seq);
 		return 0;
 	}
 
@@ -1104,7 +1104,7 @@ int dev_change_name(struct net_device *dev, const char *newname)
 
 	err = dev_get_valid_name(net, dev, newname);
 	if (err < 0) {
-		write_sequnlock(&devnet_rename_seq);
+		write_seqcount_end(&devnet_rename_seq);
 		return err;
 	}
 
@@ -1112,11 +1112,11 @@ rollback:
 	ret = device_rename(&dev->dev, dev->name);
 	if (ret) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
-		write_sequnlock(&devnet_rename_seq);
+		write_seqcount_end(&devnet_rename_seq);
 		return ret;
 	}
 
-	write_sequnlock(&devnet_rename_seq);
+	write_seqcount_end(&devnet_rename_seq);
 
 	write_lock_bh(&dev_base_lock);
 	hlist_del_rcu(&dev->name_hlist);
@@ -1135,7 +1135,7 @@ rollback:
 		/* err >= 0 after dev_alloc_name() or stores the first errno */
 		if (err >= 0) {
 			err = ret;
-			write_seqlock(&devnet_rename_seq);
+			write_seqcount_begin(&devnet_rename_seq);
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			goto rollback;
 		} else {
@@ -4180,7 +4180,7 @@ static int dev_ifname(struct net *net, struct ifreq __user *arg)
 		return -EFAULT;
 
 retry:
-	seq = read_seqbegin(&devnet_rename_seq);
+	seq = read_seqcount_begin(&devnet_rename_seq);
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(net, ifr.ifr_ifindex);
 	if (!dev) {
@@ -4190,7 +4190,7 @@ retry:
 
 	strcpy(ifr.ifr_name, dev->name);
 	rcu_read_unlock();
-	if (read_seqretry(&devnet_rename_seq, seq))
+	if (read_seqcount_retry(&devnet_rename_seq, seq))
 		goto retry;
 
 	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
diff --git a/net/core/sock.c b/net/core/sock.c
index a692ef4..bc131d4 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -583,7 +583,7 @@ static int sock_getbindtodevice(struct sock *sk, char __user *optval,
 		goto out;
 
 retry:
-	seq = read_seqbegin(&devnet_rename_seq);
+	seq = read_seqcount_begin(&devnet_rename_seq);
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
 	ret = -ENODEV;
@@ -594,7 +594,7 @@ retry:
 
 	strcpy(devname, dev->name);
 	rcu_read_unlock();
-	if (read_seqretry(&devnet_rename_seq, seq))
+	if (read_seqcount_retry(&devnet_rename_seq, seq))
 		goto retry;
 
 	len = strlen(devname) + 1;
-- 
1.7.11.7
