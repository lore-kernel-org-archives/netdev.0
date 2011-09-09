From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] af_unix: use fragments in unix_dgram_sendmsg()
Date: Fri, 09 Sep 2011 16:38:29 +0200
Message-ID: <1315579109.2294.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Andi Kleen <ak@linux.intel.com>,
	Tim Chen <tim.c.chen@linux.intel.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:65152 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758950Ab1IIOiY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Sep 2011 10:38:24 -0400
Received: by wyh22 with SMTP id 22so1630670wyh.19
        for <netdev@vger.kernel.org>; Fri, 09 Sep 2011 07:38:23 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_dgram_sendmsg() currently builds basic skbs, with a possible huge
head.

This patch uses up to MAX_SKB_FRAGS fragments to reduce the head size.

This lowers memory pressure on high order LOWMEM pages
(frags pages can be allocated from HIGHMEM).

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/unix/af_unix.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 1bd4ecf..58570f5 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1420,6 +1420,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	long timeo;
 	struct scm_cookie tmp_scm;
 	int max_level;
+	int fragslen = 0;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1453,18 +1454,28 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 
-	skb = sock_alloc_send_skb(sk, len, msg->msg_flags&MSG_DONTWAIT, &err);
+	/* try to use fragments to get order-0 header allocation */
+	if (len > SKB_MAX_ORDER(0, 0))
+		fragslen = min_t(size_t,
+				 len - SKB_MAX_ORDER(0, 0),
+				 MAX_SKB_FRAGS * PAGE_SIZE);
+
+	skb = sock_alloc_send_pskb(sk, len - fragslen, fragslen,
+				   msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out;
 
+	skb_put(skb, len - fragslen);
+	skb->data_len = fragslen;
+	skb->len = len;
+
 	err = unix_scm_to_skb(siocb->scm, skb, true, true);
 	if (err < 0)
 		goto out_free;
 	max_level = err + 1;
 	unix_get_secdata(siocb->scm, skb);
 
-	skb_reset_transport_header(skb);
-	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov, 0, len);
 	if (err)
 		goto out_free;
 
