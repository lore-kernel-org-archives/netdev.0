From: Claudiu Manoil <claudiu.manoil@freescale.com>
Subject: Re: [RFC net-next 2/4] gianfar: Clear ievent from interrupt handler
 for [RT]x int
Date: Thu, 9 Aug 2012 19:04:32 +0300
Message-ID: <5023DF90.20906@freescale.com>
References: <1344428810-29923-1-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-2-git-send-email-claudiu.manoil@freescale.com> <1344428810-29923-3-git-send-email-claudiu.manoil@freescale.com> <20120808161156.GB11043@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>
To: Paul Gortmaker <paul.gortmaker@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from va3ehsobe002.messaging.microsoft.com ([216.32.180.12]:19413
	"EHLO va3outboundpool.messaging.microsoft.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758589Ab2HIQEp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 12:04:45 -0400
In-Reply-To: <20120808161156.GB11043@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/8/2012 7:11 PM, Paul Gortmaker wrote:
> [[RFC net-next 2/4] gianfar: Clear ievent from interrupt handler for [RT]x int] On 08/08/2012 (Wed 15:26) Claudiu Manoil wrote:
>
>> It's the interrupt handler's job to clear ievent for the Tx/Rx paths, as soon
>> as the corresponding interrupt sources have been masked.
>
> What wasn't clear to me was whether we'd ever have an instance of
> gfar_poll run without RTX_MASK being cleared (in less normal conditions,
> like netconsole, KGDBoE etc), since the gfar_schedule_cleanup is only
> called from rx/tx IRQ threads, and neither of those are used by
> gfar_poll, it seems.

Hi Paul,

As I see it, netconsole has the ndo_poll_controller hook, which points
to gfar_netpoll() -> gfar_interrupt() -> gfar_receive|transmit() ->
gfar_schedule_cleanup(), so it passes through schedule_cleanup.

My understanding is that gfar_poll() is scheduled for execution
only by "__napi_schedule(&gfargrp->napi);" from the Rx/Tx interrupt
handler (gfar_receive/transmit()->gfar_schedule_cleanup()), and that
it will be executed sometimes after the interrupt handler returns,
which means RTX_MASK has been cleared (and the interrupt sources are
already masked).

I think that we might have an issue if we don't clear IEVENT right away
in the interrupt handler, as this register might cause additional hw
interrupts to the PIC upon returning from the interrupt handler.
