From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net-next] netns: correctly use per-netns ipv4
	sysctl_tcp_mem
Date: Thu, 19 Jul 2012 08:03:52 +0200
Message-ID: <1342677832.2626.3839.camel@edumazet-glaptop>
References: <50079D47.6040001@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <50079D47.6040001-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-07-19 at 13:38 +0800, Huang Qiang wrote:
> From: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> 
> Now, kernel allows each net namespace to independently set up its levels
> for tcp memory pressure thresholds.
> 
> But it seems there is a bug, as using the following steps:
> 
> [root@host socket]# lxc-start -n test -f config /bin/bash
> [root@net-test socket]# ip route add default via 192.168.58.2
> [root@net-test socket]# echo 0 0 0 > /proc/sys/net/ipv4/tcp_mem
> [root@net-test socket]# scp root-Q0ErXNX1RuabR28l3DCWlg@public.gmane.org:/home/tcp_mem_test .
> 
> and it still can transport the "tcp_mem_test" file which we hope it
> would not.
> 
> It's because inet_init() (net/ipv4/af_inet.c)initialize the tcp_prot.sysctl_mem:
> tcp_prot.sysctl_mem = init_net.ipv4.sysctl_tcp_mem;
> 
> So when the protocal is TCP, sk->sk_prot->sysctl_mem(following code)
> always use the ipv4 sysctl_tcp_mem of init_net namespace rather than
> it's own net namespace.
> This patch simply set "prot" equal to net->ipv4.sysctl_tcp_mem when
> the protocol type is TCP.
> 
> Signed-off-by: Yang Zhenzhang <yangzhenzhang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> Signed-off-by: Huang Qiang <h.huangqiang-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
> ---
>  include/net/sock.h |   24 ++++++++++++++++--------
>  1 files changed, 16 insertions(+), 8 deletions(-)
> 
> diff --git a/include/net/sock.h b/include/net/sock.h
> index 88de092..61f4363 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -59,6 +59,7 @@
>  #include <linux/static_key.h>
>  #include <linux/aio.h>
>  #include <linux/sched.h>
> +#include <linux/in.h>
> 
>  #include <linux/filter.h>
>  #include <linux/rculist_nulls.h>
> @@ -1064,14 +1065,6 @@ static inline void sk_enter_memory_pressure(struct sock *sk)
>  	sk->sk_prot->enter_memory_pressure(sk);
>  }
> 
> -static inline long sk_prot_mem_limits(const struct sock *sk, int index)
> -{
> -	long *prot = sk->sk_prot->sysctl_mem;
> -	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> -		prot = sk->sk_cgrp->sysctl_mem;
> -	return prot[index];
> -}
> -
>  static inline void memcg_memory_allocated_add(struct cg_proto *prot,
>  					      unsigned long amt,
>  					      int *parent_status)
> @@ -2155,6 +2148,21 @@ static inline void sk_change_net(struct sock *sk, struct net *net)
>  	sock_net_set(sk, hold_net(net));
>  }
> 
> +static inline long sk_prot_mem_limits(const struct sock *sk, int index)
> +{
> +	long *prot = sk->sk_prot->sysctl_mem;
> +
> +	if (sk->sk_protocol == IPPROTO_TCP) {
> +		struct net *net = sock_net(sk);
> +		prot = net->ipv4.sysctl_tcp_mem;
> +	}
> +

	if (sk->sk_protocol == IPPROTO_TCP)
		prot = sock_net(sk)->ipv4.sysctl_tcp_mem;

> +	if (mem_cgroup_sockets_enabled && sk->sk_cgrp)
> +		prot = sk->sk_cgrp->sysctl_mem;
> +
> +	return prot[index];
> +}
> +
>  static inline struct sock *skb_steal_sock(struct sk_buff *skb)
>  {
>  	if (skb->sk) {
