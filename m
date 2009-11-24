From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH 4/4] macvlan: export macvlan mode through netlink
Date: Tue, 24 Nov 2009 00:56:06 +0000
Message-ID: <1259024166-28158-5-git-send-email-arnd@arndb.de>
References: <1259024166-28158-1-git-send-email-arnd@arndb.de>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Patrick Mullaney <pmullaney@novell.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Edge Virtual Bridging <evb@yahoogroups.com>,
	Anna Fischer <anna.fischer@hp.com>,
	bridge@lists.linux-foundation.org,
	virtualization@lists.linux-foundation.org,
	Jens Osterkamp <jens@linux.vnet.ibm.com>,
	Gerhard Stenzel <gerhard.stenzel@de.ibm.com>,
	Patrick McHardy <kaber@trash.net>,
	Mark Smith <lk-netdev@lk-netdev.nosense.org>,
	Arnd Bergmann <arnd@arndb.de>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:63538 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757641AbZKXA5T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Nov 2009 19:57:19 -0500
In-Reply-To: <1259024166-28158-1-git-send-email-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In order to support all three modes of macvlan at
runtime, extend the existing netlink protocol
to allow choosing the mode per macvlan slave
interface.

This depends on a matching patch to iproute2
in order to become accessible in user land.

Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 drivers/net/macvlan.c   |   63 ++++++++++++++++++++++++++++++++++++++++++----
 include/linux/if_link.h |   15 +++++++++++
 2 files changed, 72 insertions(+), 6 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index b840b3a..3db96b9 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -33,12 +33,6 @@
 
 #define MACVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
 
-enum macvlan_mode {
-	MACVLAN_MODE_PRIVATE	= 1,
-	MACVLAN_MODE_VEPA	= 2,
-	MACVLAN_MODE_BRIDGE	= 4,
-};
-
 struct macvlan_port {
 	struct net_device	*dev;
 	struct hlist_head	vlan_hash[MACVLAN_HASH_SIZE];
@@ -600,6 +594,18 @@ static int macvlan_validate(struct nlattr *tb[], struct nlattr *data[])
 		if (!is_valid_ether_addr(nla_data(tb[IFLA_ADDRESS])))
 			return -EADDRNOTAVAIL;
 	}
+
+	if (data && data[IFLA_MACVLAN_MODE]) {
+		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+		switch (mode) {
+		case MACVLAN_MODE_PRIVATE:
+		case MACVLAN_MODE_VEPA:
+		case MACVLAN_MODE_BRIDGE:
+			break;
+		default:
+			return -EINVAL;
+		}
+	}
 	return 0;
 }
 
@@ -664,6 +670,13 @@ static int macvlan_newlink(struct net *src_net, struct net_device *dev,
 	vlan->dev      = dev;
 	vlan->port     = port;
 
+	vlan->mode     = MACVLAN_MODE_VEPA;
+	if (data && data[IFLA_MACVLAN_MODE]) {
+		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+
+		vlan->mode     = mode;
+	}
+
 	err = register_netdevice(dev);
 	if (err < 0)
 		return err;
@@ -685,6 +698,39 @@ static void macvlan_dellink(struct net_device *dev, struct list_head *head)
 		macvlan_port_destroy(port->dev);
 }
 
+static int macvlan_changelink(struct net_device *dev,
+		struct nlattr *tb[], struct nlattr *data[])
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+	if (data && data[IFLA_MACVLAN_MODE]) {
+		u32 mode = nla_get_u32(data[IFLA_MACVLAN_MODE]);
+		vlan->mode     = mode;
+	}
+
+	return 0;
+}
+
+static size_t macvlan_get_size(const struct net_device *dev)
+{
+	return nla_total_size(4);
+}
+
+static int macvlan_fill_info(struct sk_buff *skb,
+				const struct net_device *dev)
+{
+	struct macvlan_dev *vlan = netdev_priv(dev);
+
+	NLA_PUT_U32(skb, IFLA_MACVLAN_MODE, vlan->mode);
+	return 0;
+
+nla_put_failure:
+	return -EMSGSIZE;
+}
+
+static const struct nla_policy macvlan_policy[IFLA_MACVLAN_MAX + 1] = {
+	[IFLA_MACVLAN_MODE] = { .type = NLA_U32 },
+};
+
 static struct rtnl_link_ops macvlan_link_ops __read_mostly = {
 	.kind		= "macvlan",
 	.priv_size	= sizeof(struct macvlan_dev),
@@ -693,6 +739,11 @@ static struct rtnl_link_ops macvlan_link_ops __read_mostly = {
 	.validate	= macvlan_validate,
 	.newlink	= macvlan_newlink,
 	.dellink	= macvlan_dellink,
+	.maxtype	= IFLA_MACVLAN_MAX,
+	.policy		= macvlan_policy,
+	.changelink	= macvlan_changelink,
+	.get_size	= macvlan_get_size,
+	.fill_info	= macvlan_fill_info,
 };
 
 static int macvlan_device_event(struct notifier_block *unused,
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 1d3b242..6674791 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -181,4 +181,19 @@ struct ifla_vlan_qos_mapping {
 	__u32 to;
 };
 
+/* MACVLAN section */
+enum {
+	IFLA_MACVLAN_UNSPEC,
+	IFLA_MACVLAN_MODE,
+	__IFLA_MACVLAN_MAX,
+};
+
+#define IFLA_MACVLAN_MAX (__IFLA_MACVLAN_MAX - 1)
+
+enum macvlan_mode {
+	MACVLAN_MODE_PRIVATE = 1, /* don't talk to other macvlans */
+	MACVLAN_MODE_VEPA    = 2, /* talk to other ports through ext bridge */
+	MACVLAN_MODE_BRIDGE  = 4, /* talk to bridge ports directly */
+};
+
 #endif /* _LINUX_IF_LINK_H */
-- 
1.6.3.3

