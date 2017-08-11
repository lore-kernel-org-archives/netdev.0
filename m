From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: moved ptp_enable to octeon_device
 structure
Date: Fri, 11 Aug 2017 11:22:09 -0700
Message-ID: <20170811182209.GA1570@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, raghu.vatsavayi@cavium.com,
        derek.chickles@cavium.com, satananda.burla@cavium.com,
        intiyaz.basha@cavium.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0061.outbound.protection.outlook.com ([104.47.41.61]:48296
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752915AbdHKSWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 11 Aug 2017 14:22:16 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Intiyaz Basha <intiyaz.basha@cavium.com>

ptp_enable was a global static variable.  Moved this global variable to
octeon_device structure and removed extra device id check.

Signed-off-by: Intiyaz Basha <intiyaz.basha@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c      | 19 ++++++++++---------
 drivers/net/ethernet/cavium/liquidio/octeon_device.h |  1 +
 2 files changed, 11 insertions(+), 9 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index cbd6287..8bf6dfc 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -78,8 +78,6 @@ int octeon_console_debug_enabled(u32 console)
 	return (console_bitmask >> (console)) & 0x1;
 }
 
-static int ptp_enable = 1;
-
 /* Polling interval for determining when NIC application is alive */
 #define LIQUIDIO_STARTER_POLL_INTERVAL_MS 100
 
@@ -1363,6 +1361,13 @@ liquidio_probe(struct pci_dev *pdev,
 	if (pdev->device == OCTEON_CN23XX_PF_VID)
 		oct_dev->msix_on = LIO_FLAG_MSIX_ENABLED;
 
+	/* Enable PTP for 6XXX Device */
+	if (((pdev->device == OCTEON_CN66XX) ||
+	     (pdev->device == OCTEON_CN68XX)))
+		oct_dev->ptp_enable = true;
+	else
+		oct_dev->ptp_enable = false;
+
 	dev_info(&pdev->dev, "Initializing device %x:%x.\n",
 		 (u32)pdev->vendor, (u32)pdev->device);
 
@@ -2388,9 +2393,7 @@ liquidio_push_packet(u32 octeon_id __attribute__((unused)),
 
 		r_dh_off = (rh->r_dh.len - 1) * BYTES_PER_DHLEN_UNIT;
 
-		if (((oct->chip_id == OCTEON_CN66XX) ||
-		     (oct->chip_id == OCTEON_CN68XX)) &&
-		    ptp_enable) {
+		if (oct->ptp_enable) {
 			if (rh->r_dh.has_hwtstamp) {
 				/* timestamp is included from the hardware at
 				 * the beginning of the packet.
@@ -2735,8 +2738,7 @@ static int liquidio_open(struct net_device *netdev)
 			oct->droq[0]->ops.poll_mode = 1;
 	}
 
-	if ((oct->chip_id == OCTEON_CN66XX || oct->chip_id == OCTEON_CN68XX) &&
-	    ptp_enable)
+	if (oct->ptp_enable)
 		oct_ptp_open(netdev);
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
@@ -3091,8 +3093,7 @@ static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		if ((lio->oct_dev->chip_id == OCTEON_CN66XX ||
-		     lio->oct_dev->chip_id == OCTEON_CN68XX) && ptp_enable)
+		if (lio->oct_dev->ptp_enable)
 			return hwtstamp_ioctl(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
diff --git a/drivers/net/ethernet/cavium/liquidio/octeon_device.h b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
index 31efdef..b014e6a 100644
--- a/drivers/net/ethernet/cavium/liquidio/octeon_device.h
+++ b/drivers/net/ethernet/cavium/liquidio/octeon_device.h
@@ -554,6 +554,7 @@ struct octeon_device {
 	} loc;
 
 	atomic_t *adapter_refcount; /* reference count of adapter */
+	bool ptp_enable;
 };
 
 #define  OCT_DRV_ONLINE 1
