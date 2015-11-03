From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 net-next 4/5] ptp: Change ptp_class to a proper bitmask
Date: Tue, 3 Nov 2015 09:34:07 +0100
Message-ID: <1446539648-8355-5-git-send-email-stefan.sorensen@spectralink.com>
References: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <richardcochran@gmail.com>,
	=?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0133.outbound.protection.outlook.com ([157.56.110.133]:46816
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752326AbbKCIik (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Nov 2015 03:38:40 -0500
In-Reply-To: <1446539648-8355-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Change the definition of PTP_CLASS_L2 to not have any bits overlapping =
with
the other defined protocol values, allowing the PTP_CLASS_* definitions=
 to
be for simple filtering on packet type.

Signed-off-by: Stefan S=C3=B8rensen <stefan.sorensen@spectralink.com>
---
 include/linux/ptp_classify.h |  7 ++++---
 net/core/ptp_classifier.c    | 16 ++++++++--------
 2 files changed, 12 insertions(+), 11 deletions(-)

diff --git a/include/linux/ptp_classify.h b/include/linux/ptp_classify.=
h
index 159c987..a079656 100644
--- a/include/linux/ptp_classify.h
+++ b/include/linux/ptp_classify.h
@@ -32,9 +32,9 @@
 #define PTP_CLASS_VMASK 0x0f /* max protocol version is 15 */
 #define PTP_CLASS_IPV4  0x10 /* event in an IPV4 UDP packet */
 #define PTP_CLASS_IPV6  0x20 /* event in an IPV6 UDP packet */
-#define PTP_CLASS_L2    0x30 /* event in a L2 packet */
-#define PTP_CLASS_PMASK 0x30 /* mask for the packet type field */
-#define PTP_CLASS_VLAN  0x40 /* event in a VLAN tagged packet */
+#define PTP_CLASS_L2    0x40 /* event in a L2 packet */
+#define PTP_CLASS_PMASK	0x70 /* mask for the packet type field */
+#define PTP_CLASS_VLAN	0x80 /* event in a VLAN tagged packet */
=20
 #define PTP_CLASS_V1_IPV4 (PTP_CLASS_V1 | PTP_CLASS_IPV4)
 #define PTP_CLASS_V1_IPV6 (PTP_CLASS_V1 | PTP_CLASS_IPV6) /* probably =
DNE */
@@ -42,6 +42,7 @@
 #define PTP_CLASS_V2_IPV6 (PTP_CLASS_V2 | PTP_CLASS_IPV6)
 #define PTP_CLASS_V2_L2   (PTP_CLASS_V2 | PTP_CLASS_L2)
 #define PTP_CLASS_V2_VLAN (PTP_CLASS_V2 | PTP_CLASS_VLAN)
+#define PTP_CLASS_L4      (PTP_CLASS_IPV4 | PTP_CLASS_IPV6)
=20
 #define PTP_EV_PORT 319
 #define PTP_GEN_BIT 0x08 /* indicates general message, if set in messa=
ge type */
diff --git a/net/core/ptp_classifier.c b/net/core/ptp_classifier.c
index 4eab4a9..703cf76 100644
--- a/net/core/ptp_classifier.c
+++ b/net/core/ptp_classifier.c
@@ -58,7 +58,7 @@
  *   jneq #0x0, drop_ieee1588      ; for PTP_GEN_BIT and drop these
  *   ldh [18]                      ; reload payload
  *   and #0xf                      ; mask PTP_CLASS_VMASK
- *   or #0x70                      ; PTP_CLASS_VLAN|PTP_CLASS_L2
+ *   or #0xc0                      ; PTP_CLASS_VLAN|PTP_CLASS_L2
  *   ret a                         ; return PTP class
  *
  * ; PTP over UDP over IPv4 over 802.1Q over Ethernet
@@ -73,7 +73,7 @@
  *   jneq #319, drop_8021q_ipv4    ; is port PTP_EV_PORT ?
  *   ldh [x + 26]                  ; load payload
  *   and #0xf                      ; mask PTP_CLASS_VMASK
- *   or #0x50                      ; PTP_CLASS_VLAN|PTP_CLASS_IPV4
+ *   or #0x90                      ; PTP_CLASS_VLAN|PTP_CLASS_IPV4
  *   ret a                         ; return PTP class
  *   drop_8021q_ipv4: ret #0x0     ; PTP_CLASS_NONE
  *
@@ -86,7 +86,7 @@
  *   jneq #319, drop_8021q_ipv6          ; is port PTP_EV_PORT ?
  *   ldh [66]                      ; load payload
  *   and #0xf                      ; mask PTP_CLASS_VMASK
- *   or #0x60                      ; PTP_CLASS_VLAN|PTP_CLASS_IPV6
+ *   or #0xa0                      ; PTP_CLASS_VLAN|PTP_CLASS_IPV6
  *   ret a                         ; return PTP class
  *   drop_8021q_ipv6: ret #0x0     ; PTP_CLASS_NONE
  *
@@ -98,7 +98,7 @@
  *   jneq #0x0, drop_ieee1588      ; for PTP_GEN_BIT and drop these
  *   ldh [14]                      ; reload payload
  *   and #0xf                      ; mask PTP_CLASS_VMASK
- *   or #0x30                      ; PTP_CLASS_L2
+ *   or #0x40                      ; PTP_CLASS_L2
  *   ret a                         ; return PTP class
  *   drop_ieee1588: ret #0x0       ; PTP_CLASS_NONE
  */
@@ -150,7 +150,7 @@ void __init ptp_classifier_init(void)
 		{ 0x15,  0, 35, 0x00000000 },
 		{ 0x28,  0,  0, 0x00000012 },
 		{ 0x54,  0,  0, 0x0000000f },
-		{ 0x44,  0,  0, 0x00000070 },
+		{ 0x44,  0,  0, 0x000000c0 },
 		{ 0x16,  0,  0, 0x00000000 },
 		{ 0x15,  0, 12, 0x00000800 },
 		{ 0x30,  0,  0, 0x0000001b },
@@ -162,7 +162,7 @@ void __init ptp_classifier_init(void)
 		{ 0x15,  0,  4, 0x0000013f },
 		{ 0x48,  0,  0, 0x0000001a },
 		{ 0x54,  0,  0, 0x0000000f },
-		{ 0x44,  0,  0, 0x00000050 },
+		{ 0x44,  0,  0, 0x00000090 },
 		{ 0x16,  0,  0, 0x00000000 },
 		{ 0x06,  0,  0, 0x00000000 },
 		{ 0x15,  0,  8, 0x000086dd },
@@ -172,7 +172,7 @@ void __init ptp_classifier_init(void)
 		{ 0x15,  0,  4, 0x0000013f },
 		{ 0x28,  0,  0, 0x00000042 },
 		{ 0x54,  0,  0, 0x0000000f },
-		{ 0x44,  0,  0, 0x00000060 },
+		{ 0x44,  0,  0, 0x000000a0 },
 		{ 0x16,  0,  0, 0x00000000 },
 		{ 0x06,  0,  0, 0x00000000 },
 		{ 0x15,  0,  7, 0x000088f7 },
@@ -181,7 +181,7 @@ void __init ptp_classifier_init(void)
 		{ 0x15,  0,  4, 0x00000000 },
 		{ 0x28,  0,  0, 0x0000000e },
 		{ 0x54,  0,  0, 0x0000000f },
-		{ 0x44,  0,  0, 0x00000030 },
+		{ 0x44,  0,  0, 0x00000040 },
 		{ 0x16,  0,  0, 0x00000000 },
 		{ 0x06,  0,  0, 0x00000000 },
 	};
--=20
2.5.0
