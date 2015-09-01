From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next 04/11] flow_dissector: Jump to exit code in __skb_flow_dissect
Date: Tue, 1 Sep 2015 09:24:26 -0700
Message-ID: <1441124673-3438470-5-git-send-email-tom@herbertland.com>
References: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35887 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751172AbbIAQZO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:25:14 -0400
Received: from pps.filterd (m0004060 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t81GKcpA018202
	for <netdev@vger.kernel.org>; Tue, 1 Sep 2015 09:25:13 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wnf3m04h2-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 01 Sep 2015 09:25:13 -0700
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.102.107.97) with ESMTP	id
 0506af5650c611e5b4920002c99331b0-5fbfc240 for <netdev@vger.kernel.org>;	Tue,
 01 Sep 2015 09:25:12 -0700
In-Reply-To: <1441124673-3438470-1-git-send-email-tom@herbertland.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Instead of returning immediately (on a parsing failure for instance) we
jump to cleanup code. This always sets protocol values in key_control
(even on a failure there is still valid information in the key_tags that
was set before the problem was hit).

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 51 +++++++++++++++++++++++------------------------
 1 file changed, 25 insertions(+), 26 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 151b6e4..22f3d76 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -130,6 +130,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_keyid *key_keyid;
 	u8 ip_proto = 0;
+	bool ret = false;
 
 	if (!data) {
 		data = skb->data;
@@ -171,7 +172,7 @@ again:
 ip:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
 		if (!iph || iph->ihl < 5)
-			return false;
+			goto out_bad;
 		nhoff += iph->ihl * 4;
 
 		ip_proto = iph->protocol;
@@ -197,7 +198,7 @@ ip:
 ipv6:
 		iph = __skb_header_pointer(skb, nhoff, sizeof(_iph), data, hlen, &_iph);
 		if (!iph)
-			return false;
+			goto out_bad;
 
 		ip_proto = iph->nexthdr;
 		nhoff += sizeof(struct ipv6hdr);
@@ -234,7 +235,7 @@ ipv6:
 
 		vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan), data, hlen, &_vlan);
 		if (!vlan)
-			return false;
+			goto out_bad;
 
 		if (skb_flow_dissector_uses_key(flow_dissector,
 						FLOW_DISSECTOR_KEY_VLANID)) {
@@ -256,7 +257,7 @@ ipv6:
 		} *hdr, _hdr;
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
-			return false;
+			goto out_bad;
 		proto = hdr->proto;
 		nhoff += PPPOE_SES_HLEN;
 		switch (proto) {
@@ -265,7 +266,7 @@ ipv6:
 		case htons(PPP_IPV6):
 			goto ipv6;
 		default:
-			return false;
+			goto out_bad;
 		}
 	}
 	case htons(ETH_P_TIPC): {
@@ -275,9 +276,7 @@ ipv6:
 		} *hdr, _hdr;
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
-			return false;
-		key_basic->n_proto = proto;
-		key_control->thoff = (u16)nhoff;
+			goto out_bad;
 
 		if (skb_flow_dissector_uses_key(flow_dissector,
 						FLOW_DISSECTOR_KEY_TIPC_ADDRS)) {
@@ -287,7 +286,7 @@ ipv6:
 			key_addrs->tipcaddrs.srcnode = hdr->srcnode;
 			key_control->addr_type = FLOW_DISSECTOR_KEY_TIPC_ADDRS;
 		}
-		return true;
+		goto out_good;
 	}
 
 	case htons(ETH_P_MPLS_UC):
@@ -297,7 +296,7 @@ mpls:
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data,
 					   hlen, &_hdr);
 		if (!hdr)
-			return false;
+			goto out_bad;
 
 		if ((ntohl(hdr[0].entry) & MPLS_LS_LABEL_MASK) >>
 		     MPLS_LS_LABEL_SHIFT == MPLS_LABEL_ENTROPY) {
@@ -310,21 +309,17 @@ mpls:
 					htonl(MPLS_LS_LABEL_MASK);
 			}
 
-			key_basic->n_proto = proto;
-			key_basic->ip_proto = ip_proto;
-			key_control->thoff = (u16)nhoff;
-
-			return true;
+			goto out_good;
 		}
 
-		return true;
+		goto out_good;
 	}
 
 	case htons(ETH_P_FCOE):
 		key_control->thoff = (u16)(nhoff + FCOE_HEADER_LEN);
 		/* fall through */
 	default:
-		return false;
+		goto out_bad;
 	}
 
 ip_proto_again:
@@ -337,7 +332,7 @@ ip_proto_again:
 
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
-			return false;
+			goto out_bad;
 		/*
 		 * Only look inside GRE if version zero and no
 		 * routing
@@ -357,7 +352,7 @@ ip_proto_again:
 						     data, hlen, &_keyid);
 
 			if (!keyid)
-				return false;
+				goto out_bad;
 
 			if (skb_flow_dissector_uses_key(flow_dissector,
 							FLOW_DISSECTOR_KEY_GRE_KEYID)) {
@@ -378,7 +373,7 @@ ip_proto_again:
 						   sizeof(_eth),
 						   data, hlen, &_eth);
 			if (!eth)
-				return false;
+				goto out_bad;
 			proto = eth->h_proto;
 			nhoff += sizeof(*eth);
 		}
@@ -395,7 +390,7 @@ ip_proto_again:
 		opthdr = __skb_header_pointer(skb, nhoff, sizeof(_opthdr),
 					      data, hlen, &_opthdr);
 		if (!opthdr)
-			return false;
+			goto out_bad;
 
 		ip_proto = opthdr[0];
 		nhoff += (opthdr[1] + 1) << 3;
@@ -415,10 +410,6 @@ ip_proto_again:
 		break;
 	}
 
-	key_basic->n_proto = proto;
-	key_basic->ip_proto = ip_proto;
-	key_control->thoff = (u16)nhoff;
-
 	if (skb_flow_dissector_uses_key(flow_dissector,
 					FLOW_DISSECTOR_KEY_PORTS)) {
 		key_ports = skb_flow_dissector_target(flow_dissector,
@@ -428,7 +419,15 @@ ip_proto_again:
 							data, hlen);
 	}
 
-	return true;
+out_good:
+	ret = true;
+
+out_bad:
+	key_basic->n_proto = proto;
+	key_basic->ip_proto = ip_proto;
+	key_control->thoff = (u16)nhoff;
+
+	return ret;
 }
 EXPORT_SYMBOL(__skb_flow_dissect);
 
-- 
1.8.1
