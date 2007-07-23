From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: 2.6.20->2.6.21 - networking dies after random time
Date: Mon, 23 Jul 2007 10:53:00 +0200
Message-ID: <20070723085300.GB1898@ff.dom.local>
References: <JKE37W$0126317E099DF36884CC046B6F8A7AA9@xandmail.com> <20070629150759.GC2771@ff.dom.local> <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jean-Baptiste Vignaud <vignaud@xandmail.fr>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	shemminger <shemminger@linux-foundation.org>,
	linux-net <linux-net@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>
To: Marcin =?iso-8859-2?Q?=A6lusarz?= <marcin.slusarz@gmail.com>
Return-path: <linux-net-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4bacf17f0707222244p664e7a6ap850b3357a57d73c@mail.gmail.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 23, 2007 at 07:44:58AM +0200, Marcin =A6lusarz wrote:
> Ok, I've bisected this problem and found that this patch broke my NIC=
:

Congratulations!

>=20
> 76d2160147f43f982dfe881404cfde9fd0a9da21 is first bad commit
> commit 76d2160147f43f982dfe881404cfde9fd0a9da21
> Author: Ingo Molnar <mingo@elte.hu>
> Date:   Fri Feb 16 01:28:24 2007 -0800
>=20
>    [PATCH] genirq: do not mask interrupts by default
=2E..
> So I cooked patch like below and everything is working fine (so far)
>=20
> Fix default_disable interrupt function (broken by [PATCH] genirq: do
> not mask interrupts by default) - revert removal of codepath which wa=
s
> invoked when removed flag (IRQ_DELAYED_DISABLE) wag NOT set
>=20
> Signed-off-by: Marcin Slusarz <marcin.slusarz@gmail.com>
> ---
> diff --git a/kernel/irq/chip.c b/kernel/irq/chip.c
> index 76a9106..0bb23cd 100644
> --- a/kernel/irq/chip.c
> +++ b/kernel/irq/chip.c
> @@ -230,6 +230,8 @@ static void default_enable(unsigned int irq)
>  */
> static void default_disable(unsigned int irq)
> {
> +	struct irq_desc *desc =3D irq_desc + irq;
> +	desc->chip->mask(irq);
> }
>=20
> /*

I think your patch should very good point the source of the problem
and would help to many people, but it looks like too arbitrary for
those who didn't have such problems. It seems it was mainly with
x86_64, so maybe something like this below would be enough?

Cheers,
Jarek P.

PS: not tested!

---

diff -Nurp 2.6.22-/arch/x86_64/kernel/io_apic.c 2.6.22/arch/x86_64/kern=
el/io_apic.c
--- 2.6.22-/arch/x86_64/kernel/io_apic.c	2007-07-09 01:32:17.000000000 =
+0200
+++ 2.6.22/arch/x86_64/kernel/io_apic.c	2007-07-23 10:33:05.000000000 +=
0200
@@ -1427,6 +1427,7 @@ static struct irq_chip ioapic_chip __rea
 	.name 		=3D "IO-APIC",
 	.startup 	=3D startup_ioapic_irq,
 	.mask	 	=3D mask_IO_APIC_irq,
+	.disable	=3D mask_IO_APIC_irq,
 	.unmask	 	=3D unmask_IO_APIC_irq,
 	.ack 		=3D ack_apic_edge,
 	.eoi 		=3D ack_apic_level,
