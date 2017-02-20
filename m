From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp: setup random timestamp offset when write_seq
 already set
Date: Mon, 20 Feb 2017 10:18:07 -0500 (EST)
Message-ID: <20170220.101807.883027207624802826.davem@davemloft.net>
References: <1487379372-28199-1-git-send-email-alexey.kodanev@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de, edumazet@google.com
To: alexey.kodanev@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38164 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753106AbdBTPSI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 10:18:08 -0500
In-Reply-To: <1487379372-28199-1-git-send-email-alexey.kodanev@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Kodanev <alexey.kodanev@oracle.com>
Date: Sat, 18 Feb 2017 03:56:11 +0300

> @@ -232,12 +232,17 @@ int tcp_v4_connect(struct sock *sk, struct sockaddr *uaddr, int addr_len)
>  	sk->sk_gso_type = SKB_GSO_TCPV4;
>  	sk_setup_caps(sk, &rt->dst);
>  
> -	if (!tp->write_seq && likely(!tp->repair))
> +	if (!tp->write_seq && likely(!tp->repair)) {
>  		tp->write_seq = secure_tcp_sequence_number(inet->inet_saddr,
>  							   inet->inet_daddr,
>  							   inet->inet_sport,
>  							   usin->sin_port,
>  							   &tp->tsoffset);
> +	} else if (likely(!tp->repair)) {
> +		secure_tcp_sequence_number(inet->inet_saddr, inet->inet_daddr,
> +					   inet->inet_sport, usin->sin_port,
> +					   &tp->tsoffset);
> +	}

This would be so much easier to understand if it were coded as:

	if (!tp->repair) {
		seq = secure_tcp_sequence_number(...);
		if (!tp->write_seq)
			tp->write_seq = seq;
	}
