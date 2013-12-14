From: Martin Faecknitz <faecknitz@hotsplots.de>
Subject: [PATCH net] bridge: br_handle_local_finish should not return zero
Date: Sat, 14 Dec 2013 21:52:08 +0100
Message-ID: <52ACC4F8.6080703@hotsplots.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.hotsplots.de ([89.238.64.218]:54538 "EHLO mx3.hotsplots.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754059Ab3LNVBQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 14 Dec 2013 16:01:16 -0500
Received: from [192.168.1.102] (p549FC516.dip0.t-ipconnect.de [84.159.197.22])
	by mx3.hotsplots.de (Postfix) with ESMTPSA id 92D8D22464FB
	for <netdev@vger.kernel.org>; Sat, 14 Dec 2013 21:51:43 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

br_handle_local_finish is called by NF_HOOK(...) after accepting the packet. If
the return value of NF_HOOK(...) is zero (i.e. the return value of
br_handle_local_finish), the packet is passed to the network stack. This
behavior conflicts with netfilter hooks which return NF_STOLEN/NF_QUEUE. In this
case, NF_HOOK(...) returns also zero (see nf_hook_slow) but
br_handle_local_finish was never called. The packet will still passed to the
network stack.

Signed-off-by: Martin Faecknitz

--- a/net/bridge/br_input.c
+++ b/net/bridge/br_input.c
@@ -149,7 +149,7 @@ static int br_handle_local_finish(struct sk_buff *skb)
 	br_vlan_get_tag(skb, &vid);
 	if (p->flags & BR_LEARNING)
 		br_fdb_update(p->br, p, eth_hdr(skb)->h_source, vid);
-	return 0;	 /* process further */
+	return 1;	 /* process further */
 }

 /*
@@ -208,7 +208,7 @@ rx_handler_result_t br_handle_frame(struct sk_buff **pskb)

 		/* Deliver packet to local host only */
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
-			    NULL, br_handle_local_finish)) {
+			    NULL, br_handle_local_finish) != 1) {
 			return RX_HANDLER_CONSUMED; /* consumed by filter */
 		} else {
 			*pskb = skb;
