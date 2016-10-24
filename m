From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net] netvsc: fix incorrect receive checksum offloading
Date: Sun, 23 Oct 2016 21:32:47 -0700
Message-ID: <20161023213247.75d43c48@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>,
        KY Srinivasan <kys@microsoft.com>,
        Haiyang Zhang <haiyangz@microsoft.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:36775 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752087AbcJXEe4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Oct 2016 00:34:56 -0400
Received: by mail-pf0-f178.google.com with SMTP id e6so90778700pfk.3
        for <netdev@vger.kernel.org>; Sun, 23 Oct 2016 21:34:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <sthemmin@microsoft.com>

The Hyper-V netvsc driver was looking at the incorrect status bits
in the checksum info. It was setting the receive checksum unnecessary
flag based on the IP header checksum being correct. The checksum
flag is skb is about TCP and UDP checksum status. Because of this
bug, any packet received with bad TCP checksum would be passed
up the stack and to the application causing data corruption.
The problem is reproducible via netcat and netem.

This had a side effect of not doing receive checksum offload
on IPv6. The driver was also also always doing checksum offload
independent of the checksum setting done via ethtool.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
Please apply to -stable as well!

 drivers/net/hyperv/netvsc_drv.c | 19 +++++++++++--------
 1 file changed, 11 insertions(+), 8 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 5d6e75a..c71d966 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -607,15 +607,18 @@ static struct sk_buff *netvsc_alloc_recv_skb(struct net_device *net,
 	       packet->total_data_buflen);
 
 	skb->protocol = eth_type_trans(skb, net);
-	if (csum_info) {
-		/* We only look at the IP checksum here.
-		 * Should we be dropping the packet if checksum
-		 * failed? How do we deal with other checksums - TCP/UDP?
-		 */
-		if (csum_info->receive.ip_checksum_succeeded)
+
+	/* skb is already created with CHECKSUM_NONE */
+	skb_checksum_none_assert(skb);
+
+	/*
+	 * In Linux, the IP checksum is always checked.
+	 * Do L4 checksum offload if enabled and present.
+	 */
+	if (csum_info && (net->features & NETIF_F_RXCSUM)) {
+		if (csum_info->receive.tcp_checksum_succeeded ||
+		    csum_info->receive.udp_checksum_succeeded)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
-		else
-			skb->ip_summed = CHECKSUM_NONE;
 	}
 
 	if (vlan_tci & VLAN_TAG_PRESENT)
-- 
2.9.3
