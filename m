From: Steve.Glendinning@smsc.com
Subject: Re: [PATCH] SMSC LAN9500 USB2.0 10/100 ethernet adapter driver
Date: Wed, 10 Sep 2008 09:15:14 +0100
Message-ID: <OF26A16F1A.7E5C696A-ON802574BF.003B849F-802574C0.002D5A79@smsc.com>
References: <200809081154.05512.david-b@pacbell.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: Catalin Marinas <catalin.marinas@arm.com>, ian.saturley@smsc.com,
	netdev@vger.kernel.org
To: David Brownell <david-b@pacbell.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:2840 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751171AbYIJIPy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Sep 2008 04:15:54 -0400
In-Reply-To: <200809081154.05512.david-b@pacbell.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

Thanks for the feedback.

> > +#define SMSC_WARNING(msg, args...) \
> > +       printk(KERN_WARNING "%s: WARNING: " msg "\n", __func__, ## 
args)
> > +
> > +#ifdef USE_DEBUG
> > +#define SMSC_TRACE(debug_bit, msg, args...) \
> > +       if (debug_mode & debug_bit) { \
> > +               printk(KERN_WARNING "%s: " msg "\n", __func__, ## 
args); \
> > +       }
> > +#else
> > +#define SMSC_TRACE(dbgBit, msg, args...)   ({ do {} while (0); 0; })
> > +#endif
> 
> Standard feedback for such stuff:
> 
>  - avoid printk() for diagnostics, use dev_*() driver model calls
>  - ... or in this case, pr_warning() if you really must
>  - provide better messages and avoid passing __func__ 
>  - use inline functions instead of CPP macros
>  - make dead code elimination remove debug code, not #ifdefs
> 
> And specific to network devices:
> 
>  - use the ethtool message level flags not private debug_mode

There's quite a bit of variation on the debugging style across existing 
drivers.  Is there any driver you would suggest to use as an example of 
how to do things right?

> > +int turbo_mode = true;
> > +module_param(turbo_mode, bool, 0);
> > +MODULE_PARM_DESC(turbo_mode, "Enable multiple frames per Rx 
transaction");
> 
> I'm curious ... does this actually improve things on Linux?
> 
> My understanding is that on MS-Windows the costs of sending
> a transaction through the USB stack are so high that their
> APIs encourage such batching, and this has in some cases
> extended down to wire protocols and (as seems true here)
> even to hardware.
> 
> The approach Linux prefers is just to ensure that a queue
> of transactions works efficiently ... so that for example
> each Ethernet frame maps directly to one URB, and there's
> no time wasted batching/unbatching.  (Neither in Linux,
> nor in the peripheral.)
> 
> Last time I had any measurements on such issues, the
> Linux stack outperformed MS-Windows in terms of per-packet
> latency and also throughput, indicating that batching was
> not necessary for performance on most network loads.  But
> maybe that's not the case with your particular hardware,
> or in certain significant/common use cases?

On my test workstation both single and multi frame modes achieve 
wire-speed at 100Mbps, and packing multiple frames shows a slight CPU 
utilisation benefit under load.  This is much more pronounced on a slower 
platform, for example on a 533MHz ppc platform we saw a TCP RX netperf 
test drop from 59% to 30% CPU.

In multi frame mode the driver configures the device to apply a small 
hardware delay to the transaction, so it can group frames.  This delay is 
carefully chosen so the maximum additional latency (if no more frames 
arrive during the delay period) isn't significant for most applications. 
If a specific application is extremely latency sensitive the delay can be 
removed by switching to single packet mode.

Regards,
--
Steve Glendinning
SMSC GmbH
m: +44 777 933 9124
e: steve.glendinning@smsc.com
