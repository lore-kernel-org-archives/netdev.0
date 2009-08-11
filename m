From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH] ixgbe: fix issues setting rx-usecs with legacy
	interrupts
Date: Tue, 11 Aug 2009 16:18:14 -0700
Message-ID: <20090811231805.13967.1829.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Don Skidmore <donald.skidmore@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:46659 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755559AbZHKXSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Aug 2009 19:18:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Don Skidmore <donald.c.skidmore@intel.com>

Currently setting rx-usecs when the interface is in legacy interrupt
mode it is not immediate.  We were only setting EITR for each MSIx
vector and since this count would be zero for legacy mode it wasn't
set until after a reset.  This patch corrects that by checking what
mode we are in and then setting EITR accordingly.

Signed-off-by: Don Skidmore <donald.skidmore@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_ethtool.c |   27 +++++++++++++++++++--------
 1 files changed, 19 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_ethtool.c b/drivers/net/ixgbe/ixgbe_ethtool.c
index 79144e9..dff8dfa 100644
--- a/drivers/net/ixgbe/ixgbe_ethtool.c
+++ b/drivers/net/ixgbe/ixgbe_ethtool.c
@@ -1948,6 +1948,7 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
                               struct ethtool_coalesce *ec)
 {
 	struct ixgbe_adapter *adapter = netdev_priv(netdev);
+	struct ixgbe_q_vector *q_vector;
 	int i;
 
 	if (ec->tx_max_coalesced_frames_irq)
@@ -1982,14 +1983,24 @@ static int ixgbe_set_coalesce(struct net_device *netdev,
 		adapter->itr_setting = 0;
 	}
 
-	for (i = 0; i < adapter->num_msix_vectors - NON_Q_VECTORS; i++) {
-		struct ixgbe_q_vector *q_vector = adapter->q_vector[i];
-		if (q_vector->txr_count && !q_vector->rxr_count)
-			/* tx vector gets half the rate */
-			q_vector->eitr = (adapter->eitr_param >> 1);
-		else
-			/* rx only or mixed */
-			q_vector->eitr = adapter->eitr_param;
+	/* MSI/MSIx Interrupt Mode */
+	if (adapter->flags &
+	    (IXGBE_FLAG_MSIX_ENABLED | IXGBE_FLAG_MSI_ENABLED)) {
+		int num_vectors = adapter->num_msix_vectors - NON_Q_VECTORS;
+		for (i = 0; i < num_vectors; i++) {
+			q_vector = adapter->q_vector[i];
+			if (q_vector->txr_count && !q_vector->rxr_count)
+				/* tx vector gets half the rate */
+				q_vector->eitr = (adapter->eitr_param >> 1);
+			else
+				/* rx only or mixed */
+				q_vector->eitr = adapter->eitr_param;
+			ixgbe_write_eitr(q_vector);
+		}
+	/* Legacy Interrupt Mode */
+	} else {
+		q_vector = adapter->q_vector[0];
+		q_vector->eitr = adapter->eitr_param;
 		ixgbe_write_eitr(q_vector);
 	}
 

