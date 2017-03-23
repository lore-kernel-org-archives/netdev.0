From: Daniel Lezcano <daniel.lezcano@linaro.org>
Subject: [PATCH V8 1/3] irq: Add flags to request_percpu_irq function
Date: Thu, 23 Mar 2017 18:42:01 +0100
Message-ID: <1490290924-12958-1-git-send-email-daniel.lezcano@linaro.org>
Cc: linux-kernel@vger.kernel.org, peterz@infradead.org,
        nicolas.pitre@linaro.org, rafael@kernel.org,
        vincent.guittot@linaro.org, linux-snps-arc@lists.infradead.org,
        linux-arm-kernel@lists.infradead.org,
        xen-devel@lists.xenproject.org, kernel@stlinux.com,
        linux-samsung-soc@vger.kernel.org, netdev@vger.kernel.org,
        kvmarm@lists.cs.columbia.edu, kvm@vger.kernel.org
To: tglx@linutronix.de
Return-path: <linux-samsung-soc-owner@vger.kernel.org>
Sender: linux-samsung-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the next changes, we track the interrupts but we discard the timers as
that does not make sense. The next interrupt on a timer is predictable.

But, the API request_percpu_irq does not allow to pass a flag, hence specifying
if the interrupt type is a timer.

Solve this by passing a 'flags' parameter to the function and change all the
callers to pass IRQF_TIMER when the interrupt is a timer interrupt, zero
otherwise.

For now, in order to prevent a misusage of this parameter, only the IRQF_TIMER
flag is a valid parameter to be passed to the request_percpu_irq function.

Signed-off-by: Daniel Lezcano <daniel.lezcano@linaro.org>
---
 arch/arc/kernel/perf_event.c             |  2 +-
 arch/arc/kernel/smp.c                    |  2 +-
 arch/arm/kernel/smp_twd.c                |  3 ++-
 arch/arm/xen/enlighten.c                 |  2 +-
 drivers/clocksource/arc_timer.c          |  2 +-
 drivers/clocksource/arm_arch_timer.c     | 15 +++++++++------
 drivers/clocksource/arm_global_timer.c   |  2 +-
 drivers/clocksource/exynos_mct.c         |  2 +-
 drivers/clocksource/qcom-timer.c         |  2 +-
 drivers/clocksource/time-armada-370-xp.c |  2 +-
 drivers/clocksource/timer-nps.c          |  2 +-
 drivers/net/ethernet/marvell/mvneta.c    |  2 +-
 drivers/perf/arm_pmu.c                   |  2 +-
 include/linux/interrupt.h                |  5 +++--
 kernel/irq/manage.c                      | 11 ++++++++---
 virt/kvm/arm/arch_timer.c                |  5 +++--
 virt/kvm/arm/vgic/vgic-init.c            |  2 +-
 17 files changed, 37 insertions(+), 26 deletions(-)

diff --git a/arch/arc/kernel/perf_event.c b/arch/arc/kernel/perf_event.c
index 2ce24e7..2a90c7a 100644
--- a/arch/arc/kernel/perf_event.c
+++ b/arch/arc/kernel/perf_event.c
@@ -525,7 +525,7 @@ static int arc_pmu_device_probe(struct platform_device *pdev)
 		arc_pmu->irq = irq;
 
 		/* intc map function ensures irq_set_percpu_devid() called */
-		request_percpu_irq(irq, arc_pmu_intr, "ARC perf counters",
+		request_percpu_irq(irq, 0, arc_pmu_intr, "ARC perf counters",
 				   this_cpu_ptr(&arc_pmu_cpu));
 
 		on_each_cpu(arc_cpu_pmu_irq_init, &irq, 1);
diff --git a/arch/arc/kernel/smp.c b/arch/arc/kernel/smp.c
index f462671..5cdd3c9 100644
--- a/arch/arc/kernel/smp.c
+++ b/arch/arc/kernel/smp.c
@@ -381,7 +381,7 @@ int smp_ipi_irq_setup(int cpu, irq_hw_number_t hwirq)
 	if (!cpu) {
 		int rc;
 
-		rc = request_percpu_irq(virq, do_IPI, "IPI Interrupt", dev);
+		rc = request_percpu_irq(virq, 0, do_IPI, "IPI Interrupt", dev);
 		if (rc)
 			panic("Percpu IRQ request failed for %u\n", virq);
 	}
diff --git a/arch/arm/kernel/smp_twd.c b/arch/arm/kernel/smp_twd.c
index 895ae51..988f9b9 100644
--- a/arch/arm/kernel/smp_twd.c
+++ b/arch/arm/kernel/smp_twd.c
@@ -332,7 +332,8 @@ static int __init twd_local_timer_common_register(struct device_node *np)
 		goto out_free;
 	}
 
-	err = request_percpu_irq(twd_ppi, twd_handler, "twd", twd_evt);
+	err = request_percpu_irq(twd_ppi, IRQF_TIMER, twd_handler, "twd",
+				 twd_evt);
 	if (err) {
 		pr_err("twd: can't register interrupt %d (%d)\n", twd_ppi, err);
 		goto out_free;
diff --git a/arch/arm/xen/enlighten.c b/arch/arm/xen/enlighten.c
index 81e3217..2897f94 100644
--- a/arch/arm/xen/enlighten.c
+++ b/arch/arm/xen/enlighten.c
@@ -400,7 +400,7 @@ static int __init xen_guest_init(void)
 
 	xen_init_IRQ();
 
-	if (request_percpu_irq(xen_events_irq, xen_arm_callback,
+	if (request_percpu_irq(xen_events_irq, 0, xen_arm_callback,
 			       "events", &xen_vcpu)) {
 		pr_err("Error request IRQ %d\n", xen_events_irq);
 		return -EINVAL;
diff --git a/drivers/clocksource/arc_timer.c b/drivers/clocksource/arc_timer.c
index 7517f95..e78e306 100644
--- a/drivers/clocksource/arc_timer.c
+++ b/drivers/clocksource/arc_timer.c
@@ -301,7 +301,7 @@ static int __init arc_clockevent_setup(struct device_node *node)
 	}
 
 	/* Needs apriori irq_set_percpu_devid() done in intc map function */
-	ret = request_percpu_irq(arc_timer_irq, timer_irq_handler,
+	ret = request_percpu_irq(arc_timer_irq, IRQF_TIMER, timer_irq_handler,
 				 "Timer0 (per-cpu-tick)", evt);
 	if (ret) {
 		pr_err("clockevent: unable to request irq\n");
diff --git a/drivers/clocksource/arm_arch_timer.c b/drivers/clocksource/arm_arch_timer.c
index 7a8a411..11398ff 100644
--- a/drivers/clocksource/arm_arch_timer.c
+++ b/drivers/clocksource/arm_arch_timer.c
@@ -768,16 +768,19 @@ static int __init arch_timer_register(void)
 	ppi = arch_timer_ppi[arch_timer_uses_ppi];
 	switch (arch_timer_uses_ppi) {
 	case VIRT_PPI:
-		err = request_percpu_irq(ppi, arch_timer_handler_virt,
-					 "arch_timer", arch_timer_evt);
+		err = request_percpu_irq(ppi, IRQF_TIMER,
+					 arch_timer_handler_virt, "arch_timer",
+					 arch_timer_evt);
 		break;
 	case PHYS_SECURE_PPI:
 	case PHYS_NONSECURE_PPI:
-		err = request_percpu_irq(ppi, arch_timer_handler_phys,
-					 "arch_timer", arch_timer_evt);
+		err = request_percpu_irq(ppi, IRQF_TIMER,
+					 arch_timer_handler_phys, "arch_timer",
+					 arch_timer_evt);
 		if (!err && arch_timer_ppi[PHYS_NONSECURE_PPI]) {
 			ppi = arch_timer_ppi[PHYS_NONSECURE_PPI];
-			err = request_percpu_irq(ppi, arch_timer_handler_phys,
+			err = request_percpu_irq(ppi, IRQF_TIMER,
+						 arch_timer_handler_phys,
 						 "arch_timer", arch_timer_evt);
 			if (err)
 				free_percpu_irq(arch_timer_ppi[PHYS_SECURE_PPI],
@@ -785,7 +788,7 @@ static int __init arch_timer_register(void)
 		}
 		break;
 	case HYP_PPI:
-		err = request_percpu_irq(ppi, arch_timer_handler_phys,
+		err = request_percpu_irq(ppi, IRQF_TIMER, arch_timer_handler_phys,
 					 "arch_timer", arch_timer_evt);
 		break;
 	default:
diff --git a/drivers/clocksource/arm_global_timer.c b/drivers/clocksource/arm_global_timer.c
index 123ed20..1262d50 100644
--- a/drivers/clocksource/arm_global_timer.c
+++ b/drivers/clocksource/arm_global_timer.c
@@ -302,7 +302,7 @@ static int __init global_timer_of_register(struct device_node *np)
 		goto out_clk;
 	}
 
-	err = request_percpu_irq(gt_ppi, gt_clockevent_interrupt,
+	err = request_percpu_irq(gt_ppi, IRQF_TIMER, gt_clockevent_interrupt,
 				 "gt", gt_evt);
 	if (err) {
 		pr_warn("global-timer: can't register interrupt %d (%d)\n",
diff --git a/drivers/clocksource/exynos_mct.c b/drivers/clocksource/exynos_mct.c
index 670ff0f..6f174bb 100644
--- a/drivers/clocksource/exynos_mct.c
+++ b/drivers/clocksource/exynos_mct.c
@@ -524,7 +524,7 @@ static int __init exynos4_timer_resources(struct device_node *np, void __iomem *
 
 	if (mct_int_type == MCT_INT_PPI) {
 
-		err = request_percpu_irq(mct_irqs[MCT_L0_IRQ],
+		err = request_percpu_irq(mct_irqs[MCT_L0_IRQ], IRQF_TIMER,
 					 exynos4_mct_tick_isr, "MCT",
 					 &percpu_mct_tick);
 		WARN(err, "MCT: can't request IRQ %d (%d)\n",
diff --git a/drivers/clocksource/qcom-timer.c b/drivers/clocksource/qcom-timer.c
index ee358cd..80dc128 100644
--- a/drivers/clocksource/qcom-timer.c
+++ b/drivers/clocksource/qcom-timer.c
@@ -174,7 +174,7 @@ static int __init msm_timer_init(u32 dgt_hz, int sched_bits, int irq,
 	}
 
 	if (percpu)
-		res = request_percpu_irq(irq, msm_timer_interrupt,
+		res = request_percpu_irq(irq, IRQF_TIMER, msm_timer_interrupt,
 					 "gp_timer", msm_evt);
 
 	if (res) {
diff --git a/drivers/clocksource/time-armada-370-xp.c b/drivers/clocksource/time-armada-370-xp.c
index 4440aef..9643abd 100644
--- a/drivers/clocksource/time-armada-370-xp.c
+++ b/drivers/clocksource/time-armada-370-xp.c
@@ -309,7 +309,7 @@ static int __init armada_370_xp_timer_common_init(struct device_node *np)
 	/*
 	 * Setup clockevent timer (interrupt-driven).
 	 */
-	res = request_percpu_irq(armada_370_xp_clkevt_irq,
+	res = request_percpu_irq(armada_370_xp_clkevt_irq, IRQF_TIMER,
 				armada_370_xp_timer_interrupt,
 				"armada_370_xp_per_cpu_tick",
 				armada_370_xp_evt);
diff --git a/drivers/clocksource/timer-nps.c b/drivers/clocksource/timer-nps.c
index da1f798..dbdb622 100644
--- a/drivers/clocksource/timer-nps.c
+++ b/drivers/clocksource/timer-nps.c
@@ -256,7 +256,7 @@ static int __init nps_setup_clockevent(struct device_node *node)
 		return ret;
 
 	/* Needs apriori irq_set_percpu_devid() done in intc map function */
-	ret = request_percpu_irq(nps_timer0_irq, timer_irq_handler,
+	ret = request_percpu_irq(nps_timer0_irq, timer_irq_handler, IRQF_TIMER,
 				 "Timer0 (per-cpu-tick)",
 				 &nps_clockevent_device);
 	if (ret) {
diff --git a/drivers/net/ethernet/marvell/mvneta.c b/drivers/net/ethernet/marvell/mvneta.c
index 61dd446..8004f670 100644
--- a/drivers/net/ethernet/marvell/mvneta.c
+++ b/drivers/net/ethernet/marvell/mvneta.c
@@ -3517,7 +3517,7 @@ static int mvneta_open(struct net_device *dev)
 		ret = request_irq(pp->dev->irq, mvneta_isr, 0,
 				  dev->name, pp);
 	else
-		ret = request_percpu_irq(pp->dev->irq, mvneta_percpu_isr,
+		ret = request_percpu_irq(pp->dev->irq, 0, mvneta_percpu_isr,
 					 dev->name, pp->ports);
 	if (ret) {
 		netdev_err(pp->dev, "cannot request irq %d\n", pp->dev->irq);
diff --git a/drivers/perf/arm_pmu.c b/drivers/perf/arm_pmu.c
index 9612b84..0f5ab4a 100644
--- a/drivers/perf/arm_pmu.c
+++ b/drivers/perf/arm_pmu.c
@@ -661,7 +661,7 @@ static int cpu_pmu_request_irq(struct arm_pmu *cpu_pmu, irq_handler_t handler)
 
 	irq = platform_get_irq(pmu_device, 0);
 	if (irq > 0 && irq_is_percpu(irq)) {
-		err = request_percpu_irq(irq, handler, "arm-pmu",
+		err = request_percpu_irq(irq, 0, handler, "arm-pmu",
 					 &hw_events->percpu_pmu);
 		if (err) {
 			pr_err("unable to request IRQ%d for ARM PMU counters\n",
diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 53144e7..bc3b675 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -152,8 +152,9 @@ struct irqaction {
 			unsigned long flags, const char *name, void *dev_id);
 
 extern int __must_check
-request_percpu_irq(unsigned int irq, irq_handler_t handler,
-		   const char *devname, void __percpu *percpu_dev_id);
+request_percpu_irq(unsigned int irq, unsigned long flags,
+		   irq_handler_t handler,  const char *devname,
+		   void __percpu *percpu_dev_id);
 
 extern void free_irq(unsigned int, void *);
 extern void free_percpu_irq(unsigned int, void __percpu *);
diff --git a/kernel/irq/manage.c b/kernel/irq/manage.c
index a4afe5c..c0a23e2 100644
--- a/kernel/irq/manage.c
+++ b/kernel/irq/manage.c
@@ -1951,6 +1951,7 @@ int setup_percpu_irq(unsigned int irq, struct irqaction *act)
 /**
  *	request_percpu_irq - allocate a percpu interrupt line
  *	@irq: Interrupt line to allocate
+ *	@flags: Interrupt type flags (IRQF_TIMER only)
  *	@handler: Function to be called when the IRQ occurs.
  *	@devname: An ascii name for the claiming device
  *	@dev_id: A percpu cookie passed back to the handler function
@@ -1964,8 +1965,9 @@ int setup_percpu_irq(unsigned int irq, struct irqaction *act)
  *	the handler gets called with the interrupted CPU's instance of
  *	that variable.
  */
-int request_percpu_irq(unsigned int irq, irq_handler_t handler,
-		       const char *devname, void __percpu *dev_id)
+int request_percpu_irq(unsigned int irq, unsigned long flags,
+		       irq_handler_t handler, const char *devname,
+		       void __percpu *dev_id)
 {
 	struct irqaction *action;
 	struct irq_desc *desc;
@@ -1979,12 +1981,15 @@ int request_percpu_irq(unsigned int irq, irq_handler_t handler,
 	    !irq_settings_is_per_cpu_devid(desc))
 		return -EINVAL;
 
+	if (flags && flags != IRQF_TIMER)
+		return -EINVAL;
+
 	action = kzalloc(sizeof(struct irqaction), GFP_KERNEL);
 	if (!action)
 		return -ENOMEM;
 
 	action->handler = handler;
-	action->flags = IRQF_PERCPU | IRQF_NO_SUSPEND;
+	action->flags = flags | IRQF_PERCPU | IRQF_NO_SUSPEND;
 	action->name = devname;
 	action->percpu_dev_id = dev_id;
 
diff --git a/virt/kvm/arm/arch_timer.c b/virt/kvm/arm/arch_timer.c
index 35d7100..54809c8 100644
--- a/virt/kvm/arm/arch_timer.c
+++ b/virt/kvm/arm/arch_timer.c
@@ -523,8 +523,9 @@ int kvm_timer_hyp_init(void)
 		host_vtimer_irq_flags = IRQF_TRIGGER_LOW;
 	}
 
-	err = request_percpu_irq(host_vtimer_irq, kvm_arch_timer_handler,
-				 "kvm guest timer", kvm_get_running_vcpus());
+	err = request_percpu_irq(host_vtimer_irq, IRQF_TIMER,
+				 kvm_arch_timer_handler, "kvm guest timer",
+				 kvm_get_running_vcpus());
 	if (err) {
 		kvm_err("kvm_arch_timer: can't request interrupt %d (%d)\n",
 			host_vtimer_irq, err);
diff --git a/virt/kvm/arm/vgic/vgic-init.c b/virt/kvm/arm/vgic/vgic-init.c
index 276139a..a34d315 100644
--- a/virt/kvm/arm/vgic/vgic-init.c
+++ b/virt/kvm/arm/vgic/vgic-init.c
@@ -430,7 +430,7 @@ int kvm_vgic_hyp_init(void)
 		return ret;
 
 	kvm_vgic_global_state.maint_irq = gic_kvm_info->maint_irq;
-	ret = request_percpu_irq(kvm_vgic_global_state.maint_irq,
+	ret = request_percpu_irq(kvm_vgic_global_state.maint_irq, 0,
 				 vgic_maintenance_handler,
 				 "vgic", kvm_get_running_vcpus());
 	if (ret) {
-- 
1.9.1
