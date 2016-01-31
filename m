From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net] net: Allow flow dissector to handle non 4-byte aligned headers
Date: Sun, 31 Jan 2016 13:37:01 -0800
Message-ID: <1454276221-3543907-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <sowmini.varadhan@oracle.com>, <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:36397 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757500AbcAaVh4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 31 Jan 2016 16:37:56 -0500
Received: from pps.filterd (m0001255.ppops.net [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.15.0.59/8.15.0.59) with SMTP id u0VLblVo001764
	for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 13:37:55 -0800
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 20rsvbdkxx-1
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 31 Jan 2016 13:37:55 -0800
Received: from devbig284.prn2.facebook.com (10.35.15.32)	by
 mx-out.facebook.com (10.212.236.87) with ESMTP	id
 c841d66cc86211e5af850002c9521c9e-fcff82b0 for <netdev@vger.kernel.org>;	Sun,
 31 Jan 2016 13:37:10 -0800
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Call get_unaligned_be32 when we access 32-bit fields in
__skb_flow_dissect. At the beginning check for unlikely case of
1-byte aligned packet.

Note that flow_dissector may be asked to parse packet unaligned
fields in two instances:

1) Packet from a driver which is aligned to Ethernet header
   (2-byte alignment)
2) Parsing inner headers of a received GRE-TEB packet

Testing: Ran super_netperf tests did not see a regression. This was on
x86 which does not have problems with unaligned data.

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 net/core/flow_dissector.c | 19 ++++++++++++++-----
 1 file changed, 14 insertions(+), 5 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index d79699c..1c64a1a 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -95,7 +95,7 @@ __be32 __skb_flow_get_ports(const struct sk_buff *skb, int thoff, u8 ip_proto,
 		ports = __skb_header_pointer(skb, thoff + poff,
 					     sizeof(_ports), data, hlen, &_ports);
 		if (ports)
-			return *ports;
+			return get_unaligned_be32(ports);
 	}
 
 	return 0;
@@ -116,6 +116,10 @@ EXPORT_SYMBOL(__skb_flow_get_ports);
  * by flow_dissector from either the skbuff or a raw buffer specified by the
  * rest parameters.
  *
+ * This function does not assume 4-byte alignment, but it does assume 2-byte
+ * alignment (false is returned for 1-byte alignment). get_unaligned_be32
+ * is called to get thirty-two values out of the packet.
+ *
  * Caller must take care of zeroing target container memory.
  */
 bool __skb_flow_dissect(const struct sk_buff *skb,
@@ -140,6 +144,11 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		hlen = skb_headlen(skb);
 	}
 
+#ifndef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
+	if (WARN_ON(((u64)data & 0x1)))
+		return false;
+#endif
+
 	/* It is ensured by skb_flow_dissector_init() that control key will
 	 * be always present.
 	 */
@@ -230,7 +239,7 @@ ipv6:
 			key_control->addr_type = FLOW_DISSECTOR_KEY_IPV6_ADDRS;
 		}
 
-		flow_label = ip6_flowlabel(iph);
+		flow_label = get_unaligned_be32(iph) & IPV6_FLOWLABEL_MASK;
 		if (flow_label) {
 			if (dissector_uses_key(flow_dissector,
 					       FLOW_DISSECTOR_KEY_FLOW_LABEL)) {
@@ -303,7 +312,7 @@ ipv6:
 			key_addrs = skb_flow_dissector_target(flow_dissector,
 							      FLOW_DISSECTOR_KEY_TIPC_ADDRS,
 							      target_container);
-			key_addrs->tipcaddrs.srcnode = hdr->srcnode;
+			key_addrs->tipcaddrs.srcnode = get_unaligned_be32(&hdr->srcnode);
 			key_control->addr_type = FLOW_DISSECTOR_KEY_TIPC_ADDRS;
 		}
 		goto out_good;
@@ -325,7 +334,7 @@ mpls:
 				key_keyid = skb_flow_dissector_target(flow_dissector,
 								      FLOW_DISSECTOR_KEY_MPLS_ENTROPY,
 								      target_container);
-				key_keyid->keyid = hdr[1].entry &
+				key_keyid->keyid = get_unaligned_be32(&hdr[1].entry) &
 					htonl(MPLS_LS_LABEL_MASK);
 			}
 
@@ -379,7 +388,7 @@ ip_proto_again:
 				key_keyid = skb_flow_dissector_target(flow_dissector,
 								      FLOW_DISSECTOR_KEY_GRE_KEYID,
 								      target_container);
-				key_keyid->keyid = *keyid;
+				key_keyid->keyid = get_unaligned_be32(keyid);
 			}
 			nhoff += 4;
 		}
-- 
2.4.6
