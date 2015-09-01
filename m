From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 10/11] flow_dissector: Add control/reporting of encapsulation
Date: Tue, 1 Sep 2015 09:24:32 -0700
Message-ID: <1441124673-3438470-11-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:10927 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753517AbbIAQZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:23 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GOla0009009
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:22 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wnffjr0bp-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:22 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 0a74dc1a50c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:21 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an input flag to flow dissector on rather dissection should stop
when encapsulation is detected (IP/IP or GRE). Also, add a key_control
flag that indicates encapsulation was encountered during the
dissection.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  2 ++
 net/core/flow_dissector.c    | 15 +++++++++++++++
 2 files changed, 17 insertions(+)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 66dbc34..bddd108 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -14,6 +14,7 @@ struct flow_dissector_key_control {
 	u16	addr_type;
 	u32	is_fragment:1;
 	u32	first_frag:1;
+	u32	encapsulation:1;
 };
 
 /**
@@ -127,6 +128,7 @@ enum flow_dissector_key_id {
 #define FLOW_DISSECTOR_F_PARSE_1ST_FRAG		BIT(0)
 #define FLOW_DISSECTOR_F_STOP_AT_L3		BIT(1)
 #define FLOW_DISSECTOR_F_STOP_AT_FLOW_LABEL	BIT(2)
+#define FLOW_DISSECTOR_F_STOP_AT_ENCAP		BIT(3)
 
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 094e343..8d89013 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -397,6 +397,11 @@ ip_proto_again:
 			proto = eth->h_proto;
 			nhoff += sizeof(*eth);
 		}
+
+		key_control->encapsulation = 1;
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+			goto out_good;
+
 		goto again;
 	}
 	case NEXTHDR_HOP:
@@ -444,9 +449,19 @@ ip_proto_again:
 	}
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
+
+		key_control->encapsulation = 1;
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+			goto out_good;
+
 		goto ip;
 	case IPPROTO_IPV6:
 		proto = htons(ETH_P_IPV6);
+
+		key_control->encapsulation = 1;
+		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+			goto out_good;
+
 		goto ipv6;
 	case IPPROTO_MPLS:
 		proto = htons(ETH_P_MPLS_UC);
-- 
1.8.1
