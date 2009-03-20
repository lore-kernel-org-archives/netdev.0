From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Fri, 20 Mar 2009 02:40:49 +0100
Message-ID: <200903200240.50183.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903191158.52436.fzu@wemgehoertderstaat.de> <20090319222302.GA1972@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout5.freenet.de ([195.4.92.95]:33476 "EHLO mout5.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752533AbZCTBll convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 21:41:41 -0400
In-Reply-To: <20090319222302.GA1972@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag 19 M=E4rz 2009 schrieb Francois Romieu:
> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> [...]
> > Found it: CONFIG_DEBUG_SHIRQ is set here causing a "test-call" to
> > rtl8169_interrupt() from irq_request().
> >=20
> > $SUBJECT patch is ok, me still thinks. You ?
>=20
> I will have to convince myself that nothing bad can happen in the
> window between netif_rx_schedule_prep and RTL_W16. No big deal.

RTL_W16 is a posted write, if it happens, theres no difference if its
posted before or after netif_rx_schedule_prep.
=20
> I do not understand why / how the patch works at all : AFAIU, the sta=
tus
> register must contain some napi-related event in order for the patch =
to
> make a difference.

It contains 0x25 when the "test-call" runs, Link, Rx and Tx Flags.

> That's exactly what rtl8169_irq_mask_and_ack() is
> supposed to prevent. -> Does it fail ?

rtl8169_irq_mask_and_ack() resets status once and prevents interrupts
being sent by device. Maybe status reset doesn't work because device is
stopped or device isn't _completely_ stopped and updates status flags l=
ater.
Maybe Tx status only becomes 0 if some Tx data is queued.
=20
> So I'd really like to understand what is going on here.

Well, without patch any further interrupt causing napi-status isn't res=
et
_and_ netif_rx_schedule() isn't active. screaming interrupts.
slooooowish pc. Wonder why it proceeded at all though.

After rmmod/modprobe the status register contained 0x20 when in
rtl8169_irq_mask_and_ack() during "test-call", letting device work
normally.
=20
> PS: while I agree on the motivation for CONFIG_DEBUG_SHIRQ, I wonder =
if
> it is 100% safe to run an IRQ handler from a context which does not
> adhere to the original semantic. If its {disable/enable}_irq pair rac=
es
> with a similar pair due to a different driver on the same (shared) ir=
q,
> things could imho be unsafe.

=46rom the comment of disable_irq():
	"This function waits for any pending IRQ handlers for this interrupt
 	to complete before returning."
No race possible, in theory ;-)

The pc I debugged this on is a UP with no other device active on the us=
ed
int16.

Thanks,
Karsten

