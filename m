From: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
Subject: [PATCH 4/5] ipv4: share sysctl net/ipv4/conf/DEVNAME/ tables
Date: Fri,  4 Feb 2011 06:37:07 +0200
Message-ID: <cf6a4b19f6b0264f58367afb659586efb84d2a69.1296793770.git.lucian.grijincu@gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
Cc: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Oct
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1296793770.git.lucian.grijincu@gmail.com>
In-Reply-To: <cover.1296793770.git.lucian.grijincu@gmail.com>
References: <cover.1296793770.git.lucian.grijincu@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Before this, for each network device DEVNAME that supports ipv4 a new
sysctl table was registered in $PROC/sys/net/ipv4/conf/DEVNAME/.

The sysctl table was identical for all network devices, except for:
* data: pointer to the data to be accessed in the sysctl
* extra1: the 'struct ipv4_devconf*' of the network device
* extra2: the 'struct net*' of the network namespace

Assuming we have a device name and a 'struct net*', we can get the
'struct net_device*'. From there we can compute:
* data: each entry corresponds to a position in 'struct ipv4_devconf*'
* extra1: 'struct ipv4_devconf*' can be reached from 'struct net_device*'
* extra2: the 'struct net*' that we assumed to have

The device name is determined from the path to the file (the name of
the parent dentry).

The 'struct net*' is stored in the parent 'struct ctl_table*' path by
register_net_sysctl_table_pathdata().

Signed-off-by: Lucian Adrian Grijincu <lucian.grijincu@gmail.com>
---
 fs/proc/proc_sysctl.c      |   16 +++-
 include/linux/inetdevice.h |   12 +++-
 net/ipv4/devinet.c         |  203 +++++++++++++++++++++++++++++---------------
 3 files changed, 161 insertions(+), 70 deletions(-)

diff --git a/fs/proc/proc_sysctl.c b/fs/proc/proc_sysctl.c
index fb707e0..fe392f1 100644
--- a/fs/proc/proc_sysctl.c
+++ b/fs/proc/proc_sysctl.c
@@ -128,6 +128,11 @@ out:
 	return err;
 }
 
+
+typedef int proc_handler_extended(struct ctl_table *ctl, int write,
+				  void __user *buffer, size_t *lenp, loff_t *ppos,
+				  struct file *filp);
+
 static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 		size_t count, loff_t *ppos, int write)
 {
@@ -136,6 +141,7 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 	struct ctl_table *table = PROC_I(inode)->sysctl_entry;
 	ssize_t error;
 	size_t res;
+	proc_handler_extended *phx = (proc_handler_extended *) table->proc_handler;
 
 	if (IS_ERR(head))
 		return PTR_ERR(head);
@@ -155,7 +161,15 @@ static ssize_t proc_sys_call_handler(struct file *filp, void __user *buf,
 
 	/* careful: calling conventions are nasty here */
 	res = count;
-	error = table->proc_handler(table, write, buf, &res, ppos);
+	/* Most handlers only use the first 5 arguments (without @filp).
+	 * Changing all is too much of work, as, at the time of writting only
+	 * the devinet.c proc_handlers know about and use the @filp.
+	 *
+	 * This is just a HACK for now, I did this this way to not
+	 * waste time changing all the handlers, in the final version
+	 * I'll change all the handlers if there's not other solution.
+	 */
+	error = phx(table, write, buf, &res, ppos, filp);
 	if (!error)
 		error = res;
 out:
diff --git a/include/linux/inetdevice.h b/include/linux/inetdevice.h
index ae8fdc5..caf06b3 100644
--- a/include/linux/inetdevice.h
+++ b/include/linux/inetdevice.h
@@ -43,8 +43,18 @@ enum
 
 #define IPV4_DEVCONF_MAX (__IPV4_DEVCONF_MAX - 1)
 
+
+struct devinet_sysctl {
+	/* dev_name holds a copy of dev_name, because '.procname' is
+	 * regarded as const by sysctl and we wouldn't want anyone to
+	 * change it under our feet (see SIOCSIFNAME). */
+	char *dev_name;
+	struct ctl_table_header *sysctl_header;
+};
+
+
 struct ipv4_devconf {
-	void	*sysctl;
+	struct devinet_sysctl devinet_sysctl;
 	int	data[IPV4_DEVCONF_MAX];
 	DECLARE_BITMAP(state, IPV4_DEVCONF_MAX);
 };
diff --git a/net/ipv4/devinet.c b/net/ipv4/devinet.c
index 748cb5b..774d347 100644
--- a/net/ipv4/devinet.c
+++ b/net/ipv4/devinet.c
@@ -147,7 +147,7 @@ void in_dev_finish_destroy(struct in_device *idev)
 }
 EXPORT_SYMBOL(in_dev_finish_destroy);
 
-static struct in_device *inetdev_init(struct net_device *dev)
+struct in_device *inetdev_init(struct net_device *dev)
 {
 	struct in_device *in_dev;
 
@@ -158,7 +158,8 @@ static struct in_device *inetdev_init(struct net_device *dev)
 		goto out;
 	memcpy(&in_dev->cnf, dev_net(dev)->ipv4.devconf_dflt,
 			sizeof(in_dev->cnf));
-	in_dev->cnf.sysctl = NULL;
+	in_dev->cnf.devinet_sysctl.dev_name = NULL;
+	in_dev->cnf.devinet_sysctl.sysctl_header = NULL;
 	in_dev->dev = dev;
 	in_dev->arp_parms = neigh_parms_alloc(dev, &arp_tbl);
 	if (!in_dev->arp_parms)
@@ -1375,6 +1376,67 @@ static void inet_forward_change(struct net *net)
 	}
 }
 
+
+
+static int devinet_conf_handler(ctl_table *ctl, int write,
+				void __user *buffer,
+				size_t *lenp, loff_t *ppos,
+				struct file *filp,
+				proc_handler *proc_handler)
+{
+	/* The path to this file is of the form:
+	 *  $PROC_MOUNT/sys/net/ipv4/conf/$DEVNAME/$CTL
+	 *
+	 * The array of 'struct ctl_table' of devinet entries is
+	 * shared between all ipv4 network devices and the 'data'
+	 * field of each structure only hold the offset into the
+	 * 'data' field of 'struct ipv4_devconf'.
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
+	struct in_device *in_dev = NULL;
+	struct ipv4_devconf *cnf;
+	int ret;
+
+	if (strcmp(dev_name, "all") == 0) {
+		cnf = net->ipv4.devconf_all;
+	} else if (strcmp(dev_name, "default") == 0) {
+		cnf = net->ipv4.devconf_dflt;
+	} else {
+		/* the device could have been renamed (SIOCSIFADDR) or
+		 * deleted since we started accessing it's proc sysctl */
+		dev = dev_get_by_name(net, dev_name);
+		if (dev == NULL)
+			return -ENOENT;
+		in_dev = in_dev_get(dev);
+		cnf = &in_dev->cnf;
+	}
+
+	tmp_ctl = *ctl;
+	tmp_ctl.data += (char *)cnf - (char *)&ipv4_devconf;
+	tmp_ctl.extra1 = cnf;
+	tmp_ctl.extra2 = net;
+
+	ret = proc_handler(&tmp_ctl, write, buffer, lenp, ppos);
+
+	if (in_dev)
+		in_dev_put(in_dev);
+	if (dev)
+		dev_put(dev);
+	return ret;
+}
+
 static int devinet_conf_proc(ctl_table *ctl, int write,
 			     void __user *buffer,
 			     size_t *lenp, loff_t *ppos)
@@ -1445,6 +1507,33 @@ static int ipv4_doint_and_flush(ctl_table *ctl, int write,
 	return ret;
 }
 
+static int devinet_conf_proc__(ctl_table *ctl, int write,
+			       void __user *buffer,
+			       size_t *lenp, loff_t *ppos,
+			       struct file *filp)
+{
+	return devinet_conf_handler(ctl, write, buffer, lenp, ppos, filp,
+				    devinet_conf_proc);
+}
+
+static int devinet_sysctl_forward__(ctl_table *ctl, int write,
+				    void __user *buffer,
+				    size_t *lenp, loff_t *ppos,
+				    struct file *filp)
+{
+	return devinet_conf_handler(ctl, write, buffer, lenp, ppos, filp,
+				    devinet_sysctl_forward);
+}
+
+static int ipv4_doint_and_flush__(ctl_table *ctl, int write,
+				  void __user *buffer,
+				  size_t *lenp, loff_t *ppos,
+				  struct file *filp)
+{
+	return devinet_conf_handler(ctl, write, buffer, lenp, ppos, filp,
+				    ipv4_doint_and_flush);
+}
+
 #define DEVINET_SYSCTL_ENTRY(attr, name, mval, proc) \
 	{ \
 		.procname	= name, \
@@ -1452,67 +1541,60 @@ static int ipv4_doint_and_flush(ctl_table *ctl, int write,
 				  IPV4_DEVCONF_ ## attr - 1, \
 		.maxlen		= sizeof(int), \
 		.mode		= mval, \
-		.proc_handler	= proc, \
-		.extra1		= &ipv4_devconf, \
+		.proc_handler	= (proc_handler *) proc, \
 	}
 
 #define DEVINET_SYSCTL_RW_ENTRY(attr, name) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0644, devinet_conf_proc)
+	DEVINET_SYSCTL_ENTRY(attr, name, 0644, devinet_conf_proc__)
 
 #define DEVINET_SYSCTL_RO_ENTRY(attr, name) \
-	DEVINET_SYSCTL_ENTRY(attr, name, 0444, devinet_conf_proc)
+	DEVINET_SYSCTL_ENTRY(attr, name, 0444, devinet_conf_proc__)
 
 #define DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, proc) \
 	DEVINET_SYSCTL_ENTRY(attr, name, 0644, proc)
 
 #define DEVINET_SYSCTL_FLUSHING_ENTRY(attr, name) \
-	DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, ipv4_doint_and_flush)
-
-static struct devinet_sysctl_table {
-	struct ctl_table_header *sysctl_header;
-	struct ctl_table devinet_vars[__IPV4_DEVCONF_MAX];
-	char *dev_name;
-} devinet_sysctl = {
-	.devinet_vars = {
-		DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
-					     devinet_sysctl_forward),
-		DEVINET_SYSCTL_RO_ENTRY(MC_FORWARDING, "mc_forwarding"),
-
-		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_REDIRECTS, "accept_redirects"),
-		DEVINET_SYSCTL_RW_ENTRY(SECURE_REDIRECTS, "secure_redirects"),
-		DEVINET_SYSCTL_RW_ENTRY(SHARED_MEDIA, "shared_media"),
-		DEVINET_SYSCTL_RW_ENTRY(RP_FILTER, "rp_filter"),
-		DEVINET_SYSCTL_RW_ENTRY(SEND_REDIRECTS, "send_redirects"),
-		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
-					"accept_source_route"),
-		DEVINET_SYSCTL_RW_ENTRY(ACCEPT_LOCAL, "accept_local"),
-		DEVINET_SYSCTL_RW_ENTRY(SRC_VMARK, "src_valid_mark"),
-		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
-		DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
-		DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
-		DEVINET_SYSCTL_RW_ENTRY(LOG_MARTIANS, "log_martians"),
-		DEVINET_SYSCTL_RW_ENTRY(TAG, "tag"),
-		DEVINET_SYSCTL_RW_ENTRY(ARPFILTER, "arp_filter"),
-		DEVINET_SYSCTL_RW_ENTRY(ARP_ANNOUNCE, "arp_announce"),
-		DEVINET_SYSCTL_RW_ENTRY(ARP_IGNORE, "arp_ignore"),
-		DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
-		DEVINET_SYSCTL_RW_ENTRY(ARP_NOTIFY, "arp_notify"),
-		DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP_PVLAN, "proxy_arp_pvlan"),
-
-		DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
-		DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
-		DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
-					      "force_igmp_version"),
-		DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
-					      "promote_secondaries"),
-	},
+	DEVINET_SYSCTL_COMPLEX_ENTRY(attr, name, ipv4_doint_and_flush__)
+
+const struct ctl_table ipv4_devinet_sysctl_table[__IPV4_DEVCONF_MAX] = {
+	DEVINET_SYSCTL_COMPLEX_ENTRY(FORWARDING, "forwarding",
+				     devinet_sysctl_forward__),
+	DEVINET_SYSCTL_RO_ENTRY(MC_FORWARDING, "mc_forwarding"),
+
+	DEVINET_SYSCTL_RW_ENTRY(ACCEPT_REDIRECTS, "accept_redirects"),
+	DEVINET_SYSCTL_RW_ENTRY(SECURE_REDIRECTS, "secure_redirects"),
+	DEVINET_SYSCTL_RW_ENTRY(SHARED_MEDIA, "shared_media"),
+	DEVINET_SYSCTL_RW_ENTRY(RP_FILTER, "rp_filter"),
+	DEVINET_SYSCTL_RW_ENTRY(SEND_REDIRECTS, "send_redirects"),
+	DEVINET_SYSCTL_RW_ENTRY(ACCEPT_SOURCE_ROUTE,
+				"accept_source_route"),
+	DEVINET_SYSCTL_RW_ENTRY(ACCEPT_LOCAL, "accept_local"),
+	DEVINET_SYSCTL_RW_ENTRY(SRC_VMARK, "src_valid_mark"),
+	DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP, "proxy_arp"),
+	DEVINET_SYSCTL_RW_ENTRY(MEDIUM_ID, "medium_id"),
+	DEVINET_SYSCTL_RW_ENTRY(BOOTP_RELAY, "bootp_relay"),
+	DEVINET_SYSCTL_RW_ENTRY(LOG_MARTIANS, "log_martians"),
+	DEVINET_SYSCTL_RW_ENTRY(TAG, "tag"),
+	DEVINET_SYSCTL_RW_ENTRY(ARPFILTER, "arp_filter"),
+	DEVINET_SYSCTL_RW_ENTRY(ARP_ANNOUNCE, "arp_announce"),
+	DEVINET_SYSCTL_RW_ENTRY(ARP_IGNORE, "arp_ignore"),
+	DEVINET_SYSCTL_RW_ENTRY(ARP_ACCEPT, "arp_accept"),
+	DEVINET_SYSCTL_RW_ENTRY(ARP_NOTIFY, "arp_notify"),
+	DEVINET_SYSCTL_RW_ENTRY(PROXY_ARP_PVLAN, "proxy_arp_pvlan"),
+
+	DEVINET_SYSCTL_FLUSHING_ENTRY(NOXFRM, "disable_xfrm"),
+	DEVINET_SYSCTL_FLUSHING_ENTRY(NOPOLICY, "disable_policy"),
+	DEVINET_SYSCTL_FLUSHING_ENTRY(FORCE_IGMP_VERSION,
+				      "force_igmp_version"),
+	DEVINET_SYSCTL_FLUSHING_ENTRY(PROMOTE_SECONDARIES,
+				      "promote_secondaries"),
+	{ }
 };
 
 static int __devinet_sysctl_register(struct net *net, char *dev_name,
-					struct ipv4_devconf *p)
+				     struct ipv4_devconf *cnf)
 {
-	int i;
-	struct devinet_sysctl_table *t;
+	struct devinet_sysctl *t = &cnf->devinet_sysctl;
 
 #define DEVINET_CTL_PATH_DEV	3
 
@@ -1524,16 +1606,6 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 		{ },
 	};
 
-	t = kmemdup(&devinet_sysctl, sizeof(*t), GFP_KERNEL);
-	if (!t)
-		goto out;
-
-	for (i = 0; i < ARRAY_SIZE(t->devinet_vars) - 1; i++) {
-		t->devinet_vars[i].data += (char *)p - (char *)&ipv4_devconf;
-		t->devinet_vars[i].extra1 = p;
-		t->devinet_vars[i].extra2 = net;
-	}
-
 	/*
 	 * Make a copy of dev_name, because '.procname' is regarded as const
 	 * by sysctl and we wouldn't want anyone to change it under our feet
@@ -1541,37 +1613,32 @@ static int __devinet_sysctl_register(struct net *net, char *dev_name,
 	 */
 	t->dev_name = kstrdup(dev_name, GFP_KERNEL);
 	if (!t->dev_name)
-		goto free;
+		goto out;
 
 	devinet_ctl_path[DEVINET_CTL_PATH_DEV].procname = t->dev_name;
 
-	t->sysctl_header = register_net_sysctl_table(net, devinet_ctl_path,
-			t->devinet_vars);
+	t->sysctl_header = register_net_sysctl_table_pathdata(net,
+			 devinet_ctl_path, ipv4_devinet_sysctl_table, net);
 	if (!t->sysctl_header)
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
 
 static void __devinet_sysctl_unregister(struct ipv4_devconf *cnf)
 {
-	struct devinet_sysctl_table *t = cnf->sysctl;
+	struct devinet_sysctl *t = &cnf->devinet_sysctl;
 
 	if (t == NULL)
 		return;
 
-	cnf->sysctl = NULL;
 	unregister_sysctl_table(t->sysctl_header);
 	kfree(t->dev_name);
-	kfree(t);
 }
 
 static void devinet_sysctl_register(struct in_device *idev)
-- 
1.7.4.rc1.7.g2cf08.dirty
