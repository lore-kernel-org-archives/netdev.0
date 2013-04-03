From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH 3/3] net: frag queue per hash bucket locking
Date: Thu, 04 Apr 2013 00:11:00 +0200
Message-ID: <1365027060.12728.30.camel@localhost>
References: <20130327155238.15203.6688.stgit@dragon>
	 <20130327155601.15203.25289.stgit@dragon>
	 <1364405159.15753.26.camel@edumazet-glaptop>
	 <20130328185721.GA20223@order.stressinduktion.org>
	 <1364502164.15753.56.camel@edumazet-glaptop>
	 <20130328233002.GC20223@order.stressinduktion.org>
	 <1364513982.15753.57.camel@edumazet-glaptop>
	 <20130329003308.GD20223@order.stressinduktion.org>
	 <1364583693.3232.257.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Daniel Borkmann <dborkman@redhat.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755939Ab3DCWLP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Apr 2013 18:11:15 -0400
In-Reply-To: <1364583693.3232.257.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-03-29 at 20:01 +0100, Jesper Dangaard Brouer wrote:
> On Fri, 2013-03-29 at 01:33 +0100, Hannes Frederic Sowa wrote:
> > On Thu, Mar 28, 2013 at 04:39:42PM -0700, Eric Dumazet wrote:
> > > On Fri, 2013-03-29 at 00:30 +0100, Hannes Frederic Sowa wrote:
> > > > On Thu, Mar 28, 2013 at 01:22:44PM -0700, Eric Dumazet wrote:
> > > > > On Thu, 2013-03-28 at 19:57 +0100, Hannes Frederic Sowa wrote:
> > > > > 
> > > > > > I assume that it has to do with the usage of this code in
> > > > > > ipv6/netfilter/nf_conntrack_reasm.c, which could be invoked from process
> > > > > > context, if I read it correctly.
> > > > > 
> > > > > Then there would be a possible deadlock in current code.
> > > > 
> > > > Netfilter currently does a local_bh_disable() before entering inet_fragment
> > > > (and later enables it, again).
> > > > 
> > > 
> > > Good, so no need for the _bh() as I suspected.
> > 
> > Ack.
> > 
> > I replaced the _bh spin_locks with plain spinlocks and tested the code
> > with sending fragments and receiving fragments (netfilter and reassmbly
> > logic) with lockdep and didn't get any splats. Looks good so far.
> 
> Well, it's great to see, that you are working on solving my patch
> proposal.  While I'm on Easter vacation ;-)  Much appreciated.
> I'm officially back from vacation Tuesday, and I'll repost then (after
> testing it on my 10G testlab).

When I rebased patch-03 (on top of net-next commit a210576c) and
removed the _bh spinlock, I saw a performance regression.  BUT this
was caused by some unrelated change in-between.  See tests below.

Test (A) is what I reported before for patch-02, accepted in commit 1b5ab0de.
Test (B) verifying-retest of commit 1b5ab0de correspond to patch-02.
Test (C) is what I reported before for patch-03

Test (D) is net-next master HEAD (commit a210576c), which reveals some
(unknown) performance regression (compared against test (B)). And (D)
function as a new base-test.

(#) Test-type:  20G64K    20G3F    20G64K+DoS  20G3F+DoS  20G64K+MQ 20G3F+MQ
    ----------  -------   -------  ----------  ---------  --------  -------
(A) Patch-02  : 18848.7   13230.1   4103.04     5310.36     130.0    440.2
(B) 1b5ab0de  : 18841.5   13156.8   4101.08     5314.57     129.0    424.2
(C) Patch-03v1: 18838.0   13490.5   4405.11     6814.72     196.6    461.6

(D) a210576c  : 18321.5   11250.4   3635.34     5160.13     119.1    405.2
(E) with _bh  : 17247.3   11492.6   3994.74     6405.29     166.7    413.6
(F) without bh: 17471.3   11298.7   3818.05     6102.11     165.7    406.3

Test (E) and (F) is patch-03, with and without the _bh spinlocks.

I cannot explain the slow down for 20G64K (but its an artificial
"labtest" so I'm not worried).  But the other results does show
improvements.  And test (E) "with _bh" version is slightly better.

p.s. Damm, it too a bit longer, than expected, to test this fairly small
correction to the patch...
-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
