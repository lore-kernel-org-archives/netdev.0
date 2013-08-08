From: Ming Lei <ming.lei@canonical.com>
Subject: [PATCH v4 4/4] USBNET: ax88179_178a: enable tso if usb host supports sg dma
Date: Thu,  8 Aug 2013 21:48:25 +0800
Message-ID: <1375969705-24877-5-git-send-email-ming.lei@canonical.com>
References: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
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
Received: from mail-pb0-f51.google.com ([209.85.160.51]:54410 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965334Ab3HHNuH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Aug 2013 09:50:07 -0400
In-Reply-To: <1375969705-24877-1-git-send-email-ming.lei@canonical.com>
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
 drivers/net/usb/ax88179_178a.c |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/drivers/net/usb/ax88179_178a.c b/drivers/net/usb/ax88179_178a.c
index fb0caa2..3569293 100644
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
-- 
1.7.9.5
