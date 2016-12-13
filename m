From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH net-next 08/27] net/hyperv: remove use of VLAN_TAG_PRESENT
Date: Tue, 13 Dec 2016 01:12:34 +0100 (CET)
Message-ID: <3aef0ad56ef36b48d296ba10672548603a182af5.1481586602.git.mirq-linux@rere.qmqm.pl>
References: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: "K. Y. Srinivasan" <kys@microsoft.com> (maintainer:Hyper-V CORE AND
        DRIVERS),
        Haiyang Zhang <haiyangz@microsoft.com> (maintainer:Hyper-V CORE AND
        DRIVERS),
        devel@linuxdriverproject.org (open list:Hyper-V CORE AND DRIVERS)
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([84.10.57.10]:50222 "EHLO rere.qmqm.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753357AbcLMAMj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 12 Dec 2016 19:12:39 -0500
In-Reply-To: <cover.1481586602.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Michał Mirosław <mirq-linux@rere.qmqm.pl>
---
 drivers/net/hyperv/hyperv_net.h   |  2 +-
 drivers/net/hyperv/netvsc_drv.c   | 13 ++++++-------
 drivers/net/hyperv/rndis_filter.c |  4 ++--
 3 files changed, 9 insertions(+), 10 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 3958ada..b53729e 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -186,7 +186,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 			void **data,
 			struct ndis_tcp_ip_checksum_info *csum_info,
 			struct vmbus_channel *channel,
-			u16 vlan_tci);
+			u16 vlan_tci, bool vlan_present);
 void netvsc_channel_cb(void *context);
 int rndis_filter_open(struct netvsc_device *nvdev);
 int rndis_filter_close(struct netvsc_device *nvdev);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index c9414c0..6597d79 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -595,7 +595,7 @@ void netvsc_linkstatus_callback(struct hv_device *device_obj,
 static struct sk_buff *netvsc_alloc_recv_skb(struct net_device *net,
 				struct hv_netvsc_packet *packet,
 				struct ndis_tcp_ip_checksum_info *csum_info,
-				void *data, u16 vlan_tci)
+				void *data)
 {
 	struct sk_buff *skb;
 
@@ -625,10 +625,6 @@ static struct sk_buff *netvsc_alloc_recv_skb(struct net_device *net,
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 	}
 
-	if (vlan_tci & VLAN_TAG_PRESENT)
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q),
-				       vlan_tci);
-
 	return skb;
 }
 
@@ -641,7 +637,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 				void **data,
 				struct ndis_tcp_ip_checksum_info *csum_info,
 				struct vmbus_channel *channel,
-				u16 vlan_tci)
+				u16 vlan_tci, bool vlan_present)
 {
 	struct net_device *net = hv_get_drvdata(device_obj);
 	struct net_device_context *net_device_ctx = netdev_priv(net);
@@ -664,12 +660,15 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 		net = vf_netdev;
 
 	/* Allocate a skb - TODO direct I/O to pages? */
-	skb = netvsc_alloc_recv_skb(net, packet, csum_info, *data, vlan_tci);
+	skb = netvsc_alloc_recv_skb(net, packet, csum_info, *data);
 	if (unlikely(!skb)) {
 		++net->stats.rx_dropped;
 		return NVSP_STAT_FAIL;
 	}
 
+	if (vlan_present)
+		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_tci);
+
 	if (net != vf_netdev)
 		skb_record_rx_queue(skb,
 				    channel->offermsg.offer.sub_channel_index);
diff --git a/drivers/net/hyperv/rndis_filter.c b/drivers/net/hyperv/rndis_filter.c
index 8d90904..7f7b410 100644
--- a/drivers/net/hyperv/rndis_filter.c
+++ b/drivers/net/hyperv/rndis_filter.c
@@ -381,13 +381,13 @@ static int rndis_filter_receive_data(struct rndis_device *dev,
 
 	vlan = rndis_get_ppi(rndis_pkt, IEEE_8021Q_INFO);
 	if (vlan) {
-		vlan_tci = VLAN_TAG_PRESENT | vlan->vlanid |
+		vlan_tci = vlan->vlanid |
 			(vlan->pri << VLAN_PRIO_SHIFT);
 	}
 
 	csum_info = rndis_get_ppi(rndis_pkt, TCPIP_CHKSUM_PKTINFO);
 	return netvsc_recv_callback(net_device_ctx->device_ctx, pkt, data,
-				    csum_info, channel, vlan_tci);
+				    csum_info, channel, vlan_tci, vlan);
 }
 
 int rndis_filter_receive(struct hv_device *dev,
-- 
2.10.2
