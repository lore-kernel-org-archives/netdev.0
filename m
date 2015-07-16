From: sfeldma@gmail.com
Subject: [PATCH net-next v2 4/5] rocker: add offload_fwd_mark support
Date: Thu, 16 Jul 2015 01:04:56 -0700
Message-ID: <1437033897-8050-5-git-send-email-sfeldma@gmail.com>
References: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com,
	simon.horman@netronome.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f48.google.com ([209.85.220.48]:34814 "EHLO
	mail-pa0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754045AbbGPICs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Jul 2015 04:02:48 -0400
Received: by pacan13 with SMTP id an13so38941588pac.1
        for <netdev@vger.kernel.org>; Thu, 16 Jul 2015 01:02:47 -0700 (PDT)
In-Reply-To: <1437033897-8050-1-git-send-email-sfeldma@gmail.com>
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
 drivers/net/ethernet/rocker/rocker.c |   11 +++++++++++
 drivers/net/ethernet/rocker/rocker.h |    1 +
 2 files changed, 12 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 9324283..0fdfa47 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4800,6 +4800,7 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	const struct rocker_tlv *attrs[ROCKER_TLV_RX_MAX + 1];
 	struct sk_buff *skb = rocker_desc_cookie_ptr_get(desc_info);
 	size_t rx_len;
+	u16 rx_flags = 0;
 
 	if (!skb)
 		return -ENOENT;
@@ -4807,6 +4808,8 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	rocker_tlv_parse_desc(attrs, ROCKER_TLV_RX_MAX, desc_info);
 	if (!attrs[ROCKER_TLV_RX_FRAG_LEN])
 		return -EINVAL;
+	if (attrs[ROCKER_TLV_RX_FLAGS])
+		rx_flags = rocker_tlv_get_u16(attrs[ROCKER_TLV_RX_FLAGS]);
 
 	rocker_dma_rx_ring_skb_unmap(rocker, attrs);
 
@@ -4814,6 +4817,9 @@ static int rocker_port_rx_proc(const struct rocker *rocker,
 	skb_put(skb, rx_len);
 	skb->protocol = eth_type_trans(skb, rocker_port->dev);
 
+	if (rx_flags & ROCKER_RX_FLAGS_FWD_OFFLOAD)
+		skb->offload_fwd_mark = rocker_port->dev->offload_fwd_mark;
+
 	rocker_port->dev->stats.rx_packets++;
 	rocker_port->dev->stats.rx_bytes += skb->len;
 
@@ -4951,6 +4957,8 @@ static int rocker_probe_port(struct rocker *rocker, unsigned int port_number)
 	}
 	rocker->ports[port_number] = rocker_port;
 
+	switchdev_port_fwd_mark_set(rocker_port->dev, NULL, false);
+
 	rocker_port_set_learning(rocker_port, SWITCHDEV_TRANS_NONE);
 
 	err = rocker_port_ig_tbl(rocker_port, SWITCHDEV_TRANS_NONE, 0);
@@ -5230,6 +5238,7 @@ static int rocker_port_bridge_join(struct rocker_port *rocker_port,
 		rocker_port_internal_vlan_id_get(rocker_port, bridge->ifindex);
 
 	rocker_port->bridge_dev = bridge;
+	switchdev_port_fwd_mark_set(rocker_port->dev, bridge, true);
 
 	return rocker_port_vlan_add(rocker_port, SWITCHDEV_TRANS_NONE,
 				    untagged_vid, 0);
@@ -5250,6 +5259,8 @@ static int rocker_port_bridge_leave(struct rocker_port *rocker_port)
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
