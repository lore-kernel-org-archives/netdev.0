From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: randomize timestamps on syncookies
Date: Thu, 04 May 2017 18:59:08 -0700
Message-ID: <1493949548.7796.32.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1493935361.7796.29.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170505002456.GH13320@breakpoint.cc>
         <20170505003208.GI13320@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Yuchung Cheng <ycheng@google.com>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:35177 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752457AbdEEB7L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 21:59:11 -0400
Received: by mail-pg0-f65.google.com with SMTP id i63so349386pgd.2
        for <netdev@vger.kernel.org>; Thu, 04 May 2017 18:59:11 -0700 (PDT)
In-Reply-To: <20170505003208.GI13320@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-05-05 at 02:32 +0200, Florian Westphal wrote:
> Florian Westphal <fw@strlen.de> wrote:
> [..]
> > This breaks syncookies w. timestamps; cookie_timestamp_decode() lacks a tsoff
> > for readjustment.
> > 
> > We also need to pass the (recomputed) tsoff to tcp_get_cookie_sock().
> 
> This small delta makes things work for me:
> 

Hi Florian, thanks for looking at this.

One comment :

> diff --git a/net/ipv6/syncookies.c b/net/ipv6/syncookies.c
> index 895ff650db43..eb96825d6340 100644
> --- a/net/ipv6/syncookies.c
> +++ b/net/ipv6/syncookies.c
> @@ -18,6 +18,7 @@
>  #include <linux/random.h>
>  #include <linux/siphash.h>
>  #include <linux/kernel.h>
> +#include <net/secure_seq.h>
>  #include <net/ipv6.h>
>  #include <net/tcp.h>
>  
> @@ -143,6 +144,7 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
>  	int mss;
>  	struct dst_entry *dst;
>  	__u8 rcv_wscale;
> +	u32 tsoff;
>  
>  	if (!sock_net(sk)->ipv4.sysctl_tcp_syncookies || !th->ack || th->rst)
>  		goto out;
> @@ -162,6 +164,12 @@ struct sock *cookie_v6_check(struct sock *sk, struct sk_buff *skb)
>  	memset(&tcp_opt, 0, sizeof(tcp_opt));
>  	tcp_parse_options(skb, &tcp_opt, 0, NULL);
>  
> +	tsoff = 0;
> +	if (tcp_opt.saw_tstamp && tcp_opt.rcv_tsecr) {
> +		tsoff = secure_tcpv6_ts_off(&ip_hdr(skb)->daddr, &ip_hdr(skb)->saddr);

I will use the ipv6_hdr(skb)->daddr.s6_addr32 and
ipv6_hdr(skb)->saddr.s6_addr32 if you agree ;)

> +		tcp_opt.rcv_tsecr -= tsoff;
> +	}
> +

Thanks !
