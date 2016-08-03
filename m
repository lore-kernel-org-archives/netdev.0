From: fgao@ikuai8.com
Subject: [PATCH v3 1/1] rps: Inspect PPTP encapsulated by GRE to get flow hash
Date: Wed,  3 Aug 2016 22:52:40 +0800
Message-ID: <1470235960-4740-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, philipp@redfish-solutions.com,
	stephen@networkplumber.org, pshelar@nicira.com,
	tom@herbertland.com, aduyck@mirantis.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg321.qq.com ([14.17.32.30]:51901 "EHLO smtpbg321.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755878AbcHCOzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Aug 2016 10:55:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

The PPTP is encapsulated by GRE header with that GRE_VERSION bits
must contain one. But current GRE RPS needs the GRE_VERSION must be
zero. So RPS does not work for PPTP traffic.

In my test environment, there are four MIPS cores, and all traffic
are passed through by PPTP. As a result, only one core is 100% busy
while other three cores are very idle. After this patch, the usage
of four cores are balanced well.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v3: 1) Move struct pptp_gre_header defination into new file pptp.h
     2) Use sizeof GRE and PPTP type instead of literal value;
     3) Remove strict flag check for PPTP to robust;
     4) Consolidate the codes again;
 v2: Update according to Tom and Philp's advice.
     1) Consolidate the codes with GRE version 0 path;
     2) Use PPP_PROTOCOL to get ppp protol;
     3) Set the FLOW_DIS_ENCAPSULATION flag;
 v1: Intial patch

 drivers/net/ppp/pptp.c         |  36 +----------
 include/net/pptp.h             |  40 ++++++++++++
 include/uapi/linux/if_tunnel.h |   7 +-
 net/core/flow_dissector.c      | 141 +++++++++++++++++++++++++----------------
 4 files changed, 134 insertions(+), 90 deletions(-)
 create mode 100644 include/net/pptp.h

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index ae0905e..3e68dbc 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -37,6 +37,7 @@
 #include <net/icmp.h>
 #include <net/route.h>
 #include <net/gre.h>
+#include <net/pptp.h>
 
 #include <linux/uaccess.h>
 
@@ -53,41 +54,6 @@ static struct proto pptp_sk_proto __read_mostly;
 static const struct ppp_channel_ops pptp_chan_ops;
 static const struct proto_ops pptp_ops;
 
-#define PPP_LCP_ECHOREQ 0x09
-#define PPP_LCP_ECHOREP 0x0A
-#define SC_RCV_BITS	(SC_RCV_B7_1|SC_RCV_B7_0|SC_RCV_ODDP|SC_RCV_EVNP)
-
-#define MISSING_WINDOW 20
-#define WRAPPED(curseq, lastseq)\
-	((((curseq) & 0xffffff00) == 0) &&\
-	(((lastseq) & 0xffffff00) == 0xffffff00))
-
-#define PPTP_GRE_PROTO  0x880B
-#define PPTP_GRE_VER    0x1
-
-#define PPTP_GRE_FLAG_C	0x80
-#define PPTP_GRE_FLAG_R	0x40
-#define PPTP_GRE_FLAG_K	0x20
-#define PPTP_GRE_FLAG_S	0x10
-#define PPTP_GRE_FLAG_A	0x80
-
-#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
-#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
-#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
-#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
-#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
-
-#define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
-struct pptp_gre_header {
-	u8  flags;
-	u8  ver;
-	__be16 protocol;
-	__be16 payload_len;
-	__be16 call_id;
-	__be32 seq;
-	__be32 ack;
-} __packed;
-
 static struct pppox_sock *lookup_chan(u16 call_id, __be32 s_addr)
 {
 	struct pppox_sock *sock;
diff --git a/include/net/pptp.h b/include/net/pptp.h
new file mode 100644
index 0000000..301d3e2
--- /dev/null
+++ b/include/net/pptp.h
@@ -0,0 +1,40 @@
+#ifndef _NET_PPTP_H
+#define _NET_PPTP_H
+
+#define PPP_LCP_ECHOREQ 0x09
+#define PPP_LCP_ECHOREP 0x0A
+#define SC_RCV_BITS     (SC_RCV_B7_1|SC_RCV_B7_0|SC_RCV_ODDP|SC_RCV_EVNP)
+
+#define MISSING_WINDOW 20
+#define WRAPPED(curseq, lastseq)\
+	((((curseq) & 0xffffff00) == 0) &&\
+	(((lastseq) & 0xffffff00) == 0xffffff00))
+
+#define PPTP_GRE_PROTO  0x880B
+#define PPTP_GRE_VER    0x1
+
+#define PPTP_GRE_FLAG_C 0x80
+#define PPTP_GRE_FLAG_R 0x40
+#define PPTP_GRE_FLAG_K 0x20
+#define PPTP_GRE_FLAG_S 0x10
+#define PPTP_GRE_FLAG_A 0x80
+
+#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
+#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
+#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
+#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
+#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
+
+#define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
+struct pptp_gre_header {
+	u8  flags;
+	u8  ver;
+	__be16 protocol;
+	__be16 payload_len;
+	__be16 call_id;
+	__be32 seq;
+	__be32 ack;
+} __packed;
+
+
+#endif
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 1046f55..7d889db 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -24,9 +24,14 @@
 #define GRE_SEQ		__cpu_to_be16(0x1000)
 #define GRE_STRICT	__cpu_to_be16(0x0800)
 #define GRE_REC		__cpu_to_be16(0x0700)
-#define GRE_FLAGS	__cpu_to_be16(0x00F8)
+#define GRE_ACK		__cpu_to_be16(0x0080)
+#define GRE_FLAGS	__cpu_to_be16(0x0078)
 #define GRE_VERSION	__cpu_to_be16(0x0007)
 
+#define GRE_VERSION_1	__cpu_to_be16(0x0001)
+#define GRE_PROTO_PPP	__cpu_to_be16(0x880b)
+
+
 struct ip_tunnel_parm {
 	char			name[IFNAMSIZ];
 	int			link;
diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 61ad43f..52b7c3c 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -6,6 +6,8 @@
 #include <linux/if_vlan.h>
 #include <net/ip.h>
 #include <net/ipv6.h>
+#include <net/gre.h>
+#include <net/pptp.h>
 #include <linux/igmp.h>
 #include <linux/icmp.h>
 #include <linux/sctp.h>
@@ -338,71 +340,102 @@ mpls:
 ip_proto_again:
 	switch (ip_proto) {
 	case IPPROTO_GRE: {
-		struct gre_hdr {
-			__be16 flags;
-			__be16 proto;
-		} *hdr, _hdr;
+		struct gre_base_hdr *hdr, _hdr;
 
 		hdr = __skb_header_pointer(skb, nhoff, sizeof(_hdr), data, hlen, &_hdr);
 		if (!hdr)
 			goto out_bad;
-		/*
-		 * Only look inside GRE if version zero and no
-		 * routing
-		 */
-		if (hdr->flags & (GRE_VERSION | GRE_ROUTING))
-			break;
 
-		proto = hdr->proto;
-		nhoff += 4;
-		if (hdr->flags & GRE_CSUM)
-			nhoff += 4;
-		if (hdr->flags & GRE_KEY) {
-			const __be32 *keyid;
-			__be32 _keyid;
+		/* Only look inside GRE without routing */
+		if (!(hdr->flags & GRE_ROUTING)) {
+			int offset = 0;
 
-			keyid = __skb_header_pointer(skb, nhoff, sizeof(_keyid),
-						     data, hlen, &_keyid);
+			proto = hdr->protocol;
 
-			if (!keyid)
-				goto out_bad;
+			if (hdr->flags & GRE_VERSION) {
+				/* Maybe PPTP in GRE */
+				if (!(proto == GRE_PROTO_PPP && (hdr->flags & GRE_KEY) &&
+				     (hdr->flags & GRE_VERSION) == GRE_VERSION_1))
+					break;
+			}
 
-			if (dissector_uses_key(flow_dissector,
-					       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
-				key_keyid = skb_flow_dissector_target(flow_dissector,
-								      FLOW_DISSECTOR_KEY_GRE_KEYID,
-								      target_container);
-				key_keyid->keyid = *keyid;
+			offset += sizeof(struct gre_base_hdr);
+
+			if (hdr->flags & GRE_CSUM)
+				offset += sizeof(__be32);
+
+			if (hdr->flags & GRE_KEY) {
+				const __be32 *keyid;
+				__be32 _keyid;
+
+				keyid = __skb_header_pointer(skb, nhoff + offset, sizeof(_keyid),
+							     data, hlen, &_keyid);
+
+				if (!keyid)
+					goto out_bad;
+
+				if (dissector_uses_key(flow_dissector,
+						       FLOW_DISSECTOR_KEY_GRE_KEYID)) {
+					key_keyid = skb_flow_dissector_target(flow_dissector,
+									      FLOW_DISSECTOR_KEY_GRE_KEYID,
+									      target_container);
+					key_keyid->keyid = *keyid;
+				}
+				offset += sizeof(_keyid);
 			}
-			nhoff += 4;
-		}
-		if (hdr->flags & GRE_SEQ)
-			nhoff += 4;
-		if (proto == htons(ETH_P_TEB)) {
-			const struct ethhdr *eth;
-			struct ethhdr _eth;
-
-			eth = __skb_header_pointer(skb, nhoff,
-						   sizeof(_eth),
-						   data, hlen, &_eth);
-			if (!eth)
-				goto out_bad;
-			proto = eth->h_proto;
-			nhoff += sizeof(*eth);
-
-			/* Cap headers that we access via pointers at the
-			 * end of the Ethernet header as our maximum alignment
-			 * at that point is only 2 bytes.
-			 */
-			if (NET_IP_ALIGN)
-				hlen = nhoff;
-		}
 
-		key_control->flags |= FLOW_DIS_ENCAPSULATION;
-		if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
-			goto out_good;
+			if (hdr->flags & GRE_SEQ)
+				offset += sizeof(((struct pptp_gre_header *)0)->seq);
+
+			if (hdr->flags & GRE_ACK)
+				offset += sizeof(((struct pptp_gre_header *)0)->ack);
+
+			if (proto == GRE_PROTO_PPP) {
+				u8 _ppp_hdr[PPP_HDRLEN];
+				u8 *ppp_hdr;
+
+				ppp_hdr = skb_header_pointer(skb, nhoff + offset,
+							     sizeof(_ppp_hdr), _ppp_hdr);
+				if (!ppp_hdr)
+					goto out_bad;
+
+				proto = PPP_PROTOCOL(ppp_hdr);
+				if (proto == PPP_IP)
+					proto = htons(ETH_P_IP);
+				else if (proto == PPP_IPV6)
+					proto = htons(ETH_P_IPV6);
+				else
+					break;
+
+				offset += PPP_HDRLEN;
+			} else if (proto == htons(ETH_P_TEB)) {
+				const struct ethhdr *eth;
+				struct ethhdr _eth;
+
+				eth = __skb_header_pointer(skb, nhoff + offset,
+							   sizeof(_eth),
+							   data, hlen, &_eth);
+				if (!eth)
+					goto out_bad;
+				proto = eth->h_proto;
+				offset += sizeof(*eth);
+
+				/* Cap headers that we access via pointers at the
+				 * end of the Ethernet header as our maximum alignment
+				 * at that point is only 2 bytes.
+				 */
+				if (NET_IP_ALIGN)
+					hlen = (nhoff + offset);
+			}
 
-		goto again;
+			nhoff += offset;
+			key_control->flags |= FLOW_DIS_ENCAPSULATION;
+			if (flags & FLOW_DISSECTOR_F_STOP_AT_ENCAP)
+				goto out_good;
+
+			goto again;
+		}
+		break;
 	}
 	case NEXTHDR_HOP:
 	case NEXTHDR_ROUTING:
-- 
1.9.1
