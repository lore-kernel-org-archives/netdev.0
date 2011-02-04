From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 5/5] ipv6: share sysctl net/ipv6/conf/DEVNAME/ tables
Date: Fri,  4 Feb 2011 06:37:08 +0200
Message-ID: <dc0b2146da43d886ad0dfd5ff6c420ccf9f73e4b.1296793770.git.lucian.grijincu@gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Oct
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:46255 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754578Ab1BDEiS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 23:38:18 -0500
In-Reply-To: <cover.1296793770.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1296793770.git.lucian.grijincu@gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Similar to the ipv4 patch:

Before this, for each network device DEVNAME that supports ipv4 a new
sysctl table was registered in $PROC/sys/net/ipv6/conf/DEVNAME/.

The sysctl table was identical for all network devices, except for:
* data: pointer to the data to be accessed in the sysctl
* extra1: the 'struct inet6_dev*' of the network device
* extra2: the 'struct net*' of the network namespace

Assuming we have a device name and a 'struct net*', we can get the
'struct net_device*'. From there we can compute:
* data: each entry corresponds to a position in 'struct ipv6_devconf*'
* extra1: 'struct inet6_dev*' can be reached from 'struct net_device*'
* extra2: the 'struct net*' that we assume we have

The device name is determined from the path to the file (the name of
the parent dentry).

The 'struct net*' is stored in the parent 'struct ctl_table*' path by
register_net_sysctl_table_pathdata().

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 include/linux/ipv6.h |   15 ++++-
 net/ipv6/addrconf.c  |  192 +++++++++++++++++++++++++++++++++----------------
 2 files changed, 143 insertions(+), 64 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 0c99776..623761d 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -129,6 +129,17 @@ struct ipv6hdr {
 };
 
 #ifdef __KERNEL__
+
+#ifdef CONFIG_SYSCTL
+struct addrconf_sysctl {
+	/* dev_name holds a copy of dev_name, because '.procname' is
+	 * regarded as const by sysctl and we wouldn't want anyone to
+	 * change it under our feet (see SIOCSIFNAME). */
+	char *dev_name;
+	struct ctl_table_header *sysctl_header;
+};
+#endif
+
 /*
  * This structure contains configuration options per IPv6 link.
  */
@@ -172,7 +183,9 @@ struct ipv6_devconf {
 	__s32		disable_ipv6;
 	__s32		accept_dad;
 	__s32		force_tllao;
-	void		*sysctl;
+#ifdef CONFIG_SYSCTL
+	struct addrconf_sysctl addrconf_sysctl;
+#endif
 };
 
 struct ipv6_params {
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index fd6782e..27fd8a1 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -364,7 +364,8 @@ static struct inet6_dev * ipv6_add_dev(struct net_device *dev)
 
 	memcpy(&ndev->cnf, dev_net(dev)->ipv6.devconf_dflt, sizeof(ndev->cnf));
 	ndev->cnf.mtu6 = dev->mtu;
-	ndev->cnf.sysctl = NULL;
+	ndev->cnf.addrconf_sysctl.dev_name = NULL;
+	ndev->cnf.addrconf_sysctl.sysctl_header = NULL;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
 	if (ndev->nd_parms == NULL) {
 		kfree(ndev);
@@ -4249,90 +4250,176 @@ int addrconf_sysctl_disable(ctl_table *ctl, int write,
 	return ret;
 }
 
-static struct addrconf_sysctl_table
+static int addrconf_handler(ctl_table *ctl, int write,
+			    void __user *buffer,
+			    size_t *lenp, loff_t *ppos,
+			    struct file *filp,
+			    proc_handler *proc_handler)
 {
-	struct ctl_table_header *sysctl_header;
-	ctl_table addrconf_vars[DEVCONF_MAX+1];
-	char *dev_name;
-} addrconf_sysctl __read_mostly = {
-	.sysctl_header = NULL,
-	.addrconf_vars = {
+	/* The path to this file is of the form:
+	 *  $PROC_MOUNT/sys/net/ipv6/conf/$DEVNAME/$CTL
+	 *
+	 * The array of 'struct ctl_table' of devinet entries is
+	 * shared between all ipv6 network devices and the 'data'
+	 * field of each structure only hold the offset into the
+	 * 'data' field of 'struct ipv6_devconf'.
+	 *
+	 * To find the propper location of the data that must be
+	 * accessed by this handler we need the device name and the
+	 * network namespace in which it belongs.
+	 */
+
+	/* We store the network namespace in the parent table's ->extra2 */
+	struct inode *parent_inode = filp->f_path.dentry->d_parent->d_inode;
+	struct ctl_table *parent_table = PROC_I(parent_inode)->sysctl_entry;
+	struct net *net = parent_table->extra2;
+
+	const char *dev_name = filp->f_path.dentry->d_parent->d_name.name;
+	struct ctl_table tmp_ctl;
+	struct net_device *dev = NULL;
+	struct inet6_dev *in6_dev = NULL;
+	struct ipv6_devconf *cnf;
+	int ret;
+
+	if (strcmp(dev_name, "all") == 0) {
+		cnf = net->ipv6.devconf_all;
+	} else if (strcmp(dev_name, "default") == 0) {
+		cnf = net->ipv6.devconf_dflt;
+	} else {
+		/* the device could have been renamed (SIOCSIFADDR) or
+		 * deleted since we started accessing it's proc sysctl */
+		dev = dev_get_by_name(net, dev_name);
+		if (dev == NULL)
+			return -ENOENT;
+		in6_dev = in6_dev_get(dev);
+		cnf = &in6_dev->cnf;
+	}
+
+	tmp_ctl = *ctl;
+	tmp_ctl.data += (char *)cnf - (char *)&ipv6_devconf;
+	tmp_ctl.extra1 = in6_dev;
+	tmp_ctl.extra2 = net;
+
+	ret = proc_handler(&tmp_ctl, write, buffer, lenp, ppos);
+
+	if (in6_dev)
+		in6_dev_put(in6_dev);
+	if (dev)
+		dev_put(dev);
+	return ret;
+}
+
+
+static int  addrconf_proc_dointvec(ctl_table *ctl, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos, struct file *filp)
+{
+	return addrconf_handler(ctl, write, buffer, lenp, ppos, filp,
+				proc_dointvec);
+}
+
+static int  addrconf_proc_dointvec_jiffies(ctl_table *ctl, int write,
+					   void __user *buffer, size_t *lenp,
+					   loff_t *ppos, struct file *filp)
+{
+	return addrconf_handler(ctl, write, buffer, lenp, ppos, filp,
+				proc_dointvec_jiffies);
+}
+
+static int addrconf_sysctl_forward__(ctl_table *ctl, int write,
+				     void __user *buffer, size_t *lenp,
+				     loff_t *ppos, struct file *filp)
+{
+	return addrconf_handler(ctl, write, buffer, lenp, ppos, filp,
+				addrconf_sysctl_forward);
+}
+
+
+static int addrconf_sysctl_disable__(ctl_table *ctl, int write,
+				     void __user *buffer, size_t *lenp,
+				     loff_t *ppos, struct file *filp)
+{
+	return addrconf_handler(ctl, write, buffer, lenp, ppos, filp,
+				addrconf_sysctl_disable);
+}
+
+static const struct ctl_table ipv6_addrconf_sysctl_table[DEVCONF_MAX+1] = {
 		{
 			.procname	= "forwarding",
 			.data		= &ipv6_devconf.forwarding,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_forward,
+			.proc_handler	= addrconf_sysctl_forward__,
 		},
 		{
 			.procname	= "hop_limit",
 			.data		= &ipv6_devconf.hop_limit,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "mtu",
 			.data		= &ipv6_devconf.mtu6,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "accept_ra",
 			.data		= &ipv6_devconf.accept_ra,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "accept_redirects",
 			.data		= &ipv6_devconf.accept_redirects,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "autoconf",
 			.data		= &ipv6_devconf.autoconf,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "dad_transmits",
 			.data		= &ipv6_devconf.dad_transmits,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "router_solicitations",
 			.data		= &ipv6_devconf.rtr_solicits,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "router_solicitation_interval",
 			.data		= &ipv6_devconf.rtr_solicit_interval,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
+			.proc_handler	= addrconf_proc_dointvec_jiffies,
 		},
 		{
 			.procname	= "router_solicitation_delay",
 			.data		= &ipv6_devconf.rtr_solicit_delay,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
+			.proc_handler	= addrconf_proc_dointvec_jiffies,
 		},
 		{
 			.procname	= "force_mld_version",
 			.data		= &ipv6_devconf.force_mld_version,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_PRIVACY
 		{
@@ -4340,35 +4427,35 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.use_tempaddr,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "temp_valid_lft",
 			.data		= &ipv6_devconf.temp_valid_lft,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "temp_prefered_lft",
 			.data		= &ipv6_devconf.temp_prefered_lft,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "regen_max_retry",
 			.data		= &ipv6_devconf.regen_max_retry,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "max_desync_factor",
 			.data		= &ipv6_devconf.max_desync_factor,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #endif
 		{
@@ -4376,21 +4463,21 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.max_addresses,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "accept_ra_defrtr",
 			.data		= &ipv6_devconf.accept_ra_defrtr,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "accept_ra_pinfo",
 			.data		= &ipv6_devconf.accept_ra_pinfo,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_ROUTER_PREF
 		{
@@ -4398,14 +4485,14 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.accept_ra_rtr_pref,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "router_probe_interval",
 			.data		= &ipv6_devconf.rtr_probe_interval,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec_jiffies,
+			.proc_handler	= addrconf_proc_dointvec_jiffies,
 		},
 #ifdef CONFIG_IPV6_ROUTE_INFO
 		{
@@ -4413,7 +4500,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #endif
 #endif
@@ -4422,14 +4509,14 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.proxy_ndp,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname	= "accept_source_route",
 			.data		= &ipv6_devconf.accept_source_route,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
@@ -4437,7 +4524,7 @@ static struct addrconf_sysctl_table
 			.data           = &ipv6_devconf.optimistic_dad,
 			.maxlen         = sizeof(int),
 			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
+			.proc_handler   = addrconf_proc_dointvec,
 
 		},
 #endif
@@ -4447,7 +4534,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.mc_forwarding,
 			.maxlen		= sizeof(int),
 			.mode		= 0444,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #endif
 		{
@@ -4455,33 +4542,31 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.disable_ipv6,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= addrconf_sysctl_disable,
+			.proc_handler	= addrconf_sysctl_disable__,
 		},
 		{
 			.procname	= "accept_dad",
 			.data		= &ipv6_devconf.accept_dad,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 		{
 			.procname       = "force_tllao",
 			.data           = &ipv6_devconf.force_tllao,
 			.maxlen         = sizeof(int),
 			.mode           = 0644,
-			.proc_handler   = proc_dointvec
+			.proc_handler   = addrconf_proc_dointvec
 		},
 		{
 			/* sentinel */
 		}
-	},
 };
 
 static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		struct inet6_dev *idev, struct ipv6_devconf *p)
 {
-	int i;
-	struct addrconf_sysctl_table *t;
+	struct addrconf_sysctl *t = &p->addrconf_sysctl;
 
 #define ADDRCONF_CTL_PATH_DEV	3
 
@@ -4494,16 +4579,6 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	};
 
 
-	t = kmemdup(&addrconf_sysctl, sizeof(*t), GFP_KERNEL);
-	if (t == NULL)
-		goto out;
-
-	for (i = 0; t->addrconf_vars[i].data; i++) {
-		t->addrconf_vars[i].data += (char *)p - (char *)&ipv6_devconf;
-		t->addrconf_vars[i].extra1 = idev; /* embedded; no ref */
-		t->addrconf_vars[i].extra2 = net;
-	}
-
 	/*
 	 * Make a copy of dev_name, because '.procname' is regarded as const
 	 * by sysctl and we wouldn't want anyone to change it under our feet
@@ -4511,38 +4586,29 @@ static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 	 */
 	t->dev_name = kstrdup(dev_name, GFP_KERNEL);
 	if (!t->dev_name)
-		goto free;
+		goto out;
 
 	addrconf_ctl_path[ADDRCONF_CTL_PATH_DEV].procname = t->dev_name;
 
-	t->sysctl_header = register_net_sysctl_table(net, addrconf_ctl_path,
-			t->addrconf_vars);
+	t->sysctl_header = register_net_sysctl_table_pathdata(net,
+			      addrconf_ctl_path, ipv6_addrconf_sysctl_table, net);
 	if (t->sysctl_header == NULL)
 		goto free_procname;
 
-	p->sysctl = t;
 	return 0;
 
 free_procname:
 	kfree(t->dev_name);
-free:
-	kfree(t);
 out:
 	return -ENOBUFS;
 }
 
 static void __addrconf_sysctl_unregister(struct ipv6_devconf *p)
 {
-	struct addrconf_sysctl_table *t;
-
-	if (p->sysctl == NULL)
-		return;
+	struct addrconf_sysctl *t = &p->addrconf_sysctl;
 
-	t = p->sysctl;
-	p->sysctl = NULL;
 	unregister_sysctl_table(t->sysctl_header);
 	kfree(t->dev_name);
-	kfree(t);
 }
 
 static void addrconf_sysctl_register(struct inet6_dev *idev)
-- 
1.7.4.rc1.7.g2cf08.dirty

