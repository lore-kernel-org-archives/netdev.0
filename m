From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net V4 2/2] igb: offer a PTP Hardware Clock instead of
 the timecompare method
Date: Tue, 27 Mar 2012 20:05:01 +0200
Message-ID: <20120327180501.GA3878@netboy.at.omicron.at>
References: <CAAsGZS6A3Cz9eb9v94MKTeonW0YitHh5h7owpkRofKzgzUKF_Q@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DB92C@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS460uazL5n=oc3DwWKqeuTtNdQROGXQrPbs=Qh92TpnDg@mail.gmail.com>
 <20120324065147.GB2201@netboy.at.omicron.at>
 <CAAsGZS556o4iXtsWBzpiXxmv4isoZzw_h+RNv5eBMTGOsK905w@mail.gmail.com>
 <20120326152730.GA10212@localhost.localdomain>
 <CAAsGZS5Kn0nnwE0=0Eoo9a9e4+9w2fQ4nWjbCNsNrL-yfE3BtQ@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DC04D@ORSMSX105.amr.corp.intel.com>
 <CAAsGZS4Jqe5ZcZyGZjurmjBCgzj=+a0cgHAEwB+esXNoQ3P7NQ@mail.gmail.com>
 <02874ECE860811409154E81DA85FBB580DC1A0@ORSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: chetan loke <loke.chetan@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"john.stultz@linaro.org" <john.stultz@linaro.org>,
	"tglx@linutronix.de" <tglx@linutronix.de>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:42658 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755097Ab2C0SFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Mar 2012 14:05:16 -0400
Received: by wibhq7 with SMTP id hq7so162893wib.1
        for <netdev@vger.kernel.org>; Tue, 27 Mar 2012 11:05:15 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <02874ECE860811409154E81DA85FBB580DC1A0@ORSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jacob,

Thanks for your detailed explanation...

On Mon, Mar 26, 2012 at 08:46:13PM +0000, Keller, Jacob E wrote:
>
> The issue with gettime is in the SYSTIM registers. Gettime could also
> use cyc2time, and allow the background worktask to be the only one updating
> the timecounter's last read value. (this only has to happen at least twice
> every wraparound value, so for the 10gig 82599 about once every 30 seconds).
> But the lock is also protecting against corruption of the SYSTIM register
> reads. (The lock does 2 different things. We could add a separate lock,
> but I am not convinced it is worth it).

Right, the spinlock in my patch protects both the SYSTIM registers and
the struct timecounter. For the SYSTIM pair, you must use a
spinlock. There is no way around it.

The struct timecounter fields .cycle_last and .nsec are used as follows

   WRITE:   timercoutner_read()
            timercoutner_init()

   READ:    timercoutner_cyc2time()

Here you could conceivably use a reader/writer semaphore or a
seqlock. That would in turn enlarge the data structure and would
require nesting the locks.

I really doubt you will see any performance gain from such a
change. It increases code complexity and size for some dubious,
theoretical performance gain, for some really whacked use case.

Richard
