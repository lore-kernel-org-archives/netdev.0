From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 6/6] mpls: Add MPLS entropy label in flow_keys
Date: Mon, 4 May 2015 16:02:40 -0700
Message-ID: <1430780560-2758924-7-git-send-email-tom@herbertland.com>
References: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:14591 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751886AbbEDXDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 May 2015 19:03:03 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t44N2FAx003110
	for <netdev@vger.kernel.org>; Mon, 4 May 2015 16:03:03 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1u6e0qgfye-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 04 May 2015 16:03:03 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.89) with ESMTP	id
 b67336e2f2b111e495a20002c95209d8-9abf11e0 for <netdev@vger.kernel.org>;	Mon,
 04 May 2015 16:03:01 -0700
In-Reply-To: <1430780560-2758924-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow dissector if an MPLS header contains an entropy label this is
saved in the new extra entropy field of flow_keys. The entropy label is
then represented in the flow hash function input.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/uapi/linux/in.h   |  2 ++
 include/uapi/linux/mpls.h |  3 +++
 net/core/flow_dissector.c | 27 +++++++++++++++++++++++++++
 3 files changed, 32 insertions(+)

diff --git a/include/uapi/linux/in.h b/include/uapi/linux/in.h
index 589ced0..c86f6ab 100644
--- a/include/uapi/linux/in.h
+++ b/include/uapi/linux/in.h
@@ -69,6 +69,8 @@ enum {
 #define IPPROTO_SCTP		IPPROTO_SCTP
   IPPROTO_UDPLITE = 136,	/* UDP-Lite (RFC 3828)			*/
 #define IPPROTO_UDPLITE		IPPROTO_UDPLITE
+  IPPROTO_MPLS = 137,		/* MPLS in IP (RFC 4023)		*/
+#define IPPROTO_MPLS		IPPROTO_SCTP
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
index 025b91f..95c9a07 100644
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
@@ -169,6 +170,29 @@ ipv6:
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
+
+		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) ==
+		    MPLS_LS_ENTROPY_IS_NEXT) {
+			flow->n_proto = proto;
+			flow->ip_proto = ip_proto;
+			flow->extra_entropy = ntohl(hdr[1].entry) &
+					      MPLS_LS_LABEL_MASK;
+			flow->thoff = (u16)nhoff;
+
+			return true;
+		} else {
+			return false;
+		}
+	}
+
 	case htons(ETH_P_FCOE):
 		flow->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
@@ -234,6 +258,9 @@ ipv6:
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
1.8.1
