From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH] netns: embed ip6_dst_ops directly
Date: Sat, 29 Aug 2009 22:27:09 +0200
Message-ID: <4A998F1D.2050705@fr.ibm.com>
References: <20090829113449.GA3067@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	benjamin.thery@bull.net
To: Alexey Dobriyan <adobriyan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate8-bp.emea.ibm.com ([195.212.17.168]:54875 "EHLO
	mtagate8.de.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750759AbZH2U1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 16:27:10 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate8.de.ibm.com (8.13.1/8.13.1) with ESMTP id n7TKRBT2008775
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 20:27:11 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n7TKRBaO2748582
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 22:27:11 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n7TKRBAq027015
	for <netdev@vger.kernel.org>; Sat, 29 Aug 2009 22:27:11 +0200
In-Reply-To: <20090829113449.GA3067@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexey Dobriyan wrote:
> struct net::ipv6.ip6_dst_ops is separatedly dynamically allocated,
> but there is no fundamental reason for it. Embed it directly into
> struct netns_ipv6.
> 
> For that:
> * move struct dst_ops into separate header to fix circular dependencies
> 	I honestly tried not to, it's pretty impossible to do other way
> * drop dynamical allocation, allocate together with netns
> 
> For a change, remove struct dst_ops::dst_net, it's deducible
> by using container_of() given dst_ops pointer.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
> ---
> 
>  include/net/dst.h        |   23 +----------------------
>  include/net/dst_ops.h    |   28 ++++++++++++++++++++++++++++
>  include/net/netns/ipv6.h |    3 ++-
>  net/ipv6/route.c         |   34 +++++++++++++---------------------
>  4 files changed, 44 insertions(+), 44 deletions(-)
> 
> --- a/include/net/dst.h
> +++ b/include/net/dst.h
> @@ -8,6 +8,7 @@
>  #ifndef _NET_DST_H
>  #define _NET_DST_H
> 
> +#include <net/dst_ops.h>
>  #include <linux/netdevice.h>
>  #include <linux/rtnetlink.h>
>  #include <linux/rcupdate.h>
> @@ -102,28 +103,6 @@ struct dst_entry
>  	};
>  };
> 
> -
> -struct dst_ops
> -{
> -	unsigned short		family;
> -	__be16			protocol;
> -	unsigned		gc_thresh;
> -
> -	int			(*gc)(struct dst_ops *ops);
> -	struct dst_entry *	(*check)(struct dst_entry *, __u32 cookie);
> -	void			(*destroy)(struct dst_entry *);
> -	void			(*ifdown)(struct dst_entry *,
> -					  struct net_device *dev, int how);
> -	struct dst_entry *	(*negative_advice)(struct dst_entry *);
> -	void			(*link_failure)(struct sk_buff *);
> -	void			(*update_pmtu)(struct dst_entry *dst, u32 mtu);
> -	int			(*local_out)(struct sk_buff *skb);
> -
> -	atomic_t		entries;
> -	struct kmem_cache 		*kmem_cachep;
> -	struct net              *dst_net;
> -};

You will lose entries, kmem_cachep and gc_thresh per namespace, no ?
