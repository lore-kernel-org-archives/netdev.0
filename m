From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 0/1] NIU: fix spurious interrupts
Date: Tue, 19 May 2009 15:01:56 -0700 (PDT)
Message-ID: <20090519.150156.115978100.davem@davemloft.net>
References: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>
	<20090518.220911.102225532.davem@davemloft.net>
	<4A132A0F.8070800@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, matheos.worku@sun.com
To: hong.pham@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50544
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750793AbZESWB6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 18:01:58 -0400
In-Reply-To: <4A132A0F.8070800@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Hong H. Pham" <hong.pham@windriver.com>
Date: Tue, 19 May 2009 17:52:15 -0400

> Unfortunately I don't have a PCIe NIU card to test in an x86 box.
> If the hang does not happen on x86 (which is my suspicion), that
> would rule out a problem with the NIU chip.  That would mean there's
> some interaction between the NIU and sun4v hypervisor that's causing
> the spurious interrupts.

I am still leaning towards the NIU chip, or our programming of
it, as causing this behavior.

Although it's possible that the interrupt logic inside of
Niagara-T2, or how it's hooked up to the internal NIU ASIC
inside of the CPU, might be to blame I don't consider it likely
given the basic gist of the behavior you see.

To quote section 17.3.2 of the UltraSPARC-T2 manual:

	An interrupt will only be issued if the timer is zero,
	the arm bit is set, and one of more LD's in the LDG, have
	their flags set and not masked.

which confirms our understanding of how this should work.

Can you test something Hong?  Simply trigger the hung case
and when it happens read the LDG registers to see if the ARM
bit is set, and what the LDG mask bits say.

There might be a bug somewhere that causes us to call
niu_ldg_rearm() improperly.  In particular I'm looking
at that test done in niu_interrupt():

	if (likely(v0 & ~((u64)1 << LDN_MIF)))
		niu_schedule_napi(np, lp, v0, v1, v2);
	else
		niu_ldg_rearm(np, lp, 1);

If we call niu_ldg_rearm() on an LDG being serviced by NAPI
before that poll sequence calls napi_complete() we could
definitely see this weird behavior.  And whatever causes
that would be the bug to fix.

Thanks!

 
