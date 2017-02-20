From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v2] net: mpls: Add support for netconf
Date: Mon, 20 Feb 2017 08:03:30 -0800
Message-ID: <1487606610-31984-1-git-send-email-dsa@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, rshearma@brocade.com,
        ebiederm@xmission.com, nicolas.dichtel@6wind.com,
        David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f47.google.com ([74.125.83.47]:36593 "EHLO
        mail-pg0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752707AbdBTQDg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 11:03:36 -0500
Received: by mail-pg0-f47.google.com with SMTP id s67so9782614pgb.3
        for <netdev@vger.kernel.org>; Mon, 20 Feb 2017 08:03:36 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add netconf support to MPLS. Allows userpsace to learn and be notified
of changes to 'input' enable setting per interface.

Acked-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v2
- s/NETCONFA_MPLS_INPUT_ENABLED/NETCONFA_INPUT/g

Nicolas: I kept your Acked-by given the minor change that you also
         agreed to

 include/uapi/linux/netconf.h   |   1 +
 include/uapi/linux/rtnetlink.h |   2 +
 net/mpls/af_mpls.c             | 212 ++++++++++++++++++++++++++++++++++++++++-
 net/mpls/internal.h            |   2 +-
 4 files changed, 214 insertions(+), 3 deletions(-)

diff --git a/include/uapi/linux/netconf.h b/include/uapi/linux/netconf.h
index 45dfad509c4d..159d91c9c2a3 100644
--- a/include/uapi/linux/netconf.h
+++ b/include/uapi/linux/netconf.h
@@ -16,6 +16,7 @@ enum {
 	NETCONFA_MC_FORWARDING,
 	NETCONFA_PROXY_NEIGH,
 	NETCONFA_IGNORE_ROUTES_WITH_LINKDOWN,
+	NETCONFA_INPUT,
 	__NETCONFA_MAX
 };
 #define NETCONFA_MAX	(__NETCONFA_MAX - 1)
diff --git a/include/uapi/linux/rtnetlink.h b/include/uapi/linux/rtnetlink.h
index 8c93ad1ef9ab..6546917d605a 100644
--- a/include/uapi/linux/rtnetlink.h
+++ b/include/uapi/linux/rtnetlink.h
@@ -658,6 +658,8 @@ enum rtnetlink_groups {
 #define RTNLGRP_MPLS_ROUTE	RTNLGRP_MPLS_ROUTE
 	RTNLGRP_NSID,
 #define RTNLGRP_NSID		RTNLGRP_NSID
+	RTNLGRP_MPLS_NETCONF,
+#define RTNLGRP_MPLS_NETCONF	RTNLGRP_MPLS_NETCONF
 	__RTNLGRP_MAX
 };
 #define RTNLGRP_MAX	(__RTNLGRP_MAX - 1)
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index 64d3bf269a26..6859e0e25c64 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -7,6 +7,7 @@
 #include <linux/if_arp.h>
 #include <linux/ipv6.h>
 #include <linux/mpls.h>
+#include <linux/netconf.h>
 #include <linux/vmalloc.h>
 #include <linux/percpu.h>
 #include <net/ip.h>
@@ -960,15 +961,215 @@ static size_t mpls_get_stats_af_size(const struct net_device *dev)
 	return nla_total_size_64bit(sizeof(struct mpls_link_stats));
 }
 
+static int mpls_netconf_fill_devconf(struct sk_buff *skb, struct mpls_dev *mdev,
+				     u32 portid, u32 seq, int event,
+				     unsigned int flags, int type)
+{
+	struct nlmsghdr  *nlh;
+	struct netconfmsg *ncm;
+	bool all = false;
+
+	nlh = nlmsg_put(skb, portid, seq, event, sizeof(struct netconfmsg),
+			flags);
+	if (!nlh)
+		return -EMSGSIZE;
+
+	if (type == NETCONFA_ALL)
+		all = true;
+
+	ncm = nlmsg_data(nlh);
+	ncm->ncm_family = AF_MPLS;
+
+	if (nla_put_s32(skb, NETCONFA_IFINDEX, mdev->dev->ifindex) < 0)
+		goto nla_put_failure;
+
+	if ((all || type == NETCONFA_INPUT) &&
+	    nla_put_s32(skb, NETCONFA_INPUT,
+			mdev->input_enabled) < 0)
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+	return 0;
+
+nla_put_failure:
+	nlmsg_cancel(skb, nlh);
+	return -EMSGSIZE;
+}
+
+static int mpls_netconf_msgsize_devconf(int type)
+{
+	int size = NLMSG_ALIGN(sizeof(struct netconfmsg))
+			+ nla_total_size(4); /* NETCONFA_IFINDEX */
+	bool all = false;
+
+	if (type == NETCONFA_ALL)
+		all = true;
+
+	if (all || type == NETCONFA_INPUT)
+		size += nla_total_size(4);
+
+	return size;
+}
+
+static void mpls_netconf_notify_devconf(struct net *net, int type,
+					struct mpls_dev *mdev)
+{
+	struct sk_buff *skb;
+	int err = -ENOBUFS;
+
+	skb = nlmsg_new(mpls_netconf_msgsize_devconf(type), GFP_KERNEL);
+	if (!skb)
+		goto errout;
+
+	err = mpls_netconf_fill_devconf(skb, mdev, 0, 0, RTM_NEWNETCONF,
+					0, type);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in mpls_netconf_msgsize_devconf() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+
+	rtnl_notify(skb, net, 0, RTNLGRP_MPLS_NETCONF, NULL, GFP_KERNEL);
+	return;
+errout:
+	if (err < 0)
+		rtnl_set_sk_err(net, RTNLGRP_MPLS_NETCONF, err);
+}
+
+static const struct nla_policy devconf_mpls_policy[NETCONFA_MAX + 1] = {
+	[NETCONFA_IFINDEX]	= { .len = sizeof(int) },
+};
+
+static int mpls_netconf_get_devconf(struct sk_buff *in_skb,
+				    struct nlmsghdr *nlh)
+{
+	struct net *net = sock_net(in_skb->sk);
+	struct nlattr *tb[NETCONFA_MAX + 1];
+	struct netconfmsg *ncm;
+	struct net_device *dev;
+	struct mpls_dev *mdev;
+	struct sk_buff *skb;
+	int ifindex;
+	int err;
+
+	err = nlmsg_parse(nlh, sizeof(*ncm), tb, NETCONFA_MAX,
+			  devconf_mpls_policy);
+	if (err < 0)
+		goto errout;
+
+	err = -EINVAL;
+	if (!tb[NETCONFA_IFINDEX])
+		goto errout;
+
+	ifindex = nla_get_s32(tb[NETCONFA_IFINDEX]);
+	dev = __dev_get_by_index(net, ifindex);
+	if (!dev)
+		goto errout;
+
+	mdev = mpls_dev_get(dev);
+	if (!mdev)
+		goto errout;
+
+	err = -ENOBUFS;
+	skb = nlmsg_new(mpls_netconf_msgsize_devconf(NETCONFA_ALL), GFP_KERNEL);
+	if (!skb)
+		goto errout;
+
+	err = mpls_netconf_fill_devconf(skb, mdev,
+					NETLINK_CB(in_skb).portid,
+					nlh->nlmsg_seq, RTM_NEWNETCONF, 0,
+					NETCONFA_ALL);
+	if (err < 0) {
+		/* -EMSGSIZE implies BUG in mpls_netconf_msgsize_devconf() */
+		WARN_ON(err == -EMSGSIZE);
+		kfree_skb(skb);
+		goto errout;
+	}
+	err = rtnl_unicast(skb, net, NETLINK_CB(in_skb).portid);
+errout:
+	return err;
+}
+
+static int mpls_netconf_dump_devconf(struct sk_buff *skb,
+				     struct netlink_callback *cb)
+{
+	struct net *net = sock_net(skb->sk);
+	struct hlist_head *head;
+	struct net_device *dev;
+	struct mpls_dev *mdev;
+	int idx, s_idx;
+	int h, s_h;
+
+	s_h = cb->args[0];
+	s_idx = idx = cb->args[1];
+
+	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
+		idx = 0;
+		head = &net->dev_index_head[h];
+		rcu_read_lock();
+		cb->seq = net->dev_base_seq;
+		hlist_for_each_entry_rcu(dev, head, index_hlist) {
+			if (idx < s_idx)
+				goto cont;
+			mdev = mpls_dev_get(dev);
+			if (!mdev)
+				goto cont;
+			if (mpls_netconf_fill_devconf(skb, mdev,
+						      NETLINK_CB(cb->skb).portid,
+						      cb->nlh->nlmsg_seq,
+						      RTM_NEWNETCONF,
+						      NLM_F_MULTI,
+						      NETCONFA_ALL) < 0) {
+				rcu_read_unlock();
+				goto done;
+			}
+			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
+cont:
+			idx++;
+		}
+		rcu_read_unlock();
+	}
+done:
+	cb->args[0] = h;
+	cb->args[1] = idx;
+
+	return skb->len;
+}
+
 #define MPLS_PERDEV_SYSCTL_OFFSET(field)	\
 	(&((struct mpls_dev *)0)->field)
 
+static int mpls_conf_proc(struct ctl_table *ctl, int write,
+			  void __user *buffer,
+			  size_t *lenp, loff_t *ppos)
+{
+	int oval = *(int *)ctl->data;
+	int ret = proc_dointvec(ctl, write, buffer, lenp, ppos);
+
+	if (write) {
+		struct mpls_dev *mdev = ctl->extra1;
+		int i = (int *)ctl->data - (int *)mdev;
+		struct net *net = ctl->extra2;
+		int val = *(int *)ctl->data;
+
+		if (i == offsetof(struct mpls_dev, input_enabled) &&
+		    val != oval) {
+			mpls_netconf_notify_devconf(net,
+						    NETCONFA_INPUT,
+						    mdev);
+		}
+	}
+
+	return ret;
+}
+
 static const struct ctl_table mpls_dev_table[] = {
 	{
 		.procname	= "input",
 		.maxlen		= sizeof(int),
 		.mode		= 0644,
-		.proc_handler	= proc_dointvec,
+		.proc_handler	= mpls_conf_proc,
 		.data		= MPLS_PERDEV_SYSCTL_OFFSET(input_enabled),
 	},
 	{ }
@@ -978,6 +1179,7 @@ static int mpls_dev_sysctl_register(struct net_device *dev,
 				    struct mpls_dev *mdev)
 {
 	char path[sizeof("net/mpls/conf/") + IFNAMSIZ];
+	struct net *net = dev_net(dev);
 	struct ctl_table *table;
 	int i;
 
@@ -988,8 +1190,11 @@ static int mpls_dev_sysctl_register(struct net_device *dev,
 	/* Table data contains only offsets relative to the base of
 	 * the mdev at this point, so make them absolute.
 	 */
-	for (i = 0; i < ARRAY_SIZE(mpls_dev_table); i++)
+	for (i = 0; i < ARRAY_SIZE(mpls_dev_table); i++) {
 		table[i].data = (char *)mdev + (uintptr_t)table[i].data;
+		table[i].extra1 = mdev;
+		table[i].extra2 = net;
+	}
 
 	snprintf(path, sizeof(path), "net/mpls/conf/%s", dev->name);
 
@@ -1041,6 +1246,7 @@ static struct mpls_dev *mpls_add_dev(struct net_device *dev)
 	if (err)
 		goto free;
 
+	mdev->dev = dev;
 	rcu_assign_pointer(dev->mpls_ptr, mdev);
 
 	return mdev;
@@ -1861,6 +2067,8 @@ static int __init mpls_init(void)
 	rtnl_register(PF_MPLS, RTM_NEWROUTE, mpls_rtm_newroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_DELROUTE, mpls_rtm_delroute, NULL, NULL);
 	rtnl_register(PF_MPLS, RTM_GETROUTE, NULL, mpls_dump_routes, NULL);
+	rtnl_register(PF_MPLS, RTM_GETNETCONF, mpls_netconf_get_devconf,
+		      mpls_netconf_dump_devconf, NULL);
 	err = 0;
 out:
 	return err;
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
index d97243034605..76360d8b9579 100644
--- a/net/mpls/internal.h
+++ b/net/mpls/internal.h
@@ -16,7 +16,7 @@ struct mpls_pcpu_stats {
 
 struct mpls_dev {
 	int				input_enabled;
-
+	struct net_device		*dev;
 	struct mpls_pcpu_stats __percpu	*stats;
 
 	struct ctl_table_header		*sysctl;
-- 
2.1.4
