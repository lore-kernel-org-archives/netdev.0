From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] tcp: clear pfmemalloc on outgoing skb
Date: Thu, 02 Feb 2017 20:40:08 -0800
Message-ID: <1486096808.21871.67.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1485983078-2372-1-git-send-email-jbacik@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S . Miller" <davem@davemloft.net>
To: Josef Bacik <jbacik@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34388 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752230AbdBCEkK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 23:40:10 -0500
Received: by mail-pg0-f66.google.com with SMTP id v184so898022pgv.1
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 20:40:10 -0800 (PST)
In-Reply-To: <1485983078-2372-1-git-send-email-jbacik@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Josef Bacik diagnosed following problem :

   I was seeing random disconnects while testing NBD over loopback.
   This turned out to be because NBD sets pfmemalloc on it's socket,
   however the receiving side is a user space application so does not
   have pfmemalloc set on its socket. This means that
   sk_filter_trim_cap will simply drop this packet, under the
   assumption that the other side will simply retransmit. Well we do
   retransmit, and then the packet is just dropped again for the same
   reason.

It seems the better way to address this problem is to clear pfmemalloc
in the TCP transmit path. pfmemalloc strict control really makes sense
on the receive path. 

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Josef Bacik <jbacik@fb.com>
---
 net/ipv4/tcp_output.c |    7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8ce50dc3ab8cac821b8a2c3e0d31f0aa42f5c9d5..a22545c8917cdc2382717e6176f7bb384e1d91f2 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -966,6 +966,13 @@ static int tcp_transmit_skb(struct sock *sk, struct sk_buff *skb, int clone_it,
 	 */
 	skb->ooo_okay = sk_wmem_alloc_get(sk) < SKB_TRUESIZE(1);
 
+	/* If we had to use memory reserve to allocate this skb,
+	 * this might cause drops if packet is looped back :
+	 * Other socket might not have SOCK_MEMALLOC.
+	 * Packets not looped back do not care about pfmemalloc.
+	 */
+	skb->pfmemalloc = 0;
+
 	skb_push(skb, tcp_header_size);
 	skb_reset_transport_header(skb);
 
