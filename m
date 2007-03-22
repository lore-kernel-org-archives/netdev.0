From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [ANN] Unified dynamic storage for different socket types
 instead of separate hash tables.
Date: Thu, 22 Mar 2007 11:43:04 -0700
Message-ID: <20070322114304.1e516507@freekitty>
References: <20070322180957.GA17793@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:45370 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934180AbXCVSnQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Mar 2007 14:43:16 -0400
In-Reply-To: <20070322180957.GA17793@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> 
> diff --git a/include/linux/netlink.h b/include/linux/netlink.h
> index 2a20f48..f11b4e7 100644
> --- a/include/linux/netlink.h
> +++ b/include/linux/netlink.h
> @@ -151,7 +151,6 @@ struct netlink_skb_parms
>  #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
>  #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
>  
> -
>  extern struct sock *netlink_kernel_create(int unit, unsigned int groups, void (*input)(struct sock *sk, int len), struct module *module);
>  extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
>  extern int netlink_has_listeners(struct sock *sk, unsigned int group);

Minor nit this a one line blank only diff, probably just editing crap.


>  static inline void udp_lib_close(struct sock *sk, long timeout)
> diff --git a/net/core/sock.c b/net/core/sock.c
> index 8d65d64..abe1632 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -901,7 +901,9 @@ struct sock *sk_clone(const struct sock *sk, const gfp_t priority)
>  		sock_copy(newsk, sk);
>  
>  		/* SANITY */
> +#ifndef CONFIG_MDT_LOOKUP
>  		sk_node_init(&newsk->sk_node);
> +#endif
>  		sock_lock_init(newsk);
>  		bh_lock_sock(newsk);

I would rather not see ifdef's in code. Could you just stub
out the function in the include file?


>  
> diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
> index 9e8ef50..5bfb0dc 100644
> --- a/net/ipv4/Kconfig
> +++ b/net/ipv4/Kconfig
> @@ -1,6 +1,14 @@
>  #
>  # IP configuration
>  #
> +
> +config MDT_LOOKUP
> +	bool "Multidimensional trie socket lookup"
> +	depends on !INET_TCP_DIAG
> +	help
> +	  This option replaces traditional hash table lookup for TCP sockets
> +	  with multidimensional trie algorithm (similar to judy trie).

So you had to break the TCP_DIAG output to make this work.
Please fix, the ss command is useful.

> diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
> index cf358c8..8c32545 100644
> --- a/net/ipv4/af_inet.c
> +++ b/net/ipv4/af_inet.c
> @@ -1360,6 +1360,7 @@ fs_initcall(inet_init);
>  /* ------------------------------------------------------------------------ */
>  
>  #ifdef CONFIG_PROC_FS
> +#ifndef CONFIG_MDT_LOOKUP
>  static int __init ipv4_proc_init(void)
>  {
>  	int rc = 0;
> @@ -1388,7 +1389,12 @@ out_raw:
>  	rc = -ENOMEM;
>  	goto out;
>  }
> -
> +#else
> +static int __init ipv4_proc_init(void)
> +{
> +	return 0;
> +}
> +#endif

If you are making it into a stub, why not get rid of it
completely?

> +
> +#define MDT_SET_LEAF_STORAGE(leaf, ptr) do { \
> +	rcu_assign_pointer((leaf), (struct mdt_node *)(((unsigned long)(ptr)) | MDT_LEAF_STRUCT_BIT)); \
> +} while (0)

Macro yuckinesss.

<rest deleted>

What is the code size change with this?
-- 
Stephen Hemminger <shemminger@linux-foundation.org>
