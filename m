From: Wolfgang Walter <wolfgang.walter@stwm.de>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 12:36:54 +0200
Message-ID: <200808081236.55172.wolfgang.walter@stwm.de>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>
To: Suresh Siddha <suresh.b.siddha@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:38738 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753113AbYHHKg5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 06:36:57 -0400
In-Reply-To: <200808071823.02364.wolfgang.walter@stwm.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Donnerstag, 7. August 2008 18:23 schrieb Wolfgang Walter:
> Am Mittwoch, 6. August 2008 22:14 schrieb Suresh Siddha:
> > On Wed, Aug 06, 2008 at 10:33:25AM -0700, Wolfgang Walter wrote:
> > > Hello Herbert,
> > >
> > > I think I finally found the problem.
> > >
> > > Here a short description again: all our routers with a via C3 usi=
ng
> > > padlock for AES-encryption are crashing with 2.6.26 while they wo=
rk
> > > fine with 2.6.25. Not using padlock (i.e. using the i386 assemble=
r
> > > version of AES) they just work fine.
> >
> > Both the padlock version or asm version don't use FP/math registers=
,
> > right? It is interesting that you don't see the problem with asm ve=
rsion
> > but see the problem with padlock version.
> >
> > Does disabling CONFIG_PREEMPT in 2.6.26 change anything? And also,
>
> Didn't check that yet as I'm still running my modified 2.6.26. It now=
 runs
> almost one day flawlessly.
>
> But yesterday I tried the following patch on top of a vanilla 2.6.26:
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
> diff -ur ../linux-2.6.26/drivers/crypto/padlock-aes.c
> ./drivers/crypto/padlock-aes.c ---
> ../linux-2.6.26/drivers/crypto/padlock-aes.c	2008-07-15 11:29:32.0000=
00000
> +0200 +++ ./drivers/crypto/padlock-aes.c	2008-08-07 17:46:55.00000000=
0
> +0200 @@ -16,6 +16,7 @@
>  #include <linux/interrupt.h>
>  #include <linux/kernel.h>
>  #include <asm/byteorder.h>
> +#include <asm/i387.h>
>  #include "padlock.h"
>
>  /* Control word. */
> @@ -144,9 +145,11 @@
>  static inline void padlock_xcrypt(const u8 *input, u8 *output, void =
*key,
>  				  void *control_word)
>  {
> +	kernel_fpu_begin();
>  	asm volatile (".byte 0xf3,0x0f,0xa7,0xc8"	/* rep xcryptecb */
>
>  		      : "+S"(input), "+D"(output)
>  		      : "d"(control_word), "b"(key), "c"(1));
>
> +	kernel_fpu_end();
>  }
>
>  static void aes_crypt_copy(const u8 *in, u8 *out, u32 *key, struct c=
word
> *cword) @@ -179,6 +182,7 @@
>  		return;
>  	}
>
> +	kernel_fpu_begin();
>  	asm volatile ("test $1, %%cl;"
>  		      "je 1f;"
>  		      "lea -1(%%ecx), %%eax;"
> @@ -190,15 +194,18 @@
>
>  		      : "+S"(input), "+D"(output)
>  		      : "d"(control_word), "b"(key), "c"(count)
>  		      : "ax");
>
> +	kernel_fpu_end();
>  }
>
>  static inline u8 *padlock_xcrypt_cbc(const u8 *input, u8 *output, vo=
id
> *key, u8 *iv, void *control_word, u32 count)
>  {
>  	/* rep xcryptcbc */
> +	kernel_fpu_begin();
>  	asm volatile (".byte 0xf3,0x0f,0xa7,0xd0"
>
>  		      : "+S" (input), "+D" (output), "+a" (iv)
>  		      : "d" (control_word), "b" (key), "c" (count));
>
> +	kernel_fpu_end();
>  	return iv;
>  }
>
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> I found that kernel_fpu_begin(); kernel_fpu_begin(); is used with
> MMX and/or SSE:
>
> include/asm/xor_32.h
> drivers/md/raid6mmx.c
> drivers/md/raid6sse1.c
> drivers/md/raid6sse2.c
>
>
> With this change I its a little bit more stable, I needed more then 5
> minutes to crash the kernel (repeated it several times). If I read
> the code correctly this disables preemption for the time the padlock =
cmd
> is executing.

=46orget that - I booted the wrong kernel.

I now really test this modification and it seems to be stable. The rout=
er now=20
runs for 45 minutes without oops.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
Leiter EDV
Leopoldstra=DFe 15
80802 M=FCnchen
Tel: +49 89 38196 276
=46ax: +49 89 38196 150
Email: wolfgang.walter@stwm.de
http://www.studentenwerk-muenchen.de/
