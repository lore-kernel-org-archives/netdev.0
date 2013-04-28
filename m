From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Sun, 28 Apr 2013 19:27:31 +0200
Message-ID: <20130428172731.GA26169@redhat.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <20130424072630.GB1780@gmail.com> <20130424170702.GA1867@redhat.com> <5178282D.9030902@zytor.com> <20130425144818.GA25921@redhat.com> <20130426163802.GA30351@redhat.com> <517AAED5.7040400@zytor.com> <20130426171526.GA30875@redhat.com> <20130427144537.GA24256@redhat.com> <20130428005814.GB10354@somewhere>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>
To: Frederic Weisbecker <fweisbec@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130428005814.GB10354@somewhere>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/28, Frederic Weisbecker wrote:
>
> On Sat, Apr 27, 2013 at 04:45:37PM +0200, Oleg Nesterov wrote:
> >
> > -/* Define reserved bits in DR6 which are always set to 1 */
> > -#define DR6_RESERVED	(0xFFFF0FF0)
> > +#define DR6_MASK	(0xF00FU)	/* Everything else is reserved */
>
> I'm personally fine either with that or with Peter's suggestion to do:
>
> -#define DR6_RESERVED (0xFFFF0FF0)
> +#define DR6_RESERVED (~0xF00FUL)

I missed this suggestion...

Yes, and this allows to kill ifdef too.

> If this should stay stable UAPI,

I do not know, but I guess it would be safer to keep the old define's.

> I really don't mind.

Oh, I do not mind too ;)

OK, please see v3.

------------------------------------------------------------------------------
Subject: [PATCH v3] x86: make DR*_RESERVED unsigned long

DR6_RESERVED and DR_CONTROL_RESERVED are used to clear the unwanted
bits in the "unsigned long" data, but "ulong &= ~int" also clears the
upper bits that are not specified in mask.

This is actually fine, dr6[32:63] are reserved, but this is not clear
so it would be better to make them "unsigned long" to cleanup the code.

However, depending on sizeof(long), DR6_RESERVED should be either
0xFFFF0FF0 or 0xFFFFFFFF_FFFF0FF0, so this patch redefines them as
(~ 32_bit_mask UL) to avoid ifdef's.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Suggested-by: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Oleg Nesterov <oleg@redhat.com>
---
 arch/x86/include/uapi/asm/debugreg.h |    8 ++------
 1 files changed, 2 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/uapi/asm/debugreg.h b/arch/x86/include/uapi/asm/debugreg.h
index 3c0874d..4ff5d05 100644
--- a/arch/x86/include/uapi/asm/debugreg.h
+++ b/arch/x86/include/uapi/asm/debugreg.h
@@ -15,7 +15,7 @@
    are either reserved or not of interest to us. */
 
 /* Define reserved bits in DR6 which are always set to 1 */
-#define DR6_RESERVED	(0xFFFF0FF0)
+#define DR6_RESERVED	(~0xF00FUL)
 
 #define DR_TRAP0	(0x1)		/* db0 */
 #define DR_TRAP1	(0x2)		/* db1 */
@@ -64,11 +64,7 @@
    We can slow the instruction pipeline for instructions coming via the
    gdt or the ldt if we want to.  I am not sure why this is an advantage */
 
-#ifdef __i386__
-#define DR_CONTROL_RESERVED (0xFC00) /* Reserved by Intel */
-#else
-#define DR_CONTROL_RESERVED (0xFFFFFFFF0000FC00UL) /* Reserved */
-#endif
+#define DR_CONTROL_RESERVED (~0xFFFF03FFUL) /* Reserved by Intel */
 
 #define DR_LOCAL_SLOWDOWN (0x100)   /* Local slow the pipeline */
 #define DR_GLOBAL_SLOWDOWN (0x200)  /* Global slow the pipeline */
-- 
1.5.5.1
