From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 13:33:41 -0800
Message-ID: <4B425EB5.5080504@zytor.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>	<m1my0thelq.fsf@fess.ebiederm.org> <4B424305.7050803@kernel.org>	<4B4245FC.7070902@zytor.com> <4B424A5C.7080309@kernel.org> <m1y6kdbpad.fsf@fess.ebiederm.org> <4B425085.5040103@kernel.org> <4B42595E.9010404@zytor.com> <4B425BB7.90501@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from terminus.zytor.com ([198.137.202.10]:41869 "EHLO
	terminus.zytor.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753157Ab0ADVer (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 16:34:47 -0500
In-Reply-To: <4B425BB7.90501@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/04/2010 01:20 PM, Yinghai Lu wrote:
> --- linux-2.6.orig/arch/x86/include/asm/irq_vectors.h
> +++ linux-2.6/arch/x86/include/asm/irq_vectors.h
> @@ -30,8 +30,17 @@
>  /*
>   * IDT vectors usable for external interrupt sources start
>   * at 0x20:
> + * hpa said we can start from 0x1f.
> + *   0x1f is documented as reserved.  However, the ability for the APIC
> + *   to generate vectors starting at 0x10 is documented, as is the
> + *   ability for the CPU to receive any vector number as an interrupt.
> + *   0x1f is used for IRQ_MOVE_CLEANUP_VECTOR since that vector needs
> + *   an entire privilege level (16 vectors) all by itself at a higher
> + *   priority than any actual device vector.  Thus, by placing it in the
> + *   otherwise-unusable 0x10 privilege level, we avoid wasting a full
> + *   16-vector block.
>   */
> -#define FIRST_EXTERNAL_VECTOR		0x20
> +#define FIRST_EXTERNAL_VECTOR		0x1f
>  
>  #ifdef CONFIG_X86_32
>  # define SYSCALL_VECTOR			0x80
> @@ -41,15 +50,19 @@
>  #endif
>  
>  /*
> - * Reserve the lowest usable priority level 0x20 - 0x2f for triggering
> + * Reserve the lowest usable priority level 0x10 - 0x1f for triggering
>   * cleanup after irq migration.
> + * this overlaps with the reserved range for cpu exceptions so this
> + * will need to be changed to 0x20 - 0x2f if the last cpu exception is
> + * ever allocated.
>   */
> +
>  #define IRQ_MOVE_CLEANUP_VECTOR		FIRST_EXTERNAL_VECTOR
>  
>  /*
> - * Vectors 0x30-0x3f are used for ISA interrupts.
> + * Vectors 0x20-0x2f are used for ISA interrupts.
>   */
> -#define IRQ0_VECTOR			(FIRST_EXTERNAL_VECTOR + 0x10)
> +#define IRQ0_VECTOR			(FIRST_EXTERNAL_VECTOR + 1)
>  
>  #define IRQ1_VECTOR			(IRQ0_VECTOR +  1)
>  #define IRQ2_VECTOR			(IRQ0_VECTOR +  2)
> @@ -68,6 +81,13 @@
>  #define IRQ15_VECTOR			(IRQ0_VECTOR + 15)
>  

I'm not sure that making IRQ_MOVE_CLEANUP_VECTOR and IRQ0_VECTOR offsets
from FIRST_EXTERNAL_VECTOR makes sense from a readability perspective.
These are now magic numbers, and making them offsets is only confusing,
as it implies we could do it differently.

If nothing else, the actual logic for IRQ0_VECTOR should be:

#define IRQ0_VECTOR		((FIRST_EXTERNAL_VECTOR + 16) & ~15)

... since that is what we actually want -- we round up to the next
16-vector boundary.  Both +16 and +1 misrepresent the logic.

>  /*
> + * First APIC vector available to drivers: (vectors 0x30-0xee) we
> + * start at 0x31 to spread out vectors evenly between priority
> + * levels. (0x80 is the syscall vector)
> + */
> +#define FIRST_DEVICE_VECTOR		(IRQ15_VECTOR + 2)
> +

We really should fix that so we can do +1 here instead of +2; that
presumably means fixing the logic so we do something smarter than just
jump over 0x80.

	-hpa
