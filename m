From: Rafael Aquini <aquini@linux.com>
Subject: Re: [PATCH] net/bonding: adjust codingstyle for bond_3ad files
Date: Sat, 7 May 2011 14:31:43 -0300
Message-ID: <20110507173141.GA4204@x61.tchesoft.com>
References: <20110507012717.GA15854@x61.tchesoft.com>
 <1304733100.11874.33.camel@Joe-Laptop>
Reply-To: aquini@linux.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kernel-janitors@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, shemminger@vyatta.com,
	netdev@vger.kernel.org, Nicolas Kaiser <nikai@nikai.net>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:54003 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753411Ab1EGRfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 13:35:24 -0400
Content-Disposition: inline
In-Reply-To: <1304733100.11874.33.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Howdy Joe,

On Fri, May 06, 2011 at 06:51:40PM -0700, Joe Perches wrote:
> On Fri, 2011-05-06 at 22:27 -0300, Rafael Aquini wrote:
> > @@ -411,36 +406,32 @@ static inline void __initialize_port_locks(struct port *port)
> >   */
> >  static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
> >  {
> > -	u16 retval = 0; /* to silence the compiler */
> > +	u16 retval = 0;
> 
> I think it's not good to remove this sort of comment.
> (there are others like it)
Sorry to disagree, but I can't see those comments as being helpful at all. 
I mean, what's the point about add a comment stating you are initializing
an etc var just to get rid of some compiler warning?
If, instead, some trick was used to initialize the var, then a comment would be worthwhile, isn't it? something like:
 /* suppress the compiler uninitialized variable warnings 
  * without generating any code (retval is still uninitialized)
  */
 u16 retval = retval;
		     
> Another option might be to add __maybe_unused
I guess you meant uninitialized_var(x) here. 
Yeah, I totally agree with you. It would be probably better using it considering
the performance standpoint (as it would not waste .text space and CPU cycles
initializing something that is about to be overwritten). 
While better, it also would imply in some code re-factoring, as certainly at some point in the function the 'uninitialized' variable has to assume some value, otherwise bad things can happen when function returns.

To exemplify my point, I'll taking that very  __ad_timer_to_ticks() as an example:
static u16 __ad_timer_to_ticks(u16 timer_type, u16 par)
{
        u16 retval = 0;

        switch (timer_type) {
        case AD_CURRENT_WHILE_TIMER:    /* for rx machine usage */
                if (par)
                        retval = (AD_SHORT_TIMEOUT_TIME*ad_ticks_per_sec);
                else
                        retval = (AD_LONG_TIMEOUT_TIME*ad_ticks_per_sec);
                break;
        case AD_ACTOR_CHURN_TIMER:      /* for local churn machine */
                retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
                break;
        case AD_PERIODIC_TIMER:         /* for periodic machine */
                retval = (par*ad_ticks_per_sec);
                break;
        case AD_PARTNER_CHURN_TIMER:    /* for remote churn machine */
                retval = (AD_CHURN_DETECTION_TIME*ad_ticks_per_sec);
                break;
        case AD_WAIT_WHILE_TIMER:       /* for selection machine */
                retval = (AD_AGGREGATE_WAIT_TIME*ad_ticks_per_sec);
                break;
        }
        return retval;
}

If, for some unknown reason timer_type receives an 'alien' value, and we were
using retval uninitialized, this function, as it is, would return an unpredictable value to its caller. Unless we have the switch block re-factored, we cannot leave retval uninitialized. So, it's not just a matter of leaving the variable uninitialized, or initialize it just to get rid of a compiler warning. That's why those comments are not helpful anyway.


As I've mentioned at my first post, this is just a tinny collaboration in order to enforce CodingStyle. I've never had the intention of doing deep code re-factoring to this file (and I don't think it's needed), thus I didn't touch in automatic variables initialization, and other stuff related to its logic. If you thing it is needed, I can go forward and do it, though.

I'll always be more than willing (and glad) to help,

Thanks again, for the valuable feedback!

Cheers!
-- 
Rafael Aquini <aquini@linux.com>
