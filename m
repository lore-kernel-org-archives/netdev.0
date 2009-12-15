From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: packet_sendmsg_spkt sleeping from invalid context
Date: Tue, 15 Dec 2009 16:13:05 +0100
Message-ID: <20091215151302.GD5833@nowhere>
References: <20091214175211.GA5102@nowhere> <4B2690E7.4030303@gmail.com> <20091214205231.GB5037@nowhere> <4B26AD65.1020004@gmail.com> <20091214213002.GA5203@nowhere> <4B26B09A.7050607@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751534AbZLOPNN@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B26B09A.7050607@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 14, 2009 at 10:39:38PM +0100, Eric Dumazet wrote:
> OK here it is, I tested it with PREEMPT_RCU as well
> 
> Thanks !
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 0205621..bc17351 100644
> --- a/net/packet/af_packet.c
> +++ b/net/packet/af_packet.c
> @@ -415,7 +415,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
>  {
>  	struct sock *sk = sock->sk;
>  	struct sockaddr_pkt *saddr = (struct sockaddr_pkt *)msg->msg_name;
> -	struct sk_buff *skb;
> +	struct sk_buff *skb = NULL;
>  	struct net_device *dev;
>  	__be16 proto = 0;
>  	int err;
> @@ -437,6 +437,7 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
>  	 */
>  
>  	saddr->spkt_device[13] = 0;
> +retry:
>  	rcu_read_lock();
>  	dev = dev_get_by_name_rcu(sock_net(sk), saddr->spkt_device);
>  	err = -ENODEV;
> @@ -456,58 +457,48 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
>  	if (len > dev->mtu + dev->hard_header_len)
>  		goto out_unlock;
>  
> -	err = -ENOBUFS;
> -	skb = sock_wmalloc(sk, len + LL_RESERVED_SPACE(dev), 0, GFP_KERNEL);
> -
> -	/*
> -	 * If the write buffer is full, then tough. At this level the user
> -	 * gets to deal with the problem - do your own algorithmic backoffs.
> -	 * That's far more flexible.
> -	 */
> -
> -	if (skb == NULL)
> -		goto out_unlock;
> -
> -	/*
> -	 *	Fill it in
> -	 */
> -
> -	/* FIXME: Save some space for broken drivers that write a
> -	 * hard header at transmission time by themselves. PPP is the
> -	 * notable one here. This should really be fixed at the driver level.
> -	 */
> -	skb_reserve(skb, LL_RESERVED_SPACE(dev));
> -	skb_reset_network_header(skb);
> -
> -	/* Try to align data part correctly */
> -	if (dev->header_ops) {
> -		skb->data -= dev->hard_header_len;
> -		skb->tail -= dev->hard_header_len;
> -		if (len < dev->hard_header_len)
> -			skb_reset_network_header(skb);
> +	if (!skb) {
> +		size_t reserved = LL_RESERVED_SPACE(dev);
> +		unsigned int hhlen = dev->header_ops ? dev->hard_header_len : 0;
> +
> +		rcu_read_unlock();
> +		skb = sock_wmalloc(sk, len + reserved, 0, GFP_KERNEL);
> +		if (skb == NULL)
> +			return -ENOBUFS;
> +		skb_reserve(skb, reserved);
> +		/* FIXME: Save some space for broken drivers that write a hard
> +		 * header at transmission time by themselves. PPP is the notable
> +		 * one here. This should really be fixed at the driver level.
> +		 */
> +		skb_reset_network_header(skb);
> +
> +		/* Try to align data part correctly */
> +		if (hhlen) {
> +			skb->data -= hhlen;
> +			skb->tail -= hhlen;
> +			if (len < hhlen)
> +				skb_reset_network_header(skb);
> +		}
> +		err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
> +		if (err)
> +			goto out_free;
> +		goto retry;
>  	}
>  
> -	/* Returns -EFAULT on error */
> -	err = memcpy_fromiovec(skb_put(skb, len), msg->msg_iov, len);
> +
>  	skb->protocol = proto;
>  	skb->dev = dev;
>  	skb->priority = sk->sk_priority;
>  	skb->mark = sk->sk_mark;
> -	if (err)
> -		goto out_free;
> -
> -	/*
> -	 *	Now send it
> -	 */
>  
>  	dev_queue_xmit(skb);
>  	rcu_read_unlock();
>  	return len;
>  
> -out_free:
> -	kfree_skb(skb);
>  out_unlock:
>  	rcu_read_unlock();
> +out_free:
> +	kfree_skb(skb);
>  	return err;
>  }
>  
> 




Tested-by: Frederic Weisbecker <fweisbec@gmail.com>

Thanks!
