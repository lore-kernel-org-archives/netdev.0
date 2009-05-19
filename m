From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Mon, 18 May 2009 22:09:11 -0700 (PDT)
Message-ID: <20090518.220911.102225532.davem@davemloft.net>
References: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: hong.pham@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42289
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752792AbZESFJN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 01:09:13 -0400
In-Reply-To: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hong H. Pham" <hong.pham@windriver.com>
Date: Mon, 11 May 2009 15:00:52 -0400

> I've tracked down a hang on a SPARC64 system (a Netra T5220 with 64 strands)
> whenever the NIU is handling lots of receive traffic.  The hang is
> reproducible by running iperf with multiple TCP streams (eg. iperf -P16 ...),
> with the SPARC box being the listener.
> 
> I've found that it's possible for an RX DMA interrupt to be triggered
> while NAPI is in progress.  When this happens, spurious interrupts will
> keep being regenerated which will cause the CPU to hang.  It's too busy
> servicing the spurious interrupts, and the NIU NAPI handler (or anything
> else on that CPU) never gets a chance to run.
> 
> In niu_schedule_napi(), if the logical device interrupt is unconditionally
> masked out by calling __niu_fastpath_interrupt(), the hang goes away.

Thanks for tracking down this problem, but I want to understand
why this even happens.  As far as I can tell it shouldn't.

When we are done polling, the order of events is:

1) unmask LDG interrupt(s)
2) napi_complete()
3) rearm LDG interrupt(s)

The interrupts should not be sent again until that rearm operation,
which is after NAPI is completed.  So the condition you are hitting
does not seem possible.

Matheos, can the chip violate this?  If an RX event is reported
in an LDG, it is masked, and then unmaked the interrupt should
not appear until the LDG is also rearmed right?
