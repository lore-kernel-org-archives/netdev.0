From: =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
Subject: [PATCH 1/2] sierra_net: Add support for IPv6 and Dual-Stack Link Sense Indications
Date: Mon, 6 Feb 2017 21:20:33 +0100
Message-ID: <e854396b8b354f08ab42647417958079@rwthex-w2-b.rwth-ad.de>
References: <20170206202034.10962-1-stefan.bruens@rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        =?UTF-8?q?Stefan=20Br=C3=BCns?= <stefan.bruens@rwth-aachen.de>
To: <linux-usb@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170206202034.10962-1-stefan.bruens@rwth-aachen.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If a context is configured as dualstack ("IPv4v6"), the modem indicates
the context activation with a slightly different indication message.
The dual-stack indication omits the link_type (IPv4/v6) and adds
additional address fields.
IPv6 LSIs are identical to IPv4 LSIs, but have a different link type.

Signed-off-by: Stefan Brüns <stefan.bruens@rwth-aachen.de>
---
Example LSI LINK UP indication:

0000   00 ed 78 00 04 01 00 e9 0a 14 00 54 00 65 00 6c  ..x........T.e.l
0010   00 65 00 6b 00 6f 00 6d 00 2e 00 64 00 65 48 03  .e.k.o.m...d.eH.
0020   c8 be d1 00 62 00 00 00 2c 80 f0 01 00 00 00 00  ....b...,.......
0030   30 cb 04 4c 49 4e 4b 20 55 50 00 00 00 00 00 00  0..LINK UP......
0040   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
0050   00 00 00 00 04 0a 23 38 db 10 2a 01 05 98 88 c0  ......#8..*.....
0060   1f da 00 01 00 01 91 23 a8 f9 00 00 00 00 00 00  .......#........
0070   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
0080   00 04 0a 4a d2 d2 10 2a 01 05 98 07 ff 00 00 00  ...J...*........
0090   10 00 74 02 10 02 10 04 0a 4a d2 d3 10 2a 01 05  ..t......J...*..
00a0   98 07 ff 00 00 00 10 00 74 02 10 02 11 00 00 00  ........t.......
00b0   00 00 00 00 00 00 00 00 00 00 00 00 00 ff ff 00  ................
00c0   00 00 00 00 00 c3 50 04 00 00 00 00 10 fe 80 00  ......P.........
00d0   00 00 00 00 00 00 00 00 00 00 00 00 05 00 00 00  ................
00e0   00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
00f0   00
---
 drivers/net/usb/sierra_net.c | 82 +++++++++++++++++++++++++++++++-------------
 1 file changed, 58 insertions(+), 24 deletions(-)

diff --git a/drivers/net/usb/sierra_net.c b/drivers/net/usb/sierra_net.c
index a251588762ec..8c2a16c28ec1 100644
--- a/drivers/net/usb/sierra_net.c
+++ b/drivers/net/usb/sierra_net.c
@@ -122,6 +122,7 @@ struct param {
 
 /* LSI Protocol types */
 #define SIERRA_NET_PROTOCOL_UMTS      0x01
+#define SIERRA_NET_PROTOCOL_UMTS_DS   0x04
 /* LSI Coverage */
 #define SIERRA_NET_COVERAGE_NONE      0x00
 #define SIERRA_NET_COVERAGE_NOPACKET  0x01
@@ -129,7 +130,8 @@ struct param {
 /* LSI Session */
 #define SIERRA_NET_SESSION_IDLE       0x00
 /* LSI Link types */
-#define SIERRA_NET_AS_LINK_TYPE_IPv4  0x00
+#define SIERRA_NET_AS_LINK_TYPE_IPV4  0x00
+#define SIERRA_NET_AS_LINK_TYPE_IPV6  0x02
 
 struct lsi_umts {
 	u8 protocol;
@@ -137,9 +139,14 @@ struct lsi_umts {
 	__be16 length;
 	/* eventually use a union for the rest - assume umts for now */
 	u8 coverage;
-	u8 unused2[41];
+	u8 network_len; /* network name len */
+	u8 network[40]; /* network name (UCS2, bigendian) */
 	u8 session_state;
 	u8 unused3[33];
+} __packed;
+
+struct lsi_umts_single {
+	struct lsi_umts lsi;
 	u8 link_type;
 	u8 pdp_addr_len; /* NW-supplied PDP address len */
 	u8 pdp_addr[16]; /* NW-supplied PDP address (bigendian)) */
@@ -158,10 +165,31 @@ struct lsi_umts {
 	u8 reserved[8];
 } __packed;
 
+struct lsi_umts_dual {
+	struct lsi_umts lsi;
+	u8 pdp_addr4_len; /* NW-supplied PDP IPv4 address len */
+	u8 pdp_addr4[4];  /* NW-supplied PDP IPv4 address (bigendian)) */
+	u8 pdp_addr6_len; /* NW-supplied PDP IPv6 address len */
+	u8 pdp_addr6[16]; /* NW-supplied PDP IPv6 address (bigendian)) */
+	u8 unused4[23];
+	u8 dns1_addr4_len; /* NW-supplied 1st DNS v4 address len (bigendian) */
+	u8 dns1_addr4[4];  /* NW-supplied 1st DNS v4 address */
+	u8 dns1_addr6_len; /* NW-supplied 1st DNS v6 address len */
+	u8 dns1_addr6[16]; /* NW-supplied 1st DNS v6 address (bigendian)*/
+	u8 dns2_addr4_len; /* NW-supplied 2nd DNS v4 address len (bigendian) */
+	u8 dns2_addr4[4];  /* NW-supplied 2nd DNS v4 address */
+	u8 dns2_addr6_len; /* NW-supplied 2nd DNS v6 address len */
+	u8 dns2_addr6[16]; /* NW-supplied 2nd DNS v6 address (bigendian)*/
+	u8 unused5[68];
+} __packed;
+
 #define SIERRA_NET_LSI_COMMON_LEN      4
-#define SIERRA_NET_LSI_UMTS_LEN        (sizeof(struct lsi_umts))
+#define SIERRA_NET_LSI_UMTS_LEN        (sizeof(struct lsi_umts_single))
 #define SIERRA_NET_LSI_UMTS_STATUS_LEN \
 	(SIERRA_NET_LSI_UMTS_LEN - SIERRA_NET_LSI_COMMON_LEN)
+#define SIERRA_NET_LSI_UMTS_DS_LEN     (sizeof(struct lsi_umts_dual))
+#define SIERRA_NET_LSI_UMTS_DS_STATUS_LEN \
+	(SIERRA_NET_LSI_UMTS_DS_LEN - SIERRA_NET_LSI_COMMON_LEN)
 
 /* Forward definitions */
 static void sierra_sync_timer(unsigned long syncdata);
@@ -191,10 +219,11 @@ static inline void sierra_net_set_private(struct usbnet *dev,
 	dev->data[0] = (unsigned long)priv;
 }
 
-/* is packet IPv4 */
+/* is packet IPv4/IPv6 */
 static inline int is_ip(struct sk_buff *skb)
 {
-	return skb->protocol == cpu_to_be16(ETH_P_IP);
+	return skb->protocol == cpu_to_be16(ETH_P_IP) ||
+	       skb->protocol == cpu_to_be16(ETH_P_IPV6);
 }
 
 /*
@@ -350,38 +379,43 @@ static inline int sierra_net_is_valid_addrlen(u8 len)
 static int sierra_net_parse_lsi(struct usbnet *dev, char *data, int datalen)
 {
 	struct lsi_umts *lsi = (struct lsi_umts *)data;
+	u32 expected_length;
 
-	if (datalen < sizeof(struct lsi_umts)) {
-		netdev_err(dev->net, "%s: Data length %d, exp %Zu\n",
-				__func__, datalen,
-				sizeof(struct lsi_umts));
-		return -1;
-	}
-
-	if (lsi->length != cpu_to_be16(SIERRA_NET_LSI_UMTS_STATUS_LEN)) {
-		netdev_err(dev->net, "%s: LSI_UMTS_STATUS_LEN %d, exp %u\n",
-				__func__, be16_to_cpu(lsi->length),
-				(u32)SIERRA_NET_LSI_UMTS_STATUS_LEN);
+	if (datalen < sizeof(struct lsi_umts_single)) {
+		netdev_err(dev->net, "%s: Data length %d, exp >= %Zu\n",
+			   __func__, datalen, sizeof(struct lsi_umts_single));
 		return -1;
 	}
 
 	/* Validate the protocol  - only support UMTS for now */
-	if (lsi->protocol != SIERRA_NET_PROTOCOL_UMTS) {
+	if (lsi->protocol == SIERRA_NET_PROTOCOL_UMTS) {
+		struct lsi_umts_single *single = (struct lsi_umts_single *)lsi;
+
+		/* Validate the link type */
+		if (single->link_type != SIERRA_NET_AS_LINK_TYPE_IPV4 &&
+		    single->link_type != SIERRA_NET_AS_LINK_TYPE_IPV6) {
+			netdev_err(dev->net, "Link type unsupported: 0x%02x\n",
+				   single->link_type);
+			return -1;
+		}
+		expected_length = SIERRA_NET_LSI_UMTS_STATUS_LEN;
+	} else if (lsi->protocol == SIERRA_NET_PROTOCOL_UMTS_DS) {
+		expected_length = SIERRA_NET_LSI_UMTS_DS_STATUS_LEN;
+	} else {
 		netdev_err(dev->net, "Protocol unsupported, 0x%02x\n",
-			lsi->protocol);
+			   lsi->protocol);
 		return -1;
 	}
 
-	/* Validate the link type */
-	if (lsi->link_type != SIERRA_NET_AS_LINK_TYPE_IPv4) {
-		netdev_err(dev->net, "Link type unsupported: 0x%02x\n",
-			lsi->link_type);
+	if (be16_to_cpu(lsi->length) != expected_length) {
+		netdev_err(dev->net, "%s: LSI_UMTS_STATUS_LEN %d, exp %u\n",
+			   __func__, be16_to_cpu(lsi->length), expected_length);
 		return -1;
 	}
 
 	/* Validate the coverage */
-	if (lsi->coverage == SIERRA_NET_COVERAGE_NONE
-	   || lsi->coverage == SIERRA_NET_COVERAGE_NOPACKET) {
+	if (lsi->coverage == SIERRA_NET_COVERAGE_NONE ||
+	    lsi->coverage == SIERRA_NET_COVERAGE_NOPACKET) {
 		netdev_err(dev->net, "No coverage, 0x%02x\n", lsi->coverage);
 		return 0;
 	}
-- 
2.11.0
