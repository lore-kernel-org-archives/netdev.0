From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 2/4] vxlan: factor out VXLAN-GPE next protocol
Date: Mon, 28 Aug 2017 21:43:22 +0200
Message-ID: <c4c6c88e5aadcddf08edc6851e7c194ced74fb4a.1503948295.git.jbenc@redhat.com>
References: <cover.1503948295.git.jbenc@redhat.com>
Cc: Yi Yang <yi.y.yang@intel.com>, Eric Garver <e@erig.me>,
        Jan Scheurich <jan.scheurich@ericsson.com>,
        Ben Pfaff <blp@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751192AbdH1Tnm (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 15:43:42 -0400
In-Reply-To: <cover.1503948295.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The values are shared between VXLAN-GPE and NSH. Originally probably by
coincidence but I notified both working groups about this last year and they
seem to keep the values in sync since then.

Hopefully they'll get a single IANA registry for the values, too. (I asked
them for that.)

Factor out the code to be shared by the NSH implementation.

NSH and MPLS values are added in this patch, too. For MPLS, the drafts
incorrectly assign only a single value, while we have two MPLS ethertypes.
I raised the problem with both groups. For now, I assume the value is for
unicast.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 drivers/net/vxlan.c     | 32 +++++++-------------------------
 include/net/tun_proto.h | 49 +++++++++++++++++++++++++++++++++++++++++++++++++
 include/net/vxlan.h     |  6 ------
 3 files changed, 56 insertions(+), 31 deletions(-)
 create mode 100644 include/net/tun_proto.h

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index ae3a1da703c2..d7c49cf1d5e9 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -26,6 +26,7 @@
 #include <net/inet_ecn.h>
 #include <net/net_namespace.h>
 #include <net/netns/generic.h>
+#include <net/tun_proto.h>
 #include <net/vxlan.h>
 
 #if IS_ENABLED(CONFIG_IPV6)
@@ -1261,19 +1262,9 @@ static bool vxlan_parse_gpe_hdr(struct vxlanhdr *unparsed,
 	if (gpe->oam_flag)
 		return false;
 
-	switch (gpe->next_protocol) {
-	case VXLAN_GPE_NP_IPV4:
-		*protocol = htons(ETH_P_IP);
-		break;
-	case VXLAN_GPE_NP_IPV6:
-		*protocol = htons(ETH_P_IPV6);
-		break;
-	case VXLAN_GPE_NP_ETHERNET:
-		*protocol = htons(ETH_P_TEB);
-		break;
-	default:
+	*protocol = tun_p_to_eth_p(gpe->next_protocol);
+	if (!*protocol)
 		return false;
-	}
 
 	unparsed->vx_flags &= ~VXLAN_GPE_USED_BITS;
 	return true;
@@ -1799,19 +1790,10 @@ static int vxlan_build_gpe_hdr(struct vxlanhdr *vxh, u32 vxflags,
 	struct vxlanhdr_gpe *gpe = (struct vxlanhdr_gpe *)vxh;
 
 	gpe->np_applied = 1;
-
-	switch (protocol) {
-	case htons(ETH_P_IP):
-		gpe->next_protocol = VXLAN_GPE_NP_IPV4;
-		return 0;
-	case htons(ETH_P_IPV6):
-		gpe->next_protocol = VXLAN_GPE_NP_IPV6;
-		return 0;
-	case htons(ETH_P_TEB):
-		gpe->next_protocol = VXLAN_GPE_NP_ETHERNET;
-		return 0;
-	}
-	return -EPFNOSUPPORT;
+	gpe->next_protocol = tun_p_from_eth_p(protocol);
+	if (!gpe->next_protocol)
+		return -EPFNOSUPPORT;
+	return 0;
 }
 
 static int vxlan_build_skb(struct sk_buff *skb, struct dst_entry *dst,
diff --git a/include/net/tun_proto.h b/include/net/tun_proto.h
new file mode 100644
index 000000000000..2ea3deba4c99
--- /dev/null
+++ b/include/net/tun_proto.h
@@ -0,0 +1,49 @@
+#ifndef __NET_TUN_PROTO_H
+#define __NET_TUN_PROTO_H
+
+#include <linux/kernel.h>
+
+/* One byte protocol values as defined by VXLAN-GPE and NSH. These will
+ * hopefully get a shared IANA registry.
+ */
+#define TUN_P_IPV4      0x01
+#define TUN_P_IPV6      0x02
+#define TUN_P_ETHERNET  0x03
+#define TUN_P_NSH       0x04
+#define TUN_P_MPLS_UC   0x05
+
+static inline __be16 tun_p_to_eth_p(u8 proto)
+{
+	switch (proto) {
+	case TUN_P_IPV4:
+		return htons(ETH_P_IP);
+	case TUN_P_IPV6:
+		return htons(ETH_P_IPV6);
+	case TUN_P_ETHERNET:
+		return htons(ETH_P_TEB);
+	case TUN_P_NSH:
+		return htons(ETH_P_NSH);
+	case TUN_P_MPLS_UC:
+		return htons(ETH_P_MPLS_UC);
+	}
+	return 0;
+}
+
+static inline u8 tun_p_from_eth_p(__be16 proto)
+{
+	switch (proto) {
+	case htons(ETH_P_IP):
+		return TUN_P_IPV4;
+	case htons(ETH_P_IPV6):
+		return TUN_P_IPV6;
+	case htons(ETH_P_TEB):
+		return TUN_P_ETHERNET;
+	case htons(ETH_P_NSH):
+		return TUN_P_NSH;
+	case htons(ETH_P_MPLS_UC):
+		return TUN_P_MPLS_UC;
+	}
+	return 0;
+}
+
+#endif
diff --git a/include/net/vxlan.h b/include/net/vxlan.h
index 3f430e38ab82..4e3876dde295 100644
--- a/include/net/vxlan.h
+++ b/include/net/vxlan.h
@@ -168,12 +168,6 @@ struct vxlanhdr_gpe {
 #define VXLAN_GPE_USED_BITS (VXLAN_HF_VER | VXLAN_HF_NP | VXLAN_HF_OAM | \
 			     cpu_to_be32(0xff))
 
-/* VXLAN-GPE header Next Protocol. */
-#define VXLAN_GPE_NP_IPV4      0x01
-#define VXLAN_GPE_NP_IPV6      0x02
-#define VXLAN_GPE_NP_ETHERNET  0x03
-#define VXLAN_GPE_NP_NSH       0x04
-
 struct vxlan_metadata {
 	u32		gbp;
 };
-- 
1.8.3.1
