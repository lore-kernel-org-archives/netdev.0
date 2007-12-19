From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] [IPv6]: IPV6_MULTICAST_IF setting is ignored on link-local
 connect()
Date: Wed, 19 Dec 2007 10:20:53 -0500
Message-ID: <476936D5.4070606@hp.com>
References: <OF7B1ADDCA.711DCE7B-ON882573B5.00820D67-882573B5.0083AEF8@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:3002 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756302AbXLSPVM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 10:21:12 -0500
In-Reply-To: <OF7B1ADDCA.711DCE7B-ON882573B5.00820D67-882573B5.0083AEF8@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Daven

David Stevens wrote:
> Brian,
> 
> OK, I see what you're trying to fix now.
> 
> I think the scope_id checks are not quite right-- they
> should be something like this:
> 
> if (addr_type&IPV6_ADDR_LINKLOCAL) {
>         if (addr_len >= sizeof(struct sockaddr_in6)) {
>                 if (sk->sk_bound_dev_if && usin->sin6_scope_id &&
>                     sk->sk_bound_dev_if != usin->sin6_scope_id) {
>                         err = -EINVAL;
>                         goto out;
>                 }
>                 if (usin->sin6_scope_id)
>                         sk->sk_bound_dev_if = usin->sin6_scope_id;
>                 if (!sk->sk_bound_dev_if &&
>                      (addr_type & IPV6_ADDR_MULTICAST))
>                         fl.oif = np->mcast_oif;
>         }
> 
>         /* connect to the link-local addres requires an interface */
>         if (!sk->sk_bound_dev_if) {
>                 err = -EINVAL;
>                 goto out;
>         }
> }

But this still requires either a SO_BINDTODEVICE or sin6_scope_id.  This
means the an application can call BINDTODEVICE(eth0), MULTICAST_IF(eth1)
issue a connect on a UDP socket an succeed?  Seems wrong to me.

Can you check section 6.7 of RFC 3542.

Thanks
-vlad

> 
>         That is (in English):
> 
>         If I did an SO_BINDTODEVICE and specified sin6_scope_id,
> then they better agree.
>         If I specified sin6_scope_id without SO_BINDTODEVICE, set
> the device to that.
>         If I get this far without a device and it's multicast, use 
> mcast_oif
>         If I get all through that and don't have a device, EINVAL.
> 
>         Does that work for you?
> 
>                                         +-DLS
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 

