From: KOVACS Krisztian <hidden@balabit.hu>
Subject: Re: [PATCH/RFC 01/10] Implement local diversion of IPv4 skbs
Date: Wed, 10 Jan 2007 11:17:47 +0100
Message-ID: <200701101117.47576@nienna>
References: <20070103163357.14635.37754.stgit@nienna.balabit> <20070103163427.14635.49596.stgit@nienna.balabit> <45A48BD6.5010507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	Balazs Scheidler <bazsi@balabit.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:1129 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964813AbXAJKSO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 05:18:14 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id F3C0A4C0FA
	for <netdev@vger.kernel.org>; Wed, 10 Jan 2007 11:18:07 +0100 (CET)
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <45A48BD6.5010507@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


  Hi,

On Wednesday 10 January 2007 07:46, Patrick McHardy wrote:
> > +	rcu_read_lock();
> > +	for (rth = rcu_dereference(rt_hash_table[hash].chain); rth;
> > +	     rth = rcu_dereference(rth->u.rt_next)) {
> > +		if (rth->fl.fl4_dst == iph->daddr &&
> > +		    rth->fl.fl4_src == iph->saddr &&
> > +		    rth->fl.iif == iif &&
> > +		    rth->fl.oif == 0 &&
> > +		    rth->fl.mark == skb->mark &&
> > +		    (rth->u.dst.flags & DST_DIVERTED) &&
> > +		    rth->fl.fl4_tos == tos) {
>
> Mark and tos look unnecessary here since they don't affect the further
> processing of the packet.

  Indeed, thanks for spotting it.

> > +			rth->u.dst.lastuse = jiffies;
> > +			dst_hold(&rth->u.dst);
> > +			rth->u.dst.__use++;
> > +			RT_CACHE_STAT_INC(in_hit);
> > +			rcu_read_unlock();
> > +
> > +			dst_release(skb->dst);
> > +			skb->dst = (struct dst_entry*)rth;
> > +
> > +			if (sk) {
> > +				sock_hold(sk);
> > +				skb->sk = sk;
>
> This looks racy, the socket could be closed between the lookup and
> the actual use. Why do you need the socket lookup at all, can't
> you just divert all packets selected by iptables?

  Yes, it's racy, but I this is true for the "regular" socket lookup, too. 
Take UDP for example: __udp4_lib_rcv() does the socket lookup, gets a 
reference to the socket, and then calls udp_queue_rcv_skb() to queue the 
skb. As far as I can see there's nothing there which prevents the socket 
from being closed between these calls. sk_common_release() even documents 
this behaviour:

	[...]
	if (sk->sk_prot->destroy)
		sk->sk_prot->destroy(sk);

	/*
	 * Observation: when sock_common_release is called, processes have
	 * no access to socket. But net still has.
	 * Step one, detach it from networking:
	 *
	 * A. Remove from hash tables.
	 */

	sk->sk_prot->unhash(sk);

	/*
	 * In this point socket cannot receive new packets, but it is possible
	 * that some packets are in flight because some CPU runs receiver and
	 * did hash table lookup before we unhashed socket. They will achieve
	 * receive queue and will be purged by socket destructor.
	 *
	 * Also we still have packets pending on receive queue and probably,
	 * our own packets waiting in device queues. sock_destroy will drain
	 * receive queue, but transmitted packets will delay socket destruction
	 * until the last reference will be released.
	 */
	[...]

  Of course it's true that doing early lookups and storing that reference 
in the skb widens the window considerably, but I think this race is 
already handled. Or is there anything I don't see?

-- 
 Regards,
  Krisztian Kovacs
