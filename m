From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: do not overwrite inetpeer metrics prematurely
Date: Thu, 6 Mar 2014 21:06:58 +0100
Message-ID: <20140306200658.GA32699@unicorn.suse.cz>
References: <20140306095054.EEC5EE6E04@unicorn.suse.cz>
 <20140306.142425.1675660751208500651.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:33930 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbaCFUHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Mar 2014 15:07:00 -0500
Content-Disposition: inline
In-Reply-To: <20140306.142425.1675660751208500651.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 06, 2014 at 02:24:25PM -0500, David Miller wrote:
> 
> > +static void rt6_metrics_to_peer(struct rt6_info *rt)
> > +{
> > +	struct inet_peer *peer = rt6_has_peer(rt) ? rt6_peer_ptr(rt) : NULL;
> > +	struct dst_entry *dst = &rt->dst;
> > +	unsigned long old = dst->_metrics;
> > +
> > +	if (!(rt->dst.flags & DST_HOST) || dst_metrics_read_only(dst))
> > +		return;
> > +	if (peer && dst_metrics_ptr(dst) == peer->metrics)
> > +		return;
> > +
> > +	dst->ops->cow_metrics(dst, old);
> > +	if (dst->_metrics != old) {
> > +		u32 *old_p = __DST_METRICS_PTR(old);
> > +
> > +		memcpy(dst_metrics_ptr(dst), old_p, RTAX_MAX * sizeof(u32));
> > +		kfree(old_p);
> > +	}
> > +}
> 
> Hmmm...  if inet_metrics_new() is true then ->cow_metrics() will copy the
> metrics from old to new.  So you therefore shouldn't have to do the copy
> explicitly here.

If we are replacing an existing host route with metrics, e.g.

  ip route add fec0::1 dev eth0 rto_min 1000
  ip route change fec0::1 dev eth0 rto_min 1500

then peer will be the existing inetpeer and inet_metrics_new() will be
false. However, we still need to copy the new metrics from the netlink
message over the old ones.

> If inet_metrics_new() is not true, you are overwriting non-new metrics.

The only problem with this is IMHO that if inet_metrics_new() is true,
i.e. when adding a new route with new inetpeer (or old inetpeer whose
metrics were not used before), the memcpy() is done twice, once in
ipv6_cow_metrics() and once in rt6_metrics_to_peer(). We are copying the
same data twice so that the result is correct but it's not efficient and
it's not nice.

The only way I can see to avoid this (except using own metrics always
instead of those in struct inetpeer as we do for non-host routes) would
be not to call ipv6_cow_metrics() at all and write a special function
for this purpose in net/ipv6/route.c which would duplicate the parts of
ipv6_cow_metrics() we really need (and add the free()). Do you think
this is the way to go?

                                                        Michal Kubecek
