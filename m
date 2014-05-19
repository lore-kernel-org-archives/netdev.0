From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next] net: ipv6: trigger action when setting conf.all sysctls
Date: Mon, 19 May 2014 13:09:31 -0400
Message-ID: <1400519372-5703-1-git-send-email-milos.vyletel@gmail.com>
Cc: Milos Vyletel <milos.vyletel@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	netdev@vger.kernel.org (open list:NETWORKING [IPv4/...),
	linux-kernel@vger.kernel.org (open list)
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

As it is right now most of these tunables don't do anything - they don't
set any interface specific settings to the desired value and they don't
take precedence before device specific settings in most cases.

Documentation/networking/ip-sysctl.txt defines them to be:
conf/all/*:
        Change all the interface-specific settings.

but that is not really the case.

Following patch will, when any net.ipv6.conf.all settings are set,
trigger action that will change default as well as all interface
specific settings of same procname. Only sysctls handled by default
proc_dointvec* are being changed. Per device changes are still allowed
and work as before.

Setting accept_dad (just as an example) with this patch looks like this
[root@linux ~]# uname -r
3.15.0-rc5+
[root@linux ~]# sysctl net.ipv6.conf | grep accept_dad
net.ipv6.conf.all.accept_dad = 0
net.ipv6.conf.default.accept_dad = 0
net.ipv6.conf.eth0.accept_dad = 0
net.ipv6.conf.lo.accept_dad = 0
[root@linux ~]# sysctl net.ipv6.conf.all.accept_dad=1
net.ipv6.conf.all.accept_dad = 1
[root@linux ~]# sysctl net.ipv6.conf | grep accept_dad
net.ipv6.conf.all.accept_dad = 1
net.ipv6.conf.default.accept_dad = 1
net.ipv6.conf.eth0.accept_dad = 1
net.ipv6.conf.lo.accept_dad = 1
[root@linux ~]# sysctl net.ipv6.conf.eth0.accept_dad=0
net.ipv6.conf.eth0.accept_dad = 0
[root@linux ~]# sysctl net.ipv6.conf | grep accept_dad
net.ipv6.conf.all.accept_dad = 1
net.ipv6.conf.default.accept_dad = 1
net.ipv6.conf.eth0.accept_dad = 0
net.ipv6.conf.lo.accept_dad = 1

Signed-off-by: Milos Vyletel <milos.vyletel@gmail.com>
---
 net/ipv6/addrconf.c | 157 ++++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 127 insertions(+), 30 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 6c7fa08..f4a1eaa 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -110,6 +110,7 @@ static inline u32 cstamp_delta(unsigned long cstamp)
 #ifdef CONFIG_SYSCTL
 static void addrconf_sysctl_register(struct inet6_dev *idev);
 static void addrconf_sysctl_unregister(struct inet6_dev *idev);
+static int __addrconf_sysctl_all_trigger(struct net *, void *);
 #else
 static inline void addrconf_sysctl_register(struct inet6_dev *idev)
 {
@@ -4922,6 +4923,56 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static
+int addrconf_proc_dointvec(struct ctl_table *ctl, int write,
+			   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	struct inet6_dev *idev = ctl->extra1;
+	struct net *net = ctl->extra2;
+	int ret;
+
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+
+	if (write && idev == NULL)
+		ret = __addrconf_sysctl_all_trigger(net, valp);
+
+	return ret;
+}
+
+static
+int addrconf_proc_dointvec_jiffies(struct ctl_table *ctl, int write,
+			   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	struct inet6_dev *idev = ctl->extra1;
+	struct net *net = ctl->extra2;
+	int ret;
+
+	ret = proc_dointvec_jiffies(ctl, write, buffer, lenp, ppos);
+
+	if (write && idev == NULL)
+		ret = __addrconf_sysctl_all_trigger(net, valp);
+
+	return ret;
+}
+
+static
+int addrconf_proc_dointvec_ms_jiffies(struct ctl_table *ctl, int write,
+			   void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	struct inet6_dev *idev = ctl->extra1;
+	struct net *net = ctl->extra2;
+	int ret;
+
+	ret = proc_dointvec_ms_jiffies(ctl, write, buffer, lenp, ppos);
+
+	if (write && idev == NULL)
+		ret = __addrconf_sysctl_all_trigger(net, valp);
+
+	return ret;
+}
 
 static struct addrconf_sysctl_table
 {
@@ -4942,70 +4993,70 @@ static struct addrconf_sysctl_table
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
 		{
 			.procname	= "mldv1_unsolicited_report_interval",
@@ -5013,7 +5064,7 @@ static struct addrconf_sysctl_table
 				&ipv6_devconf.mldv1_unsolicited_report_interval,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
+			.proc_handler	= addrconf_proc_dointvec_ms_jiffies,
 		},
 		{
 			.procname	= "mldv2_unsolicited_report_interval",
@@ -5021,63 +5072,63 @@ static struct addrconf_sysctl_table
 				&ipv6_devconf.mldv2_unsolicited_report_interval,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec_ms_jiffies,
+			.proc_handler	= addrconf_proc_dointvec_ms_jiffies,
 		},
 		{
 			.procname	= "use_tempaddr",
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
 		{
 			.procname	= "max_addresses",
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
@@ -5085,14 +5136,14 @@ static struct addrconf_sysctl_table
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
@@ -5100,7 +5151,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.accept_ra_rt_info_max_plen,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #endif
 #endif
@@ -5116,7 +5167,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.accept_source_route,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #ifdef CONFIG_IPV6_OPTIMISTIC_DAD
 		{
@@ -5124,7 +5175,7 @@ static struct addrconf_sysctl_table
 			.data           = &ipv6_devconf.optimistic_dad,
 			.maxlen         = sizeof(int),
 			.mode           = 0644,
-			.proc_handler   = proc_dointvec,
+			.proc_handler   = addrconf_proc_dointvec,
 
 		},
 #endif
@@ -5134,7 +5185,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.mc_forwarding,
 			.maxlen		= sizeof(int),
 			.mode		= 0444,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_proc_dointvec,
 		},
 #endif
 		{
@@ -5149,28 +5200,28 @@ static struct addrconf_sysctl_table
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
 			.procname       = "ndisc_notify",
 			.data           = &ipv6_devconf.ndisc_notify,
 			.maxlen         = sizeof(int),
 			.mode           = 0644,
-			.proc_handler   = proc_dointvec
+			.proc_handler   = addrconf_proc_dointvec
 		},
 		{
 			.procname	= "suppress_frag_ndisc",
 			.data		= &ipv6_devconf.suppress_frag_ndisc,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec
+			.proc_handler	= addrconf_proc_dointvec
 		},
 		{
 			/* sentinel */
@@ -5178,6 +5229,52 @@ static struct addrconf_sysctl_table
 	},
 };
 
+static int __addrconf_sysctl_all_trigger(struct net *net, void *p)
+{
+	int i;
+	int size;
+	int *data;
+	struct net_device *dev;
+	struct inet6_dev *idev;
+	struct addrconf_sysctl_table *t;
+
+	BUG_ON(net == NULL);
+	BUG_ON(p == NULL);
+
+	/* locate index in devconf_all sysctl table */
+	t = net->ipv6.devconf_all->sysctl;
+	for (i = 0; (data = t->addrconf_vars[i].data); i++)
+		if (data == p)
+			break;
+	if (data == NULL)
+		return 0;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	/* change default */
+	t = net->ipv6.devconf_dflt->sysctl;
+	data = t->addrconf_vars[i].data;
+	size = t->addrconf_vars[i].maxlen;
+	if (data)
+		memcpy(data, p, size);
+
+	/* change all devices */
+	for_each_netdev(net, dev) {
+		idev = __in6_dev_get(dev);
+		if (idev) {
+			t = idev->cnf.sysctl;
+			data = t->addrconf_vars[i].data;
+			size = t->addrconf_vars[i].maxlen;
+			if (data)
+				memcpy(data, p, size);
+		}
+	}
+
+	rtnl_unlock();
+	return 0;
+}
+
 static int __addrconf_sysctl_register(struct net *net, char *dev_name,
 		struct inet6_dev *idev, struct ipv6_devconf *p)
 {
-- 
1.9.0
