From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 17:57:32 +0200
Message-ID: <200808091757.32999.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080808231121.GA13158@linux-os.sc.intel.com> <20080809143727.GA30499@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Suresh Siddha <suresh.b.siddha@intel.com>,
	"H. Peter Anvin" <hpa@zytor.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>,
	"viro@ZenIV.linux.org.uk" <viro@zeniv.linux.org.uk>,
	"vegard.nossum@gmail.com" <vegard.nossum@gmail.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:57257 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753389AbYHIP5f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 11:57:35 -0400
In-Reply-To: <20080809143727.GA30499@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 August 2008, Herbert Xu wrote:
> On Fri, Aug 08, 2008 at 04:11:21PM -0700, Suresh Siddha wrote:
> >
> > With out the recent dynamic fpu allocation changes, while we don't =
see=20
oops,
> > there is a possible race still present in older kernels(for example=
,
> > while kernel is using kernel_fpu_begin() in some optimized clear/co=
py
> > page and an interrupt/softirq happens which uses these padlock
> > instructions generating DNA fault).
>=20
> No this wasn't a problem because kernel_fpu_begin clears TS and
> therefore we don't get faults on SSE instructions.
>=20
> However, with your patch it will become a problem due to the
> fact that it wasn't designed to be nested.
>=20


I don't exactly understand this. You think that

kernel_fpu_begin();
XCRYPT....
kernel_fpu_end();

is a problem and wasn't before?

Say we have a software crypt-alg which uses optimized memcpy implemente=
d with=20
SSE instructions. These are protected with kernel_fpu_begin();=20
kernel_fpu_end();

So we have also code

kernel_fpu_begin();
SSE....
kernel_fpu_end();

in crypto called under same circumstances.

If XCRYPT may be interrupted and the interrupt code again uses this opt=
imized=20
memcpy implementation and so nesting kernel_fpu_begin then why should t=
his=20
not happen with the other alg.

How could any kernel code use MMX/SSE/FPU when the interrupt case isn't=
=20
handled?


Or is your argument that its lazy allocation itself is the problem: thi=
s=20
nesting could always happen and was a bug but only with lazy allocation=
 it is=20
dangerous (as it may cause a spurious math fault in the race window).

If this were right than any kernel code executing SSE may trigger now a=
 oops=20
in __switch_to() under some special circumstances.


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leiter EDV
Leopoldstra=DFe 15
80802 M=FCnchen
Tel: +49 89 38196-276
=46ax: +49 89 38196-144
wolfgang.walter@stwm.de
http://www.studentenwerk-muenchen.de/
