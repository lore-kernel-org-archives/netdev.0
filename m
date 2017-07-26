From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v2 07/10] netvsc: allow smaller send/recv buffer size
Date: Wed, 26 Jul 2017 16:40:26 -0700
Message-ID: <20170726234029.7342-8-sthemmin@microsoft.com>
References: <20170726234029.7342-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, linux-doc@vger.kernel.org,
        netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com,
        corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20170726234029.7342-1-sthemmin@microsoft.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The default value of send and receive buffer area for host DMA
is much larger than it needs to be. Experimentation shows that
4M receive and 1M send is sufficient.

Make the size a module parameter so that it can be adjusted
as needed for testing or special needs.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |  2 ++
 drivers/net/hyperv/netvsc.c     | 18 ++++++++++++------
 drivers/net/hyperv/netvsc_drv.c | 31 ++++++++++++++++++++++++++++++-
 3 files changed, 44 insertions(+), 7 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index f2cef5aaed1f..4779422868cf 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -148,6 +148,8 @@ struct netvsc_device_info {
 	unsigned char mac_adr[ETH_ALEN];
 	int  ring_size;
 	u32  num_chn;
+	u32  recv_buf_size;
+	u32  send_buf_size;
 };
 
 enum rndis_device_state {
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c5e6f7fc4f2b..dd64227c736c 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -482,14 +482,16 @@ static int negotiate_nvsp_ver(struct hv_device *device,
 }
 
 static int netvsc_connect_vsp(struct hv_device *device,
-			      struct netvsc_device *net_device)
+			      struct netvsc_device *net_device,
+			      const struct netvsc_device_info *device_info)
 {
 	const u32 ver_list[] = {
 		NVSP_PROTOCOL_VERSION_1, NVSP_PROTOCOL_VERSION_2,
 		NVSP_PROTOCOL_VERSION_4, NVSP_PROTOCOL_VERSION_5
 	};
 	struct nvsp_message *init_packet;
-	int ndis_version, i, ret;
+	u32 max_recv_buf_size, ndis_version;
+	int i, ret;
 
 	init_packet = &net_device->channel_init_pkt;
 
@@ -534,10 +536,14 @@ static int netvsc_connect_vsp(struct hv_device *device,
 
 	/* Post the big receive buffer to NetVSP */
 	if (net_device->nvsp_version <= NVSP_PROTOCOL_VERSION_2)
-		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE_LEGACY;
+		max_recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE_LEGACY;
 	else
-		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
-	net_device->send_buf_size = NETVSC_SEND_BUFFER_SIZE;
+		max_recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
+
+	net_device->recv_buf_size = min(max_recv_buf_size,
+					device_info->recv_buf_size);
+	net_device->send_buf_size = min_t(u32, NETVSC_SEND_BUFFER_SIZE,
+					  device_info->send_buf_size);
 
 	ret = netvsc_init_buf(device, net_device);
 
@@ -1302,7 +1308,7 @@ struct netvsc_device *netvsc_device_add(struct hv_device *device,
 	rcu_assign_pointer(net_device_ctx->nvdev, net_device);
 
 	/* Connect with the NetVsp */
-	ret = netvsc_connect_vsp(device, net_device);
+	ret = netvsc_connect_vsp(device, net_device, device_info);
 	if (ret != 0) {
 		netdev_err(ndev,
 			"unable to connect to NetVSP - %d\n", ret);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 8ff4cbf582cc..b662c0198807 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -44,13 +44,23 @@
 
 #include "hyperv_net.h"
 
-#define RING_SIZE_MIN 64
+#define RING_SIZE_MIN	 64
+#define RECV_BUFFER_MIN	 16
+#define SEND_BUFFER_MIN	 4
 #define LINKCHANGE_INT (2 * HZ)
 
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
 
+static unsigned int recv_buffer_size = (4 * 1024 * 1024) / PAGE_SIZE;
+module_param(recv_buffer_size, uint, S_IRUGO);
+MODULE_PARM_DESC(recv_buffer_size, "Receive buffer size (# of pages)");
+
+static unsigned int send_buffer_size = (1024 * 1024) / PAGE_SIZE;
+module_param(send_buffer_size, uint, S_IRUGO);
+MODULE_PARM_DESC(send_buffer_size, "Send buffer size (# of pages)");
+
 static const u32 default_msg = NETIF_MSG_DRV | NETIF_MSG_PROBE |
 				NETIF_MSG_LINK | NETIF_MSG_IFUP |
 				NETIF_MSG_IFDOWN | NETIF_MSG_RX_ERR |
@@ -751,6 +761,8 @@ static int netvsc_set_channels(struct net_device *net,
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.num_chn = count;
 	device_info.ring_size = ring_size;
+	device_info.send_buf_size = nvdev->send_buf_size;
+	device_info.recv_buf_size = nvdev->recv_buf_size;
 
 	nvdev = rndis_filter_device_add(dev, &device_info);
 	if (!IS_ERR(nvdev)) {
@@ -848,6 +860,8 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
 	device_info.num_chn = nvdev->num_chn;
+	device_info.send_buf_size = nvdev->send_buf_size;
+	device_info.recv_buf_size = nvdev->recv_buf_size;
 
 	rndis_filter_device_remove(hdev, nvdev);
 
@@ -1518,6 +1532,8 @@ static int netvsc_probe(struct hv_device *dev,
 	memset(&device_info, 0, sizeof(device_info));
 	device_info.ring_size = ring_size;
 	device_info.num_chn = VRSS_CHANNEL_DEFAULT;
+	device_info.send_buf_size = send_buffer_size * PAGE_SIZE;
+	device_info.recv_buf_size = recv_buffer_size * PAGE_SIZE;
 
 	nvdev = rndis_filter_device_add(dev, &device_info);
 	if (IS_ERR(nvdev)) {
@@ -1669,6 +1685,19 @@ static int __init netvsc_drv_init(void)
 		pr_info("Increased ring_size to %d (min allowed)\n",
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

