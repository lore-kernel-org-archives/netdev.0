From: "Hall, Christopher S" <christopher.s.hall@intel.com>
Subject: RE: [PATCH v2 4/4] Added getsynctime64() callback
Date: Thu, 13 Aug 2015 21:10:36 +0000
Message-ID: <B79D786B7111A34A8CF09F833429C493A90A0E74@ORSMSX109.amr.corp.intel.com>
References: <1438988495-9942-1-git-send-email-christopher.s.hall@intel.com>
 <1438988495-9942-5-git-send-email-christopher.s.hall@intel.com>
 <20150810084949.GA18566@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>,
	"mingo@redhat.com" <mingo@redhat.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"hpa@zytor.com" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: 'Richard Cochran' <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:45430 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751452AbbHMVKi convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2015 17:10:38 -0400
In-Reply-To: <20150810084949.GA18566@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Monday, August 10, 2015 1:50 AM
> To: Hall, Christopher S
> Cc: john.stultz@linaro.org; tglx@linutronix.de; mingo@redhat.com; Kirsher,
> Jeffrey T; Ronciak, John; hpa@zytor.com; x86@kernel.org; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org
> Subject: Re: [PATCH v2 4/4] Added getsynctime64() callback
> 
> On Fri, Aug 07, 2015 at 04:01:35PM -0700, Christopher Hall wrote:
> > --- a/drivers/net/ethernet/intel/e1000e/defines.h
> > +++ b/drivers/net/ethernet/intel/e1000e/defines.h
> > @@ -527,6 +527,13 @@
> >  #define E1000_RXCW_C          0x20000000        /* Receive config */
> >  #define E1000_RXCW_SYNCH      0x40000000        /* Receive config synch
> */
> >
> > +/* HH Time Sync */
> > +#define E1000_TSYNCTXCTL_MAX_ALLOWED_DLY_MASK   0x0000F000      /* max
> delay */
> > +#define E1000_TSYNCTXCTL_SYNC_COMP              0x40000000      /* sync
> complete
> > + */
> > +#define E1000_TSYNCTXCTL_START_SYNC             0x80000000      /*
> initiate sync
> > + */
> 
> Split comment looks bad.  Trim this leading space instead.   ^^^^^^

OK.

> 
> > @@ -98,6 +100,91 @@ static int e1000e_phc_adjtime(struct ptp_clock_info
> *ptp, s64 delta)
> >  	return 0;
> >  }
> >
> > +#define HW_WAIT_COUNT (2)
> > +#define HW_RETRY_COUNT (2)
> 
> A busy wait, plus a retry, ...
> 
> > +#define SYNCTIME_RETRY_COUNT (2)
> 
> plus another retry!
> 
> Seems a bit heavy handed to me.  Is the HW really that flakey?
> 
> I would expect that a reasonably long polling loop should be
> sufficient.  If not, then the HW ignores certain requests, and that is
> worth a comment.
> 
> In any case, I don't understand why you have two nested retry loops.

The retry in get_synctime() is a left over from the previous patch.  It's not necessary,
the current timekeeping code won't fail in a way necessitating a retry.  It's removed.

The inner retry loop is due to huge inaccuracies in udelay().  I've done some testing
and it appears udelay(2) actually results in about an 8 microsecond delay.  On
Skylake the time for completion of the cross timestamp should be about 2 microseconds.
If we eliminate the inner most loop we either spin for too long or possibly risk not
waiting long enough.  Are there any guarantees for udelay()?

As for HW_RETRY_LOOP, I will confirm whether this is necessary.  It was in reference
code I was given, but, I agree, it seems odd.

> 
> > +static int e1000e_phc_getsynctime(struct ptp_clock_info *ptp,
> > +				  struct timespec64 *devts,
> > +				  struct timespec64 *systs)
> > +{
> > +	struct e1000_adapter *adapter = container_of(ptp, struct
> e1000_adapter,
> > +						     ptp_clock_info);
> > +	unsigned long flags;
> > +	u32 remainder;
> > +	struct correlated_ts art_correlated_ts;
> > +	u64 device_time;
> > +	int i, ret;
> > +
> > +	if (!cpu_has_art)
> > +		return -EOPNOTSUPP;
> 
> Perform this check before registration, setting .getsynctime64
> accordingly.

The problem here is that ART initialization doesn't happen until we install TSC as a clocksource.  This design is per Thomas' suggestion.  That occurs after the driver is loaded (as a module).

In my somewhat limited testing, it's about 400 ms later.  The problem is the several seconds of TSC frequency refinement.  I, in principle, agree, but we either need to move the ART initialization earlier (probably split it) or defer PTP clock initialization in the driver.

> 
> Thanks,
> Richard
