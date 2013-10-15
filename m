From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH 2/2] be2net: drop non-tso frames longer than mtu
Date: Tue, 15 Oct 2013 17:26:28 +0530
Message-ID: <1381838188-9625-2-git-send-email-sathya.perla@emulex.com>
References: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:26240 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758776Ab3JOLwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Oct 2013 07:52:50 -0400
In-Reply-To: <1381838188-9625-1-git-send-email-sathya.perla@emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Pktgen can generate non-TSO frames of arbitrary length disregarding
the MTU value of the physical interface. Drop such frames in the driver
instead of sending them to HW as it cannot handle such frames.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 2c38cc4..76057b8 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -855,6 +855,13 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	unsigned int eth_hdr_len;
 	struct iphdr *ip;
 
+	/* Don't allow non-TSO packets longer than MTU */
+	eth_hdr_len = (ntohs(skb->protocol) == ETH_P_8021Q) ?
+			VLAN_ETH_HLEN : ETH_HLEN;
+	if (!skb_is_gso(skb) &&
+	    (skb->len - eth_hdr_len) > adapter->netdev->mtu)
+			goto tx_drop;
+
 	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or less
 	 * may cause a transmit stall on that port. So the work-around is to
 	 * pad short packets (<= 32 bytes) to a 36-byte length.
@@ -869,8 +876,6 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	 * incorrecly when VLAN tag is inserted by HW.
 	 * For padded packets, Lancer computes incorrect checksum.
 	 */
-	eth_hdr_len = ntohs(skb->protocol) == ETH_P_8021Q ?
-						VLAN_ETH_HLEN : ETH_HLEN;
 	if (skb->len <= 60 &&
 	    (lancer_chip(adapter) || vlan_tx_tag_present(skb)) &&
 	    is_ipv4_pkt(skb)) {
-- 
1.7.1
