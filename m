From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v2 4/4] USBNET: ax88179_178a: enable tso if usb host supports sg dma
Date: Mon,  5 Aug 2013 16:47:03 +0800
Message-ID: <1375692423-9497-5-git-send-email-ming.lei@canonical.com>
References: <1375692423-9497-1-git-send-email-ming.lei@canonical.com>
Cc: Oliver Neukum <oneukum@suse.de>,
	Sarah Sharp <sarah.a.sharp@linux.intel.com>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Ming Lei <ming.lei@canonical.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>,
	Alan Stern <stern@rowland.harvard.edu>,
	Freddy Xin <freddy@asix.com.tw>
To: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:36535 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755277Ab3HEIsO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 04:48:14 -0400
In-Reply-To: <1375692423-9497-1-git-send-email-ming.lei@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables 'can_dma_sg' flag for ax88179_178a device
if the attached host controller supports building packet from
discontinuous buffers(DMA SG is possible), so TSO can be enabled
and skb fragment buffers can be passed to usb stack via urb->sg
directly.

With the patch, system CPU utilization decreased ~50% and throughput
increased by ~10% when doing iperf client test on one ARM A15 dual
core board.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ben Hutchings <bhutchings@solarflare.com>
Cc: Grant Grundler <grundler@google.com>
Cc: Oliver Neukum <oneukum@suse.de>
Cc: Alan Stern <stern@rowland.harvard.edu>
Cc: Freddy Xin <freddy@asix.com.tw>
Signed-off-by: Ming Lei <ming.lei@canonical.com>
---
 drivers/net/usb/ax88179_178a.c |   12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index fb0caa2..7a96326 100644
--- a/drivers/net/usb/ax88179_178a.c
+++ b/drivers/net/usb/ax88179_178a.c
@@ -1031,12 +1031,20 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
 	dev->mii.phy_id = 0x03;
 	dev->mii.supports_gmii = 1;
 
+	if (usb_device_no_sg_constraint(dev->udev))
+		dev->can_dma_sg = 1;
+
 	dev->net->features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 			      NETIF_F_RXCSUM;
 
 	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				 NETIF_F_RXCSUM;
 
+	if (dev->can_dma_sg) {
+		dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
+		dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
+	}
+
 	/* Enable checksum offload */
 	*tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
 	       AX_RXCOE_TCPV6 | AX_RXCOE_UDPV6;
@@ -1310,6 +1318,10 @@ static int ax88179_reset(struct usbnet *dev)
 
 	dev->net->hw_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
 				 NETIF_F_RXCSUM;
+	if (dev->can_dma_sg) {
+		dev->net->features |= NETIF_F_SG | NETIF_F_TSO;
+		dev->net->hw_features |= NETIF_F_SG | NETIF_F_TSO;
+	}
 
 	/* Enable checksum offload */
 	*tmp = AX_RXCOE_IP | AX_RXCOE_TCP | AX_RXCOE_UDP |
-- 
1.7.9.5
