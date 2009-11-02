From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] net: Introduce for_each_netdev_rcu() iterator
Date: Mon, 02 Nov 2009 16:11:12 +0100
Message-ID: <4AEEF690.4000208@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41386 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755116AbZKBPLN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Nov 2009 10:11:13 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Adds RCU management to the list of netdevices.

Convert some for_each_netdev() users to RCU version, if
it can avoid read_lock-ing dev_base_lock

Ie:
	read_lock(&dev_base_loack);
	for_each_netdev(net, dev)
		some_action();
	read_unlock(&dev_base_lock);

becomes :

	rcu_read_lock();
	for_each_netdev_rcu(net, dev)
		some_action();
	rcu_read_unlock();


Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    2 ++
 net/core/dev.c            |   30 ++++++++++++++++--------------
 net/decnet/af_decnet.c    |    6 +++---
 net/decnet/dn_fib.c       |    6 +++---
 net/decnet/dn_route.c     |    6 +++---
 net/ipv4/devinet.c        |   30 +++++++++++-------------------
 net/ipv6/addrconf.c       |   20 +++++++-------------
 net/ipv6/anycast.c        |    6 +++---
 net/netrom/nr_route.c     |   15 ++++++++-------
 net/rose/rose_route.c     |   16 ++++++++--------
 net/sctp/protocol.c       |    6 +++---
 11 files changed, 67 insertions(+), 76 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index bcf1083..5077de0 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1081,6 +1081,8 @@ extern rwlock_t				dev_base_lock;		/* Device list lock */
 
 #define for_each_netdev(net, d)		\
 		list_for_each_entry(d, &(net)->dev_base_head, dev_list)
+#define for_each_netdev_rcu(net, d)		\
+		list_for_each_entry_rcu(d, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_safe(net, d, n)	\
 		list_for_each_entry_safe(d, n, &(net)->dev_base_head, dev_list)
 #define for_each_netdev_continue(net, d)		\
diff --git a/net/core/dev.c b/net/core/dev.c
index 76a1502..bf629ac 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -175,7 +175,7 @@ static struct list_head ptype_all __read_mostly;	/* Taps */
  * The @dev_base_head list is protected by @dev_base_lock and the rtnl
  * semaphore.
  *
- * Pure readers hold dev_base_lock for reading.
+ * Pure readers hold dev_base_lock for reading, or rcu_read_lock()
  *
  * Writers must hold the rtnl semaphore while they loop through the
  * dev_base_head list, and hold dev_base_lock for writing when they do the
@@ -212,7 +212,7 @@ static int list_netdevice(struct net_device *dev)
 	ASSERT_RTNL();
 
 	write_lock_bh(&dev_base_lock);
-	list_add_tail(&dev->dev_list, &net->dev_base_head);
+	list_add_tail_rcu(&dev->dev_list, &net->dev_base_head);
 	hlist_add_head_rcu(&dev->name_hlist, dev_name_hash(net, dev->name));
 	hlist_add_head_rcu(&dev->index_hlist,
 			   dev_index_hash(net, dev->ifindex));
@@ -229,7 +229,7 @@ static void unlist_netdevice(struct net_device *dev)
 
 	/* Unlink dev from the device chain */
 	write_lock_bh(&dev_base_lock);
-	list_del(&dev->dev_list);
+	list_del_rcu(&dev->dev_list);
 	hlist_del_rcu(&dev->name_hlist);
 	hlist_del_rcu(&dev->index_hlist);
 	write_unlock_bh(&dev_base_lock);
@@ -799,15 +799,15 @@ struct net_device *dev_get_by_flags(struct net *net, unsigned short if_flags,
 	struct net_device *dev, *ret;
 
 	ret = NULL;
-	read_lock(&dev_base_lock);
-	for_each_netdev(net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
 		if (((dev->flags ^ if_flags) & mask) == 0) {
 			dev_hold(dev);
 			ret = dev;
 			break;
 		}
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return ret;
 }
 EXPORT_SYMBOL(dev_get_by_flags);
@@ -3077,18 +3077,18 @@ static int dev_ifconf(struct net *net, char __user *arg)
  *	in detail.
  */
 void *dev_seq_start(struct seq_file *seq, loff_t *pos)
-	__acquires(dev_base_lock)
+	__acquires(RCU)
 {
 	struct net *net = seq_file_net(seq);
 	loff_t off;
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
+	rcu_read_lock();
 	if (!*pos)
 		return SEQ_START_TOKEN;
 
 	off = 1;
-	for_each_netdev(net, dev)
+	for_each_netdev_rcu(net, dev)
 		if (off++ == *pos)
 			return dev;
 
@@ -3097,16 +3097,18 @@ void *dev_seq_start(struct seq_file *seq, loff_t *pos)
 
 void *dev_seq_next(struct seq_file *seq, void *v, loff_t *pos)
 {
-	struct net *net = seq_file_net(seq);
+	struct net_device *dev = (v == SEQ_START_TOKEN) ?
+				  first_net_device(seq_file_net(seq)) :
+				  next_net_device((struct net_device *)v);
+
 	++*pos;
-	return v == SEQ_START_TOKEN ?
-		first_net_device(net) : next_net_device((struct net_device *)v);
+	return rcu_dereference(dev);
 }
 
 void dev_seq_stop(struct seq_file *seq, void *v)
-	__releases(dev_base_lock)
+	__releases(RCU)
 {
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
diff --git a/net/decnet/af_decnet.c b/net/decnet/af_decnet.c
index 664965c..2e35584 100644
--- a/net/decnet/af_decnet.c
+++ b/net/decnet/af_decnet.c
@@ -749,9 +749,9 @@ static int dn_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 
 	if (!(saddr->sdn_flags & SDF_WILD)) {
 		if (le16_to_cpu(saddr->sdn_nodeaddrl)) {
-			read_lock(&dev_base_lock);
+			rcu_read_lock();
 			ldev = NULL;
-			for_each_netdev(&init_net, dev) {
+			for_each_netdev_rcu(&init_net, dev) {
 				if (!dev->dn_ptr)
 					continue;
 				if (dn_dev_islocal(dev, dn_saddr2dn(saddr))) {
@@ -759,7 +759,7 @@ static int dn_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
 					break;
 				}
 			}
-			read_unlock(&dev_base_lock);
+			rcu_read_unlock();
 			if (ldev == NULL)
 				return -EADDRNOTAVAIL;
 		}
diff --git a/net/decnet/dn_fib.c b/net/decnet/dn_fib.c
index 27ea2e9..fd641f6 100644
--- a/net/decnet/dn_fib.c
+++ b/net/decnet/dn_fib.c
@@ -607,8 +607,8 @@ static void dn_fib_del_ifaddr(struct dn_ifaddr *ifa)
 	ASSERT_RTNL();
 
 	/* Scan device list */
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		dn_db = dev->dn_ptr;
 		if (dn_db == NULL)
 			continue;
@@ -619,7 +619,7 @@ static void dn_fib_del_ifaddr(struct dn_ifaddr *ifa)
 			}
 		}
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 
 	if (found_it == 0) {
 		fib_magic(RTM_DELROUTE, RTN_LOCAL, ifa->ifa_local, 16, ifa);
diff --git a/net/decnet/dn_route.c b/net/decnet/dn_route.c
index 57662ca..860286a 100644
--- a/net/decnet/dn_route.c
+++ b/net/decnet/dn_route.c
@@ -908,8 +908,8 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 			dev_put(dev_out);
 			goto out;
 		}
-		read_lock(&dev_base_lock);
-		for_each_netdev(&init_net, dev) {
+		rcu_read_lock();
+		for_each_netdev_rcu(&init_net, dev) {
 			if (!dev->dn_ptr)
 				continue;
 			if (!dn_dev_islocal(dev, oldflp->fld_src))
@@ -922,7 +922,7 @@ static int dn_route_output_slow(struct dst_entry **pprt, const struct flowi *old
 			dev_out = dev;
 			break;
 		}
-		read_unlock(&dev_base_lock);
+		rcu_read_unlock();
 		if (dev_out == NULL)
 			goto out;
 		dev_hold(dev_out);
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index ccccaae..8aa7a13 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -876,19 +876,16 @@ __be32 inet_select_addr(const struct net_device *dev, __be32 dst, int scope)
 		if (!addr)
 			addr = ifa->ifa_local;
 	} endfor_ifa(in_dev);
-no_in_dev:
-	rcu_read_unlock();
 
+no_in_dev:
 	if (addr)
-		goto out;
+		goto out_unlock;
 
 	/* Not loopback addresses on loopback should be preferred
 	   in this case. It is importnat that lo is the first interface
 	   in dev_base list.
 	 */
-	read_lock(&dev_base_lock);
-	rcu_read_lock();
-	for_each_netdev(net, dev) {
+	for_each_netdev_rcu(net, dev) {
 		if ((in_dev = __in_dev_get_rcu(dev)) == NULL)
 			continue;
 
@@ -896,12 +893,11 @@ no_in_dev:
 			if (ifa->ifa_scope != RT_SCOPE_LINK &&
 			    ifa->ifa_scope <= scope) {
 				addr = ifa->ifa_local;
-				goto out_unlock_both;
+				goto out_unlock;
 			}
 		} endfor_ifa(in_dev);
 	}
-out_unlock_both:
-	read_unlock(&dev_base_lock);
+out_unlock:
 	rcu_read_unlock();
 out:
 	return addr;
@@ -962,9 +958,8 @@ __be32 inet_confirm_addr(struct in_device *in_dev,
 		return confirm_addr_indev(in_dev, dst, local, scope);
 
 	net = dev_net(in_dev->dev);
-	read_lock(&dev_base_lock);
 	rcu_read_lock();
-	for_each_netdev(net, dev) {
+	for_each_netdev_rcu(net, dev) {
 		if ((in_dev = __in_dev_get_rcu(dev))) {
 			addr = confirm_addr_indev(in_dev, dst, local, scope);
 			if (addr)
@@ -972,7 +967,6 @@ __be32 inet_confirm_addr(struct in_device *in_dev,
 		}
 	}
 	rcu_read_unlock();
-	read_unlock(&dev_base_lock);
 
 	return addr;
 }
@@ -1240,18 +1234,18 @@ static void devinet_copy_dflt_conf(struct net *net, int i)
 {
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
 		struct in_device *in_dev;
-		rcu_read_lock();
+
 		in_dev = __in_dev_get_rcu(dev);
 		if (in_dev && !test_bit(i, in_dev->cnf.state))
 			in_dev->cnf.data[i] = net->ipv4.devconf_dflt->data[i];
-		rcu_read_unlock();
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
+/* called with RTNL locked */
 static void inet_forward_change(struct net *net)
 {
 	struct net_device *dev;
@@ -1260,7 +1254,6 @@ static void inet_forward_change(struct net *net)
 	IPV4_DEVCONF_ALL(net, ACCEPT_REDIRECTS) = !on;
 	IPV4_DEVCONF_DFLT(net, FORWARDING) = on;
 
-	read_lock(&dev_base_lock);
 	for_each_netdev(net, dev) {
 		struct in_device *in_dev;
 		if (on)
@@ -1271,7 +1264,6 @@ static void inet_forward_change(struct net *net)
 			IN_DEV_CONF_SET(in_dev, FORWARDING, on);
 		rcu_read_unlock();
 	}
-	read_unlock(&dev_base_lock);
 }
 
 static int devinet_conf_proc(ctl_table *ctl, int write,
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 9186484..024bba3 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -481,9 +481,8 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(net, dev) {
-		rcu_read_lock();
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.forwarding) ^ (!newf);
@@ -491,9 +490,8 @@ static void addrconf_forward_change(struct net *net, __s32 newf)
 			if (changed)
 				dev_forward_change(idev);
 		}
-		rcu_read_unlock();
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int addrconf_fixup_forwarding(struct ctl_table *table, int *p, int old)
@@ -1137,10 +1135,9 @@ int ipv6_dev_get_saddr(struct net *net, struct net_device *dst_dev,
 	hiscore->rule = -1;
 	hiscore->ifa = NULL;
 
-	read_lock(&dev_base_lock);
 	rcu_read_lock();
 
-	for_each_netdev(net, dev) {
+	for_each_netdev_rcu(net, dev) {
 		struct inet6_dev *idev;
 
 		/* Candidate Source Address (section 4)
@@ -1235,7 +1232,6 @@ try_nextdev:
 		read_unlock_bh(&idev->lock);
 	}
 	rcu_read_unlock();
-	read_unlock(&dev_base_lock);
 
 	if (!hiscore->ifa)
 		return -EADDRNOTAVAIL;
@@ -4052,9 +4048,8 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 	struct net_device *dev;
 	struct inet6_dev *idev;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(net, dev) {
-		rcu_read_lock();
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
 		idev = __in6_dev_get(dev);
 		if (idev) {
 			int changed = (!idev->cnf.disable_ipv6) ^ (!newf);
@@ -4062,9 +4057,8 @@ static void addrconf_disable_change(struct net *net, __s32 newf)
 			if (changed)
 				dev_disable_change(idev);
 		}
-		rcu_read_unlock();
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
diff --git a/net/ipv6/anycast.c b/net/ipv6/anycast.c
index 1ae58be..2f00ca8 100644
--- a/net/ipv6/anycast.c
+++ b/net/ipv6/anycast.c
@@ -404,13 +404,13 @@ int ipv6_chk_acast_addr(struct net *net, struct net_device *dev,
 
 	if (dev)
 		return ipv6_chk_acast_dev(dev, addr);
-	read_lock(&dev_base_lock);
-	for_each_netdev(net, dev)
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev)
 		if (ipv6_chk_acast_dev(dev, addr)) {
 			found = 1;
 			break;
 		}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return found;
 }
 
diff --git a/net/netrom/nr_route.c b/net/netrom/nr_route.c
index 4eb1ac9..aacba76 100644
--- a/net/netrom/nr_route.c
+++ b/net/netrom/nr_route.c
@@ -597,15 +597,15 @@ struct net_device *nr_dev_first(void)
 {
 	struct net_device *dev, *first = NULL;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_NETROM)
 			if (first == NULL || strncmp(dev->name, first->name, 3) < 0)
 				first = dev;
 	}
 	if (first)
 		dev_hold(first);
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 
 	return first;
 }
@@ -617,16 +617,17 @@ struct net_device *nr_dev_get(ax25_address *addr)
 {
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
-		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_NETROM && ax25cmp(addr, (ax25_address *)dev->dev_addr) == 0) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
+		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_NETROM &&
+		    ax25cmp(addr, (ax25_address *)dev->dev_addr) == 0) {
 			dev_hold(dev);
 			goto out;
 		}
 	}
 	dev = NULL;
 out:
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return dev;
 }
 
diff --git a/net/rose/rose_route.c b/net/rose/rose_route.c
index 9478d9b..bd7a544 100644
--- a/net/rose/rose_route.c
+++ b/net/rose/rose_route.c
@@ -600,13 +600,13 @@ struct net_device *rose_dev_first(void)
 {
 	struct net_device *dev, *first = NULL;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE)
 			if (first == NULL || strncmp(dev->name, first->name, 3) < 0)
 				first = dev;
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 
 	return first;
 }
@@ -618,8 +618,8 @@ struct net_device *rose_dev_get(rose_address *addr)
 {
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE && rosecmp(addr, (rose_address *)dev->dev_addr) == 0) {
 			dev_hold(dev);
 			goto out;
@@ -635,14 +635,14 @@ static int rose_dev_exists(rose_address *addr)
 {
 	struct net_device *dev;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		if ((dev->flags & IFF_UP) && dev->type == ARPHRD_ROSE && rosecmp(addr, (rose_address *)dev->dev_addr) == 0)
 			goto out;
 	}
 	dev = NULL;
 out:
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 	return dev != NULL;
 }
 

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index d9f4cc2..fe44c57 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -205,14 +205,14 @@ static void sctp_get_local_addr_list(void)
 	struct list_head *pos;
 	struct sctp_af *af;
 
-	read_lock(&dev_base_lock);
-	for_each_netdev(&init_net, dev) {
+	rcu_read_lock();
+	for_each_netdev_rcu(&init_net, dev) {
 		__list_for_each(pos, &sctp_address_families) {
 			af = list_entry(pos, struct sctp_af, list);
 			af->copy_addrlist(&sctp_local_addr_list, dev);
 		}
 	}
-	read_unlock(&dev_base_lock);
+	rcu_read_unlock();
 }
 
 /* Free the existing local addresses.  */
