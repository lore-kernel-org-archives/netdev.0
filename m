From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH v2 net-next] af_unix: reduce high order page allocations
Date: Tue, 03 Apr 2012 17:28:28 +0200
Message-ID: <1333466908.18626.274.camel@edumazet-glaptop>
References: <201204022201.41808.remi@remlab.net>
	 <20120402.174006.70116829696492189.davem@davemloft.net>
	 <1333417997.18626.1.camel@edumazet-glaptop>
	 <20120402.215911.1929019308299701014.davem@davemloft.net>
	 <1333419304.18626.5.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:49168 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753843Ab2DCP2c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 11:28:32 -0400
Received: by eaaq12 with SMTP id q12so1282906eaa.19
        for <netdev@vger.kernel.org>; Tue, 03 Apr 2012 08:28:31 -0700 (PDT)
In-Reply-To: <1333419304.18626.5.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

unix_dgram_sendmsg() currently builds linear skbs, and this can stress
page allocator with high order page allocations. When memory gets
fragmented, this can eventually fail.

We can try to use order-2 allocations for skb head (SKB_MAX_ALLOC) plus
up to 16 page fragments to lower pressure on buddy allocator.

This patch has no effect on messages of less than 16064 bytes.
(on 64bit arches with PAGE_SIZE=4096)

For bigger messages (from 16065 to 81600 bytes), this patch brings
reliability at the expense of performance penalty because of extra pages
allocations.

netperf -t DG_STREAM -T 0,2 -- -m 16064 -s 200000
->4086040 Messages / 10s

netperf -t DG_STREAM -T 0,2 -- -m 16068 -s 200000
->3901747 Messages / 10s

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
v2: use SKB_MAX_ALLOC instead of SKB_MAX_ORDER(0, 0) to not slow down
    applications using up to 16000 bytes messages.

 net/unix/af_unix.c |   15 ++++++++++++---
 1 file changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index d510353..eadb902 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -1442,6 +1442,7 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	long timeo;
 	struct scm_cookie tmp_scm;
 	int max_level;
+	int data_len = 0;
 
 	if (NULL == siocb->scm)
 		siocb->scm = &tmp_scm;
@@ -1475,7 +1476,13 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	if (len > sk->sk_sndbuf - 32)
 		goto out;
 
-	skb = sock_alloc_send_skb(sk, len, msg->msg_flags&MSG_DONTWAIT, &err);
+	if (len > SKB_MAX_ALLOC)
+		data_len = min_t(size_t,
+				 len - SKB_MAX_ALLOC,
+				 MAX_SKB_FRAGS * PAGE_SIZE);
+
+	skb = sock_alloc_send_pskb(sk, len - data_len, data_len,
+				   msg->msg_flags & MSG_DONTWAIT, &err);
 	if (skb == NULL)
 		goto out;
 
@@ -1485,8 +1492,10 @@ static int unix_dgram_sendmsg(struct kiocb *kiocb, struct socket *sock,
 	max_level = err + 1;
 	unix_get_secdata(siocb->scm, skb);
 
-	skb_reset_transport_header(skb);
-	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
+	skb_put(skb, len - data_len);
+	skb->data_len = data_len;
+	skb->len = len;
+	err = skb_copy_datagram_from_iovec(skb, 0, msg->msg_iov, 0, len);
 	if (err)
 		goto out_free;
 
