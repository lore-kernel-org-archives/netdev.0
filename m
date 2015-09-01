From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 06/11] flow_dissector: Add control/reporting of fragmentation
Date: Tue, 1 Sep 2015 09:24:28 -0700
Message-ID: <1441124673-3438470-7-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:40138 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753453AbbIAQZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:18 -0400
Received: from pps.filterd (m0044012 [127.0.0.1])
	by mx0a-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GLq7f006296
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:17 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0a-00082601.pphosted.com with ESMTP id 1wnf09r2yf-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:17 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 07a1955050c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:16 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add an input flag to flow dissector on rather dissection should be
attempted on a first fragment. Also add key_control flags to indicate
that a packet is a fragment or first fragment.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 include/net/flow_dissector.h |  4 ++++
 net/core/flow_dissector.c    | 15 +++++++++++++--
 2 files changed, 17 insertions(+), 2 deletions(-)

diff --git a/include/net/flow_dissector.h b/include/net/flow_dissector.h
index 74fe160..3410227 100644
--- a/include/net/flow_dissector.h
+++ b/include/net/flow_dissector.h
@@ -12,6 +12,8 @@
 struct flow_dissector_key_control {
 	u16	thoff;
 	u16	addr_type;
+	u32	is_fragment:1;
+	u32	first_frag:1;
 };
 
 /**
@@ -122,6 +124,8 @@ enum flow_dissector_key_id {
 	FLOW_DISSECTOR_KEY_MAX,
 };
 
+#define FLOW_DISSECTOR_F_PARSE_1ST_FRAG		BIT(0)
+
 struct flow_dissector_key {
 	enum flow_dissector_key_id key_id;
 	size_t offset; /* offset of struct flow_dissector_key_*
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index c3d9807..7536a46 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -177,8 +177,6 @@ ip:
 		nhoff += iph->ihl * 4;
 
 		ip_proto = iph->protocol;
-		if (ip_is_fragment(iph))
-			ip_proto = 0;
 
 		if (!skb_flow_dissector_uses_key(flow_dissector,
 						 FLOW_DISSECTOR_KEY_IPV4_ADDRS))
@@ -189,6 +187,19 @@ ip:
 		memcpy(&key_addrs->v4addrs, &iph->saddr,
 		       sizeof(key_addrs->v4addrs));
 		key_control->addr_type = FLOW_DISSECTOR_KEY_IPV4_ADDRS;
+
+		if (ip_is_fragment(iph)) {
+			key_control->is_fragment = 1;
+
+			if (iph->frag_off & htons(IP_OFFSET)) {
+				goto out_good;
+			} else {
+				key_control->first_frag = 1;
+				if (!(flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG))
+					goto out_good;
+			}
+		}
+
 		break;
 	}
 	case htons(ETH_P_IPV6): {
-- 
1.8.1
