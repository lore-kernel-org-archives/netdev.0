From: Simon Wunderlich <sw@simonwunderlich.de>
Subject: [net-next v2 3/3] cfg80211: add MPLS and 802.21 classification
Date: Mon, 17 Feb 2014 17:56:13 +0100
Message-ID: <1392656174-14791-4-git-send-email-sw@simonwunderlich.de>
References: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
Cc: davem@davemloft.net, linux-wireless@vger.kernel.org,
	mathias.kretschmer@fokus.fraunhofer.de,
	Simon Wunderlich <sw@simonwunderlich.de>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from packetmixer.de ([79.140.42.25]:55601 "EHLO
	mail.mail.packetmixer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753120AbaBQQ4U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 11:56:20 -0500
In-Reply-To: <1392656174-14791-1-git-send-email-sw@simonwunderlich.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

MPLS labels may contain traffic control information, which should be
evaluated and used by the wireless subsystem if present.

Also check for IEEE 802.21 which is always network control traffic.

Signed-off-by: Simon Wunderlich <sw@simonwunderlich.de>
Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
---
Changes to first version:

 * include linux/mpls.h, not the UAPI one
 * change __constant_htons to htons
---
 net/wireless/util.c |   24 ++++++++++++++++++++++++
 1 file changed, 24 insertions(+)

diff --git a/net/wireless/util.c b/net/wireless/util.c
index d39c371..54956eb 100644
--- a/net/wireless/util.c
+++ b/net/wireless/util.c
@@ -11,6 +11,7 @@
 #include <net/ip.h>
 #include <net/dsfield.h>
 #include <linux/if_vlan.h>
+#include <linux/mpls.h>
 #include "core.h"
 #include "rdev-ops.h"
 
@@ -710,6 +711,29 @@ unsigned int cfg80211_classify8021d(struct sk_buff *skb,
 			return vlan_priority;
 	}
 
+	if (skb_headlen(skb) >= sizeof(struct ethhdr)) {
+		struct ethhdr *eh = (struct ethhdr *)skb->data;
+		struct mpls_label_stack mpls_tmp, *mpls;
+
+		switch (eh->h_proto) {
+		case htons(ETH_P_MPLS_UC):
+		case htons(ETH_P_MPLS_MC):
+			/* MPLS */
+			mpls = skb_header_pointer(skb, sizeof(*eh),
+						  sizeof(*mpls), &mpls_tmp);
+			if (!mpls)
+				break;
+
+			return (ntohl(mpls->entry) & MPLS_LS_TC_MASK)
+				>> MPLS_LS_TC_SHIFT;
+		case htons(ETH_P_80221):
+			/* 802.21 is always network control traffic */
+			return 7;
+		default:
+			break;
+		}
+	}
+
 	switch (skb->protocol) {
 	case htons(ETH_P_IP):
 		dscp = ipv4_get_dsfield(ip_hdr(skb)) & 0xfc;
-- 
1.7.10.4
