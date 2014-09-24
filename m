From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 01/24] net: rbridge: add trill frame description
Date: Wed, 24 Sep 2014 17:51:57 +0200
Message-ID: <1411573940-14079-2-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Emmanuel Hocdet <manu@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:38926 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753013AbaIXP6L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:11 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

add basic trill header description and basic header getter and setter fuctions

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Emmanuel Hocdet <manu@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
---
 include/linux/if_trill.h      | 89 +++++++++++++++++++++++++++++++++++++++++++
 include/uapi/linux/if_ether.h |  1 +
 2 files changed, 90 insertions(+)
 create mode 100644 include/linux/if_trill.h

diff --git a/include/linux/if_trill.h b/include/linux/if_trill.h
new file mode 100644
index 0000000..ad9c631
--- /dev/null
+++ b/include/linux/if_trill.h
@@ -0,0 +1,89 @@
+#ifndef _LINUX_IF_TRILL_H_
+#define _LINUX_IF_TRILL_H_
+
+#include <linux/types.h>
+
+/*
+ * trill_hdr structure
+ *                                +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *                                | V | R |M|op-Length| Hop Count |
+ *+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *|  Egress RBridge Nickname      |    Ingress RBridge Nickname   |
+ *+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
+ *
+ */
+
+struct trill_hdr {
+	__be16 th_flags;
+	__be16 th_egressnick;
+	__be16 th_ingressnick;
+} __attribute__ ((packed));
+
+static inline u16 trill_get_version(u16 trill_flags)
+{
+	return ((trill_flags >> 14) & 0x0003);
+}
+
+static inline u16 trill_set_version(u16 trill_flags, u16 v)
+{
+	trill_flags |= ((v & 0x0003) << 14);
+	return trill_flags;
+}
+
+static inline u16 trill_get_reserved(u16 trill_flags)
+{
+	return ((trill_flags >> 12) & 0x0003);
+}
+
+static inline u16 trill_set_reserved(u16 trill_flags, u16 v)
+{
+	trill_flags |= ((v & 0x0003) << 12);
+	return trill_flags;
+}
+
+static inline u16 trill_get_multidest(u16 trill_flags)
+{
+	return ((trill_flags >> 11) & 0x0001);
+}
+
+static inline u16 trill_set_multidest(u16 trill_flags, u16 flag)
+{
+	trill_flags |= ((flag & 0x0001) << 11);
+	return trill_flags;
+}
+
+/* len is in 4 bytes units << 2*/
+static inline size_t trill_get_optslen(u16 trill_flags)
+{
+	return (((trill_flags >> 6) & 0x001F) << 2);
+}
+
+static inline u16 trill_set_optslen(u16 trill_flags, u16 len)
+{
+	trill_flags |= (((len >> 2) & 0x001F) << 6);
+	return trill_flags;
+}
+
+static inline u16 trill_get_hopcount(u16 trill_flags)
+{
+	return (trill_flags & 0x003F);
+}
+
+static inline u16 trill_set_hopcount(u16 trill_flags, u16 count)
+{
+	trill_flags |= (count & 0x003F);
+	return trill_flags;
+}
+
+static inline void trillhdr_dec_hopcount(struct trill_hdr *trh)
+{
+	u8 *flags = (u8 *) & (trh->th_flags);
+	if (flags[1] & 0x3F)
+		flags[1] -= 1;
+}
+
+static inline size_t trill_header_len(struct trill_hdr *trh)
+{
+	return (sizeof(*trh) + trill_get_optslen(ntohs(trh->th_flags)));
+}
+#endif				/* !(_LINUX_IF_TRILL_H_) */
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ether.h
index 0f8210b..a9eb2f2 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -48,6 +48,7 @@
 #define	ETH_P_BPQ	0x08FF		/* G8BPQ AX.25 Ethernet Packet	[ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_IEEEPUP	0x0a00		/* Xerox IEEE802.3 PUP packet */
 #define ETH_P_IEEEPUPAT	0x0a01		/* Xerox IEEE802.3 PUP Addr Trans packet */
+#define ETH_P_TRILL	0x22F3		/* TRILL frames RFC 6325 */
 #define ETH_P_BATMAN	0x4305		/* B.A.T.M.A.N.-Advanced packet [ NOT AN OFFICIALLY REGISTERED ID ] */
 #define ETH_P_DEC       0x6000          /* DEC Assigned proto           */
 #define ETH_P_DNA_DL    0x6001          /* DEC DNA Dump/Load            */
-- 
1.9.1
