From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net] dccp: fix memory leak during tear-down of unsuccessful connection request
Date: Mon, 13 Mar 2017 00:01:30 +0100
Message-ID: <20170312230130.5013-1-hannes@stressinduktion.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:40126 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1755789AbdCLXBf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 12 Mar 2017 19:01:35 -0400
Received: from compute7.internal (compute7.nyi.internal [10.202.2.47])
        by mailout.nyi.internal (Postfix) with ESMTP id DBF6F2067F
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:33 -0400 (EDT)
Received: from m.localhost.localhost (unknown [213.55.211.72])
        by mail.messagingengine.com (Postfix) with ESMTPA id F35482423E
        for <netdev@vger.kernel.org>; Sun, 12 Mar 2017 19:01:32 -0400 (EDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes a memory leak, which happens if the connection request
is not fulfilled between parsing the DCCP options and handling the SYN
(because e.g. the backlog is full), because we forgot to free the
list of ack vectors.

Reported-by: Jianwen Ji <jiji@redhat.com>
Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/dccp/ccids/ccid2.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/dccp/ccids/ccid2.c b/net/dccp/ccids/ccid2.c
index f053198e730c48..5e3a7302f7747e 100644
--- a/net/dccp/ccids/ccid2.c
+++ b/net/dccp/ccids/ccid2.c
@@ -749,6 +749,7 @@ static void ccid2_hc_tx_exit(struct sock *sk)
 	for (i = 0; i < hc->tx_seqbufc; i++)
 		kfree(hc->tx_seqbuf[i]);
 	hc->tx_seqbufc = 0;
+	dccp_ackvec_parsed_cleanup(&hc->tx_av_chunks);
 }
 
 static void ccid2_hc_rx_packet_recv(struct sock *sk, struct sk_buff *skb)
-- 
2.9.3
