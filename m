From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 09/14] rocker: add rtnl ops for port mode [gs]etting
Date: Sun,  4 Oct 2015 23:25:44 +0200
Message-ID: <1443993949-3915-10-git-send-email-jiri@resnulli.us>
References: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, sfeldma@gmail.com, idosch@mellanox.com,
	eladr@mellanox.com, tgraf@suug.ch, ast@plumgrid.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35814 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751984AbbJDV0E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Oct 2015 17:26:04 -0400
Received: by wicge5 with SMTP id ge5so95546576wic.0
        for <netdev@vger.kernel.org>; Sun, 04 Oct 2015 14:26:02 -0700 (PDT)
In-Reply-To: <1443993949-3915-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Introduce a stub for allowing user to change rocker port world/mode.
This is implemented using rtnl changelink op.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 drivers/net/ethernet/rocker/rocker_main.c | 56 +++++++++++++++++++++++++++++++
 include/uapi/linux/if_link.h              | 11 ++++++
 2 files changed, 67 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker_main.c b/drivers/net/ethernet/rocker/rocker_main.c
index 2dda7f9..fb7e8c2 100644
--- a/drivers/net/ethernet/rocker/rocker_main.c
+++ b/drivers/net/ethernet/rocker/rocker_main.c
@@ -5263,6 +5263,61 @@ static void rocker_port_dev_addr_init(struct rocker_port *rocker_port)
 	}
 }
 
+static const struct nla_policy rocker_policy[IFLA_ROCKER_MAX + 1] = {
+	[IFLA_ROCKER_MODE] = { .type = NLA_STRING,
+			       .len = ROCKER_MODE_MAX - 1 },
+};
+
+static int rocker_changelink(struct net_device *dev,
+			     struct nlattr *tb[], struct nlattr *data[])
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	int err;
+
+	if (!data)
+		return 0;
+
+	if (data[IFLA_ROCKER_MODE]) {
+		char mode[ROCKER_MODE_MAX];
+
+		nla_strlcpy(mode, tb[IFLA_ROCKER_MODE], ROCKER_MODE_MAX);
+		err = rocker_port_change_world(rocker_port, mode);
+		if (err)
+			return err;
+	}
+	return 0;
+}
+
+static size_t rocker_get_size(const struct net_device *dev)
+{
+	return nla_total_size(sizeof(u8)) +	/* IFLA_ROCKER_MODE */
+	       0;
+}
+
+static int rocker_fill_info(struct sk_buff *skb,
+			    const struct net_device *dev)
+{
+	struct rocker_port *rocker_port = netdev_priv(dev);
+	const char *mode = rocker_port->world->ops->kind;
+
+	if (nla_put_string(skb, IFLA_ROCKER_MODE, mode))
+		goto nla_put_failure;
+
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static struct rtnl_link_ops rocker_link_ops __read_mostly = {
+	.kind			= "rocker",
+	.maxtype		= IFLA_ROCKER_MAX,
+	.policy			= rocker_policy,
+	.changelink		= rocker_changelink,
+	.get_size		= rocker_get_size,
+	.fill_info		= rocker_fill_info,
+};
+
 static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 {
 	const struct pci_dev *pdev = rocker->pdev;
@@ -5285,6 +5340,7 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	rocker_port_dev_addr_init(rocker_port);
 	dev->netdev_ops = &rocker_port_netdev_ops;
 	dev->ethtool_ops = &rocker_port_ethtool_ops;
+	dev->rtnl_link_ops = &rocker_link_ops;
 	dev->switchdev_ops = &rocker_port_switchdev_ops;
 	netif_napi_add(dev, &rocker_port->napi_tx, rocker_port_poll_tx,
 		       NAPI_POLL_WEIGHT);
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
index 3a5f263..7da768e 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -416,6 +416,17 @@ enum {
 };
 #define IFLA_GENEVE_MAX	(__IFLA_GENEVE_MAX - 1)
 
+/* Rocker section */
+enum {
+	IFLA_ROCKER_UNSPEC,
+	IFLA_ROCKER_MODE,
+	__IFLA_ROCKER_MAX,
+};
+
+#define IFLA_ROCKER_MAX	(__IFLA_ROCKER_MAX - 1)
+
+#define ROCKER_MODE_MAX 16
+
 /* Bonding section */
 
 enum {
-- 
1.9.3
