From: Jesper Dangaard Brouer <jbrouer@redhat.com>
Subject: Re: [net-next PATCH] net: codel: Avoid undefined behavior from
 signed overflow
Date: Thu, 31 Oct 2013 15:15:51 +0100
Message-ID: <20131031151551.675ab908@redhat.com>
References: <20131030172341.19203.93490.stgit@dragon>
	<1383156104.4857.49.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62046 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754302Ab3JaOQE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Oct 2013 10:16:04 -0400
In-Reply-To: <1383156104.4857.49.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 30 Oct 2013 11:01:44 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Wed, 2013-10-30 at 18:23 +0100, Jesper Dangaard Brouer wrote:
> > From: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> > 
> > As described in commit 5a581b367 (jiffies: Avoid undefined
> > behavior from signed overflow), according to the C standard
> > 3.4.3p3, overflow of a signed integer results in undefined
> > behavior.
> > 
> > To fix this, do as the above commit, and do an unsigned
> > subtraction, and interpreting the result as a signed
> > two's-complement number.  This is based on the theory from
> > RFC 1982 and is nicely described in wikipedia here:
> >  https://en.wikipedia.org/wiki/Serial_number_arithmetic#General_Solution
> > 
> > A side-note, I have seen practical issues with the previous logic
> > when dealing with 16-bit, on a 64-bit machine (gcc version
> > 4.4.5). This were 32-bit, which I have not observed issues with.
> > 
> > Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> > Signed-off-by: Jesper Dangaard Brouer <netoptimizer@brouer.com>
> > ---
> > 
> >  include/net/codel.h |    8 ++++----
> >  1 files changed, 4 insertions(+), 4 deletions(-)
> > 
> > diff --git a/include/net/codel.h b/include/net/codel.h
> > index 389cf62..700fcdf 100644
> > --- a/include/net/codel.h
> > +++ b/include/net/codel.h
> > @@ -72,10 +72,10 @@ static inline codel_time_t codel_get_time(void)
> >  	return ns >> CODEL_SHIFT;
> >  }
> >  
> > -#define codel_time_after(a, b)		((s32)(a) - (s32)(b) > 0)
> > -#define codel_time_after_eq(a, b)	((s32)(a) - (s32)(b) >= 0)
> > -#define codel_time_before(a, b)		((s32)(a) - (s32)(b) < 0)
> > -#define codel_time_before_eq(a, b)	((s32)(a) - (s32)(b) <= 0)
> > +#define codel_time_after(a, b)		((s32)((a) - (b)) > 0)
> > +#define codel_time_after_eq(a, b)	((s32)((a) - (b)) >= 0)
> > +#define codel_time_before(a, b) 	((s32)((a) - (b)) < 0)
> > +#define codel_time_before_eq(a, b)	((s32)((a) - (b)) <= 0)
> >  
> 
> I see nothing enforcing an unsigned subtraction as claimed in your
> changelog.
> 
> a / b could be signed.
> 
> Paul commit 5a581b367b5 was OK because of existing typecheck(unsigned
> long, ....)

Okay, I'll cook up another patch, after work.

Adding all the typecheck() stuff, just bloats the code.

Would it be better/okay just to do?:
 (s32)((u32)(a) - (u32)(b)) > 0)


-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
