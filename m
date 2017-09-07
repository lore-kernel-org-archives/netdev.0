From: <Tristram.Ha@microchip.com>
Subject: [PATCH RFC 6/6] Modify tag_ksz.c to support other KSZ switch drivers
Date: Thu, 7 Sep 2017 21:09:30 +0000
Message-ID: <93AF473E2DA327428DE3D46B72B1E9FD41121A22@CHN-SV-EXMX02.mchp-main.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <andrew@lunn.ch>, <muvarov@gmail.com>, <pavel@ucw.cz>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>, <f.fainelli@gmail.com>,
        <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        <Woojung.Huh@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:25730 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932464AbdIGVJn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 17:09:43 -0400
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121901@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tristram Ha <Tristram.Ha@microchip.com>

The KSZ tail tag code can be used by different KSZ switch drivers.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c index 010ca0a..d5faf14 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -13,35 +13,21 @@
 #include <linux/slab.h>
 #include <net/dsa.h>
 #include "dsa_priv.h"
-
-/* For Ingress (Host -> KSZ), 2 bytes are added before FCS.
- * ---------------------------------------------------------------------------
- * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|tag1(1byte)|FCS(4bytes)
- * ---------------------------------------------------------------------------
- * tag0 : Prioritization (not used now)
- * tag1 : each bit represents port (eg, 0x01=port1, 0x02=port2, 0x10=port5)
- *
- * For Egress (KSZ -> Host), 1 byte is added before FCS.
- * ---------------------------------------------------------------------------
- * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|FCS(4bytes)
- * ---------------------------------------------------------------------------
- * tag0 : zero-based value represents port
- *	  (eg, 0x00=port1, 0x02=port3, 0x06=port7)
- */
-
-#define	KSZ_INGRESS_TAG_LEN	2
-#define	KSZ_EGRESS_TAG_LEN	1
+#include "../../drivers/net/dsa/microchip/ksz_priv.h"
 
 static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)  {
 	struct dsa_slave_priv *p = netdev_priv(dev);
+	struct dsa_switch *ds = p->dp->ds;
+	struct ksz_device *swdev = ds->priv;
 	struct sk_buff *nskb;
+	int len;
 	int padlen;
-	u8 *tag;
 
 	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
 
-	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
+	len = swdev->dev_ops->get_tx_len(swdev);
+	if (skb_tailroom(skb) >= padlen + len) {
 		/* Let dsa_slave_xmit() free skb */
 		if (__skb_put_padto(skb, skb->len + padlen, false))
 			return NULL;
@@ -49,7 +35,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 		nskb = skb;
 	} else {
 		nskb = alloc_skb(NET_IP_ALIGN + skb->len +
-				 padlen + KSZ_INGRESS_TAG_LEN, GFP_ATOMIC);
+				 padlen + len, GFP_ATOMIC);
 		if (!nskb)
 			return NULL;
 		skb_reserve(nskb, NET_IP_ALIGN);
@@ -70,9 +56,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 		consume_skb(skb);
 	}
 
-	tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
-	tag[0] = 0;
-	tag[1] = 1 << p->dp->index; /* destination port */
+	swdev->dev_ops->add_tail_tag(swdev, nskb, p->dp->index);
 
 	return nskb;
 }
@@ -83,16 +67,16 @@ static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
 	struct dsa_switch_tree *dst = dev->dsa_ptr;
 	struct dsa_port *cpu_dp = dsa_get_cpu_port(dst);
 	struct dsa_switch *ds = cpu_dp->ds;
-	u8 *tag;
+	struct ksz_device *swdev = ds->priv;
+	int len;
 	int source_port;
 
-	tag = skb_tail_pointer(skb) - KSZ_EGRESS_TAG_LEN;
+	len = swdev->dev_ops->get_tail_tag(swdev, skb, &source_port);
 
-	source_port = tag[0] & 7;
 	if (source_port >= ds->num_ports || !ds->ports[source_port].netdev)
 		return NULL;
 
-	pskb_trim_rcsum(skb, skb->len - KSZ_EGRESS_TAG_LEN);
+	pskb_trim_rcsum(skb, skb->len - len);
 
 	skb->dev = ds->ports[source_port].netdev;
