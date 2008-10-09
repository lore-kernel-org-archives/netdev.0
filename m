From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [NET-NEXT PATCH 1/2] e1000e: don't generate bad checksums for tcp
	packets with 0 csum
Date: Thu, 09 Oct 2008 09:58:31 -0700
Message-ID: <20081009165831.32435.81922.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dave Graham <david.graham@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: jeff@garzik.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta04.emeryville.ca.mail.comcast.net ([76.96.30.40]:43292 "EHLO
	QMTA04.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752861AbYJIQ6x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 12:58:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Graham <david.graham@intel.com>

When offloading transmit checksums only, the driver was not
correctly configuring the hardware to handle the case of a zero
checksum.  For UDP the correct behavior is to leave it alone, but
for tcp the checksum must be changed from 0x0000 to 0xFFFF.  The
hardware takes care of this case but only if it is told the
packet is tcp.

Signed-off-by: Dave Graham <david.graham@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/netdev.c |   62 +++++++++++++++++++++++++++----------------
 1 files changed, 39 insertions(+), 23 deletions(-)

diff --git a/drivers/net/e1000e/netdev.c b/drivers/net/e1000e/netdev.c
index 1b72749..abd492b 100644
--- a/drivers/net/e1000e/netdev.c
+++ b/drivers/net/e1000e/netdev.c
@@ -3749,34 +3749,50 @@ static bool e1000_tx_csum(struct e1000_adapter *adapter, struct sk_buff *skb)
 	struct e1000_buffer *buffer_info;
 	unsigned int i;
 	u8 css;
+	u32 cmd_len = E1000_TXD_CMD_DEXT;
 
-	if (skb->ip_summed == CHECKSUM_PARTIAL) {
-		css = skb_transport_offset(skb);
-
-		i = tx_ring->next_to_use;
-		buffer_info = &tx_ring->buffer_info[i];
-		context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
-
-		context_desc->lower_setup.ip_config = 0;
-		context_desc->upper_setup.tcp_fields.tucss = css;
-		context_desc->upper_setup.tcp_fields.tucso =
-					css + skb->csum_offset;
-		context_desc->upper_setup.tcp_fields.tucse = 0;
-		context_desc->tcp_seg_setup.data = 0;
-		context_desc->cmd_and_length = cpu_to_le32(E1000_TXD_CMD_DEXT);
+	if (skb->ip_summed != CHECKSUM_PARTIAL)
+		return 0;
 
-		buffer_info->time_stamp = jiffies;
-		buffer_info->next_to_watch = i;
+	switch (skb->protocol) {
+	case __constant_htons(ETH_P_IP):
+		if (ip_hdr(skb)->protocol == IPPROTO_TCP)
+			cmd_len |= E1000_TXD_CMD_TCP;
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		/* XXX not handling all IPV6 headers */
+		if (ipv6_hdr(skb)->nexthdr == IPPROTO_TCP)
+			cmd_len |= E1000_TXD_CMD_TCP;
+		break;
+	default:
+		if (unlikely(net_ratelimit()))
+			e_warn("checksum_partial proto=%x!\n", skb->protocol);
+		break;
+	}
 
-		i++;
-		if (i == tx_ring->count)
-			i = 0;
-		tx_ring->next_to_use = i;
+	css = skb_transport_offset(skb);
 
-		return 1;
-	}
+	i = tx_ring->next_to_use;
+	buffer_info = &tx_ring->buffer_info[i];
+	context_desc = E1000_CONTEXT_DESC(*tx_ring, i);
+
+	context_desc->lower_setup.ip_config = 0;
+	context_desc->upper_setup.tcp_fields.tucss = css;
+	context_desc->upper_setup.tcp_fields.tucso =
+				css + skb->csum_offset;
+	context_desc->upper_setup.tcp_fields.tucse = 0;
+	context_desc->tcp_seg_setup.data = 0;
+	context_desc->cmd_and_length = cpu_to_le32(cmd_len);
+
+	buffer_info->time_stamp = jiffies;
+	buffer_info->next_to_watch = i;
+
+	i++;
+	if (i == tx_ring->count)
+		i = 0;
+	tx_ring->next_to_use = i;
 
-	return 0;
+	return 1;
 }
 
 #define E1000_MAX_PER_TXD	8192

