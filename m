From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: [PATCH net 2/2] dccp: limit sk_filter trim to payload
Date: Tue, 12 Jul 2016 18:18:57 -0400
Message-ID: <1468361937-102786-3-git-send-email-willemdebruijn.kernel@gmail.com>
References: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Cc: alexei.starovoitov@gmail.com, daniel@iogearbox.net,
	davem@davemloft.net, hannes@stressinduktion.org,
	eric.dumazet@gmail.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35433 "EHLO
	mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751879AbcGLWTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2016 18:19:17 -0400
Received: by mail-qk0-f196.google.com with SMTP id q62so1831896qkf.2
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2016 15:19:10 -0700 (PDT)
In-Reply-To: <1468361937-102786-1-git-send-email-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Dccp verifies packet integrity, including length, at initial rcv in
dccp_invalid_packet, later pulls headers in dccp_enqueue_skb.

A call to sk_filter in-between can cause __skb_pull to wrap skb->len.
skb_copy_datagram_msg interprets this as a negative value, so
(correctly) fails with EFAULT. The negative length is reported in
ioctl SIOCINQ or possibly in a DCCP_WARN in dccp_close.

Introduce an sk_receive_skb variant that caps how small a filter
program can trim packets, and call this in dccp with the header
length. Excessively trimmed packets are now processed normally and
queued for reception as 0B payloads.

Fixes: 7c657876b63c ("[DCCP]: Initial implementation")
Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 include/net/sock.h | 8 +++++++-
 net/core/sock.c    | 7 ++++---
 net/dccp/ipv4.c    | 2 +-
 net/dccp/ipv6.c    | 2 +-
 4 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 649d2a8..ff5be7e 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1576,7 +1576,13 @@ static inline void sock_put(struct sock *sk)
  */
 void sock_gen_put(struct sock *sk);
 
-int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested);
+int __sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested,
+		     unsigned int trim_cap);
+static inline int sk_receive_skb(struct sock *sk, struct sk_buff *skb,
+				 const int nested)
+{
+	return __sk_receive_skb(sk, skb, nested, 1);
+}
 
 static inline void sk_tx_queue_set(struct sock *sk, int tx_queue)
 {
diff --git a/net/core/sock.c b/net/core/sock.c
index b7f1263..25dab8b 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -452,11 +452,12 @@ int sock_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
 }
 EXPORT_SYMBOL(sock_queue_rcv_skb);
 
-int sk_receive_skb(struct sock *sk, struct sk_buff *skb, const int nested)
+int __sk_receive_skb(struct sock *sk, struct sk_buff *skb,
+		     const int nested, unsigned int trim_cap)
 {
 	int rc = NET_RX_SUCCESS;
 
-	if (sk_filter(sk, skb))
+	if (sk_filter_trim_cap(sk, skb, trim_cap))
 		goto discard_and_relse;
 
 	skb->dev = NULL;
@@ -492,7 +493,7 @@ discard_and_relse:
 	kfree_skb(skb);
 	goto out;
 }
-EXPORT_SYMBOL(sk_receive_skb);
+EXPORT_SYMBOL(__sk_receive_skb);
 
 struct dst_entry *__sk_dst_check(struct sock *sk, u32 cookie)
 {
diff --git a/net/dccp/ipv4.c b/net/dccp/ipv4.c
index 25dd25b..345a3ae 100644
--- a/net/dccp/ipv4.c
+++ b/net/dccp/ipv4.c
@@ -868,7 +868,7 @@ lookup:
 		goto discard_and_relse;
 	nf_reset(skb);
 
-	return sk_receive_skb(sk, skb, 1);
+	return __sk_receive_skb(sk, skb, 1, dh->dccph_doff * 4);
 
 no_dccp_socket:
 	if (!xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb))
diff --git a/net/dccp/ipv6.c b/net/dccp/ipv6.c
index d176f4e..3ff137d 100644
--- a/net/dccp/ipv6.c
+++ b/net/dccp/ipv6.c
@@ -732,7 +732,7 @@ lookup:
 	if (!xfrm6_policy_check(sk, XFRM_POLICY_IN, skb))
 		goto discard_and_relse;
 
-	return sk_receive_skb(sk, skb, 1) ? -1 : 0;
+	return __sk_receive_skb(sk, skb, 1, dh->dccph_doff * 4) ? -1 : 0;
 
 no_dccp_socket:
 	if (!xfrm6_policy_check(NULL, XFRM_POLICY_IN, skb))
-- 
2.8.0.rc3.226.g39d4020
