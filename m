From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] liquidio: remove PTP support in 23XX adapters
Date: Tue, 3 Jan 2017 11:27:33 -0800
Message-ID: <20170103192733.GA4979@felix.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <raghu.vatsavayi@cavium.com>,
        <derek.chickles@cavium.com>, <satananda.burla@cavium.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0060.outbound.protection.outlook.com ([104.47.42.60]:57506
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1757384AbdACT2a (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 3 Jan 2017 14:28:30 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Prasad Kanneganti <prasad.kanneganti@cavium.com>

liquidio driver incorrectly indicates that PTP is supported in 23XX
adapters; this patch fixes that.  PTP is supported in 66XX and 68XX
adapters, and the driver correctly indicates that.

Signed-off-by: Prasad Kanneganti <prasad.kanneganti@cavium.com>
Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Derek Chickles <derek.chickles@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/ethernet/cavium/liquidio/lio_main.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/cavium/liquidio/lio_main.c b/drivers/net/ethernet/cavium/liquidio/lio_main.c
index 39a9665..6443bc1 100644
--- a/drivers/net/ethernet/cavium/liquidio/lio_main.c
+++ b/drivers/net/ethernet/cavium/liquidio/lio_main.c
@@ -2629,7 +2629,9 @@ static int liquidio_open(struct net_device *netdev)
 			oct->droq[0]->ops.poll_mode = 1;
 	}
 
-	oct_ptp_open(netdev);
+	if ((oct->chip_id == OCTEON_CN66XX || oct->chip_id == OCTEON_CN68XX) &&
+	    ptp_enable)
+		oct_ptp_open(netdev);
 
 	ifstate_set(lio, LIO_IFSTATE_RUNNING);
 
@@ -2973,9 +2975,13 @@ static int hwtstamp_ioctl(struct net_device *netdev, struct ifreq *ifr)
  */
 static int liquidio_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
 {
+	struct lio *lio = GET_LIO(netdev);
+
 	switch (cmd) {
 	case SIOCSHWTSTAMP:
-		return hwtstamp_ioctl(netdev, ifr);
+		if ((lio->oct_dev->chip_id == OCTEON_CN66XX ||
+		     lio->oct_dev->chip_id == OCTEON_CN68XX) && ptp_enable)
+			return hwtstamp_ioctl(netdev, ifr);
 	default:
 		return -EOPNOTSUPP;
 	}
