From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 12:14:50 -0800
Message-ID: <m1y6kdbpad.fsf@fess.ebiederm.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>
	<4B398ECD.1080506@kernel.org>
	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>
	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>
	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>
	<m1my0thelq.fsf@fess.ebiederm.org> <4B424305.7050803@kernel.org>
	<4B4245FC.7070902@zytor.com> <4B424A5C.7080309@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Suresh Siddha <suresh.b.siddha@intel.com>
To: Yinghai Lu <yinghai@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:59554 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753463Ab0ADUO4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 15:14:56 -0500
In-Reply-To: <4B424A5C.7080309@kernel.org> (Yinghai Lu's message of "Mon\, 04 Jan 2010 12\:06\:52 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Yinghai Lu <yinghai@kernel.org> writes:

> On 01/04/2010 11:48 AM, H. Peter Anvin wrote:
>> [Adding Suresh to the Cc: list]
>> 
>> On 01/04/2010 11:35 AM, Yinghai Lu wrote:
>>>
>>> so we can use [0x10, 0x1f]
>>>
>>> sth like this?
>>>
>> 
>> No!!!
>> 
>> [0x10, 0x1f] is reserved for exceptions.  We can probably get away with
>> stealing *one* vector... presumably at the end (0x1f).  However, we can
>> absolutely not use the whole block: 0x10-0x13 is occupied by exceptions
>> we already have OS support for (#MF, #AC, #MC, and #XM), and it's pretty
>> much guaranteed we'll have more coming.  However, growth is quite slow
>> and since this is a kernel-internal vector (not accessible to user
>> space) it is not creating an API.
>> 
>> In other words, we could change FIRST_EXTERNAL_VECTOR to 0x1f, and use
>> it for IRQ_MOVE_CLEANUP_VECTOR.  Then use 0x20..0x2f for the legacy vectors.
>> 
> Subject: [PATCH 1/2] x86: get back 16 vectors
>
> -v2: according to hpa that we could start from 0x1f

The code in the patch is ok, but the comments are wrong.

>
> Signed-off-by: Yinghai Lu <yinghai@kernel.org>
>
> ---
>  arch/x86/include/asm/irq_vectors.h |    9 +++++----
>  1 file changed, 5 insertions(+), 4 deletions(-)
>
> Index: linux-2.6/arch/x86/include/asm/irq_vectors.h
> ===================================================================
> --- linux-2.6.orig/arch/x86/include/asm/irq_vectors.h
> +++ linux-2.6/arch/x86/include/asm/irq_vectors.h
> @@ -30,8 +30,9 @@
>  /*
>   * IDT vectors usable for external interrupt sources start
>   * at 0x20:
> + * hpa said we can start from 0x1f

You need to document the reasons here.

>   */
> -#define FIRST_EXTERNAL_VECTOR		0x20
> +#define FIRST_EXTERNAL_VECTOR		0x1f
>  
>  #ifdef CONFIG_X86_32
>  # define SYSCALL_VECTOR			0x80
> @@ -41,15 +42,15 @@
>  #endif
>  
>  /*
> - * Reserve the lowest usable priority level 0x20 - 0x2f for triggering
> + * Reserve the lowest usable priority level 0x1f for triggering

Should be:
+   * Reserve the lowest usable priority level 0x10 - 0x1f for triggering
>   * cleanup after irq migration.

+   * this overlaps with the reserved range for cpu exceptions so this
+   * will need to be changed to 0x20 - 0x2f if the last cpu exception is
+   * ever allocated.
>   */
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
