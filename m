From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sun, 10 Aug 2008 00:59:10 +0200
Message-ID: <200808100059.10729.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080809185224.GH13158@linux-os.sc.intel.com> <20080809193724.GJ13158@linux-os.sc.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:41939 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752809AbYHIW7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 18:59:13 -0400
In-Reply-To: <20080809193724.GJ13158@linux-os.sc.intel.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 August 2008, Suresh Siddha wrote:
> On Sat, Aug 09, 2008 at 11:52:24AM -0700, Siddha, Suresh B wrote:
> > Backing out lazy allocation is not just enough here. Let me think a=
 little
> > more on this.
>=20
> Can we have something like irq_ts_save() and irq_ts_restore(), which =
will
> do something like:
>=20
> int irq_ts_save()
> {
> 	if (!in_interrupt())
> 		return 0;
>=20
> 	if (read_cr0() & X86_CR0_TS) {
> 		clts();
> 		return 1;
> 	}
> 	return 0;
> }
>=20
> void irq_ts_restore(int TS_state)
> {
> 	if (!in_interrupt())
> 		return 0;
>=20
> 	if (TS_state)
> 		stts();
> }
>=20
> and use this around padlock usage. Taking a spurious DNA fault in the=
=20
process
> context(even inside the kernel) should be ok. Main issue is with the=20
interrupt
> context and we can prevent the DNA fault in the irq context using abo=
ve.
>=20
> Either above, or we have to remove the lazy fpu allocation and make t=
he
> below code in kernel_fpu_begin() atomic by disabling interrupts(to fi=
x
> the security hole with padlock usage)
>=20
> kernel_fpu_begin:
> 	...
>=20
> 	local_irq_disable();
>=20
>         if (me->status & TS_USEDFPU)
>                 __save_init_fpu(me->task);
>         else
>                 clts();=20
>=20
> 	local_irq_enable();
> 	...
>=20
>=20

The first solution - if it works and padlock is the only which has prob=
lem=20
with it - seems to be a good fix for 2.6.26. If it works I can't say as=
 I'm=20
not familiar enough with these things. But I'll happily test it :-).

The second would be a little bit intrusive, wouldn't it? Most machines =
don't=20
have padlock, and therfore don't need this change but nevertheless may =
be=20
affected (i.e. they use MMX for memcpy or MMX/SSE with raid6) and now g=
et a=20
different behaviour. Don't know how expensive such a local_irq_enable/d=
isable=20
would be.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
