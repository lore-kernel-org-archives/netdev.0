From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: sock_ioctl sleeping while atomic warning during boot.
Date: Thu, 20 Dec 2012 19:25:08 -0800
Message-ID: <1356060308.21834.4455.camel@edumazet-glaptop>
References: <20121221022409.GA1927@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Brian Haley <brian.haley@hp.com>
To: Dave Jones <davej@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:54763 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750908Ab2LUDZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 22:25:12 -0500
Received: by mail-pa0-f42.google.com with SMTP id rl6so2517206pac.15
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 19:25:11 -0800 (PST)
In-Reply-To: <20121221022409.GA1927@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

On Thu, 2012-12-20 at 21:24 -0500, Dave Jones wrote:
> Seen on Linus tree as of 810a4855513b9cb1a191301eb5e4e28b276cc318
> 
> 
>  BUG: sleeping function called from invalid context at mm/slub.c:925
>  in_atomic(): 1, irqs_disabled(): 0, pid: 364, name: systemd-udevd
>  2 locks on stack by systemd-udevd/364:
>   #0: held:     (rtnl_mutex){+.+.+.}, instance: ffffffff81d1c038, at: [<ffffffff815d82d7>] rtnl_lock+0x17/0x20
>   #1: held:     (devnet_rename_seq){+.+.+.}, instance: ffffffff81d1ba60, at: [<ffffffff815c9737>] dev_change_name+0x67/0x2a0
>  Pid: 364, comm: systemd-udevd Not tainted 3.7.0+ #32
>  Call Trace:
>   [<ffffffff810a892b>] __might_sleep+0x14b/0x210
>   [<ffffffff811ce833>] __kmalloc_track_caller+0x63/0x2d0
>   [<ffffffff8146810f>] ? device_rename+0x5f/0x130
>   [<ffffffff8119190a>] kstrdup+0x3a/0x70
>   [<ffffffff8146810f>] device_rename+0x5f/0x130
>   [<ffffffff815c97d3>] dev_change_name+0x103/0x2a0
>   [<ffffffff815cb851>] dev_ifsioc+0x251/0x3b0
>   [<ffffffff815cbb5b>] dev_ioctl+0x1ab/0x840
>   [<ffffffff81367588>] ? __const_udelay+0x28/0x30
>   [<ffffffff812f7a49>] ? avc_has_perm_flags+0x29/0x2b0
>   [<ffffffff815aa86d>] sock_do_ioctl+0x5d/0x70
>   [<ffffffff815aa8fd>] sock_ioctl+0x7d/0x2c0
>   [<ffffffff812f9d05>] ? inode_has_perm.isra.47.constprop.60+0x65/0xa0
>   [<ffffffff811f1079>] do_vfs_ioctl+0x99/0x5a0
>   [<ffffffff812f9dd7>] ? file_has_perm+0x97/0xb0
>   [<ffffffff811f1611>] sys_ioctl+0x91/0xb0
>   [<ffffffff81711480>] tracesys+0xdd/0xe2
>  systemd-udevd[364]: renamed network interface eth0 to p6p1
> 
> --

OK, thanks for the report.

We need a seqcount, not a seqlock, as RTNL already protects multiple
writers.

Please try following fix :


[PATCH] net: devnet_rename_seq should be a seqcount

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
---
 include/linux/netdevice.h |    2 +-
 net/core/dev.c            |   18 +++++++++---------
 net/core/sock.c           |    4 ++--
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
index d0cbc93..26d73e2 100644
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
