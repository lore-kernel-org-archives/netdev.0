From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1] hv_netvsc: Allocate the receive buffer from the correct NUMA node
Date: Thu, 28 May 2015 14:56:26 -0700
Message-ID: <1432850186-31770-1-git-send-email-kys@microsoft.com>
Cc: "K. Y. Srinivasan" <kys@microsoft.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devel@linuxdriverproject.org,
	olaf@aepfle.de, apw@canonical.com, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from p3plsmtps2ded03.prod.phx3.secureserver.net ([208.109.80.60]:39471
	"EHLO p3plsmtps2ded03.prod.phx3.secureserver.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753372AbbE1Ufc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 May 2015 16:35:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allocate the receive bufer from the NUMA node assigned to the primary
channel.

Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/netvsc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index b024968..d187965 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -227,13 +227,18 @@ static int netvsc_init_buf(struct hv_device *device)
 	struct netvsc_device *net_device;
 	struct nvsp_message *init_packet;
 	struct net_device *ndev;
+	int node;
 
 	net_device = get_outbound_net_device(device);
 	if (!net_device)
 		return -ENODEV;
 	ndev = net_device->ndev;
 
-	net_device->recv_buf = vzalloc(net_device->recv_buf_size);
+	node = cpu_to_node(device->channel->target_cpu);
+	net_device->recv_buf = vzalloc_node(net_device->recv_buf_size, node);
+	if (!net_device->recv_buf)
+		net_device->recv_buf = vzalloc(net_device->recv_buf_size);
+
 	if (!net_device->recv_buf) {
 		netdev_err(ndev, "unable to allocate receive "
 			"buffer of size %d\n", net_device->recv_buf_size);
-- 
1.7.4.1
