From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [PATCH 6/8] ixgbe: properly return CHECKSUM_NONE, cleanup csum code
Date: Fri, 01 Feb 2008 15:59:09 -0800
Message-ID: <20080201235909.31474.2938.stgit@localhost.localdomain>
References: <20080201235841.31474.49421.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:33904 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761290AbYBBAAs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Feb 2008 19:00:48 -0500
In-Reply-To: <20080201235841.31474.49421.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>

We were not returning CHECKSUM_NONE in a lot of cases which is
wrong. Move common exit points in this function and error code
up before the actual work in this function.

Signed-off-by: Ayyappan Veeraiyan <ayyappan.veeraiyan@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   29 ++++++++++++++++++++++-------
 1 files changed, 22 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index c814d9b..ee5ee10 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -304,25 +304,40 @@ static void ixgbe_receive_skb(struct ixgbe_adapter *adapter,
 	}
 }
 
+/**
+ * ixgbe_rx_checksum - indicate in skb if hw indicated a good cksum
+ * @adapter: address of board private structure
+ * @status_err: hardware indication of status of receive
+ * @skb: skb currently being received and modified
+ **/
 static inline void ixgbe_rx_checksum(struct ixgbe_adapter *adapter,
 					 u32 status_err,
 					 struct sk_buff *skb)
 {
 	skb->ip_summed = CHECKSUM_NONE;
 
-	/* Ignore Checksum bit is set */
+	/* Ignore Checksum bit is set, or rx csum disabled */
 	if ((status_err & IXGBE_RXD_STAT_IXSM) ||
-		     !(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
+	    !(adapter->flags & IXGBE_FLAG_RX_CSUM_ENABLED))
 		return;
-	/* TCP/UDP checksum error bit is set */
-	if (status_err & (IXGBE_RXDADV_ERR_TCPE | IXGBE_RXDADV_ERR_IPE)) {
-		/* let the stack verify checksum errors */
+
+	/* if IP and error */
+	if ((status_err & IXGBE_RXD_STAT_IPCS) &&
+	    (status_err & IXGBE_RXDADV_ERR_IPE)) {
 		adapter->hw_csum_rx_error++;
 		return;
 	}
+
+	if (!(status_err & IXGBE_RXD_STAT_L4CS))
+		return;
+
+	if (status_err & IXGBE_RXDADV_ERR_TCPE) {
+		adapter->hw_csum_rx_error++;
+		return;
+	}
+
 	/* It must be a TCP or UDP packet with a valid checksum */
-	if (status_err & (IXGBE_RXD_STAT_L4CS | IXGBE_RXD_STAT_UDPCS))
-		skb->ip_summed = CHECKSUM_UNNECESSARY;
+	skb->ip_summed = CHECKSUM_UNNECESSARY;
 	adapter->hw_csum_rx_good++;
 }
 

