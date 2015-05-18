From: p.kosyh@gmail.com
Subject: __assign_irq_vector (x86) and irq vectors exhaust
Date: Mon, 18 May 2015 15:57:45 +0300
Message-ID: <20150518125745.GA10966@peter-bsd.cuba.int>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YZ5djTAD1cGYuMQK"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f42.google.com ([209.85.215.42]:35092 "EHLO
	mail-la0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbbERM5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2015 08:57:49 -0400
Received: by labbd9 with SMTP id bd9so218725458lab.2
        for <netdev@vger.kernel.org>; Mon, 18 May 2015 05:57:47 -0700 (PDT)
Received: from localhost ([83.220.32.68])
        by mx.google.com with ESMTPSA id h3sm2690917lbj.19.2015.05.18.05.57.46
        for <netdev@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 May 2015 05:57:47 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--YZ5djTAD1cGYuMQK
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline

Hello all!

Playing with 10Gb network adapters and /proc/irq/<nr>/smp_affinity 
we found that sometimes we can not move interrupt on selected cpu.

After digging source code we found, that
arch/x86/kernel/apic/vector.c: __assign_irq_vector (4.0 kernel)
allocates vectors in not optimal way.

For example, we have a 32 cpu system with lot of 10Gb cards (each of
them has 32 msi-x irqs). Even if card is not used, it allocates an irq
vector after probing (pci_enable_msix()). We have about ~200 vectors limit 
per cpu (on x86), and __assign_irq_vector allocates them filling cpus one 
by one (see at cpumask_first_and()):

	...

	cpumask_clear(cfg->old_domain);
	cpu = cpumask_first_and(mask, cpu_online_mask);
	/* here we are got 1st non zero bit <----------- */
	while (cpu < nr_cpu_ids) {
		int new_cpu, vector, offset;

		apic->vector_allocation_domain(cpu, tmp_mask, mask);

		...

		if (unlikely(current_vector == vector)) {
		cpumask_or(cfg->old_domain, cfg->old_domain,
tmp_mask);
			cpumask_andnot(tmp_mask, mask, cfg->old_domain);
			cpu = cpumask_first_and(tmp_mask,
cpu_online_mask);
			/* get next non zero bit <------------ */
			continue;
		}

		...

So, after our system is up, we have a situation when some cpus
has no free vectors at all!! And some cpus has all vectors free.

Userspace do not know nothing about this exhaust!!! So after writing 
mask to the smp_affinity we can got a situation that irq can not be moved.
Silently.

It is not a critical thing when you are doing all stuff by
hands, but if we are using irq balancer, like birq (http://birq.libcode.org) 
or any other, this problem becomes critical one! Balancer has not idea, why irq
is still not moved!!! Btw, the other problem is napi and softirq sticking
(http://comments.gmane.org/gmane.linux.network/322914). But i
already wrote about this problem and possible solution.

Anyway, it's like a bad idea to allocate cpu one after one and not to sparse 
irq vectors.

The solution is simple. Instead of using cpumask_first_and(), try to get
RANDOM bit. I wrote dirty realization that works for me. Of
course, it must be done in right way, but i have attached patch for
illustration. 

Hope, it help someone else....

Thank you!



-- 
Peter Kosyh

--YZ5djTAD1cGYuMQK
Content-Type: text/x-diff; charset=utf-8
Content-Disposition: attachment; filename="linux-3.10-irq-rr.patch"

diff -Nur linux-3.10.65/arch/x86/kernel/apic/io_apic.c linux-3.10.65-irq-rr/arch/x86/kernel/apic/io_apic.c
--- linux-3.10.65/arch/x86/kernel/apic/io_apic.c	2015-01-16 18:00:00.000000000 +0300
+++ linux-3.10.65-irq-rr/arch/x86/kernel/apic/io_apic.c	2015-05-14 10:29:45.618572555 +0300
@@ -1072,6 +1072,7 @@
 {
 	raw_spin_unlock(&vector_lock);
 }
+extern int cpumask_any_and_real(const struct cpumask *src1p, const struct cpumask *src2p);
 
 static int
 __assign_irq_vector(int irq, struct irq_cfg *cfg, const struct cpumask *mask)
@@ -1101,7 +1102,7 @@
 	/* Only try and allocate irqs on cpus that are present */
 	err = -ENOSPC;
 	cpumask_clear(cfg->old_domain);
-	cpu = cpumask_first_and(mask, cpu_online_mask);
+	cpu = cpumask_any_and_real(mask, cpu_online_mask);
 	while (cpu < nr_cpu_ids) {
 		int new_cpu, vector, offset;
 
@@ -1135,7 +1136,7 @@
 		if (unlikely(current_vector == vector)) {
 			cpumask_or(cfg->old_domain, cfg->old_domain, tmp_mask);
 			cpumask_andnot(tmp_mask, mask, cfg->old_domain);
-			cpu = cpumask_first_and(tmp_mask, cpu_online_mask);
+			cpu = cpumask_any_and_real(tmp_mask, cpu_online_mask);
 			continue;
 		}
 
diff -Nur linux-3.10.65/lib/cpumask.c linux-3.10.65-irq-rr/lib/cpumask.c
--- linux-3.10.65/lib/cpumask.c	2015-01-16 18:00:00.000000000 +0300
+++ linux-3.10.65-irq-rr/lib/cpumask.c	2015-05-14 10:28:28.410574546 +0300
@@ -164,3 +164,31 @@
 	free_bootmem(__pa(mask), cpumask_size());
 }
 #endif
+
+int cpumask_any_and_real(const struct cpumask *src1p,
+		const struct cpumask *src2p)
+{
+	int i;
+	int n = 0;
+	static int seed = 0;
+
+	for_each_cpu_and(i, src1p, src2p) { /* total number of cpus */
+		n ++;
+	}
+
+	if (!n) /* no cpus */
+		return nr_cpu_ids;
+
+	n = (seed ^ jiffies) % n;
+
+	seed ++;
+
+	for_each_cpu_and(i, src1p, src2p) { /* total number of cpus */
+		if (!n)
+			return i;
+		n --;
+	}
+	return nr_cpu_ids;
+}
+
+EXPORT_SYMBOL(cpumask_any_and_real);

--YZ5djTAD1cGYuMQK--
