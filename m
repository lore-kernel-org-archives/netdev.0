From: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
Subject: [PATCH net,stable v2] net: cdc_ncm: update datagram size after changing mtu
Date: Thu, 19 May 2016 11:56:09 +0200
Message-ID: <1463651769-27513-1-git-send-email-robert.dobrowolski@linux.intel.com>
Cc: robert.dobrowolski@linux.intel.com, stable@vger.kernel.org,
	oliver@neukum.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Rafal Redzimski <rafal.f.redzimski@intel.com>
To: linux-usb@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34775 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754095AbcESJ64 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 May 2016 05:58:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rafal Redzimski <rafal.f.redzimski@intel.com>

Current implementation updates the mtu size and notify cdc_ncm
device using USB_CDC_SET_MAX_DATAGRAM_SIZE request about datagram
size change instead of changing rx_urb_size.

Whenever mtu is being changed, datagram size should also be
updated. Also updating maxmtu formula so it takes max_datagram_size with
use of cdc_ncm_max_dgram_size() and not ctx.

Signed-off-by: Robert Dobrowolski <robert.dobrowolski@linux.intel.com>
Signed-off-by: Rafal Redzimski <rafal.f.redzimski@intel.com>
---
Changes in v2:
- Changed the way maxmtu is being calculated. Its now based
on cdc_ncm_max_dgram_size and not on ctx->max_datagram_size.
New datagram size is calculated correctly.

 drivers/net/usb/cdc_ncm.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/usb/cdc_ncm.c b/drivers/net/usb/cdc_ncm.c
index 2fb31ed..53759c3 100644
--- a/drivers/net/usb/cdc_ncm.c
+++ b/drivers/net/usb/cdc_ncm.c
@@ -740,12 +740,14 @@ static void cdc_ncm_free(struct cdc_ncm_ctx *ctx)
 int cdc_ncm_change_mtu(struct net_device *net, int new_mtu)
 {
 	struct usbnet *dev = netdev_priv(net);
-	struct cdc_ncm_ctx *ctx = (struct cdc_ncm_ctx *)dev->data[0];
-	int maxmtu = ctx->max_datagram_size - cdc_ncm_eth_hlen(dev);
+	int maxmtu = cdc_ncm_max_dgram_size(dev) - cdc_ncm_eth_hlen(dev);
 
 	if (new_mtu <= 0 || new_mtu > maxmtu)
 		return -EINVAL;
+
 	net->mtu = new_mtu;
+	cdc_ncm_set_dgram_size(dev, new_mtu + cdc_ncm_eth_hlen(dev));
+
 	return 0;
 }
 EXPORT_SYMBOL_GPL(cdc_ncm_change_mtu);
-- 
1.9.1
