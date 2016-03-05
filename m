From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH net-next] tcp: Add RFC4898
 tcpEStatsPerfDataSegsOut/In
Date: Fri, 04 Mar 2016 16:33:33 -0800
Message-ID: <1457138013.2761.12.camel@edumazet-ThinkPad-T530>
References: <1457135853-4110588-1-git-send-email-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Kernel Team <kernel-team@fb.com>,
	Chris Rapier <rapier@psc.edu>,
	Eric Dumazet <edumazet@google.com>,
	Marcelo Ricardo Leitner <mleitner@redhat.com>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>
To: Martin KaFai Lau <kafai@fb.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:33455 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759694AbcCEAdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2016 19:33:35 -0500
Received: by mail-pf0-f181.google.com with SMTP id 124so44076950pfg.0
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2016 16:33:35 -0800 (PST)
In-Reply-To: <1457135853-4110588-1-git-send-email-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On ven., 2016-03-04 at 15:57 -0800, Martin KaFai Lau wrote:

> diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
> index 4c8d58d..c9b576f 100644
> --- a/net/ipv4/tcp_ipv4.c
> +++ b/net/ipv4/tcp_ipv4.c
> @@ -1540,6 +1540,7 @@ int tcp_v4_rcv(struct sk_buff *skb)
>  	const struct iphdr *iph;
>  	const struct tcphdr *th;
>  	struct sock *sk;
> +	u16 segs_in;
>  	int ret;
>  	struct net *net = dev_net(skb->dev);
>  
> @@ -1650,7 +1651,11 @@ process:
>  	sk_incoming_cpu_update(sk);
>  
>  	bh_lock_sock_nested(sk);
> -	tcp_sk(sk)->segs_in += max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +	segs_in = max_t(u16, 1, skb_shinfo(skb)->gso_segs);
> +	tcp_sk(sk)->segs_in += segs_in;
> +	if (skb->len > __tcp_hdrlen(th))
> +		tcp_sk(sk)->data_segs_in += segs_in;


It looks like we have a bug if the segment comes for a SYN_RECV request
socket.  (It happens if the ACK packet of the 3WHS was lost)

We do not enter this path in this case.
