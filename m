From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH net-next 0/8] Basic MPLS support
Date: Sun, 01 Mar 2015 23:10:12 -0600
Message-ID: <871tl8dlxn.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
	<20150301.230306.2023670900391030920.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:46068 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbbCBFNy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Mar 2015 00:13:54 -0500
In-Reply-To: <20150301.230306.2023670900391030920.davem@davemloft.net> (David
	Miller's message of "Sun, 01 Mar 2015 23:03:06 -0500 (EST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Fri, 27 Feb 2015 18:58:09 -0600
>
>> Part of that expediency was the realization that waiting for neighbour
>> resolution before transmitting packets requires the packets have dst
>> entries.  Something that is not otherwise required.  That seems to add
>> a noticable amount of complexity to the forwarding code.  If nothing
>> else I have to manage dst objects and their packet specific lifetimes.
>
> There is no requirement as such, in fact you can use your MPLS
> forwarding frames to trigger neighbour resolution.
>
> You just put IPv4/IPv6 addresses in your mpls routes, and then
> at transmit time:
>
> 	rcu_read_lock();
> 	n = __ipv4_neigh_lookup_noref(&arp_tbl, &mpls_route->v4addr, dev, false);
> 	if (unlikely(!n))
> 		n = __neigh_create(&arp_tbl, &mpls_route->v4addr, dev, false);
> 	if (!IS_ERR(n)) {
> 		const struct hh_cache *hh = &n->hh;
>
> 		if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
> 			return neigh_hh_output(hh, skb);
> 		else
> 			return n->output(n, skb);
> 	}
> 	rcu_read_unlock();

Which fails miserably.  neigh_hh_output will use an ethertype of
ETH_P_IP from the cached header, instead of a header type of
ETH_P_MPLS_UC from skb->protocol.

Just using n->output is better but if you look at neigh_resolve_output
frames without a dst entry will be dropped.

>> I think to properly handle ipv4 and ipv6 next hops I would need to pull
>> the neighbour cache apart and and put it back together again while
>> reexaming all of it's assumptions about which things are a good idea to
>> optimize.   That feels like more work in benchmarking etc than the MPLS
>> code has been so far.  
>
> No you don't, the neigh state machine is built to properly handle
> everything, see above.

The state machine is fine.  Things like hardware header caching and teql
driver cause some interesting issues.

That said I have figured out how to sourt out the neighbour cache
without touching the fast path.  (Assuming I don't try to use the
cached header).

My neighbour table patches just need a final look over and then I will
send them out.

Eric
