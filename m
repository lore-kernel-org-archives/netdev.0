From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [PATCH 3/4] [IPV4]: Add default config support after inetdev_init
Date: Tue, 05 Jun 2007 16:31:03 +1000
Message-ID: <E1HvSZL-0003AB-00@gondolin.me.apana.org.au>
References: <20070605062929.GA12024@gondor.apana.org.au>
To: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:4095 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760263AbXFEGbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2007 02:31:09 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[IPV4]: Add default config support after inetdev_init

Previously once inetdev_init has been called on a device any changes made
to ipv4_devconf_dflt would have no effect on that device's configuration.

This creates a problem since we have moved the point where inetdev_init
is called from when an address is added to where the device is registered.

This patch is the first half of a set that tries to mimic the old behaviour
while still calling inetdev_init.

It propagates any changes to ipv4_devconf_dflt to those devices that have
not had the corresponding attribute set.

The next patch will forcibly set all values at the point where inetdev_init
was previously called.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
---

 include/linux/inetdevice.h |    3 +
 net/ipv4/devinet.c         |  133 +++++++++++++++++++++++++++++++++------------
 2 files changed, 101 insertions(+), 35 deletions(-)

diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -3,6 +3,7 @@
 
 #ifdef __KERNEL__
 
+#include <linux/bitmap.h>
 #include <linux/if.h>
 #include <linux/netdevice.h>
 #include <linux/rcupdate.h>
@@ -12,6 +13,7 @@ struct ipv4_devconf
 {
 	void	*sysctl;
 	int	data[__NET_IPV4_CONF_MAX - 1];
+	DECLARE_BITMAP(state, __NET_IPV4_CONF_MAX - 1);
 };
 
 extern struct ipv4_devconf ipv4_devconf;
@@ -53,6 +55,7 @@ static inline void ipv4_devconf_set(stru
 				    int val)
 {
 	index--;
+	set_bit(index, in_dev->cnf.state);
 	in_dev->cnf.data[index] = val;
 }
 
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -1244,6 +1244,91 @@ errout:
 
 #ifdef CONFIG_SYSCTL
 
+static void devinet_copy_dflt_conf(int i)
+{
+	struct net_device *dev;
+
+	read_lock(&dev_base_lock);
+	for_each_netdev(dev) {
+		struct in_device *in_dev;
+		rcu_read_lock();
+		in_dev = __in_dev_get_rcu(dev);
+		if (in_dev && !test_bit(i, in_dev->cnf.state))
+			in_dev->cnf.data[i] = ipv4_devconf_dflt.data[i];
+		rcu_read_unlock();
+	}
+	read_unlock(&dev_base_lock);
+}
+
+static int devinet_conf_proc(ctl_table *ctl, int write,
+			     struct file* filp, void __user *buffer,
+			     size_t *lenp, loff_t *ppos)
+{
+	int ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+
+	if (write) {
+		struct ipv4_devconf *cnf = ctl->extra1;
+		int i = (int *)ctl->data - cnf->data;
+
+		set_bit(i, cnf->state);
+
+		if (cnf == &ipv4_devconf_dflt)
+			devinet_copy_dflt_conf(i);
+	}
+
+	return ret;
+}
+
+static int devinet_conf_sysctl(ctl_table *table, int __user *name, int nlen,
+			       void __user *oldval, size_t __user *oldlenp,
+			       void __user *newval, size_t newlen)
+{
+	struct ipv4_devconf *cnf;
+	int *valp = table->data;
+	int new;
+	int i;
+
+	if (!newval || !newlen)
+		return 0;
+
+	if (newlen != sizeof(int))
+		return -EINVAL;
+
+	if (get_user(new, (int __user *)newval))
+		return -EFAULT;
+
+	if (new == *valp)
+		return 0;
+
+	if (oldval && oldlenp) {
+		size_t len;
+
+		if (get_user(len, oldlenp))
+			return -EFAULT;
+
+		if (len) {
+			if (len > table->maxlen)
+				len = table->maxlen;
+			if (copy_to_user(oldval, valp, len))
+				return -EFAULT;
+			if (put_user(len, oldlenp))
+				return -EFAULT;
+		}
+	}
+
+	*valp = new;
+
+	cnf = table->extra1;
+	i = (int *)table->data - cnf->data;
+
+	set_bit(i, cnf->state);
+
+	if (cnf == &ipv4_devconf_dflt)
+		devinet_copy_dflt_conf(i);
+
+	return 1;
+}
+
 void inet_forward_change(void)
 {
 	struct net_device *dev;
@@ -1302,40 +1387,13 @@ int ipv4_doint_and_flush_strategy(ctl_ta
 				  void __user *oldval, size_t __user *oldlenp,
 				  void __user *newval, size_t newlen)
 {
-	int *valp = table->data;
-	int new;
-
-	if (!newval || !newlen)
-		return 0;
-
-	if (newlen != sizeof(int))
-		return -EINVAL;
+	int ret = devinet_conf_sysctl(table, name, nlen, oldval, oldlenp,
+				      newval, newlen);
 
-	if (get_user(new, (int __user *)newval))
-		return -EFAULT;
-
-	if (new == *valp)
-		return 0;
-
-	if (oldval && oldlenp) {
-		size_t len;
-
-		if (get_user(len, oldlenp))
-			return -EFAULT;
-
-		if (len) {
-			if (len > table->maxlen)
-				len = table->maxlen;
-			if (copy_to_user(oldval, valp, len))
-				return -EFAULT;
-			if (put_user(len, oldlenp))
-				return -EFAULT;
-		}
-	}
+	if (ret == 1)
+		rt_cache_flush(0);
 
-	*valp = new;
-	rt_cache_flush(0);
-	return 1;
+	return ret;
 }
 
 
@@ -1349,13 +1407,16 @@ int ipv4_doint_and_flush_strategy(ctl_ta
 		.mode		= mval, \
 		.proc_handler	= proc, \
 		.strategy	= sysctl, \
+		.extra1		= &ipv4_devconf, \
 	}
 
 #define DEVINET_SYSCTL_RW_ENTRY(attr, name) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0644, &proc_dointvec, NULL)
+	DEVINET_SYSCTL_ENTRY(attr, name, 0644, devinet_conf_proc, \
+			     devinet_conf_sysctl)
 
 #define DEVINET_SYSCTL_RO_ENTRY(attr, name) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0444, &proc_dointvec, NULL)
+	DEVINET_SYSCTL_ENTRY(attr, name, 0444, devinet_conf_proc, \
+			     devinet_conf_sysctl)
 
 #define DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, proc, sysctl) \
 	DEVINET_SYSCTL_ENTRY(attr, name, 0644, proc, sysctl)
@@ -1374,7 +1435,8 @@ static struct devinet_sysctl_table {
 } devinet_sysctl = {
 	.devinet_vars = {
 		DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
-					     devinet_sysctl_forward, NULL),
+					     devinet_sysctl_forward,
+					     devinet_conf_sysctl),
 		DEVINET_SYSCTL_RO_ENTRY(MC_FORWARDING, "mc_forwarding"),
 
 		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_REDIRECTS, "accept_redirects"),
@@ -1448,6 +1510,7 @@ static void devinet_sysctl_register(stru
 		return;
 	for (i = 0; i < ARRAY_SIZE(t->devinet_vars) - 1; i++) {
 		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
+		t->devinet_vars[i].extra1 = p;
 	}
 
 	if (dev) {
