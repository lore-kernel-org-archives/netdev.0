From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC V3] net: don't wait for order-3 page allocation
Date: Thu, 18 Jun 2015 16:43:11 +0200
Message-ID: <20150618144311.GF5858@dhcp22.suse.cz>
References: <0099265406c32b9b9057de100404a4148d602cdd.1434066549.git.shli@fb.com>
 <557AA834.8070503@suse.cz>
 <alpine.DEB.2.10.1506171602300.8203@chino.kir.corp.google.com>
 <20150618143019.GE5858@dhcp22.suse.cz>
 <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Rientjes <rientjes@google.com>,
	Vlastimil Babka <vbabka@suse.cz>, Shaohua Li <shli@fb.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	kernel-team <Kernel-team@fb.com>, clm@fb.com, linux-mm@kvack.org,
	dbavatar@gmail.com
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48797 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752029AbbFROnP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 18 Jun 2015 10:43:15 -0400
Content-Disposition: inline
In-Reply-To: <CANn89iLr2iNV3VjA4POPpfsmOpyB7jP2-wPiAkCOcA+Oh+2=5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu 18-06-15 07:35:53, Eric Dumazet wrote:
> On Thu, Jun 18, 2015 at 7:30 AM, Michal Hocko <mhocko@suse.cz> wrote:
> 
> > Abusing __GFP_NO_KSWAPD is a wrong way to go IMHO. It is true that the
> > _current_ implementation of the allocator has this nasty and very subtle
> > side effect but that doesn't mean it should be abused outside of the mm
> > proper. Why shouldn't this path wake the kswapd and let it compact
> > memory on the background to increase the success rate for the later
> > high order allocations?
> 
> I kind of agree.
> 
> If kswapd is a problem (is it ???) we should fix it, instead of adding
> yet another flag to some random locations attempting
> memory allocations.

No, kswapd is not a problem. The problem is ~__GFP_WAIT allocation can
access some portion of the memory reserves (see gfp_to_alloc_flags resp.
__zone_watermark_ok and ALLOC_HARDER). __GFP_NO_KSWAPD is just a dirty
hack to not give that access which was introduced for THP AFAIR.

The implicit access to memory reserves for non sleeping allocation has
been there for ages and it might be not suitable for this particular
path but that doesn't mean another gfp flag with a different side effect
should be hijacked. We should either stop doing that implicit access to
memory reserves and give __GFP_RESERVE or add the __GFP_NORESERVE. But
that is a problem to be solved in the mm proper. Spreading subtle
dependencies outside of mm will just make situation worse. 
-- 
Michal Hocko
SUSE Labs
