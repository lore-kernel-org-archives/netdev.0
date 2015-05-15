From: Jason Baron <jbaron@akamai.com>
Subject: Re: [PATCH net-next 5/6] tcp: allow one skb to be received per socket
 under memory pressure
Date: Fri, 15 May 2015 14:20:50 -0400
Message-ID: <55563902.402@akamai.com>
References: <1431701638-24451-1-git-send-email-edumazet@google.com> <1431701638-24451-6-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Yuchung Cheng <ycheng@google.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from prod-mail-xrelay02.akamai.com ([72.246.2.14]:36194 "EHLO
	prod-mail-xrelay02.akamai.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751221AbbEOSUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 May 2015 14:20:51 -0400
In-Reply-To: <1431701638-24451-6-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2015 10:53 AM, Eric Dumazet wrote:
> While testing tight tcp_mem settings, I found tcp sessions could be
> stuck because we do not allow even one skb to be received on them.
>
> By allowing one skb to be received, we introduce fairness and
> eventuallu force memory hogs to release their allocation.
>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  net/ipv4/tcp_input.c | 10 ++++++----
>  1 file changed, 6 insertions(+), 4 deletions(-)
>
> diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> index 093779f7e893..f6763faf0a60 100644
> --- a/net/ipv4/tcp_input.c
> +++ b/net/ipv4/tcp_input.c
> @@ -4507,10 +4507,12 @@ static void tcp_data_queue(struct sock *sk, struct sk_buff *skb)
>  
>  		if (eaten <= 0) {
>  queue_and_out:
> -			if (eaten < 0 &&
> -			    tcp_try_rmem_schedule(sk, skb, skb->truesize))
> -				goto drop;
> -
> +			if (eaten < 0) {
> +				if (skb_queue_len(&sk->sk_write_queue) == 0)

I'm confused here. Isn't this about the sk->sk_receive_queue being
empty? Maybe a comment to help clarify?

> +					sk_forced_mem_schedule(sk, skb->truesize);
> +				else if (tcp_try_rmem_schedule(sk, skb, skb->truesize))
> +					goto drop;
> +			}
>  			eaten = tcp_queue_rcv(sk, skb, 0, &fragstolen);
>  		}
>  		tcp_rcv_nxt_update(tp, TCP_SKB_CB(skb)->end_seq);


The rest of the patches looked ok to me. Thanks for looking at this!

-Jason
