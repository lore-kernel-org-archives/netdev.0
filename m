From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net 1/7] be2net: Fix to prevent Tx stall on SH-R when packet
 size < 32
Date: Fri, 27 Sep 2013 15:17:04 -0500
Message-ID: <20130927201704.GA4511@emulex.com>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:14687 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753269Ab3I0URH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 16:17:07 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tx on SH-R can lockup if the packet size is less than 32 bytes.
Pad such packets to a safer 36-byte size.
Patch uses the Lancer-R workaround - which checks for packet <= 32-bytes

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 100b528..31fa13b 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -855,11 +855,11 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 	unsigned int eth_hdr_len;
 	struct iphdr *ip;
 
-	/* Lancer ASIC has a bug wherein packets that are 32 bytes or less
+	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or less
 	 * may cause a transmit stall on that port. So the work-around is to
-	 * pad such packets to a 36-byte length.
+	 * pad short packets (<= 32 bytes) to a 36-byte length.
 	 */
-	if (unlikely(lancer_chip(adapter) && skb->len <= 32)) {
+	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
 		if (skb_padto(skb, 36))
 			goto tx_drop;
 		skb->len = 36;
-- 
1.8.1.2
