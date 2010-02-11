From: Simon Kagstrom <simon.kagstrom@netinsight.net>
Subject: Re: [PATCH 3/3] via-velocity: Fix races on shared interrupts
Date: Thu, 11 Feb 2010 09:05:49 +0100
Message-ID: <20100211090549.2b23a6f8@marrow.netinsight.se>
References: <20100205165253.3f316b98@marrow.netinsight.se>
	<20100205165545.28832c53@marrow.netinsight.se>
	<97949e3e1002100941s34010bdfu1a52f95693d3a9e9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net, davej@redhat.com,
	ben@decadent.org.uk
To: Laurent Chavey <chavey@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ernst.netinsight.se ([194.16.221.21]:15129 "HELO
	ernst.netinsight.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751259Ab0BKIF7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2010 03:05:59 -0500
In-Reply-To: <97949e3e1002100941s34010bdfu1a52f95693d3a9e9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Laurent!

On Wed, 10 Feb 2010 09:41:59 -0800
Laurent Chavey <chavey@google.com> wrote:

> > - =A0 =A0 =A0 spin_lock(&vptr->lock);
> > + =A0 =A0 =A0 /* Check if the lock is taken, and if so ignore the i=
nterrupt. This
> > + =A0 =A0 =A0 =A0* can happen with shared interrupts, where the oth=
er device can
> > + =A0 =A0 =A0 =A0* interrupt during velocity_poll (where the lock i=
s held).
> > + =A0 =A0 =A0 =A0*
> > + =A0 =A0 =A0 =A0* With spinlock debugging active on a uniprocessor=
, this will give
> > + =A0 =A0 =A0 =A0* a warning which can safely be ignored.
> > + =A0 =A0 =A0 =A0*/
> > + =A0 =A0 =A0 if (!spin_trylock(&vptr->lock))
> > + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return IRQ_NONE;
>=20
> does the thread handling the interrupts check that an new
> interrupts was received while it was servicing a previous one ?
> wondering if there is a potential for an event that generates the int=
errupt
> to be missed.

I should say that this particular part of the patch was reworked in
version 2, which David took in here:
 =20
  http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-2.6.git;a=3Dcom=
mitdiff;h=3D3f2e8d9f13246382fbda6f03178eef867a9bfbe2

Anyway, velocity_poll will try to empty all events within it's budget
from the device and is executing with the device interrupt turned off
(and now also with the local processor interrupts off). If something
would be posted when it's exiting, that's fine since it either

  1) Consumed it's entire budget, in which case it will stay in the
  polling mode anyway

or,

  2) Didn't consume the budget and will then turn on the interrupt
  again and get the new event promptly.


You are right about the code above though, that one is racy as David
explained here:

  http://permalink.gmane.org/gmane.linux.network/151578

// Simon
