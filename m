From: Felix Jia <felix.jia@alliedtelesis.co.nz>
Subject: [PATCH main-v4.9-rc7] net/ipv6: allow sysctl to change link-local address generation mode
Date: Fri,  2 Dec 2016 15:14:57 +1300
Message-ID: <20161202021457.13163-1-felix.jia@alliedtelesis.co.nz>
Cc: Felix Jia <felix.jia@alliedtelesis.co.nz>,
        Carl Smith <carl.smith@alliedtelesis.co.nz>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate2.alliedtelesis.co.nz ([202.36.163.20]:58142 "EHLO
        gate2.alliedtelesis.co.nz" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750960AbcLBCPb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 21:15:31 -0500
Received: from mmarshal3.atlnz.lc (mmarshal3.atlnz.lc [10.32.18.43])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (Client did not present a certificate)
        by gate2.alliedtelesis.co.nz (Postfix) with ESMTPS id 8C8C18784B
        for <netdev@vger.kernel.org>; Fri,  2 Dec 2016 15:15:27 +1300 (NZDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The address generation mode for IPv6 link-local can only be configured
by netlink messages. This patch adds the ability to change the address
generation mode via sysctl.

An possible improvement is to remove the addrgenmode variable from the
idev structure and use the systcl storage for the flag.

The patch is based from v4.9-rc7 in mainline.

Signed-off-by: Felix Jia <felix.jia@alliedtelesis.co.nz>
Cc: Carl Smith <carl.smith@alliedtelesis.co.nz>
---
 include/linux/ipv6.h      |  1 +
 include/uapi/linux/ipv6.h |  1 +
 net/ipv6/addrconf.c       | 77 ++++++++++++++++++++++++++++++++++++++++++++++-
 3 files changed, 78 insertions(+), 1 deletion(-)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index a064997..0d9e5d4 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -64,6 +64,7 @@ struct ipv6_devconf {
 	} stable_secret;
 	__s32		use_oif_addrs_only;
 	__s32		keep_addr_on_down;
+	__s32		addrgenmode;
 
 	struct ctl_table_header *sysctl_header;
 };
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 8c27723..0524e2c 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -178,6 +178,7 @@ enum {
 	DEVCONF_DROP_UNSOLICITED_NA,
 	DEVCONF_KEEP_ADDR_ON_DOWN,
 	DEVCONF_RTR_SOLICIT_MAX_INTERVAL,
+	DEVCONF_ADDRGENMODE,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 4bc5ba3..8d1f6e6 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -238,6 +238,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
+	.addrgenmode = IN6_ADDR_GEN_MODE_EUI64,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -284,6 +285,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 	.use_oif_addrs_only	= 0,
 	.ignore_routes_with_linkdown = 0,
 	.keep_addr_on_down	= 0,
+	.addrgenmode = IN6_ADDR_GEN_MODE_EUI64,
 };
 
 /* Check if a valid qdisc is available */
@@ -378,7 +380,7 @@ static struct inet6_dev *ipv6_add_dev(struct net_device *dev)
 	if (ndev->cnf.stable_secret.initialized)
 		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_STABLE_PRIVACY;
 	else
-		ndev->addr_gen_mode = IN6_ADDR_GEN_MODE_EUI64;
+		ndev->addr_gen_mode = ipv6_devconf_dflt.addrgenmode;
 
 	ndev->cnf.mtu6 = dev->mtu;
 	ndev->nd_parms = neigh_parms_alloc(dev, &nd_tbl);
@@ -4950,6 +4952,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 	array[DEVCONF_DROP_UNICAST_IN_L2_MULTICAST] = cnf->drop_unicast_in_l2_multicast;
 	array[DEVCONF_DROP_UNSOLICITED_NA] = cnf->drop_unsolicited_na;
 	array[DEVCONF_KEEP_ADDR_ON_DOWN] = cnf->keep_addr_on_down;
+	array[DEVCONF_ADDRGENMODE] = cnf->addrgenmode;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5496,6 +5499,71 @@ int addrconf_sysctl_mtu(struct ctl_table *ctl, int write,
 	return proc_dointvec_minmax(&lctl, write, buffer, lenp, ppos);
 }
 
+static void addrconf_addrgenmode_change(struct net *net)
+{
+	struct net_device *dev;
+	struct inet6_dev *idev;
+
+	read_lock(&dev_base_lock);
+	for_each_netdev(net, dev) {
+		rcu_read_lock();
+		idev = __in6_dev_get(dev);
+		if (idev) {
+			idev->cnf.addrgenmode = ipv6_devconf_dflt.addrgenmode;
+			idev->addr_gen_mode = ipv6_devconf_dflt.addrgenmode;
+			rtnl_lock();
+			addrconf_dev_config(idev->dev);
+			rtnl_unlock();
+		}
+		rcu_read_unlock();
+	}
+	read_unlock(&dev_base_lock);
+}
+
+static int addrconf_sysctl_addrgenmode(struct ctl_table *ctl, int write,
+								void __user *buffer, size_t *lenp, loff_t *ppos)
+{
+	int ret;
+	int new_val;
+	struct inet6_dev *idev = (struct inet6_dev *)ctl->extra1;
+	struct net *net = (struct net *)ctl->extra2;
+
+	if (write) { /* sysctl write request */
+		ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+		new_val = *((int *)ctl->data);
+
+		/* request for the all */
+		if (&net->ipv6.devconf_all->addrgenmode == ctl->data) {
+			ipv6_devconf_dflt.addrgenmode = new_val;
+			addrconf_addrgenmode_change(net);
+
+		/* request for default */
+		} else if (&net->ipv6.devconf_dflt->addrgenmode == ctl->data) {
+			ipv6_devconf_dflt.addrgenmode = new_val;
+
+		/* request for individual inet device */
+		} else {
+			if (!idev) {
+				return ret;
+			}
+			if (idev->addr_gen_mode != new_val) {
+				idev->addr_gen_mode = new_val;
+				rtnl_lock();
+				addrconf_dev_config(idev->dev);
+				rtnl_unlock();
+			}
+		}
+
+	} else { /* sysctl read request */
+		if (idev) {
+			memcpy(ctl->data, &idev->addr_gen_mode, sizeof(idev->addr_gen_mode));
+		}
+		ret = proc_dointvec(ctl, 0, buffer, lenp, ppos);
+	}
+
+	return ret;
+}
+
 static void dev_disable_change(struct inet6_dev *idev)
 {
 	struct netdev_notifier_info info;
@@ -6042,6 +6110,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 
 	},
 	{
+		.procname	= "addrgenmode",
+		.data		= &ipv6_devconf.addrgenmode,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= addrconf_sysctl_addrgenmode,
+	},
+	{
 		/* sentinel */
 	}
 };
-- 
2.10.2
