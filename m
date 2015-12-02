From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH net-next V3 09/17] hv_netvsc: move subchannel existence check to netvsc_select_queue()
Date: Tue,  1 Dec 2015 16:43:11 -0800
Message-ID: <1449016999-9796-9-git-send-email-kys@microsoft.com>
References: <1449016978-9755-1-git-send-email-kys@microsoft.com>
 <1449016999-9796-1-git-send-email-kys@microsoft.com>
Cc: Vitaly Kuznetsov <vkuznets@redhat.com>,
	"K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded04.prod.phx3.secureserver.net ([208.109.80.198]:41323
	"EHLO p3plsmtps2ded04.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932184AbbLAXKe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Dec 2015 18:10:34 -0500
In-Reply-To: <1449016999-9796-1-git-send-email-kys@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vitaly Kuznetsov <vkuznets@redhat.com>

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |   15 ---------------
 drivers/net/hyperv/netvsc.c     |    5 ++---
 drivers/net/hyperv/netvsc_drv.c |    3 +++
 3 files changed, 5 insertions(+), 18 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index e15dc2c..a9d2bdc5 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -1260,19 +1260,4 @@ struct rndis_message {
 #define TRANSPORT_INFO_IPV6_TCP ((INFO_IPV6 << 16) | INFO_TCP)
 #define TRANSPORT_INFO_IPV6_UDP ((INFO_IPV6 << 16) | INFO_UDP)
 
-static inline struct vmbus_channel *get_channel(struct hv_netvsc_packet *packet,
-					struct netvsc_device *net_device)
-
-{
-	struct vmbus_channel *out_channel;
-
-	out_channel = net_device->chn_table[packet->q_idx];
-	if (!out_channel) {
-		out_channel = net_device->dev->channel;
-		packet->q_idx = 0;
-	}
-	return out_channel;
-}
-
-
 #endif /* _HYPERV_NET_H */
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0e0b723..419b055 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -749,8 +749,8 @@ static inline int netvsc_send_pkt(
 	struct netvsc_device *net_device)
 {
 	struct nvsp_message nvmsg;
-	struct vmbus_channel *out_channel = get_channel(packet, net_device);
 	u16 q_idx = packet->q_idx;
+	struct vmbus_channel *out_channel = net_device->chn_table[q_idx];
 	struct net_device *ndev = net_device->ndev;
 	u64 req_id;
 	int ret;
@@ -859,8 +859,7 @@ int netvsc_send(struct hv_device *device,
 	if (!net_device)
 		return -ENODEV;
 
-	out_channel = get_channel(packet, net_device);
-	q_idx = packet->q_idx;
+	out_channel = net_device->chn_table[q_idx];
 
 	packet->send_buf_index = NETVSC_INVALID_INDEX;
 	packet->cp_partial = false;
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 90cc8d9..da3a224 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -272,6 +272,9 @@ static u16 netvsc_select_queue(struct net_device *ndev, struct sk_buff *skb,
 		skb_set_hash(skb, hash, PKT_HASH_TYPE_L3);
 	}
 
+	if (!nvsc_dev->chn_table[q_idx])
+		q_idx = 0;
+
 	return q_idx;
 }
 
-- 
1.7.4.1
