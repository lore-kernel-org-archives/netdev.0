From: Mike_Phillips@URSCorp.com
Subject: Re: [PATCH] fix for olympic cable pull induced hang
Date: Mon, 20 Oct 2003 06:51:31 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OF96B1A49A.B5BD7E93-ON88256DC5.004B0F5F-88256DC5.004C20D3@urscorp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Don Fry <brazilnut@us.ibm.com>, netdev@oss.sgi.com,
        netdev-bounce@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


> Thanks, I'll take a look at this.

> Mike, please let me know if this looks sane to you, too.  (i would like
> your 'ack' before sending upstream...)

*sigh*, yes there's a hang in the driver (it's been there since day one),
but its only when its compiled up in SMP mode and you're not supposed to
pull the cables out of token ring cards. The driver was specifically
written to be nice to the rest of the machine. I could easily just have
grabbed the interrupt on detection/module insertion and then free'd it up
on removal, but it was written this way to only hold the interrupt when the
card is actually open, it should release it when the card gets closed or an
error condition occurs. A better fix is just to cure that particular bug.
You can't call free_irq from the driver's own interrupt, true enough, a
better fix is to set of a timer so that the interrrupt can return and then
the timer function can free up the interrupt.

This patch changes other stuff as well, I want to take a good look at it
and check that it doesn't upset cardbus, which definitely needs to free the
interrupt if it gets a card ejection notification. The driver was designed
to be able to sit around even without an adapter in the machine.

There is also another bug that's surfaced recently to do with timing out in
open commands which I'm currently looking at. (For some reason on recent
kernels, both 2.4 and 2.6 it's taking longer for the open command to
return)

Plus:

> If other cards are on the ring then just one down/up will work.  After
that
> when the active monitor is removed from the ring another down/up cycle is
> required.

What !!, the card should detect when an active monitor is removed from the
ring, a contention method kicks in (at hardware level) and a different
adapter becomes the active monitor - this USED to work.

Mike
