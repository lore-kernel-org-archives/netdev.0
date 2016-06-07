From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next v4 2/2] net: vrf: Add l3mdev rules on first device create
Date: Mon,  6 Jun 2016 20:35:52 -0700
Message-ID: <1465270552-30925-3-git-send-email-dsa@cumulusnetworks.com>
References: <[PATCH net-next v4 0/2] net: vrf: Improve use of FIB rules>
 <1465270552-30925-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35888 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752972AbcFGDgL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2016 23:36:11 -0400
Received: by mail-pf0-f181.google.com with SMTP id z187so19167060pfz.3
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2016 20:36:05 -0700 (PDT)
In-Reply-To: <1465270552-30925-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add l3mdev rule per address family when the first VRF device is
created. The rules are installed with a default preference of 1000.
Users can replace the default rule as desired.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
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
index d356f5d0f7b0..4bfac107710f 100644
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
 
+static bool add_fib_rules = true;
+static u32 rule_pref = 1000; /* default preference for FIB rules */
+
 struct net_vrf {
 	struct rtable __rcu	*rth;
 	struct rt6_info	__rcu	*rt6;
@@ -729,6 +733,91 @@ static const struct ethtool_ops vrf_ethtool_ops = {
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
@@ -769,6 +858,7 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 		       struct nlattr *tb[], struct nlattr *data[])
 {
 	struct net_vrf *vrf = netdev_priv(dev);
+	int err;
 
 	if (!data || !data[IFLA_VRF_TABLE])
 		return -EINVAL;
@@ -777,7 +867,21 @@ static int vrf_newlink(struct net *src_net, struct net_device *dev,
 
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
