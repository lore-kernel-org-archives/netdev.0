From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH net-next 2/3] ptp: Classify ptp over ip over vlan packets
Date: Fri, 27 Jun 2014 11:59:10 +0200
Message-ID: <1403863151-13337-3-git-send-email-stefan.sorensen@spectralink.com>
References: <1403863151-13337-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: davem@davemloft.net, richardcochran@gmail.com, kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 213083164162.static.sonofon.dk ([213.83.164.162]:54160 "EHLO
	HORWDSPRD01.spectralink.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750756AbaF0KE5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jun 2014 06:04:57 -0400
In-Reply-To: <1403863151-13337-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This extends the ptp bpf to also match ptp over ip over vlan packets. T=
he ptp
classes are changed to orthogonal bitfields representing version, trans=
port
and vlan values to simplify matching.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 drivers/net/ethernet/ti/cpts.c | 24 ++++++++--------
 drivers/net/phy/dp83640.c      | 46 ++++++++++++++----------------
 include/linux/ptp_classify.h   |  5 ++--
 net/core/ptp_classifier.c      | 64 ++++++++++++++++++++++++++++++++++=
++++----
 4 files changed, 92 insertions(+), 47 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/c=
pts.c
index 6b56f85..ab92f67 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -256,23 +256,21 @@ static int cpts_match(struct sk_buff *skb, unsign=
ed int ptp_class,
 		      u16 ts_seqid, u8 ts_msgtype)
 {
 	u16 *seqid;
-	unsigned int offset;
+	unsigned int offset =3D 0;
 	u8 *msgtype, *data =3D skb->data;
=20
-	switch (ptp_class) {
-	case PTP_CLASS_V1_IPV4:
-	case PTP_CLASS_V2_IPV4:
-		offset =3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
-		break;
-	case PTP_CLASS_V1_IPV6:
-	case PTP_CLASS_V2_IPV6:
-		offset =3D OFF_PTP6;
+	if (ptp_class & PTP_CLASS_VLAN)
+		offset +=3D VLAN_HLEN;
+
+	switch (ptp_class & PTP_CLASS_PMASK) {
+	case PTP_CLASS_IPV4:
+		offset +=3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
 		break;
-	case PTP_CLASS_V2_L2:
-		offset =3D ETH_HLEN;
+	case PTP_CLASS_IPV6:
+		offset +=3D ETH_HLEN + IP6_HLEN + UDP_HLEN;
 		break;
-	case PTP_CLASS_V2_VLAN:
-		offset =3D ETH_HLEN + VLAN_HLEN;
+	case PTP_CLASS_L2:
+		offset +=3D ETH_HLEN;
 		break;
 	default:
 		return 0;
diff --git a/drivers/net/phy/dp83640.c b/drivers/net/phy/dp83640.c
index 6a999e6..5dff8f2 100644
--- a/drivers/net/phy/dp83640.c
+++ b/drivers/net/phy/dp83640.c
@@ -837,20 +837,18 @@ static int is_sync(struct sk_buff *skb, int type)
 	u8 *data =3D skb->data, *msgtype;
 	unsigned int offset =3D 0;
=20
-	switch (type) {
-	case PTP_CLASS_V1_IPV4:
-	case PTP_CLASS_V2_IPV4:
-		offset =3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
-		break;
-	case PTP_CLASS_V1_IPV6:
-	case PTP_CLASS_V2_IPV6:
-		offset =3D OFF_PTP6;
+	if (type & PTP_CLASS_VLAN)
+		offset +=3D VLAN_HLEN;
+
+	switch (type & PTP_CLASS_PMASK) {
+	case PTP_CLASS_IPV4:
+		offset +=3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
 		break;
-	case PTP_CLASS_V2_L2:
-		offset =3D ETH_HLEN;
+	case PTP_CLASS_IPV6:
+		offset +=3D ETH_HLEN + IP6_HLEN + UDP_HLEN;
 		break;
-	case PTP_CLASS_V2_VLAN:
-		offset =3D ETH_HLEN + VLAN_HLEN;
+	case PTP_CLASS_L2:
+		offset +=3D ETH_HLEN;
 		break;
 	default:
 		return 0;
@@ -870,25 +868,23 @@ static int is_sync(struct sk_buff *skb, int type)
 static int match(struct sk_buff *skb, unsigned int type, struct rxts *=
rxts)
 {
 	u16 *seqid;
-	unsigned int offset;
+	unsigned int offset =3D 0;
 	u8 *msgtype, *data =3D skb_mac_header(skb);
=20
 	/* check sequenceID, messageType, 12 bit hash of offset 20-29 */
=20
-	switch (type) {
-	case PTP_CLASS_V1_IPV4:
-	case PTP_CLASS_V2_IPV4:
-		offset =3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
-		break;
-	case PTP_CLASS_V1_IPV6:
-	case PTP_CLASS_V2_IPV6:
-		offset =3D OFF_PTP6;
+	if (type & PTP_CLASS_VLAN)
+		offset +=3D VLAN_HLEN;
+
+	switch (type & PTP_CLASS_PMASK) {
+	case PTP_CLASS_IPV4:
+		offset +=3D ETH_HLEN + IPV4_HLEN(data) + UDP_HLEN;
 		break;
-	case PTP_CLASS_V2_L2:
-		offset =3D ETH_HLEN;
+	case PTP_CLASS_IPV6:
+		offset +=3D ETH_HLEN + IP6_HLEN + UDP_HLEN;
 		break;
-	case PTP_CLASS_V2_VLAN:
-		offset =3D ETH_HLEN + VLAN_HLEN;
+	case PTP_CLASS_L2:
+		offset +=3D ETH_HLEN;
 		break;
 	default:
 		return 0;
diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.=
h
index 7dfed71..159c987 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -33,8 +33,8 @@
 #define PTP_CLASS_IPV4  0x10 /* event in an IPV4 UDP packet */
 #define PTP_CLASS_IPV6  0x20 /* event in an IPV6 UDP packet */
 #define PTP_CLASS_L2    0x30 /* event in a L2 packet */
-#define PTP_CLASS_VLAN  0x40 /* event in a VLAN tagged L2 packet */
-#define PTP_CLASS_PMASK 0xf0 /* mask for the packet type field */
+#define PTP_CLASS_PMASK 0x30 /* mask for the packet type field */
+#define PTP_CLASS_VLAN  0x40 /* event in a VLAN tagged packet */
=20
 #define PTP_CLASS_V1_IPV4 (PTP_CLASS_V1 | PTP_CLASS_IPV4)
 #define PTP_CLASS_V1_IPV6 (PTP_CLASS_V1 | PTP_CLASS_IPV6) /* probably =
DNE */
@@ -54,7 +54,6 @@
 #define IP6_HLEN	40
 #define UDP_HLEN	8
 #define OFF_IHL		14
-#define OFF_PTP6	(ETH_HLEN + IP6_HLEN + UDP_HLEN)
 #define IPV4_HLEN(data) (((struct iphdr *)(data + OFF_IHL))->ihl << 2)
=20
 #if defined(CONFIG_NET_PTP_CLASSIFY)
diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
index d3027a7..12ab7b4 100644
--- a/net/core/ptp_classifier.c
+++ b/net/core/ptp_classifier.c
@@ -52,14 +52,43 @@
  * test_8021q:
  *   jneq #0x8100, test_ieee1588   ; ETH_P_8021Q ?
  *   ldh [16]                      ; load inner type
- *   jneq #0x88f7, drop_ieee1588   ; ETH_P_1588 ?
+ *   jneq #0x88f7, test_8021q_ipv4 ; ETH_P_1588 ?
  *   ldb [18]                      ; load payload
  *   and #0x8                      ; as we don't have ports here, test
  *   jneq #0x0, drop_ieee1588      ; for PTP_GEN_BIT and drop these
  *   ldh [18]                      ; reload payload
  *   and #0xf                      ; mask PTP_CLASS_VMASK
- *   or #0x40                      ; PTP_CLASS_V2_VLAN
+ *   or #0x70                      ; PTP_CLASS_VLAN|PTP_CLASS_L2
+ *   ret a                         ; return PTP class
+ *
+ * ; PTP over UDP over IPv4 over 802.1Q over Ethernet
+ * test_8021q_ipv4:
+ *   jneq #0x800, test_8021q_ipv6  ; ETH_P_IP ?
+ *   ldb [27]                      ; load proto
+ *   jneq #17, drop_8021q_ipv4     ; IPPROTO_UDP ?
+ *   ldh [24]                      ; load frag offset field
+ *   jset #0x1fff, drop_8021q_ipv4; don't allow fragments
+ *   ldxb 4*([18]&0xf)             ; load IP header len
+ *   ldh [x + 20]                  ; load UDP dst port
+ *   jneq #319, drop_8021q_ipv4    ; is port PTP_EV_PORT ?
+ *   ldh [x + 26]                  ; load payload
+ *   and #0xf                      ; mask PTP_CLASS_VMASK
+ *   or #0x50                      ; PTP_CLASS_VLAN|PTP_CLASS_IPV4
+ *   ret a                         ; return PTP class
+ *   drop_8021q_ipv4: ret #0x0     ; PTP_CLASS_NONE
+ *
+ * ; PTP over UDP over IPv6 over 802.1Q over Ethernet
+ * test_8021q_ipv6:
+ *   jneq #0x86dd, drop_8021q_ipv6 ; ETH_P_IPV6 ?
+ *   ldb [24]                      ; load proto
+ *   jneq #17, drop_8021q_ipv6           ; IPPROTO_UDP ?
+ *   ldh [60]                      ; load UDP dst port
+ *   jneq #319, drop_8021q_ipv6          ; is port PTP_EV_PORT ?
+ *   ldh [66]                      ; load payload
+ *   and #0xf                      ; mask PTP_CLASS_VMASK
+ *   or #0x60                      ; PTP_CLASS_VLAN|PTP_CLASS_IPV6
  *   ret a                         ; return PTP class
+ *   drop_8021q_ipv6: ret #0x0     ; PTP_CLASS_NONE
  *
  * ; PTP over Ethernet
  * test_ieee1588:
@@ -113,16 +142,39 @@ void __init ptp_classifier_init(void)
 		{ 0x44,  0,  0, 0x00000020 },
 		{ 0x16,  0,  0, 0x00000000 },
 		{ 0x06,  0,  0, 0x00000000 },
-		{ 0x15,  0,  9, 0x00008100 },
+		{ 0x15,  0, 32, 0x00008100 },
 		{ 0x28,  0,  0, 0x00000010 },
-		{ 0x15,  0, 15, 0x000088f7 },
+		{ 0x15,  0,  7, 0x000088f7 },
 		{ 0x30,  0,  0, 0x00000012 },
 		{ 0x54,  0,  0, 0x00000008 },
-		{ 0x15,  0, 12, 0x00000000 },
+		{ 0x15,  0, 35, 0x00000000 },
 		{ 0x28,  0,  0, 0x00000012 },
 		{ 0x54,  0,  0, 0x0000000f },
-		{ 0x44,  0,  0, 0x00000040 },
+		{ 0x44,  0,  0, 0x00000070 },
+		{ 0x16,  0,  0, 0x00000000 },
+		{ 0x15,  0, 12, 0x00000800 },
+		{ 0x30,  0,  0, 0x0000001b },
+		{ 0x15,  0,  9, 0x00000011 },
+		{ 0x28,  0,  0, 0x00000018 },
+		{ 0x45,  7,  0, 0x00001fff },
+		{ 0xb1,  0,  0, 0x00000012 },
+		{ 0x48,  0,  0, 0x00000014 },
+		{ 0x15,  0,  4, 0x0000013f },
+		{ 0x48,  0,  0, 0x0000001a },
+		{ 0x54,  0,  0, 0x0000000f },
+		{ 0x44,  0,  0, 0x00000050 },
+		{ 0x16,  0,  0, 0x00000000 },
+		{ 0x06,  0,  0, 0x00000000 },
+		{ 0x15,  0,  8, 0x000086dd },
+		{ 0x30,  0,  0, 0x00000018 },
+		{ 0x15,  0,  6, 0x00000011 },
+		{ 0x28,  0,  0, 0x0000003c },
+		{ 0x15,  0,  4, 0x0000013f },
+		{ 0x28,  0,  0, 0x00000042 },
+		{ 0x54,  0,  0, 0x0000000f },
+		{ 0x44,  0,  0, 0x00000060 },
 		{ 0x16,  0,  0, 0x00000000 },
+		{ 0x06,  0,  0, 0x00000000 },
 		{ 0x15,  0,  7, 0x000088f7 },
 		{ 0x30,  0,  0, 0x0000000e },
 		{ 0x54,  0,  0, 0x00000008 },
--=20
1.9.3
