From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 07/11] ixgbe: Enable jumbo frame for FCoE feature
	in 82599
Date: Sun, 17 May 2009 15:34:35 -0700
Message-ID: <20090517223434.14124.82534.stgit@localhost.localdomain>
References: <20090517223213.14124.61405.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.emeryville.ca.mail.comcast.net ([76.96.30.48]:48929 "EHLO
	QMTA05.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755296AbZEQWex (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 May 2009 18:34:53 -0400
In-Reply-To: <20090517223213.14124.61405.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

Enable jumbo frame when FCoE feature is enabled in 82599. Use 3K
as the receive queue buffer size for receive queues used by FCoE
to address for max Fiber Channel frame size as 2148 bytes (with
max 2112 bytes of payload).

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    4 ++++
 drivers/net/ixgbe/ixgbe_main.c |   22 ++++++++++++++++++++++
 2 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 94b0465..3f83a12 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -222,6 +222,10 @@ struct ixgbe_q_vector {
 	(&(((struct ixgbe_adv_tx_context_desc *)((R).desc))[i]))
 
 #define IXGBE_MAX_JUMBO_FRAME_SIZE        16128
+#ifdef IXGBE_FCOE
+/* Use 3K as the baby jumbo frame size for FCoE */
+#define IXGBE_FCOE_JUMBO_FRAME_SIZE       3072
+#endif /* IXGBE_FCOE */
 
 #define OTHER_VECTOR 1
 #define NON_Q_VECTORS (OTHER_VECTOR)
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 68edeab..1b4af3f 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1864,6 +1864,10 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		hlreg0 &= ~IXGBE_HLREG0_JUMBOEN;
 	else
 		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
+#ifdef IXGBE_FCOE
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+		hlreg0 |= IXGBE_HLREG0_JUMBOEN;
+#endif
 	IXGBE_WRITE_REG(hw, IXGBE_HLREG0, hlreg0);
 
 	rdlen = adapter->rx_ring[0].count * sizeof(union ixgbe_adv_rx_desc);
@@ -1885,6 +1889,17 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 		adapter->rx_ring[i].tail = IXGBE_RDT(j);
 		adapter->rx_ring[i].rx_buf_len = rx_buf_len;
 
+#ifdef IXGBE_FCOE
+		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED) {
+			struct ixgbe_ring_feature *f;
+			f = &adapter->ring_feature[RING_F_FCOE];
+			if ((rx_buf_len < IXGBE_FCOE_JUMBO_FRAME_SIZE) &&
+			    (i >= f->mask) && (i < f->mask + f->indices))
+				adapter->rx_ring[i].rx_buf_len =
+				        IXGBE_FCOE_JUMBO_FRAME_SIZE;
+		}
+
+#endif /* IXGBE_FCOE */
 		ixgbe_configure_srrctl(adapter, j);
 	}
 
@@ -2423,6 +2438,13 @@ static int ixgbe_up_complete(struct ixgbe_adapter *adapter)
 		IXGBE_WRITE_REG(hw, IXGBE_GPIE, gpie);
 	}
 
+#ifdef IXGBE_FCOE
+	/* adjust max frame to be able to do baby jumbo for FCoE */
+	if ((adapter->flags & IXGBE_FLAG_FCOE_ENABLED) &&
+	    (max_frame < IXGBE_FCOE_JUMBO_FRAME_SIZE))
+		max_frame = IXGBE_FCOE_JUMBO_FRAME_SIZE;
+
+#endif /* IXGBE_FCOE */
 	mhadd = IXGBE_READ_REG(hw, IXGBE_MHADD);
 	if (max_frame != (mhadd >> IXGBE_MHADD_MFS_SHIFT)) {
 		mhadd &= ~IXGBE_MHADD_MFS_MASK;

