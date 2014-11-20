From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Thu, 20 Nov 2014 10:18:04 +0100
Message-ID: <20141120091804.GA4587@localhost.localdomain>
References: <cover.1416265321.git.richardcochran@gmail.com>
 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
 <20141119063724.GB4109@localhost.localdomain>
 <1416425553.15933.32.camel@jekeller-desk1.amr.corp.intel.com>
 <20141119202604.GA22213@localhost.localdomain>
 <1416431178.15933.38.camel@jekeller-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f52.google.com ([74.125.82.52]:51130 "EHLO
	mail-wg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754574AbaKTJSK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2014 04:18:10 -0500
Received: by mail-wg0-f52.google.com with SMTP id a1so3116878wgh.11
        for <netdev@vger.kernel.org>; Thu, 20 Nov 2014 01:18:08 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416431178.15933.38.camel@jekeller-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 19, 2014 at 09:06:19PM +0000, Keller, Jacob E wrote:
> On Wed, 2014-11-19 at 21:26 +0100, Richard Cochran wrote:
> > On Wed, Nov 19, 2014 at 07:32:33PM +0000, Keller, Jacob E wrote:
> > > Good catch :)

I have not been able to reproduce the crash, and so the cause is not
what I thought it was. Maybe it was my patch that preserved the
enabled interrupts in igb_ptp_reset(). I didn't notice that the driver
frees and reallocates the ptp_clock. I would never do that, myself.

> I think you need something here, but it should be clearing that register
> after a MAC reset, so it needs to be re-initialized. I'm not sure if
> that reset path was used in the same place in the past.

Okay, lets figure this out. Why is there a PTP reset function at all?
I don't know, lets see who calls it...

  Finding functions calling: igb_ptp_reset
  ----------------------------------------
  *** drivers/net/ethernet/intel/igb/igb_main.c:
  igb_reset[2033]                igb_ptp_reset(adapter);

Easy enough to understand. But who is calling igb_reset?

  Finding functions calling: igb_reset
  ------------------------------------
  *** drivers/net/ethernet/intel/igb/igb_ethtool.c:
  igb_set_settings[345]          igb_reset(adapter);
  igb_set_pauseparam[409]        igb_reset(adapter);
  igb_diag_test[2016]            igb_reset(adapter);
  igb_set_eee[2729]              igb_reset(adapter);
  *** drivers/net/ethernet/intel/igb/igb_main.c:
  igb_down[1814]                 igb_reset(adapter);
  igb_set_features[2069]         igb_reset(adapter);
  igb_probe[2526]                igb_reset(adapter);
  __igb_open[3110]               igb_reset(adapter);
  igb_watchdog_task[4231]        igb_reset(adapter);
  igb_change_mtu[5189]           igb_reset(adapter);
  igb_resume[7460]               igb_reset(adapter);
  igb_sriov_reinit[7545]         igb_reset(adapter);
  igb_io_slot_reset[7678]        igb_reset(adapter);

Wow, that is quite much. So, whenever any random parameter is changed,
we reset the PTP clock. Great.

Really, wouldn't better to reset the clock functions only when
absolutely necessary?

Thanks,
Richard
