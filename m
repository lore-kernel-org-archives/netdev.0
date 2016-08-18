From: fgao@ikuai8.com
Subject: [PATCH v1 1/2] pptp: Use macro and sizeof instead of literal number
Date: Thu, 18 Aug 2016 12:47:34 +0800
Message-ID: <1471495654-20134-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: xeb@mail.ru, philipp@redfish-solutions.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpbg291.qq.com ([113.108.11.223]:60859 "EHLO smtpbg291.qq.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbcHREto (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Aug 2016 00:49:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Use existing macros like PPP_ADDRESS, SC_COMP_PROT and sizeof fixed
variables instead of original literal number to enhance readbility.

BTW, the original pptp_rcv uses literal number "12" as the param
of pskb_may_pull. Actually the "12" is less than the size of struct
pptp_gre_header. Now use the sizeof(*header) fixes this issue.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 v1: Initial patch

 drivers/net/ppp/pptp.c | 23 ++++++++++++-----------
 1 file changed, 12 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ppp/pptp.c b/drivers/net/ppp/pptp.c
index 1951b10..48c3701 100644
--- a/drivers/net/ppp/pptp.c
+++ b/drivers/net/ppp/pptp.c
@@ -54,6 +54,8 @@ static struct proto pptp_sk_proto __read_mostly;
 static const struct ppp_channel_ops pptp_chan_ops;
 static const struct proto_ops pptp_ops;
 
+static const u8 fixed_ppphdr[2] = {PPP_ALLSTATIONS, PPP_UI};
+
 static struct pppox_sock *lookup_chan(u16 call_id, __be32 s_addr)
 {
 	struct pppox_sock *sock;
@@ -167,7 +169,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 
 	tdev = rt->dst.dev;
 
-	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(*iph) + sizeof(*hdr) + 2;
+	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(*iph) + sizeof(*hdr) + sizeof(fixed_ppphdr);
 
 	if (skb_headroom(skb) < max_headroom || skb_cloned(skb) || skb_shared(skb)) {
 		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
@@ -190,9 +192,9 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 
 	/* Put in the address/control bytes if necessary */
 	if ((opt->ppp_flags & SC_COMP_AC) == 0 || islcp) {
-		data = skb_push(skb, 2);
-		data[0] = PPP_ALLSTATIONS;
-		data[1] = PPP_UI;
+		data = skb_push(skb, sizeof(fixed_ppphdr));
+		data[0] = fixed_ppphdr[0];
+		data[1] = fixed_ppphdr[1];
 	}
 
 	len = skb->len;
@@ -219,8 +221,7 @@ static int pptp_xmit(struct ppp_channel *chan, struct sk_buff *skb)
 	}
 	hdr->payload_len = htons(len);
 
-	/*	Push down and install the IP header. */
-
+	/* Push down and install the IP header. */
 	skb_reset_transport_header(skb);
 	skb_push(skb, sizeof(*iph));
 	skb_reset_network_header(skb);
@@ -319,14 +320,14 @@ static int pptp_rcv_core(struct sock *sk, struct sk_buff *skb)
 allow_packet:
 		skb_pull(skb, headersize);
 
-		if (payload[0] == PPP_ALLSTATIONS && payload[1] == PPP_UI) {
+		if (PPP_ADDRESS(payload) == PPP_ALLSTATIONS && PPP_CONTROL(payload) == PPP_UI) {
 			/* chop off address/control */
 			if (skb->len < 3)
 				goto drop;
-			skb_pull(skb, 2);
+			skb_pull(skb, sizeof(fixed_ppphdr));
 		}
 
-		if ((*skb->data) & 1) {
+		if ((*skb->data) & SC_COMP_PROT) {
 			/* protocol is compressed */
 			skb_push(skb, 1)[0] = 0;
 		}
@@ -351,7 +352,7 @@ static int pptp_rcv(struct sk_buff *skb)
 	if (skb->pkt_type != PACKET_HOST)
 		goto drop;
 
-	if (!pskb_may_pull(skb, 12))
+	if (!pskb_may_pull(skb, sizeof(*header)))
 		goto drop;
 
 	iph = ip_hdr(skb);
@@ -468,7 +469,7 @@ static int pptp_connect(struct socket *sock, struct sockaddr *uservaddr,
 	ip_rt_put(rt);
 	po->chan.mtu -= PPTP_HEADER_OVERHEAD;
 
-	po->chan.hdrlen = 2 + sizeof(struct pptp_gre_header);
+	po->chan.hdrlen = sizeof(fixed_ppphdr) + sizeof(struct pptp_gre_header);
 	error = ppp_register_channel(&po->chan);
 	if (error) {
 		pr_err("PPTP: failed to register PPP channel (%d)\n", error);
-- 
1.9.1
