From: Florian Westphal <fw@strlen.de>
Subject: [PATCH RFC 13/14] net: tcp: don't assert sock_skb_cb_check_size
Date: Mon,  2 Mar 2015 18:40:27 +0100
Message-ID: <1425318028-26531-14-git-send-email-fw@strlen.de>
References: <1425318028-26531-1-git-send-email-fw@strlen.de>
Cc: Florian Westphal <fw@strlen.de>,
	Eyal Birger <eyal.birger@gmail.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:54121 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754720AbbCBRku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 12:40:50 -0500
In-Reply-To: <1425318028-26531-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Its required fro af_packet and all protocol that make use of

SOCK_SKB_CB(skb)->dropcount

via sock_queue_rcv_skb.

But tcp doesn't seem to do that.  This avoids build failure
with a 44byte sized tcp cb.

Cc: Eyal Birger <eyal.birger@gmail.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 net/ipv4/tcp.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 4b57ea8..9d72a0f 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -3005,11 +3005,12 @@ static void __init tcp_init_mem(void)
 
 void __init tcp_init(void)
 {
+	struct sk_buff *skb = NULL;
 	unsigned long limit;
 	int max_rshare, max_wshare, cnt;
 	unsigned int i;
 
-	sock_skb_cb_check_size(sizeof(struct tcp_skb_cb));
+	BUILD_BUG_ON(sizeof(struct tcp_skb_cb) > sizeof(skb->cb));
 
 	percpu_counter_init(&tcp_sockets_allocated, 0, GFP_KERNEL);
 	percpu_counter_init(&tcp_orphan_count, 0, GFP_KERNEL);
-- 
2.0.5
