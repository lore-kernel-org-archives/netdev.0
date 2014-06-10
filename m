From: Milos Vyletel <milos.vyletel@gmail.com>
Subject: [patch net-next 5/5] ipv6: copy default config values to interfaces
Date: Tue, 10 Jun 2014 12:19:13 -0400
Message-ID: <1402417153-2551-6-git-send-email-milos.vyletel@gmail.com>
References: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Cc: Milos Vyletel <milos.vyletel@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>,
	Florent Fourcot <florent.fourcot@enst-bretagne.fr>,
	Paul Durrant <Paul.Durrant@citrix.com>,
	linux-kernel@vger.kernel.org (open list)
To: davem@davemloft.net, amwang@redhat.com, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1402417153-2551-1-git-send-email-milos.vyletel@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Propagate changes to default sysctl values to all interfaces if they
were not previously configured and interface was not up before. This is
usually only true during boot when we apply /etc/sysctl.conf values
before network is brought up.

Signed-off-by: Milos Vyletel <milos.vyletel@gmail.com>
---
 include/linux/ipv6.h |  2 ++
 include/net/ipv6.h   |  6 ++++++
 net/ipv6/addrconf.c  | 39 +++++++++++++++++++++++++++++++++++++--
 3 files changed, 45 insertions(+), 2 deletions(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index fe8d38d..e356905 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -1,6 +1,7 @@
 #ifndef _IPV6_H
 #define _IPV6_H
 
+#include <linux/bitmap.h>
 #include <uapi/linux/ipv6.h>
 
 #define ipv6_optlen(p)  (((p)->hdrlen+1) << 3)
@@ -11,6 +12,7 @@
 struct ipv6_devconf {
 	void	*sysctl;
 	__s32	data[IPV6_DEVCONF_MAX];
+	DECLARE_BITMAP(state, IPV6_DEVCONF_MAX);
 };
 
 struct ipv6_params {
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 1ee39a5..eb4e911 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -302,9 +302,15 @@ static inline int ipv6_devconf_get(struct inet6_dev *idev, int index)
 static inline void ipv6_devconf_set(struct inet6_dev *idev, int index,
 				    int val)
 {
+	set_bit(index, idev->cnf.state);
 	idev->cnf.data[index] = val;
 }
 
+static inline void ipv6_devconf_setall(struct inet6_dev *idev)
+{
+	bitmap_fill(idev->cnf.state, IPV6_DEVCONF_MAX);
+}
+
 #define IN6_DEV_CONF_GET(idev, attr) \
 	ipv6_devconf_get((idev), IPV6_DEVCONF_ ## attr)
 #define IN6_DEV_CONF_SET(idev, attr, val) \
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 5b1b578..5218978 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -40,6 +40,7 @@
 
 #define pr_fmt(fmt) "IPv6: " fmt
 
+#include <linux/bitmap.h>
 #include <linux/errno.h>
 #include <linux/types.h>
 #include <linux/kernel.h>
@@ -852,6 +853,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		goto out;
 	}
 
+	ipv6_devconf_setall(idev);
 	neigh_parms_data_state_setall(idev->nd_parms);
 
 	ifa->addr = *addr;
@@ -4897,6 +4899,39 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 	return ret;
 }
 
+static void addrconf_copy_dflt_conf(struct net *net, int i)
+{
+	struct net_device *dev;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		struct inet6_dev *idev = __in6_dev_get(dev);
+
+		if (idev && !test_bit(i, idev->cnf.state))
+			idev->cnf.data[i] = net->ipv6.devconf_dflt->data[i];
+	}
+	rcu_read_unlock();
+}
+
+static int addrconf_sysctl_proc(struct ctl_table *ctl, int write,
+				void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+
+	if (write) {
+		struct ipv6_devconf *cnf = ctl->extra1;
+		struct net *net = ctl->extra2;
+		int i = (int *)ctl->data - cnf->data;
+
+		set_bit(i, cnf->state);
+
+		if (cnf == net->ipv6.devconf_dflt)
+			addrconf_copy_dflt_conf(net, i);
+	}
+
+	return ret;
+}
+
 #define ADDRCONF_SYSCTL_ENTRY(attr, name, mval, proc) \
 	{ \
 		.procname	= #name, \
@@ -4909,10 +4944,10 @@ int addrconf_sysctl_proxy_ndp(struct ctl_table *ctl, int write,
 	}
 
 #define ADDRCONF_SYSCTL_RW_ENTRY(attr, name) \
-	ADDRCONF_SYSCTL_ENTRY(attr, name, 0644, proc_dointvec)
+	ADDRCONF_SYSCTL_ENTRY(attr, name, 0644, addrconf_sysctl_proc)
 
 #define ADDRCONF_SYSCTL_RO_ENTRY(attr, name) \
-	ADDRCONF_SYSCTL_ENTRY(attr, name, 0444, proc_dointvec)
+	ADDRCONF_SYSCTL_ENTRY(attr, name, 0444, addrconf_sysctl_proc)
 
 #define ADDRCONF_SYSCTL_COMPLEX_ENTRY(attr, name, proc) \
 	ADDRCONF_SYSCTL_ENTRY(attr, name, 0644, proc)
-- 
1.9.0
