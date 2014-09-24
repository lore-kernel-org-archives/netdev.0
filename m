From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: use tcp_flags in tcp_data_queue()
Date: Wed, 24 Sep 2014 03:54:28 -0700
Message-ID: <1411556068.15395.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <08ce1deee03778416354009d6e11ded50e76fc2a.1411554808.git.panweiping3@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: Weiping Pan <panweiping3@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:49623 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751620AbaIXKy0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2014 06:54:26 -0400
Received: by mail-pa0-f53.google.com with SMTP id hz1so8592902pad.40
        for <netdev@vger.kernel.org>; Wed, 24 Sep 2014 03:54:25 -0700 (PDT)
In-Reply-To: <08ce1deee03778416354009d6e11ded50e76fc2a.1411554808.git.panweiping3@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-09-24 at 18:35 +0800, Weiping Pan wrote:
> Follow the idea in commit e11ecddf5128 (tcp: use TCP_SKB_CB(skb)->tcp_flags in
> input path), we can use tcp_flags to avoid cache miss.
> 
> Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> ---
>  net/ipv4/tcp_input.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 13f3da4..85298c9 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4392,7 +4392,7 @@ queue_and_out:
>  		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
>  		if (skb->len)
>  			tcp_event_data_recv(sk, skb);
> -		if (th->fin)
> +		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
>  			tcp_fin(sk);
>  
>  		if (!skb_queue_empty(&tp->out_of_order_queue)) {

I thought of this, but my reasoning was that we needed th anyway, and
th->fin had the same cost.

But thinking more about this, its possible compiler can generate better
code, as tcp_hdr() will only be needed at the very beginning of the
function, and compiler no longer has to keep around th value.

Could you go one step further maybe ?

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index f3f016a15c5a..1a399737802b 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -4344,7 +4344,6 @@ err:
 
 static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 {
-	const struct tcphdr *th = tcp_hdr(skb);
 	struct tcp_sock *tp = tcp_sk(sk);
 	int eaten = -1;
 	bool fragstolen = false;
@@ -4353,7 +4352,7 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
 		goto drop;
 
 	skb_dst_drop(skb);
-	__skb_pull(skb, th->doff * 4);
+	__skb_pull(skb, tcp_hdr(skb)->doff * 4);
 
 	TCP_ECN_accept_cwr(tp, skb);
 
@@ -4397,7 +4396,7 @@ queue_and_out:
 		tp->rcv_nxt = TCP_SKB_CB(skb)->end_seq;
 		if (skb->len)
 			tcp_event_data_recv(sk, skb);
-		if (th->fin)
+		if (TCP_SKB_CB(skb)->tcp_flags & TCPHDR_FIN)
 			tcp_fin(sk);
 
 		if (!skb_queue_empty(&tp->out_of_order_queue)) {
