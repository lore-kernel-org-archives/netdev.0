From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [4.9.13] use after free in ipv4_mtu
Date: Thu, 02 Mar 2017 05:28:01 -0800
Message-ID: <1488461281.9415.327.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAMVG2ssDe2NMOZzeTF77H1zEEh3dBuT75bS6f81Tqd+3v_4J+g@mail.gmail.com>
         <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>,
        Stephen Hemminger <shemminger@vyatta.com>
To: Daniel J Blueman <daniel@quora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:36766 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751229AbdCBN7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Mar 2017 08:59:50 -0500
Received: by mail-pg0-f65.google.com with SMTP id 25so9426813pgy.3
        for <netdev@vger.kernel.org>; Thu, 02 Mar 2017 05:58:08 -0800 (PST)
In-Reply-To: <1488460104.9415.325.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-03-02 at 05:08 -0800, Eric Dumazet wrote:

> Thanks for the report !
> 
> This patch should solve this precise issue, but we need more work.
> 
> We need to audit all __sk_dst_get() and make sure they are inside an
> rcu_read_lock()/rcu_read_unlock() section.
> 
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 22548b5f05cbe5a655e0c53df2d31c5cc2e8a702..517963e1cb6eb9d70fcd71f44262813c3378759f 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -1459,7 +1459,7 @@ EXPORT_SYMBOL(tcp_sync_mss);
>  unsigned int tcp_current_mss(struct sock *sk)
>  {
>  	const struct tcp_sock *tp = tcp_sk(sk);
> -	const struct dst_entry *dst = __sk_dst_get(sk);
> +	const struct dst_entry *dst;
>  	u32 mss_now;
>  	unsigned int header_len;
>  	struct tcp_out_options opts;
> @@ -1467,11 +1467,14 @@ unsigned int tcp_current_mss(struct sock *sk)
>  
>  	mss_now = tp->mss_cache;
>  
> +	rcu_read_lock();
> +	dst = __sk_dst_get(sk);
>  	if (dst) {
>  		u32 mtu = dst_mtu(dst);
>  		if (mtu != inet_csk(sk)->icsk_pmtu_cookie)
>  			mss_now = tcp_sync_mss(sk, mtu);
>  	}
> +	rcu_read_unlock();
>  
>  	header_len = tcp_established_options(sk, NULL, &opts, &md5) +
>  		     sizeof(struct tcphdr);
> 

Normally TCP sockets sk_dst_cache can only be changed if the thread
doing the change owns the socket.

I have not yet understood which point was breaking the rule yet.
