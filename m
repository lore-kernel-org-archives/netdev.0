From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 04/20] ixgbe: combine two modifications of TXDCTL
	into one
Date: Thu, 19 Aug 2010 16:34:27 -0700
Message-ID: <20100819233425.10335.67211.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:56051 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751731Ab0HSXer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:34:47 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

In ixgbe_up_complete we were doing a read-modify-write of TXDCTL followed
by another one just a few lines further down.  Instead of performing two
separate read-modify-writes it would make more sense to combine the two
into one.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   18 ++++++------------
 1 files changed, 6 insertions(+), 12 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index fffb1ce..5d90f69 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -3411,6 +3411,12 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_MHADD, mhadd);
 	}
 
+	if (hw->mac.type == ixgbe_mac_82599EB) {
+		/* DMATXCTL.EN must be set after all Tx queue config is done */
+		dmatxctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
+		dmatxctl |= IXGBE_DMATXCTL_TE;
+		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, dmatxctl);
+	}
 	for (i = 0; i < adapter->num_tx_queues; i++) {
 		j = adapter->tx_ring[i]->reg_idx;
 		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
@@ -3421,18 +3427,6 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 			/* enable WTHRESH=8 descriptors, to encourage burst writeback */
 			txdctl |= (8 << 16);
 		}
-		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
-	}
-
-	if (hw->mac.type == ixgbe_mac_82599EB) {
-		/* DMATXCTL.EN must be set after all Tx queue config is done */
-		dmatxctl = IXGBE_READ_REG(hw, IXGBE_DMATXCTL);
-		dmatxctl |= IXGBE_DMATXCTL_TE;
-		IXGBE_WRITE_REG(hw, IXGBE_DMATXCTL, dmatxctl);
-	}
-	for (i = 0; i < adapter->num_tx_queues; i++) {
-		j = adapter->tx_ring[i]->reg_idx;
-		txdctl = IXGBE_READ_REG(hw, IXGBE_TXDCTL(j));
 		txdctl |= IXGBE_TXDCTL_ENABLE;
 		IXGBE_WRITE_REG(hw, IXGBE_TXDCTL(j), txdctl);
 		if (hw->mac.type == ixgbe_mac_82599EB) {

