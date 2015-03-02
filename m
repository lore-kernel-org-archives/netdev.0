From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/8] Basic MPLS support
Date: Sun, 01 Mar 2015 23:03:06 -0500 (EST)
Message-ID: <20150301.230306.2023670900391030920.davem@davemloft.net>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
	<20150227.162131.431559184124647735.davem@davemloft.net>
	<87mw3yg8da.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
	stephen@networkplumber.org, santiago@crfreenet.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46310 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753148AbbCBEDI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 23:03:08 -0500
In-Reply-To: <87mw3yg8da.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 27 Feb 2015 18:58:09 -0600

> Part of that expediency was the realization that waiting for neighbour
> resolution before transmitting packets requires the packets have dst
> entries.  Something that is not otherwise required.  That seems to add
> a noticable amount of complexity to the forwarding code.  If nothing
> else I have to manage dst objects and their packet specific lifetimes.

There is no requirement as such, in fact you can use your MPLS
forwarding frames to trigger neighbour resolution.

You just put IPv4/IPv6 addresses in your mpls routes, and then
at transmit time:

	rcu_read_lock();
	n = __ipv4_neigh_lookup_noref(&arp_tbl, &mpls_route->v4addr, dev, false);
	if (unlikely(!n))
		n = __neigh_create(&arp_tbl, &mpls_route->v4addr, dev, false);
	if (!IS_ERR(n)) {
		const struct hh_cache *hh = &n->hh;

		if ((n->nud_state & NUD_CONNECTED) && hh->hh_len)
			return neigh_hh_output(hh, skb);
		else
			return n->output(n, skb);
	}
	rcu_read_unlock();
> I think to properly handle ipv4 and ipv6 next hops I would need to pull
> the neighbour cache apart and and put it back together again while
> reexaming all of it's assumptions about which things are a good idea to
> optimize.   That feels like more work in benchmarking etc than the MPLS
> code has been so far.  

No you don't, the neigh state machine is built to properly handle
everything, see above.
