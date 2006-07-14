From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: Re: [PATCH] bcm43xx-softmac: Further improvement in wireless	statistics
Date: Fri, 14 Jul 2006 09:25:17 -0700
Message-ID: <20060714162517.GA21960@bougret.hpl.hp.com>
References: <44B3CC25.7060305@lwfinger.net> <1152646370.27683.2.camel@localhost.localdomain> <44B474AF.6010907@lwfinger.net> <1152848265.2584.48.camel@localhost.localdomain>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelbas03.cce.hp.com ([161.114.21.106]:31977 "EHLO
	ccerelbas03.cce.hp.com") by vger.kernel.org with ESMTP
	id S1161215AbWGNQZa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Jul 2006 12:25:30 -0400
To: Dan Williams <dcbw@redhat.com>
Content-Disposition: inline
In-Reply-To: <1152848265.2584.48.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jul 13, 2006 at 11:37:45PM -0400, Dan Williams wrote:
> On Tue, 2006-07-11 at 23:03 -0500, Larry Finger wrote:
> > Dan Williams wrote:
> > > 
> > > NAK... remember, range->max_qual.level must be _0_ if you're in dBm,
> > 
> > I do not think this is right. From the comments in include/linux/wireless.h:
> > 
> >          /* Quality of link & SNR stuff */
> >          /* Quality range (link, level, noise)
> >           * If the quality is absolute, it will be in the range [0 ; max_qual],
> >           * if the quality is dBm, it will be in the range [max_qual ; 0].
> >           * Don't forget that we use 8 bit arithmetics... */
> 
> Jean, what's the official word on range->max_qual.level?
> 
> I don't know where I came up with the requirement that max_qual.level
> must be 0 to indicate that the units are in dBm (as opposed to RSSI),
> but it might well have been because we had no way to detect RSSI vs. dBm
> before IW_QUAL_DBM was added as a flag in WE-19, and therefore using
> level = 0 was the only reliable way because 0 is the theoretical "max"
> level that most cards can handle.

	I must admit that the original definition was too clever (or
too ambiguous, or too original, take your pick). range->max_qual.level
is always supposed to have a meaningfull value. People that did not
understand that original definition just put 0 there, as it was the
easiest way to output dBm.
	If you want more details, check the comment in the function
iw_print_stats() in iwlib.c.
	As I say, range->max_qual.level is always supposed to have
something useful, so :

if(IW_QUAL_DBM == 0)
	rssi level in the range [0 ; range->max_qual.level]
if(IW_QUAL_DBM == 1)
	(rssi level - 256) in the range [range->max_qual.level - 256 ; 0]

> So if you want to express your quality in dBm, you have a choice; either
> set IW_QUAL_DBM explicitly and do what you want with max_qual.level, or
> set your max_qual.level to 0.  That's my interpretation, of course I
> could be wrong.

	Correct for WE>19.

> Furthermore, there's no point to setting your max_qual.level to be the
> lowest level, since that's what your max_qual.noise is!!!
> max_qual.noise is the noise floor of your card and that effectively _is_
> the lowest level at which your card can operate.

	I did not think about that, and that's a very interesting
point. Yes, we could modify the definition to make use of that.

> In the ideal world, which we are now much closer to, we could _require_
> that IW_QUAL_DBM was set, otherwise values would be interpreted as RSSI.
> And we can if the driver's we_source_version is >= 19.  I agree, it's
> all quite confusing for starters.
> 
> Jean?

	I think WE-19 is old enough (most distro seems to use 2.6.16)
that we don't have to bother about earlier version going forward.

> Hm, I didn't think that WE's quality specification took scale into
> account; AFAIK you get 255 values to play with, and each maps either to
> an RSSI value of your choice, or to an absolute dBm value.  There's no
> scaling involved AFAIK.

	You can use the full 255 values (but not 256). There is
scaling is you want you indicator to look nice with all cards.

> So; if you want to use dBm you should probably set IW_QUAL_DBM flag on
> the qual->updated field when you update level & noise.  Then, nothing is
> ambiguous and everyone knows exactly what you mean.  Which is why
> IW_QUAL_DBM was added, because I complained that quality was too
> ambiguous.
> 
> Jean?

	Correct.
	And as pointed out later, it has the added bonus of having a
correct display of dBm in /proc/net/wireless.

> Cheers,
> Dan

	Jean
