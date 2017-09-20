From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH] hv_netvsc: fix send buffer failure on MTU change
Date: Wed, 20 Sep 2017 11:17:35 -0700
Message-ID: <20170920181735.31316-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, Alex Ng <alexng@microsoft.com>,
        Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net, kys@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f43.google.com ([74.125.83.43]:45658 "EHLO
        mail-pg0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751387AbdITSwe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 14:52:34 -0400
Received: by mail-pg0-f43.google.com with SMTP id 188so2179137pgb.2
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 11:52:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alex Ng <alexng@microsoft.com>

If MTU is changed the host would reject the send buffer change.
This problem is result of recent change to allow changing send
buffer size.

Every time we change the MTU, we store the previous net_device section
count before destroying the buffer, but we don’t store the previous
section size. When we reinitialize the buffer, its size is calculated
by multiplying the previous count and previous size. Since we
continuously increase the MTU, the host returns us a decreasing count
value while the section size is reinitialized to 1728 bytes every
time.

This eventually leads to a condition where the calculated buf_size is
so small that the host rejects it.

Fixes: 8b5327975ae1 ("netvsc: allow controlling send/recv buffer size")
Signed-off-by: Alex Ng <alexng@microsoft.com>
Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h | 2 ++
 drivers/net/hyperv/netvsc.c     | 7 ++-----
 drivers/net/hyperv/netvsc_drv.c | 8 ++++++++
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index d98cdfb1536b..5176be76ca7d 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -150,6 +150,8 @@ struct netvsc_device_info {
 	u32  num_chn;
 	u32  send_sections;
 	u32  recv_sections;
+	u32  send_section_size;
+	u32  recv_section_size;
 };
 
 enum rndis_device_state {
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index a5511b7326af..8d5077fb0492 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -76,9 +76,6 @@ static struct netvsc_device *alloc_net_device(void)
 	net_device->max_pkt = RNDIS_MAX_PKT_DEFAULT;
 	net_device->pkt_align = RNDIS_PKT_ALIGN_DEFAULT;
 
-	net_device->recv_section_size = NETVSC_RECV_SECTION_SIZE;
-	net_device->send_section_size = NETVSC_SEND_SECTION_SIZE;
-
 	init_completion(&net_device->channel_init_wait);
 	init_waitqueue_head(&net_device->subchan_open);
 	INIT_WORK(&net_device->subchan_work, rndis_set_subchannel);
@@ -262,7 +259,7 @@ static int netvsc_init_buf(struct hv_device *device,
 	int ret = 0;
 
 	/* Get receive buffer area. */
-	buf_size = device_info->recv_sections * net_device->recv_section_size;
+	buf_size = device_info->recv_sections * device_info->recv_section_size;
 	buf_size = roundup(buf_size, PAGE_SIZE);
 
 	net_device->recv_buf = vzalloc(buf_size);
@@ -344,7 +341,7 @@ static int netvsc_init_buf(struct hv_device *device,
 		goto cleanup;
 
 	/* Now setup the send buffer. */
-	buf_size = device_info->send_sections * net_device->send_section_size;
+	buf_size = device_info->send_sections * device_info->send_section_size;
 	buf_size = round_up(buf_size, PAGE_SIZE);
 
 	net_device->send_buf = vzalloc(buf_size);
diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index d4902ee5f260..a32ae02e1b6c 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -848,7 +848,9 @@ static int netvsc_set_channels(struct net_device *net,
 	device_info.num_chn = count;
 	device_info.ring_size = ring_size;
 	device_info.send_sections = nvdev->send_section_cnt;
+	device_info.send_section_size = nvdev->send_section_size;
 	device_info.recv_sections = nvdev->recv_section_cnt;
+	device_info.recv_section_size = nvdev->recv_section_size;
 
 	rndis_filter_device_remove(dev, nvdev);
 
@@ -963,7 +965,9 @@ static int netvsc_change_mtu(struct net_device *ndev, int mtu)
 	device_info.ring_size = ring_size;
 	device_info.num_chn = nvdev->num_chn;
 	device_info.send_sections = nvdev->send_section_cnt;
+	device_info.send_section_size = nvdev->send_section_size;
 	device_info.recv_sections = nvdev->recv_section_cnt;
+	device_info.recv_section_size = nvdev->recv_section_size;
 
 	rndis_filter_device_remove(hdev, nvdev);
 
@@ -1485,7 +1489,9 @@ static int netvsc_set_ringparam(struct net_device *ndev,
 	device_info.num_chn = nvdev->num_chn;
 	device_info.ring_size = ring_size;
 	device_info.send_sections = new_tx;
+	device_info.send_section_size = nvdev->send_section_size;
 	device_info.recv_sections = new_rx;
+	device_info.recv_section_size = nvdev->recv_section_size;
 
 	netif_device_detach(ndev);
 	was_opened = rndis_filter_opened(nvdev);
@@ -1934,7 +1940,9 @@ static int netvsc_probe(struct hv_device *dev,
 	device_info.ring_size = ring_size;
 	device_info.num_chn = VRSS_CHANNEL_DEFAULT;
 	device_info.send_sections = NETVSC_DEFAULT_TX;
+	device_info.send_section_size = NETVSC_SEND_SECTION_SIZE;
 	device_info.recv_sections = NETVSC_DEFAULT_RX;
+	device_info.recv_section_size = NETVSC_RECV_SECTION_SIZE;
 
 	nvdev = rndis_filter_device_add(dev, &device_info);
 	if (IS_ERR(nvdev)) {
-- 
2.11.0
