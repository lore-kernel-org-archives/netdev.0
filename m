From: Mathieu Trudel-Lapierre <mathieu.trudel-lapierre@canonical.com>
Subject: [PATCH] ipv6: make the net.ipv6.conf.all.use_tempaddr sysctl propagate to interface settings
Date: Fri, 16 Dec 2011 16:45:33 -0500
Message-ID: <1324071933-2961-1-git-send-email-mathieu.trudel-lapierre@canonical.com>
Cc: Mathieu Trudel-Lapierre <mathieu.trudel-lapierre@canonical.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40087 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760426Ab1LPVqd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Dec 2011 16:46:33 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The description for IPV6_PRIVACY mentions using .../all/use_tempaddr to enable
IPv6 Privacy Extensions, and IP sysctl documentation mentions 'all' as setting
all interface-specific settings. We make sure at least use_tempaddr actually
works as documented.

Signed-off-by: Mathieu Trudel-Lapierre <mathieu.trudel-lapierre@canonical.com>
---
 net/ipv6/addrconf.c |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 files changed, 79 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index cf88df8..a20ab55 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4340,6 +4340,84 @@ int addrconf_sysctl_disable(ctl_table *ctl, int write,
 	return ret;
 }
 
+#ifdef CONFIG_IPV6_PRIVACY
+static void dev_tempaddr_change(struct inet6_dev *idev)
+{
+	if (!idev || !idev->dev)
+		return;
+
+	if (!idev->cnf.disable_ipv6) {
+		/* If ipv6 is enabled, try to bring down and back up the
+		 * interface to get new temporary addresses created
+		 */
+		addrconf_notify(NULL, NETDEV_DOWN, idev->dev);
+		addrconf_notify(NULL, NETDEV_UP, idev->dev);
+	}
+}
+
+static void addrconf_tempaddr_change(struct net *net, __s32 newf)
+{
+	struct net_device *dev;
+	struct inet6_dev *idev;
+
+	rcu_read_lock();
+	for_each_netdev_rcu(net, dev) {
+		idev = __in6_dev_get(dev);
+		if (idev) {
+			int changed = (!idev->cnf.use_tempaddr) ^ (!newf);
+			idev->cnf.use_tempaddr = newf;
+			if (changed)
+				dev_tempaddr_change(idev);
+		}
+	}
+	rcu_read_unlock();
+}
+
+static int addrconf_use_tempaddr(struct ctl_table *table, int *p, int old)
+{
+	struct net *net;
+
+	net = (struct net *)table->extra2;
+
+	if (p == &net->ipv6.devconf_dflt->use_tempaddr)
+		return 0;
+
+	if (!rtnl_trylock()) {
+		/* Restore the original values before restarting */
+		*p = old;
+		return restart_syscall();
+	}
+
+	if (p == &net->ipv6.devconf_all->use_tempaddr) {
+		__s32 newf = net->ipv6.devconf_all->use_tempaddr;
+		net->ipv6.devconf_dflt->use_tempaddr = newf;
+		addrconf_tempaddr_change(net, newf);
+	} else if ((!*p) ^ (!old))
+		dev_tempaddr_change((struct inet6_dev *)table->extra1);
+
+	rtnl_unlock();
+	return 0;
+}
+
+static
+int addrconf_sysctl_tempaddr(ctl_table *ctl, int write,
+			     void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int val = *valp;
+	loff_t pos = *ppos;
+	int ret;
+
+	ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+
+	if (write)
+		ret = addrconf_use_tempaddr(ctl, valp, val);
+	if (ret)
+		*ppos = pos;
+	return ret;
+}
+#endif
+
 static struct addrconf_sysctl_table
 {
 	struct ctl_table_header *sysctl_header;
@@ -4431,7 +4509,7 @@ static struct addrconf_sysctl_table
 			.data		= &ipv6_devconf.use_tempaddr,
 			.maxlen		= sizeof(int),
 			.mode		= 0644,
-			.proc_handler	= proc_dointvec,
+			.proc_handler	= addrconf_sysctl_tempaddr,
 		},
 		{
 			.procname	= "temp_valid_lft",
-- 
1.7.7.3
