From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH] igb: Use irq_synchronize per vector when using
	MSI-X
Date: Mon, 02 Aug 2010 17:40:52 -0700
Message-ID: <20100803004044.4441.34335.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Jean Delvare <jdelvare@suse.de>,
	Emil Tantilov <emil.s.tantilov@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta13.westchester.pa.mail.comcast.net ([76.96.59.243]:50857
	"EHLO qmta13.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751143Ab0HCAlP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Aug 2010 20:41:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Emil Tantilov <emil.s.tantilov@intel.com>

Synchronize all IRQs when using MSI-X. Similar to ixgbe.
Issue was reported on e1000e, but the patch is also valid for igb.

CC: Jean Delvare <jdelvare@suse.de>
Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
Tested-by: Jeff Pieper <jeffrey.e.pieper@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 667b527..df5dcd2 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1290,7 +1290,13 @@ static void igb_irq_disable(struct igb_adapter *adapter)
 	wr32(E1000_IAM, 0);
 	wr32(E1000_IMC, ~0);
 	wrfl();
-	synchronize_irq(adapter->pdev->irq);
+	if (adapter->msix_entries) {
+		int i;
+		for (i = 0; i < adapter->num_q_vectors; i++)
+			synchronize_irq(adapter->msix_entries[i].vector);
+	} else {
+		synchronize_irq(adapter->pdev->irq);
+	}
 }
 
 /**

