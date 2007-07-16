From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [**RFC**] [IPV6]: Support RFC3542 IPV6_PKTINFO socket option.
Date: Mon, 16 Jul 2007 13:47:57 -0400
Message-ID: <469BAF4D.9020903@hp.com>
References: <20070716.234413.103263857.yoshfuji@linux-ipv6.org>	<469B8F50.7000906@hp.com> <20070717.015518.45418916.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:37037 "EHLO atlrel6.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753721AbXGPRsZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jul 2007 13:48:25 -0400
In-Reply-To: <20070717.015518.45418916.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Yoshifuji-san

Some more comments below...

YOSHIFUJI Hideaki / 吉藤英明 wrote:
> 
> Thank you.  Here's take 2.
> 
> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
> index b1fe7ac..119363a 100644
> --- a/net/ipv6/datagram.c
> +++ b/net/ipv6/datagram.c
> @@ -496,7 +496,58 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
>  	return 0;
>  }
>  
> -int datagram_send_ctl(struct msghdr *msg, struct flowi *fl,
> +int ip6_datagram_set_pktinfo(struct sock *sk,
> +			     struct in6_pktinfo *src_info,
> +			     struct flowi *fl)
> +{
> +	struct net_device *dev = NULL;
> +	int addr_type;
> +	int err = 0;
> +	struct in6_addr *saddr = sk ? &inet6_sk(sk)->saddr : NULL;
> +
> +	if (src_info->ipi6_ifindex) {
> +		dev = dev_get_by_index(src_info->ipi6_ifindex);
> +		if (!dev)
> +			return -ENODEV;
> +	}
> +
> +	fl->oif = src_info->ipi6_ifindex;
> +
> +	addr_type = ipv6_addr_type(&src_info->ipi6_addr);
> +	if (addr_type == IPV6_ADDR_ANY)
> +		goto out;
> +
> +	err = -EINVAL;
> +
> +	if (sk && inet_sk(sk)->is_icsk)
> +		goto out;
> +

> +	if (saddr) {
> +		if (!ipv6_addr_any(saddr))
> +			goto out;
> +		if (!ipv6_addr_equal(&src_info->ipi6_addr, saddr))
> +			goto out;
> +	}

shouldn't the block above go away?  IPV6_PKTINFO can override the
source address that was bound or specified via other options.

 diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
> index aa3d07c..3ebcef8 100644
> --- a/net/ipv6/ipv6_sockglue.c
> +++ b/net/ipv6/ipv6_sockglue.c
> @@ -456,6 +456,28 @@ sticky_done:
>  		break;
>  	}
>  
> +	case IPV6_PKTINFO:
> +	{
> +		struct in6_pktinfo pktinfo;
> +		struct flowi fl;
> +		int err;
> +
> +		if (optlen < sizeof(pktinfo))
> +			return -EINVAL;
> +		if (copy_from_user(&pktinfo, optval, sizeof(pktinfo)))
> +			return -EFAULT;
> +
> +		fl.fl6_flowlabel = 0;
> +		fl.oif = sk->sk_bound_dev_if;
> +
> +		lock_sock(sk);
> +		err = ip6_datagram_set_pktinfo(sk, &pktinfo, &fl);
> +		if (!err)
> +			sk->sk_bound_dev_if = fl.oif;
> +		release_sock(sk);
> +		break;
> +	}
> +

Shouldn't this stash the source address out of the fl into something?
Otherwise we lose the source address information.

It seems like adding to ip6_txoptions might be an option.
We seem to have the same issue for IPV6_2292PKTOPTIONS case too.

>  	case IPV6_2292PKTOPTIONS:
>  	{
>  		struct ipv6_txoptions *opt = NULL;
> @@ -490,7 +512,7 @@ sticky_done:
>  		msg.msg_controllen = optlen;
>  		msg.msg_control = (void*)(opt+1);
>  
> -		retv = datagram_send_ctl(&msg, &fl, opt, &junk, &junk);
> +		retv = datagram_send_ctl(sk, &msg, &fl, opt, &junk, &junk);
>  		if (retv)
>  			goto done;
>  update:
> @@ -933,6 +955,29 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
>  		val = np->ipv6only;
>  		break;
>  
> +	case IPV6_PKTINFO:
> +	{
> +		struct in6_pktinfo pktinfo;
> +
> +		lock_sock(sk);
> +		val = sk->sk_bound_dev_if;
> +		release_sock(sk);
> +
> +		/*
> +		 * XXX: we may need to clear pktinfo to avoid
> +		 * disclosing stack here.
> +		 */
> +		pktinfo.ipi6_addr = inet6_sk(sk)->saddr;
> +		pktinfo.ipi6_ifindex = val;
> +
> +		len = min_t(unsigned int, sizeof(pktinfo), len);
> +		if (put_user(len, optlen))
> +			return -EFAULT;
> +		if (copy_to_user(optval, &pktinfo, len))
> +			return -EFAULT;
> +		return 0;
> +	}
> +

This returns the bound address, not the address specified in the setsockopt.

Thanks
-vlad
