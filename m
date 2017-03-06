From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net-next 5/5] flow_dissector: Move GRE dissection into a separate function
Date: Mon,  6 Mar 2017 16:39:55 +0100
Message-ID: <1488814795-5152-6-git-send-email-jiri@resnulli.us>
References: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, tom@herbertland.com,
        simon.horman@netronome.com, eric.dumazet@gmail.com,
        dinan.gunawardena@netronome.com, hadarh@mellanox.com, e@erig.me,
        fgao@ikuai8.com, mlxsw@mellanox.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f195.google.com ([209.85.128.195]:33948 "EHLO
        mail-wr0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932130AbdCFPkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 6 Mar 2017 10:40:11 -0500
Received: by mail-wr0-f195.google.com with SMTP id u48so22265197wrc.1
        for <netdev@vger.kernel.org>; Mon, 06 Mar 2017 07:40:09 -0800 (PST)
In-Reply-To: <1488814795-5152-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@mellanox.com>

Make the main flow_dissect function a bit smaller and move the GRE
dissection into a separate function.

Signed-off-by: Jiri Pirko <jiri@mellanox.com>
---
 net/core/flow_dissector.c | 244 +++++++++++++++++++++++++---------------------
 1 file changed, 134 insertions(+), 110 deletions(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 9120835..5f3ae92 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -116,6 +116,7 @@ EXPORT_SYMBOL(__skb_flow_get_ports);
 enum flow_dissect_ret {
 	FLOW_DISSECT_RET_OUT_GOOD,
 	FLOW_DISSECT_RET_OUT_BAD,
+	FLOW_DISSECT_RET_OUT_PROTO_AGAIN,
 };
 
 static enum flow_dissect_ret
@@ -200,6 +201,128 @@ __skb_flow_dissect_arp(const struct sk_buff *skb,
 	return FLOW_DISSECT_RET_OUT_GOOD;
 }
 
+static enum flow_dissect_ret
+__skb_flow_dissect_gre(const struct sk_buff *skb,
+		       struct flow_dissector_key_control *key_control,
+		       struct flow_dissector *flow_dissector,
+		       void *target_container, void *data,
+		       __be16 *p_proto, int *p_nhoff, int *p_hlen,
+		       unsigned int flags)
+{
+	struct flow_dissector_key_keyid *key_keyid;
+	struct gre_base_hdr *hdr, _hdr;
+	int offset = 0;
+	u16 gre_ver;
+
+	hdr = __skb_header_pointer(skb, *p_nhoff, sizeof(_hdr),
+				   data, *p_hlen, &_hdr);
+	if (!hdr)
+		return FLOW_DISSECT_RET_OUT_BAD;
+
+	/* Only look inside GRE without routing */
+	if (hdr->flags & GRE_ROUTING)
+		return FLOW_DISSECT_RET_OUT_GOOD;
+
+	/* Only look inside GRE for version 0 and 1 */
+	gre_ver = ntohs(hdr->flags & GRE_VERSION);
+	if (gre_ver > 1)
+		return FLOW_DISSECT_RET_OUT_GOOD;
+
+	*p_proto = hdr->protocol;
+	if (gre_ver) {
+		/* Version1 must be PPTP, and check the flags */
+		if (!(*p_proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY)))
+			return FLOW_DISSECT_RET_OUT_GOOD;
+	}
+
+	offset += sizeof(struct gre_base_hdr);
+
+	if (hdr->flags & GRE_CSUM)
+		offset += sizeof(((struct gre_full_hdr *) 0)->csum) +
+			  sizeof(((struct gre_full_hdr *) 0)->reserved1);
+
+	if (hdr->flags & GRE_KEY) {
+		const __be32 *keyid;
+		__be32 _keyid;
+
+		keyid = __skb_header_pointer(skb, *p_nhoff + offset,
+					     sizeof(_keyid),
+					     data, *p_hlen, &_keyid);
+		if (!keyid)
+			return FLOW_DISSECT_RET_OUT_BAD;
+
+		if (dissector_uses_key(flow_dissector,
+				       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
+			key_keyid = skb_flow_dissector_target(flow_dissector,
+							      FLOW_DISSECTOR_KEY_GRE_KEYID,
+							      target_container);
+			if (gre_ver == 0)
+				key_keyid->keyid = *keyid;
+			else
+				key_keyid->keyid = *keyid & GRE_PPTP_KEY_MASK;
+		}
+		offset += sizeof(((struct gre_full_hdr *) 0)->key);
+	}
+
+	if (hdr->flags & GRE_SEQ)
+		offset += sizeof(((struct pptp_gre_header *) 0)->seq);
+
+	if (gre_ver == 0) {
+		if (*p_proto == htons(ETH_P_TEB)) {
+			const struct ethhdr *eth;
+			struct ethhdr _eth;
+
+			eth = __skb_header_pointer(skb, *p_nhoff + offset,
+						   sizeof(_eth),
+						   data, *p_hlen, &_eth);
+			if (!eth)
+				return FLOW_DISSECT_RET_OUT_BAD;
+			*p_proto = eth->h_proto;
+			offset += sizeof(*eth);
+
+			/* Cap headers that we access via pointers at the
+			 * end of the Ethernet header as our maximum alignment
+			 * at that point is only 2 bytes.
+			 */
+			if (NET_IP_ALIGN)
+				*p_hlen = *p_nhoff + offset;
+		}
+	} else { /* version 1, must be PPTP */
+		u8 _ppp_hdr[PPP_HDRLEN];
+		u8 *ppp_hdr;
+
+		if (hdr->flags & GRE_ACK)
+			offset += sizeof(((struct pptp_gre_header *) 0)->ack);
+
+		ppp_hdr = __skb_header_pointer(skb, *p_nhoff + offset,
+					       sizeof(_ppp_hdr),
+					       data, *p_hlen, _ppp_hdr);
+		if (!ppp_hdr)
+			return FLOW_DISSECT_RET_OUT_BAD;
+
+		switch (PPP_PROTOCOL(ppp_hdr)) {
+		case PPP_IP:
+			*p_proto = htons(ETH_P_IP);
+			break;
+		case PPP_IPV6:
+			*p_proto = htons(ETH_P_IPV6);
+			break;
+		default:
+			/* Could probably catch some more like MPLS */
+			break;
+		}
+
+		offset += PPP_HDRLEN;
+	}
+
+	*p_nhoff += offset;
+	key_control->flags |= FLOW_DIS_ENCAPSULATION;
+	if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+		return FLOW_DISSECT_RET_OUT_GOOD;
+
+	return FLOW_DISSECT_RET_OUT_PROTO_AGAIN;
+}
+
 /**
  * __skb_flow_dissect - extract the flow_keys struct and return it
  * @skb: sk_buff to extract the flow from, can be NULL if the rest are specified
@@ -229,7 +352,6 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 	struct flow_dissector_key_icmp *key_icmp;
 	struct flow_dissector_key_tags *key_tags;
 	struct flow_dissector_key_vlan *key_vlan;
-	struct flow_dissector_key_keyid *key_keyid;
 	bool skip_vlan = false;
 	u8 ip_proto = 0;
 	bool ret;
@@ -443,6 +565,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		case FLOW_DISSECT_RET_OUT_GOOD:
 			goto out_good;
 		case FLOW_DISSECT_RET_OUT_BAD:
+		default:
 			goto out_bad;
 		}
 	case htons(ETH_P_FCOE):
@@ -460,6 +583,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		case FLOW_DISSECT_RET_OUT_GOOD:
 			goto out_good;
 		case FLOW_DISSECT_RET_OUT_BAD:
+		default:
 			goto out_bad;
 		}
 	default:
@@ -468,117 +592,17 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 
 ip_proto_again:
 	switch (ip_proto) {
-	case IPPROTO_GRE: {
-		struct gre_base_hdr *hdr, _hdr;
-		u16 gre_ver;
-		int offset = 0;
-
-		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
-		if (!hdr)
-			goto out_bad;
-
-		/* Only look inside GRE without routing */
-		if (hdr->flags & GRE_ROUTING)
-			goto out_good;
-
-		/* Only look inside GRE for version 0 and 1 */
-		gre_ver = ntohs(hdr->flags & GRE_VERSION);
-		if (gre_ver > 1)
+	case IPPROTO_GRE:
+		switch (__skb_flow_dissect_gre(skb, key_control, flow_dissector,
+					       target_container, data,
+					       &proto, &nhoff, &hlen, flags)) {
+		case FLOW_DISSECT_RET_OUT_GOOD:
 			goto out_good;
-
-		proto = hdr->protocol;
-		if (gre_ver) {
-			/* Version1 must be PPTP, and check the flags */
-			if (!(proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY)))
-				goto out_good;
-		}
-
-		offset += sizeof(struct gre_base_hdr);
-
-		if (hdr->flags & GRE_CSUM)
-			offset += sizeof(((struct gre_full_hdr *)0)->csum) +
-				  sizeof(((struct gre_full_hdr *)0)->reserved1);
-
-		if (hdr->flags & GRE_KEY) {
-			const __be32 *keyid;
-			__be32 _keyid;
-
-			keyid = __skb_header_pointer(skb, nhoff + offset, sizeof(_keyid),
-						     data, hlen, &_keyid);
-			if (!keyid)
-				goto out_bad;
-
-			if (dissector_uses_key(flow_dissector,
-					       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
-				key_keyid = skb_flow_dissector_target(flow_dissector,
-								      FLOW_DISSECTOR_KEY_GRE_KEYID,
-								      target_container);
-				if (gre_ver == 0)
-					key_keyid->keyid = *keyid;
-				else
-					key_keyid->keyid = *keyid & GRE_PPTP_KEY_MASK;
-			}
-			offset += sizeof(((struct gre_full_hdr *)0)->key);
-		}
-
-		if (hdr->flags & GRE_SEQ)
-			offset += sizeof(((struct pptp_gre_header *)0)->seq);
-
-		if (gre_ver == 0) {
-			if (proto == htons(ETH_P_TEB)) {
-				const struct ethhdr *eth;
-				struct ethhdr _eth;
-
-				eth = __skb_header_pointer(skb, nhoff + offset,
-							   sizeof(_eth),
-							   data, hlen, &_eth);
-				if (!eth)
-					goto out_bad;
-				proto = eth->h_proto;
-				offset += sizeof(*eth);
-
-				/* Cap headers that we access via pointers at the
-				 * end of the Ethernet header as our maximum alignment
-				 * at that point is only 2 bytes.
-				 */
-				if (NET_IP_ALIGN)
-					hlen = (nhoff + offset);
-			}
-		} else { /* version 1, must be PPTP */
-			u8 _ppp_hdr[PPP_HDRLEN];
-			u8 *ppp_hdr;
-
-			if (hdr->flags & GRE_ACK)
-				offset += sizeof(((struct pptp_gre_header *)0)->ack);
-
-			ppp_hdr = __skb_header_pointer(skb, nhoff + offset,
-						     sizeof(_ppp_hdr),
-						     data, hlen, _ppp_hdr);
-			if (!ppp_hdr)
-				goto out_bad;
-
-			switch (PPP_PROTOCOL(ppp_hdr)) {
-			case PPP_IP:
-				proto = htons(ETH_P_IP);
-				break;
-			case PPP_IPV6:
-				proto = htons(ETH_P_IPV6);
-				break;
-			default:
-				/* Could probably catch some more like MPLS */
-				break;
-			}
-
-			offset += PPP_HDRLEN;
+		case FLOW_DISSECT_RET_OUT_BAD:
+			goto out_bad;
+		case FLOW_DISSECT_RET_OUT_PROTO_AGAIN:
+			goto proto_again;
 		}
-
-		nhoff += offset;
-		key_control->flags |= FLOW_DIS_ENCAPSULATION;
-		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
-			goto out_good;
-
-		goto proto_again;
-	}
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
 	case NEXTHDR_DEST: {
-- 
2.7.4
