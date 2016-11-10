From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH net-next v1 01/11] amd-xgbe: Guard against incorrectly
 generated interrupts
Date: Thu, 10 Nov 2016 17:09:29 -0600
Message-ID: <20161110230929.20704.29819.stgit@tlendack-t1.amdoffice.net>
References: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0083.outbound.protection.outlook.com ([104.47.42.83]:62972
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S933993AbcKJXJm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 18:09:42 -0500
In-Reply-To: <20161110230916.20704.34081.stgit@tlendack-t1.amdoffice.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Due to a hardware issue, it is possible for interrupt events to be
incorrectly generated when performing a soft reset.  To guard against
this, perform the soft reset twice.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 drivers/net/ethernet/amd/xgbe/xgbe-dev.c |   16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
index 9037319..e3862bb 100644
--- a/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
+++ b/drivers/net/ethernet/amd/xgbe/xgbe-dev.c
@@ -1897,7 +1897,7 @@ static int xgbe_disable_int(struct xgbe_channel *channel,
 	return 0;
 }
 
-static int xgbe_exit(struct xgbe_prv_data *pdata)
+static int __xgbe_exit(struct xgbe_prv_data *pdata)
 {
 	unsigned int count = 2000;
 
@@ -1919,6 +1919,20 @@ static int xgbe_exit(struct xgbe_prv_data *pdata)
 	return 0;
 }
 
+static int xgbe_exit(struct xgbe_prv_data *pdata)
+{
+	int ret;
+
+	/* To guard against possible incorrectly generated interrupts,
+	 * issue the software reset twice.
+	 */
+	ret = __xgbe_exit(pdata);
+	if (ret)
+		return ret;
+
+	return __xgbe_exit(pdata);
+}
+
 static int xgbe_flush_tx_queues(struct xgbe_prv_data *pdata)
 {
 	unsigned int i, count;
