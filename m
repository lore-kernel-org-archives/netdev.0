From: David Forster <dforster@brocade.com>
Subject: [PATCH net]ipv6: Provide ipv6 version of "disable_policy" sysctl
Date: Thu, 23 Feb 2017 16:27:18 +0000
Message-ID: <1487867238-27179-1-git-send-email-dforster@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:53206 "EHLO
        mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751041AbdBWRut (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:50:49 -0500
Received: from pps.filterd (m0048192.ppops.net [127.0.0.1])
        by mx0b-000f0801.pphosted.com (8.16.0.20/8.16.0.20) with SMTP id v1NGP8AM020119
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 08:27:43 -0800
Received: from brmwp-exmb12.corp.brocade.com ([208.47.132.227])
        by mx0b-000f0801.pphosted.com with ESMTP id 28scup4qv0-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-SHA384 bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2017 08:27:43 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides equivalent functionality to the existing ipv4
"disable_policy" systcl. ie. Allows IPsec processing to be skipped
on terminating packets on a per-interface basis.

Signed-off-by: David Forster <dforster@brocade.com>
---
 include/linux/ipv6.h      |   1 +
 include/uapi/linux/ipv6.h |   1 +
 net/ipv6/addrconf.c       | 114 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 116 insertions(+)

diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
index 71be5b3..f0d79bd 100644
--- a/include/linux/ipv6.h
+++ b/include/linux/ipv6.h
@@ -70,6 +70,7 @@ struct ipv6_devconf {
 #endif
 	__u32		enhanced_dad;
 	__u32		addr_gen_mode;
+	__s32		disable_policy;
 
 	struct ctl_table_header *sysctl_header;
 };
diff --git a/include/uapi/linux/ipv6.h b/include/uapi/linux/ipv6.h
index 8ef9e75..d8f6a1a 100644
--- a/include/uapi/linux/ipv6.h
+++ b/include/uapi/linux/ipv6.h
@@ -183,6 +183,7 @@ enum {
 	DEVCONF_SEG6_REQUIRE_HMAC,
 	DEVCONF_ENHANCED_DAD,
 	DEVCONF_ADDR_GEN_MODE,
+	DEVCONF_DISABLE_POLICY,
 	DEVCONF_MAX
 };
 
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 3a2025f..615646b 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -244,6 +244,7 @@ static struct ipv6_devconf ipv6_devconf __read_mostly = {
 #endif
 	.enhanced_dad           = 1,
 	.addr_gen_mode		= IN6_ADDR_GEN_MODE_EUI64,
+	.disable_policy		= 0,
 };
 
 static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
@@ -296,6 +297,7 @@ static struct ipv6_devconf ipv6_devconf_dflt __read_mostly = {
 #endif
 	.enhanced_dad           = 1,
 	.addr_gen_mode		= IN6_ADDR_GEN_MODE_EUI64,
+	.disable_policy		= 0,
 };
 
 /* Check if a valid qdisc is available */
@@ -943,6 +945,7 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 	      const struct in6_addr *peer_addr, int pfxlen,
 	      int scope, u32 flags, u32 valid_lft, u32 prefered_lft)
 {
+	struct net *net = dev_net(idev->dev);
 	struct inet6_ifaddr *ifa = NULL;
 	struct rt6_info *rt;
 	unsigned int hash;
@@ -989,6 +992,10 @@ ipv6_add_addr(struct inet6_dev *idev, const struct in6_addr *addr,
 		goto out;
 	}
 
+	if (net->ipv6.devconf_all->disable_policy ||
+	    idev->cnf.disable_policy)
+		rt->dst.flags |= DST_NOPOLICY;
+
 	neigh_parms_data_state_setall(idev->nd_parms);
 
 	ifa->addr = *addr;
@@ -5002,6 +5009,7 @@ static inline void ipv6_store_devconf(struct ipv6_devconf *cnf,
 #endif
 	array[DEVCONF_ENHANCED_DAD] = cnf->enhanced_dad;
 	array[DEVCONF_ADDR_GEN_MODE] = cnf->addr_gen_mode;
+	array[DEVCONF_DISABLE_POLICY] = cnf->disable_policy;
 }
 
 static inline size_t inet6_ifla6_size(void)
@@ -5818,6 +5826,105 @@ int addrconf_sysctl_ignore_routes_with_linkdown(struct ctl_table *ctl,
 	return ret;
 }
 
+static
+void addrconf_set_nopolicy(struct rt6_info *rt, int action)
+{
+	if (rt) {
+		if (action)
+			rt->dst.flags |= DST_NOPOLICY;
+		else
+			rt->dst.flags &= ~DST_NOPOLICY;
+	}
+}
+
+static
+void addrconf_disable_policy_idev(struct inet6_dev *idev, int val)
+{
+	struct inet6_ifaddr *ifa;
+
+	read_lock_bh(&idev->lock);
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
+		spin_lock(&ifa->lock);
+		if (ifa->rt) {
+			struct rt6_info *rt = ifa->rt;
+			struct fib6_table *table = rt->rt6i_table;
+			int cpu;
+
+			read_lock(&table->tb6_lock);
+			addrconf_set_nopolicy(ifa->rt, val);
+			if (rt->rt6i_pcpu) {
+				for_each_possible_cpu(cpu) {
+					struct rt6_info **rtp;
+
+					rtp = per_cpu_ptr(rt->rt6i_pcpu, cpu);
+					addrconf_set_nopolicy(*rtp, val);
+				}
+			}
+			read_unlock(&table->tb6_lock);
+		}
+		spin_unlock(&ifa->lock);
+	}
+	read_unlock_bh(&idev->lock);
+}
+
+static
+int addrconf_disable_policy(struct ctl_table *ctl, int *valp, int val)
+{
+	struct inet6_dev *idev;
+	struct net *net;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	*valp = val;
+
+	net = (struct net *)ctl->extra2;
+	if (valp == &net->ipv6.devconf_dflt->disable_policy) {
+		rtnl_unlock();
+		return 0;
+	}
+
+	if (valp == &net->ipv6.devconf_all->disable_policy)  {
+		struct net_device *dev;
+
+		for_each_netdev(net, dev) {
+			idev = __in6_dev_get(dev);
+			if (idev)
+				addrconf_disable_policy_idev(idev, val);
+		}
+	} else {
+		idev = (struct inet6_dev *)ctl->extra1;
+		addrconf_disable_policy_idev(idev, val);
+	}
+
+	rtnl_unlock();
+	return 0;
+}
+
+static
+int addrconf_sysctl_disable_policy(struct ctl_table *ctl, int write,
+				   void __user *buffer, size_t *lenp,
+				   loff_t *ppos)
+{
+	int *valp = ctl->data;
+	int val = *valp;
+	loff_t pos = *ppos;
+	struct ctl_table lctl;
+	int ret;
+
+	lctl = *ctl;
+	lctl.data = &val;
+	ret = proc_dointvec(&lctl, write, buffer, lenp, ppos);
+
+	if (write && (*valp != val))
+		ret = addrconf_disable_policy(ctl, valp, val);
+
+	if (ret)
+		*ppos = pos;
+
+	return ret;
+}
+
 static int minus_one = -1;
 static const int one = 1;
 static const int two_five_five = 255;
@@ -6176,6 +6283,13 @@ static const struct ctl_table addrconf_sysctl[] = {
 		.proc_handler	= addrconf_sysctl_addr_gen_mode,
 	},
 	{
+		.procname       = "disable_policy",
+		.data           = &ipv6_devconf.disable_policy,
+		.maxlen         = sizeof(int),
+		.mode           = 0644,
+		.proc_handler   = addrconf_sysctl_disable_policy,
+	},
+	{
 		/* sentinel */
 	}
 };
-- 
2.1.4
