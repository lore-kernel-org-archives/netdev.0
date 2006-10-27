From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [PATCH 9/13] [SCTP] Merge IPv4 and IPv6 versions of
	get_saddr() with their corresponding get_dst().
Date: Fri, 27 Oct 2006 10:47:35 -0700
Message-ID: <1161971255.5820.13.camel@w-sridhar2.beaverton.ibm.com>
References: <453421AD.1010906@tcs.hut.fi>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	Thomas Graf <tgraf@suug.ch>, kim.nordlund@nokia.com,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:12758 "EHLO e1.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1750708AbWJ0SbA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2006 14:31:00 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9RIUwHV018044
	for <netdev@vger.kernel.org>; Fri, 27 Oct 2006 14:30:58 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9RIUx64235068
	for <netdev@vger.kernel.org>; Fri, 27 Oct 2006 14:30:59 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9RIUsJ8007464
	for <netdev@vger.kernel.org>; Fri, 27 Oct 2006 14:30:55 -0400
To: Ville Nuorvala <vnuorval@tcs.hut.fi>
In-Reply-To: <453421AD.1010906@tcs.hut.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-17 at 03:19 +0300, Ville Nuorvala wrote:
> As the IPv6 route lookup now also returns the selected source address
> there is no need for a separate source address lookup. In fact, the
> source address selection needs to be moved to get_dst() because the
> selected IPv6 source address isn't always stored in the route.
> Sometimes this makes it impossible to guess the correct address later on.
> 

Ville,

Overall the patch looks pretty good. I found only 1 issue in 
sctp_v6_get_dst(). See below.


<snip>


> 
> +/* Returns the dst cache entry for the given source and destination ip
> + * addresses.
> + */
> +static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
> +					 union sctp_addr *daddr,
> +					 union sctp_addr *saddr)
> +{
> +	struct dst_entry *dst;
> +	struct flowi fl;
> +	struct sctp_bind_addr *bp;
> +	rwlock_t *addr_lock;
> +	struct sctp_sockaddr_entry *laddr;
> +	struct list_head *pos;
> +	struct rt6_info *rt;
> +	union sctp_addr baddr;
> +	sctp_scope_t scope;
> +	__u8 matchlen = 0;
> +	__u8 bmatchlen;
> +
> +	memset(&fl, 0, sizeof(fl));
> +	ipv6_addr_copy(&fl.fl6_dst, &daddr->v6.sin6_addr);
> +	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
> +		fl.oif = daddr->v6.sin6_scope_id;
> +
> +	ipv6_addr_copy(&fl.fl6_src, &saddr->v6.sin6_addr);
> +	SCTP_DEBUG_PRINTK("%s: DST=" NIP6_FMT " SRC=" NIP6_FMT " ",
> +			  __FUNCTION__, NIP6(fl.fl6_dst), NIP6(fl.fl6_src));
> +
> +	dst = ip6_route_output(NULL, &fl);
> +	if (dst->error) {
> +		dst_release(dst);
> +		dst = NULL;
> +	}
> +	if (!ipv6_addr_any(&saddr->v6.sin6_addr))
> +		goto out;
> +	if (!asoc) {
> +		if (dst)
> +			ipv6_addr_copy(&saddr->v6.sin6_addr, &fl.fl6_src);
> +		goto out;
> +	}
> +	bp = &asoc->base.bind_addr;
> +	addr_lock = &asoc->base.addr_lock;
> +
> +	if (dst) {
> +		/* Walk through the bind address list and look for a bind
> +		 * address that matches the source address of the returned rt.
> +		 */
> +		sctp_v6_fl_saddr(&baddr, &fl, bp->port);
Here we are checking if the source address returned in the dst matches one of
the address in the bind address list of the association. Not the source address
that is passed to this routine(it could be INADDRY_ANY).
So this should be changed back to sctp_v6_dst_saddr().

Thanks
Sridhar

> +		sctp_read_lock(addr_lock);
> +		list_for_each(pos, &bp->address_list) {
> +			laddr = list_entry(pos, struct sctp_sockaddr_entry,
> +					   list);
> +			if (!laddr->use_as_src)
> +				continue;
> +			if (sctp_v6_cmp_addr(&baddr, &laddr->a))
> +				goto init_saddr;
> +		}
> +		sctp_read_unlock(addr_lock);
> +
> +		/* Invalid rt or none of the bound addresses match the source
> +		 * address. So release it.
> +		 */
> +		dst_release(dst);
> +		dst = NULL;
> +	}
> +
> +	/* Go through the bind address list and find the best source address
> +	 * that matches the scope of the destination address.
> +	 */
> +	memset(&baddr, 0, sizeof(union sctp_addr));
> +	scope = sctp_scope(daddr);
> +	sctp_read_lock(addr_lock);
> +	list_for_each(pos, &bp->address_list) {
> +		laddr = list_entry(pos, struct sctp_sockaddr_entry, list);
> +		
> +		if (!laddr->use_as_src ||
> +		    laddr->a.sa.sa_family != AF_INET6 ||
> +		    scope > sctp_scope(&laddr->a) ||
> +		    (ipv6_addr_type(&laddr->a.v6.sin6_addr) &
> +		     IPV6_ADDR_LINKLOCAL &&
> +		     laddr->a.v6.sin6_scope_id != fl.oif))
> +			continue;
> +
> +		bmatchlen = sctp_v6_addr_match_len(daddr, &laddr->a);
> +		if (!dst || (matchlen < bmatchlen)) {
> +			struct dst_entry *dst2;
> +			ipv6_addr_copy(&fl.fl6_src, &laddr->a.v6.sin6_addr);
> +			dst2 = ip6_route_output(NULL, &fl);
> +			if (dst2->error) {
> +				dst_release(dst2);
> +				dst2 = NULL;
> +				continue;
> +			}
> +			dst_release(dst);
> +			dst = dst2;
> +			memcpy(&baddr, &laddr->a, sizeof(union sctp_addr));
> +			matchlen = bmatchlen;
> +		}
> +	}
> +	if (dst)
> +		goto init_saddr;
> +out_unlock:
> +	sctp_read_unlock(addr_lock);
> +out:
> +	if (dst) {
> +		rt = (struct rt6_info *) dst;
> +		SCTP_DEBUG_PRINTK("SRC=" NIP6_FMT
> +				  " rt6_dst=" NIP6_FMT
> +				  " rt6_src=" NIP6_FMT "\n",
> +				  NIP6(saddr->v6.sin6_addr),
> +				  NIP6(rt->rt6i_dst.addr),
> +				  NIP6(rt->rt6i_src.addr));
> +	} else
> +		SCTP_DEBUG_PRINTK("NO ROUTE\n");
> +	return dst;
> +init_saddr:
> +	memcpy(saddr, &baddr, sizeof(union sctp_addr));
> +	goto out_unlock;
> +}



