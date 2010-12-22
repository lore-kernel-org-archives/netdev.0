From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Using ethernet device as efficient small packet generator
Date: Wed, 22 Dec 2010 09:08:22 +0100
Message-ID: <1293005302.4317.19.camel@edumazet-laptop>
References: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: juice@swagman.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:38262 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752396Ab0LVII1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Dec 2010 03:08:27 -0500
Received: by wwa36 with SMTP id 36so5012866wwa.1
        for <netdev@vger.kernel.org>; Wed, 22 Dec 2010 00:08:26 -0800 (PST)
In-Reply-To: <e66c1ff20e095bcc3a9a678a9935dc7e.squirrel@www.liukuma.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 09:30 +0200, juice a =C3=A9cri=
t :
> > On Tue, 21 Dec 2010 11:56:42 +0200 shemminger wrote:
> > I regularly get full 1G line rate of 64 byte packets using old Opte=
ron
> box and pktgen.  It does require some tuning of IRQ's and interrupt
> mitigation but
> > no patches. Did you remember to do the basic stuff like setting IRQ
> affinity
> > and not enabling debugging or tracing in the kernel? This is on sky=
2,
> but
> > also using e1000 and tg3. Others have reported 7M packets per secon=
d
> over
> > 10G cards.
> > The r8169 hardware is low end consumer hardware and doesn't work as
> well.
> > It is possible to get close to 1G line rate forwarding with a singl=
e
> core
> > with current
> > generation processors. Actual rate depends on hardware and configur=
ation
> (size of route
> > table, firewalling, etc).  Much better performance with multi-queue
> hardware to spread load
> > over multiple cores.
>=20
> I did my testing on two kinds of boxes we use in our lab, an older Po=
mi
> Supermicro with e1000 and a newer Dell T3500 with tg3 and r8169.
> Both computers have dual-core 2.4G Xeon Cpus, but with somewhat diffe=
rent
> model and stepping.
> Both boxes are running the same OS, Ubuntu 2.6.32-26-generic #48.
>=20

Hmm, might be better with 10.10 ubuntu, with 2.6.35 kernels

> Could you share some information on the required interrupt tuning? It
> would certainly be easiest if the full line rate can be achieved with=
out
> any patching of drivers or hindering normal eth/ip interface operatio=
n.
>=20

Thats pretty easy.

Say your card has 8 queues, do :

echo 01 >/proc/irq/*/eth1-fp-0/../smp_affinity
echo 02 >/proc/irq/*/eth1-fp-1/../smp_affinity
echo 04 >/proc/irq/*/eth1-fp-2/../smp_affinity
echo 08 >/proc/irq/*/eth1-fp-3/../smp_affinity
echo 10 >/proc/irq/*/eth1-fp-4/../smp_affinity
echo 20 >/proc/irq/*/eth1-fp-5/../smp_affinity
echo 40 >/proc/irq/*/eth1-fp-6/../smp_affinity
echo 80 >/proc/irq/*/eth1-fp-7/../smp_affinity

Then, start your pktgen threads on each queue, so that TX completion IR=
Q
are run on same CPU.

I confirm getting 6Mpps (or more) out of the box is OK.

I did it one year ago on ixgbe, no patches needed.

With recent kernels, it should even be faster.



