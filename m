From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: tcp_make_synack() minor changes
Date: Wed, 26 Mar 2014 09:57:19 -0700
Message-ID: <1395853039.12610.217.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:34854 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932095AbaCZQ5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 12:57:21 -0400
Received: by mail-pd0-f176.google.com with SMTP id r10so2116667pdi.35
        for <netdev@vger.kernel.org>; Wed, 26 Mar 2014 09:57:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There is no need to allocate 15 bytes in excess for a SYNACK packet,
as it contains no data, only headers.

SYNACK are always generated in softirq context, and contain a single
segment, we can use TCP_INC_STATS_BH()

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index e0a7b33fe953..3d2124d2cc4a 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2741,7 +2741,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	int tcp_header_size;
 	int mss;
 
-	skb = sock_wmalloc(sk, MAX_TCP_HEADER + 15, 1, GFP_ATOMIC);
+	skb = sock_wmalloc(sk, MAX_TCP_HEADER, 1, GFP_ATOMIC);
 	if (unlikely(!skb)) {
 		dst_release(dst);
 		return NULL;
@@ -2811,7 +2811,7 @@ struct sk_buff *tcp_make_synack(struct sock *sk, struct dst_entry *dst,
 	th->window = htons(min(req->rcv_wnd, 65535U));
 	tcp_options_write((__be32 *)(th + 1), tp, &opts);
 	th->doff = (tcp_header_size >> 2);
-	TCP_ADD_STATS(sock_net(sk), TCP_MIB_OUTSEGS, tcp_skb_pcount(skb));
+	TCP_INC_STATS_BH(sock_net(sk), TCP_MIB_OUTSEGS);
 
 #ifdef CONFIG_TCP_MD5SIG
 	/* Okay, we have all we need - do the md5 hash if needed */
