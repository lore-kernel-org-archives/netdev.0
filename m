From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] bcm43xx-softmac: Further improvement in
	wireless	statistics
Date: Thu, 13 Jul 2006 23:37:45 -0400
Message-ID: <1152848265.2584.48.camel@localhost.localdomain>
References: <44B3CC25.7060305@lwfinger.net>
	 <1152646370.27683.2.camel@localhost.localdomain>
	 <44B474AF.6010907@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Jean Tourrilhes <jt@hpl.hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:41116 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1161235AbWGNDjT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 23:39:19 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44B474AF.6010907@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-07-11 at 23:03 -0500, Larry Finger wrote:
> Dan Williams wrote:
> > 
> > NAK... remember, range->max_qual.level must be _0_ if you're in dBm,
> 
> I do not think this is right. From the comments in include/linux/wireless.h:
> 
>          /* Quality of link & SNR stuff */
>          /* Quality range (link, level, noise)
>           * If the quality is absolute, it will be in the range [0 ; max_qual],
>           * if the quality is dBm, it will be in the range [max_qual ; 0].
>           * Don't forget that we use 8 bit arithmetics... */

Jean, what's the official word on range->max_qual.level?

I don't know where I came up with the requirement that max_qual.level
must be 0 to indicate that the units are in dBm (as opposed to RSSI),
but it might well have been because we had no way to detect RSSI vs. dBm
before IW_QUAL_DBM was added as a flag in WE-19, and therefore using
level = 0 was the only reliable way because 0 is the theoretical "max"
level that most cards can handle.

So if you want to express your quality in dBm, you have a choice; either
set IW_QUAL_DBM explicitly and do what you want with max_qual.level, or
set your max_qual.level to 0.  That's my interpretation, of course I
could be wrong.

Furthermore, there's no point to setting your max_qual.level to be the
lowest level, since that's what your max_qual.noise is!!!
max_qual.noise is the noise floor of your card and that effectively _is_
the lowest level at which your card can operate.

In the ideal world, which we are now much closer to, we could _require_
that IW_QUAL_DBM was set, otherwise values would be interpreted as RSSI.
And we can if the driver's we_source_version is >= 19.  I agree, it's
all quite confusing for starters.

Jean?

> My interpretation of this is that if 0 < max_qual < 128, the quantity is absolute. Conversely, if 
> -129 < max_qual < 0, the quantity is in dBm. This is in fact what I see, both from the KDE applets 
> and the various wireless extension tools.
> 
> > since 0 is the actual maximum, and your level values are negative since
> > they are in dBm.
> > 
> > If KDE network applets display the wrong value when max_qual.level == 0,
> > then they are wrong and need to be fixed.
> 
> They display correctly; however, choosing 0 rather than -100 expands the scale to the point that my 
> noise values of -65 dBm display as rather high values. Despite the 8-bit arithmetic, I think it 
> creates a scale from 0 to -255 dBm. My choice of parameters expands the scale by limiting the lower 
> value to -100 dBm.

Hm, I didn't think that WE's quality specification took scale into
account; AFAIK you get 255 values to play with, and each maps either to
an RSSI value of your choice, or to an absolute dBm value.  There's no
scaling involved AFAIK.

> > If you actually want RSSI, then you set max_qual.level to the upper
> > limit of your RSSI, and the RSSI is assumed to go from 0 ->
> > max_qual.level.  AFAIK, the patch you had earlier is using dBm, _not_
> > RSSI, so max_qual.level = 0 is correct.
> 
> As I explained earlier, the RSSI value returned by the firmware has been processed by the driver 
> into a quantity that varies between -10 and -65 as the receiver is moved from very close to very far 
> from the AP, which looks like strength in dBm. This is what is stored in stats.rssi. As this seems 
> to be confusing, I will rewrite the driver code so that this value is returned in stats.signal with 
> the RSSI value preserved in stats.rssi. The quality output will be derived from stats.rssi, and the 
> level output will come from stats.signal. These two quantities have a correlation of -1 so there is 
> no new information, but that might change in the future.

So; if you want to use dBm you should probably set IW_QUAL_DBM flag on
the qual->updated field when you update level & noise.  Then, nothing is
ambiguous and everyone knows exactly what you mean.  Which is why
IW_QUAL_DBM was added, because I complained that quality was too
ambiguous.

Jean?

Cheers,
Dan

> Larry

