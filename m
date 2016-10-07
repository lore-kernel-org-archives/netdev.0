From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next v3 4/6] openvswitch: keep vlan tag accelerated on internal device
Date: Fri,  7 Oct 2016 18:07:39 +0200
Message-ID: <e10f83e6907169d243ab0e6475ce61f0ef621d68.1475855896.git.jbenc@redhat.com>
References: <cover.1475855896.git.jbenc@redhat.com>
Cc: pravin shelar <pshelar@ovn.org>, Eric Garver <e@erig.me>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46114 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S936330AbcJGQH5 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 7 Oct 2016 12:07:57 -0400
In-Reply-To: <cover.1475855896.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Disallow turning off of vlan acceleration on internal ports. We need the
vlan tag to be in skb->vlan_tci; otherwise, we would pull it back in
ovs_flow_key_extract, defeating the purpose of setting the vlan acceleration
off in the first place.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
v3: new in v3
---
 net/openvswitch/vport-internal_dev.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/vport-internal_dev.c b/net/openvswitch/vport-internal_dev.c
index e7da29021b38..0531d48eb960 100644
--- a/net/openvswitch/vport-internal_dev.c
+++ b/net/openvswitch/vport-internal_dev.c
@@ -143,6 +143,12 @@ static void internal_set_rx_headroom(struct net_device *dev, int new_hr)
 	dev->needed_headroom = new_hr < 0 ? 0 : new_hr;
 }
 
+static netdev_features_t internal_fix_features(struct net_device *dev,
+					       netdev_features_t features)
+{
+	return features | NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_HW_VLAN_STAG_TX;
+}
+
 static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_open = internal_dev_open,
 	.ndo_stop = internal_dev_stop,
@@ -151,6 +157,7 @@ static const struct net_device_ops internal_dev_netdev_ops = {
 	.ndo_change_mtu = internal_dev_change_mtu,
 	.ndo_get_stats64 = internal_get_stats,
 	.ndo_set_rx_headroom = internal_set_rx_headroom,
+	.ndo_fix_features = internal_fix_features,
 };
 
 static struct rtnl_link_ops internal_dev_link_ops __read_mostly = {
-- 
1.8.3.1
