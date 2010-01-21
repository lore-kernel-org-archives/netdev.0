From: Alan Cox <alan@linux.intel.com>
Subject: [RFC PATCH] e100: Fix workqueue race
Date: Thu, 21 Jan 2010 16:48:01 +0000
Message-ID: <20100121164801.416170b9@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: jesse.brandeburg@intel.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga05.intel.com ([192.55.52.89]:43360 "EHLO
	fmsmga101.fm.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753801Ab0AURNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 12:13:42 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Incidentally this doesn't seem to be the only net driver that looks
suspect here)

e100: Fix the TX workqueue race

From: Alan Cox <alan@linux.intel.com>

Nothing stops the workqueue being left to run in parallel with close or a
few other operations. This causes double unmaps and the like.

See kerneloops.org #1041230 for an example

Signed-off-by: Alan Cox <alan@linux.intel.com>
---

 drivers/net/e100.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)


diff --git a/drivers/net/e100.c b/drivers/net/e100.c
index 5c7a155..5e02e4f 100644
--- a/drivers/net/e100.c
+++ b/drivers/net/e100.c
@@ -2232,7 +2232,7 @@ err_rx_clean_list:
 	return err;
 }
 
-static void e100_down(struct nic *nic)
+static void e100_do_down(struct nic *nic)
 {
 	/* wait here for poll to complete */
 	napi_disable(&nic->napi);
@@ -2245,6 +2245,15 @@ static void e100_down(struct nic *nic)
 	e100_rx_clean_list(nic);
 }
 
+/* For the non TX timeout case we want to kill the tx timeout before
+   we do this otherwise a parallel tx timeout will make a nasty mess. */
+
+static void e100_down(struct nic *nic)
+{
+	cancel_work_sync(&nic->tx_timeout_task);
+	e100_do_down(nic);
+}
+
 static void e100_tx_timeout(struct net_device *netdev)
 {
 	struct nic *nic = netdev_priv(netdev);
@@ -2261,7 +2270,7 @@ static void e100_tx_timeout_task(struct work_struct *work)
 
 	DPRINTK(TX_ERR, DEBUG, "scb.status=0x%02X\n",
 		ioread8(&nic->csr->scb.status));
-	e100_down(netdev_priv(netdev));
+	e100_do_down(netdev_priv(netdev));
 	e100_up(netdev_priv(netdev));
 }
 
