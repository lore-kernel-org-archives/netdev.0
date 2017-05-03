From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 08/15] netvsc: allow overriding send/recv buffer size
Date: Wed,  3 May 2017 16:01:10 -0700
Message-ID: <20170503230117.20070-9-sthemmin@microsoft.com>
References: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:33927 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752379AbdECXB3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:29 -0400
Received: by mail-pf0-f173.google.com with SMTP id e64so1765944pfd.1
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:29 -0700 (PDT)
In-Reply-To: <20170503230117.20070-1-sthemmin@microsoft.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default value of send and receive buffer area for host DMA
is much larger than it needs to be. Experimentation shows that
a much smaller buffer still keeps same performance; change
from 16M buffer to 4M receive and 1M send.

Make the size a module parameter so that it can be adjusted
as needed for testing or special needs. It would have been
better to use ethtool to control this but ethtool rx/tx parameters
are in number of descriptors not bytes.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |  2 ++
 drivers/net/hyperv/netvsc.c     | 18 ++++++++++--------
 drivers/net/hyperv/netvsc_drv.c | 40 +++++++++++++++++++++++++++++++++++-----
 3 files changed, 47 insertions(+), 13 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 2b4a9b058f6d..21666df4cd35 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -148,6 +148,8 @@ struct netvsc_device_info {
 	unsigned char mac_adr[ETH_ALEN];
 	bool link_state;	/* 0 - link up, 1 - link down */
 	u32  ring_size;
+	u32  recv_buf_size;
+	u32  send_buf_size;
 	u32  max_num_vrss_chns;
 	u32  num_chn;
 };
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 480bd7704b68..59ca5fd6797d 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -488,16 +488,16 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 	return ret;
 }
 
-static int netvsc_connect_vsp(struct hv_device *device)
+static int netvsc_connect_vsp(struct hv_device *device,
+			      const struct netvsc_device_info *device_info)
 {
-	int ret;
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
-	int ndis_version;
 	const u32 ver_list[] = {
 		NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
 		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5 };
-	int i;
+	u32 max_recv_buf_size, ndis_version;
+	int i, ret;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
@@ -546,10 +546,12 @@ static int netvsc_connect_vsp(struct hv_device *device)
 
 	/* Post the big receive buffer to NetVSP */
 	if (net_device->nvsp_version <= NVSP_PROTOCOL_VERSION_2)
-		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE_LEGACY;
+		max_recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE_LEGACY;
 	else
-		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
-	net_device->send_buf_size = NETVSC_SEND_BUFFER_SIZE;
+		max_recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
+
+	net_device->recv_buf_size = min(max_recv_buf_size, device_info->recv_buf_size);
+	net_device->send_buf_size = min_t(u32, NETVSC_SEND_BUFFER_SIZE, device_info->send_buf_size);
 
 	ret = netvsc_init_buf(device);
 
@@ -1360,7 +1362,7 @@ int netvsc_device_add(struct hv_device *device,
 	rcu_assign_pointer(net_device_ctx->nvdev, net_device);
 
 	/* Connect with the NetVsp */
-	ret = netvsc_connect_vsp(device);
+	ret = netvsc_connect_vsp(device, device_info);
 	if (ret != 0) {
 		netdev_err(ndev,
 			"unable to connect to NetVSP - %d\n", ret);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index fb743c78f3dc..ef3a3a46790f 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -40,13 +40,23 @@
 
 #include "hyperv_net.h"
 
-#define RING_SIZE_MIN 64
+#define RING_SIZE_MIN	 64
+#define RECV_BUFFER_MIN	 16
+#define SEND_BUFFER_MIN	 4
 #define LINKCHANGE_INT (2 * HZ)
 
 static unsigned int ring_size = 128;
 module_param(ring_size, uint, 0444);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
+static unsigned int recv_buffer_size = (4 * 1024 * 1024) / PAGE_SIZE;
+module_param(recv_buffer_size, uint, 0444);
+MODULE_PARM_DESC(recv_buffer_size, "Receive buffer size (# of pages)");
+
+static unsigned int send_buffer_size = (1024 * 1024) / PAGE_SIZE;
+module_param(send_buffer_size, uint, 0444);
+MODULE_PARM_DESC(send_buffer_size, "Send buffer size (# of pages)");
+
 static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				NETIF_MSG_IFDOWN | NETIF_MSG_RX_ERR |
@@ -764,8 +774,8 @@ static void netvsc_get_channels(struct net_device *net,
 	}
 }
 
-static int netvsc_set_queues(struct net_device *net, struct hv_device *dev,
-			     u32 num_chn)
+static int netvsc_set_queues(struct net_device *net, struct netvsc_device *nvdev,
+			     struct hv_device *dev, u32 num_chn)
 {
 	struct netvsc_device_info device_info;
 	int ret;
@@ -774,6 +784,8 @@ static int netvsc_set_queues(struct net_device *net, struct hv_device *dev,
 	device_info.num_chn = num_chn;
 	device_info.ring_size = ring_size;
 	device_info.max_num_vrss_chns = num_chn;
+	device_info.send_buf_size = nvdev->send_buf_size;
+	device_info.recv_buf_size = nvdev->recv_buf_size;
 
 	ret = rndis_filter_device_add(dev, &device_info);
 	if (ret)
@@ -824,11 +836,11 @@ static int netvsc_set_channels(struct net_device *net,
 
 	rndis_filter_device_remove(dev, nvdev);
 
-	ret = netvsc_set_queues(net, dev, count);
+	ret = netvsc_set_queues(net, nvdev, dev, count);
 	if (ret == 0)
 		nvdev->num_chn = count;
 	else
-		netvsc_set_queues(net, dev, nvdev->num_chn);
+		netvsc_set_queues(net, nvdev, dev, nvdev->num_chn);
 
 	if (was_running)
 		ret = netvsc_open(net);
@@ -917,6 +929,8 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	device_info.ring_size = ring_size;
 	device_info.num_chn = nvdev->num_chn;
 	device_info.max_num_vrss_chns = nvdev->num_chn;
+	device_info.send_buf_size = nvdev->send_buf_size;
+	device_info.recv_buf_size = nvdev->recv_buf_size;
 
 	rndis_filter_device_remove(hdev, nvdev);
 
@@ -1568,6 +1582,9 @@ static int netvsc_probe(struct hv_device *dev,
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
 	device_info.num_chn = VRSS_CHANNEL_DEFAULT;
+	device_info.send_buf_size = send_buffer_size * PAGE_SIZE;
+	device_info.recv_buf_size = recv_buffer_size * PAGE_SIZE;
+
 	ret = rndis_filter_device_add(dev, &device_info);
 	if (ret != 0) {
 		netdev_err(net, "unable to add netvsc device (ret %d)\n", ret);
@@ -1716,6 +1733,19 @@ static int __init netvsc_drv_init(void)
 		pr_notice("Increased ring_size to %u (min allowed)\n",
 			  ring_size);
 	}
+
+	if (recv_buffer_size < RECV_BUFFER_MIN) {
+		recv_buffer_size = RECV_BUFFER_MIN;
+		pr_notice("Increased receive buffer size to %u (min allowed)\n",
+			  recv_buffer_size);
+	}
+
+	if (send_buffer_size < SEND_BUFFER_MIN) {
+		send_buffer_size = SEND_BUFFER_MIN;
+		pr_notice("Increased receive buffer size to %u (min allowed)\n",
+			  send_buffer_size);
+	}
+
 	ret = vmbus_driver_register(&netvsc_drv);
 
 	if (ret)
-- 
2.11.0
