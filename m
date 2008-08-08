From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 21:09:46 +0200
Message-ID: <200808082109.47284.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:38538 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758057AbYHHTJt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 15:09:49 -0400
In-Reply-To: <200808081236.55172.wolfgang.walter@stwm.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 8. August 2008 12:36 schrieb Wolfgang Walter:
> Am Donnerstag, 7. August 2008 18:23 schrieb Wolfgang Walter:
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> > diff -ur ../linux-2.6.26/drivers/crypto/padlock-aes.c
> > ./drivers/crypto/padlock-aes.c ---
> > ../linux-2.6.26/drivers/crypto/padlock-aes.c	2008-07-15
> > 11:29:32.000000000 +0200 +++ ./drivers/crypto/padlock-aes.c	2008-08=
-07
> > 17:46:55.000000000 +0200 @@ -16,6 +16,7 @@
> >  #include <linux/interrupt.h>
> >  #include <linux/kernel.h>
> >  #include <asm/byteorder.h>
> > +#include <asm/i387.h>
> >  #include "padlock.h"
> >
> >  /* Control word. */
> > @@ -144,9 +145,11 @@
> >  static inline void padlock_xcrypt(const u8 *input, u8 *output, voi=
d
> > *key, void *control_word)
> >  {
> > +	kernel_fpu_begin();
> >  	asm volatile (".byte 0xf3,0x0f,0xa7,0xc8"	/* rep xcryptecb */
> >
> >  		      : "+S"(input), "+D"(output)
> >  		      : "d"(control_word), "b"(key), "c"(1));
> >
> > +	kernel_fpu_end();
> >  }
> >
> >  static void aes_crypt_copy(const u8 *in, u8 *out, u32 *key, struct=
 cword
> > *cword) @@ -179,6 +182,7 @@
> >  		return;
> >  	}
> >
> > +	kernel_fpu_begin();
> >  	asm volatile ("test $1, %%cl;"
> >  		      "je 1f;"
> >  		      "lea -1(%%ecx), %%eax;"
> > @@ -190,15 +194,18 @@
> >
> >  		      : "+S"(input), "+D"(output)
> >  		      : "d"(control_word), "b"(key), "c"(count)
> >  		      : "ax");
> >
> > +	kernel_fpu_end();
> >  }
> >
> >  static inline u8 *padlock_xcrypt_cbc(const u8 *input, u8 *output, =
void
> > *key, u8 *iv, void *control_word, u32 count)
> >  {
> >  	/* rep xcryptcbc */
> > +	kernel_fpu_begin();
> >  	asm volatile (".byte 0xf3,0x0f,0xa7,0xd0"
> >
> >  		      : "+S" (input), "+D" (output), "+a" (iv)
> >  		      : "d" (control_word), "b" (key), "c" (count));
> >
> > +	kernel_fpu_end();
> >  	return iv;
> >  }
> >
> > =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> >
> > I found that kernel_fpu_begin(); kernel_fpu_begin(); is used with
> > MMX and/or SSE:
> >
> > include/asm/xor_32.h
> > drivers/md/raid6mmx.c
> > drivers/md/raid6sse1.c
> > drivers/md/raid6sse2.c
> >
> >
> > With this change I its a little bit more stable, I needed more then=
 5
> > minutes to crash the kernel (repeated it several times). If I read
> > the code correctly this disables preemption for the time the padloc=
k cmd
> > is executing.
>
> Forget that - I booted the wrong kernel.
>
> I now really test this modification and it seems to be stable. The ro=
uter
> now runs for 45 minutes without oops.

It now runs for 8 hours.

So how to proceed?

Here a summary:

1) 2.6.25.x works

2) 2.6.26 without padlock works

3a) 2.6.26 using padlock and ipsec chrashes.=20

Always the same reason:

	__switch_to() wants to fxsave but there is no memory allocated

which means that TS_USEDFPU has been set.

3b) 2.6.26 with padlock code from 2.6.25: using padlock and ipsec chras=
hes.

4) Reverting the fpu patches (from 2.6.25 to 2.6.26) fixes the problem.

5) Protecting the padlock cmds with kernel_fpu_begin(); kernel_fpu_begi=
n();=20
fixes the problem.


Some thoughts:

4) probably fixes the problem because memory for fxsave is always alloc=
ated.

Maybe this is also the reason why 2.6.25 and earlier work.

5) is interesting:

kernel_fpu_begin() will save the fpu state if TS_USEDFPU is set - exact=
ly as=20
__unlazy_fpu in __switch_to would do. So when the crypto code calls pad=
lock=20
the world is ok: if TS_USEDFPU is set then memory has been allocated.

This makes me rather sure that there is no memory corruption by the net=
work=20
code and/or crypto code itself overwriting the task_info stucture and s=
etting=20
TS_USEDFPU.

I don't know though why kernel_fpu_begin exactly fixes the problem:

Maybe preemption must be disabled when padlocks RNG, ACE, Hash-engine e=
tc. is=20
used. Maybe just some barrier is needed which preempt_disable provides.

The padlock programming guide states that padlock's RNG, ACE, ... inter=
nally=20
use SSE. Especially "it temporary enables SSE until no further SSE=20
instruction or XSTORE, ... is seen". Further it may overlap with execut=
ion of=20
non-SSE instructions.


Probably it is the best to treat the padlock opcodes as SSE instruction=
s.



What should I do now?


Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
