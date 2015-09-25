From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 15/17] dccp: constify dccp_make_response() socket argument
Date: Fri, 25 Sep 2015 07:39:22 -0700
Message-ID: <1443191964-923-16-git-send-email-edumazet@google.com>
References: <1443191964-923-1-git-send-email-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Eric Dumazet <edumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36813 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932113AbbIYOkl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 10:40:41 -0400
Received: by pablk4 with SMTP id lk4so10835819pab.3
        for <netdev@vger.kernel.org>; Fri, 25 Sep 2015 07:40:41 -0700 (PDT)
In-Reply-To: <1443191964-923-1-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Like tcp_make_synack() the only time we might change the socket is
when calling sock_wmalloc(), which is using atomic operation to
update sk->sk_wmem_alloc

Also use MAX_DCCP_HEADER as both IPv4/IPv6 use this value for max_header.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/dccp/dccp.h   |  2 +-
 net/dccp/output.c | 17 +++++++++++------
 2 files changed, 12 insertions(+), 7 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index bebc735f5afc..31e96df500d1 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -293,7 +293,7 @@ int dccp_init_sock(struct sock *sk, const __u8 ctl_sock_initialized);
 void dccp_destroy_sock(struct sock *sk);
 
 void dccp_close(struct sock *sk, long timeout);
-struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
+struct sk_buff *dccp_make_response(const struct sock *sk, struct dst_entry *dst,
 				   struct request_sock *req);
 
 int dccp_connect(struct sock *sk);
diff --git a/net/dccp/output.c b/net/dccp/output.c
index 0248e8a3460c..4ce912e691d0 100644
--- a/net/dccp/output.c
+++ b/net/dccp/output.c
@@ -390,7 +390,7 @@ int dccp_retransmit_skb(struct sock *sk)
 	return dccp_transmit_skb(sk, skb_clone(sk->sk_send_head, GFP_ATOMIC));
 }
 
-struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
+struct sk_buff *dccp_make_response(const struct sock *sk, struct dst_entry *dst,
 				   struct request_sock *req)
 {
 	struct dccp_hdr *dh;
@@ -398,13 +398,18 @@ struct sk_buff *dccp_make_response(struct sock *sk, struct dst_entry *dst,
 	const u32 dccp_header_size = sizeof(struct dccp_hdr) +
 				     sizeof(struct dccp_hdr_ext) +
 				     sizeof(struct dccp_hdr_response);
-	struct sk_buff *skb = sock_wmalloc(sk, sk->sk_prot->max_header, 1,
-					   GFP_ATOMIC);
-	if (skb == NULL)
+	struct sk_buff *skb;
+
+	/* sk is marked const to clearly express we dont hold socket lock.
+	 * sock_wmalloc() will atomically change sk->sk_wmem_alloc,
+	 * it is safe to promote sk to non const.
+	 */
+	skb = sock_wmalloc((struct sock *)sk, MAX_DCCP_HEADER, 1,
+			   GFP_ATOMIC);
+	if (!skb)
 		return NULL;
 
-	/* Reserve space for headers. */
-	skb_reserve(skb, sk->sk_prot->max_header);
+	skb_reserve(skb, MAX_DCCP_HEADER);
 
 	skb_dst_set(skb, dst_clone(dst));
 
-- 
2.6.0.rc2.230.g3dd15c0
