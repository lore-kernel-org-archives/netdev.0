From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tcp-lp 2.6.18-rc6: fix
 tcp_lp_remote_hz_estimator() about rhz
Date: Sun, 10 Dec 2006 22:40:55 -0800 (PST)
Message-ID: <20061210.224055.63737876.davem@davemloft.net>
References: <3feffd230609040244o497070f2j7909c6268f4eb588@mail.gmail.com>
	<20061203123207.GA17178@janus>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41842
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1762586AbWLKGk4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Dec 2006 01:40:56 -0500
To: frankvm@frankvm.com
In-Reply-To: <20061203123207.GA17178@janus>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Frank van Maarseveen <frankvm@frankvm.com>
Date: Sun, 3 Dec 2006 13:32:07 +0100

> On Mon, Sep 04, 2006 at 05:44:58PM +0800, Wong Edison wrote:
> > pageexec report an oops for tcp_lp_owd_calculator(). This is due to
> > tcp_lp_remote_hz_estimator can return 0.
> > 
> > This patch fix the handling of lp->flag, so will set lp->flag as FALSE
> > if rhz <= 0
> > 
> > Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>
> > 
> > ---
> > 
> > diff -urpN 2.6.18-rc6/tcp_lp.c tcp-lp/tcp_lp.c
> > --- 2.6.18-rc6/tcp_lp.c	2006-09-04 16:21:00.000000000 +0800
> > +++ tcp-lp/tcp_lp.c	2006-09-04 17:22:19.000000000 +0800
> > @@ -153,14 +157,17 @@ static u32 tcp_lp_remote_hz_estimator(st
> > 	if (m < 0)
> > 		m = -m;
> > 
> > -	if (rhz != 0) {
> > +	if (rhz > 0) {
> > 		m -= rhz >> 6;	/* m is now error in remote HZ est */
> > 		rhz += m;	/* 63/64 old + 1/64 new */
> > 	} else
> > 		rhz = m << 6;
> > 
> > 	/* record time for successful remote HZ calc */
> > -	lp->flag |= LP_VALID_RHZ;
> > +	if (rhz > 0)
> > +		lp->flag |= LP_VALID_RHZ;
> > +	else
> > +		lp->flag &= ~LP_VALID_RHZ;
> > 
> >  out:
> > 	/* record reference time stamp */
> > 
> > -- 
> > VGER BF report: U 0.500057
> 
> Got bitten by this zerodivide in 2.6.18.* (every few days a panic inside
> an interrupt handler) and it doesn't seem to be fixed in 2.6.19.

That patch doesn't even apply, because the following other
patch from Wong is in the tree which conflicts.  So I can't
apply this other fix of his, even if I wanted to.

commit bfbea8a8869a0e21b97605841d04190d63665d19
Author: Wong Hoi Sing Edison <hswong3i@gmail.com>
Date:   Thu Sep 28 14:40:21 2006 -0700

    [TCP] tcp-lp: prevent chance for oops
    
    This patch fix the chance for tcp_lp_remote_hz_estimator return 0, if
    0 < rhz < 64. It also make sure the flag LP_VALID_RHZ is set
    correctly.
    
    Signed-off-by: Wong Hoi Sing Edison <hswong3i@gmail.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/ipv4/tcp_lp.c b/net/ipv4/tcp_lp.c
index 308fb7e..f0ebaf0 100644
--- a/net/ipv4/tcp_lp.c
+++ b/net/ipv4/tcp_lp.c
@@ -31,8 +31,6 @@
  *   Hung Hing Lun, Mike <hlhung3i@gmail.com>
  * SourceForge project page:
  *   http://tcp-lp-mod.sourceforge.net/
- *
- * Version: $Id: tcp_lp.c,v 1.24 2006/09/05 20:22:53 hswong3i Exp $
  */
 
 #include <linux/module.h>
@@ -164,7 +162,7 @@ static u32 tcp_lp_remote_hz_estimator(st
 
  out:
 	/* record time for successful remote HZ calc */
-	if (rhz > 0)
+	if ((rhz >> 6) > 0)
 		lp->flag |= LP_VALID_RHZ;
 	else
 		lp->flag &= ~LP_VALID_RHZ;
