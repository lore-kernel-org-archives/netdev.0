From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] tcp: fix possible deadlock in tcp_send_fin()
Date: Tue, 21 Apr 2015 18:32:24 -0700
Message-ID: <1429666344.18561.37.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1426807170-19258-1-git-send-email-johunt@akamai.com>
	 <20150320.132029.103306583158863864.davem@davemloft.net>
	 <550C5A98.5040305@akamai.com>
	 <20150324.021050.384709317309031128.davem@davemloft.net>
	 <55110009.4020706@akamai.com>
	 <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	edumazet@google.com, Greg Thelen <gthelen@google.com>,
	David Rientjes <rientjes@google.com>
To: Josh Hunt <johunt@akamai.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f180.google.com ([209.85.216.180]:34304 "EHLO
	mail-qc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753994AbbDVBcr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Apr 2015 21:32:47 -0400
Received: by qcyk17 with SMTP id k17so85938480qcy.1
        for <netdev@vger.kernel.org>; Tue, 21 Apr 2015 18:32:46 -0700 (PDT)
In-Reply-To: <1429661349.18561.23.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Using sk_stream_alloc_skb() in tcp_send_fin() is dangerous in
case a huge process is killed by OOM, and tcp_mem[2] is hit.

To be able to free memory we need to make progress, so this
patch allows FIN packets to not care about tcp_mem[2], if
skb allocation succeeded.

In a follow-up patch, we might abort tcp_send_fin() infinite loop
in case TIF_MEMDIE is set on this thread, as memory allocator
did its best getting extra memory already. 

This patch reverts d22e15371811 ("tcp: fix tcp fin memory accounting")

Fixes: d22e15371811 ("tcp: fix tcp fin memory accounting")
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_output.c |   20 +++++++++++++++++++-
 1 file changed, 19 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index 8c8d7e06b72f..2ade67b7cdb0 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2812,6 +2812,21 @@ begin_fwd:
 	}
 }
 
+/* We allow to exceed memory limits for FIN packets to expedite
+ * connection tear down and (memory) recovery.
+ * Otherwise tcp_send_fin() could loop forever.
+ */
+static void sk_forced_wmem_schedule(struct sock *sk, int size)
+{
+	int amt, status;
+
+	if (size <= sk->sk_forward_alloc)
+		return;
+	amt = sk_mem_pages(size);
+	sk->sk_forward_alloc += amt * SK_MEM_QUANTUM;
+	sk_memory_allocated_add(sk, amt, &status);
+}
+
 /* Send a fin.  The caller locks the socket for us.  This cannot be
  * allowed to fail queueing a FIN frame under any circumstances.
  */
@@ -2834,11 +2849,14 @@ void tcp_send_fin(struct sock *sk)
 	} else {
 		/* Socket is locked, keep trying until memory is available. */
 		for (;;) {
-			skb = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
+			skb = alloc_skb_fclone(MAX_TCP_HEADER,
+					       sk->sk_allocation);
 			if (skb)
 				break;
 			yield();
 		}
+		skb_reserve(skb, MAX_TCP_HEADER);
+		sk_forced_wmem_schedule(sk, skb->truesize);
 		/* FIN eats a sequence byte, write_seq advanced by tcp_queue_skb(). */
 		tcp_init_nondata_skb(skb, tp->write_seq,
 				     TCPHDR_ACK | TCPHDR_FIN);
