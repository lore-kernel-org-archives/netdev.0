From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 2.6.30 4/4] cxgb3: Fix EEH final recovery attempt
Date: Fri, 17 Apr 2009 15:21:27 -0700
Message-ID: <20090417222127.8569.59426.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:7088 "EHLO
	stargate.chelsio.com" rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754555AbZDQXD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 19:03:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

EEH attempts to recover up 6 times.
The last attempt leaves all the ports and adapter down.hen
The driver is then unloaded, bringing the adapter down again
unconditionally. The unload will hang.
Check if the adapter is already down before trying to bring it down again.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index cbd59fe..7ea4841 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -1235,6 +1235,10 @@ static int cxgb_close(struct net_device *dev)
 	struct port_info *pi = netdev_priv(dev);
 	struct adapter *adapter = pi->adapter;
 
+	
+	if (!adapter->open_device_map)
+		return 0;
+
 	/* Stop link fault interrupts */
 	t3_xgm_intr_disable(adapter, pi->port_id);
 	t3_read_reg(adapter, A_XGM_INT_STATUS + pi->mac.offset);
@@ -2823,6 +2827,9 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 	struct adapter *adapter = pci_get_drvdata(pdev);
 	int ret;
 
+	if (state == pci_channel_io_perm_failure)
+		return PCI_ERS_RESULT_DISCONNECT;
+
 	ret = t3_adapter_error(adapter, 0);
 
 	/* Request a slot reset. */

