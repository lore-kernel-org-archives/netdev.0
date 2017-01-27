From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v3] can: Fix kernel panic at security_sock_rcv_skb
Date: Fri, 27 Jan 2017 21:02:13 +0100
Message-ID: <25ca6661-f98c-399f-c89b-1cf89ecd18a8@hartkopp.net>
References: <1484202799-7287-1-git-send-email-shuo.a.liu@intel.com>
 <0e458012-e97b-298d-296e-ed25e35689a0@hartkopp.net>
 <1484226099.15816.25.camel@edumazet-glaptop3.roam.corp.google.com>
 <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Liu ShuoX <shuo.a.liu@intel.com>, yanmin_zhang@linux.intel.com,
        shuox.liu@gmail.com, Zhang Yanmin <yanmin.zhang@intel.com>,
        "He, Bo" <bo.he@intel.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:CAN NETWORK LAYER" <linux-can@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.217]:27268 "EHLO
        mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdA0UF2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:05:28 -0500
In-Reply-To: <1485533504.6360.62.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 01/27/2017 05:11 PM, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> Zhang Yanmin reported crashes [1] and provided a patch adding a
> synchronize_rcu() call in can_rx_unregister()
>
> The main problem seems that the sockets themselves are not RCU
> protected.
>
> If CAN uses RCU for delivery, then sockets should be freed only after
> one RCU grace period.
>
> Recent kernels could use sock_set_flag(sk, SOCK_RCU_FREE), but let's
> ease stable backports with the following fix instead.
>
> [1]
> BUG: unable to handle kernel NULL pointer dereference at (null)
> IP: [<ffffffff81495e25>] selinux_socket_sock_rcv_skb+0x65/0x2a0
>
> Call Trace:
>  <IRQ>
>  [<ffffffff81485d8c>] security_sock_rcv_skb+0x4c/0x60
>  [<ffffffff81d55771>] sk_filter+0x41/0x210
>  [<ffffffff81d12913>] sock_queue_rcv_skb+0x53/0x3a0
>  [<ffffffff81f0a2b3>] raw_rcv+0x2a3/0x3c0
>  [<ffffffff81f06eab>] can_rcv_filter+0x12b/0x370
>  [<ffffffff81f07af9>] can_receive+0xd9/0x120
>  [<ffffffff81f07beb>] can_rcv+0xab/0x100
>  [<ffffffff81d362ac>] __netif_receive_skb_core+0xd8c/0x11f0
>  [<ffffffff81d36734>] __netif_receive_skb+0x24/0xb0
>  [<ffffffff81d37f67>] process_backlog+0x127/0x280
>  [<ffffffff81d36f7b>] net_rx_action+0x33b/0x4f0
>  [<ffffffff810c88d4>] __do_softirq+0x184/0x440
>  [<ffffffff81f9e86c>] do_softirq_own_stack+0x1c/0x30
>  <EOI>
>  [<ffffffff810c76fb>] do_softirq.part.18+0x3b/0x40
>  [<ffffffff810c8bed>] do_softirq+0x1d/0x20
>  [<ffffffff81d30085>] netif_rx_ni+0xe5/0x110
>  [<ffffffff8199cc87>] slcan_receive_buf+0x507/0x520
>  [<ffffffff8167ef7c>] flush_to_ldisc+0x21c/0x230
>  [<ffffffff810e3baf>] process_one_work+0x24f/0x670
>  [<ffffffff810e44ed>] worker_thread+0x9d/0x6f0
>  [<ffffffff810e4450>] ? rescuer_thread+0x480/0x480
>  [<ffffffff810ebafc>] kthread+0x12c/0x150
>  [<ffffffff81f9ccef>] ret_from_fork+0x3f/0x70
>
> Reported-by: Zhang Yanmin <yanmin.zhang@intel.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Acked-by: Oliver Hartkopp <socketcan@hartkopp.net>

Thanks Eric!

BR
Oliver

> ---
>  include/linux/can/core.h |    7 +++----
>  net/can/af_can.c         |   14 +++++++++++---
>  net/can/af_can.h         |    3 ++-
>  net/can/bcm.c            |    4 ++--
>  net/can/gw.c             |    2 +-
>  net/can/raw.c            |    4 ++--
>  6 files changed, 21 insertions(+), 13 deletions(-)
>
> diff --git a/include/linux/can/core.h b/include/linux/can/core.h
> index a0875001b13c84ad70a9b2909654e9ffb6824c58..df08a41d5be5f26cfa4cdc74935f5eae7fa51385 100644
> --- a/include/linux/can/core.h
> +++ b/include/linux/can/core.h
> @@ -45,10 +45,9 @@ struct can_proto {
>  extern int  can_proto_register(const struct can_proto *cp);
>  extern void can_proto_unregister(const struct can_proto *cp);
>
> -extern int  can_rx_register(struct net_device *dev, canid_t can_id,
> -			    canid_t mask,
> -			    void (*func)(struct sk_buff *, void *),
> -			    void *data, char *ident);
> +int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
> +		    void (*func)(struct sk_buff *, void *),
> +		    void *data, char *ident, struct sock *sk);
>
>  extern void can_rx_unregister(struct net_device *dev, canid_t can_id,
>  			      canid_t mask,
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 1108079d934f8383a599d7997b08100fca0465e9..d2b0638284b9a71aaba9cc433822329baf82a34e 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -445,6 +445,7 @@ static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
>   * @func: callback function on filter match
>   * @data: returned parameter for callback function
>   * @ident: string for calling module identification
> + * @sk: socket pointer (might be NULL)
>   *
>   * Description:
>   *  Invokes the callback function with the received sk_buff and the given
> @@ -468,7 +469,7 @@ static struct hlist_head *find_rcv_list(canid_t *can_id, canid_t *mask,
>   */
>  int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
>  		    void (*func)(struct sk_buff *, void *), void *data,
> -		    char *ident)
> +		    char *ident, struct sock *sk)
>  {
>  	struct receiver *r;
>  	struct hlist_head *rl;
> @@ -496,6 +497,7 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
>  		r->func    = func;
>  		r->data    = data;
>  		r->ident   = ident;
> +		r->sk      = sk;
>
>  		hlist_add_head_rcu(&r->list, rl);
>  		d->entries++;
> @@ -520,8 +522,11 @@ EXPORT_SYMBOL(can_rx_register);
>  static void can_rx_delete_receiver(struct rcu_head *rp)
>  {
>  	struct receiver *r = container_of(rp, struct receiver, rcu);
> -
> +	struct sock *sk = r->sk;
> +	
>  	kmem_cache_free(rcv_cache, r);
> +	if (sk)
> +		sock_put(sk);
>  }
>
>  /**
> @@ -596,8 +601,11 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
>  	spin_unlock(&can_rcvlists_lock);
>
>  	/* schedule the receiver item for deletion */
> -	if (r)
> +	if (r) {
> +		if (r->sk)
> +			sock_hold(r->sk);
>  		call_rcu(&r->rcu, can_rx_delete_receiver);
> +	}
>  }
>  EXPORT_SYMBOL(can_rx_unregister);
>
> diff --git a/net/can/af_can.h b/net/can/af_can.h
> index fca0fe9fc45a497cdf3da82d5414e846e7cc61b7..b86f5129e8385fe84ef671bb914e8e05c2977ca0 100644
> --- a/net/can/af_can.h
> +++ b/net/can/af_can.h
> @@ -50,13 +50,14 @@
>
>  struct receiver {
>  	struct hlist_node list;
> -	struct rcu_head rcu;
>  	canid_t can_id;
>  	canid_t mask;
>  	unsigned long matches;
>  	void (*func)(struct sk_buff *, void *);
>  	void *data;
>  	char *ident;
> +	struct sock *sk;
> +	struct rcu_head rcu;
>  };
>
>  #define CAN_SFF_RCV_ARRAY_SZ (1 << CAN_SFF_ID_BITS)
> diff --git a/net/can/bcm.c b/net/can/bcm.c
> index 21ac75390e3d64f795faad074b515d34ce0bbfa3..5c94071819188a2b92db9ae7fe1e0d41fb9a27c6 100644
> --- a/net/can/bcm.c
> +++ b/net/can/bcm.c
> @@ -1216,7 +1216,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>  				err = can_rx_register(dev, op->can_id,
>  						      REGMASK(op->can_id),
>  						      bcm_rx_handler, op,
> -						      "bcm");
> +						      "bcm", sk);
>
>  				op->rx_reg_dev = dev;
>  				dev_put(dev);
> @@ -1225,7 +1225,7 @@ static int bcm_rx_setup(struct bcm_msg_head *msg_head, struct msghdr *msg,
>  		} else
>  			err = can_rx_register(NULL, op->can_id,
>  					      REGMASK(op->can_id),
> -					      bcm_rx_handler, op, "bcm");
> +					      bcm_rx_handler, op, "bcm", sk);
>  		if (err) {
>  			/* this bcm rx op is broken -> remove it */
>  			list_del(&op->list);
> diff --git a/net/can/gw.c b/net/can/gw.c
> index a54ab0c821048ab2034bf32cef3c1f35e0dc82a5..7056a1a2bb70098e691ce557f05e5bc1f27cb42f 100644
> --- a/net/can/gw.c
> +++ b/net/can/gw.c
> @@ -442,7 +442,7 @@ static inline int cgw_register_filter(struct cgw_job *gwj)
>  {
>  	return can_rx_register(gwj->src.dev, gwj->ccgw.filter.can_id,
>  			       gwj->ccgw.filter.can_mask, can_can_gw_rcv,
> -			       gwj, "gw");
> +			       gwj, "gw", NULL);
>  }
>
>  static inline void cgw_unregister_filter(struct cgw_job *gwj)
> diff --git a/net/can/raw.c b/net/can/raw.c
> index b075f028d7e23958e9433a4b19f4475ad930b547..6dc546a06673ff41fc121c546ebd0567bb0da05f 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -190,7 +190,7 @@ static int raw_enable_filters(struct net_device *dev, struct sock *sk,
>  	for (i = 0; i < count; i++) {
>  		err = can_rx_register(dev, filter[i].can_id,
>  				      filter[i].can_mask,
> -				      raw_rcv, sk, "raw");
> +				      raw_rcv, sk, "raw", sk);
>  		if (err) {
>  			/* clean up successfully registered filters */
>  			while (--i >= 0)
> @@ -211,7 +211,7 @@ static int raw_enable_errfilter(struct net_device *dev, struct sock *sk,
>
>  	if (err_mask)
>  		err = can_rx_register(dev, 0, err_mask | CAN_ERR_FLAG,
> -				      raw_rcv, sk, "raw");
> +				      raw_rcv, sk, "raw", sk);
>
>  	return err;
>  }
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-can" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
