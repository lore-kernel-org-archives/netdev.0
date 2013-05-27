From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 3/3] be2net: Trim padded packets for Lancer
Date: Mon, 27 May 2013 12:39:06 +0530
Message-ID: <ef0e7e38-ba3f-45d5-a2d0-6f0831304d63@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:5508 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab3E0HKM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 03:10:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For padded packets, Lancer computes incorrect checksum. The workaround is
to trim such packets. This workaround is mainly for IPv4 packets.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a1b9474..0db8f65 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -868,10 +868,12 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 
 	/* For padded packets, BE HW modifies tot_len field in IP header
 	 * incorrecly when VLAN tag is inserted by HW.
+	 * For padded packets, Lancer computes incorrect checksum.
 	 */
 	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
 						VLAN_ETH_HLEN : ETH_HLEN;
-	if (skb->len <= 60 && vlan_tx_tag_present(skb) &&
+	if (skb->len <= 60 &&
+	    (lancer_chip(adapter) || vlan_tx_tag_present(skb)) &&
 	    is_ipv4_pkt(skb)) {
 		ip = (struct iphdr *)ip_hdr(skb);
 		pskb_trim(skb, eth_hdr_len + ntohs(ip->tot_len));
-- 
1.5.6.1
