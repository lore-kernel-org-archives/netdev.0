From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: Fix kernel panic at security_sock_rcv_skb
Date: Thu, 12 Jan 2017 09:22:17 +0100
Message-ID: <0e458012-e97b-298d-296e-ed25e35689a0@hartkopp.net>
References: <1484202799-7287-1-git-send-email-shuo.a.liu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yanmin_zhang@linux.intel.com, shuox.liu@gmail.com,
        Zhang Yanmin <yanmin.zhang@intel.com>,
        "He, Bo" <bo.he@intel.com>, Marc Kleine-Budde <mkl@pengutronix.de>,
        "David S. Miller" <davem@davemloft.net>,
        "open list:CAN NETWORK LAYER" <linux-can@vger.kernel.org>,
        "open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>
To: Liu ShuoX <shuo.a.liu@intel.com>, linux-kernel@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1484202799-7287-1-git-send-email-shuo.a.liu@intel.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 01/12/2017 07:33 AM, Liu ShuoX wrote:
> From: Zhang Yanmin <yanmin.zhang@intel.com>
>
> The patch is for fix the below kernel panic:
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
> The sk dereferenced in panic has been released. After the rcu_call in
> can_rx_unregister, receiver was protected by RCU but inner data was
> not, then later sk will be freed while other CPU is still using it.
> We need wait here to make sure sk referenced via receiver was safe.
>
> => security_sk_free
> => sk_destruct
> => __sk_free
> => sk_free
> => raw_release
> => sock_release
> => sock_close
> => __fput
> => ____fput
> => task_work_run
> => exit_to_usermode_loop
> => syscall_return_slowpath
> => int_ret_from_sys_call
>
> Signed-off-by: Zhang Yanmin <yanmin.zhang@intel.com>
> Signed-off-by: He, Bo <bo.he@intel.com>
> Signed-off-by: Liu Shuo A <shuo.a.liu@intel.com>
> ---
>  net/can/af_can.c | 14 ++++++++------
>  net/can/af_can.h |  1 -
>  2 files changed, 8 insertions(+), 7 deletions(-)
>
> diff --git a/net/can/af_can.c b/net/can/af_can.c
> index 1108079..fcbe971 100644
> --- a/net/can/af_can.c
> +++ b/net/can/af_can.c
> @@ -517,10 +517,8 @@ int can_rx_register(struct net_device *dev, canid_t can_id, canid_t mask,
>  /*
>   * can_rx_delete_receiver - rcu callback for single receiver entry removal
>   */
> -static void can_rx_delete_receiver(struct rcu_head *rp)
> +static void can_rx_delete_receiver(struct receiver *r)
>  {
> -	struct receiver *r = container_of(rp, struct receiver, rcu);
> -
>  	kmem_cache_free(rcv_cache, r);
>  }
>
> @@ -595,9 +593,13 @@ void can_rx_unregister(struct net_device *dev, canid_t can_id, canid_t mask,
>   out:
>  	spin_unlock(&can_rcvlists_lock);
>
> -	/* schedule the receiver item for deletion */
> -	if (r)
> -		call_rcu(&r->rcu, can_rx_delete_receiver);
> +	/* synchronize_rcu to wait until a grace period has elapsed, to make
> +	 * sure all receiver's sk dereferenced by others.
> +	 */
> +	if (r) {
> +		synchronize_rcu();
> +		can_rx_delete_receiver(r);

Nitpick: When can_rx_delete_receiver() just contains 
kmem_cache_free(rcv_cache, r), then the function definition should be 
removed.

But my main concern is:

The reason why can_rx_delete_receiver() was introduced was the need to 
remove a huge number of receivers with can_rx_unregister().

When you call synchronize_rcu() after each receiver removal this would 
potentially lead to a big performance issue when e.g. closing CAN_RAW 
sockets with a high number of receivers.

So the idea was to remove/unlink the receiver hlist_del_rcu(&r->list) 
and also kmem_cache_free(rcv_cache, r) by some rcu mechanism - so that 
all elements are cleaned up by rcu at a later point.

Is it possible that the problems emerge due to hlist_del_rcu(&r->list) 
and you accidently fix it with your introduced synchronize_rcu()?

Regards,
Oliver


> +	}
>  }
>  EXPORT_SYMBOL(can_rx_unregister);
>
> diff --git a/net/can/af_can.h b/net/can/af_can.h
> index fca0fe9..a0cbf83 100644
> --- a/net/can/af_can.h
> +++ b/net/can/af_can.h
> @@ -50,7 +50,6 @@
>
>  struct receiver {
>  	struct hlist_node list;
> -	struct rcu_head rcu;
>  	canid_t can_id;
>  	canid_t mask;
>  	unsigned long matches;
>
