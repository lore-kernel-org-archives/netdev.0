From: Tom Herbert <therbert@google.com>
Subject: [PATCH net-next 6/6] flow_dissector: Include MPLS entropy label in hash computation
Date: Fri, 27 Feb 2015 19:11:49 -0800
Message-ID: <1425093109-1077-7-git-send-email-therbert@google.com>
References: <1425093109-1077-1-git-send-email-therbert@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:41977 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752345AbbB1DNE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 22:13:04 -0500
Received: by iecrd18 with SMTP id rd18so35719645iec.8
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 19:13:03 -0800 (PST)
In-Reply-To: <1425093109-1077-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch add MPLS cases in flow dissection. If the top labels are
entropy labels (entropy label next indicator label followed by an
entropy label) the entropy value is extracted and used as a
substitute for ports in flow keys.

Entropy labels for MPLS are described in RFC 6790.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 include/uapi/linux/in.h   |  2 ++
 include/uapi/linux/mpls.h |  3 +++
 net/core/flow_dissector.c | 24 ++++++++++++++++++++++++
 3 files changed, 29 insertions(+)

diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 589ced0..5f9bc1f 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -69,6 +69,8 @@ enum {
 #define IPPROTO_SCTP		IPPROTO_SCTP
   IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
 #define IPPROTO_UDPLITE		IPPROTO_UDPLITE
+  IPPROTO_MPLS = 137,		/* MPLS (RFC 4023)			*/
+#define IPPROTO_MPLS		IPPROTO_MPLS
   IPPROTO_RAW = 255,		/* Raw IP packets			*/
 #define IPPROTO_RAW		IPPROTO_RAW
   IPPROTO_MAX
diff --git a/include/uapi/linux/mpls.h b/include/uapi/linux/mpls.h
index bc9abfe..3be9eb7 100644
--- a/include/uapi/linux/mpls.h
+++ b/include/uapi/linux/mpls.h
@@ -31,4 +31,7 @@ struct mpls_label {
 #define MPLS_LS_TTL_MASK        0x000000FF
 #define MPLS_LS_TTL_SHIFT       0
 
+/* Reserved labels */
+#define MPLS_LS_ENTROPY_IS_NEXT	7
+
 #endif /* _UAPI_MPLS_H */
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index e04946f..c4c35cd 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -7,6 +7,7 @@
 #include <net/ipv6.h>
 #include <linux/igmp.h>
 #include <linux/icmp.h>
+#include <linux/mpls.h>
 #include <linux/sctp.h>
 #include <linux/dccp.h>
 #include <linux/if_tunnel.h>
@@ -193,6 +194,26 @@ ipv6:
 		flow->thoff = (u16)nhoff;
 		return true;
 	}
+	case htons(ETH_P_MPLS_UC):
+	case htons(ETH_P_MPLS_MC): {
+		struct mpls_label *hdr, _hdr[2];
+mpls:
+		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
+					   hlen, &_hdr);
+		if (!hdr)
+			return false;
+		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) ==
+		    MPLS_LS_ENTROPY_IS_NEXT) {
+			flow->n_proto = proto;
+			flow->ip_proto = ip_proto;
+			flow->ports = ntohl(hdr[1].entry) & MPLS_LS_LABEL_MASK;
+			flow->thoff = (u16)nhoff;
+
+			return true;
+		} else {
+			return false;
+		}
+	}
 	case htons(ETH_P_FCOE):
 		flow->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
@@ -258,6 +279,9 @@ ipv6:
 	case IPPROTO_IPV6:
 		proto = htons(ETH_P_IPV6);
 		goto ipv6;
+	case IPPROTO_MPLS:
+		proto = htons(ETH_P_MPLS_UC);
+		goto mpls;
 	default:
 		break;
 	}
-- 
2.2.0.rc0.207.ga3a616c
