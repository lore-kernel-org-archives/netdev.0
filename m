From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v5 2/2] net: vrf: Add l3mdev rules on first device create
Date: Wed,  8 Jun 2016 10:55:40 -0700
Message-ID: <1465408540-6251-3-git-send-email-dsa@cumulusnetworks.com>
References: <1465408540-6251-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33176 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079AbcFHRzt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 13:55:49 -0400
Received: by mail-pa0-f43.google.com with SMTP id ec8so4557163pac.0
        for <netdev@vger.kernel.org>; Wed, 08 Jun 2016 10:55:49 -0700 (PDT)
In-Reply-To: <1465408540-6251-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add l3mdev rule per address family when the first VRF device is
created. The rules are installed with a default preference of 1000.
Users can replace the default rule as desired.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
v5
- make pref a macro

v4
- removed module parameter for pref
- changed num_vrfs to add_fib_rules and only add rules once on first
  device create. This allows the user to delete the default rule if
  there is a preference for a different priority

v3
- per Nik's comment changed num_vrfs from atomic to unsigned int; all
  accesses are with rtnl held

v2
- added EXCL flag and EEXISTS check. Appropriate once the exclude fib rule
  patch is accepted
- changed 3rd arg to vrf_fib_rule from 0/1 to false/true

 drivers/net/vrf.c | 106 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 105 insertions(+), 1 deletion(-)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index 1b214ea4619a..e3e693bf0dec 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -35,6 +35,7 @@
 #include <net/route.h>
 #include <net/addrconf.h>
 #include <net/l3mdev.h>
+#include <net/fib_rules.h>
 
 #define RT_FL_TOS(oldflp4) \
 	((oldflp4)->flowi4_tos & (IPTOS_RT_MASK | RTO_ONLINK))
@@ -42,6 +43,9 @@
 #define DRV_NAME	"vrf"
 #define DRV_VERSION	"1.0"
 
+#define FIB_RULE_PREF  1000       /* default preference for FIB rules */
+static bool add_fib_rules = true;
+
 struct net_vrf {
 	struct rtable __rcu	*rth;
 	struct rtable __rcu	*rth_local;
@@ -897,6 +901,91 @@ static const struct ethtool_ops vrf_ethtool_ops = {
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
+	if (nla_put_u32(skb, FRA_PRIORITY, FIB_RULE_PREF))
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
+		goto ipv6_err;
+
+	return 0;
+
+ipv6_err:
+	vrf_fib_rule(dev, AF_INET,  false);
+
+out_err:
+	netdev_err(dev, "Failed to add FIB rules.\n");
+	return err;
+}
+
 static void vrf_setup(struct net_device *dev)
 {
 	ether_setup(dev);
@@ -937,6 +1026,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
+	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
 		return -EINVAL;
@@ -945,7 +1035,21 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
 	dev->priv_flags |= IFF_L3MDEV_MASTER;
 
-	return register_netdevice(dev);
+	err = register_netdevice(dev);
+	if (err)
+		goto out;
+
+	if (add_fib_rules) {
+		err = vrf_add_fib_rules(dev);
+		if (err) {
+			unregister_netdevice(dev);
+			goto out;
+		}
+		add_fib_rules = false;
+	}
+
+out:
+	return err;
 }
 
 static size_t vrf_nl_getsize(const struct net_device *dev)
-- 
2.1.4
