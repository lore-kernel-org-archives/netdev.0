From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] vmxnet3: cleanup tso headers manipulation
Date: Wed, 25 Jan 2012 06:47:21 +0100
Message-ID: <1327470441.14373.37.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Shreyas Bhatewara <sbhatewara@vmware.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62966 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751610Ab2AYFrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2012 00:47:24 -0500
Received: by werb13 with SMTP id b13so3521835wer.19
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2012 21:47:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use existing helpers to clarify skb headers manipulation.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Shreyas Bhatewara <sbhatewara@vmware.com>
---
 drivers/net/vmxnet3/vmxnet3_drv.c |   22 +++++++++++-----------
 1 file changed, 11 insertions(+), 11 deletions(-)

diff --git a/drivers/net/vmxnet3/vmxnet3_drv.c b/drivers/net/vmxnet3/vmxnet3_drv.c
index de7fc34..be6aa35 100644
--- a/drivers/net/vmxnet3/vmxnet3_drv.c
+++ b/drivers/net/vmxnet3/vmxnet3_drv.c
@@ -816,27 +816,24 @@ vmxnet3_parse_and_copy_hdr(struct sk_buff *skb, struct vmxnet3_tx_queue *tq,
 
 	if (ctx->mss) {	/* TSO */
 		ctx->eth_ip_hdr_size = skb_transport_offset(skb);
-		ctx->l4_hdr_size = ((struct tcphdr *)
-				   skb_transport_header(skb))->doff * 4;
+		ctx->l4_hdr_size = tcp_hdrlen(skb);
 		ctx->copy_size = ctx->eth_ip_hdr_size + ctx->l4_hdr_size;
 	} else {
 		if (skb->ip_summed == CHECKSUM_PARTIAL) {
 			ctx->eth_ip_hdr_size = skb_checksum_start_offset(skb);
 
 			if (ctx->ipv4) {
-				struct iphdr *iph = (struct iphdr *)
-						    skb_network_header(skb);
+				const struct iphdr *iph = ip_hdr(skb);
+
 				if (iph->protocol == IPPROTO_TCP)
-					ctx->l4_hdr_size = ((struct tcphdr *)
-					   skb_transport_header(skb))->doff * 4;
+					ctx->l4_hdr_size = tcp_hdrlen(skb);
 				else if (iph->protocol == IPPROTO_UDP)
 					/*
 					 * Use tcp header size so that bytes to
 					 * be copied are more than required by
 					 * the device.
 					 */
-					ctx->l4_hdr_size =
-							sizeof(struct tcphdr);
+					ctx->l4_hdr_size = sizeof(struct tcphdr);
 				else
 					ctx->l4_hdr_size = 0;
 			} else {
@@ -881,14 +878,17 @@ static void
 vmxnet3_prepare_tso(struct sk_buff *skb,
 		    struct vmxnet3_tx_ctx *ctx)
 {
-	struct tcphdr *tcph = (struct tcphdr *)skb_transport_header(skb);
+	struct tcphdr *tcph = tcp_hdr(skb);
+
 	if (ctx->ipv4) {
-		struct iphdr *iph = (struct iphdr *)skb_network_header(skb);
+		struct iphdr *iph = ip_hdr(skb);
+
 		iph->check = 0;
 		tcph->check = ~csum_tcpudp_magic(iph->saddr, iph->daddr, 0,
 						 IPPROTO_TCP, 0);
 	} else {
-		struct ipv6hdr *iph = (struct ipv6hdr *)skb_network_header(skb);
+		struct ipv6hdr *iph = ipv6_hdr(skb);
+
 		tcph->check = ~csum_ipv6_magic(&iph->saddr, &iph->daddr, 0,
 					       IPPROTO_TCP, 0);
 	}
