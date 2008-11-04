From: Brian Haley <brian.haley@hp.com>
Subject: Re: ipv6_addr_type() and mapped IPv4 loopback
Date: Tue, 04 Nov 2008 16:16:48 -0500
Message-ID: <4910BBC0.1060309@hp.com>
References: <06930890-5BC3-4BE2-97CC-B3F6DF33B794@oracle.com> <490FB460.2010501@hp.com> <443B1A57-9994-4555-BCE6-B66B8F406DA2@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:35878 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754296AbYKDVQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2008 16:16:50 -0500
In-Reply-To: <443B1A57-9994-4555-BCE6-B66B8F406DA2@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> Hi Brian-
> 
> On Nov 3, 2008, at Nov 3, 2008, 9:33 PM, Brian Haley wrote:
>> Chuck Lever wrote:
>>> The __ipv6_addr_type() function does not recognize the mapped IPv4 
>>> loopback address:
>>>   ::ffff:7f00:0001
>>> as type IPV6_ADDR_LOOPBACK.  Is this intentional?
>>
>> I would think that since the IPv6 loopback address is ::1, and 
>> ipv4-mapped is ::ffff:* that this would be IPV6_ADDR_MAPPED.  That's 
>> what RFC 4291 seems to say.
> 
> So the answer to my original question is then "yes, this is 
> intentional," correct?

I didn't design the Linux IPv6 stack, but it looks right to me.

> On a system with an AF_INET6 listener, legacy applications use 127.0.0.1 
> to contact a local listener.  The incoming source address will be 
> ::ffff:7f00:0001, not ::1.  This means IPv6-enabled applications have to 
> perform a separate check for ::ffff:7f00:0001 if they are looking for 
> loopback addresses.

Right, applications have to see if it's really an IPv4 address if 
necessary.  If you're just looking for loopback and it's in the kernel, 
it's only about this much code:

	if (ipv6_addr_type(addr->sin6_addr) == IPV6_ADDR_MAPPED) {
                 __be32 v4addr = addr->sin6_addr.s6_addr32[3];
                 if (ipv4_is_loopback(v4addr)) {
                         /* it's 127.0.0.* */
                 }
	}

There's the IN6_IS_ADDR_V4MAPPED() macro for user-space as well.

> The kernel's lockd must verify that an NLM request comes from the local 
> user space.  It's not a lot of extra logic, but it is a subtlety.

Agreed.

-Brian
