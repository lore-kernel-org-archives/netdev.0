From: Ingo Molnar <mingo@kernel.org>
Subject: Re: Unsigned widening casts of binary "not" operations..
Date: Wed, 24 Apr 2013 09:26:30 +0200
Message-ID: <20130424072630.GB1780@gmail.com>
References: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "H. Peter Anvin" <hpa@zytor.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	David Miller <davem@davemloft.net>,
	Theodore Ts'o <tytso@mit.edu>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	the arch/x86 maintainers <x86@kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	"linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Fr??d??ric Weisbecker <fweisbec@gmail.com>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Cyrill Gorcunov <gorcunov@gmail.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-ext4-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CA+55aFwpLu0qNms=hkQr43yqD0K9DgESNm91OEWKT1ZuT8MU6Q@mail.gmail.com>
Sender: linux-ext4-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> And there's quite a lot of them. Even in my (fairly small) config I use on
> my desktop. And the first warnings I see are in x86 code:
> 
>     arch/x86/kernel/traps.c:405:16: warning: implicit unsigned widening
> cast of a '~' expression
>     arch/x86/kernel/cpu/perf_event_p4.c:912:15: warning: implicit unsigned
> widening cast of a '~' expression

Hm, the perf_event_p4.c code is indeed confused.

I think the bug is real but probably benign in effect: we allow narrower 
values into the MSR register than probably intended. Only a couple of low 
bits are reserved AFAICS.

Here's an (untested!) patch that tries to untangle it all: it just moves 
to clean 64-bit types everywhere - these MSRs are 64-bit wide regardless 
of whether we run on 32-bit or not.

Would be nice if someone with a working P4 could test it - Cyrill? [It 
should also be double checked whether the high words are really not 
reserved and can be written to ...]

Thanks,

	Ingo
---->


Linus, while extending integer type extension checks in the sparse static 
code checker, found fragile patterns of mixed signed/unsigned 
64-bit/32-bit integer use in perf_events_p4.c.

The relevant hardware register ABI is 64 bit wide on 32-bit kernels as 
well, so clean it all up a bit, remove unnecessary casts, and make sure we 
use 64-bit unsigned integers in these places.

Signed-off-by: Ingo Molnar <mingo@kernel.org>


diff --git a/arch/x86/include/asm/perf_event_p4.h b/arch/x86/include/asm/perf_event_p4.h
index 4f7e67e..85e13cc 100644
--- a/arch/x86/include/asm/perf_event_p4.h
+++ b/arch/x86/include/asm/perf_event_p4.h
@@ -24,45 +24,45 @@
 #define ARCH_P4_CNTRVAL_MASK	((1ULL << ARCH_P4_CNTRVAL_BITS) - 1)
 #define ARCH_P4_UNFLAGGED_BIT	((1ULL) << (ARCH_P4_CNTRVAL_BITS - 1))
 
-#define P4_ESCR_EVENT_MASK	0x7e000000U
+#define P4_ESCR_EVENT_MASK	0x7e000000ULL
 #define P4_ESCR_EVENT_SHIFT	25
-#define P4_ESCR_EVENTMASK_MASK	0x01fffe00U
+#define P4_ESCR_EVENTMASK_MASK	0x01fffe00ULL
 #define P4_ESCR_EVENTMASK_SHIFT	9
-#define P4_ESCR_TAG_MASK	0x000001e0U
+#define P4_ESCR_TAG_MASK	0x000001e0ULL
 #define P4_ESCR_TAG_SHIFT	5
-#define P4_ESCR_TAG_ENABLE	0x00000010U
-#define P4_ESCR_T0_OS		0x00000008U
-#define P4_ESCR_T0_USR		0x00000004U
-#define P4_ESCR_T1_OS		0x00000002U
-#define P4_ESCR_T1_USR		0x00000001U
+#define P4_ESCR_TAG_ENABLE	0x00000010ULL
+#define P4_ESCR_T0_OS		0x00000008ULL
+#define P4_ESCR_T0_USR		0x00000004ULL
+#define P4_ESCR_T1_OS		0x00000002ULL
+#define P4_ESCR_T1_USR		0x00000001ULL
 
 #define P4_ESCR_EVENT(v)	((v) << P4_ESCR_EVENT_SHIFT)
 #define P4_ESCR_EMASK(v)	((v) << P4_ESCR_EVENTMASK_SHIFT)
 #define P4_ESCR_TAG(v)		((v) << P4_ESCR_TAG_SHIFT)
 
-#define P4_CCCR_OVF			0x80000000U
-#define P4_CCCR_CASCADE			0x40000000U
-#define P4_CCCR_OVF_PMI_T0		0x04000000U
-#define P4_CCCR_OVF_PMI_T1		0x08000000U
-#define P4_CCCR_FORCE_OVF		0x02000000U
-#define P4_CCCR_EDGE			0x01000000U
-#define P4_CCCR_THRESHOLD_MASK		0x00f00000U
+#define P4_CCCR_OVF			0x80000000ULL
+#define P4_CCCR_CASCADE			0x40000000ULL
+#define P4_CCCR_OVF_PMI_T0		0x04000000ULL
+#define P4_CCCR_OVF_PMI_T1		0x08000000ULL
+#define P4_CCCR_FORCE_OVF		0x02000000ULL
+#define P4_CCCR_EDGE			0x01000000ULL
+#define P4_CCCR_THRESHOLD_MASK		0x00f00000ULL
 #define P4_CCCR_THRESHOLD_SHIFT		20
-#define P4_CCCR_COMPLEMENT		0x00080000U
-#define P4_CCCR_COMPARE			0x00040000U
-#define P4_CCCR_ESCR_SELECT_MASK	0x0000e000U
+#define P4_CCCR_COMPLEMENT		0x00080000ULL
+#define P4_CCCR_COMPARE			0x00040000ULL
+#define P4_CCCR_ESCR_SELECT_MASK	0x0000e000ULL
 #define P4_CCCR_ESCR_SELECT_SHIFT	13
-#define P4_CCCR_ENABLE			0x00001000U
-#define P4_CCCR_THREAD_SINGLE		0x00010000U
-#define P4_CCCR_THREAD_BOTH		0x00020000U
-#define P4_CCCR_THREAD_ANY		0x00030000U
-#define P4_CCCR_RESERVED		0x00000fffU
+#define P4_CCCR_ENABLE			0x00001000ULL
+#define P4_CCCR_THREAD_SINGLE		0x00010000ULL
+#define P4_CCCR_THREAD_BOTH		0x00020000ULL
+#define P4_CCCR_THREAD_ANY		0x00030000ULL
+#define P4_CCCR_RESERVED		0x00000fffULL
 
 #define P4_CCCR_THRESHOLD(v)		((v) << P4_CCCR_THRESHOLD_SHIFT)
 #define P4_CCCR_ESEL(v)			((v) << P4_CCCR_ESCR_SELECT_SHIFT)
 
 #define P4_GEN_ESCR_EMASK(class, name, bit)	\
-	class##__##name = ((1 << bit) << P4_ESCR_EVENTMASK_SHIFT)
+	class##__##name = ((1ULL << bit) << P4_ESCR_EVENTMASK_SHIFT)
 #define P4_ESCR_EMASK_BIT(class, name)		class##__##name
 
 /*
@@ -107,7 +107,7 @@
  * P4_PEBS_CONFIG_MASK and related bits on
  * modification.)
  */
-#define P4_CONFIG_ALIASABLE		(1 << 9)
+#define P4_CONFIG_ALIASABLE		(1ULL << 9)
 
 /*
  * The bits we allow to pass for RAW events
@@ -784,17 +784,17 @@ enum P4_ESCR_EMASKS {
  * Note we have UOP and PEBS bits reserved for now
  * just in case if we will need them once
  */
-#define P4_PEBS_CONFIG_ENABLE		(1 << 7)
-#define P4_PEBS_CONFIG_UOP_TAG		(1 << 8)
-#define P4_PEBS_CONFIG_METRIC_MASK	0x3f
-#define P4_PEBS_CONFIG_MASK		0xff
+#define P4_PEBS_CONFIG_ENABLE		(1ULL << 7)
+#define P4_PEBS_CONFIG_UOP_TAG		(1ULL << 8)
+#define P4_PEBS_CONFIG_METRIC_MASK	0x3FLL
+#define P4_PEBS_CONFIG_MASK		0xFFLL
 
 /*
  * mem: Only counters MSR_IQ_COUNTER4 (16) and
  * MSR_IQ_COUNTER5 (17) are allowed for PEBS sampling
  */
-#define P4_PEBS_ENABLE			0x02000000U
-#define P4_PEBS_ENABLE_UOP_TAG		0x01000000U
+#define P4_PEBS_ENABLE			0x02000000ULL
+#define P4_PEBS_ENABLE_UOP_TAG		0x01000000ULL
 
 #define p4_config_unpack_metric(v)	(((u64)(v)) & P4_PEBS_CONFIG_METRIC_MASK)
 #define p4_config_unpack_pebs(v)	(((u64)(v)) & P4_PEBS_CONFIG_MASK)
diff --git a/arch/x86/kernel/cpu/perf_event_p4.c b/arch/x86/kernel/cpu/perf_event_p4.c
index 92c7e39..3486e66 100644
--- a/arch/x86/kernel/cpu/perf_event_p4.c
+++ b/arch/x86/kernel/cpu/perf_event_p4.c
@@ -895,8 +895,8 @@ static void p4_pmu_disable_pebs(void)
 	 * So at moment let leave metrics turned on forever -- it's
 	 * ok for now but need to be revisited!
 	 *
-	 * (void)wrmsrl_safe(MSR_IA32_PEBS_ENABLE, (u64)0);
-	 * (void)wrmsrl_safe(MSR_P4_PEBS_MATRIX_VERT, (u64)0);
+	 * (void)wrmsrl_safe(MSR_IA32_PEBS_ENABLE, 0);
+	 * (void)wrmsrl_safe(MSR_P4_PEBS_MATRIX_VERT, 0);
 	 */
 }
 
@@ -910,8 +910,7 @@ static inline void p4_pmu_disable_event(struct perf_event *event)
 	 * asserted again and again
 	 */
 	(void)wrmsrl_safe(hwc->config_base,
-		(u64)(p4_config_unpack_cccr(hwc->config)) &
-			~P4_CCCR_ENABLE & ~P4_CCCR_OVF & ~P4_CCCR_RESERVED);
+		p4_config_unpack_cccr(hwc->config) & ~P4_CCCR_ENABLE & ~P4_CCCR_OVF & ~P4_CCCR_RESERVED);
 }
 
 static void p4_pmu_disable_all(void)
@@ -957,7 +956,7 @@ static void p4_pmu_enable_event(struct perf_event *event)
 	u64 escr_addr, cccr;
 
 	bind = &p4_event_bind_map[idx];
-	escr_addr = (u64)bind->escr_msr[thread];
+	escr_addr = bind->escr_msr[thread];
 
 	/*
 	 * - we dont support cascaded counters yet

