From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Wed, 21 Mar 2012 17:06:09 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580DA6CC@ORSMSX105.amr.corp.intel.com>
References: <D3F292ADF945FB49B35E96C94C2061B916484EC4@nsmail.netscout.com>
 <CAAsGZS4_owYK3NpdutP_6Lgfu453qmpQ8GO6i8FbG6V8wXafBg@mail.gmail.com>
 <20120316065537.GB2199@netboy.at.omicron.at>
 <CAAsGZS6=UsyiGK=ZOwRuY0CNR7aOFLrwpn-2hXEtQJbWEULciA@mail.gmail.com>
 <20120321160817.GB1941@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: Richard Cochran <richardcochran@gmail.com>,
	chetan loke <loke.chetan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:10153 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756066Ab2CURGN convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 13:06:13 -0400
In-Reply-To: <20120321160817.GB1941@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Wednesday, March 21, 2012 9:08 AM
> To: chetan loke
> Cc: netdev@vger.kernel.org; e1000-devel@lists.sourceforge.net; Keller, Jacob
> E; Kirsher, Jeffrey T; Ronciak, John; john.stultz@linaro.org;
> tglx@linutronix.de
> Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of the
> timecompare method
> 
> On Wed, Mar 21, 2012 at 11:00:59AM -0400, chetan loke wrote:
> >
> > Once PHC->gettime goes live(aka exported to user space), we can't
> > really control how users will use it in their applications. There
> > could be 100+ apps all trying to get real-time from the network to do
> > some time-keeping stuff. They might pound the ioctls at high rate. The
> > last thing we would want is to self-induce a light weight DOS.
> 
> Well, if people want to write programs that make no sense at all, then I can
> cannot stop them. There really isn't any point in general applications using
> the PHC directly. You can easily synchronize the system time to the PHC to
> within a few microseconds. Just the error from reading the clock (due to
> various kinds of latency) is much larger than that.
> 
> Also, although you might be able to optimize clock_gettime performance for a
> PCI card, this will never work for PHY based devices, which, by the way, offer
> superior PTP time stamping. So, in general, applications should stick to
> reading the system time.
> 
> We still need to get some more tools out there in order to support the
> PHC->system synchronization, but that is not too far off. That is what
> I am working on now, and I don't think optimizing the igb is worth the effort.
> If you want to try it, please go right ahead, but adding the PPS would be much
> more useful IMHO.
> 
> Thanks,
> Richard
> 

I agree with Chetan. I think it would be best to make sure the correct form of locking is done, as we are providing an interface to the user. Using a seqlock would allow for preventing the ioctls from blocking the hardware timestamp code.

It's a fairly simple change for the gettime function (the most likely culprit to be hammered) by changing it to use timecounter_cyc2time function instead of timecounter_read. (as long as timecounter_read is called at least every 1/2 the system time overflow, which it should be due to the work task.)

With that change, then the section use a seqlock (along with the section for checking hardware timestamps). Other places would do the full write lock.

I do agree with Richard about supporting the PPS if possible, as that is much more useful as a general clock synchronization tool.

- Jake
