From: akpm@osdl.org
Subject: [patch 2/9] IPv6/DCCP: fix memory leak in dccp_v6_do_rcv()
Date: Fri, 20 Oct 2006 14:43:02 -0700
Message-ID: <200610202143.k9KLh25B003765@shell0.pdx.osdl.net>
Cc: netdev@vger.kernel.org, akpm@osdl.org, jesper.juhl@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35460 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S2992761AbWJTVnT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Oct 2006 17:43:19 -0400
To: davem@davemloft.net
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jesper Juhl <jesper.juhl@gmail.com>

Coverity found what looks like a real leak in
net/dccp/ipv6.c::dccp_v6_do_rcv()

We may leave via the return inside "if (sk->sk_state == DCCP_OPEN) {" but
at that point we may have allocated opt_skb, but we never free it in that
path before the return.

(akpm: does opt_skb actually do anything?)

Signed-off-by: Jesper Juhl <jesper.juhl@gmail.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 net/dccp/ipv6.c |    9 ++++-----
 1 files changed, 4 insertions(+), 5 deletions(-)

diff -puN net/dccp/ipv6.c~ipv6-dccp-fix-memory-leak-in-dccp_v6_do_rcv net/dccp/ipv6.c
--- a/net/dccp/ipv6.c~ipv6-dccp-fix-memory-leak-in-dccp_v6_do_rcv
+++ a/net/dccp/ipv6.c
@@ -997,7 +997,7 @@ static int dccp_v6_do_rcv(struct sock *s
 	if (sk->sk_state == DCCP_OPEN) { /* Fast path */
 		if (dccp_rcv_established(sk, skb, dccp_hdr(skb), skb->len))
 			goto reset;
-		return 0;
+		goto out;
 	}
 
 	if (sk->sk_state == DCCP_LISTEN) {
@@ -1013,9 +1013,7 @@ static int dccp_v6_do_rcv(struct sock *s
  		if (nsk != sk) {
 			if (dccp_child_process(sk, nsk, skb))
 				goto reset;
-			if (opt_skb != NULL)
-				__kfree_skb(opt_skb);
-			return 0;
+			goto out;
 		}
 	}
 
@@ -1026,9 +1024,10 @@ static int dccp_v6_do_rcv(struct sock *s
 reset:
 	dccp_v6_ctl_send_reset(skb);
 discard:
+	kfree_skb(skb);
+out:
 	if (opt_skb != NULL)
 		__kfree_skb(opt_skb);
-	kfree_skb(skb);
 	return 0;
 }
 
_
