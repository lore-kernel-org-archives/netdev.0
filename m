From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next] route: fix breakage after moving lwtunnel
 state
Date: Wed, 26 Aug 2015 18:19:26 +0200
Message-ID: <20150826181926.0444240f@griffin>
References: <a80cafb781c91314f90613c3e7d2ed4268eb4f06.1440153500.git.jbenc@redhat.com>
	<20150823.165103.2104601245219561984.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60981 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752794AbbHZQTa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Aug 2015 12:19:30 -0400
In-Reply-To: <20150823.165103.2104601245219561984.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 23 Aug 2015 16:51:03 -0700 (PDT), David Miller wrote:
> From: Jiri Benc <jbenc@redhat.com>
> Date: Fri, 21 Aug 2015 12:41:14 +0200
> 
> > @@ -99,6 +99,9 @@ struct dst_entry {
> >  	atomic_t		__refcnt;	/* client references	*/
> >  	int			__use;
> >  	unsigned long		lastuse;
> > +#ifndef CONFIG_64BIT
> > +	struct lwtunnel_state   *lwtstate;
> > +#endif
> >  	union {
> >  		struct dst_entry	*next;
> >  		struct rtable __rcu	*rt_next;
> 
> I'm going to apply this to fix the build error without reverting your
> change entirely, but this is really an undesirable solution.
> 
> This cache line of the SKB is for write heavy members of struct
> dst_entry and so if you put a read-mostly member here it's going to
> result in performance problems.

I've spent the last few days taking measurements using tbench (which was
originally used for dst_entry reshuffling) and netperf (super_netperf
with various number of concurrent TCP streams) on i686 and found no
regression introduced by this.

This looks somehow surprising until we look at where and how lwtstate is
used. In non-tunnel case, it's either:

(1) used in netlink route notifications or
(2) used together with the first few fields in struct rtable/rt6_info or
(3) it's a skb_tunnel_info call.

No more cases than those three. Of those, (1) is not of much concern.

As for (2), the first few fields in struct rtable and struct rt6_info share
the same cacheline with __refcnt, thus accessing the lwtstate makes no
difference here.

About (3), skb_tunnel_info is called from ip_route_input_slow and
ip6_route_input. However, skb->dst is set only in case of a metadata
dst_entry. In such case, tunnel info is fetched from metadata; otherwise,
skb->dst is NULL. In either case, lwtstate is not accessed at all.

This confirms what I measured - placing lwtstate in the same cacheline as
__refcnt has no impact on performance in non-tunneling case.

As for tunneling, I did not see any performance degradation after my patch
in most cases. However, there were some cases where there was small
degradation (<2%). I bisected it to the addition of IPv6 fields into
ip_tunnel_key (i.e. commit c1ea5d672aaf). This is not much conclusive,
though, the variation of the benchmark results was relatively high and this
might be a noise. However, there's definitely room for performance
improvement here, the lwtunnel vxlan throughput is at about ~40% of the
non-vxlan throughput. I did not spend too much time on analyzing this, yet,
but it's clear the dst_entry layout is not our biggest concern here.

As the result, I think that the lwtstate field may stay where it is. For
simplification of the code and to get rid of the #ifdefs, we can have it
at the end of the struct also for 64bit case. Let me know if you prefer
this, I'll submit a patch.

Please let me know if you disagree with my analysis above.

Thanks,

  Jiri

-- 
Jiri Benc
