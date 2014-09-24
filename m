From: Ahmed Amamou <ahmed@gandi.net>
Subject: [RFC PATCH 05/24] net: rbridge: Adapt Bridge structure
Date: Wed, 24 Sep 2014 17:52:01 +0200
Message-ID: <1411573940-14079-6-git-send-email-ahmed@gandi.net>
References: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: william@gandi.net, f.cachereul@alphalink.fr,
	Ahmed Amamou <ahmed@gandi.net>,
	Kamel Haddadou <kamel@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:48731 "EHLO mail4.gandi.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752854AbaIXP6J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Sep 2014 11:58:09 -0400
In-Reply-To: <1411573940-14079-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

change bridge structure to add corresponding RBridge reference
change bridge port structure to identify disable /P2P/ ACCESS / TRUNK p=
ort/

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: Kamel Haddadou <kamel@gandi.net>
Signed-off-by: Fran=C3=A7ois Cachereul <f.cachereul@alphalink.fr>
---
 include/linux/etherdevice.h | 34 ++++++++++++++++++++++++++++++++++
 net/bridge/br_private.h     | 25 +++++++++++++++++++++++++
 2 files changed, 59 insertions(+)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 9c5529d..09dc18c 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -54,6 +54,16 @@ struct net_device *alloc_etherdev_mqs(int sizeof_pri=
v, unsigned int txqs,
 /* Reserved Ethernet Addresses per IEEE 802.1Q */
 static const u8 eth_reserved_addr_base[ETH_ALEN] __aligned(2) =3D
 { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
+#ifdef CONFIG_TRILL
+static const u8 eth_reserved_addr_all_rbridge[ETH_ALEN] __aligned(2) =3D=
 {
+0x01, 0x80, 0xc2, 0x00, 0x00, 0x40};
+
+static const u8 eth_reserved_addr_isis_rbridge[ETH_ALEN] __aligned(2) =
=3D {
+0x01, 0x80, 0xc2, 0x00, 0x00, 0x41};
+
+static const u8 eth_reserved_addr_esadi_rbridge[ETH_ALEN] __aligned(2)=
 =3D {
+0x01, 0x80, 0xc2, 0x00, 0x00, 0x42};
+#endif
=20
 /**
  * is_link_local_ether_addr - Determine if given Ethernet address is l=
ink-local
@@ -391,4 +401,28 @@ static inline unsigned long compare_ether_header(c=
onst void *a, const void *b)
 #endif
 }
=20
+#ifdef CONFIG_TRILL
+/**
+ * is_all_rbr_address - check if it is a specific Rbridge brodcast mac=
 address
+ * @addr1: Pointer to a six-byte array containing the Ethernet address
+ *
+ * returns true if it is a RBridge brodcast address 01:80:C2:00:00:40
+ */
+static inline bool is_all_rbr_address(const u8 * addr1)
+{
+	return ether_addr_equal(addr1, eth_reserved_addr_all_rbridge);
+}
+
+static inline bool is_isis_rbr_address(const u8 * addr1)
+{
+	return ether_addr_equal(addr1, eth_reserved_addr_isis_rbridge);
+}
+
+static inline bool is_esadi_rbr_address(const u8 * addr1)
+{
+	return ether_addr_equal(addr1, eth_reserved_addr_esadi_rbridge);
+}
+#endif
+
+
 #endif	/* _LINUX_ETHERDEVICE_H */
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 62a7fa2..430c556 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -19,6 +19,9 @@
 #include <linux/u64_stats_sync.h>
 #include <net/route.h>
 #include <linux/if_vlan.h>
+#ifdef CONFIG_TRILL
+#include "rbridge/rbr_private.h"
+#endif
=20
 #define BR_HASH_BITS 8
 #define BR_HASH_SIZE (1 << BR_HASH_BITS)
@@ -31,6 +34,18 @@
=20
 #define BR_VERSION	"2.3"
=20
+#ifdef CONFIG_TRILL
+  /* TRILL flagged ports are ports where we expect receiving native la=
yer 2 frames
+   */
+#define TRILL_FLAG_DISABLE	0x1
+#define TRILL_FLAG_P2P		0x2
+#define TRILL_FLAG_ACCESS	0x4
+#define TRILL_FLAG_TRUNK	0x8	/* DROP ALL native L2 frame */
+/* Bridge TRILL state */
+#define BR_NO_TRILL			0	/* no trill  */
+#define BR_TRILL			1	/* trill enabled */
+#endif
+
 /* Control of forwarding link local multicast */
 #define BR_GROUPFWD_DEFAULT	0
 /* Don't allow forwarding control protocols like STP and LLDP */
@@ -163,6 +178,11 @@ struct net_bridge_port
 	struct rcu_head			rcu;
=20
 	unsigned long 			flags;
+	/* Trill */
+#ifdef CONFIG_TRILL
+	uint8_t					trill_flag;
+#endif /* CONFIG_TRILL */
+
 #define BR_HAIRPIN_MODE		0x00000001
 #define BR_BPDU_GUARD           0x00000002
 #define BR_ROOT_BLOCK		0x00000004
@@ -252,6 +272,11 @@ struct net_bridge
 		BR_USER_STP,		/* new RSTP in userspace */
 	} stp_enabled;
=20
+#ifdef CONFIG_TRILL
+	bool	 				trill_enabled;
+	struct rbr              *rbr;
+#endif
+
 	unsigned char			topology_change;
 	unsigned char			topology_change_detected;
=20
--=20
1.9.1
