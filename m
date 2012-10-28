From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 10/16] batman-adv: don't allow ECTP traffic on batman-adv
Date: Sun, 28 Oct 2012 12:17:11 +0100
Message-ID: <1351423037-5292-11-git-send-email-ordex@autistici.org>
References: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	Simon Wunderlich <siwu@hrz.tu-chemnitz.de>,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from latitanza.investici.org ([82.94.249.234]:56104 "EHLO
	latitanza.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750932Ab2J1LSj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2012 07:18:39 -0400
In-Reply-To: <1351423037-5292-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>

We have seen this to break networks when used with bridge loop
avoidance. As we can't see any benefit from sending these ancient frames
via our mesh, we just drop them.

Signed-off-by: Simon Wunderlich <siwu@hrz.tu-chemnitz.de>
Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/soft-interface.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 948860a..22bc651 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -146,8 +146,10 @@ static int batadv_interface_tx(struct sk_buff *skb,
 	struct batadv_bcast_packet *bcast_packet;
 	struct vlan_ethhdr *vhdr;
 	__be16 ethertype = __constant_htons(BATADV_ETH_P_BATMAN);
-	static const uint8_t stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00, 0x00,
-						   0x00};
+	static const uint8_t stp_addr[ETH_ALEN] = {0x01, 0x80, 0xC2, 0x00,
+						   0x00, 0x00};
+	static const uint8_t ectp_addr[ETH_ALEN] = {0xCF, 0x00, 0x00, 0x00,
+						    0x00, 0x00};
 	unsigned int header_len = 0;
 	int data_len = skb->len, ret;
 	short vid __maybe_unused = -1;
@@ -180,10 +182,16 @@ static int batadv_interface_tx(struct sk_buff *skb,
 
 	/* don't accept stp packets. STP does not help in meshes.
 	 * better use the bridge loop avoidance ...
+	 *
+	 * The same goes for ECTP sent at least by some Cisco Switches,
+	 * it might confuse the mesh when used with bridge loop avoidance.
 	 */
 	if (batadv_compare_eth(ethhdr->h_dest, stp_addr))
 		goto dropped;
 
+	if (batadv_compare_eth(ethhdr->h_dest, ectp_addr))
+		goto dropped;
+
 	if (is_multicast_ether_addr(ethhdr->h_dest)) {
 		do_bcast = true;
 
-- 
1.7.12.4
