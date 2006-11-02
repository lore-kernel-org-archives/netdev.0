From: Ville Nuorvala <vnuorval@tcs.hut.fi>
Subject: Re: [PATCH 9/13] [SCTP] Merge IPv4 and IPv6 versions of	get_saddr()
 with their corresponding get_dst().
Date: Thu, 02 Nov 2006 14:32:34 +0200
Message-ID: <4549E562.8030704@tcs.hut.fi>
References: <453421AD.1010906@tcs.hut.fi> <1161971255.5820.13.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from neon.tcs.hut.fi ([130.233.215.20]:29834 "EHLO mail.tcs.hut.fi")
	by vger.kernel.org with ESMTP id S1752193AbWKBMcm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 07:32:42 -0500
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1161971255.5820.13.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/27/06 20:47, Sridhar Samudrala wrote:
> On Tue, 2006-10-17 at 03:19 +0300, Ville Nuorvala wrote:
>> As the IPv6 route lookup now also returns the selected source address
>> there is no need for a separate source address lookup. In fact, the
>> source address selection needs to be moved to get_dst() because the
>> selected IPv6 source address isn't always stored in the route.
>> Sometimes this makes it impossible to guess the correct address later on.
>>
> 
> Ville,
> 
> Overall the patch looks pretty good. I found only 1 issue in 
> sctp_v6_get_dst(). See below.
> 
> 
> <snip>
> 
> 
>> +/* Returns the dst cache entry for the given source and destination ip
>> + * addresses.
>> + */
>> +static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
>> +					 union sctp_addr *daddr,
>> +					 union sctp_addr *saddr)
>> +{
>> +	struct dst_entry *dst;
>> +	struct flowi fl;
>> +	struct sctp_bind_addr *bp;
>> +	rwlock_t *addr_lock;
>> +	struct sctp_sockaddr_entry *laddr;
>> +	struct list_head *pos;
>> +	struct rt6_info *rt;
>> +	union sctp_addr baddr;
>> +	sctp_scope_t scope;
>> +	__u8 matchlen = 0;
>> +	__u8 bmatchlen;
>> +
>> +	memset(&fl, 0, sizeof(fl));
>> +	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
>> +	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
>> +		fl.oif = daddr->v6.sin6_scope_id;
>> +
>> +	ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
>> +	SCTP_DEBUG_PRINTK("%s: DST=" NIP6_FMT " SRC=" NIP6_FMT " ",
>> +			  __FUNCTION__, NIP6(fl.fl6_dst), NIP6(fl.fl6_src));
>> +
>> +	dst = ip6_route_output(NULL, &fl);
>> +	if (dst->error) {
>> +		dst_release(dst);
>> +		dst = NULL;
>> +	}
>> +	if (!ipv6_addr_any(&saddr->v6.sin6_addr))
>> +		goto out;
>> +	if (!asoc) {
>> +		if (dst)
>> +			ipv6_addr_copy(&saddr->v6.sin6_addr, &fl.fl6_src);
>> +		goto out;
>> +	}
>> +	bp = &asoc->base.bind_addr;
>> +	addr_lock = &asoc->base.addr_lock;
>> +
>> +	if (dst) {
>> +		/* Walk through the bind address list and look for a bind
>> +		 * address that matches the source address of the returned rt.
>> +		 */
>> +		sctp_v6_fl_saddr(&baddr, &fl, bp->port);
> Here we are checking if the source address returned in the dst matches one of
> the address in the bind address list of the association. Not the source address
> that is passed to this routine(it could be INADDRY_ANY).
> So this should be changed back to sctp_v6_dst_saddr().

No, see that's the problem. The source address isn't always stored in
the  rt6_info. Therefore I copy the address into the flowi, so after
ip6_route_output() fl does indeed contain the selected source address.
Sorry if I didn't cc you all relevant patches from the patch set.

Anyway there are still some unresolved issues with my code, but it's
nice to know I didn't at least mess up SCTP in a big way ;-)

Thanks,
Ville
