From: Haavard Skinnemoen <haavard.skinnemoen@atmel.com>
Subject: Re: [PATCH] macb: Add support of the netpoll API
Date: Thu, 16 Apr 2009 12:31:02 +0200
Message-ID: <20090416123102.6a5453b4@hskinnemoen-d830>
References: <20090415154658.40e3639a@surf>
	<20090416110753.5c75b805@hskinnemoen-d830>
	<20090416112435.0b779859@surf>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Michael Opdenacker <michael@free-electrons.com>
To: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.atmel.no ([80.232.32.139]:60562 "EHLO relay.atmel.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751579AbZDPKbJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Apr 2009 06:31:09 -0400
In-Reply-To: <20090416112435.0b779859@surf>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thomas Petazzoni wrote:
> Le Thu, 16 Apr 2009 11:07:53 +0200,
> Haavard Skinnemoen <haavard.skinnemoen@atmel.com> a =C3=A9crit :
>=20
> > Hmm...is this safe? What if printk() is called from the macb interr=
upt
> > handler? =20
>=20
> I'm not sure, but that strategy is used in most drivers supporting th=
e
> netpoll API (3c509.c, 8139cp.c, 8139too.c, b44.c, bfin_mac.c,
> bnx2x_main.c, etc.). It also seems to be the way suggested by netpoll
> author, http://oss.sgi.com/archives/netdev/2003-10/msg00800.html.
>=20
> disable_irq() only disables the macb IRQ line. Is that an issue for
> printk() execution ?

I'm worried about this potential deadlock:
  macb_interrupt()
  calls printk()
  calls macb_poll_controller()
  calls disable_irq()
  calls synchronize_irq()
  waits until macb_interrupt() returns, which will never happen

So I think it's safer to just use local_irq_save(). The interrupt
handler shouldn't run for long anyway since it uses NAPI for RX
processing, and it probably ought to use NAPI for TX processing too,
eventually.

Haavard
