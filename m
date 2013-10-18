From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 7/7] bonding: add Netlink support active_slave option
Date: Fri, 18 Oct 2013 17:43:39 +0200
Message-ID: <1382111019-1102-8-git-send-email-jiri@resnulli.us>
References: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, fubar@us.ibm.com, vfalico@redhat.com,
	andy@greyhouse.net, stephen@networkplumber.org, vyasevic@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:33629 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481Ab3JRPnw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 11:43:52 -0400
Received: by mail-ee0-f54.google.com with SMTP id e53so2126380eek.41
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 08:43:51 -0700 (PDT)
In-Reply-To: <1382111019-1102-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 drivers/net/bonding/bond_netlink.c | 23 ++++++++++++++++++++++-
 include/uapi/linux/if_link.h       |  1 +
 2 files changed, 23 insertions(+), 1 deletion(-)

diff --git a/drivers/net/bonding/bond_netlink.c b/drivers/net/bonding/bond_netlink.c
index a94f870..fe3500b 100644
--- a/drivers/net/bonding/bond_netlink.c
+++ b/drivers/net/bonding/bond_netlink.c
@@ -22,6 +22,7 @@
 
 static const struct nla_policy bond_policy[IFLA_BOND_MAX + 1] = {
 	[IFLA_BOND_MODE]		= { .type = NLA_U8 },
+	[IFLA_BOND_ACTIVE_SLAVE]	= { .type = NLA_U32 },
 };
 
 static int bond_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -48,6 +49,22 @@ static int bond_changelink(struct net_device *bond_dev,
 		if (err)
 			return err;
 	}
+	if (data && data[IFLA_BOND_ACTIVE_SLAVE]) {
+		int ifindex = nla_get_u32(data[IFLA_BOND_ACTIVE_SLAVE]);
+		struct net_device *slave_dev;
+
+		if (ifindex == 0) {
+			slave_dev = NULL;
+		} else {
+			slave_dev = __dev_get_by_index(dev_net(bond_dev),
+						       ifindex);
+			if (!slave_dev)
+				return -ENODEV;
+		}
+		err = bond_option_active_slave_set(bond, slave_dev);
+		if (err)
+			return err;
+	}
 	return 0;
 }
 
@@ -66,14 +83,18 @@ static int bond_newlink(struct net *src_net, struct net_device *bond_dev,
 static size_t bond_get_size(const struct net_device *bond_dev)
 {
 	return nla_total_size(sizeof(u8));	/* IFLA_BOND_MODE */
+		+ nla_total_size(sizeof(u32));	/* IFLA_BOND_ACTIVE_SLAVE */
 }
 
 static int bond_fill_info(struct sk_buff *skb,
 			  const struct net_device *bond_dev)
 {
 	struct bonding *bond = netdev_priv(bond_dev);
+	struct net_device *slave_dev = bond_option_active_slave_get(bond);
 
-	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode))
+	if (nla_put_u8(skb, IFLA_BOND_MODE, bond->params.mode) ||
+	    (slave_dev &&
+	     nla_put_u32(skb, IFLA_BOND_ACTIVE_SLAVE, slave_dev->ifindex)))
 		goto nla_put_failure;
 	return 0;
 
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 06fd3fe..8a1e346 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -330,6 +330,7 @@ struct ifla_vxlan_port_range {
 enum {
 	IFLA_BOND_UNSPEC,
 	IFLA_BOND_MODE,
+	IFLA_BOND_ACTIVE_SLAVE,
 	__IFLA_BOND_MAX,
 };
 
-- 
1.8.3.1
