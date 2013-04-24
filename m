From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH RFC net-next] ipv6: Kill ipv6 dependency of
 icmpv6_send().
Date: Tue, 23 Apr 2013 17:05:50 -0700
Message-ID: <1366761950.8964.43.camel@edumazet-glaptop>
References: <1366760953-27408-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33100 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754597Ab3DXAFy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Apr 2013 20:05:54 -0400
Received: by mail-pa0-f42.google.com with SMTP id kl13so806957pab.1
        for <netdev@vger.kernel.org>; Tue, 23 Apr 2013 17:05:53 -0700 (PDT)
In-Reply-To: <1366760953-27408-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-04-23 at 16:49 -0700, Pravin B Shelar wrote:
> Following patch adds icmp-registration module for ipv6.  It allows
> ipv6 protocol to register icmp_sender which is used for sending
> ipv6 icmp msgs.  This extra layer allows us to kill dependency
> on ipv6 for icmpv6_send() function.
> 
> This patch also fixes ip_tunnel compilation problem when ip_tunnel
> is statically compiled in kernel but ipv6 is module.
> 
> Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
> ---
>  include/linux/icmpv6.h |   18 +++++++++++--
>  net/ipv6/Makefile      |    2 +-
>  net/ipv6/icmp.c        |   35 +++++++++++++++-----------
>  net/ipv6/ip6_icmp.c    |   64 ++++++++++++++++++++++++++++++++++++++++++++++++
>  4 files changed, 100 insertions(+), 19 deletions(-)
>  create mode 100644 net/ipv6/ip6_icmp.c
> 
> diff --git a/include/linux/icmpv6.h b/include/linux/icmpv6.h
> index b4f6c29..630f453 100644
> --- a/include/linux/icmpv6.h
> +++ b/include/linux/icmpv6.h
> @@ -11,9 +11,21 @@ static inline struct icmp6hdr *icmp6_hdr(const struct sk_buff *skb)
>  
>  #include <linux/netdevice.h>
>  
> -extern void				icmpv6_send(struct sk_buff *skb,
> -						    u8 type, u8 code,
> -						    __u32 info);
> +#if IS_ENABLED(CONFIG_IPV6)
> +extern void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info);
> +
> +typedef void ip6_icmp_send_t(struct sk_buff *skb, u8 type, u8 code, __u32 info);
> +extern int inet6_register_icmp_sender(ip6_icmp_send_t *fn);
> +extern int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn);
> +
> +#else
> +
> +static inline void icmpv6_send(struct sk_buff *skb,
> +			       u8 type, u8 code, __u32 info)
> +{
> +
> +}
> +#endif
>  
>  extern int				icmpv6_init(void);
>  extern int				icmpv6_err_convert(u8 type, u8 code,
> diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
> index 309af19..9af088d 100644
> --- a/net/ipv6/Makefile
> +++ b/net/ipv6/Makefile
> @@ -40,7 +40,7 @@ obj-$(CONFIG_IPV6_SIT) += sit.o
>  obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
>  obj-$(CONFIG_IPV6_GRE) += ip6_gre.o
>  
> -obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o
> +obj-y += addrconf_core.o exthdrs_core.o ip6_checksum.o ip6_icmp.o
>  obj-$(CONFIG_INET) += output_core.o protocol.o $(ipv6-offload)
>  
>  obj-$(subst m,y,$(CONFIG_IPV6)) += inet6_hashtables.o
> diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
> index 71b900c..2a53a79 100644
> --- a/net/ipv6/icmp.c
> +++ b/net/ipv6/icmp.c
> @@ -124,15 +124,6 @@ static __inline__ void icmpv6_xmit_unlock(struct sock *sk)
>  }
>  
>  /*
> - * Slightly more convenient version of icmpv6_send.
> - */
> -void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
> -{
> -	icmpv6_send(skb, ICMPV6_PARAMPROB, code, pos);
> -	kfree_skb(skb);
> -}
> -
> -/*
>   * Figure out, may we reply to this packet with icmp error.
>   *
>   * We do not reply, if:
> @@ -332,7 +323,7 @@ static struct dst_entry *icmpv6_route_lookup(struct net *net, struct sk_buff *sk
>  	 * anycast.
>  	 */
>  	if (((struct rt6_info *)dst)->rt6i_flags & RTF_ANYCAST) {
> -		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: acast source\n");
> +		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: acast source\n");
>  		dst_release(dst);
>  		return ERR_PTR(-EINVAL);
>  	}
> @@ -381,7 +372,7 @@ relookup_failed:
>  /*
>   *	Send an ICMP message in response to a packet in error
>   */
> -void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
> +static void icmp6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
>  {
>  	struct net *net = dev_net(skb->dev);
>  	struct inet6_dev *idev = NULL;
> @@ -406,7 +397,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
>  	/*
>  	 *	Make sure we respect the rules
>  	 *	i.e. RFC 1885 2.4(e)
> -	 *	Rule (e.1) is enforced by not using icmpv6_send
> +	 *	Rule (e.1) is enforced by not using icmp6_send
>  	 *	in any code that processes icmp errors.
>  	 */
>  	addr_type = ipv6_addr_type(&hdr->daddr);
> @@ -444,7 +435,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
>  	 *	and anycast addresses will be checked later.
>  	 */
>  	if ((addr_type == IPV6_ADDR_ANY) || (addr_type & IPV6_ADDR_MULTICAST)) {
> -		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: addr_any/mcast source\n");
> +		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: addr_any/mcast source\n");
>  		return;
>  	}
>  
> @@ -452,7 +443,7 @@ void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
>  	 *	Never answer to a ICMP packet.
>  	 */
>  	if (is_ineligible(skb)) {
> -		LIMIT_NETDEBUG(KERN_DEBUG "icmpv6_send: no reply to icmp error\n");
> +		LIMIT_NETDEBUG(KERN_DEBUG "icmp6_send: no reply to icmp error\n");
>  		return;
>  	}
>  
> @@ -529,7 +520,14 @@ out_dst_release:
>  out:
>  	icmpv6_xmit_unlock(sk);
>  }
> -EXPORT_SYMBOL(icmpv6_send);
> +
> +/* Slightly more convenient version of icmp6_send.
> + */
> +void icmpv6_param_prob(struct sk_buff *skb, u8 code, int pos)
> +{
> +	icmp6_send(skb, ICMPV6_PARAMPROB, code, pos);
> +	kfree_skb(skb);
> +}
>  
>  static void icmpv6_echo_reply(struct sk_buff *skb)
>  {
> @@ -885,8 +883,14 @@ int __init icmpv6_init(void)
>  	err = -EAGAIN;
>  	if (inet6_add_protocol(&icmpv6_protocol, IPPROTO_ICMPV6) < 0)
>  		goto fail;
> +
> +	err = inet6_register_icmp_sender(icmp6_send);
> +	if (err)
> +		goto sender_reg_err;
>  	return 0;
>  
> +sender_reg_err:
> +	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
>  fail:
>  	pr_err("Failed to register ICMP6 protocol\n");
>  	unregister_pernet_subsys(&icmpv6_sk_ops);
> @@ -895,6 +899,7 @@ fail:
>  
>  void icmpv6_cleanup(void)
>  {
> +	inet6_unregister_icmp_sender(icmp6_send);
>  	unregister_pernet_subsys(&icmpv6_sk_ops);
>  	inet6_del_protocol(&icmpv6_protocol, IPPROTO_ICMPV6);
>  }
> diff --git a/net/ipv6/ip6_icmp.c b/net/ipv6/ip6_icmp.c
> new file mode 100644
> index 0000000..cfcc563
> --- /dev/null
> +++ b/net/ipv6/ip6_icmp.c
> @@ -0,0 +1,64 @@
> +#include <linux/export.h>
> +#include <linux/icmpv6.h>
> +#include <linux/mutex.h>
> +#include <linux/netdevice.h>
> +#include <linux/spinlock.h>
> +
> +#include <net/ipv6.h>
> +
> +#if IS_ENABLED(CONFIG_IPV6)
> +
> +static ip6_icmp_send_t __rcu *ip6_icmp_send;
> +static DEFINE_MUTEX(handler_lock);
> +
> +int inet6_register_icmp_sender(ip6_icmp_send_t *fn)
> +{
> +	int ret = 0;
> +
> +	mutex_lock(&handler_lock);
> +	if (rcu_dereference(ip6_icmp_send)) {

rcu_dereference_protected()

> +		ret = -EBUSY;
> +		goto out;
> +	}
> +	rcu_assign_pointer(ip6_icmp_send, fn);
> +
> +out:
> +	mutex_unlock(&handler_lock);
> +	return ret;
> +}
> +EXPORT_SYMBOL(inet6_register_icmp_sender);
> +
> +int inet6_unregister_icmp_sender(ip6_icmp_send_t *fn)
> +{
> +	int ret = 0;
> +
> +	mutex_lock(&handler_lock);
> +	if (rcu_dereference(ip6_icmp_send) != fn) {

rcu_dereference_protected()

> +		ret = -EINVAL;
> +		goto out;
> +	}
> +	rcu_assign_pointer(ip6_icmp_send, NULL);
> +
> +out:
> +	mutex_unlock(&handler_lock);
> +	synchronize_net();
> +
> +	return ret;
> +}
> +EXPORT_SYMBOL(inet6_unregister_icmp_sender);
> +
> +void icmpv6_send(struct sk_buff *skb, u8 type, u8 code, __u32 info)
> +{
> +	ip6_icmp_send_t *send;
> +
> +	rcu_read_lock();
> +	send = rcu_dereference(ip6_icmp_send);
> +
> +	if (!send)
> +		goto out;
> +	send(skb, type, code, info);
> +out:
> +	rcu_read_unlock();
> +}
> +EXPORT_SYMBOL(icmpv6_send);
> +#endif
