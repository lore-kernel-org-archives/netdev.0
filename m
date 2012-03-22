From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Thu, 22 Mar 2012 08:00:26 +0100
Message-ID: <20120322070026.GC2182@netboy.at.omicron.at>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321160817.GB1941@netboy.at.omicron.at>
 <CAAsGZS4xU6Uqu59r6donnVmvi-NdxhQRi-7FEEHwg0mFcmKhxA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	jacob.e.keller@intel.com, jeffrey.t.kirsher@intel.com,
	john.ronciak@intel.com, john.stultz@linaro.org, tglx@linutronix.de
To: chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:61394 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751112Ab2CVHAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Mar 2012 03:00:40 -0400
Received: by wejx9 with SMTP id x9so1545527wej.19
        for <netdev@vger.kernel.org>; Thu, 22 Mar 2012 00:00:39 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAAsGZS4xU6Uqu59r6donnVmvi-NdxhQRi-7FEEHwg0mFcmKhxA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 21, 2012 at 01:02:38PM -0400, chetan loke wrote:
> > Well, if people want to write programs that make no sense at all,
> > then I can cannot stop them. There really isn't any point in general
> > applications using the PHC directly. You can easily synchronize the
> 
> I thought the core patches enables using PHC as a reference time, no?
> So that seems to be contradicting the PHC API. If there's no point
> then why are we exporting PHC->get_time as a generic interface? May be
> just limit get_time interface to something like ethtool?

There was a long discussion on this list and the lkml about the API,
and I think what we came up is a good solution. There is nothing to
prevent you from rewriting all of user space to use a dynamic clock ID
instead of CLOCK_REALTIME, but I seriously doubt anyone is going to do
this.

It does make sense for the time synchronization services to use
the clock_gettime calls to do their work.

Calls to read the system clock are highly optimized (at least on x86),
and thus applications wanting quick time stamps are wise to use that
clock. Calling clock_gettime on another clock, a PHY based clock for
example, might block for a long, long time. There is no way to
optimize around that, since it is a MDIO bus transaction.

> Once, the clocks are in-sync, it's not an error - but  *somewhat
> fixed* latency. There are users who don't want to spend extra money
> for expensive GPS time-sync stuff but yet have enough CPUs such that
> they can dedicate 1 CPU for book-keeping. For such users, this
> *somewhat fixed* latency should be constant over a period of time even
> when other CPUs are processing traffic at line rate.

Consider the following program:

	if (interesting_event()) {
		/* what happens in this empty space? preemption? interrupt? */
		clock_gettime();
	}

Run cyclictest on your system, and let's then talk about your 'fixed'
latency numbers.

> Sounds good on the tools part. But if applications should stick to
> reading sys-time then either we shouldn't export the API or export it
> selectively.If there's an API then user-space guys will use it. For
> this discussion, lets focus on PCI cards because that is what this
> patch talks about. Also the majority of the deployment will be LOM or
> PCI cards.

Like I said, I personally don't see much utility in optimizing igb. I
only have so much time to spend, but I am not against you or Jacob or
anyone else doing that work.

Thanks,
Richard
