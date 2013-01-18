From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH v4] cgroup: net_cls: traffic counter based on
 classification control cgroup
Date: Fri, 18 Jan 2013 06:27:20 -0800
Message-ID: <1358519240.11051.107.camel@edumazet-glaptop>
References: <20130118135944.GA15062@aperevalov>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130118135944.GA15062@aperevalov>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-01-18 at 17:59 +0400, Alexey Perevalov wrote:
> Traffic counter based on classification control group
> 
> 	The main goal of this patch it's counting traffic for process placed to
> 	net_cls cgroup (ingress and egress).
> 	It's based on atomic and holds counter per network interfaces.
> 
> 	It handles packets in net/core/dev.c for egress and in
> 	/net/ipv4/tcp.c|udp.c for ingress.
> 
> 	Cgroup fs interface provides following files additional to existing
> 		net_cls files:
> 			net_cls.ifacename.usage_in_bytes
> 			Containing rcv/snd lines.
> 
> Signed-off-by: Alexey Perevalov <a.perevalov-Sze3O3UU22JBDgjK7y7TUQ@public.gmane.org>
> ---

...

> index d1e8116..ffc9ec2 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -135,6 +135,7 @@
>  #include <linux/net_tstamp.h>
>  #include <linux/static_key.h>
>  #include <net/flow_keys.h>
> +#include <net/cls_cgroup.h>
>  
>  #include "net-sysfs.h"
>  
> @@ -2922,6 +2923,11 @@ int dev_queue_xmit(struct sk_buff *skb)
>  	 */
>  	rcu_read_lock_bh();
>  
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +	if (dev)

How dev could be NULL here ?

> +		count_cls_snd(skb_cls_classid(skb), skb->len, dev->name);
> +#endif

Why do you add these ugly ifdefs in the C files ?

As already said, you should not add new ifdef in C files, but properly
define empty functions in the header files

#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
 ...
#else
 static inline void count_cls_snd( args ) { }
#endif




> +
>  	skb_update_prio(skb);
>  
>  	txq = netdev_pick_tx(dev, skb);
> diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
> index 1ca2536..dc4dc3a 100644
> --- a/net/ipv4/tcp.c
> +++ b/net/ipv4/tcp.c
> @@ -276,6 +276,7 @@
>  #include <net/ip.h>
>  #include <net/netdma.h>
>  #include <net/sock.h>
> +#include <net/cls_cgroup.h>
>  
>  #include <asm/uaccess.h>
>  #include <asm/ioctls.h>
> @@ -1464,6 +1465,9 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
>  	u32 seq = tp->copied_seq;
>  	u32 offset;
>  	int copied = 0;
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +	int ifindex = 0;
> +#endif
>  
>  	if (sk->sk_state == TCP_LISTEN)
>  		return -ENOTCONN;
> @@ -1510,6 +1514,9 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
>  			++seq;
>  			break;
>  		}
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +		ifindex = get_ifindex_from_skb(skb);
> +#endif
>  		sk_eat_skb(sk, skb, false);
>  		if (!desc->count)
>  			break;
> @@ -1520,8 +1527,12 @@ int tcp_read_sock(struct sock *sk, read_descriptor_t *desc,
>  	tcp_rcv_space_adjust(sk);
>  
>  	/* Clean up data we have read: This will do ACK frames. */
> -	if (copied > 0)
> +	if (copied > 0) {
>  		tcp_cleanup_rbuf(sk, copied);
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +		count_cls_rcv(current, copied, ifindex);
> +#endif
> +	}
>  	return copied;
>  }
>  EXPORT_SYMBOL(tcp_read_sock);
> @@ -1549,6 +1560,9 @@ int tcp_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
>  	bool copied_early = false;
>  	struct sk_buff *skb;
>  	u32 urg_hole = 0;
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +	int ifindex = 0;
> +#endif
>  
>  	lock_sock(sk);
>  
> @@ -1873,6 +1887,9 @@ skip_copy:
>  		if (tcp_hdr(skb)->fin)
>  			goto found_fin_ok;
>  		if (!(flags & MSG_PEEK)) {
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +			ifindex = get_ifindex_from_skb(skb);
> +#endif
>  			sk_eat_skb(sk, skb, copied_early);
>  			copied_early = false;
>  		}
> @@ -1882,6 +1899,9 @@ skip_copy:
>  		/* Process the FIN. */
>  		++*seq;
>  		if (!(flags & MSG_PEEK)) {
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +			ifindex = get_ifindex_from_skb(skb);
> +#endif
>  			sk_eat_skb(sk, skb, copied_early);
>  			copied_early = false;
>  		}
> @@ -1924,6 +1944,11 @@ skip_copy:
>  	/* Clean up data we have read: This will do ACK frames. */
>  	tcp_cleanup_rbuf(sk, copied);
>  
> +#if IS_ENABLED(CONFIG_NET_CLS_COUNTER)
> +	if (copied > 0)
> +		count_cls_rcv(current, copied, ifindex);
> +#endif
> +
>  	release_sock(sk);
>  	return copied;
>  


There is no need to add so much ugly code in tcp at least

For input packets, as soon as we identify a matching socket in IP/TCP
early demux, we are done. It permits to properly account packets, even
the retransmits and ACKS, and even packets dropped by netfilter or
sk_filter.
