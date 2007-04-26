From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [patch 10/15] ppp_generic: fix lockdep warning
Date: Thu, 26 Apr 2007 12:49:50 +0200
Message-ID: <20070426104950.GA3145@ff.dom.local>
References: <200704260727.l3Q7RTxG023970@shell0.pdx.osdl.net> <20070426.013911.69219176.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org, jura@netams.com,
	paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx12.go2.pl ([193.17.41.142]:57620 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1031160AbXDZKoA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Apr 2007 06:44:00 -0400
Content-Disposition: inline
In-Reply-To: <20070426.013911.69219176.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 26, 2007 at 01:39:11AM -0700, David Miller wrote:
> From: akpm@linux-foundation.org
> Date: Thu, 26 Apr 2007 00:27:29 -0700
> 
> > lockdep has seen locks "-> #0" - "-> #3" taken in circular order, but IMHO,
> > lock "-> #3" (&pch->downl) taken after "-> #2" (&ppp->wlock) differs from
> > &pch->downl lock taken in "-> #0" (before &vlan_netdev_xmit_lock_key) and
> > lockdep should be notified about this.
> > 
> > Reported & tested by: "Yuriy N. Shkandybin" <jura@netams.com>
> > Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>
> > Cc: Paul Mackerras <paulus@samba.org>
> > Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> 
> I believe there were some problems found in this one,
> so I'm going to hold on it for now.
> 

This patch should prevent lockdep from reporting one kind
of possible circular locking error, which in my opinion is
impossible (lockdep doesn't see the difference in serving
two types of ppp channels). So, if I'm not wrong, this
patch is helpful sometime.

But there is also a second, very similar lockdep report,
probably also false (lockdep cannot see the difference
between locks of two different, I hope, vlan devices),
which needs more work:
a) vlan should use different lockdep lock subclasses or
classes for each device, which would require quite a lot
of static memory reserved, probably only to silence
lockdep,
b) pppoe could change the way of sending packets, so
the locks of ppp_generic were not seen by lockdep
with so many variants; I'm not sure the maintainer of
pppoe likes this idea;

Doing a) should be enough, I guess; doing b) is easier
but, probably, the similar is possible elsewhere, too.

Of course, there is possibility to silence lockdep
easier, e.g. don't let it know about vlan's lock
at all, but there is always, a risk lockdep reports
could be right sometimes...

Probably this kind of "error" reports could be avoided,
if vlan's config were started after all their devices
were up. Here it is probably: netdev1, vlan1, netdev2,
vlan2... and lockdep isn't able to distinguish them
enough.

Currently I think about some change in lockdep, to track
something like different vlans with less memory, but I'm
not sure it'll work, yet.

Regards,
Jarek P.
