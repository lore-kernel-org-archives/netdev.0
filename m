From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 3/3] be2net: Fix PVID tag offload for packets with inline
 VLAN tag.
Date: Wed, 24 Apr 2013 16:53:08 -0500
Message-ID: <20130424215308.GA5829@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:30394 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757864Ab3DXVxL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Apr 2013 17:53:11 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BE3 HW in UMC mode could wrongly double tag a packet with PVID
when the packet already has a inlined VLAN tag.
In UMC mode, When HW finds that a packet is already VLAN tagged
PVID should not be inserted into the packet.
To fix this use the FW hack to instruct the HW to skip PVID tagging.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 21109b5..1232e91 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -834,6 +834,7 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 	u32 start = txq->head, eth_hdr_len;
 	bool dummy_wrb, stopped = false;
 	bool skip_hw_vlan = false;
+	struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 
 	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
 		VLAN_ETH_HLEN : ETH_HLEN;
@@ -846,6 +847,13 @@ static netdev_tx_t be_xmit(struct sk_buff *skb,
 		pskb_trim(skb, eth_hdr_len + ntohs(ip->tot_len));
 	}
 
+	/* If vlan tag is already inlined in the packet, skip HW VLAN
+	 * tagging in UMC mode
+	 */
+	if ((adapter->function_mode & UMC_ENABLED) &&
+	    veh->h_vlan_proto == htons(ETH_P_8021Q))
+			skip_hw_vlan = true;
+
 	/* HW has a bug wherein it will calculate CSUM for VLAN
 	 * pkts even though it is disabled.
 	 * Manually insert VLAN in pkt.
-- 
1.7.1
