From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net 5/5] be2net: isolate TX workarounds not applicable to Skyhawk-R
Date: Mon, 24 Feb 2014 12:21:09 +0530
Message-ID: <ad20d448-e798-4898-9823-898de98d54a2@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge1.ext.emulex.com ([138.239.224.99]:8500 "EHLO
	CMEXEDGE1.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751922AbaBXGwy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 01:52:54 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasundhara Volam <vasundhara.volam@emulex.com>

Some of TX workarounds in be_xmit_workarounds() routine
are not applicable (and result in HW errors) to Skyhawk-R chip.
Isolate BE3-R/Lancer specific workarounds to a separate routine.

Signed-off-by: Vasundhara Volam <vasundhara.volam@emulex.com>
Signed-off-by: Sathya Perla <sathya.perla@emulex.com>
Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/ethernet/emulex/benet/be_main.c |   42 ++++++++++++++++++--------
 1 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index f6a4481..6cf6e2a 100644
--- a/drivers/net/ethernet/emulex/benet/be_main.c
+++ b/drivers/net/ethernet/emulex/benet/be_main.c
@@ -913,24 +913,14 @@ static int be_ipv6_tx_stall_chk(struct be_adapter *adapter,
 	return BE3_chip(adapter) && be_ipv6_exthdr_check(skb);
 }
 
-static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
-					   struct sk_buff *skb,
-					   bool *skip_hw_vlan)
+static struct sk_buff *be_lancer_xmit_workarounds(struct be_adapter *adapter,
+						  struct sk_buff *skb,
+						  bool *skip_hw_vlan)
 {
 	struct vlan_ethhdr *veh = (struct vlan_ethhdr *)skb->data;
 	unsigned int eth_hdr_len;
 	struct iphdr *ip;
 
-	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or less
-	 * may cause a transmit stall on that port. So the work-around is to
-	 * pad short packets (<= 32 bytes) to a 36-byte length.
-	 */
-	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
-		if (skb_padto(skb, 36))
-			goto err;
-		skb->len = 36;
-	}
-
 	/* For padded packets, BE HW modifies tot_len field in IP header
 	 * incorrecly when VLAN tag is inserted by HW.
 	 * For padded packets, Lancer computes incorrect checksum.
@@ -991,6 +981,32 @@ err:
 	return NULL;
 }
 
+static struct sk_buff *be_xmit_workarounds(struct be_adapter *adapter,
+					   struct sk_buff *skb,
+					   bool *skip_hw_vlan)
+{
+	/* Lancer, SH-R ASICs have a bug wherein Packets that are 32 bytes or
+	 * less may cause a transmit stall on that port. So the work-around is
+	 * to pad short packets (<= 32 bytes) to a 36-byte length.
+	 */
+	if (unlikely(!BEx_chip(adapter) && skb->len <= 32)) {
+		if (skb_padto(skb, 36))
+			goto err;
+		skb->len = 36;
+	}
+
+	if (BEx_chip(adapter) || lancer_chip(adapter)) {
+		skb = be_lancer_xmit_workarounds(adapter, skb, skip_hw_vlan);
+		if (!skb)
+			goto err;
+	}
+
+	return skb;
+
+err:
+	return NULL;
+}
+
 static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-- 
1.5.6.1
