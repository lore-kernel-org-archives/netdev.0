From: "Hall, Christopher S" <christopher.s.hall@intel.com>
Subject: RE: [PATCH v3 1/4] Add correlated clocksource deriving system time
 from an auxiliary clocksource
Date: Thu, 3 Sep 2015 23:20:37 +0000
Message-ID: <B79D786B7111A34A8CF09F833429C493A90B2D1F@ORSMSX109.amr.corp.intel.com>
References: <1440183128-1384-1-git-send-email-christopher.s.hall@intel.com>
 <1440183128-1384-2-git-send-email-christopher.s.hall@intel.com>
 <alpine.DEB.2.11.1508222143530.3873@nanos>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"richardcochran@gmail.com" <richardcochran@gmail.com>,
	"x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>,
	"peterz@infradead.org" <peterz@infradead.org>
To: Thomas Gleixner <tglx@linutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:34784 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750708AbbICXUs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2015 19:20:48 -0400
In-Reply-To: <alpine.DEB.2.11.1508222143530.3873@nanos>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Thomas Gleixner [mailto:tglx@linutronix.de]
> Sent: Saturday, August 22, 2015 1:17 PM
> To: Hall, Christopher S
> Cc: Kirsher, Jeffrey T; hpa@zytor.com; mingo@redhat.com;
> john.stultz@linaro.org; richardcochran@gmail.com; x86@kernel.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; intel-wired-
> lan@lists.osuosl.org; peterz@infradead.org
> Subject: Re: [PATCH v3 1/4] Add correlated clocksource deriving system time
> from an auxiliary clocksource
>  
> > +/**
> > + * get_correlated_timestamp - Get a correlated timestamp
> > + *
> > + * Reads a timestamp from a device and correlates it to system time
> > + */
> > +int get_correlated_timestamp(struct correlated_ts *crt,
> > +			     struct correlated_cs *crs)
> > +{
> > +	struct timekeeper *tk = &tk_core.timekeeper;
> > +	unsigned long seq;
> > +	cycles_t cycles;
> > +	ktime_t base;
> > +	s64 nsecs;
> > +	int ret;
> > +
> > +	do {
> > +		seq = read_seqcount_begin(&tk_core.seq);
> > +		/*
> > +		 * Verify that the correlated clocksoure is related to
> > +		 * the currently installed timekeeper clocksoure
> > +		 */
> > +		if (tk->tkr_mono.clock != crs->related_cs)
> > +			return -ENODEV;
> > +
> > +		/*
> > +		 * Try to get a timestamp from the device.
> > +		 */
> > +		ret = crt->get_ts(crt);
> > +		if (ret)
> > +			return ret;
> > +
[Re-added code for context]

In addition to the network interface, ART will be used in the audio interface as well.
We need to support the case where an audio co-processor will control the audio device.
In this case, the get_ts() function supplied by the audio driver will be very slow
(several milliseconds) and the result will be out of date by some fraction of that 
amount.

This loop makes strict requirements on the latency and recency. Is it possible to relax
that requirement in some way?

For example, supply the ART value as an argument and, in the case of the realtime
clock, keep a short history of clock changes.  It would fail in cases where there
are a lot of calls to adjtimex(), but it will would work most of the time.

What can you suggest? Thanks

Chris

> > +	} while (read_seqcount_retry(&tk_core.seq, seq));
> > +	return 0;
> > +}
