From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: net_timedelta() affected by settimeofday() (was: [patch 12/13]
 net: mac80211: Remove silly timespec dance)
Date: Thu, 12 Jun 2014 10:57:57 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1406121047280.5170@nanos>
References: <20140611234024.103571777@linutronix.de>  <20140611234607.683770899@linutronix.de>  <1402555774.4224.1.camel@jlt4.sipsolutions.net>  <alpine.DEB.2.10.1406121017500.5170@nanos>  <1402562114.8095.3.camel@jlt4.sipsolutions.net>
 (sfid-20140612_103558_525847_209A5C98) <1402562399.8095.5.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Stultz <john.stultz@linaro.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:38464 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932673AbaFLI6M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jun 2014 04:58:12 -0400
In-Reply-To: <1402562399.8095.5.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 12 Jun 2014, Johannes Berg wrote:

> On Thu, 2014-06-12 at 10:35 +0200, Johannes Berg wrote:
> > +netdev, Stephen
> 
> Well, stupid me. Fixing that netdev address.
> 
> > On Thu, 2014-06-12 at 10:19 +0200, Thomas Gleixner wrote:
> > > On Thu, 12 Jun 2014, Johannes Berg wrote:
> > > 
> > > > On Wed, 2014-06-11 at 23:59 +0000, Thomas Gleixner wrote:
> > > > 
> > > > > +	msrmnt = ktime_to_ms(net_timedelta(skb_arv));
> > > > 
> > > > This is probably more of a question about net_timedelta(), but is
> > > > ktime_get_real() really appropriate for duration measurements? Isn't
> > > > that non-monotonic?
> > > 
> > > Well, it's monotonic, but might be affected by settimeofday().
> > 
> > Right, but isn't that odd? Suddenly your delay measurement here might be
> > minutes, hours, or years if you settimeofday() between timestamping and
> > calculating the delta. That seems very strange to me, why would that be
> > the right behaviour in any way?

Indeed. clock monotonic is the appropriate one for measurements.
 
> > Now, it seems that there are only two current users of net_timedelta()
> > (in DCCP) so perhaps it's not too late to change some of this?
> > 
> > Maybe in general the skb timestamp should be based on a different clock
> > and only adjusted to real time when used in userspace?

You have the same problem then, just at a different place:

    ts = ktime_get();

			settimeofday()
			   offset_mono_to_real = new value;

    userts = mono_to_real(ts);

But maybe that's not a real issue, as ktime_get_real() can race with
settimeofday() or NTP as well.

   ts = ktime_get_real();
				settimeofday();
   userts = ts;

So the user might see a weird timestamp for a packet, which cannot be
correlated with the user space gettimeofday().

Thanks,

	tglx
