From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 3/3] ixgb and e1000: Use new function for
	copybreak tests
Date: Thu, 13 May 2010 18:26:17 -0700
Message-ID: <20100514012615.30457.37881.stgit@localhost.localdomain>
References: <20100514012425.30457.23799.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Joe Perches <joe@perches.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:42435
	"EHLO qmta05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755147Ab0ENB0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 May 2010 21:26:36 -0400
In-Reply-To: <20100514012425.30457.23799.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>

There appears to be an off-by-1 defect in the maximum packet size
copied when copybreak is speified in these modules.

The copybreak module params are specified as:
"Maximum size of packet that is copied to a new buffer on receive"

The tests are changed from "< copybreak" to "<= copybreak"
and moved into new static functions for readability.

Signed-off-by: Joe Perches <joe@perches.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000/e1000_main.c |   47 +++++++++++++++++++++---------------
 drivers/net/ixgb/ixgb_main.c   |   52 ++++++++++++++++++++++++----------------
 2 files changed, 58 insertions(+), 41 deletions(-)

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index e9b19f7..b56eda0 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -3787,6 +3787,31 @@ next_desc:
 	return cleaned;
 }
 
+/*
+ * this should improve performance for small packets with large amounts
+ * of reassembly being done in the stack
+ */
+static void e1000_check_copybreak(struct net_device *netdev,
+				 struct e1000_buffer *buffer_info,
+				 u32 length, struct sk_buff **skb)
+{
+	struct sk_buff *new_skb;
+
+	if (length > copybreak)
+		return;
+
+	new_skb = netdev_alloc_skb_ip_align(netdev, length);
+	if (!new_skb)
+		return;
+
+	skb_copy_to_linear_data_offset(new_skb, -NET_IP_ALIGN,
+				       (*skb)->data - NET_IP_ALIGN,
+				       length + NET_IP_ALIGN);
+	/* save the skb in buffer_info as good */
+	buffer_info->skb = *skb;
+	*skb = new_skb;
+}
+
 /**
  * e1000_clean_rx_irq - Send received data up the network stack; legacy
  * @adapter: board private structure
@@ -3885,26 +3910,8 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
 		total_rx_bytes += length;
 		total_rx_packets++;
 
-		/* code added for copybreak, this should improve
-		 * performance for small packets with large amounts
-		 * of reassembly being done in the stack */
-		if (length < copybreak) {
-			struct sk_buff *new_skb =
-			    netdev_alloc_skb_ip_align(netdev, length);
-			if (new_skb) {
-				skb_copy_to_linear_data_offset(new_skb,
-							       -NET_IP_ALIGN,
-							       (skb->data -
-							        NET_IP_ALIGN),
-							       (length +
-							        NET_IP_ALIGN));
-				/* save the skb in buffer_info as good */
-				buffer_info->skb = skb;
-				skb = new_skb;
-			}
-			/* else just continue with the old one */
-		}
-		/* end copybreak code */
+		e1000_check_copybreak(netdev, buffer_info, length, &skb);
+
 		skb_put(skb, length);
 
 		/* Receive Checksum Offload */
diff --git a/drivers/net/ixgb/ixgb_main.c b/drivers/net/ixgb/ixgb_main.c
index d58ca6b..c6b75c8 100644
--- a/drivers/net/ixgb/ixgb_main.c
+++ b/drivers/net/ixgb/ixgb_main.c
@@ -1921,6 +1921,31 @@ ixgb_rx_checksum(struct ixgb_adapter *adapter,
 	}
 }
 
+/*
+ * this should improve performance for small packets with large amounts
+ * of reassembly being done in the stack
+ */
+static void ixgb_check_copybreak(struct net_device *netdev,
+				 struct ixgb_buffer *buffer_info,
+				 u32 length, struct sk_buff **skb)
+{
+	struct sk_buff *new_skb;
+
+	if (length > copybreak)
+		return;
+
+	new_skb = netdev_alloc_skb_ip_align(netdev, length);
+	if (!new_skb)
+		return;
+
+	skb_copy_to_linear_data_offset(new_skb, -NET_IP_ALIGN,
+				       (*skb)->data - NET_IP_ALIGN,
+				       length + NET_IP_ALIGN);
+	/* save the skb in buffer_info as good */
+	buffer_info->skb = *skb;
+	*skb = new_skb;
+}
+
 /**
  * ixgb_clean_rx_irq - Send received data up the network stack,
  * @adapter: board private structure
@@ -1957,11 +1982,14 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 
 		prefetch(skb->data - NET_IP_ALIGN);
 
-		if (++i == rx_ring->count) i = 0;
+		if (++i == rx_ring->count)
+			i = 0;
 		next_rxd = IXGB_RX_DESC(*rx_ring, i);
 		prefetch(next_rxd);
 
-		if ((j = i + 1) == rx_ring->count) j = 0;
+		j = i + 1;
+		if (j == rx_ring->count)
+			j = 0;
 		next2_buffer = &rx_ring->buffer_info[j];
 		prefetch(next2_buffer);
 
@@ -1997,25 +2025,7 @@ ixgb_clean_rx_irq(struct ixgb_adapter *adapter, int *work_done, int work_to_do)
 			goto rxdesc_done;
 		}
 
-		/* code added for copybreak, this should improve
-		 * performance for small packets with large amounts
-		 * of reassembly being done in the stack */
-		if (length < copybreak) {
-			struct sk_buff *new_skb =
-			    netdev_alloc_skb_ip_align(netdev, length);
-			if (new_skb) {
-				skb_copy_to_linear_data_offset(new_skb,
-							       -NET_IP_ALIGN,
-							       (skb->data -
-							        NET_IP_ALIGN),
-							       (length +
-							        NET_IP_ALIGN));
-				/* save the skb in buffer_info as good */
-				buffer_info->skb = skb;
-				skb = new_skb;
-			}
-		}
-		/* end copybreak code */
+		ixgb_check_copybreak(netdev, buffer_info, length, &skb);
 
 		/* Good Receive */
 		skb_put(skb, length);

