From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 05/14] amd-xgbe: Prevent looping forever if
 timestamp update fails
Date: Wed, 28 Jun 2017 13:42:07 -0500
Message-ID: <20170628184207.21972.30173.stgit@tlendack-t1.amdoffice.net>
References: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0067.outbound.protection.outlook.com ([104.47.32.67]:7332
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751669AbdF1SmN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 28 Jun 2017 14:42:13 -0400
In-Reply-To: <20170628184122.21972.87767.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just to be on the safe side, should the update of the timestamp registers
not complete, issue a warning rather than looping forever waiting for the
update to complete.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   15 +++++++++++++--
 1 file changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 24a687c..3ad4036 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1497,26 +1497,37 @@ static void xgbe_rx_desc_init(struct xgbe_channel *channel)
 static void xgbe_update_tstamp_addend(struct xgbe_prv_data *pdata,
 				      unsigned int addend)
 {
+	unsigned int count = 10000;
+
 	/* Set the addend register value and tell the device */
 	XGMAC_IOWRITE(pdata, MAC_TSAR, addend);
 	XGMAC_IOWRITE_BITS(pdata, MAC_TSCR, TSADDREG, 1);
 
 	/* Wait for addend update to complete */
-	while (XGMAC_IOREAD_BITS(pdata, MAC_TSCR, TSADDREG))
+	while (--count && XGMAC_IOREAD_BITS(pdata, MAC_TSCR, TSADDREG))
 		udelay(5);
+
+	if (!count)
+		netdev_err(pdata->netdev,
+			   "timed out updating timestamp addend register\n");
 }
 
 static void xgbe_set_tstamp_time(struct xgbe_prv_data *pdata, unsigned int sec,
 				 unsigned int nsec)
 {
+	unsigned int count = 10000;
+
 	/* Set the time values and tell the device */
 	XGMAC_IOWRITE(pdata, MAC_STSUR, sec);
 	XGMAC_IOWRITE(pdata, MAC_STNUR, nsec);
 	XGMAC_IOWRITE_BITS(pdata, MAC_TSCR, TSINIT, 1);
 
 	/* Wait for time update to complete */
-	while (XGMAC_IOREAD_BITS(pdata, MAC_TSCR, TSINIT))
+	while (--count && XGMAC_IOREAD_BITS(pdata, MAC_TSCR, TSINIT))
 		udelay(5);
+
+	if (!count)
+		netdev_err(pdata->netdev, "timed out initializing timestamp\n");
 }
 
 static u64 xgbe_get_tstamp_time(struct xgbe_prv_data *pdata)
