From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH net-next 2/3] ipv6: use newly introduced __ipv6_addr_needs_scope_id
 and ipv6_iface_scope_id
Date: Tue, 12 Feb 2013 21:51:06 -0500
Message-ID: <511AFF9A.8040506@hp.com>
References: <20130212221634.GA7212@order.stressinduktion.org> <20130213001357.GB1096@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:9816 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752915Ab3BMCvK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Feb 2013 21:51:10 -0500
In-Reply-To: <20130213001357.GB1096@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/12/2013 07:13 PM, Hannes Frederic Sowa wrote:
>> --- a/net/ipv6/af_inet6.c
>> +++ b/net/ipv6/af_inet6.c
>> @@ -323,7 +323,7 @@ int inet6_bind(struct socket *sock, struct sockaddr *uaddr, int addr_len)
>>  			struct net_device *dev = NULL;
>>  
>>  			rcu_read_lock();
>> -			if (addr_type & IPV6_ADDR_LINKLOCAL) {
>> +			if (__ipv6_addr_needs_scope_id(addr_type)) {
>>  				if (addr_len >= sizeof(struct sockaddr_in6) &&
>>  				    addr->sin6_scope_id) {
>>  					/* Override any existing binding, if another one
> 
> By trying to setup the multicast interface scoped routes by default I
> just found a bug in this patch essentially breaking ipv6 multicast. I
> overlooked that ipv6_addr_type strips off the scopes, thus my check if
> a multicast address needs a scope_id always returns true. I'll check
> if I can convert the ipv6_addr_type calls to __ipv6_addr_type and will
> reroll the patch.  Sorry, my tests were too focused on interface/local
> multicast. :(

I'd always thought of adding helper inlines like these in net/ipv6.h:

static inline bool ipv6_addr_linklocal(const struct in6_addr *a)
{
        return ((a->s6_addr32[0] & htonl(0xFFC00000)) == htonl(0xFE800000));
}

static inline bool ipv6_addr_mc_linklocal(const struct in6_addr *a)
{
        return (((a->s6_addr32[0] & htonl(0xFF000000)) == htonl(0xFF000000)) &&
                ((a->s6_addr32[1] & 0x0F) == IPV6_ADDR_SCOPE_LINKLOCAL));
}

Maybe something like that would help here?

When I saw this in patch 3/3 it just seemed like the long way to determine if
the address was a link-local multicast:

	!__ipv6_addr_needs_scope_id(__ipv6_addr_type(&hdr->daddr))

The helper isn't as generic as your patch, but more direct.

-Brian
