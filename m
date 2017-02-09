From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net] udp: fix a potential panic in first_packet_length()
Date: Thu, 09 Feb 2017 18:01:18 +0100
Message-ID: <1486659678.2591.11.camel@redhat.com>
References: <1486654229.7793.100.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>,
        Andrey Konovalov <andreyknvl@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:37424 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752003AbdBIRB4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 9 Feb 2017 12:01:56 -0500
In-Reply-To: <1486654229.7793.100.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2017-02-09 at 07:30 -0800, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> first_packet_length() is called from udp_ioctl()
> 
> udp_ioctl(), as its name suggests, is used by UDP protocols,
> but is also used by L2TP :(
> 
> We shall call udp_rmem_release() only for UDP variants.
> 
> Thanks to Andrey and syzkaller team for providing the report
> and a nice reproducer.
> 
> Fixes: 7c13f97ffde63 ("udp: do fwd memory scheduling on dequeue")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Andrey Konovalov <andreyknvl@google.com>
> ---
>  net/ipv4/udp.c |    6 +++++-
>  1 file changed, 5 insertions(+), 1 deletion(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 8aab7d78d25bc6eaa42dcc960cdbd5086f614cad..7c0807ee82cec6ca8c856da14fa6109dfdf27868 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1376,7 +1376,11 @@ static int first_packet_length(struct sock *sk)
>  		kfree_skb(skb);
>  	}
>  	res = skb ? skb->len : -1;
> -	if (total)
> +	/* udp_ioctl() can be used by UDP/UDPLite, but also L2TP.
> +	 * We only need to call udp_rmem_release() for UDP sockets.
> +	 * L2TP does have a proper skb destructor invoked at kfree_skb() time.
> +	 */
> +	if (total && sk->sk_prot->memory_allocated == &udp_memory_allocated)
>  		udp_rmem_release(sk, total, 1);
>  	spin_unlock_bh(&rcvq->lock);
>  	return res;
> 
> 

My bad, I missed completely that call path.

I'm wondering if calling first_packet_length() for l2tp_ip sockets
makes sense ?!? Am I missing something or it touches udp stats and
checks udp csum for non udp packets ?!?

Paolo
