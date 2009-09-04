From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 2/3] igb: only disable/enable interrupt bits for igb
	physical function
Date: Thu, 03 Sep 2009 17:49:15 -0700
Message-ID: <20090904004914.14537.67180.stgit@localhost.localdomain>
References: <20090904004828.14537.72187.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta07.emeryville.ca.mail.comcast.net ([76.96.30.64]:34873 "EHLO
	QMTA07.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753990AbZIDAt3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 20:49:29 -0400
In-Reply-To: <20090904004828.14537.72187.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

The igb_irq_disable/enable calls were causing virtual functions associated
with the igb physical function to have their interrupts disabled.  In order
to prevent this from occuring we should only clear/set the bits related to
the physical function.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |   14 +++++++++-----
 1 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index 95089a8..1d03fcb 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -821,9 +821,11 @@ static void igb_irq_disable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
-		wr32(E1000_EIAM, 0);
-		wr32(E1000_EIMC, ~0);
-		wr32(E1000_EIAC, 0);
+		u32 regval = rd32(E1000_EIAM);
+		wr32(E1000_EIAM, regval & ~adapter->eims_enable_mask);
+		wr32(E1000_EIMC, adapter->eims_enable_mask);
+		regval = rd32(E1000_EIAC);
+		wr32(E1000_EIAC, regval & ~adapter->eims_enable_mask);
 	}
 
 	wr32(E1000_IAM, 0);
@@ -841,8 +843,10 @@ static void igb_irq_enable(struct igb_adapter *adapter)
 	struct e1000_hw *hw = &adapter->hw;
 
 	if (adapter->msix_entries) {
-		wr32(E1000_EIAC, adapter->eims_enable_mask);
-		wr32(E1000_EIAM, adapter->eims_enable_mask);
+		u32 regval = rd32(E1000_EIAC);
+		wr32(E1000_EIAC, regval | adapter->eims_enable_mask);
+		regval = rd32(E1000_EIAM);
+		wr32(E1000_EIAM, regval | adapter->eims_enable_mask);
 		wr32(E1000_EIMS, adapter->eims_enable_mask);
 		if (adapter->vfs_allocated_count)
 			wr32(E1000_MBVFIMR, 0xFF);

