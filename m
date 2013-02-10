From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: Re: [IPv6] interface-local multicast escapes the local node
Date: Mon, 11 Feb 2013 03:42:53 +0900
Message-ID: <5117EA2D.1020106@linux-ipv6.org>
References: <20130206084949.GA11193@eerihug-hybrid.ki.sw.ericsson.se> <20130206121248.GC10290@order.stressinduktion.org> <5112759E.90104@linux-ipv6.org> <20130206165415.GB19537@order.stressinduktion.org> <20130209121005.GB23281@order.stressinduktion.org> <5116595E.2080601@linux-ipv6.org> <20130210153230.GA21377@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Erik Hugne <erik.hugne@ericsson.com>, netdev@vger.kernel.org,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:40230 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754843Ab3BJSmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Feb 2013 13:42:54 -0500
In-Reply-To: <20130210153230.GA21377@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa wrote:
> On Sat, Feb 09, 2013 at 11:12:46PM +0900, YOSHIFUJI Hideaki wrote:
>> Hi,
>>
>> Hannes Frederic Sowa wrote:
>>> On Wed, Feb 06, 2013 at 05:54:15PM +0100, Hannes Frederic Sowa wrote:
>>>> On Thu, Feb 07, 2013 at 12:24:14AM +0900, YOSHIFUJI Hideaki wrote:
>>>>> NAK.  I think we should select routes via loopback device here.
>>>>
>>>> Will try your idea, thanks.
>>>
>>> Does this patch look reasonable? Btw. i am pleased to see this kind of
>>> things work out as expected most of the time (addrtype checking etc. all
>>> in place). :)
>>>
>>
>> Well, I rethink of what "interface-local" means.
>>
>> It seems applications will join ff01::/16%eth0 instead of ff01::/16%lo.
>> If so, your original patch seems better.  My bad, sorry.
> 
> I was looking at getpeername et. al. where we should report the scope
> back to the user. A common pattern is:
> 
>                         if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
>                                 sin->sin6_scope_id = IP6CB(skb)->iif;
> 
> I propose to introduce something like 'bool ipv6_addr_intf_scoped(in6_addr)'
> and let it check for ll addresses and interface scoped addresses.

Hmm, maybe, we might want to say:

__u32 __ipv6_iface_scope_id(int type, unsigned int iface)
{
	if (type == IPV6_ADDR_ANY ||
	    type & IPV6_ADDR_LOOPBACK ||
	    __ipv6_addr_src_scope(type) > IPV6_ADDR_SCOPE_LINKLOCAL)
		return 0;
	return iface;
}

__u32 ipv6_iface_scope_id(const struct in6_addr *addr, unsigned int iface)
{
	return __ipv6_iface_scope_id(__ipv6_addr_type(addr), iface);
}

And then,
	sin->sin6_scope_id = __ipv6_iface_scope_id(__ipv6_addr_type(&sin->sin6_addr),
						   IP6CB(skb)->iif);
or
	sin->sin6_scope_id = ipv6_iface_scope_id(&sin->sin6_addr, IP6CB(skb)->iif);

--yoshfuji
