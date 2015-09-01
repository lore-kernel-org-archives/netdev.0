From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 07/11] flow_dissector: Support IPv6 fragment header
Date: Tue, 1 Sep 2015 09:24:29 -0700
Message-ID: <1441124673-3438470-8-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33851 "EHLO
	mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753450AbbIAQZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:19 -0400
Received: from pps.filterd (m0004003 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GNWB2007855
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:18 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wnf6p03dn-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:18 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 082b808050c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:17 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Parse NEXTHDR_FRAGMENT. When seen account for it in the fragment bits of
key_control. Also, check if first fragment should be parsed.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 25 +++++++++++++++++++++++++
 1 file changed, 25 insertions(+)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 7536a46..907de2f 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -409,6 +409,31 @@ ip_proto_again:
 
 		goto ip_proto_again;
 	}
+	case NEXTHDR_FRAGMENT: {
+		struct frag_hdr _fh, *fh;
+
+		if (proto != htons(ETH_P_IPV6))
+			break;
+
+		fh = __skb_header_pointer(skb, nhoff, sizeof(_fh),
+					  data, hlen, &_fh);
+
+		if (!fh)
+			goto out_bad;
+
+		key_control->is_fragment = 1;
+
+		nhoff += sizeof(_fh);
+
+		if (!(fh->frag_off & htons(IP6_OFFSET))) {
+			key_control->first_frag = 1;
+			if (flags & FLOW_DISSECTOR_F_PARSE_1ST_FRAG) {
+				ip_proto = fh->nexthdr;
+				goto ip_proto_again;
+			}
+		}
+		goto out_good;
+	}
 	case IPPROTO_IPIP:
 		proto = htons(ETH_P_IP);
 		goto ip;
-- 
1.8.1
