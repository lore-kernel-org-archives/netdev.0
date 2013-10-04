From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: [PATCH net-next v2 2/3] udp: Add udp early demux
Date: Fri, 4 Oct 2013 16:05:11 -0500
Message-ID: <20131004210511.GA12356@sbohrermbp13-local.rgmadvisors.com>
References: <1380914896-24754-1-git-send-email-shawn.bohrer@gmail.com>
 <1380914896-24754-3-git-send-email-shawn.bohrer@gmail.com>
 <1380916926.3564.30.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, tomk@rgmadvisors.com,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f171.google.com ([209.85.223.171]:51774 "EHLO
	mail-ie0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752248Ab3JDVF1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Oct 2013 17:05:27 -0400
Received: by mail-ie0-f171.google.com with SMTP id at1so10288941iec.2
        for <netdev@vger.kernel.org>; Fri, 04 Oct 2013 14:05:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1380916926.3564.30.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 04, 2013 at 01:02:06PM -0700, Eric Dumazet wrote:
> On Fri, 2013-10-04 at 14:28 -0500, Shawn Bohrer wrote:
> 
> > +
> > +/* For unicast we should only early demux connected sockets or we can
> > + * break forwarding setups.  The chains here can be long so only check
> > + * if the first socket is an exact match and if not move on.
> > + */
> > +static struct sock *__udp4_lib_demux_lookup(struct net *net,
> > +					    __be16 loc_port, __be32 loc_addr,
> > +					    __be16 rmt_port, __be32 rmt_addr,
> > +					    int dif)
> > +{
> > +	struct sock *sk, *result;
> > +	struct hlist_nulls_node *node;
> > +	unsigned short hnum = ntohs(loc_port);
> > +	unsigned int slot = udp_hashfn(net, hnum, udp_table.mask);
> > +	struct udp_hslot *hslot = &udp_table.hash[slot];
> > +	INET_ADDR_COOKIE(acookie, rmt_addr, loc_addr)
> > +	const __portpair ports = INET_COMBINED_PORTS(rmt_port, hnum);
> > +
> > +	rcu_read_lock();
> > +	result = NULL;
> > +	sk_nulls_for_each_rcu(sk, node, &hslot->head) {
> > +		if (INET_MATCH(sk, net, acookie,
> > +			       rmt_addr, loc_addr, ports, dif))
> > +			result = sk;
> > +		/* Only check first socket in chain */
> > +		break;
> > +	}
> > +
> > +	if (result) {
> > +		if (unlikely(!atomic_inc_not_zero_hint(&result->sk_refcnt, 2)))
> > +			result = NULL;
> 
> Here you must check again the keys (because of UDP sockets being
> SLAB_DESTROY_BY_RCU , this socket might have been freed and reused
> elsewhere)
> 
> 	else
> 		if (unlikely!(INET_MATCH(result, net, acookie,
> 					 rmt_addr, loc_addr,
> 					 ports, dif))) {
> 			sock_put(result);
> 			result = NULL;
> 		}
 
Same thing must be true in the multicast case correct? I'll fix them
both.

--
Shawn
