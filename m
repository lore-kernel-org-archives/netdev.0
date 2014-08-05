From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 06/12] net: dsa: allow switches to work without tagging
Date: Tue,  5 Aug 2014 15:31:40 -0700
Message-ID: <1407277906-19989-7-git-send-email-f.fainelli@gmail.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:64990 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753861AbaHEWcM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 18:32:12 -0400
Received: by mail-pd0-f174.google.com with SMTP id fp1so2092064pdb.33
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 15:32:12 -0700 (PDT)
In-Reply-To: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case switch port tagging is disabled (voluntarily, or the switch just
does not support it), allow us to continue using the master net_device
operations instead of the tag-specific ones.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 25 ++++++++++++++++++++++++-
 1 file changed, 24 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b4b6d457bfd0..d1dfa3d8552f 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -332,6 +332,28 @@ static const struct net_device_ops trailer_netdev_ops = {
 };
 #endif
 
+static netdev_tx_t dsa_slave_dummy_xmit(struct sk_buff *skb,
+					struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	skb->dev = p->parent->dst->master_netdev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops dummy_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
+	.ndo_open		= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= dsa_slave_dummy_xmit,
+	.ndo_change_rx_flags	= dsa_slave_change_rx_flags,
+	.ndo_set_rx_mode	= dsa_slave_set_rx_mode,
+	.ndo_set_mac_address	= dsa_slave_set_mac_address,
+	.ndo_do_ioctl		= dsa_slave_ioctl,
+};
+
 static void dsa_slave_adjust_link(struct net_device *dev)
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
@@ -432,7 +454,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		break;
 #endif
 	default:
-		BUG();
+		slave_dev->netdev_ops = &dummy_netdev_ops;
+		break;
 	}
 
 	SET_NETDEV_DEV(slave_dev, parent);
-- 
1.9.1
