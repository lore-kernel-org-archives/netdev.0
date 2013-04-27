From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v2] x86: make DR*_RESERVED unsigned long
Date: Sat, 27 Apr 2013 16:45:37 +0200
Message-ID: <20130427144537.GA24256@redhat.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com> <20130424072630.GB1780@gmail.com> <20130424170702.GA1867@redhat.com> <5178282D.9030902@zytor.com> <20130425144818.GA25921@redhat.com> <20130426163802.GA30351@redhat.com> <517AAED5.7040400@zytor.com> <20130426171526.GA30875@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
	Fr??d??ric Weisbecker <fweisbec@gmail.com>
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20130426171526.GA30875@redhat.com>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26, Oleg Nesterov wrote:

> On 04/26, H. Peter Anvin wrote:
> >
> > On 04/26/2013 09:38 AM, Oleg Nesterov wrote:
> > >
> > > 	- do_debug:
> > >
> > > 		dr6 &= ~DR6_RESERVED;
> > >
> > > 	  this also wrongly clears 32-63 bits. Fortunately these
> > > 	  bits are reserved and must be zero.
> >
> > I don't think this is wrongly at all.
>
> OK, I meant that it also clears the bits that are not specified in
> DR6_RESERVED mask.
>
> > The whole point is to mask out
> > the bits that the handler doesn't want to deal with, so masking out the
> > reserved bits [63:32] seems reasonable to me.
>
> Then we should do
>
> 	- #define DR6_RESERVED    0xFFFF0FF0
> 	+ #define DR6_RESERVED    0xFFFFFFFFFFFF0FF0
>
> ?
>
> or what? (just in case, I will happily agree with "do nothing" ;)

Or we can do the s/reserved/mask/ change and avoid any "unexpected"
effect of "long &= ~int". This allso allows to kill ifdef(__i386__).

But this is include/uapi, I do not know if I can simply remove the
old define's.

In short: whatever you prefer, including "leave it alone".

Oleg.

diff --git a/arch/x86/include/uapi/asm/debugreg.h b/arch/x86/include/uapi/asm/debugreg.h
index 3c0874d..2678b23 100644
--- a/arch/x86/include/uapi/asm/debugreg.h
+++ b/arch/x86/include/uapi/asm/debugreg.h
@@ -14,8 +14,7 @@
    which debugging register was responsible for the trap.  The other bits
    are either reserved or not of interest to us. */
 
-/* Define reserved bits in DR6 which are always set to 1 */
-#define DR6_RESERVED	(0xFFFF0FF0)
+#define DR6_MASK	(0xF00FU)	/* Everything else is reserved */
 
 #define DR_TRAP0	(0x1)		/* db0 */
 #define DR_TRAP1	(0x2)		/* db1 */
@@ -32,6 +31,8 @@
    and indicates what types of access we trap on, and how large the data
    field is that we are looking at */
 
+#define DR_CONTROL_MASK (0xFFFF03FFU) /* Everything else is reserved */
+
 #define DR_CONTROL_SHIFT 16 /* Skip this many bits in ctl register */
 #define DR_CONTROL_SIZE 4   /* 4 control bits per register */
 
@@ -64,12 +65,6 @@
    We can slow the instruction pipeline for instructions coming via the
    gdt or the ldt if we want to.  I am not sure why this is an advantage */
 
-#ifdef __i386__
-#define DR_CONTROL_RESERVED (0xFC00) /* Reserved by Intel */
-#else
-#define DR_CONTROL_RESERVED (0xFFFFFFFF0000FC00UL) /* Reserved */
-#endif
-
 #define DR_LOCAL_SLOWDOWN (0x100)   /* Local slow the pipeline */
 #define DR_GLOBAL_SLOWDOWN (0x200)  /* Global slow the pipeline */
 
diff --git a/arch/x86/kernel/ptrace.c b/arch/x86/kernel/ptrace.c
index 7461f50..bc5fb98 100644
--- a/arch/x86/kernel/ptrace.c
+++ b/arch/x86/kernel/ptrace.c
@@ -657,7 +657,7 @@ static int ptrace_write_dr7(struct task_struct *tsk, unsigned long data)
 	bool second_pass = false;
 	int i, rc, ret = 0;
 
-	data &= ~DR_CONTROL_RESERVED;
+	data &= DR_CONTROL_MASK;
 	old_dr7 = ptrace_get_dr7(thread->ptrace_bps);
 
 restore:
diff --git a/arch/x86/kernel/traps.c b/arch/x86/kernel/traps.c
index 68bda7a..42a635f 100644
--- a/arch/x86/kernel/traps.c
+++ b/arch/x86/kernel/traps.c
@@ -402,7 +402,7 @@ dotraplinkage void __kprobes do_debug(struct pt_regs *regs, long error_code)
 	get_debugreg(dr6, 6);
 
 	/* Filter out all the reserved bits which are preset to 1 */
-	dr6 &= ~DR6_RESERVED;
+	dr6 &= DR6_MASK;
 
 	/*
 	 * If dr6 has no reason to give us about the origin of this trap,

