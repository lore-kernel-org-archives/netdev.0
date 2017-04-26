From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 02/10] tcp: do not pass timestamp to
 tcp_rack_detect_loss()
Date: Wed, 26 Apr 2017 16:03:14 -0700
Message-ID: <1493247794.6453.90.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170425171541.3417-1-edumazet@google.com>
         <20170425171541.3417-3-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Soheil Hassas Yeganeh <soheil@google.com>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:33986 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1032470AbdDZXDR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 19:03:17 -0400
Received: by mail-pf0-f194.google.com with SMTP id g23so3445615pfj.1
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 16:03:17 -0700 (PDT)
In-Reply-To: <20170425171541.3417-3-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-04-25 at 10:15 -0700, Eric Dumazet wrote:
> We can use tp->tcp_mstamp as it contains a recent timestamp.
> 

> @@ -165,12 +164,10 @@ void tcp_rack_advance(struct tcp_sock *tp, u8 sacked, u32 end_seq,
>  void tcp_rack_reo_timeout(struct sock *sk)
>  {
>  	struct tcp_sock *tp = tcp_sk(sk);
> -	struct skb_mstamp now;
>  	u32 timeout, prior_inflight;
>  
> -	skb_mstamp_get(&now);

Oh this is silly, a timer event is not updating tp->tcp_mstamp yet.

I will provide a patch, after tests.

>  	prior_inflight = tcp_packets_in_flight(tp);
> -	tcp_rack_detect_loss(sk, &now, &timeout);
> +	tcp_rack_detect_loss(sk, &timeout);
>  	if (prior_inflight != tcp_packets_in_flight(tp)) {
>  		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Recovery) {
>  			tcp_enter_recovery(sk, false);

Something like :

diff --git a/net/ipv4/tcp_recovery.c b/net/ipv4/tcp_recovery.c
index fdac262e277b2f25492f155bbb295d6d87e31d02..75096becac21f09fd14466b5f87dffe5820325b5 100644
--- a/net/ipv4/tcp_recovery.c
+++ b/net/ipv4/tcp_recovery.c
@@ -167,6 +167,7 @@ void tcp_rack_reo_timeout(struct sock *sk)
 	u32 timeout, prior_inflight;
 
 	prior_inflight = tcp_packets_in_flight(tp);
+	skb_mstamp_get(&tp->tcp_mstamp);
 	tcp_rack_detect_loss(sk, &timeout);
 	if (prior_inflight != tcp_packets_in_flight(tp)) {
 		if (inet_csk(sk)->icsk_ca_state != TCP_CA_Recovery) {
