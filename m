From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 01/30] net: fec: Don't clear IPV6 header checksum field
 when IP accelerator enable
Date: Fri, 20 Jun 2014 13:11:48 +0100
Message-ID: <E1WxxfY-0005Wt-9N@rmk-PC.arm.linux.org.uk>
References: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36317 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966820AbaFTMLu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:11:50 -0400
In-Reply-To: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
To: linux-arm-kernel@lists.infradead.org

The commit 96c50caa5148 (net: fec: Enable IP header hardware checksum)
enable HW IP header checksum for IPV4 and IPV6, which causes IPV6 TCP/UDP
cannot work. (The issue is reported by Russell King)

For FEC IP header checksum function: Insert IP header checksum. This "IINS"
bit is written by the user. If set, IP accelerator calculates the IP header
checksum and overwrites the IINS corresponding header field with the calculated
value. The checksum field must be cleared by user, otherwise the checksum
always is 0xFFFF.

So the previous patch clear IP header checksum field regardless of IP frame
type.

In fact, IP HW detect the packet as IPV6 type, even if the "IINS" bit is set,
the IP accelerator is not triggered to calculates IPV6 header checksum because
IPV6 frame format don't have checksum.

So this results in the IPV6 frame being corrupted.

The patch just add software detect the current packet type, if it is IPV6
frame, it don't clear IP header checksum field.

Reported-and-tested-by: Russell King <rmk+kernel@arm.linux.org.uk>
Signed-off-by: Fugang Duan <B38611@freescale.com>
Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/ethernet/freescale/fec_main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
index 38d9d276ab8b..77037fd377b8 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -320,6 +320,11 @@ static void *swap_buffer(void *bufaddr, int len)
 	return bufaddr;
 }
 
+static inline bool is_ipv4_pkt(struct sk_buff *skb)
+{
+	return skb->protocol == htons(ETH_P_IP) && ip_hdr(skb)->version == 4;
+}
+
 static int
 fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 {
@@ -330,7 +335,8 @@ fec_enet_clear_csum(struct sk_buff *skb, struct net_device *ndev)
 	if (unlikely(skb_cow_head(skb, 0)))
 		return -1;
 
-	ip_hdr(skb)->check = 0;
+	if (is_ipv4_pkt(skb))
+		ip_hdr(skb)->check = 0;
 	*(__sum16 *)(skb->head + skb->csum_start + skb->csum_offset) = 0;
 
 	return 0;
-- 
1.8.3.1
