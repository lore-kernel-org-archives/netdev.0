From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: Subject: [PATCH 1/2] x86: get back 15 vectors
Date: Mon, 04 Jan 2010 15:03:48 -0800
Message-ID: <4B4273D4.2080709@zytor.com>
References: <4B347AEE.6030705@kernel.org> <20091228094707.GH24690@elte.hu>	<4B398ECD.1080506@kernel.org>	<4807377b1001031906s6b1ee576jc021da2642bb4147@mail.gmail.com>	<4B415E73.1050801@kernel.org> <4B419113.1090204@kernel.org>	<m1aawtlu6y.fsf@fess.ebiederm.org> <4B423B08.3010005@zytor.com>	<m1my0thelq.fsf@fess.ebiederm.org> <4B424305.7050803@kernel.org>	<4B4245FC.7070902@zytor.com> <4B424A5C.7080309@kernel.org> <m1y6kdbpad.fsf@fess.ebiederm.org> <4B425085.5040103@kernel.org> <4B42595E.9010404@zytor.com> <4B425BB7.90501@kernel.org> <4B425EB5.5080504@zytor.com> <4B426550.6000209@kernel.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070704020001030904050005"
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
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753993Ab0ADXEy@vger.kernel.org>
In-Reply-To: <4B426550.6000209@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070704020001030904050005
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

On 01/04/2010 02:01 PM, Yinghai Lu wrote:
>>
>>>  /*
>>> + * First APIC vector available to drivers: (vectors 0x30-0xee) we
>>> + * start at 0x31 to spread out vectors evenly between priority
>>> + * levels. (0x80 is the syscall vector)
>>> + */
>>> +#define FIRST_DEVICE_VECTOR		(IRQ15_VECTOR + 2)
>>> +
>>
>> We really should fix that so we can do +1 here instead of +2; that
>> presumably means fixing the logic so we do something smarter than just
>> jump over 0x80.
> 
> we already use used_vectors to skip 0x80. so we could change that to +1?
> 

Yes, but the problem is that we *skip* 0x80, which leads to suboptimal
allocation on systems with only a handful of vectors.

The easy solution to accomplishing what we want without wasting vector
0x30 is obviously to start allocation at 0x31, but not by artificially
limiting the vector space; see the attached patch.

For what it's worth, this code(__assign_irq_vector() in
arch/x86/kernel/apic/io_apic.c) has me somewhat confused about the use
of the constant 8:

		vector += 8;

The only justification that I can immediately think of is to try to
assign exactly two sources to each priority level (since early APICs
started losing interrupts with more than two sources per priority level.)

This is ancient code -- predates not just the git but the bk history --
and as such I would assume that that is the motivation.

	-hpa

--------------070704020001030904050005
Content-Type: text/x-patch;
 name="0001-x86-irq-Don-t-waste-a-vector-to-improve-vector-sprea.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename*0="0001-x86-irq-Don-t-waste-a-vector-to-improve-vector-sprea.pa";
 filename*1="tch"

>From 6e586d7d1da44360b16d2c0ac2bea623c1fcfa6e Mon Sep 17 00:00:00 2001
From: H. Peter Anvin <hpa@zytor.com>
Date: Mon, 4 Jan 2010 15:00:57 -0800
Subject: [PATCH] x86, irq: Don't waste a vector to improve vector spread

We want to use a vector-assignment sequence that avoids stumbling onto
0x80 earlier in the sequence, in order to improve the spread of
vectors across priority levels on machines with a small number of
interrupt sources.  Right now, this is done by simply making the first
vector (0x31 or 0x41) completely unusable.  This is unnecessary; all
we need is to start assignment at a +1 offset, we don't actually need
to prohibit the usage of this vector once we have wrapped around.

Signed-off-by: H. Peter Anvin <hpa@zytor.com>
---
 arch/x86/include/asm/irq_vectors.h |    9 +++++----
 arch/x86/kernel/apic/io_apic.c     |    3 ++-
 2 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/arch/x86/include/asm/irq_vectors.h b/arch/x86/include/asm/irq_vectors.h
index 4611f08..718dcdd 100644
--- a/arch/x86/include/asm/irq_vectors.h
+++ b/arch/x86/include/asm/irq_vectors.h
@@ -121,11 +121,12 @@
 #define MCE_SELF_VECTOR			0xeb
 
 /*
- * First APIC vector available to drivers: (vectors 0x30-0xee) we
- * start at 0x31(0x41) to spread out vectors evenly between priority
- * levels. (0x80 is the syscall vector)
+ * First APIC vector available to drivers: (vectors 0x30-0xee).  We
+ * start allocating at 0x31(0x41) to spread out vectors evenly between
+ * priority levels. (0x80 is the syscall vector)
  */
-#define FIRST_DEVICE_VECTOR		(IRQ15_VECTOR + 2)
+#define FIRST_DEVICE_VECTOR		(IRQ15_VECTOR + 1)
+#define VECTOR_OFFSET_START		1
 
 #define NR_VECTORS			 256
 
diff --git a/arch/x86/kernel/apic/io_apic.c b/arch/x86/kernel/apic/io_apic.c
index de00c46..e289148 100644
--- a/arch/x86/kernel/apic/io_apic.c
+++ b/arch/x86/kernel/apic/io_apic.c
@@ -1162,7 +1162,8 @@ __assign_irq_vector(int irq, struct irq_cfg *cfg, const struct cpumask *mask)
 	 * Also, we've got to be careful not to trash gate
 	 * 0x80, because int 0x80 is hm, kind of importantish. ;)
 	 */
-	static int current_vector = FIRST_DEVICE_VECTOR, current_offset = 0;
+	static int current_vector = FIRST_DEVICE_VECTOR + VECTOR_OFFSET_START;
+	static int current_offset = VECTOR_OFFSET_START % 8;
 	unsigned int old_vector;
 	int cpu, err;
 	cpumask_var_t tmp_mask;
-- 
1.6.5.2


--------------070704020001030904050005--
