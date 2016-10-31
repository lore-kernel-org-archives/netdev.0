From: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Subject: [PATCH net-next 1/4] net: pim: add common pimhdr struct and helpers
Date: Mon, 31 Oct 2016 13:21:02 +0100
Message-ID: <1477916465-20406-2-git-send-email-nikolay@cumulusnetworks.com>
References: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Cc: roopa@cumulusnetworks.com, dwalton@cumulusnetworks.com,
        stephen@networkplumber.org, davem@davemloft.net,
        Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f46.google.com ([74.125.82.46]:36850 "EHLO
        mail-wm0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941400AbcJaMVS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 08:21:18 -0400
Received: by mail-wm0-f46.google.com with SMTP id p190so143766633wmp.1
        for <netdev@vger.kernel.org>; Mon, 31 Oct 2016 05:21:18 -0700 (PDT)
In-Reply-To: <1477916465-20406-1-git-send-email-nikolay@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the common pimhdr structure and helpers to access it, also cleanup the
format of the header file.

Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
---
 include/linux/pim.h | 44 ++++++++++++++++++++++++++++++++++++--------
 1 file changed, 36 insertions(+), 8 deletions(-)

diff --git a/include/linux/pim.h b/include/linux/pim.h
index e1d756f81348..354235a2691b 100644
--- a/include/linux/pim.h
+++ b/include/linux/pim.h
@@ -1,6 +1,7 @@
 #ifndef __LINUX_PIM_H
 #define __LINUX_PIM_H
 
+#include <linux/skbuff.h>
 #include <asm/byteorder.h>
 
 /* Message types - V1 */
@@ -13,20 +14,47 @@
 
 #define PIM_NULL_REGISTER	cpu_to_be32(0x40000000)
 
-static inline bool ipmr_pimsm_enabled(void)
-{
-	return IS_BUILTIN(CONFIG_IP_PIMSM_V1) || IS_BUILTIN(CONFIG_IP_PIMSM_V2);
-}
+/* RFC7761, sec 4.9:
+ * The PIM header common to all PIM messages is:
+ *   0                   1                   2                   3
+ *   0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *  |PIM Ver| Type  |   Reserved    |           Checksum            |
+ *  +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ */
+struct pimhdr {
+	__u8	type;
+	__u8	reserved;
+	__be16	csum;
+};
 
 /* PIMv2 register message header layout (ietf-draft-idmr-pimvsm-v2-00.ps */
-struct pimreghdr
-{
+struct pimreghdr {
 	__u8	type;
 	__u8	reserved;
 	__be16	csum;
 	__be32	flags;
 };
 
-struct sk_buff;
-extern int pim_rcv_v1(struct sk_buff *);
+int pim_rcv_v1(struct sk_buff *skb);
+
+static inline bool ipmr_pimsm_enabled(void)
+{
+	return IS_BUILTIN(CONFIG_IP_PIMSM_V1) || IS_BUILTIN(CONFIG_IP_PIMSM_V2);
+}
+
+static inline struct pimhdr *pim_hdr(const struct sk_buff *skb)
+{
+	return (struct pimhdr *)skb_transport_header(skb);
+}
+
+static inline u8 pim_hdr_version(const struct pimhdr *pimhdr)
+{
+	return pimhdr->type >> 4;
+}
+
+static inline u8 pim_hdr_type(const struct pimhdr *pimhdr)
+{
+	return pimhdr->type & 0xf;
+}
 #endif
-- 
2.1.4
