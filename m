From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: packet_sendmsg_spkt sleeping from invalid context
Date: Mon, 14 Dec 2009 21:11:57 +0100
Message-ID: <20091214201154.GA5037@nowhere>
References: <20091214175211.GA5102@nowhere> <4B2690E7.4030303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>,
	Netdev <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f219.google.com ([209.85.219.219]:47160 "EHLO
	mail-ew0-f219.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754975AbZLNUMB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 15:12:01 -0500
Content-Disposition: inline
In-Reply-To: <4B2690E7.4030303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 14, 2009 at 08:24:23PM +0100, Eric Dumazet wrote:
> Thanks for the report Frederic.
> 
> We could partly revert the original commit, but as we wanted to avoid touching 
> device refcount, and af_packet might be the only real abuser, we could
> try following patch instead.
> 
> Thanks
> 
> [PATCH] packet: dont call sleeping function while holding rcu_read_lock()
> 
> commit 654d1f8a019dfa06d (packet: less dev_put() calls)
> introduced a problem, calling a potentially sleeping function from a
> rcu_read_lock() protected section.
> 
> Fix this by releasing lock before the sock_wmalloc() call.
> After skb allocation, we redo device lookup and appropriate tests.
> 
> Reported-by: Frederic Weisbecker <fweisbec@gmail.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/packet/af_packet.c |   36 +++++++++++++-----------------------
>  1 file changed, 13 insertions(+), 23 deletions(-)
> 
> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> index 0205621..19ceadc 100644
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
> @@ -456,27 +457,21 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
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
> +	if (!skb) {
> +		size_t reserved = LL_RESERVED_SPACE(dev);
>  
> -	if (skb == NULL)
> -		goto out_unlock;
> -
> -	/*
> -	 *	Fill it in
> -	 */
> +		rcu_read_unlock();
> +		skb = sock_wmalloc(sk, len + reserved, 0, GFP_KERNEL);
> +		if (skb == NULL)
> +			return -ENOBUFS;
> +		skb_reserve(skb, reserved);
> +		goto retry;
> +	}
>  
>  	/* FIXME: Save some space for broken drivers that write a
>  	 * hard header at transmission time by themselves. PPP is the
>  	 * notable one here. This should really be fixed at the driver level.
>  	 */
> -	skb_reserve(skb, LL_RESERVED_SPACE(dev));
>  	skb_reset_network_header(skb);
>  
>  	/* Try to align data part correctly */
> @@ -494,20 +489,15 @@ static int packet_sendmsg_spkt(struct kiocb *iocb, struct socket *sock,
>  	skb->priority = sk->sk_priority;
>  	skb->mark = sk->sk_mark;
>  	if (err)
> -		goto out_free;
> -
> -	/*
> -	 *	Now send it
> -	 */
> +		goto out_unlock;
>  
>  	dev_queue_xmit(skb);
>  	rcu_read_unlock();
>  	return len;
>  
> -out_free:
> -	kfree_skb(skb);
>  out_unlock:
>  	rcu_read_unlock();
> +	kfree_skb(skb);
>  	return err;
>  }
>  


Thanks, yeah it fixes the problem but unearthes a new one:

[   32.428785] sched: BUG: sleeping function called from invalid context at mm/memory.c:3369
[   32.454154] sched: in_atomic(): 1, irqs_disabled(): 0, pid: 3531, name: dhclient3
[   32.472866] 1 lock held by dhclient3/3531:
[   32.472872]  #0:  (rcu_read_lock){.+.+..}, at: [<ffffffff815d1a5e>] packet_sendmsg_spkt+0xce/0x340
[   32.472900] Pid: 3531, comm: dhclient3 Tainted: G        W  2.6.32-tip+ #135
[   32.472906] Call Trace:
[   32.472920]  [<ffffffff81081403>] ? __debug_show_held_locks+0x13/0x30
[   32.472933]  [<ffffffff8103d6b8>] __might_sleep+0x118/0x140
[   32.472944]  [<ffffffff810f48cb>] might_fault+0x3b/0xd0
[   32.472955]  [<ffffffff81549c1e>] memcpy_fromiovec+0x6e/0xa0
[   32.472965]  [<ffffffff815d1c44>] packet_sendmsg_spkt+0x2b4/0x340
[   32.472975]  [<ffffffff815d1a5e>] ? packet_sendmsg_spkt+0xce/0x340
[   32.472986]  [<ffffffff8153e167>] sock_sendmsg+0x127/0x140
[   32.472999]  [<ffffffff8106f6e0>] ? autoremove_wake_function+0x0/0x40
[   32.473009]  [<ffffffff810f490b>] ? might_fault+0x7b/0xd0
[   32.473019]  [<ffffffff810f490b>] ? might_fault+0x7b/0xd0
[   32.473030]  [<ffffffff8154043a>] ? move_addr_to_kernel+0x6a/0x70
[   32.473040]  [<ffffffff8154052f>] sys_sendto+0xef/0x120
[   32.473053]  [<ffffffff81131709>] ? mntput_no_expire+0x29/0x110
[   32.473067]  [<ffffffff810027db>] system_call_fastpath+0x16/0x1b


And I guess you need to protect dev until the packet is submitted.
Looks tricky...

I've searched a kind of get_net_dev() but did not find any :)

