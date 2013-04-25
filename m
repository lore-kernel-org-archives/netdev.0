From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net 2/3] unix/dgram: fix peeking with an offset larger
 than data in queue
Date: Thu, 25 Apr 2013 11:58:23 -0700
Message-ID: <1366916303.8964.174.camel@edumazet-glaptop>
References: <1366897638-21882-1-git-send-email-bpoirier@suse.de>
	 <1366897638-21882-2-git-send-email-bpoirier@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Pavel Emelyanov <xemul@parallels.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Benjamin Poirier <bpoirier@suse.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1366897638-21882-2-git-send-email-bpoirier@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-04-25 at 09:47 -0400, Benjamin Poirier wrote:
> Currently, peeking on a unix datagram socket with an offset larger than len of
> the data in the sk receive queue returns immediately with bogus data. That's
> because *off is not reset between each skb_queue_walk().
> 
> This patch fixes this so that the behavior is the same as peeking with no
> offset on an empty queue: the caller blocks.
> 
> Signed-off-by: Benjamin Poirier <bpoirier@suse.de>
> ---
>  net/core/datagram.c |   25 +++++++++++++++----------
>  1 file changed, 15 insertions(+), 10 deletions(-)
> 
> diff --git a/net/core/datagram.c b/net/core/datagram.c
> index 02398ae..6c502b5 100644
> --- a/net/core/datagram.c
> +++ b/net/core/datagram.c
> @@ -78,9 +78,10 @@ static int receiver_wake_function(wait_queue_t *wait, unsigned int mode, int syn
>  	return autoremove_wake_function(wait, mode, sync, key);
>  }
>  /*
> - * Wait for a packet..
> + * Wait for the last received packet to be different from skb
>   */
> -static int wait_for_packet(struct sock *sk, int *err, long *timeo_p)
> +static int wait_for_more_packets(struct sock *sk, int *err, long *timeo_p,
> +				 struct sk_buff *skb)

const struct sk_buff *skb

>  {
>  	int error;
>  	DEFINE_WAIT_FUNC(wait, receiver_wake_function);
> @@ -92,7 +93,7 @@ static int wait_for_packet(struct sock *sk, int *err, long *timeo_p)
>  	if (error)
>  		goto out_err;
>  
> -	if (!skb_queue_empty(&sk->sk_receive_queue))
> +	if ((struct sk_buff *)sk->sk_receive_queue.prev != skb)

Why is the cast needed ?

>  		goto out;
>  
>  	/* Socket shut down? */
> @@ -131,9 +132,9 @@ out_noerr:
>   *	__skb_recv_datagram - Receive a datagram skbuff
>   *	@sk: socket
>   *	@flags: MSG_ flags
> - *	@off: an offset in bytes to peek skb from. Returns an offset
> - *	      within an skb where data actually starts
>   *	@peeked: returns non-zero if this packet has been seen before
> + *	@_off: an offset in bytes to peek skb from. Returns an offset
> + *	       within an skb where data actually starts
>   *	@err: error code returned
>   *
>   *	Get a datagram skbuff, understands the peeking, nonblocking wakeups
> @@ -159,9 +160,9 @@ out_noerr:
>   *	the standard around please.
>   */
>  struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
> -				    int *peeked, int *off, int *err)
> +				    int *peeked, int *_off, int *err)
>  {
> -	struct sk_buff *skb;
> +	struct sk_buff *skb, *last;
>  	long timeo;
>  	/*
>  	 * Caller is allowed not to check sk->sk_err before skb_recv_datagram()
> @@ -182,13 +183,16 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>  		 */
>  		unsigned long cpu_flags;
>  		struct sk_buff_head *queue = &sk->sk_receive_queue;
> +		int off = *_off;
>  
>  		spin_lock_irqsave(&queue->lock, cpu_flags);
> +		last = (struct sk_buff *)queue;

This could be done before spin_lock

>  		skb_queue_walk(queue, skb) {
> +			last = skb;
>  			*peeked = skb->peeked;
>  			if (flags & MSG_PEEK) {
> -				if (*off >= skb->len && (skb->len || *off)) {
> -					*off -= skb->len;
> +				if (off >= skb->len && (skb->len || off)) {
> +					off -= skb->len;
>  					continue;
>  				}
>  				skb->peeked = 1;
> @@ -197,6 +201,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>  				__skb_unlink(skb, queue);
>  
>  			spin_unlock_irqrestore(&queue->lock, cpu_flags);
> +			*_off = off;
>  			return skb;
>  		}
>  		spin_unlock_irqrestore(&queue->lock, cpu_flags);
> @@ -206,7 +211,7 @@ struct sk_buff *__skb_recv_datagram(struct sock *sk, unsigned int flags,
>  		if (!timeo)
>  			goto no_packet;
>  
> -	} while (!wait_for_packet(sk, err, &timeo));
> +	} while (!wait_for_more_packets(sk, err, &timeo, last));
>  
>  	return NULL;
>  

Other than that, patch seems fine.
