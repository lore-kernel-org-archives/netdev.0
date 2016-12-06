From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: reduce maximum GSO size
Date: Tue,  6 Dec 2016 13:43:54 -0800
Message-ID: <20161206214354.15473-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:32927 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750813AbcLFVoN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2016 16:44:13 -0500
Received: by mail-pf0-f173.google.com with SMTP id d2so72452922pfd.0
        for <netdev@vger.kernel.org>; Tue, 06 Dec 2016 13:44:11 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hyper-V (and Azure) support using NVGRE which requires some extra space
for encapsulation headers. Because of this the largest allowed TSO
packet is reduced.

For older releases, hard code a fixed reduced value.  For next release,
there is a better solution which uses result of host offload
negotiation.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Please queue this for stable as well.

 drivers/net/hyperv/netvsc_drv.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index f638215..c9140c3 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -47,6 +47,10 @@
 				 NETIF_F_TSO | \
 				 NETIF_F_TSO6 | \
 				 NETIF_F_HW_CSUM)
+
+/* Restrict GSO size to account for NVGRE */
+#define NETVSC_GSO_MAX_SIZE	62768
+
 static int ring_size = 128;
 module_param(ring_size, int, S_IRUGO);
 MODULE_PARM_DESC(ring_size, "Ring buffer size (# of pages)");
@@ -1400,6 +1404,7 @@ static int netvsc_probe(struct hv_device *dev,
 	nvdev = net_device_ctx->nvdev;
 	netif_set_real_num_tx_queues(net, nvdev->num_chn);
 	netif_set_real_num_rx_queues(net, nvdev->num_chn);
+	netif_set_gso_max_size(net, NETVSC_GSO_MAX_SIZE);
 
 	ret = register_netdev(net);
 	if (ret != 0) {
-- 
2.10.2
