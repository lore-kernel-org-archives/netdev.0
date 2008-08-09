From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Sat, 9 Aug 2008 12:50:42 +0200
Message-ID: <200808091250.43184.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808090443.00597.wolfgang.walter@stwm.de> <489D0F69.9050307@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Suresh Siddha <suresh.b.siddha@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@zeniv.linux.org.uk,
	vegard.nossum@gmail.com
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:53810 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751352AbYHIKuq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Aug 2008 06:50:46 -0400
In-Reply-To: <489D0F69.9050307@zytor.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 09 August 2008, H. Peter Anvin wrote:
> Wolfgang Walter wrote:
> >=20
> > These FPU changes are already in 2.6.26. Undoing them, would that b=
e=20
accepted=20
> > for 2.6.26 stable?
> >=20
> > Maybe the following solution would be possible: if a processor with=
=20
padlock is=20
> > detected the memory for xstate is always allocated when the thread =
is=20
created=20
> > instead "lazy"?
> >=20
>=20
> That will effectively happen, so it doesn't really matter.

With the patch? I don't think so:

With the patch the following changes compared with 2.6.25:

* processes which do not use FPU/SSE will not start saving and loading =
there=20
xstate any more (and will not allocate xstate memory) if kernel is usin=
g=20
padlock with the crypto-framework. Its similar to other places where th=
e=20
kernel uses MMX/SSE and protects them with kernel_fpu_begin();=20
kernel_fpu_end(); isn't it?

* if user space uses FPU/SSE its xstate will be saved though it is not =
really=20
necessary.

* the crypto-framework using padlock can not be preempted any more whil=
e=20
executing padlock-opcodes.

This is what Hebert fears.



What I'm not really understand - and Suresh probably could tell us - if=
 with=20
2.6.25 and earlier the following could happen:

1) a process is using FPU/SSE so it has a saved xstate BUT its not load=
ed=20
because of lazy loading of FPU state (didn't use FPU/SSE for some time)=
=2E

2) padlock usage by kernel without kernel_fpu_begin() kernel_fpu_end() =
sets=20
TS_USEDFPU of this task but its not loaded

3) in __switch_to() the process then saves its FPU/SSE state overwritin=
g its=20
real xstate.

If I understand Suresh explanations correctly this could not happen.

The problem only exists at task creation time: a race between initialis=
ing=20
TS_USEDFPU, used_math()) and setting the xstate pointer to NULL.

So wouldn't this help:

* a flag TS_INITIALISING is set for this task bevor used_math and TS_US=
EDFPU=20
is set
* then math-state of the new task is initialisied including setting xst=
ate to=20
NULL
* then the flag is cleared
* math_state_restore() in trap_32.c does nothing if this flag is set.

Another possibility would be to use xstate for tracking if math has eve=
r be=20
used by this task and made TS_USEDFPU only valid if xtate !=3D NULL

Both would only reestablish 2.6.25 behaviour.


But even if one or both would work its no solution for 2.6.26 (and prob=
ably=20
2.6.27). My trust in 2.6.26 increased enough to use it on desktops and =
I=20
would be a little bit nervous with such changes :-).

>=20
> The true optimization would be to recognize that the state doesn't ha=
ve=20
> to be saved, and track when we did so, and so on and so forth.

Yes that would be perfect. But fixing the race between math-state=20
initialisation and setting xtsate to NULL would be good enough. With ip=
sec=20
traffic some tasks would save and restore unecessarily its xstate (as i=
t is=20
the case with 2.6.25 and earlier).

There is no way to know if it was the kernel who caused a math fault?

>=20
> VIA really did their customers a disservice tying this to CR0.TS.
>=20
> 	-hpa
>=20
>=20


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
