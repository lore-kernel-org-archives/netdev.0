From: Nicolas Schichan <nschichan@freebox.fr>
Subject: [PATCH v3.10-rc7] net: fix kernel deadlock with interface rename and netdev name retrieval.
Date: Wed, 26 Jun 2013 17:23:42 +0200
Message-ID: <1372260222-8597-1-git-send-email-nschichan@freebox.fr>
Cc: Eric Dumazet <edumazet@google.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	Nicolas Schichan <nschichan@freebox.fr>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When the kernel (compiled with CONFIG_PREEMPT=n) is performing the
rename of a network interface, it can end up waiting for a workqueue
to complete. If userland is able to invoke a SIOCGIFNAME ioctl or a
SO_BINDTODEVICE getsockopt in between, the kernel will deadlock due to
the fact that read_secklock_begin() will spin forever waiting for the
writer process (the one doing the interface rename) to update the
devnet_rename_seq sequence.

This patch fixes the problem by adding a helper (netdev_get_name())
and using it in the code handling the SIOCGIFNAME ioctl and
SO_BINDTODEVICE setsockopt.

The netdev_get_name() helper uses raw_seqcount_begin() to avoid
spinning forever, waiting for devnet_rename_seq->sequence to become
even. cond_resched() is used in the contended case, before retrying
the access to give the writer process a chance to finish.

The use of raw_seqcount_begin() will incur some unneeded work in the
reader process in the contended case, but this is better than
deadlocking the system.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
---
 include/linux/netdevice.h |    1 +
 net/core/dev.c            |   34 ++++++++++++++++++++++++++++++++++
 net/core/dev_ioctl.c      |   19 ++++---------------
 net/core/sock.c           |   17 ++---------------
 4 files changed, 41 insertions(+), 30 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 60584b1..96e4c21 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1695,6 +1695,7 @@ extern int		init_dummy_netdev(struct net_device *dev);
 extern struct net_device	*dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*__dev_get_by_index(struct net *net, int ifindex);
 extern struct net_device	*dev_get_by_index_rcu(struct net *net, int ifindex);
+extern int		netdev_get_name(struct net *net, char *name, int ifindex);
 extern int		dev_restart(struct net_device *dev);
 #ifdef CONFIG_NETPOLL_TRAP
 extern int		netpoll_trap(void);
diff --git a/net/core/dev.c b/net/core/dev.c
index fc1e289..faebb39 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -792,6 +792,40 @@ struct net_device *dev_get_by_index(struct net *net, int ifindex)
 EXPORT_SYMBOL(dev_get_by_index);
 
 /**
+ *	netdev_get_name - get a netdevice name, knowing its ifindex.
+ *	@net: network namespace
+ *	@name: a pointer to the buffer where the name will be stored.
+ *	@ifindex: the ifindex of the interface to get the name from.
+ *
+ *	The use of raw_seqcount_begin() and cond_resched() before
+ *	retrying is required as we want to give the writers a chance
+ *	to complete when CONFIG_PREEMPT is not set.
+ */
+int netdev_get_name(struct net *net, char *name, int ifindex)
+{
+	struct net_device *dev;
+	unsigned int seq;
+
+retry:
+	seq = raw_seqcount_begin(&devnet_rename_seq);
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, ifindex);
+	if (!dev) {
+		rcu_read_unlock();
+		return -ENODEV;
+	}
+
+	strcpy(name, dev->name);
+	rcu_read_unlock();
+	if (read_seqcount_retry(&devnet_rename_seq, seq)) {
+		cond_resched();
+		goto retry;
+	}
+
+	return 0;
+}
+
+/**
  *	dev_getbyhwaddr_rcu - find a device by its hardware address
  *	@net: the applicable net namespace
  *	@type: media type of device
diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 6cc0481..5b7d0e1 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -19,9 +19,8 @@
 
 static int dev_ifname(struct net *net, struct ifreq __user *arg)
 {
-	struct net_device *dev;
 	struct ifreq ifr;
-	unsigned seq;
+	int error;
 
 	/*
 	 *	Fetch the caller's info block.
@@ -30,19 +29,9 @@ static int dev_ifname(struct net *net, struct ifreq __user *arg)
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;
 
-retry:
-	seq = read_seqcount_begin(&devnet_rename_seq);
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, ifr.ifr_ifindex);
-	if (!dev) {
-		rcu_read_unlock();
-		return -ENODEV;
-	}
-
-	strcpy(ifr.ifr_name, dev->name);
-	rcu_read_unlock();
-	if (read_seqcount_retry(&devnet_rename_seq, seq))
-		goto retry;
+	error = netdev_get_name(net, ifr.ifr_name, ifr.ifr_ifindex);
+	if (error)
+		return error;
 
 	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
 		return -EFAULT;
diff --git a/net/core/sock.c b/net/core/sock.c
index 88868a9..d6d024c 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -571,9 +571,7 @@ static int sock_getbindtodevice(struct sock *sk, char __user *optval,
 	int ret = -ENOPROTOOPT;
 #ifdef CONFIG_NETDEVICES
 	struct net *net = sock_net(sk);
-	struct net_device *dev;
 	char devname[IFNAMSIZ];
-	unsigned seq;
 
 	if (sk->sk_bound_dev_if == 0) {
 		len = 0;
@@ -584,20 +582,9 @@ static int sock_getbindtodevice(struct sock *sk, char __user *optval,
 	if (len < IFNAMSIZ)
 		goto out;
 
-retry:
-	seq = read_seqcount_begin(&devnet_rename_seq);
-	rcu_read_lock();
-	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
-	ret = -ENODEV;
-	if (!dev) {
-		rcu_read_unlock();
+	ret = netdev_get_name(net, devname, sk->sk_bound_dev_if);
+	if (ret)
 		goto out;
-	}
-
-	strcpy(devname, dev->name);
-	rcu_read_unlock();
-	if (read_seqcount_retry(&devnet_rename_seq, seq))
-		goto retry;
 
 	len = strlen(devname) + 1;
 
-- 
1.7.10.4
