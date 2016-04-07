From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net-next 2/2] rxrpc: do not pull udp headers on receive
Date: Thu,  7 Apr 2016 11:44:59 -0400
Message-ID: <1460043899-56894-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: davem@davemloft.net, fcooper@ti.com, samanthakumar@google.com,
	Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f66.google.com ([209.85.192.66]:33009 "EHLO
	mail-qg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756683AbcDGPpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 11:45:07 -0400
Received: by mail-qg0-f66.google.com with SMTP id 7so4854521qgj.0
        for <netdev@vger.kernel.org>; Thu, 07 Apr 2016 08:45:06 -0700 (PDT)
In-Reply-To: <1460043899-56894-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Commit e6afc8ace6dd modified the udp receive path by pulling the udp
header before queuing an skbuff onto the receive queue.

Rxrpc also calls skb_recv_datagram to dequeue an skb from a udp
socket. Modify this receive path to also no longer expect udp
headers.

Fixes: e6afc8ace6dd ("udp: remove headers from UDP packets before queueing")

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 net/rxrpc/ar-input.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/rxrpc/ar-input.c b/net/rxrpc/ar-input.c
index 63ed75c..4824a82 100644
--- a/net/rxrpc/ar-input.c
+++ b/net/rxrpc/ar-input.c
@@ -612,9 +612,9 @@ int rxrpc_extract_header(struct rxrpc_skb_priv *sp, struct sk_buff *skb)
 	struct rxrpc_wire_header whdr;
 
 	/* dig out the RxRPC connection details */
-	if (skb_copy_bits(skb, sizeof(struct udphdr), &whdr, sizeof(whdr)) < 0)
+	if (skb_copy_bits(skb, 0, &whdr, sizeof(whdr)) < 0)
 		return -EBADMSG;
-	if (!pskb_pull(skb, sizeof(struct udphdr) + sizeof(whdr)))
+	if (!pskb_pull(skb, sizeof(whdr)))
 		BUG();
 
 	memset(sp, 0, sizeof(*sp));
-- 
2.8.0.rc3.226.g39d4020
