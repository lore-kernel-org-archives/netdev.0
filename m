From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [RFC net-next 06/11] net: dsa: allow switches to working without tagging
Date: Tue, 13 May 2014 22:00:32 -0700
Message-ID: <1400043637-9799-7-git-send-email-f.fainelli@gmail.com>
References: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, Florian Fainelli <f.fainelli@gmail.com>,
	nhorman@tuxdriver.com, andy@greyhouse.net, tgraf@suug.ch,
	dborkman@redhat.com, ogerlitz@mellanox.com, jesse@nicira.com,
	pshelar@nicira.com, azhou@nicira.com, ben@decadent.org.uk,
	stephen@networkplumber.org, jeffrey.t.kirsher@intel.com,
	vyasevic@redhat.com, xiyou.wangcong@gmail.com,
	john.r.fastabend@intel.com, edumazet@google.com, jhs@mojatatu.com,
	sfeldma@cumulusnetworks.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:52215 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754015AbaENFBZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 01:01:25 -0400
Received: by mail-pa0-f42.google.com with SMTP id rd3so1187222pab.29
        for <netdev@vger.kernel.org>; Tue, 13 May 2014 22:01:25 -0700 (PDT)
In-Reply-To: <1400043637-9799-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case switch port tagging is disabled, allow us to continue using the
master net_device operations instead of the tag-specific ones.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
 net/dsa/slave.c | 24 +++++++++++++++++++++++-
 1 file changed, 23 insertions(+), 1 deletion(-)

diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index d2dbd271300a..7b190b6f64e4 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -332,6 +332,27 @@ static const struct net_device_ops trailer_netdev_ops = {
 };
 #endif
 
+static netdev_tx_t dsa_slave_dummy_xmit(struct sk_buff *skb, struct net_device *dev)
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
@@ -422,7 +443,8 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		break;
 #endif
 	default:
-		BUG();
+		slave_dev->netdev_ops = &dummy_netdev_ops;
+		break;
 	}
 
 	parent->of_node = ds->pd->port_dn[port];
-- 
1.9.1
