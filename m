From: Viresh Kumar <viresh.kumar@linaro.org>
Subject: [PATCH] bus: subsys: update return type of ->remove_dev() to void
Date: Thu, 30 Jul 2015 15:04:01 +0530
Message-ID: <02c0569741812b655edde5124c3e2937bb79f9f8.1438248445.git.viresh.kumar@linaro.org>
Cc: Rafael Wysocki <rjw@rjwysocki.net>,
	Viresh Kumar <viresh.kumar@linaro.org>,
	Borislav Petkov <bp@alien8.de>,
	Chris Metcalf <cmetcalf@ezchip.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	"H. Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@redhat.com>,
	Joe Perches <joe@perches.com>, Joerg Roedel <jroedel@suse.de>,
	linux-kernel@vger.kernel.org (open list),
	linux-pm@vger.kernel.org (open list:CPU FREQUENCY DRIVERS),
	linux-sh@vger.kernel.org (open list:SUPERH),
	"Luis R. Rodriguez" <mcgrof@suse.com>,
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	Nicolas Iooss <nicolas.iooss_linux@m4x.org>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	x86@kernel.org (maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT))
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-sh-owner@vger.kernel.org>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Its return value is not used by the subsys core and nothing meaningful
can be done with it, even if we want to use it. The subsys device is
anyway getting removed.

Update prototype of ->remove_dev() to make its return type as void. Fix
all usage sites as well.

Signed-off-by: Viresh Kumar <viresh.kumar@linaro.org>
---
Based of 4.2-rc4.
---
 arch/sh/kernel/cpu/sh4/sq.c          |  3 +--
 arch/tile/kernel/sysfs.c             | 11 ++++-------
 arch/x86/kernel/cpu/microcode/core.c |  5 ++---
 drivers/cpufreq/cpufreq.c            | 12 +++++-------
 drivers/net/rionet.c                 |  4 +---
 include/linux/device.h               |  2 +-
 6 files changed, 14 insertions(+), 23 deletions(-)

diff --git a/arch/sh/kernel/cpu/sh4/sq.c b/arch/sh/kernel/cpu/sh4/sq.c
index 0a47bd3e7bee..4ca78ed71ad2 100644
--- a/arch/sh/kernel/cpu/sh4/sq.c
+++ b/arch/sh/kernel/cpu/sh4/sq.c
@@ -355,13 +355,12 @@ static int sq_dev_add(struct device *dev, struct subsys_interface *sif)
 	return error;
 }
 
-static int sq_dev_remove(struct device *dev, struct subsys_interface *sif)
+static void sq_dev_remove(struct device *dev, struct subsys_interface *sif)
 {
 	unsigned int cpu = dev->id;
 	struct kobject *kobj = sq_kobject[cpu];
 
 	kobject_put(kobj);
-	return 0;
 }
 
 static struct subsys_interface sq_interface = {
diff --git a/arch/tile/kernel/sysfs.c b/arch/tile/kernel/sysfs.c
index a3ed12f8f83b..825867c53853 100644
--- a/arch/tile/kernel/sysfs.c
+++ b/arch/tile/kernel/sysfs.c
@@ -198,16 +198,13 @@ static int hv_stats_device_add(struct device *dev, struct subsys_interface *sif)
 	return err;
 }
 
-static int hv_stats_device_remove(struct device *dev,
-				  struct subsys_interface *sif)
+static void hv_stats_device_remove(struct device *dev,
+				   struct subsys_interface *sif)
 {
 	int cpu = dev->id;
 
-	if (!cpu_online(cpu))
-		return 0;
-
-	sysfs_remove_file(&dev->kobj, &dev_attr_hv_stats.attr);
-	return 0;
+	if (cpu_online(cpu))
+		sysfs_remove_file(&dev->kobj, &dev_attr_hv_stats.attr);
 }
 
 
diff --git a/arch/x86/kernel/cpu/microcode/core.c b/arch/x86/kernel/cpu/microcode/core.c
index 6236a54a63f4..3c986390058a 100644
--- a/arch/x86/kernel/cpu/microcode/core.c
+++ b/arch/x86/kernel/cpu/microcode/core.c
@@ -377,17 +377,16 @@ static int mc_device_add(struct device *dev, struct subsys_interface *sif)
 	return err;
 }
 
-static int mc_device_remove(struct device *dev, struct subsys_interface *sif)
+static void mc_device_remove(struct device *dev, struct subsys_interface *sif)
 {
 	int cpu = dev->id;
 
 	if (!cpu_online(cpu))
-		return 0;
+		return;
 
 	pr_debug("CPU%d removed\n", cpu);
 	microcode_fini_cpu(cpu);
 	sysfs_remove_group(&dev->kobj, &mc_attr_group);
-	return 0;
 }
 
 static struct subsys_interface mc_cpu_interface = {
diff --git a/drivers/cpufreq/cpufreq.c b/drivers/cpufreq/cpufreq.c
index 26063afb3eba..6da25c10bdfd 100644
--- a/drivers/cpufreq/cpufreq.c
+++ b/drivers/cpufreq/cpufreq.c
@@ -1518,7 +1518,7 @@ static int __cpufreq_remove_dev_finish(struct device *dev,
  *
  * Removes the cpufreq interface for a CPU device.
  */
-static int cpufreq_remove_dev(struct device *dev, struct subsys_interface *sif)
+static void cpufreq_remove_dev(struct device *dev, struct subsys_interface *sif)
 {
 	unsigned int cpu = dev->id;
 	int ret;
@@ -1533,7 +1533,7 @@ static int cpufreq_remove_dev(struct device *dev, struct subsys_interface *sif)
 		struct cpumask mask;
 
 		if (!policy)
-			return 0;
+			return;
 
 		cpumask_copy(&mask, policy->related_cpus);
 		cpumask_clear_cpu(cpu, &mask);
@@ -1544,19 +1544,17 @@ static int cpufreq_remove_dev(struct device *dev, struct subsys_interface *sif)
 		 */
 		if (cpumask_intersects(&mask, cpu_present_mask)) {
 			remove_cpu_dev_symlink(policy, cpu);
-			return 0;
+			return;
 		}
 
 		cpufreq_policy_free(policy, true);
-		return 0;
+		return;
 	}
 
 	ret = __cpufreq_remove_dev_prepare(dev, sif);
 
 	if (!ret)
-		ret = __cpufreq_remove_dev_finish(dev, sif);
-
-	return ret;
+		__cpufreq_remove_dev_finish(dev, sif);
 }
 
 static void handle_update(struct work_struct *work)
diff --git a/drivers/net/rionet.c b/drivers/net/rionet.c
index dac7a0d9bb46..01f08a7751f7 100644
--- a/drivers/net/rionet.c
+++ b/drivers/net/rionet.c
@@ -396,7 +396,7 @@ static int rionet_close(struct net_device *ndev)
 	return 0;
 }
 
-static int rionet_remove_dev(struct device *dev, struct subsys_interface *sif)
+static void rionet_remove_dev(struct device *dev, struct subsys_interface *sif)
 {
 	struct rio_dev *rdev = to_rio_dev(dev);
 	unsigned char netid = rdev->net->hport->id;
@@ -416,8 +416,6 @@ static int rionet_remove_dev(struct device *dev, struct subsys_interface *sif)
 			}
 		}
 	}
-
-	return 0;
 }
 
 static void rionet_get_drvinfo(struct net_device *ndev,
diff --git a/include/linux/device.h b/include/linux/device.h
index a2b4ea70a946..1225f98e9240 100644
--- a/include/linux/device.h
+++ b/include/linux/device.h
@@ -341,7 +341,7 @@ struct subsys_interface {
 	struct bus_type *subsys;
 	struct list_head node;
 	int (*add_dev)(struct device *dev, struct subsys_interface *sif);
-	int (*remove_dev)(struct device *dev, struct subsys_interface *sif);
+	void (*remove_dev)(struct device *dev, struct subsys_interface *sif);
 };
 
 int subsys_interface_register(struct subsys_interface *sif);
-- 
2.4.0

