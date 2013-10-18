From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 6/7] bonding: add Netlink support mode option
Date: Fri, 18 Oct 2013 17:43:38 +0200
Message-ID: <1382111019-1102-7-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:40721 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756317Ab3JRPnu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:50 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so2058978ead.7
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:49 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_netlink.c | 56 ++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h       | 10 +++++++
 2 files changed, 66 insertions(+)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index 3e5c5f8..a94f870 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -20,6 +20,10 @@
 #include <net/rtnetlink.h>
 #include "bonding.h"
 
+static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
+	[IFLA_BOND_MODE]		= { .type = NLA_U8 },
+};
+
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 {
 	if (tb[IFLA_ADDRESS]) {
@@ -31,11 +35,63 @@ static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
 	return 0;
 }
 
+static int bond_changelink(struct net_device *bond_dev,
+			   struct nlattr *tb[], struct nlattr *data[])
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+	int err;
+
+	if (data && data[IFLA_BOND_MODE]) {
+		int mode = nla_get_u8(data[IFLA_BOND_MODE]);
+
+		err = bond_option_mode_set(bond, mode);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
+			struct nlattr *tb[], struct nlattr *data[])
+{
+	int err;
+
+	err = bond_changelink(bond_dev, tb, data);
+	if (err < 0)
+		return err;
+
+	return register_netdevice(bond_dev);
+}
+
+static size_t bond_get_size(const struct net_device *bond_dev)
+{
+	return nla_total_size(sizeof(u8));	/* IFLA_BOND_MODE */
+}
+
+static int bond_fill_info(struct sk_buff *skb,
+			  const struct net_device *bond_dev)
+{
+	struct bonding *bond = netdev_priv(bond_dev);
+
+	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
 struct rtnl_link_ops bond_link_ops __read_mostly = {
 	.kind			= "bond",
 	.priv_size		= sizeof(struct bonding),
 	.setup			= bond_setup,
+	.maxtype		= IFLA_BOND_MAX,
+	.policy			= bond_policy,
 	.validate		= bond_validate,
+	.newlink		= bond_newlink,
+	.changelink		= bond_changelink,
+	.get_size		= bond_get_size,
+	.fill_info		= bond_fill_info,
 	.get_num_tx_queues	= bond_get_num_tx_queues,
 	.get_num_rx_queues	= bond_get_num_tx_queues, /* Use the same number
 							     as for TX queues */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 80394e8..06fd3fe 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -325,6 +325,16 @@ struct ifla_vxlan_port_range {
 	__be16	high;
 };
 
+/* Bonding section */
+
+enum {
+	IFLA_BOND_UNSPEC,
+	IFLA_BOND_MODE,
+	__IFLA_BOND_MAX,
+};
+
+#define IFLA_BOND_MAX	(__IFLA_BOND_MAX - 1)
+
 /* SR-IOV virtual function management section */
 
 enum {
-- 
1.8.3.1
