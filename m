From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v3 06/12] net: dsa: allow switches to work without tagging
Date: Sun, 24 Aug 2014 11:44:23 -0700
Message-ID: <1408905869-10471-7-git-send-email-f.fainelli@gmail.com>
References: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemlof.net, jhs@mojatatu.com, linville@tuxdriver.com,
	alexander.h.duyck@intel.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f171.google.com ([209.85.192.171]:57875 "EHLO
	mail-pd0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753152AbaHXSpK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Aug 2014 14:45:10 -0400
Received: by mail-pd0-f171.google.com with SMTP id z10so18809623pdj.16
        for <netdev@vger.kernel.org>; Sun, 24 Aug 2014 11:45:10 -0700 (PDT)
In-Reply-To: <1408905869-10471-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case switch port tagging is disabled (voluntarily, or the switch just
does not support it), allow us to continue using the master net_device
operations instead of the tag-specific ones.

dsa_protocol_is_tagged() is updated to check that the switch driver
tag_protocol field is not 0 to avoid overriding skb->protocol in the
eth_type_trans().

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v3:
- update logic with the helpers introduced in the firs patch set
- renamed dummy to notag

 include/net/dsa.h |  2 +-
 net/dsa/slave.c   | 25 ++++++++++++++++++++++++-
 2 files changed, 25 insertions(+), 2 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 89b44e8d2dc3..6620d4722efa 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -206,7 +206,7 @@ static inline void *ds_to_priv(struct dsa_switch *ds)
  */
 static inline bool dsa_protocol_is_tagged(struct dsa_switch_tree *dst)
 {
-	return dst->tag_protocol != ETH_P_EDSA;
+	return (dst->tag_protocol != 0) && (dst->tag_protocol != ETH_P_EDSA);
 }
 
 static inline __be16 dsa_tag_protocol(struct dsa_switch_tree *dst)
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index b4b6d457bfd0..35cd8b7a56b8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -332,6 +332,28 @@ static const struct net_device_ops trailer_netdev_ops = {
 };
 #endif
 
+static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb,
+				  struct net_device *dev)
+{
+	struct dsa_slave_priv *p = netdev_priv(dev);
+
+	skb->dev = p->parent->dst->master_netdev;
+	dev_queue_xmit(skb);
+
+	return NETDEV_TX_OK;
+}
+
+static const struct net_device_ops notag_netdev_ops = {
+	.ndo_init		= dsa_slave_init,
+	.ndo_open		= dsa_slave_open,
+	.ndo_stop		= dsa_slave_close,
+	.ndo_start_xmit		= dsa_slave_xmit,
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
+		slave_dev->netdev_ops = &notag_netdev_ops;
+		break;
 	}
 
 	SET_NETDEV_DEV(slave_dev, parent);
-- 
1.9.1
