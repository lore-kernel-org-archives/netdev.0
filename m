From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v3 2/2] net: vrf: Add l3mdev rules on first device create
Date: Fri,  3 Jun 2016 12:36:56 -0700
Message-ID: <1464982616-23030-3-git-send-email-dsa@cumulusnetworks.com>
References: <1464982616-23030-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:36629 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932538AbcFCThF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 15:37:05 -0400
Received: by mail-pa0-f51.google.com with SMTP id te7so13625260pab.3
        for <netdev@vger.kernel.org>; Fri, 03 Jun 2016 12:37:04 -0700 (PDT)
In-Reply-To: <1464982616-23030-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add l3mdev rule per address family when the first VRF device is
created. Remove them when the last is deleted.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v3
- per Nik's comment changed num_vrfs from atomic to unsigned int; all
  accesses are with rtnl held

v2
- added EXCL flag and EEXISTS check. Appropriate once the exclude fib rule
  patch is accepted
- changed 3rd arg to vrf_fib_rule from 0/1 to false/true

 drivers/net/vrf.c | 120 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 119 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index d356f5d0f7b0..d81eabe951f5 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -35,6 +35,7 @@
 #include <net/route.h>
 #include <net/addrconf.h>
 #include <net/l3mdev.h>
+#include <net/fib_rules.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -42,6 +43,12 @@
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
+/* only referenced with rtnl held */
+static unsigned int num_vrfs;
+
+static u32 rule_pref = 1000;
+module_param(rule_pref, uint,  S_IRUGO);
+
 struct net_vrf {
 	struct rtable __rcu	*rth;
 	struct rt6_info	__rcu	*rt6;
@@ -729,6 +736,98 @@ static const struct ethtool_ops vrf_ethtool_ops = {
 	.get_drvinfo	= vrf_get_drvinfo,
 };
 
+static inline size_t vrf_fib_rule_nl_size(void)
+{
+	size_t sz;
+
+	sz  = NLMSG_ALIGN(sizeof(struct fib_rule_hdr));
+	sz += nla_total_size(sizeof(u8));	/* FRA_L3MDEV */
+	sz += nla_total_size(sizeof(u32));	/* FRA_PRIORITY */
+
+	return sz;
+}
+
+static int vrf_fib_rule(const struct net_device *dev, __u8 family, bool add_it)
+{
+	struct fib_rule_hdr *frh;
+	struct nlmsghdr *nlh;
+	struct sk_buff *skb;
+	int err;
+
+	skb = nlmsg_new(vrf_fib_rule_nl_size(), GFP_KERNEL);
+	if (!skb)
+		return -ENOMEM;
+
+	nlh = nlmsg_put(skb, 0, 0, 0, sizeof(*frh), 0);
+	if (!nlh)
+		goto nla_put_failure;
+
+	/* rule only needs to appear once */
+	nlh->nlmsg_flags &= NLM_F_EXCL;
+
+	frh = nlmsg_data(nlh);
+	memset(frh, 0, sizeof(*frh));
+	frh->family = family;
+	frh->action = FR_ACT_TO_TBL;
+
+	if (nla_put_u32(skb, FRA_L3MDEV, 1))
+		goto nla_put_failure;
+
+	if (nla_put_u32(skb, FRA_PRIORITY, rule_pref))
+		goto nla_put_failure;
+
+	nlmsg_end(skb, nlh);
+
+	/* fib_nl_{new,del}rule handling looks for net from skb->sk */
+	skb->sk = dev_net(dev)->rtnl;
+	if (add_it) {
+		err = fib_nl_newrule(skb, nlh);
+		if (err == -EEXIST)
+			err = 0;
+	} else {
+		err = fib_nl_delrule(skb, nlh);
+		if (err == -ENOENT)
+			err = 0;
+	}
+	nlmsg_free(skb);
+
+	return err;
+
+nla_put_failure:
+	nlmsg_free(skb);
+
+	return -EMSGSIZE;
+}
+
+static void vrf_del_fib_rules(const struct net_device *dev)
+{
+	if (vrf_fib_rule(dev, AF_INET,  false) ||
+	    vrf_fib_rule(dev, AF_INET6, false)) {
+		netdev_err(dev, "Failed to delete FIB rules.\n");
+	}
+}
+
+static int vrf_add_fib_rules(const struct net_device *dev)
+{
+	int err;
+
+	err = vrf_fib_rule(dev, AF_INET,  true);
+	if (err < 0)
+		goto out_err;
+
+	err = vrf_fib_rule(dev, AF_INET6, true);
+	if (err < 0)
+		goto out_err;
+
+	return 0;
+
+out_err:
+	netdev_err(dev, "Failed to add FIB rules.\n");
+	vrf_del_fib_rules(dev);
+
+	return err;
+}
+
 static void vrf_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -763,12 +862,17 @@ static int vrf_validate(struct nlattr *tb[], struct nlattr *data[])
 static void vrf_dellink(struct net_device *dev, struct list_head *head)
 {
 	unregister_netdevice_queue(dev, head);
+
+	num_vrfs--;
+	if (!num_vrfs)
+		vrf_del_fib_rules(dev);
 }
 
 static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
+	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
 		return -EINVAL;
@@ -777,7 +881,21 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-	return register_netdevice(dev);
+	err = register_netdevice(dev);
+	if (err)
+		goto out;
+
+	if (!num_vrfs) {
+		err = vrf_add_fib_rules(dev);
+		if (err) {
+			unregister_netdevice(dev);
+			goto out;
+		}
+	}
+
+	num_vrfs++;
+out:
+	return err;
 }
 
 static size_t vrf_nl_getsize(const struct net_device *dev)
-- 
2.1.4
