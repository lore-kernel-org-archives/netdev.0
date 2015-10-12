From: Sathya Perla <sathya.perla@avagotech.com>
Subject: [PATCH 3/5] be2net: pad skb to meet minimum TX pkt size in BE3
Date: Mon, 12 Oct 2015 03:47:19 -0400
Message-ID: <1444636041-4727-4-git-send-email-sathya.perla@avagotech.com>
References: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmrelayp1.emulex.com ([138.239.112.140]:50637 "EHLO
	CMRELAYP1.ad.emulex.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751779AbbJLH5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2015 03:57:24 -0400
In-Reply-To: <1444636041-4727-1-git-send-email-sathya.perla@avagotech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Suresh Reddy <Suresh.Reddy@avagotech.com>

On BE3 chips in SRIOV configs, the TX path stalls when a packet less
than 32B is received from the host. A workaround to pad such packets
already exists for the Skyhawk and Lancer chips. Use the same workaround
for BE3 chips too.

Signed-off-by: Suresh Reddy <suresh.reddy@avagotech.com>
Signed-off-by: Sathya Perla <sathya.perla@avagotech.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c | 9 +++++----
 1 file changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index 86eed47..821e014 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -1123,11 +1123,12 @@ static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
 					   struct sk_buff *skb,
 					   struct be_wrb_params *wrb_params)
 {
-	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or
-	 * less may cause a transmit stall on that port. So the work-around is
-	 * to pad short packets (<= 32 bytes) to a 36-byte length.
+	/* Lancer, SH and BE3 in SRIOV mode have a bug wherein
+	 * packets that are 32b or less may cause a transmit stall
+	 * on that port. The workaround is to pad such packets
+	 * (len <= 32 bytes) to a minimum length of 36b.
 	 */
-	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
+	if (skb->len <= 32) {
 		if (skb_put_padto(skb, 36))
 			return NULL;
 	}
-- 
2.4.1
