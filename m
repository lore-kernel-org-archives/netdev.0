From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: introduce SO_INCOMING_CPU
Date: Mon, 10 Nov 2014 15:51:21 -0800
Message-ID: <1415663481.9613.18.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1415393472.13896.119.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141110.150826.1917858055737674539.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ycai@google.com, willemb@google.com,
	ncardwell@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:59675 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbaKJXvX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Nov 2014 18:51:23 -0500
Received: by mail-ig0-f178.google.com with SMTP id a13so33801igq.11
        for <netdev@vger.kernel.org>; Mon, 10 Nov 2014 15:51:23 -0800 (PST)
In-Reply-To: <20141110.150826.1917858055737674539.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-11-10 at 15:08 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 07 Nov 2014 12:51:12 -0800
> 
> > @@ -1455,6 +1455,7 @@ process:
> >  		goto discard_and_relse;
> >  
> >  	sk_mark_napi_id(sk, skb);
> > +	sk_incoming_cpu_update(sk);
> 
> Just make sk_mark_napi_id() call sk_incoming_cpu_update().
> 
> You've matched up the calls precisely in this patch, and I can't think
> of any situation where we'd add a sk_mark_napi_call() not not want to
> do an sk_incoming_cpu_update().

I believe this was a coincidence.

In fact some sk_mark_napi_id() calls are not at the right place.
It makes little sense to change sk->sk_napi_id for a listener socket.

sk_mark_napi_id() should better be done [1] at the same time we call
sock_rps_save_rxhash

But we need to store cpu before prequeue or backlog (as I did in my
patch)


[1]

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 9c7d7621466b1241f404a5ca11de809dcff2d02a..f10438ac9c0a4013a8a812b64d94e1cf6dfbd83e 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1429,6 +1429,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 		struct dst_entry *dst = sk->sk_rx_dst;
 
 		sock_rps_save_rxhash(sk, skb);
+		sk_mark_napi_id(sk, skb);
 		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, 0) == NULL) {
@@ -1450,6 +1451,7 @@ int tcp_v4_do_rcv(struct sock *sk, struct sk_buff *skb)
 
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
+			sk_mark_napi_id(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb)) {
 				rsk = nsk;
 				goto reset;
@@ -1661,7 +1663,6 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_mark_napi_id(sk, skb);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index ace29b60813cf8a1d7182ad2262cbcbd21810fa7..a83eaff0d936677ef71e8f9f9cd0509cb023b45d 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -1293,6 +1293,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		struct dst_entry *dst = sk->sk_rx_dst;
 
 		sock_rps_save_rxhash(sk, skb);
+		sk_mark_napi_id(sk, skb);
 		if (dst) {
 			if (inet_sk(sk)->rx_dst_ifindex != skb->skb_iif ||
 			    dst->ops->check(dst, np->rx_dst_cookie) == NULL) {
@@ -1322,6 +1323,7 @@ static int tcp_v6_do_rcv(struct sock *sk, struct sk_buff *skb)
 		 */
 		if (nsk != sk) {
 			sock_rps_save_rxhash(nsk, skb);
+			sk_mark_napi_id(nsk, skb);
 			if (tcp_child_process(sk, nsk, skb))
 				goto reset;
 			if (opt_skb)
@@ -1454,7 +1456,6 @@ process:
 	if (sk_filter(sk, skb))
 		goto discard_and_relse;
 
-	sk_mark_napi_id(sk, skb);
 	skb->dev = NULL;
 
 	bh_lock_sock_nested(sk);
