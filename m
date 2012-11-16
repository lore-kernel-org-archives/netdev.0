From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH v2 net-next] sockopt: Change getsockopt() of SO_BINDTODEVICE
 to return an interface name
Date: Fri, 16 Nov 2012 15:58:35 -0500
Message-ID: <50A6A8FB.3050901@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@parallels.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:40470 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753387Ab2KPU7D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 15:59:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
will then require another call like if_indextoname() to get the actual interface
name, have it return the name directly.

This also matches the existing man page description on socket(7) which mentions
the argument being an interface name.

If the value has not been set, zero is returned and optlen will be set to zero
to indicate there is no interface name present.

Added a seqlock to protect this code path, and dev_ifname(), from someone
changing the device name via dev_change_name().

v2: Added seqlock protection while copying device name.

Signed-off-by: Brian Haley <brian.haley@hp.com>

--

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index e46c830..e9929ab 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1567,6 +1567,8 @@ extern int call_netdevice_notifiers(unsigned long val,
struct net_device *dev);

 extern rwlock_t				dev_base_lock;		/* Device list lock */

+extern seqlock_t	devnet_rename_seq;	/* Device rename lock */
+

 #define for_each_netdev(net, d)		\
 		list_for_each_entry(d, &(net)->dev_base_head, dev_list)
diff --git a/net/core/dev.c b/net/core/dev.c
index 2705a2a..3a576ed 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -203,6 +203,8 @@ static struct list_head offload_base __read_mostly;
 DEFINE_RWLOCK(dev_base_lock);
 EXPORT_SYMBOL(dev_base_lock);

+DEFINE_SEQLOCK(devnet_rename_seq);
+
 static inline void dev_base_seq_inc(struct net *net)
 {
 	while (++net->dev_base_seq == 0);
@@ -1091,22 +1093,31 @@ int dev_change_name(struct net_device *dev, const char
*newname)
 	if (dev->flags & IFF_UP)
 		return -EBUSY;

-	if (strncmp(newname, dev->name, IFNAMSIZ) == 0)
+	write_seqlock(&devnet_rename_seq);
+
+	if (strncmp(newname, dev->name, IFNAMSIZ) == 0) {
+		write_sequnlock(&devnet_rename_seq);
 		return 0;
+	}

 	memcpy(oldname, dev->name, IFNAMSIZ);

 	err = dev_get_valid_name(net, dev, newname);
-	if (err < 0)
+	if (err < 0) {
+		write_sequnlock(&devnet_rename_seq);
 		return err;
+	}

 rollback:
 	ret = device_rename(&dev->dev, dev->name);
 	if (ret) {
 		memcpy(dev->name, oldname, IFNAMSIZ);
+		write_sequnlock(&devnet_rename_seq);
 		return ret;
 	}

+	write_sequnlock(&devnet_rename_seq);
+
 	write_lock_bh(&dev_base_lock);
 	hlist_del_rcu(&dev->name_hlist);
 	write_unlock_bh(&dev_base_lock);
@@ -1124,6 +1135,7 @@ rollback:
 		/* err >= 0 after dev_alloc_name() or stores the first errno */
 		if (err >= 0) {
 			err = ret;
+			write_seqlock(&devnet_rename_seq);
 			memcpy(dev->name, oldname, IFNAMSIZ);
 			goto rollback;
 		} else {
@@ -4148,6 +4160,7 @@ static int dev_ifname(struct net *net, struct ifreq __user
*arg)
 {
 	struct net_device *dev;
 	struct ifreq ifr;
+	unsigned seq;

 	/*
 	 *	Fetch the caller's info block.
@@ -4156,6 +4169,8 @@ static int dev_ifname(struct net *net, struct ifreq __user
*arg)
 	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
 		return -EFAULT;

+retry:
+	seq = read_seqbegin(&devnet_rename_seq);
 	rcu_read_lock();
 	dev = dev_get_by_index_rcu(net, ifr.ifr_ifindex);
 	if (!dev) {
@@ -4165,6 +4180,8 @@ static int dev_ifname(struct net *net, struct ifreq __user
*arg)

 	strcpy(ifr.ifr_name, dev->name);
 	rcu_read_unlock();
+	if (read_seqretry(&devnet_rename_seq, seq))
+		goto retry;

 	if (copy_to_user(arg, &ifr, sizeof(struct ifreq)))
 		return -EFAULT;
diff --git a/net/core/sock.c b/net/core/sock.c
index 0628600..f2a42e3 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -505,7 +505,8 @@ struct dst_entry *sk_dst_check(struct sock *sk, u32 cookie)
 }
 EXPORT_SYMBOL(sk_dst_check);

-static int sock_bindtodevice(struct sock *sk, char __user *optval, int optlen)
+static int sock_setbindtodevice(struct sock *sk, char __user *optval,
+				int optlen)
 {
 	int ret = -ENOPROTOOPT;
 #ifdef CONFIG_NETDEVICES
@@ -562,6 +563,59 @@ out:
 	return ret;
 }

+static int sock_getbindtodevice(struct sock *sk, char __user *optval,
+				int __user *optlen, int len)
+{
+	int ret = -ENOPROTOOPT;
+#ifdef CONFIG_NETDEVICES
+	struct net *net = sock_net(sk);
+	struct net_device *dev;
+	char devname[IFNAMSIZ];
+	unsigned seq;
+
+	if (sk->sk_bound_dev_if == 0) {
+		len = 0;
+		goto zero;
+	}
+
+	ret = -EINVAL;
+	if (len < IFNAMSIZ)
+		goto out;
+
+retry:
+	seq = read_seqbegin(&devnet_rename_seq);
+	rcu_read_lock();
+	dev = dev_get_by_index_rcu(net, sk->sk_bound_dev_if);
+	ret = -ENODEV;
+	if (!dev) {
+		rcu_read_unlock();
+		goto out;
+	}
+
+	strcpy(devname, dev->name);
+	rcu_read_unlock();
+	if (read_seqretry(&devnet_rename_seq, seq))
+		goto retry;
+
+	len = strlen(devname) + 1;
+
+	ret = -EFAULT;
+	if (copy_to_user(optval, devname, len))
+		goto out;
+
+zero:
+	ret = -EFAULT;
+	if (put_user(len, optlen))
+		goto out;
+
+	ret = 0;
+
+out:
+#endif
+
+	return ret;
+}
+
 static inline void sock_valbool_flag(struct sock *sk, int bit, int valbool)
 {
 	if (valbool)
@@ -589,7 +643,7 @@ int sock_setsockopt(struct socket *sock, int level, int optname,
 	 */

 	if (optname == SO_BINDTODEVICE)
-		return sock_bindtodevice(sk, optval, optlen);
+		return sock_setbindtodevice(sk, optval, optlen);

 	if (optlen < sizeof(int))
 		return -EINVAL;
@@ -1074,15 +1128,17 @@ int sock_getsockopt(struct socket *sock, int level, int
optname,
 	case SO_NOFCS:
 		v.val = sock_flag(sk, SOCK_NOFCS);
 		break;
+
 	case SO_BINDTODEVICE:
-		v.val = sk->sk_bound_dev_if;
-		break;
+		return sock_getbindtodevice(sk, optval, optlen, len);
+
 	case SO_GET_FILTER:
 		len = sk_get_filter(sk, (struct sock_filter __user *)optval, len);
 		if (len < 0)
 			return len;

 		goto lenout;
+
 	default:
 		return -ENOPROTOOPT;
 	}
