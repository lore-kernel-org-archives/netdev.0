From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: /proc/net/sockstat invalid memory accounting or memory leak in
 latest kernels? (trying to debug)
Date: Sun, 16 Nov 2014 21:01:36 -0800
Message-ID: <1416200496.24093.5.camel@edumazet-glaptop2.roam.corp.google.com>
References: <40bc2b5fcda47d790f1fd247bc409041@visp.net.lb>
	 <1405597918.10255.76.camel@edumazet-glaptop2.roam.corp.google.com>
	 <37e25a5815a18a2da507a5b20b58427d@visp.net.lb>
	 <1405604568.10255.80.camel@edumazet-glaptop2.roam.corp.google.com>
	 <a927787503c2f0d71c330b879303b14f@visp.net.lb>
	 <1405672897.10255.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1405676214.10255.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0b0b74ab8d2222fa85b23e06c6e992ec@visp.net.lb>
	 <1405849675.10255.100.camel@edumazet-glaptop2.roam.corp.google.com>
	 <6fc086a122bc3ac728a7aec9e812310f@visp.net.lb>
	 <1406016045.10255.122.camel@edumazet-glaptop2.roam.corp.google.com>
	 <3f463c3912608f7959481edaa6d7668d@visp.net.lb>
	 <1406194817.3363.70.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8f138d88e3b850130eb9bb15e3e27069@visp.net.lb>
	 <2adbf5346b4dd2bebe1915096c1c567c@visp.net.lb>
	 <1415813254.17262.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <64ef227cf22945d373cb06271fe6e051@visp.net.lb>
	 <1416161495.17262.90.camel@edumazet-glaptop2.roam.corp.google.com>
	 <8d9b6a2c313db242c1afb3bcd6a12c51@visp.net.lb>
	 <1416168961.17262.96.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>, netdev@vger.kernel.org
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:63963 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750718AbaKQFBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 00:01:34 -0500
Received: by mail-ie0-f176.google.com with SMTP id rd18so20482091iec.7
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 21:01:33 -0800 (PST)
In-Reply-To: <1416168961.17262.96.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-11-16 at 12:16 -0800, Eric Dumazet wrote:

> Thanks Denys !
> 
> Could you try following patch ?
> 
> Thanks !

Hmm.... I have an updated patch, sorry.

(A memcpy_fromiovec() has to be memcpy_fromiovecend() )

diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
index a3d453b94747..c2bbfcd9c0db 100644
--- a/net/ipv4/tcp_output.c
+++ b/net/ipv4/tcp_output.c
@@ -2998,7 +2998,7 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 {
 	struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_fastopen_request *fo = tp->fastopen_req;
-	int syn_loss = 0, space, i, err = 0, iovlen = fo->data->msg_iovlen;
+	int syn_loss = 0, space, err = 0;
 	struct sk_buff *syn_data = NULL, *data;
 	unsigned long last_syn_loss = 0;
 
@@ -3031,25 +3031,19 @@ static int tcp_send_syn_data(struct sock *sk, struct sk_buff *syn)
 	/* limit to order-0 allocations */
 	space = min_t(size_t, space, SKB_MAX_HEAD(MAX_TCP_HEADER));
 
-	syn_data = skb_copy_expand(syn, MAX_TCP_HEADER, space,
-				   sk->sk_allocation);
-	if (syn_data == NULL)
+	syn_data = sk_stream_alloc_skb(sk, space, sk->sk_allocation);
+	if (!syn_data)
 		goto fallback;
 
-	for (i = 0; i < iovlen && syn_data->len < space; ++i) {
-		struct iovec *iov = &fo->data->msg_iov[i];
-		unsigned char __user *from = iov->iov_base;
-		int len = iov->iov_len;
-
-		if (syn_data->len + len > space)
-			len = space - syn_data->len;
-		else if (i + 1 == iovlen)
-			/* No more data pending in inet_wait_for_connect() */
-			fo->data = NULL;
+	syn_data->ip_summed = CHECKSUM_PARTIAL;
+	memcpy(syn_data->cb, syn->cb, sizeof(syn->cb));
+	if (memcpy_fromiovecend(skb_put(syn_data, space),
+				fo->data->msg_iov, 0, space))
+		goto fallback;
 
-		if (skb_add_data(syn_data, from, len))
-			goto fallback;
-	}
+	/* No more data pending in inet_wait_for_connect() */
+	if (space == fo->size)
+		fo->data = NULL;
 
 	/* Queue a data-only packet after the regular SYN for retransmission */
 	data = pskb_copy(syn_data, sk->sk_allocation);
@@ -3101,13 +3095,10 @@ int tcp_connect(struct sock *sk)
 		return 0;
 	}
 
-	buff = alloc_skb_fclone(MAX_TCP_HEADER + 15, sk->sk_allocation);
-	if (unlikely(buff == NULL))
+	buff = sk_stream_alloc_skb(sk, 0, sk->sk_allocation);
+	if (unlikely(!buff))
 		return -ENOBUFS;
 
-	/* Reserve space for headers. */
-	skb_reserve(buff, MAX_TCP_HEADER);
-
 	tcp_init_nondata_skb(buff, tp->write_seq++, TCPHDR_SYN);
 	tp->retrans_stamp = tcp_time_stamp;
 	tcp_connect_queue_skb(sk, buff);
