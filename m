From: <Tristram.Ha@microchip.com>
Subject: [PATCH v1 RFC 7/7] Modify tag_ksz.c so that tail tag code can be used by other KSZ switch drivers
Date: Fri, 6 Oct 2017 13:33:05 -0700
Message-ID: <1507321985-15097-8-git-send-email-Tristram.Ha@microchip.com>
References: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Tristram Ha <Tristram.Ha@microchip.com>, <muvarov@gmail.com>,
        <nathan.leigh.conrad@gmail.com>,
        <vivien.didelot@savoirfairelinux.com>,
        <UNGLinuxDriver@microchip.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Pavel Machek <pavel@ucw.cz>,
        Ruediger Schmitt <ruediger.schmitt@philips.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1507321985-15097-1-git-send-email-Tristram.Ha@microchip.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tristram Ha <Tristram.Ha@microchip.com>

Modify tag_ksz.c so that tail tag code can be used by other KSZ switch
drivers.

Signed-off-by: Tristram Ha <Tristram.Ha@microchip.com>
---
 drivers/net/dsa/microchip/Kconfig   |   2 +-
 drivers/net/dsa/microchip/ksz9477.c |   2 +-
 include/net/dsa.h                   |   2 +-
 net/dsa/Kconfig                     |   4 ++
 net/dsa/dsa.c                       |   4 +-
 net/dsa/dsa_priv.h                  |   2 +-
 net/dsa/tag_ksz.c                   | 107 ++++++++++++++++++++++++++----------
 7 files changed, 88 insertions(+), 35 deletions(-)

diff --git a/drivers/net/dsa/microchip/Kconfig b/drivers/net/dsa/microchip/Kconfig
index 5a8660d..ab8f9f6 100644
--- a/drivers/net/dsa/microchip/Kconfig
+++ b/drivers/net/dsa/microchip/Kconfig
@@ -1,7 +1,7 @@
 menuconfig MICROCHIP_KSZ9477
 	tristate "Microchip KSZ9477 series switch support"
 	depends on NET_DSA
-	select NET_DSA_TAG_KSZ
+	select NET_DSA_TAG_KSZ9477
 	help
 	  This driver adds support for Microchip KSZ9477 switch chips.
 
diff --git a/drivers/net/dsa/microchip/ksz9477.c b/drivers/net/dsa/microchip/ksz9477.c
index 9579d03..e6d2956 100644
--- a/drivers/net/dsa/microchip/ksz9477.c
+++ b/drivers/net/dsa/microchip/ksz9477.c
@@ -342,7 +342,7 @@ static void ksz9477_port_init_cnt(struct ksz_device *dev, int port)
 
 static enum dsa_tag_protocol ksz9477_get_tag_protocol(struct dsa_switch *ds)
 {
-	return DSA_TAG_PROTO_KSZ;
+	return DSA_TAG_PROTO_KSZ9477;
 }
 
 static int ksz9477_phy_read16(struct dsa_switch *ds, int addr, int reg)
diff --git a/include/net/dsa.h b/include/net/dsa.h
index 10dcecc..28cdc5e 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -31,7 +31,7 @@ enum dsa_tag_protocol {
 	DSA_TAG_PROTO_BRCM,
 	DSA_TAG_PROTO_DSA,
 	DSA_TAG_PROTO_EDSA,
-	DSA_TAG_PROTO_KSZ,
+	DSA_TAG_PROTO_KSZ9477,
 	DSA_TAG_PROTO_LAN9303,
 	DSA_TAG_PROTO_MTK,
 	DSA_TAG_PROTO_QCA,
diff --git a/net/dsa/Kconfig b/net/dsa/Kconfig
index cc5f8f9..d2bbd21 100644
--- a/net/dsa/Kconfig
+++ b/net/dsa/Kconfig
@@ -28,6 +28,10 @@ config NET_DSA_TAG_EDSA
 config NET_DSA_TAG_KSZ
 	bool
 
+config NET_DSA_TAG_KSZ9477
+	bool
+	select NET_DSA_TAG_KSZ
+
 config NET_DSA_TAG_LAN9303
 	bool
 
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 51ca2a5..cc03a09 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -49,8 +49,8 @@ static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
 #ifdef CONFIG_NET_DSA_TAG_EDSA
 	[DSA_TAG_PROTO_EDSA] = &edsa_netdev_ops,
 #endif
-#ifdef CONFIG_NET_DSA_TAG_KSZ
-	[DSA_TAG_PROTO_KSZ] = &ksz_netdev_ops,
+#ifdef CONFIG_NET_DSA_TAG_KSZ9477
+	[DSA_TAG_PROTO_KSZ9477] = &ksz9477_netdev_ops,
 #endif
 #ifdef CONFIG_NET_DSA_TAG_LAN9303
 	[DSA_TAG_PROTO_LAN9303] = &lan9303_netdev_ops,
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 2850077c..e0dc2d4 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -183,7 +183,7 @@ int dsa_port_vlan_del(struct dsa_port *dp,
 extern const struct dsa_device_ops edsa_netdev_ops;
 
 /* tag_ksz.c */
-extern const struct dsa_device_ops ksz_netdev_ops;
+extern const struct dsa_device_ops ksz9477_netdev_ops;
 
 /* tag_lan9303.c */
 extern const struct dsa_device_ops lan9303_netdev_ops;
diff --git a/net/dsa/tag_ksz.c b/net/dsa/tag_ksz.c
index b241c99..1bb5b7d 100644
--- a/net/dsa/tag_ksz.c
+++ b/net/dsa/tag_ksz.c
@@ -14,34 +14,28 @@
 #include <net/dsa.h>
 #include "dsa_priv.h"
 
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
+/* Typically only one byte is used for tail tag. */
+#define	KSZ_EGRESS_TAG_LEN		1
+#define	KSZ_INGRESS_TAG_LEN		1
 
-#define	KSZ_INGRESS_TAG_LEN	2
-#define	KSZ_EGRESS_TAG_LEN	1
+/* Frames with following addresse may need to be sent even when the port is
+ * closed.
+ */
+static const u8 special_mult_addr[] = {
+	0x01, 0x80, 0xC2, 0x00, 0x00, 0x00
+};
 
-static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
+static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev,
+				int len,
+				void (*set_tag)(void *ptr, u8 *addr, int p))
 {
 	struct dsa_slave_priv *p = netdev_priv(dev);
 	struct sk_buff *nskb;
 	int padlen;
-	u8 *tag;
 
 	padlen = (skb->len >= ETH_ZLEN) ? 0 : ETH_ZLEN - skb->len;
 
-	if (skb_tailroom(skb) >= padlen + KSZ_INGRESS_TAG_LEN) {
+	if (skb_tailroom(skb) >= padlen + len) {
 		/* Let dsa_slave_xmit() free skb */
 		if (__skb_put_padto(skb, skb->len + padlen, false))
 			return NULL;
@@ -49,7 +43,7 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 		nskb = skb;
 	} else {
 		nskb = alloc_skb(NET_IP_ALIGN + skb->len +
-				 padlen + KSZ_INGRESS_TAG_LEN, GFP_ATOMIC);
+				 padlen + len, GFP_ATOMIC);
 		if (!nskb)
 			return NULL;
 		skb_reserve(nskb, NET_IP_ALIGN);
@@ -70,33 +64,88 @@ static struct sk_buff *ksz_xmit(struct sk_buff *skb, struct net_device *dev)
 		consume_skb(skb);
 	}
 
-	tag = skb_put(nskb, KSZ_INGRESS_TAG_LEN);
-	tag[0] = 0;
-	tag[1] = 1 << p->dp->index; /* destination port */
+	set_tag(skb_put(nskb, len), skb_mac_header(nskb), p->dp->index);
 
 	return nskb;
 }
 
 static struct sk_buff *ksz_rcv(struct sk_buff *skb, struct net_device *dev,
-			       struct packet_type *pt)
+			       struct packet_type *pt,
+			       int (*get_tag)(u8 *tag, int *port))
 {
 	u8 *tag;
+	int len;
 	int source_port;
 
 	tag = skb_tail_pointer(skb) - KSZ_EGRESS_TAG_LEN;
 
-	source_port = tag[0] & 7;
+	len = get_tag(tag, &source_port);
 
 	skb->dev = dsa_master_get_slave(dev, 0, source_port);
 	if (!skb->dev)
 		return NULL;
 
-	pskb_trim_rcsum(skb, skb->len - KSZ_EGRESS_TAG_LEN);
+	pskb_trim_rcsum(skb, skb->len - len);
 
 	return skb;
 }
 
-const struct dsa_device_ops ksz_netdev_ops = {
-	.xmit	= ksz_xmit,
-	.rcv	= ksz_rcv,
+/* For Ingress (Host -> KSZ9477), 2 bytes are added before FCS.
+ * ---------------------------------------------------------------------------
+ * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|tag1(1byte)|FCS(4bytes)
+ * ---------------------------------------------------------------------------
+ * tag0 : Prioritization (not used now)
+ * tag1 : each bit represents port (eg, 0x01=port1, 0x02=port2, 0x10=port5)
+ *
+ * For Egress (KSZ9477 -> Host), 1 byte is added before FCS.
+ * ---------------------------------------------------------------------------
+ * DA(6bytes)|SA(6bytes)|....|Data(nbytes)|tag0(1byte)|FCS(4bytes)
+ * ---------------------------------------------------------------------------
+ * tag0 : zero-based value represents port
+ *	  (eg, 0x00=port1, 0x02=port3, 0x06=port7)
+ */
+
+#define KSZ9477_INGRESS_TAG_LEN		2
+#define KSZ9477_PTP_TAG_LEN		4
+#define KSZ9477_PTP_TAG_INDICATION	0x80
+
+#define KSZ9477_TAIL_TAG_OVERRIDE	BIT(9)
+#define KSZ9477_TAIL_TAG_LOOKUP		BIT(10)
+
+static int ksz9477_get_tag(u8 *tag, int *port)
+{
+	int len = KSZ_EGRESS_TAG_LEN;
+
+	/* Extra 4-bytes PTP timestamp */
+	if (tag[0] & KSZ9477_PTP_TAG_INDICATION)
+		len += KSZ9477_PTP_TAG_LEN;
+	*port = tag[0] & 7;
+	return len;
+}
+
+static void ksz9477_set_tag(void *ptr, u8 *addr, int p)
+{
+	u16 *tag = (u16 *)ptr;
+
+	*tag = 1 << p;
+	if (!memcmp(addr, special_mult_addr, ETH_ALEN))
+		*tag |= KSZ9477_TAIL_TAG_OVERRIDE;
+	*tag = cpu_to_be16(*tag);
+}
+
+static struct sk_buff *ksz9477_xmit(struct sk_buff *skb,
+				    struct net_device *dev)
+{
+	return ksz_xmit(skb, dev, KSZ9477_INGRESS_TAG_LEN, ksz9477_set_tag);
+}
+
+static struct sk_buff *ksz9477_rcv(struct sk_buff *skb, struct net_device *dev,
+				   struct packet_type *pt)
+{
+	return ksz_rcv(skb, dev, pt, ksz9477_get_tag);
+}
+
+const struct dsa_device_ops ksz9477_netdev_ops = {
+	.xmit	= ksz9477_xmit,
+	.rcv	= ksz9477_rcv,
 };
-- 
1.9.1
