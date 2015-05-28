From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH v4 net-next 11/11] mpls: Add MPLS entropy label in flow_keys
Date: Thu, 28 May 2015 11:19:08 -0700
Message-ID: <1432837148-1359931-12-git-send-email-tom@herbertland.com>
References: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:48625 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754533AbbE1STh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 14:19:37 -0400
Received: from pps.filterd (m0004346 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t4SIJJP4031639
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:37 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1up77gg4c7-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 28 May 2015 11:19:37 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 18510aa8056611e5bc140002c9521c9e-a4fef3a0 for <netdev@vger.kernel.org>;	Thu,
 28 May 2015 11:19:35 -0700
In-Reply-To: <1432837148-1359931-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In flow dissector if an MPLS header contains an entropy label this is
saved in the new keyid field of flow_keys. The entropy label is
then represented in the flow hash function input.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  1 +
 net/core/flow_dissector.c    | 35 +++++++++++++++++++++++++++++++++++
 2 files changed, 36 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 5d4257b..09f4b76 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -118,6 +118,7 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_VLANID, /* struct flow_dissector_key_flow_tags */
 	FLOW_DISSECTOR_KEY_FLOW_LABEL, /* struct flow_dissector_key_flow_tags */
 	FLOW_DISSECTOR_KEY_GRE_KEYID, /* struct flow_dissector_key_keyid */
+	FLOW_DISSECTOR_KEY_MPLS_ENTROPY, /* struct flow_dissector_key_keyid */
 
 	FLOW_DISSECTOR_KEY_MAX,
 };
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index ea318d5..aaebe52 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -15,6 +15,7 @@
 #include <linux/ppp_defs.h>
 #include <linux/stddef.h>
 #include <linux/if_ether.h>
+#include <linux/mpls.h>
 #include <net/flow_dissector.h>
 #include <scsi/fc/fc_fcoe.h>
 
@@ -288,6 +289,37 @@ ipv6:
 		}
 		return true;
 	}
+
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
+		     MPLS_LABEL_ENTROPY) {
+			if (skb_flow_dissector_uses_key(flow_dissector,
+							FLOW_DISSECTOR_KEY_MPLS_ENTROPY)) {
+				key_keyid = skb_flow_dissector_target(flow_dissector,
+								      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
+								      target_container);
+				key_keyid->keyid = ntohl(hdr[1].entry) &
+					MPLS_LS_LABEL_MASK;
+			}
+
+			key_basic->n_proto = proto;
+			key_basic->ip_proto = ip_proto;
+			key_control->thoff = (u16)nhoff;
+
+			return true;
+		}
+
+		return true;
+	}
+
 	case htons(ETH_P_FCOE):
 		key_control->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
@@ -357,6 +389,9 @@ ipv6:
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
