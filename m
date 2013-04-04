From: Christoph Lameter <cl@linux.com>
Subject: Re: this cpu documentation
Date: Thu, 4 Apr 2013 14:41:08 +0000
Message-ID: <0000013dd57e7ad7-d5959142-ca41-4a53-9497-7559766aafc9-000000@email.amazonses.com>
References: <1364463761-32510-1-git-send-email-roy.qing.li@gmail.com> <1364475933.15753.36.camel@edumazet-glaptop> <0000013db16f1e1d-abcb7d9e-1c9d-4ef9-b4de-767bc0282ccf-000000@email.amazonses.com> <CAJFZqHzkGcFT_gcqgu=ktuig7UEoR4FVTUZF6G46=6n6FkYZ2A@mail.gmail.com>
 <0000013dc6307f44-940f2bf1-7556-4d9e-92ab-1a84d2a47ca8-000000@email.amazonses.com> <1364833887.5113.161.camel@edumazet-glaptop> <0000013dd1a20ebf-4a76fb06-4b9d-492e-9d77-4b3f43aceca7-000000@email.amazonses.com> <515F679E.8020203@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	RongQing Li <roy.qing.li@gmail.com>,
	Shan Wei <davidshan@tencent.com>, netdev@vger.kernel.org,
	Tejun Heo <htejun@gmail.com>
To: Randy Dunlap <rdunlap@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a9-66.smtp-out.amazonses.com ([54.240.9.66]:53670 "EHLO
	a9-66.smtp-out.amazonses.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761960Ab3DDOw3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 10:52:29 -0400
In-Reply-To: <515F679E.8020203@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Lameter <cl@linux.com>
Subject: this_cpu: Add documentation V2

Document the rationale and the way to use this_cpu operations.

V2: Improved after feedback from Randy Dunlap

Signed-off-by: Christoph Lameter <cl@linux.com>

Index: linux/Documentation/this_cpu_ops
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux/Documentation/this_cpu_ops	2013-04-04 09:40:06.431946280 -0500
@@ -0,0 +1,197 @@
+this_cpu operations
+-------------------
+
+this_cpu operations are a way of optimizing access to per cpu variables
+associated with the *currently* executing processor
+through the use of segment registers (or a dedicated register where the cpu
+permanently stored the beginning of the per cpu area for a specific
+processor).
+
+The this_cpu operations add a per cpu variable offset to the processor
+specific percpu base and encode that operation in the instruction operating
+on the per cpu variable.
+
+This meanthere are no atomicity issues between the calculation
+of the offset and the operation on the data. Therefore it is not necessary
+to disable preempt or interrupts to ensure that the processor is not changed
+between the calculation of the address and the operation on the data.
+
+Read-modify-write operations are of particular interest. Frequently
+processors have special lower latency instructions that can operate without
+the typical synchronization overhead but still provide some sort of relaxed
+atomicity guarantee. The x86 for example can execute RMV (Read Modify Write)
+instructions like inc/dec/cmpxchg without the lock prefix and the
+associated latency penalty.
+
+Access to the variable without the lock prefix is not synchronized but
+synchronization is not necessary since we are dealing with per cpu data
+specific to the currently executing processor. Only the current processor
+should be accessing that variable and therefore there are no concurirency
+issues with other processors in the system.
+
+On x86 the fs: or the gs: segment registers contain the base of the per cpu area. It is
+then possible to simply use the segment override to relocate a per cpu relative address
+to the proper per cpu area for the processor. So the relocation to the per cpu base
+is encoded in the instruction via a segment register prefix.
+
+For example:
+
+	DEFINE_PER_CPU(int, x);
+	int z;
+
+	z = this_cpu_read(x);
+
+results in a single instruction
+
+	mov ax, gs:[x]
+
+instead of a sequence of calculation of the address and then a fetch from
+that address which occurs with the percpu operations. Before this_cpu_ops
+such sequence also required preempt disable/enable to prevent the kernel from
+moving the thread to a different processor while the calculation is performed.
+
+
+The main use of the this_cpu operations has been to optimize counter operations.
+
+
+	this_cpu_inc(x)
+
+results in the following single instruction (no lock prefix!)
+
+	inc gs:[x]
+
+
+instead of the following operations required if there is no segment register.
+
+	int *y;
+	int cpu;
+
+	cpu = get_cpu();
+	y = per_cpu_ptr(&x, cpu);
+	(*y)++;
+	put_cpu();
+
+
+Note that these operations can only be used on percpu data that is reserved for
+a specific processor. Without disabling preemption in the surrounding code
+this_cpu_inc() will only guarantee that one of the percpu counters is correctly
+incremented. However, there is no guarantee that the OS will not move the process
+directly before or after the this_cpu instruction is executed. In general this
+means that the value of the individual counters for each processor are
+meaningless. The sum of all the per cpu counters is the only value that is of
+interest.
+
+Per cpu variables are used for performance reasons. Bouncing cache lines can
+be avoided if multiple processors concurrently go through the same code paths.
+Since each processor has its own per cpu variables no concurrent cacheline
+updates take place. The price that has to be paid for this optimization is
+the need to add up the per cpu counters when the value of the counter is
+needed.
+
+
+Special operations:
+-------------------
+
+	y = this_cpu_ptr(&x)
+
+Takes the offset of a per cpu variable (&x !) and returns the address of the
+per cpu variable that belongs to the currently executing processor.
+this_cpu_ptr avoids multiple steps that the common get_cpu/put_cpu sequence
+requires. No processor number is available. Instead the offset of the local
+per cpu area is simply added to the percpu offset.
+
+
+
+Per cpu variables and offsets
+-----------------------------
+
+Per cpu variables have *offsets* to the beginning of the percpu area. They do
+not have addresses although they look like that in the code. Offsets
+cannot be directly dereferenced. The offset must be added to a base pointer of
+a percpu area of a processor in order to form a valid address.
+
+Therefore the use of x or &x outside of the context of per cpu operations
+is invalid and will generally be treated like a NULL pointer dereference.
+
+In the context of per cpu operations
+
+	x is a per cpu variable. Most this_cpu operations take a cpu variable.
+
+	&x is the *offset* a per cpu variable. this_cpu_ptr() takes the offset
+		of a per cpu variable which makes this look a bit strange.
+
+
+
+Operations on a field of a per cpu structure
+--------------------------------------------
+
+Let's say we have a percpu structure
+
+	struct s {
+		int n,m;
+	};
+
+	DEFINE_PER_CPU(struct s, p);
+
+
+Operations on these fields are straightforward
+
+	this_cpu_inc(p.m)
+
+	z = this_cpu_cmpxchg(p.m, 0, 1);
+
+
+If we have an offset to struct s:
+
+	struct s __percpu *ps = &p;
+
+	z = this_cpu_dec(ps->m);
+
+	z = this_cpu_inc_return(ps->n);
+
+
+The calculation of the pointer may require the use of this_cpu_ptr() if we
+do not make use of this_cpu ops later to manipulate fields:
+
+	struct s *pp;
+
+	pp = this_cpu_ptr(&p);
+
+	pp->m--;
+
+	z = pp->n++;
+
+
+Variants of this_cpu ops
+-------------------------
+
+this_cpu ops are interrupt safe. Some architecture do not support these per
+cpu local operations. In that case the operation must be replaced by code
+that disables interrupts, then does the operations that are guaranteed to be
+atomic and then reenable interrupts. Doing so is expensive. If there are
+other reasons why the scheduler cannot change the processor we are executing
+on then there is no reason to disable interrupts. For that purpose
+the __this_cpu operations are provided. For example.
+
+	__this_cpu_inc(x);
+
+Will increment x and will not fallback to code that disables interrupts on
+platforms that cannot accomplish atomicity through address relocation and
+an Read-Modify-Write operation in the same instruction.
+
+
+
+&this_cpu_ptr(pp)->n vs this_cpu_ptr(&pp->n)
+--------------------------------------------
+
+The first operation takes the offset and forms an address and then adds
+the offset of the n field.
+
+The second one first adds the two offsets and then does the relocation.
+IMHO the second form looks cleaner and has an easier time with (). The
+second form also is consistent with the way this_cpu_read() and friends
+are used.
+
+
+Christoph Lameter, April 3rd, 2013
+
