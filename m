From: Brian Haley <brian.haley@hp.com>
Subject: [PATCH v2] IPv6: Add 'autoconf' and 'disable_ipv6' module parameters
Date: Fri, 29 May 2009 16:48:49 -0400
Message-ID: <4A204A31.4010105@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Kolbj=F8rn_Barmen?= <linux@kolla.no>,
	Vladislav Yasevich <vladislav.yasevich@hp.com>
To: David Miller <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:17762 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752346AbZE2Usv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 May 2009 16:48:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is v2 of the patch to add autoconf and disable_ipv6 module parameters to
IPv6.  I don't think anything more complicated is needed, assuming you play with
the /etc configuration files.

For example, if you wanted to enable IPv6 just on 'lo' you
would:

1. Add "ipv6" to /etc/modules (if you don't, step #3 might fail)

2. Add this to /etc/modprobe.conf:

	options ipv6 disable_ipv6=1

3. Add these to /etc/sysctl.conf:

	net.ipv6.conf.lo.disable_ipv6=0

# ip -6 a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever

The wording can probably be cleaned-up a little in ipv6.txt, comments welcome.

Differences from v1:

1. Changing sysctl value net.ipv6.conf.all.disable_ipv6 toggles the value on all
interfaces.

2. Changing the sysctl value "disable_ipv6" for a specific interface will
dynamically change the state of the interface.  On an enable, it will add a
link-local and start DAD.  On a disable it will remove all IPv6 addresses.  This
also happens in #1 above as well.

3. The "all" values for these sysctl's are no longer set on module load to their
given values, just the "default" ones.

4. ipv6_prefix_rcv() no longer checks net.ipv6.conf.all.autoconf before deciding
to do auto-configuration, just the device-specific value.


---------------------------------------------------------------

Add 'autoconf' and 'disable_ipv6' parameters to the IPv6 module.

The first controls if IPv6 addresses are autoconfigured from
prefixes received in Router Advertisements.  The IPv6 loopback
(::1) and link-local addresses are still configured.

The second controls if IPv6 addresses are desired at all.  No
IPv6 addresses will be added to any interfaces.

Signed-off-by: Brian Haley <brian.haley@hp.com>
---

diff --git a/Documentation/networking/ip-sysctl.txt
b/Documentation/networking/ip-sysctl.txt
index 3ffd233..8be7623 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -1057,6 +1057,13 @@ disable_ipv6 - BOOLEAN
 	address.
 	Default: FALSE (enable IPv6 operation)

+	When this value is changed from 1 to 0 (IPv6 is being enabled),
+	it will dynamically create a link-local address on the given
+	interface and start Duplicate Address Detection, if necessary.
+
+	When this value is changed from 0 to 1 (IPv6 is being disabled),
+	it will dynamically delete all address on the given interface.
+
 accept_dad - INTEGER
 	Whether to accept DAD (Duplicate Address Detection).
 	0: Disable DAD
diff --git a/Documentation/networking/ipv6.txt b/Documentation/networking/ipv6.txt
index 268e5c1..9fd7e21 100644
--- a/Documentation/networking/ipv6.txt
+++ b/Documentation/networking/ipv6.txt
@@ -33,3 +33,40 @@ disable

 		A reboot is required to enable IPv6.

+autoconf
+
+	Specifies whether to enable IPv6 address autoconfiguration
+	on all interfaces.  This might be used when one does not wish
+	for addresses to be automatically generated from prefixes
+	received in Router Advertisements.
+
+	The possible values and their effects are:
+
+	0
+		IPv6 address autoconfiguration is disabled on all interfaces.
+
+		Only the IPv6 loopback address (::1) and link-local addresses
+		will be added to interfaces.
+
+	1
+		IPv6 address autoconfiguration is enabled on all interfaces.
+
+		This is the default value.
+
+disable_ipv6
+
+	Specifies whether to disable IPv6 on all interfaces.
+	This might be used when no IPv6 addresses are desired.
+
+	The possible values and their effects are:
+
+	0
+		IPv6 is enabled on all interfaces.
+
+		This is the default value.
+
+	1
+		IPv6 is disabled on all interfaces.
+
+		No IPv6 addresses will be added to interfaces.
+
diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 476d946..c662efa 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -169,6 +169,12 @@ struct ipv6_devconf {
 	__s32		accept_dad;
 	void		*sysctl;
 };
+
+struct ipv6_params {
+	__s32 disable_ipv6;
+	__s32 autoconf;
+};
+extern struct ipv6_params ipv6_defaults;
 #endif

 /* index values for the variables in ipv6_devconf */
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 31938e5..c348837 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -591,7 +591,6 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr
*addr, int pfxlen,
 {
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
-	struct net *net = dev_net(idev->dev);
 	int hash;
 	int err = 0;
 	int addr_type = ipv6_addr_type(addr);
@@ -608,7 +607,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr
*addr, int pfxlen,
 		goto out2;
 	}

-	if (idev->cnf.disable_ipv6 || net->ipv6.devconf_all->disable_ipv6) {
+	if (idev->cnf.disable_ipv6) {
 		err = -EACCES;
 		goto out2;
 	}
@@ -1752,6 +1751,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt,
int len)
 	__u32 prefered_lft;
 	int addr_type;
 	struct inet6_dev *in6_dev;
+	struct net *net = dev_net(dev);

 	pinfo = (struct prefix_info *) opt;

@@ -1809,7 +1809,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt,
int len)
 		if (addrconf_finite_timeout(rt_expires))
 			rt_expires *= HZ;

-		rt = rt6_lookup(dev_net(dev), &pinfo->prefix, NULL,
+		rt = rt6_lookup(net, &pinfo->prefix, NULL,
 				dev->ifindex, 1);

 		if (rt && addrconf_is_prefix_route(rt)) {
@@ -1846,7 +1846,6 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt,
int len)
 		struct inet6_ifaddr * ifp;
 		struct in6_addr addr;
 		int create = 0, update_lft = 0;
-		struct net *net = dev_net(dev);

 		if (pinfo->prefix_len == 64) {
 			memcpy(&addr, &pinfo->prefix, 8);
@@ -3988,6 +3987,75 @@ static int addrconf_sysctl_forward_strategy(ctl_table *table,
 	return addrconf_fixup_forwarding(table, valp, val);
 }

+static void dev_disable_change(struct inet6_dev *idev)
+{
+	if (!idev || !idev->dev)
+		return;
+
+	if (idev->cnf.disable_ipv6)
+		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
+	else
+		addrconf_notify(NULL, NETDEV_UP, idev->dev);
+}
+
+static void addrconf_disable_change(struct net *net, __s32 newf)
+{
+	struct net_device *dev;
+	struct inet6_dev *idev;
+
+	read_lock(&dev_base_lock);
+	for_each_netdev(net, dev) {
+		rcu_read_lock();
+		idev = __in6_dev_get(dev);
+		if (idev) {
+			int changed = (!idev->cnf.disable_ipv6) ^ (!newf);
+			idev->cnf.disable_ipv6 = newf;
+			if (changed)
+				dev_disable_change(idev);
+		}
+		rcu_read_unlock();
+	}
+	read_unlock(&dev_base_lock);
+}
+
+static int addrconf_disable_ipv6(struct ctl_table *table, int *p, int old)
+{
+	struct net *net;
+
+	net = (struct net *)table->extra2;
+
+	if (p == &net->ipv6.devconf_dflt->disable_ipv6)
+		return 0;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (p == &net->ipv6.devconf_all->disable_ipv6) {
+		__s32 newf = net->ipv6.devconf_all->disable_ipv6;
+		net->ipv6.devconf_dflt->disable_ipv6 = newf;
+		addrconf_disable_change(net, newf);
+	} else if ((!*p) ^ (!old))
+		dev_disable_change((struct inet6_dev *)table->extra1);
+
+	rtnl_unlock();
+	return 0;
+}
+
+static
+int addrconf_sysctl_disable(ctl_table *ctl, int write, struct file * filp,
+			    void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int val = *valp;
+	int ret;
+
+	ret = proc_dointvec(ctl, write, filp, buffer, lenp, ppos);
+
+	if (write)
+		ret = addrconf_disable_ipv6(ctl, valp, val);
+	return ret;
+}
+
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
@@ -4225,7 +4293,8 @@ static struct addrconf_sysctl_table
 			.data		=	&ipv6_devconf.disable_ipv6,
 			.maxlen		=	sizeof(int),
 			.mode		=	0644,
-			.proc_handler	=	proc_dointvec,
+			.proc_handler	=	addrconf_sysctl_disable,
+			.strategy	=	sysctl_intvec,
 		},
 		{
 			.ctl_name	=	CTL_UNNUMBERED,
@@ -4346,6 +4415,10 @@ static int addrconf_init_net(struct net *net)
 		dflt = kmemdup(dflt, sizeof(ipv6_devconf_dflt), GFP_KERNEL);
 		if (dflt == NULL)
 			goto err_alloc_dflt;
+	} else {
+		/* these will be inherited by all namespaces */
+		dflt->autoconf = ipv6_defaults.autoconf;
+		dflt->disable_ipv6 = ipv6_defaults.disable_ipv6;
 	}

 	net->ipv6.devconf_all = all;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b6215be..85b3d00 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -72,9 +72,21 @@ MODULE_LICENSE("GPL");
 static struct list_head inetsw6[SOCK_MAX];
 static DEFINE_SPINLOCK(inetsw6_lock);

-static int disable_ipv6 = 0;
-module_param_named(disable, disable_ipv6, int, 0);
-MODULE_PARM_DESC(disable, "Disable IPv6 such that it is non-functional");
+struct ipv6_params ipv6_defaults = {
+	.disable_ipv6 = 0,
+	.autoconf = 1,
+};
+
+static int disable_ipv6_mod = 0;
+
+module_param_named(disable, disable_ipv6_mod, int, 0444);
+MODULE_PARM_DESC(disable, "Disable IPv6 module such that it is non-functional");
+
+module_param_named(disable_ipv6, ipv6_defaults.disable_ipv6, int, 0444);
+MODULE_PARM_DESC(disable_ipv6, "Disable IPv6 on all interfaces");
+
+module_param_named(autoconf, ipv6_defaults.autoconf, int, 0444);
+MODULE_PARM_DESC(autoconf, "Enable IPv6 address autoconfiguration on all
interfaces");

 static __inline__ struct ipv6_pinfo *inet6_sk_generic(struct sock *sk)
 {
@@ -1038,7 +1050,7 @@ static int __init inet6_init(void)
 	for(r = &inetsw6[0]; r < &inetsw6[SOCK_MAX]; ++r)
 		INIT_LIST_HEAD(r);

-	if (disable_ipv6) {
+	if (disable_ipv6_mod) {
 		printk(KERN_INFO
 		       "IPv6: Loaded, but administratively disabled, "
 		       "reboot required to enable\n");
@@ -1227,7 +1239,7 @@ module_init(inet6_init);

 static void __exit inet6_exit(void)
 {
-	if (disable_ipv6)
+	if (disable_ipv6_mod)
 		return;

 	/* First of all disallow new sockets creation. */
-- 
1.5.4.3
