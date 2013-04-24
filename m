From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 1/3] be2net: Remove an incorrect pvid check in Tx
Date: Wed, 24 Apr 2013 16:52:28 -0500
Message-ID: <20130424215228.GA5795@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:30384 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757864Ab3DXVwb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 17:52:31 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To work-around a HW bug that corrupts certain packets while inserting
a pvid, the driver needs to invoke a special hack in firmware to avoid
the VLAN tagging in the HW. Since this logic is missing from the driver,
removing the check for pvid.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   14 ++++----------
 1 files changed, 4 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2886c9b..a254942 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -626,11 +626,6 @@ static inline u16 be_get_tx_vlan_tag(struct be_adapter *adapter,
 	return vlan_tag;
 }
 
-static int be_vlan_tag_chk(struct be_adapter *adapter, struct sk_buff *skb)
-{
-	return vlan_tx_tag_present(skb) || adapter->pvid;
-}
-
 static void wrb_fill_hdr(struct be_adapter *adapter, struct be_eth_hdr_wrb *hdr,
 		struct sk_buff *skb, u32 wrb_cnt, u32 len)
 {
@@ -781,11 +776,10 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
 		VLAN_ETH_HLEN : ETH_HLEN;
 
-	/* HW has a bug which considers padding bytes as legal
-	 * and modifies the IPv4 hdr's 'tot_len' field
+	/* For padded packets, BE HW modifies tot_len field in IP header
+	 * incorrecly when VLAN tag is inserted by HW.
 	 */
-	if (skb->len <= 60 && be_vlan_tag_chk(adapter, skb) &&
-			is_ipv4_pkt(skb)) {
+	if (skb->len <= 60 && vlan_tx_tag_present(skb) && is_ipv4_pkt(skb)) {
 		ip = (struct iphdr *)ip_hdr(skb);
 		pskb_trim(skb, eth_hdr_len + ntohs(ip->tot_len));
 	}
@@ -795,7 +789,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	 * Manually insert VLAN in pkt.
 	 */
 	if (skb->ip_summed != CHECKSUM_PARTIAL &&
-			be_vlan_tag_chk(adapter, skb)) {
+			vlan_tx_tag_present(skb)) {
 		skb = be_insert_vlan_in_pkt(adapter, skb);
 		if (unlikely(!skb))
 			goto tx_drop;
-- 
1.7.1
