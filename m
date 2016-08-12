From: fgao@ikuai8.com
Subject: [PATCH v1 1/1] pptp: Refactor the struct and macros of PPTP codes
Date: Sat, 13 Aug 2016 00:30:48 +0800
Message-ID: <1471019448-3336-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, philipp@redfish-solutions.com,
	stephen@networkplumber.org, pshelar@nicira.com,
	tom@herbertland.com, xeb@mail.ru, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg341.qq.com ([14.17.44.36]:57057 "EHLO smtpbg341.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752452AbcHLQbo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Aug 2016 12:31:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

1. Use struct gre_base_hdr directly in pptp_gre_header instead of
duplicated members;
2. Use existing macros like GRE_KEY, GRE_SEQ, and so on instead of
duplicated macros defined by PPTP;
3. Add new macros like GRE_IS_ACK/SEQ and so on instead of
PPTP_GRE_IS_A/S and so on;

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial patch

 drivers/net/ppp/pptp.c         | 28 +++++++++++++---------------
 include/net/pptp.h             | 19 +------------------
 include/uapi/linux/if_tunnel.h | 12 ++++++++++--
 3 files changed, 24 insertions(+), 35 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 3e68dbc..1951b10 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -206,16 +206,14 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	skb_push(skb, header_len);
 	hdr = (struct pptp_gre_header *)(skb->data);
 
-	hdr->flags       = PPTP_GRE_FLAG_K;
-	hdr->ver         = PPTP_GRE_VER;
-	hdr->protocol    = htons(PPTP_GRE_PROTO);
-	hdr->call_id     = htons(opt->dst_addr.call_id);
+	hdr->gre_hd.flags = GRE_KEY | GRE_VERSION_1 | GRE_SEQ;
+	hdr->gre_hd.protocol = GRE_PROTO_PPP;
+	hdr->call_id = htons(opt->dst_addr.call_id);
 
-	hdr->flags      |= PPTP_GRE_FLAG_S;
-	hdr->seq         = htonl(++opt->seq_sent);
+	hdr->seq = htonl(++opt->seq_sent);
 	if (opt->ack_sent != seq_recv)	{
 		/* send ack with this message */
-		hdr->ver |= PPTP_GRE_FLAG_A;
+		hdr->gre_hd.flags |= GRE_ACK;
 		hdr->ack  = htonl(seq_recv);
 		opt->ack_sent = seq_recv;
 	}
@@ -278,7 +276,7 @@ static int pptp_rcv_core(struct sock *sk, struct sk_buff *skb)
 	headersize  = sizeof(*header);
 
 	/* test if acknowledgement present */
-	if (PPTP_GRE_IS_A(header->ver)) {
+	if (GRE_IS_ACK(header->gre_hd.flags)) {
 		__u32 ack;
 
 		if (!pskb_may_pull(skb, headersize))
@@ -286,7 +284,7 @@ static int pptp_rcv_core(struct sock *sk, struct sk_buff *skb)
 		header = (struct pptp_gre_header *)(skb->data);
 
 		/* ack in different place if S = 0 */
-		ack = PPTP_GRE_IS_S(header->flags) ? header->ack : header->seq;
+		ack = GRE_IS_SEQ(header->gre_hd.flags) ? header->ack : header->seq;
 
 		ack = ntohl(ack);
 
@@ -299,7 +297,7 @@ static int pptp_rcv_core(struct sock *sk, struct sk_buff *skb)
 		headersize -= sizeof(header->ack);
 	}
 	/* test if payload present */
-	if (!PPTP_GRE_IS_S(header->flags))
+	if (!GRE_IS_SEQ(header->gre_hd.flags))
 		goto drop;
 
 	payload_len = ntohs(header->payload_len);
@@ -360,11 +358,11 @@ static int pptp_rcv(struct sk_buff *skb)
 
 	header = (struct pptp_gre_header *)skb->data;
 
-	if (ntohs(header->protocol) != PPTP_GRE_PROTO || /* PPTP-GRE protocol for PPTP */
-		PPTP_GRE_IS_C(header->flags) ||                /* flag C should be clear */
-		PPTP_GRE_IS_R(header->flags) ||                /* flag R should be clear */
-		!PPTP_GRE_IS_K(header->flags) ||               /* flag K should be set */
-		(header->flags&0xF) != 0)                      /* routing and recursion ctrl = 0 */
+	if (header->gre_hd.protocol != GRE_PROTO_PPP || /* PPTP-GRE protocol for PPTP */
+		GRE_IS_CSUM(header->gre_hd.flags) ||    /* flag CSUM should be clear */
+		GRE_IS_ROUTING(header->gre_hd.flags) || /* flag ROUTING should be clear */
+		!GRE_IS_KEY(header->gre_hd.flags) ||    /* flag KEY should be set */
+		(header->gre_hd.flags & GRE_FLAGS))     /* flag Recursion Ctrl should be clear */
 		/* if invalid, discard this packet */
 		goto drop;
 
diff --git a/include/net/pptp.h b/include/net/pptp.h
index 301d3e2..92e9f1f 100644
--- a/include/net/pptp.h
+++ b/include/net/pptp.h
@@ -10,26 +10,9 @@
 	((((curseq) & 0xffffff00) == 0) &&\
 	(((lastseq) & 0xffffff00) == 0xffffff00))
 
-#define PPTP_GRE_PROTO  0x880B
-#define PPTP_GRE_VER    0x1
-
-#define PPTP_GRE_FLAG_C 0x80
-#define PPTP_GRE_FLAG_R 0x40
-#define PPTP_GRE_FLAG_K 0x20
-#define PPTP_GRE_FLAG_S 0x10
-#define PPTP_GRE_FLAG_A 0x80
-
-#define PPTP_GRE_IS_C(f) ((f)&PPTP_GRE_FLAG_C)
-#define PPTP_GRE_IS_R(f) ((f)&PPTP_GRE_FLAG_R)
-#define PPTP_GRE_IS_K(f) ((f)&PPTP_GRE_FLAG_K)
-#define PPTP_GRE_IS_S(f) ((f)&PPTP_GRE_FLAG_S)
-#define PPTP_GRE_IS_A(f) ((f)&PPTP_GRE_FLAG_A)
-
 #define PPTP_HEADER_OVERHEAD (2+sizeof(struct pptp_gre_header))
 struct pptp_gre_header {
-	u8  flags;
-	u8  ver;
-	__be16 protocol;
+	struct gre_base_hdr gre_hd;
 	__be16 payload_len;
 	__be16 call_id;
 	__be32 seq;
diff --git a/include/uapi/linux/if_tunnel.h b/include/uapi/linux/if_tunnel.h
index 60dbb20..361b9f0 100644
--- a/include/uapi/linux/if_tunnel.h
+++ b/include/uapi/linux/if_tunnel.h
@@ -28,8 +28,16 @@
 #define GRE_FLAGS	__cpu_to_be16(0x0078)
 #define GRE_VERSION	__cpu_to_be16(0x0007)
 
-#define GRE_VERSION_1	__cpu_to_be16(0x0001)
-#define GRE_PROTO_PPP	__cpu_to_be16(0x880b)
+#define GRE_IS_CSUM(f)		((f) & GRE_CSUM)
+#define GRE_IS_ROUTING(f)	((f) & GRE_ROUTING)
+#define GRE_IS_KEY(f)		((f) & GRE_KEY)
+#define GRE_IS_SEQ(f)		((f) & GRE_SEQ)
+#define GRE_IS_STRICT(f)	((f) & GRE_STRICT)
+#define GRE_IS_REC(f)		((f) & GRE_REC)
+#define GRE_IS_ACK(f)		((f) & GRE_ACK)
+
+#define GRE_VERSION_1		__cpu_to_be16(0x0001)
+#define GRE_PROTO_PPP		__cpu_to_be16(0x880b)
 #define GRE_PPTP_KEY_MASK	__cpu_to_be32(0xffff)
 
 struct ip_tunnel_parm {
-- 
1.9.1
