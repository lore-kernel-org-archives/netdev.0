From: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Subject: [PATCH net-next 1/5] ieee802154: add definitions for link-layer security and header functions
Date: Tue, 13 May 2014 19:24:02 +0200
Message-ID: <1400001846-5349-2-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
References: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Cc: linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net,
	Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:39669 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753123AbaEMRYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2014 13:24:24 -0400
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s4DHOL90024086
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 13 May 2014 19:24:21 +0200
In-Reply-To: <1400001846-5349-1-git-send-email-phoebe.buckheister@itwm.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When dealing with 802.15.4, one often has to know the maximum payload
size for a given packet. This depends on many factors, one of which is
whether or not a security header is present in the frame. These
definitions and functions provide an easy way for any upper layer to
calculate the maximum payload size for a packet. The first obvious user
for this is 6lowpan, which duplicates this calculation and gets it
partially wrong because it ignores security headers.

Signed-off-by: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
---
 include/net/ieee802154.h        |    9 +++++++
 include/net/ieee802154_netdev.h |   29 ++++++++++++++++++++++
 net/ieee802154/header_ops.c     |   52 +++++++++++++++++++++++++++++++++------
 3 files changed, 83 insertions(+), 7 deletions(-)

diff --git a/include/net/ieee802154.h b/include/net/ieee802154.h
index c7ae0ac..0aa7122 100644
--- a/include/net/ieee802154.h
+++ b/include/net/ieee802154.h
@@ -79,6 +79,15 @@
 #define IEEE802154_SCF_KEY_SHORT_INDEX		2
 #define IEEE802154_SCF_KEY_HW_INDEX		3
 
+#define IEEE802154_SCF_SECLEVEL_NONE		0
+#define IEEE802154_SCF_SECLEVEL_MIC32		1
+#define IEEE802154_SCF_SECLEVEL_MIC64		2
+#define IEEE802154_SCF_SECLEVEL_MIC128		3
+#define IEEE802154_SCF_SECLEVEL_ENC		4
+#define IEEE802154_SCF_SECLEVEL_ENC_MIC32	5
+#define IEEE802154_SCF_SECLEVEL_ENC_MIC64	6
+#define IEEE802154_SCF_SECLEVEL_ENC_MIC128	7
+
 /* MAC footer size */
 #define IEEE802154_MFR_SIZE	2 /* 2 octets */
 
diff --git a/include/net/ieee802154_netdev.h b/include/net/ieee802154_netdev.h
index 5a719ca..6e4d3e1 100644
--- a/include/net/ieee802154_netdev.h
+++ b/include/net/ieee802154_netdev.h
@@ -27,6 +27,7 @@
 #ifndef IEEE802154_NETDEVICE_H
 #define IEEE802154_NETDEVICE_H
 
+#include <net/ieee802154.h>
 #include <net/af_ieee802154.h>
 #include <linux/netdevice.h>
 #include <linux/skbuff.h>
@@ -114,6 +115,34 @@ int ieee802154_hdr_pull(struct sk_buff *skb, struct ieee802154_hdr *hdr);
 int ieee802154_hdr_peek_addrs(const struct sk_buff *skb,
 			      struct ieee802154_hdr *hdr);
 
+/* parses the full 802.15.4 header a given skb and stores them into hdr,
+ * performing pan id decompression and length checks to be suitable for use in
+ * header_ops.parse
+ */
+int ieee802154_hdr_peek(const struct sk_buff *skb, struct ieee802154_hdr *hdr);
+
+int ieee802154_max_payload(const struct ieee802154_hdr *hdr);
+
+static inline int
+ieee802154_sechdr_authtag_len(const struct ieee802154_sechdr *sec)
+{
+	switch (sec->level) {
+	case IEEE802154_SCF_SECLEVEL_MIC32:
+	case IEEE802154_SCF_SECLEVEL_ENC_MIC32:
+		return 4;
+	case IEEE802154_SCF_SECLEVEL_MIC64:
+	case IEEE802154_SCF_SECLEVEL_ENC_MIC64:
+		return 8;
+	case IEEE802154_SCF_SECLEVEL_MIC128:
+	case IEEE802154_SCF_SECLEVEL_ENC_MIC128:
+		return 16;
+	case IEEE802154_SCF_SECLEVEL_NONE:
+	case IEEE802154_SCF_SECLEVEL_ENC:
+	default:
+		return 0;
+	}
+}
+
 static inline int ieee802154_hdr_length(struct sk_buff *skb)
 {
 	struct ieee802154_hdr hdr;
diff --git a/net/ieee802154/header_ops.c b/net/ieee802154/header_ops.c
index bed42a4..c09294e 100644
--- a/net/ieee802154/header_ops.c
+++ b/net/ieee802154/header_ops.c
@@ -195,15 +195,16 @@ ieee802154_hdr_get_sechdr(const u8 *buf, struct ieee802154_sechdr *hdr)
 	return pos;
 }
 
+static int ieee802154_sechdr_lengths[4] = {
+	[IEEE802154_SCF_KEY_IMPLICIT] = 5,
+	[IEEE802154_SCF_KEY_INDEX] = 6,
+	[IEEE802154_SCF_KEY_SHORT_INDEX] = 10,
+	[IEEE802154_SCF_KEY_HW_INDEX] = 14,
+};
+
 static int ieee802154_hdr_sechdr_len(u8 sc)
 {
-	switch (IEEE802154_SCF_KEY_ID_MODE(sc)) {
-	case IEEE802154_SCF_KEY_IMPLICIT: return 5;
-	case IEEE802154_SCF_KEY_INDEX: return 6;
-	case IEEE802154_SCF_KEY_SHORT_INDEX: return 10;
-	case IEEE802154_SCF_KEY_HW_INDEX: return 14;
-	default: return -EINVAL;
-	}
+	return ieee802154_sechdr_lengths[IEEE802154_SCF_KEY_ID_MODE(sc)];
 }
 
 static int ieee802154_hdr_minlen(const struct ieee802154_hdr *hdr)
@@ -285,3 +286,40 @@ ieee802154_hdr_peek_addrs(const struct sk_buff *skb, struct ieee802154_hdr *hdr)
 	return pos;
 }
 EXPORT_SYMBOL_GPL(ieee802154_hdr_peek_addrs);
+
+int
+ieee802154_hdr_peek(const struct sk_buff *skb, struct ieee802154_hdr *hdr)
+{
+	const u8 *buf = skb_mac_header(skb);
+	int pos;
+
+	pos = ieee802154_hdr_peek_addrs(skb, hdr);
+	if (pos < 0)
+		return -EINVAL;
+
+	if (hdr->fc.security_enabled) {
+		u8 key_id_mode = IEEE802154_SCF_KEY_ID_MODE(*(buf + pos));
+		int want = pos + ieee802154_sechdr_lengths[key_id_mode];
+
+		if (buf + want > skb_tail_pointer(skb))
+			return -EINVAL;
+
+		pos += ieee802154_hdr_get_sechdr(buf + pos, &hdr->sec);
+	}
+
+	return pos;
+}
+EXPORT_SYMBOL_GPL(ieee802154_hdr_peek);
+
+int ieee802154_max_payload(const struct ieee802154_hdr *hdr)
+{
+	int hlen = ieee802154_hdr_minlen(hdr);
+
+	if (hdr->fc.security_enabled) {
+		hlen += ieee802154_sechdr_lengths[hdr->sec.key_id_mode] - 1;
+		hlen += ieee802154_sechdr_authtag_len(&hdr->sec);
+	}
+
+	return IEEE802154_MTU - hlen - IEEE802154_MFR_SIZE;
+}
+EXPORT_SYMBOL_GPL(ieee802154_max_payload);
-- 
1.7.9.5
