From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 4/4] net: dsa: Add netconsole support
Date: Fri, 31 Jul 2015 11:42:57 -0700
Message-ID: <1438368177-23942-5-git-send-email-f.fainelli@gmail.com>
References: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, pgynther@google.com, jaedon.shin@gmail.com,
	Florian Fainelli <f.fainelli@gmail.com>,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	andrew@lunn.ch, cphealy@gmail.com, mathieu@codeaurora.org,
	jonasj76@gmail.com, andrey.volkov@nexvision.fr,
	Chris.Packham@alliedtelesis.co.nz, alexander.h.duyck@redhat.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:35198 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbGaSpV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2015 14:45:21 -0400
Received: by pdrg1 with SMTP id g1so46845710pdr.2
        for <netdev@vger.kernel.org>; Fri, 31 Jul 2015 11:45:20 -0700 (PDT)
In-Reply-To: <1438368177-23942-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for using DSA slave network devices with netconsole, which
requires us to allocate and free custom netpoll instances and invoke the
parent network device poll controller callback.

In order for netconsole to work, we need to construct the DSA tag, but
not queue the skb for transmission on the master network device xmit
function.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/dsa_priv.h |  4 ++++
 net/dsa/slave.c    | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 71 insertions(+)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index eeade901e67a..311796c809af 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -13,6 +13,7 @@
 
 #include <linux/phy.h>
 #include <linux/netdevice.h>
+#include <linux/netpoll.h>
 
 struct dsa_device_ops {
 	struct sk_buff *(*xmit)(struct sk_buff *skb, struct net_device *dev);
@@ -47,6 +48,9 @@ struct dsa_slave_priv {
 	int			old_duplex;
 
 	struct net_device	*bridge_dev;
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	struct netpoll		*netpoll;
+#endif
 };
 
 /* dsa.c */
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 5fc87ee53905..0010c690cc67 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -18,6 +18,7 @@
 #include <net/rtnetlink.h>
 #include <net/switchdev.h>
 #include <linux/if_bridge.h>
+#include <linux/netpoll.h>
 #include "dsa_priv.h"
 
 /* slave mii_bus handling ***************************************************/
@@ -418,6 +419,18 @@ static int dsa_slave_port_attr_get(struct net_device *dev,
 	return 0;
 }
 
+static inline netdev_tx_t dsa_netpoll_send_skb(struct dsa_slave_priv *p,
+					       struct sk_buff *skb)
+{
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	if (p->netpoll)
+		netpoll_send_skb(p->netpoll, skb);
+#else
+	BUG();
+#endif
+	return NETDEV_TX_OK;
+}
+
 static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -431,6 +444,12 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (!nskb)
 		return NETDEV_TX_OK;
 
+	/* SKB for netpoll still need to be mangled with the protocol-specific
+	 * tag to be successfully transmitted
+	 */
+	if (unlikely(netpoll_tx_running(dev)))
+		return dsa_netpoll_send_skb(p, nskb);
+
 	/* Queue the SKB for transmission on the parent interface, but
 	 * do not modify its EtherType
 	 */
@@ -676,6 +695,49 @@ static int dsa_slave_get_eee(struct net_device *dev, struct ethtool_eee *e)
 	return ret;
 }
 
+#ifdef CONFIG_NET_POLL_CONTROLLER
+static int dsa_slave_netpoll_setup(struct net_device *dev,
+				   struct netpoll_info *ni)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->parent;
+	struct net_device *master = ds->dst->master_netdev;
+	struct netpoll *netpoll;
+	int err = 0;
+
+	netpoll = kzalloc(sizeof(*netpoll), GFP_KERNEL);
+	if (!netpoll)
+		return -ENOMEM;
+
+	err = __netpoll_setup(netpoll, master);
+	if (err) {
+		kfree(netpoll);
+		goto out;
+	}
+
+	p->netpoll = netpoll;
+out:
+	return err;
+}
+
+static void dsa_slave_netpoll_cleanup(struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct netpoll *netpoll = p->netpoll;
+
+	if (!netpoll)
+		return;
+
+	p->netpoll = NULL;
+
+	__netpoll_free_async(netpoll);
+}
+
+static void dsa_slave_poll_controller(struct net_device *dev)
+{
+}
+#endif
+
 static const struct ethtool_ops dsa_slave_ethtool_ops = {
 	.get_settings		= dsa_slave_get_settings,
 	.set_settings		= dsa_slave_set_settings,
@@ -708,6 +770,11 @@ static const struct net_device_ops dsa_slave_netdev_ops = {
 	.ndo_fdb_dump		= dsa_slave_fdb_dump,
 	.ndo_do_ioctl		= dsa_slave_ioctl,
 	.ndo_get_iflink		= dsa_slave_get_iflink,
+#ifdef CONFIG_NET_POLL_CONTROLLER
+	.ndo_netpoll_setup	= dsa_slave_netpoll_setup,
+	.ndo_netpoll_cleanup	= dsa_slave_netpoll_cleanup,
+	.ndo_poll_controller	= dsa_slave_poll_controller,
+#endif
 };
 
 static const struct switchdev_ops dsa_slave_switchdev_ops = {
-- 
2.1.0
