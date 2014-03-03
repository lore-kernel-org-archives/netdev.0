From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net v2 4/4] be2net: isolate TX workarounds not applicable to Skyhawk-R
Date: Mon, 3 Mar 2014 14:25:38 +0530
Message-ID: <eb74c94f-7efe-4bb9-9273-7385ddf76859@CMEXHTCAS2.ad.emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>,
	Vasundhara Volam <vasundhara.volam@emulex.com>,
	Sathya Perla <sathya.perla@emulex.com>,
	Somnath Kotur <somnath.kotur@emulex.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.ext.emulex.com ([138.239.224.100]:47403 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754061AbaCCI5X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 03:57:23 -0500
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
v2: Returning NULL directly instead of goto. (Thanks WBR,Sergei)

 drivers/net/ethernet/emulex/benet/be_main.c |   39 ++++++++++++++++++---------
 1 files changed, 26 insertions(+), 13 deletions(-)

diff --git a/drivers/net/ethernet/emulex/benet/be_main.c b/drivers/net/ethernet/emulex/benet/be_main.c
index a9da6f9..36c8061 100644
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
@@ -991,6 +981,29 @@ err:
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
+			return NULL;
+		skb->len = 36;
+	}
+
+	if (BEx_chip(adapter) || lancer_chip(adapter)) {
+		skb = be_lancer_xmit_workarounds(adapter, skb, skip_hw_vlan);
+		if (!skb)
+			return NULL;
+	}
+
+	return skb;
+}
+
 static netdev_tx_t be_xmit(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct be_adapter *adapter = netdev_priv(netdev);
-- 
1.5.6.1
