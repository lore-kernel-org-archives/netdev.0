From: Thomas Gleixner <tglx@linutronix.de>
Subject: RE: [PATCH 1/5] Add functions producing system time given a backing
 counter value
Date: Wed, 29 Jul 2015 16:05:19 +0200 (CEST)
Message-ID: <alpine.DEB.2.11.1507291603220.3825@nanos>
References: <1438044416-15588-1-git-send-email-christopher.s.hall@intel.com> <1438044416-15588-2-git-send-email-christopher.s.hall@intel.com> <CALAqxLWSakB1zdnYAE=2yQTPLdzkjO3wLA82Q+CJoJccGLWM8Q@mail.gmail.com>
 <B79D786B7111A34A8CF09F833429C493A909CEE1@ORSMSX109.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: 'John Stultz' <john.stultz@linaro.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Ingo Molnar <mingo@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"x86@kernel.org" <x86@kernel.org>,
	lkml <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Hall, Christopher S" <christopher.s.hall@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:40719 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbbG2OFm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Jul 2015 10:05:42 -0400
In-Reply-To: <B79D786B7111A34A8CF09F833429C493A909CEE1@ORSMSX109.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 29 Jul 2015, Hall, Christopher S wrote:
> 
> > -----Original Message-----
> > From: John Stultz [mailto:john.stultz@linaro.org]
> > Sent: Monday, July 27, 2015 8:44 PM
> > To: Hall, Christopher S
> > Cc: Thomas Gleixner; Richard Cochran; Ingo Molnar; Kirsher, Jeffrey T;
> > Ronciak, John; H. Peter Anvin; x86@kernel.org; lkml;
> > netdev@vger.kernel.org
> > Subject: Re: [PATCH 1/5] Add functions producing system time given a
> > backing counter value
> > 
> > On Mon, Jul 27, 2015 at 5:46 PM, Christopher Hall
> > <christopher.s.hall@intel.com> wrote:
> > > * counter_to_rawmono64
> > > * counter_to_mono64
> > > * counter_to_realtime64
> > >
> > > Enables drivers to translate a captured system clock counter to system
> > > time. This is useful for network and audio devices that capture
> > timestamps
> > > in terms of both the system clock and device clock.
> > 
> > Huh.  So for counter_to_realtime64 & mono64, this seems to ignore the
> > fact that the multiplier is constantly adjusted and corrected. So that
> > calling the function twice with the same counter value may result in
> > different returned values.
> > 
> > I've not yet groked the whole patchset, but it seems like there needs
> > to be some mechanism that ensures the counter value is captured and
> > used in the same (or at least close) interval that the timekeeper data
> > is valid for.
> 
> The ART (and derived TSC) values are always in the past.  There's no
> chance that we could exceed the interval.  I don't think any similar
> usage would be a problem either.
> 
> Are you suggesting that, for completeness, this be enforced by the
> conversion function?
> 
> I do a check here to make sure that the current counter value isn't before
> the beginning of the current interval:
> 
> timekeeping_get_delta()
> ...
>                if (cycle_now < tkr->cycle_last &&
>                    tkr->cycle_last - cycle_now < ROLLOVER_THRESHOLD)
>                         return -EAGAIN;
> 
> If tkr->cycle_last - cycle_now is large, the assumption is that
> rollover occurred.  Otherwise, the caller should re-read the counter
> so that it falls within the current interval.  In my "normal use"
> testing, re-read never occurred.

Sure that never happens, because your rollover value is 2 << 39 for
whatever reasons.

So on a 1GHz machine that is (2 << 39) / 1e9 ~= 1099.51 seconds.

Oh well.
