From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next 2/3] be2net: Pad skb to meet min Tx pkt size in lancer
Date: Mon, 27 May 2013 12:38:47 +0530
Message-ID: <c40f603c-7072-41db-b991-cf1ba84c941b@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, Somnath Kotur <somnath.kotur@emulex.com>,
	Kalesh AP <kalesh.purayil@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:17647 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753852Ab3E0HJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 May 2013 03:09:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In Lancer, packets that are 32 bytes or less may cause a transmit stall.
The work-around is to pad such packets to a 36 byte length.

Signed-off-by: Kalesh AP <kalesh.purayil@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 0f21c35..a1b9474 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -856,6 +856,16 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	unsigned int eth_hdr_len;
 	struct iphdr *ip;
 
+	/* Lancer ASIC has a bug wherein packets that are 32 bytes or less
+	 * may cause a transmit stall on that port. So the work-around is to
+	 * pad such packets to a 36-byte length.
+	 */
+	if (unlikely(lancer_chip(adapter) && skb->len <= 32)) {
+		if (skb_padto(skb, 36))
+			goto tx_drop;
+		skb->len = 36;
+	}
+
 	/* For padded packets, BE HW modifies tot_len field in IP header
 	 * incorrecly when VLAN tag is inserted by HW.
 	 */
-- 
1.5.6.1
