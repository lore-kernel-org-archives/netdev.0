From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH V4 net-next] tun/macvtap: use consume_skb() instead of
 kfree_skb() when needed
Date: Mon, 1 Dec 2014 11:30:19 +0200
Message-ID: <20141201093019.GE15607@redhat.com>
References: <1417423995-4765-1-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1417423995-4765-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 01, 2014 at 04:53:15PM +0800, Jason Wang wrote:
> To be more friendly with drop monitor, we should only call kfree_skb() when
> the packets were dropped and use consume_skb() in other cases.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
> Changes from V3:
> - rebase to net-next.git
> Changes from V2:
> - use unlikely() when necessary
> Changes from V1:
> - check the return value of tun/macvtap_put_user()
> ---
>  drivers/net/macvtap.c | 5 ++++-
>  drivers/net/tun.c     | 5 ++++-
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 22b4cf2..ba1e5db 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -859,7 +859,10 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
>  	}
>  	if (skb) {
>  		ret = macvtap_put_user(q, skb, to);
> -		kfree_skb(skb);
> +		if (unlikely(ret < 0))
> +			kfree_skb(skb);
> +		else
> +			consume_skb(skb);
>  	}
>  	if (!noblock)
>  		finish_wait(sk_sleep(&q->sk), &wait);
> diff --git a/drivers/net/tun.c b/drivers/net/tun.c
> index 6d44da1..9c58286 100644
> --- a/drivers/net/tun.c
> +++ b/drivers/net/tun.c
> @@ -1362,7 +1362,10 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
>  		return 0;
>  
>  	ret = tun_put_user(tun, tfile, skb, to);
> -	kfree_skb(skb);
> +	if (unlikely(ret < 0))
> +		kfree_skb(skb);
> +	else
> +		consume_skb(skb);
>  
>  	return ret;
>  }
> -- 
> 1.9.1
