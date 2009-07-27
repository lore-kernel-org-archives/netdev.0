From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] xfrm: export xfrm garbage collector thresholds via
	sysctl
Date: Mon, 27 Jul 2009 15:36:25 -0400
Message-ID: <20090727193625.GD15823@hmsreliant.think-freely.org>
References: <20090727182246.GC15823@hmsreliant.think-freely.org> <20090727.113755.260927092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, joe@nall.com, herbert@gondor.apana.org.au,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:50198 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbZG0Tgg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 15:36:36 -0400
Content-Disposition: inline
In-Reply-To: <20090727.113755.260927092.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 27, 2009 at 11:37:55AM -0700, David Miller wrote:
> From: Neil Horman <nhorman@tuxdriver.com>
> Date: Mon, 27 Jul 2009 14:22:46 -0400
> 
> > Export garbage collector thresholds for xfrm[4|6]_dst_ops
> > 
> > Had a problem reported to me recently in which a high volume of ipsec
> > connections on a system began reporting ENOBUFS for new connections eventually.
> > It seemed that after about 2000 connections we started being unable to create
> > more.  A quick look revealed that the xfrm code used a dst_ops structure that
> > limited the gc_thresh value to 1024, and alaways dropped route cache entries
> > after 2x the gc_thresh.  It seems the most direct solution is to export the
> > gc_thresh values in the xfrm[4|6] dst_ops as sysctls, like the main routing
> > table does, so that higher volumes of connections can be supported.  This patch
> > has been tested and allows the reporter to increase their ipsec connection
> > volume successfully.
> > 
> > Reported-by: Joe Nall <joe@nall.com>
> > Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> 
> Applied, but this suggests that either:
> 
Thanks!

> 1) we pick a horrible default
> 
> 2) our IPSEC machinery holds onto dst entries too tightly and that's
>    the true cause of this problem
> 
> I'd like to ask that you investigate this, because with defaults
> we should be able to handle IPSEC loads as high as the routing
> loads we could handle.
> 
I'll gladly look into this further.  Compared to the main routing table, the
ipsec default selection is pretty bad.  Its statcially set despite the size of
the larger routing table.  Looking at the garbage collection algorithm, we do
keep a pretty tight leash on freeing entries, but I think its warrented.  We
create 1 dst_entry for each open socket on an ipsec tunnel, and don't release it
until its __refcnt drops to zero.  I think that makes sense, since it means
we only keep cache entries for active connections, and clean them up as soon as
they close (e.g. I don't really see the advantage to unhashing a xfrm cache
entry only to recreate it on the next packet sent).  I think the most sensible
first step is to dynamically choose a gc threshold based on the size of memory
or the main routing table.  I'll write this up and post later this week after I
do some testing.  Thanks!
Neil

> Thanks.
> 
