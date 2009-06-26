From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: weird problem
Date: Fri, 26 Jun 2009 09:05:45 +0000
Message-ID: <20090626090545.GB6445@ff.dom.local>
References: <4A43DB99.70602@gmail.com> <20090626083719.GA6445@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: =?us-ascii?B?PT9JU08tODg1OS0yP1E/UGF3ZT1CM19TdGFzemV3c2tpPz0=?=
	<pstaszewski@itcare.pl>,
	Linux Network Development list <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f213.google.com ([209.85.220.213]:60456 "EHLO
	mail-fx0-f213.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758564AbZFZJFv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 05:05:51 -0400
Received: by fxm9 with SMTP id 9so1962758fxm.37
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 02:05:51 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20090626083719.GA6445@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jun 26, 2009 at 08:37:19AM +0000, Jarek Poplawski wrote:
> On 25-06-2009 22:18, Eric Dumazet wrote:
> > Pawe? Staszewski a ?crit :
> >> Ok
> >>
> >> After this day of observation im near 100% sure that this cpu load is
> >> made by route cahce flushes
> >> When route cache increase to its "net.ipv4.route.gc_thresh" size or is
> >> near that size
> >> system is starting to drop some routes from cache then cpu load is
> >> increase from 2% to near 80%
> >> after cleaning / flush cache when cache is filling cpu load is again
> >> normal 2%
> >>
> >> Someone know how to resolve this ?
> >> on kernels < 2.6.29 i don't see this, all start after upgrade from
> >> 2.6.28 to 2.6.29 - then i try 2.6.29.1 , 2.6.29.3 and 2.6.30 and on all
> >> this kernels >= 2.6.29 problem with cpu load is the same.
> >>
> >> I can minimize this cpu fluctuations by changing of route cache /proc
> >> parameters but the best result for my router was
> >>
> >> 15 sec of 2% cpu
> >> and after
> >> 15sec of 80% cpu
> >>
> >>
> >> Regards
> >> Pawel Staszewski
> > 
> > 
> > I believe this is known 2.6.29 regressions
> > 
> > Following two commits should correct the problem you have
> > 
> > Your best bet would be to try 2.6.31-rc1, and tell us if this recent kernel
> > is ok on your machine ?
> 
> 
> Btw., the first of these commits is in 2.6.30, which according to

And the second as well.

Jarek P.

> Pawel was tried. And IMHO trying -rc1 on a production system needs
> a lot of bravery.
> 
> Jarek P.
> 
> > 
> > 
> > 
> > commit 1ddbcb005c395518c2cd0df504cff3d4b5c85853
> > Author: Eric Dumazet <dada1@cosmosbay.com>
> > Date:   Tue May 19 20:14:28 2009 +0000
> > 
> >     net: fix rtable leak in net/ipv4/route.c
> > 
> >     Alexander V. Lukyanov found a regression in 2.6.29 and made a complete
> >     analysis found in http://bugzilla.kernel.org/show_bug.cgi?id=13339
> >     Quoted here because its a perfect one :
> > 
> >     begin_of_quotation
> >      2.6.29 patch has introduced flexible route cache rebuilding. Unfortunately the
> >      patch has at least one critical flaw, and another problem.
> > 
> >      rt_intern_hash calculates rthi pointer, which is later used for new entry
> >      insertion. The same loop calculates cand pointer which is used to clean the
> >      list. If the pointers are the same, rtable leak occurs, as first the cand is
> >      removed then the new entry is appended to it.
> > 
> >      This leak leads to unregister_netdevice problem (usage count > 0).
> > 
> >      Another problem of the patch is that it tries to insert the entries in certain
> >      order, to facilitate counting of entries distinct by all but QoS parameters.
> >      Unfortunately, referencing an existing rtable entry moves it to list beginning,
> >      to speed up further lookups, so the carefully built order is destroyed.
> > 
> >      For the first problem the simplest patch it to set rthi=0 when rthi==cand, but
> >      it will also destroy the ordering.
> >     end_of_quotation
> > 
> >     Problematic commit is 1080d709fb9d8cd4392f93476ee46a9d6ea05a5b
> >     (net: implement emergency route cache rebulds when gc_elasticity is exceeded)
> > 
> >     Trying to keep dst_entries ordered is too complex and breaks the fact that
> >     order should depend on the frequency of use for garbage collection.
> > 
> >     A possible fix is to make rt_intern_hash() simpler, and only makes
> >     rt_check_expire() a litle bit smarter, being able to cope with an arbitrary
> >     entries order. The added loop is running on cache hot data, while cpu
> >     is prefetching next object, so should be unnoticied.
> > 
> >     Reported-and-analyzed-by: Alexander V. Lukyanov <lav@yar.ru>
> > 
> > commit cf8da764fc6959b7efb482f375dfef9830e98205
> > Author: Eric Dumazet <dada1@cosmosbay.com>
> > Date:   Tue May 19 18:54:22 2009 +0000
> > 
> >     net: fix length computation in rt_check_expire()
> > 
> >     rt_check_expire() computes average and standard deviation of chain lengths,
> >     but not correclty reset length to 0 at beginning of each chain.
> >     This probably gives overflows for sum2 (and sum) on loaded machines instead
> >     of meaningful results.
> > 
> >     Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> >     Acked-by: Neil Horman <nhorman@tuxdriver.com>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
