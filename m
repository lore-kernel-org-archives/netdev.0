From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 2/2] flow_dissector: add support for dst, hop-by-hop and routing ext hdrs
Date: Fri, 12 Jun 2015 09:01:06 -0700
Message-ID: <1434124866-3881537-3-git-send-email-tom@herbertland.com>
References: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:12614 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750856AbbFLQB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jun 2015 12:01:29 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t5CFxjXj013410
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:01:28 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1v01n586td-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 09:01:28 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.101.97) with ESMTP	id
 47b91e40111c11e5a6a724be0595f910-c74d82a0 for <netdev@vger.kernel.org>;	Fri,
 12 Jun 2015 09:01:26 -0700
In-Reply-To: <1434124866-3881537-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If dst, hop-by-hop or routing extension headers are present determine
length of the options and skip over them in flow dissection.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 17 +++++++++++++++++
 1 file changed, 17 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 1818cdc..22e4dff 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -327,6 +327,7 @@ mpls:
 		return false;
 	}
 
+ip_proto_again:
 	switch (ip_proto) {
 	case IPPROTO_GRE: {
 		struct gre_hdr {
@@ -383,6 +384,22 @@ mpls:
 		}
 		goto again;
 	}
+	case NEXTHDR_HOP:
+	case NEXTHDR_ROUTING:
+	case NEXTHDR_DEST: {
+		u8 _opthdr[2], *opthdr;
+
+		if (proto != htons(ETH_P_IPV6))
+			break;
+
+		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
+					      data, hlen, &_opthdr);
+
+		ip_proto = _opthdr[0];
+		nhoff += (_opthdr[1] + 1) << 3;
+
+		goto ip_proto_again;
+	}
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
 		goto ip;
-- 
1.8.1
