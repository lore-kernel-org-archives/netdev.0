From: Salil Mehta <salil.mehta@huawei.com>
Subject: [PATCH V2 for-next 7/8] net: hns: bug fix about broadcast/multicast packets
Date: Thu, 29 Sep 2016 18:09:15 +0100
Message-ID: <20160929170916.631972-8-salil.mehta@huawei.com>
References: <20160929170916.631972-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <salil.mehta@huawei.com>, <yisen.zhuang@huawei.com>,
        <xavier.huwei@huawei.com>, <oulijun@huawei.com>,
        <mehta.salil.lnk@gmail.com>, <linux-rdma@vger.kernel.org>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <linuxarm@huawei.com>, Daode Huang <huangdaode@hisilicon.com>
To: <dledford@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga02-in.huawei.com ([119.145.14.65]:41383 "EHLO
        szxga02-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934495AbcI2RLf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 13:11:35 -0400
In-Reply-To: <20160929170916.631972-1-salil.mehta@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daode Huang <huangdaode@hisilicon.com>

When the dsaf mode receives a broadcast packet, it will filter
the packet by comparing the received queue number and destination
queue number(get from forwarding table), if they are the same,
the packet will be filtered. Otherwise, the packet will be loopback.
So this patch select queue 0 to send broadcast and multicast packets.

Signed-off-by: Daode Huang <huangdaode@hisilicon.com>
Reviewed-by: Yisen Zhuang <yisen.zhuang@huawei.com>
Signed-off-by: Salil Mehta <salil.mehta@huawei.com>
---
PATCH v2: Addressed comments by David Miller
          Link: https://lkml.org/lkml/2016/9/28/390
PATCH V1: Initial Submit
---
 drivers/net/ethernet/hisilicon/hns/hns_enet.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/drivers/net/ethernet/hisilicon/hns/hns_enet.c b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
index 09ed237..5494e0e 100644
--- a/drivers/net/ethernet/hisilicon/hns/hns_enet.c
+++ b/drivers/net/ethernet/hisilicon/hns/hns_enet.c
@@ -1597,6 +1597,21 @@ struct rtnl_link_stats64 *hns_nic_get_stats64(struct net_device *ndev,
 	return stats;
 }
 
+static u16
+hns_nic_select_queue(struct net_device *ndev, struct sk_buff *skb,
+		     void *accel_priv, select_queue_fallback_t fallback)
+{
+	struct ethhdr *eth_hdr = (struct ethhdr *)skb->data;
+	struct hns_nic_priv *priv = netdev_priv(ndev);
+
+	/* fix hardware broadcast/multicast packets queue loopback */
+	if (!AE_IS_VER1(priv->enet_ver) &&
+	    is_multicast_ether_addr(eth_hdr->h_dest))
+		return 0;
+	else
+		return fallback(ndev, skb);
+}
+
 static const struct net_device_ops hns_nic_netdev_ops = {
 	.ndo_open = hns_nic_net_open,
 	.ndo_stop = hns_nic_net_stop,
@@ -1612,6 +1627,7 @@ static const struct net_device_ops hns_nic_netdev_ops = {
 	.ndo_poll_controller = hns_nic_poll_controller,
 #endif
 	.ndo_set_rx_mode = hns_nic_set_rx_mode,
+	.ndo_select_queue = hns_nic_select_queue,
 };
 
 static void hns_nic_update_link_status(struct net_device *netdev)
-- 
1.7.9.5
