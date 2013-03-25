From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next (TAKE 4) 2/6] firewire net: Send L2 multicast via
 GASP.
Date: Tue, 26 Mar 2013 03:25:48 +0900
Message-ID: <515096AC.6050505@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux1394-devel@lists.sourceforge.net,
	stephan.gatzka@gmail.com, yoshfuji@linux-ipv6.org
To: davem@davemloft.net, stefanr@s5r6.in-berlin.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:58075 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932576Ab3CYSZt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Mar 2013 14:25:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Send L2 multicast packet via GASP (Global asynchronous stream packet) by
seeing the multicast bit in the L2 hardware address, not by seeing upper-
layer protocol address.

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 drivers/firewire/net.c |   12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index d438c5b..7c2e16a 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -84,6 +84,11 @@ struct fwnet_header {
 	__be16 h_proto;		/* packet type ID field */
 } __packed;
 
+static bool fwnet_hwaddr_is_multicast(u8 *ha)
+{
+	return !!(*ha & 1);
+}
+
 /* IPv4 and IPv6 encapsulation header */
 struct rfc2734_header {
 	u32 w0;
@@ -626,7 +631,7 @@ static int fwnet_finish_incoming_packet(struct net_device *net,
 		skb_reset_mac_header(skb);
 		skb_pull(skb, sizeof(*eth));
 		eth = (struct fwnet_header *)skb_mac_header(skb);
-		if (*eth->h_dest & 1) {
+		if (fwnet_hwaddr_is_multicast(eth->h_dest)) {
 			if (memcmp(eth->h_dest, net->broadcast,
 				   net->addr_len) == 0)
 				skb->pkt_type = PACKET_BROADCAST;
@@ -1366,10 +1371,7 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
 	 * Set the transmission type for the packet.  ARP packets and IP
 	 * broadcast packets are sent via GASP.
 	 */
-	if (memcmp(hdr_buf.h_dest, net->broadcast, FWNET_ALEN) == 0
-	    || proto == htons(ETH_P_ARP)
-	    || (proto == htons(ETH_P_IP)
-		&& IN_MULTICAST(ntohl(ip_hdr(skb)->daddr)))) {
+	if (fwnet_hwaddr_is_multicast(hdr_buf.h_dest)) {
 		max_payload        = dev->broadcast_xmt_max_payload;
 		datagram_label_ptr = &dev->broadcast_xmt_datagramlabel;
 
-- 
1.7.9.5
