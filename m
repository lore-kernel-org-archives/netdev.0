From: sfeldma@gmail.com
Subject: [PATCH net-next 4/5] rocker: add offload_fwd_mark support
Date: Wed,  8 Jul 2015 16:16:42 -0700
Message-ID: <1436397403-62412-5-git-send-email-sfeldma@gmail.com>
References: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:35885 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314AbbGHXOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 19:14:18 -0400
Received: by pacgz10 with SMTP id gz10so65708233pac.3
        for <netdev@vger.kernel.org>; Wed, 08 Jul 2015 16:14:17 -0700 (PDT)
In-Reply-To: <1436397403-62412-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

If device flags ingress packet as "fwd offload", mark the
skb->offlaod_fwd_mark using the ingress port's dev->offlaod_fwd_mark.  This
will be the hint to the kernel that this packet has already been forwarded
by device to egress ports matching skb->offlaod_fwd_mark.

For rocker, derive port dev->offlaod_fwd_mark based on device switch ID and
port ifindex.  If port is bridged, use the bridge ifindex rather than the
port ifindex.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   14 +++++++++++++-
 drivers/net/ethernet/rocker/rocker.h |    1 +
 2 files changed, 14 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index c005167..a4ced91 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4787,6 +4787,7 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	const struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
 	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
 	size_t rx_len;
+	u16 rx_flags = 0;
 
 	if (!skb)
 		return -ENOENT;
@@ -4794,6 +4795,8 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_RX_MAX, desc_info);
 	if (!attrs[ROCKER_TLV_RX_FRAG_LEN])
 		return -EINVAL;
+	if (attrs[ROCKER_TLV_RX_FLAGS])
+		rx_flags = rocker_tlv_get_u16(attrs[ROCKER_TLV_RX_FLAGS]);
 
 	rocker_dma_rx_ring_skb_unmap(rocker, attrs);
 
@@ -4801,6 +4804,9 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	skb_put(skb, rx_len);
 	skb->protocol = eth_type_trans(skb, rocker_port->dev);
 
+	if (rx_flags & ROCKER_RX_FLAGS_FWD_OFFLOAD)
+		skb->offload_fwd_mark = rocker_port->dev->offload_fwd_mark;
+
 	rocker_port->dev->stats.rx_packets++;
 	rocker_port->dev->stats.rx_bytes += skb->len;
 
@@ -4938,11 +4944,13 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	}
 	rocker->ports[port_number] = rocker_port;
 
+	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
+
 	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
 
 	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
 	if (err) {
-		dev_err(&pdev->dev, "install ig port table failed\n");
+		netdev_err(rocker_port->dev, "install ig port table failed\n");
 		goto err_port_ig_tbl;
 	}
 
@@ -4962,6 +4970,7 @@ err_untagged_vlan:
 	rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE,
 			   ROCKER_OP_FLAG_REMOVE);
 err_port_ig_tbl:
+	rocker->ports[port_number] = NULL;
 	unregister_netdev(dev);
 err_register_netdev:
 	free_netdev(dev);
@@ -5217,6 +5226,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
 
 	rocker_port->bridge_dev = bridge;
+	switchdev_port_fwd_mark_set(rocker_port->dev, bridge, true);
 
 	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
 				    untagged_vid, 0);
@@ -5237,6 +5247,8 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
 		rocker_port_internal_vlan_id_get(rocker_port,
 						 rocker_port->dev->ifindex);
 
+	switchdev_port_fwd_mark_set(rocker_port->dev, rocker_port->bridge_dev,
+				    false);
 	rocker_port->bridge_dev = NULL;
 
 	err = rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
diff --git a/drivers/net/ethernet/rocker/rocker.h b/drivers/net/ethernet/rocker/rocker.h
index 08b2c3d..12490b2 100644
--- a/drivers/net/ethernet/rocker/rocker.h
+++ b/drivers/net/ethernet/rocker/rocker.h
@@ -246,6 +246,7 @@ enum {
 #define ROCKER_RX_FLAGS_TCP			BIT(5)
 #define ROCKER_RX_FLAGS_UDP			BIT(6)
 #define ROCKER_RX_FLAGS_TCP_UDP_CSUM_GOOD	BIT(7)
+#define ROCKER_RX_FLAGS_FWD_OFFLOAD		BIT(8)
 
 enum {
 	ROCKER_TLV_TX_UNSPEC,
-- 
1.7.10.4
