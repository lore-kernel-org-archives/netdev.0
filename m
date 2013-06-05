From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [net-next rfc V3 2/9] macvtap: do not add self to waitqueue if
 doing a nonblock read
Date: Wed, 5 Jun 2013 14:07:22 +0300
Message-ID: <20130605110722.GK31830@redhat.com>
References: <1370414192-5830-1-git-send-email-jasowang@redhat.com>
 <1370414192-5830-3-git-send-email-jasowang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1370414192-5830-3-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 05, 2013 at 02:36:25PM +0800, Jason Wang wrote:
> There's no need to add self to waitqueue if doing a nonblock read. This could
> help to avoid the spinlock contention.
> 
> Signed-off-by: Jason Wang <jasowang@redhat.com>

Acked-by: Michael S. Tsirkin <mst@redhat.com>

> ---
>  drivers/net/macvtap.c |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
> index 5e485e3..8949631 100644
> --- a/drivers/net/macvtap.c
> +++ b/drivers/net/macvtap.c
> @@ -845,7 +845,9 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
>  	ssize_t ret = 0;
>  
>  	while (len) {
> -		prepare_to_wait(sk_sleep(&q->sk), &wait, TASK_INTERRUPTIBLE);
> +		if (!noblock)
> +			prepare_to_wait(sk_sleep(&q->sk), &wait,
> +					TASK_INTERRUPTIBLE);
>  
>  		/* Read frames from the queue */
>  		skb = skb_dequeue(&q->sk.sk_receive_queue);
> @@ -867,7 +869,8 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
>  		break;
>  	}
>  
> -	finish_wait(sk_sleep(&q->sk), &wait);
> +	if (!noblock)
> +		finish_wait(sk_sleep(&q->sk), &wait);
>  	return ret;
>  }
>  
> -- 
> 1.7.1
