From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 19/20] igb: add single vector msi-x testing to
	interrupt test
Date: Tue, 27 Oct 2009 18:55:22 -0700
Message-ID: <20091028015521.12470.56692.stgit@localhost.localdomain>
References: <20091028014858.12470.99520.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta09.westchester.pa.mail.comcast.net ([76.96.62.96]:49446
	"EHLO QMTA09.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756730AbZJ1B7F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 21:59:05 -0400
In-Reply-To: <20091028014858.12470.99520.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

This change adds testing of the first msix vector to the interrupt testing.
This should help with determining the cause of interrupt issues when they are
encountered.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_ethtool.c |   27 +++++++++++++++++----------
 1 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/igb/igb_ethtool.c b/drivers/net/igb/igb_ethtool.c
index aa05f00..65c538f 100644
--- a/drivers/net/igb/igb_ethtool.c
+++ b/drivers/net/igb/igb_ethtool.c
@@ -1123,32 +1123,36 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	*data = 0;
 
 	/* Hook up test interrupt handler just for this test */
-	if (adapter->msix_entries)
-		/* NOTE: we don't test MSI-X interrupts here, yet */
-		return 0;
+	if (adapter->msix_entries) {
+		if (request_irq(adapter->msix_entries[0].vector,
+		                &igb_test_intr, 0, netdev->name, adapter)) {
+			*data = 1;
+			return -1;
+		}
 
-	if (adapter->flags & IGB_FLAG_HAS_MSI) {
+	} else if (adapter->flags & IGB_FLAG_HAS_MSI) {
 		shared_int = false;
-		if (request_irq(irq, &igb_test_intr, 0, netdev->name, netdev)) {
+		if (request_irq(irq,
+		                &igb_test_intr, 0, netdev->name, adapter)) {
 			*data = 1;
 			return -1;
 		}
 	} else if (!request_irq(irq, &igb_test_intr, IRQF_PROBE_SHARED,
-				netdev->name, netdev)) {
+				netdev->name, adapter)) {
 		shared_int = false;
 	} else if (request_irq(irq, &igb_test_intr, IRQF_SHARED,
-		 netdev->name, netdev)) {
+		 netdev->name, adapter)) {
 		*data = 1;
 		return -1;
 	}
 	dev_info(&adapter->pdev->dev, "testing %s interrupt\n",
 		(shared_int ? "shared" : "unshared"));
 	/* Disable all the interrupts */
-	wr32(E1000_IMC, 0xFFFFFFFF);
+	wr32(E1000_IMC, ~0);
 	msleep(10);
 
 	/* Define all writable bits for ICS */
-	switch(hw->mac.type) {
+	switch (hw->mac.type) {
 	case e1000_82575:
 		ics_mask = 0x37F47EDD;
 		break;
@@ -1238,7 +1242,10 @@ static int igb_intr_test(struct igb_adapter *adapter, u64 *data)
 	msleep(10);
 
 	/* Unhook test interrupt handler */
-	free_irq(irq, netdev);
+	if (adapter->msix_entries)
+		free_irq(adapter->msix_entries[0].vector, adapter);
+	else
+		free_irq(irq, adapter);
 
 	return *data;
 }

