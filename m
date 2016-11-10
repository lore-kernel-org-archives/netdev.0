From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 02/11] amd-xgbe: Add a workaround for Tx
 timestamp issue
Date: Thu, 10 Nov 2016 17:09:45 -0600
Message-ID: <20161110230945.20704.27939.stgit@tlendack-t1.amdoffice.net>
References: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0081.outbound.protection.outlook.com ([104.47.42.81]:57024
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933993AbcKJXJx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 18:09:53 -0500
In-Reply-To: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update the reading of the Tx timestamp to account for a hardware issue
on how the fields and interrupt are cleared.  The "seconds" portion of
the timestamp should be read first, followed by the "nanoseconds" portion.
Reading the "nanoseconds" portion should clear the timestamp data and the
interrupt.  Because of an issue with the hardware this order is reversed
and reading the "seconds" portion actually clears the timestamp.  The code
currently follows this workaround, but to guard against future versions
where this is fixed add a field to the version data to indicate if the
workaround is required or not.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c      |   13 ++++++++++---
 drivers/net/ethernet/amd/xgbe/xgbe-platform.c |    1 +
 drivers/net/ethernet/amd/xgbe/xgbe.h          |    1 +
 3 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index e3862bb..81d4780 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1360,14 +1360,21 @@ static u64 xgbe_get_tstamp_time(struct xgbe_prv_data *pdata)
 
 static u64 xgbe_get_tx_tstamp(struct xgbe_prv_data *pdata)
 {
-	unsigned int tx_snr;
+	unsigned int tx_snr, tx_ssr;
 	u64 nsec;
 
-	tx_snr = XGMAC_IOREAD(pdata, MAC_TXSNR);
+	if (pdata->vdata->tx_tstamp_workaround) {
+		tx_snr = XGMAC_IOREAD(pdata, MAC_TXSNR);
+		tx_ssr = XGMAC_IOREAD(pdata, MAC_TXSSR);
+	} else {
+		tx_ssr = XGMAC_IOREAD(pdata, MAC_TXSSR);
+		tx_snr = XGMAC_IOREAD(pdata, MAC_TXSNR);
+	}
+
 	if (XGMAC_GET_BITS(tx_snr, MAC_TXSNR, TXTSSTSMIS))
 		return 0;
 
-	nsec = XGMAC_IOREAD(pdata, MAC_TXSSR);
+	nsec = tx_ssr;
 	nsec *= NSEC_PER_SEC;
 	nsec += tx_snr;
 
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-platform.c b/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
index 0edbcd5..7a701de 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-platform.c
@@ -581,6 +581,7 @@ static int xgbe_platform_resume(struct device *dev)
 	.xpcs_access			= XGBE_XPCS_ACCESS_V1,
 	.tx_max_fifo_size		= 81920,
 	.rx_max_fifo_size		= 81920,
+	.tx_tstamp_workaround		= 1,
 };
 
 #ifdef CONFIG_ACPI
diff --git a/drivers/net/ethernet/amd/xgbe/xgbe.h b/drivers/net/ethernet/amd/xgbe/xgbe.h
index 0779247..8523779 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe.h
+++ b/drivers/net/ethernet/amd/xgbe/xgbe.h
@@ -805,6 +805,7 @@ struct xgbe_version_data {
 	unsigned int mmc_64bit;
 	unsigned int tx_max_fifo_size;
 	unsigned int rx_max_fifo_size;
+	unsigned int tx_tstamp_workaround;
 };
 
 struct xgbe_prv_data {
