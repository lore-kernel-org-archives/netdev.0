From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [net-next v4 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon,  3 Mar 2014 17:23:12 +0100
Message-ID: <1393863792-18172-4-git-send-email-sw@simonwunderlich.de>
References: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de,
	Simon Wunderlich <sw@simonwunderlich.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55042 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754588AbaCCQXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 11:23:19 -0500
In-Reply-To: <1393863792-18172-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS labels may contain traffic control information, which should be
evaluated and used by the wireless subsystem if present.

Also check for IEEE 802.21 which is always network control traffic.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Acked-by: Johannes Berg <johannes@sipsolutions.net>
---
Changes to third version:

 * add Johannes' Ack
 * fix over-indented closing brace

Changes to second version:

 * rely on skb->protocol instead of checking ethertype

Changes to first version:

 * include linux/mpls.h, not the UAPI one
 * change __constant_htons to htons
---
 net/wireless/util.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index 780b454..ad03af3 100644
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
+		struct mpls_label mpls_tmp, *mpls;
+
+		mpls = skb_header_pointer(skb, sizeof(struct ethhdr),
+					  sizeof(*mpls), &mpls_tmp);
+		if (!mpls)
+			return 0;
+
+		return (ntohl(mpls->entry) & MPLS_LS_TC_MASK)
+			>> MPLS_LS_TC_SHIFT;
+	}
+	case htons(ETH_P_80221):
+		/* 802.21 is always network control traffic */
+		return 7;
 	default:
 		return 0;
 	}
-- 
1.7.10.4
