From: Suresh Siddha <suresh.b.siddha@intel.com>
Subject: Re: Kernel oops with 2.6.26, padlock and ipsec: probably problem with fpu state changes
Date: Fri, 8 Aug 2008 11:53:57 -0700
Message-ID: <20080808185356.GC607@linux-os.sc.intel.com>
References: <200807171653.59177.wolfgang.walter@stwm.de> <20080806201401.GA607@linux-os.sc.intel.com> <200808071823.02364.wolfgang.walter@stwm.de> <200808081236.55172.wolfgang.walter@stwm.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Siddha, Suresh B" <suresh.b.siddha@intel.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Ingo Molnar <mingo@elte.hu>, viro@ZenIV.linux.org.uk,
	hpa@zytor.com, vegard.nossum@gmail.com
To: Wolfgang Walter <wolfgang.walter@stwm.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:49884 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753231AbYHHSx7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Aug 2008 14:53:59 -0400
Content-Disposition: inline
In-Reply-To: <200808081236.55172.wolfgang.walter@stwm.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 08, 2008 at 03:36:54AM -0700, Wolfgang Walter wrote:
> Am Donnerstag, 7. August 2008 18:23 schrieb Wolfgang Walter:
> > But yesterday I tried the following patch on top of a vanilla 2.6.26:
> >
> > =======================================================
> > diff -ur ../linux-2.6.26/drivers/crypto/padlock-aes.c
> > ./drivers/crypto/padlock-aes.c ---
> > ../linux-2.6.26/drivers/crypto/padlock-aes.c  2008-07-15 11:29:32.000000000
> > +0200 +++ ./drivers/crypto/padlock-aes.c      2008-08-07 17:46:55.000000000
> > +0200 @@ -16,6 +16,7 @@
> >  #include <linux/interrupt.h>
> >  #include <linux/kernel.h>
> >  #include <asm/byteorder.h>
> > +#include <asm/i387.h>
> >  #include "padlock.h"
> >
> >  /* Control word. */
> > @@ -144,9 +145,11 @@
> >  static inline void padlock_xcrypt(const u8 *input, u8 *output, void *key,
> >                                 void *control_word)
> >  {
> > +     kernel_fpu_begin();
> >       asm volatile (".byte 0xf3,0x0f,0xa7,0xc8"       /* rep xcryptecb */
> >
> >                     : "+S"(input), "+D"(output)
> >                     : "d"(control_word), "b"(key), "c"(1));
> >
> > +     kernel_fpu_end();
> >  }
> >
> >  static void aes_crypt_copy(const u8 *in, u8 *out, u32 *key, struct cword
> > *cword) @@ -179,6 +182,7 @@
> >               return;
> >       }
> >
> > +     kernel_fpu_begin();
> >       asm volatile ("test $1, %%cl;"
> >                     "je 1f;"
> >                     "lea -1(%%ecx), %%eax;"
> > @@ -190,15 +194,18 @@
> >
> >                     : "+S"(input), "+D"(output)
> >                     : "d"(control_word), "b"(key), "c"(count)
> >                     : "ax");
> >
> > +     kernel_fpu_end();
> >  }
> >
> >  static inline u8 *padlock_xcrypt_cbc(const u8 *input, u8 *output, void
> > *key, u8 *iv, void *control_word, u32 count)
> >  {
> >       /* rep xcryptcbc */
> > +     kernel_fpu_begin();
> >       asm volatile (".byte 0xf3,0x0f,0xa7,0xd0"
> >
> >                     : "+S" (input), "+D" (output), "+a" (iv)
> >                     : "d" (control_word), "b" (key), "c" (count));
> >
> > +     kernel_fpu_end();
> >       return iv;
> >  }
> >
> > =============================================================
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
> > With this change I its a little bit more stable, I needed more then 5
> > minutes to crash the kernel (repeated it several times). If I read
> > the code correctly this disables preemption for the time the padlock cmd
> > is executing.
> 
> Forget that - I booted the wrong kernel.
> 
> I now really test this modification and it seems to be stable. The router now
> runs for 45 minutes without oops.

Ok. Thanks. I think I can explain the failure:

These padlock instructions though don't use/touch SSE registers, but it behaves
similar to other SSE instructions. For example, it might cause DNA faults
when cr0.ts is set. While this is a spurious DNA trap, it might cause
problems with the recent fpu code changes.

This is the code sequence  that is probably causing this problem:

a) new app is getting exec'd and it is somewhere in between
   start_thread() and flush_old_exec() in the load_xyz_binary()

b) At pont "a", task's fpu state (like TS_USEDFPU, used_math() etc) is
   cleared.

c) Now we get an interrupt/softirq which starts using these encrypt/decrypt
   routines in the network stack. This generates a math fault (as
   cr0.ts is '1') which sets TS_USEDFPU and restores the math that is
   in the task's xstate.

d) Return to exec code path, which does start_thread() which does
   free_thread_xstate() and sets xstate pointer to NULL while
   the TS_USEDFPU is still set.

e) At the next context switch from the new exec'd task to another task,
   we have a scenarios where TS_USEDFPU is set but xstate pointer is null.
   This can cause an oops during unlazy_fpu() in __switch_to()

Now:

1) This should happen with or with out pre-emption. Viro also encountered
   similar problem with out CONFIG_PREEMPT.

2) kernel_fpu_begin() and kernel_fpu_end() will fix this problem, because
   kernel_fpu_begin() will manually do a clts() and won't run in to the
   situation of setting TS_USEDFPU in step "c" above.

3) This was working before the fpu changes, because its a spurious
   math fault  which doesn't corrupt any fpu/sse registers and the task's
   math state was always in an allocated state.

I propose to go with wolf's patch which add's kernel_fpu_begin() and
kernel_fpu_end() around these instructions. This is the correct fix
(unless there is something wrong in my above understanding).

thanks,
suresh
