From: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Subject: [net-next v3 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 24 Feb 2014 13:28:40 +0100
Message-ID: <1393244920-15903-4-git-send-email-sw@simonwunderlich.de>
References: <1393244920-15903-1-git-send-email-sw@simonwunderlich.de>
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org,
	Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1393244920-15903-1-git-send-email-sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

MPLS labels may contain traffic control information, which should be
evaluated and used by the wireless subsystem if present.

Also check for IEEE 802.21 which is always network control traffic.

Signed-off-by: Simon Wunderlich <sw-2YrNx6rUIHYiY0qSoAWiAoQuADTiUCJX@public.gmane.org>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer-8LS2qeF34IpklNlQbfROjRvVK+yQ3ZXh@public.gmane.org>
---
Changes to second version:

 * rely on skb->protocol instead of checking ethertype

Changes to first version:

 * include linux/mpls.h, not the UAPI one
 * change __constant_htons to htons
---
 net/wireless/util.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index d39c371..6799d5a 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -11,6 +11,7 @@
 #include <net/ip.h>
 #include <net/dsfield.h>
 #include <linux/if_vlan.h>
+#include <linux/mpls.h>
 #include "core.h"
 #include "rdev-ops.h"
 
@@ -717,6 +718,21 @@ unsigned int cfg80211_classify8021d(struct sk_buff *skb,
 	case htons(ETH_P_IPV6):
 		dscp = ipv6_get_dsfield(ipv6_hdr(skb)) & 0xfc;
 		break;
+	case htons(ETH_P_MPLS_UC):
+	case htons(ETH_P_MPLS_MC): {
+		struct mpls_label_stack mpls_tmp, *mpls;
+
+		mpls = skb_header_pointer(skb, sizeof(struct ethhdr),
+					  sizeof(*mpls), &mpls_tmp);
+		if (!mpls)
+			return 0;
+
+		return (ntohl(mpls->entry) & MPLS_LS_TC_MASK)
+			>> MPLS_LS_TC_SHIFT;
+		}
+	case htons(ETH_P_80221):
+		/* 802.21 is always network control traffic */
+		return 7;
 	default:
 		return 0;
 	}
-- 
1.7.10.4

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
