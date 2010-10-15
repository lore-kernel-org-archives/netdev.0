From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH V2 net-next] can-raw: add msg_flags to distinguish local
	traffic
Date: Fri, 15 Oct 2010 18:15:51 +0200
Message-ID: <4CB87E37.4070908@hartkopp.net>
References: <20101015153829.GA317@e-circ.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kurt Van Dijck <kurt.van.dijck-/BeEPy95v10@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20101015153829.GA317-MxZ6Iy/zr/UdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello Kurt,

thanks for the patch.

I really appreciate this extension.

Some remarks inline ...

On 15.10.2010 17:38, Kurt Van Dijck wrote:

> diff --git a/Documentation/networking/can.txt b/Documentation/networking/can.txt
> index cd79735..95341aa 100644
> --- a/Documentation/networking/can.txt
> +++ b/Documentation/networking/can.txt
> @@ -22,6 +22,7 @@ This file contains
>        4.1.2 RAW socket option CAN_RAW_ERR_FILTER
>        4.1.3 RAW socket option CAN_RAW_LOOPBACK
>        4.1.4 RAW socket option CAN_RAW_RECV_OWN_MSGS
> +      4.1.5 RAW socket returned flags
>      4.2 Broadcast Manager protocol sockets (SOCK_DGRAM)
>      4.3 connected transport protocols (SOCK_SEQPACKET)
>      4.4 unconnected transport protocols (SOCK_DGRAM)
> @@ -471,6 +472,16 @@ solution for a couple of reasons:
>      setsockopt(s, SOL_CAN_RAW, CAN_RAW_RECV_OWN_MSGS,
>                 &recv_own_msgs, sizeof(recv_own_msgs));
>  
> +  4.1.5 RAW socket returned flags
> +
> +  When using recvmsg() call, the msg->msg_flags may contain following flags:
> +
> +    MSG_DONTROUTE: set when the frame was sent via the same physical device,
> +	ie. a loopback frame.

According the code MSG_DONTROUTE indicates frames that have been originated on
the local host. Nothing more.

Only when you enabled CAN_RAW_RECV_OWN_MSGS and you bound the socket to a
specific CAN interface, the description becomes correct.

Better write:

MSG_DONTROUTE : set when the received frame was created on the local host.


> +    MSG_CONFIRM: set when the frame was sent via the socket it is received on.

ok.

> +	This flag acts as a 'transmission confirmation'.

Better:

This flag can be interpreted as a 'transmission confirmation' when the CAN
driver supports the echo of CAN frames on driver level, see 3.2 and 6.2

> +	In order to receive such messages, CAN_RAW_RECV_OWN_MSGS must be set.
> +
>    4.2 Broadcast Manager protocol sockets (SOCK_DGRAM)
>    4.3 connected transport protocols (SOCK_SEQPACKET)
>    4.4 unconnected transport protocols (SOCK_DGRAM)
> diff --git a/net/can/raw.c b/net/can/raw.c
> index 7d77e67..9020c4f 100644
> --- a/net/can/raw.c
> +++ b/net/can/raw.c
> @@ -90,23 +90,39 @@ struct raw_sock {
>  	can_err_mask_t err_mask;
>  };
>  
> +/*
> + * return some space to store extra msg flags in.
> + * We use 1 int beyond the 'struct sockaddr_can' in skb->cb
> + * to store those.
> + * These flags will be use in raw_recvmsg()
> + */

/*
 * Return pointer to store the extra msg flags for raw_recvmsg().
 * We use the space of one unsigned int beyond the 'struct sockaddr_can'
 * in skb->cb.
 */


> +static inline unsigned int *raw_flags(struct sk_buff *skb)
> +{
> +	BUILD_BUG_ON(sizeof(skb->cb) <= (sizeof(struct sockaddr_can)
> +				+ sizeof(unsigned int)));

One empty line would be nice here ...

> +	/* return pointer after struct sockaddr_can */
> +	return (unsigned int *)(&((struct sockaddr_can *)skb->cb)[1]);
> +}
> +
>  static inline struct raw_sock *raw_sk(const struct sock *sk)
>  {
>  	return (struct raw_sock *)sk;
>  }
>  
> -static void raw_rcv(struct sk_buff *skb, void *data)
> +static void raw_rcv(struct sk_buff *oskb, void *data)
>  {
>  	struct sock *sk = (struct sock *)data;
>  	struct raw_sock *ro = raw_sk(sk);
>  	struct sockaddr_can *addr;
> +	struct sk_buff *skb;
> +	unsigned int *pflags;
>  
>  	/* check the received tx sock reference */
> -	if (!ro->recv_own_msgs && skb->sk == sk)
> +	if (!ro->recv_own_msgs && oskb->sk == sk)
>  		return;
>  
>  	/* clone the given skb to be able to enqueue it into the rcv queue */
> -	skb = skb_clone(skb, GFP_ATOMIC);
> +	skb = skb_clone(oskb, GFP_ATOMIC);
>  	if (!skb)
>  		return;
>  
> @@ -123,6 +139,14 @@ static void raw_rcv(struct sk_buff *skb, void *data)
>  	addr->can_family  = AF_CAN;
>  	addr->can_ifindex = skb->dev->ifindex;
>  
> +	/* prepare the flags for raw_recvmsg() */
> +	pflags = raw_flags(skb);
> +	*pflags = 0;
> +	if (oskb->sk)
> +		*pflags |= MSG_DONTROUTE;
> +	if (oskb->sk == sk)
> +		*pflags |= MSG_CONFIRM;
> +

A good improvement since your first proof-of-concept code :-)

>  	if (sock_queue_rcv_skb(sk, skb) < 0)
>  		kfree_skb(skb);
>  }
> @@ -707,6 +731,9 @@ static int raw_recvmsg(struct kiocb *iocb, struct socket *sock,
>  		memcpy(msg->msg_name, skb->cb, msg->msg_namelen);
>  	}
>  
> +	/* assign the flags that have been recorded in raw_rcv() */
> +	msg->msg_flags |= *(raw_flags(skb));
> +

dito :-)

>  	skb_free_datagram(sk, skb);
>  
>  	return size;

Tnx & regards,
Oliver
