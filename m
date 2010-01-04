From: Yinghai Lu <yinghai@kernel.org>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 11:35:33 -0800
Message-ID: <4B424305.7050803@kernel.org>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com> <m1my0thelq.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Ingo Molnar <mingo@elte.hu>,
	Thomas Gleixner <tglx@linutronix.de>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	NetDEV list <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753864Ab0ADThR@vger.kernel.org>
In-Reply-To: <m1my0thelq.fsf@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/04/2010 11:09 AM, Eric W. Biederman wrote:
> "H. Peter Anvin" <hpa@zytor.com> writes:
> 
>> On 01/04/2010 08:18 AM, Eric W. Biederman wrote:
>>> Yinghai Lu <yinghai@kernel.org> writes:
>>>
>>> This patch is wrong.
>>>
>>>> between FIRST_EXTERNAL_VECTOR (0x20) and FIRST_DEVICE_VECTOR (0x41)
>>>>
>>>> for 0x20 and 0x2f, we are safe be used_vectors will prevent it to use used one.
>>>
>>> We can not use any of 0x20 - 0x2f for ioapic irqs.  We need the entire
>>> priority level to ensure that the irq move cleanup ipi is of a lower
>>> priority.
>>>
>>
>> Almost makes one want to abuse 0x1f for that.  Although 0x00..0x1f are
>> reserved for exceptions, the APICs range down to 0x10, and well, when
>> 0x1f ends up actually getting used as an exception vector that we
>> support, then we can trivially change that.  In the meantime it would
>> actually make use of an otherwise-unusable APIC priority level.
> 
> An optimization like that (with a big fat comment) seems reasonable
> to me.

so we can use [0x10, 0x1f]

sth like this?

Subject: [PATCH 1/2] x86: get back 16 vectors

-v2: according to hpa that we could start from 0x10
     according to Eric, we should hold 16 vectors for IRQ MOVE

Signed-off-by: Yinghai Lu <yinghai@kernel.org>

---
 arch/x86/include/asm/irq_vectors.h |    3 ++-
 arch/x86/kernel/apic/io_apic.c     |    5 +++--
 arch/x86/kernel/irqinit.c          |   11 +++++++++--
 3 files changed, 14 insertions(+), 5 deletions(-)

Index: linux-2.6/arch/x86/kernel/apic/io_apic.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/apic/io_apic.c
+++ linux-2.6/arch/x86/kernel/apic/io_apic.c
@@ -1162,7 +1162,8 @@ __assign_irq_vector(int irq, struct irq_
 	 * Also, we've got to be careful not to trash gate
 	 * 0x80, because int 0x80 is hm, kind of importantish. ;)
 	 */
-	static int current_vector = FIRST_DEVICE_VECTOR, current_offset = 0;
+	static int current_vector = 0;
+	static int current_offset = 0;
 	unsigned int old_vector;
 	int cpu, err;
 	cpumask_var_t tmp_mask;
@@ -1198,7 +1199,7 @@ next:
 		if (vector >= first_system_vector) {
 			/* If out of vectors on large boxen, must share them. */
 			offset = (offset + 1) % 8;
-			vector = FIRST_DEVICE_VECTOR + offset;
+			vector = 0 + offset;
 		}
 		if (unlikely(current_vector == vector))
 			continue;
Index: linux-2.6/arch/x86/include/asm/irq_vectors.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/irq_vectors.h
+++ linux-2.6/arch/x86/include/asm/irq_vectors.h
@@ -30,8 +30,9 @@
 /*
  * IDT vectors usable for external interrupt sources start
  * at 0x20:
+ * hpa said we can start from 0x10
  */
-#define FIRST_EXTERNAL_VECTOR		0x20
+#define FIRST_EXTERNAL_VECTOR		0x10
 
 #ifdef CONFIG_X86_32
 # define SYSCALL_VECTOR			0x80
Index: linux-2.6/arch/x86/kernel/irqinit.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/irqinit.c
+++ linux-2.6/arch/x86/kernel/irqinit.c
@@ -149,6 +149,8 @@ static void __init smp_intr_init(void)
 {
 #ifdef CONFIG_SMP
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_LOCAL_APIC)
+	int i;
+
 	/*
 	 * The reschedule interrupt is a CPU-to-CPU reschedule-helper
 	 * IPI, driven by wakeup.
@@ -174,7 +176,9 @@ static void __init smp_intr_init(void)
 
 	/* Low priority IPI to cleanup after moving an irq */
 	set_intr_gate(IRQ_MOVE_CLEANUP_VECTOR, irq_move_cleanup_interrupt);
-	set_bit(IRQ_MOVE_CLEANUP_VECTOR, used_vectors);
+	/* Eric said: Need to hold entire priority */
+	for (i = IRQ_MOVE_CLEANUP_VECTOR; i < IRQ_MOVE_CLEANUP_VECTOR+0x10; i++)
+		set_bit(i, used_vectors);
 
 	/* IPI used for rebooting/stopping */
 	alloc_intr_gate(REBOOT_VECTOR, reboot_interrupt);
@@ -222,6 +226,9 @@ void __init native_init_IRQ(void)
 	/* Execute any quirks before the call gates are initialised: */
 	x86_init.irqs.pre_vector_init();
 
+	for (i = 0; i < 0x10; i++)
+		set_bit(i, used_vectors);
+
 	apic_intr_init();
 
 	/*
@@ -229,7 +236,7 @@ void __init native_init_IRQ(void)
 	 * us. (some of these will be overridden and become
 	 * 'special' SMP interrupts)
 	 */
-	for (i = FIRST_EXTERNAL_VECTOR; i < NR_VECTORS; i++) {
+	for (i = 0; i < NR_VECTORS; i++) {
 		/* IA32_SYSCALL_VECTOR could be used in trap_init already. */
 		if (!test_bit(i, used_vectors))
 			set_intr_gate(i, interrupt[i-FIRST_EXTERNAL_VECTOR]);
